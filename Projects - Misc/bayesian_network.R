library(shiny)
library(gRain)

# UI
ui <- fluidPage(
  titlePanel("Bayesian Network: Alarm Model with Editable CPTs"),
  sidebarLayout(
    sidebarPanel(
      h4("Set Evidence"),
      selectInput("j_val", "Jaheira Calls (J)", choices = c("None", "TRUE", "FALSE")),
      selectInput("m_val", "Minthara Calls (M)", choices = c("None", "TRUE", "FALSE")),
      selectInput("a_val", "Alarm (A)", choices = c("None", "TRUE", "FALSE")),
      actionButton("reset", "Reset Evidence"),
      
      tags$hr(),
      h4("Tune CPTs"),
      sliderInput("pB", "P(B=TRUE)", min = 0, max = 1, value = 0.001),
      sliderInput("pE", "P(E=TRUE)", min = 0, max = 1, value = 0.002),
      sliderInput("pA11", "P(A=TRUE | B=TRUE, E=TRUE)", min = 0, max = 1, value = 0.95),
      sliderInput("pA10", "P(A=TRUE | B=TRUE, E=FALSE)", min = 0, max = 1, value = 0.94),
      sliderInput("pA01", "P(A=TRUE | B=FALSE, E=TRUE)", min = 0, max = 1, value = 0.29),
      sliderInput("pA00", "P(A=TRUE | B=FALSE, E=FALSE)", min = 0, max = 1, value = 0.001),
      sliderInput("pJ1", "P(J=TRUE | A=TRUE)", min = 0, max = 1, value = 0.9),
      sliderInput("pJ0", "P(J=TRUE | A=FALSE)", min = 0, max = 1, value = 0.05),
      sliderInput("pM1", "P(M=TRUE | A=TRUE)", min = 0, max = 1, value = 0.7),
      sliderInput("pM0", "P(M=TRUE | A=FALSE)", min = 0, max = 1, value = 0.01)
    ),
    mainPanel(
      h4("Posterior Probability Table (Burglary and Earthquake)"),
      tableOutput("posterior"),
      br(),
      
      plotOutput("heatmapPlot", height = "250px")
    )
  )
)



server <- function(input, output, session) {
  # Reactive expression: builds the net with current CPTs
  buildNet <- reactive({
    cpt_B <- cptable(~B, values = c(input$pB, 1 - input$pB), levels = c("TRUE", "FALSE"))
    cpt_E <- cptable(~E, values = c(input$pE, 1 - input$pE), levels = c("TRUE", "FALSE"))
    cpt_A <- cptable(~A | B:E, values = c(
      input$pA11, 1 - input$pA11,
      input$pA10, 1 - input$pA10,
      input$pA01, 1 - input$pA01,
      input$pA00, 1 - input$pA00
    ), levels = c("TRUE", "FALSE"))
    cpt_J <- cptable(~J | A, values = c(input$pJ1, 1 - input$pJ1, input$pJ0, 1 - input$pJ0),
                     levels = c("TRUE", "FALSE"))
    cpt_M <- cptable(~M | A, values = c(input$pM1, 1 - input$pM1, input$pM0, 1 - input$pM0),
                     levels = c("TRUE", "FALSE"))
    
    plist <- compileCPT(list(cpt_B, cpt_E, cpt_A, cpt_J, cpt_M))
    grain(plist)
  })
  
  # Reactive expression: applies evidence to the network
  netWithEvidence <- reactive({
    ev <- list()
    if (input$j_val != "None") ev$J <- input$j_val
    if (input$m_val != "None") ev$M <- input$m_val
    if (input$a_val != "None") ev$A <- input$a_val
    setEvidence(buildNet(), evidence = ev)
  })
  
  # Reset input controls only (safe)
  observeEvent(input$reset, {
    updateSelectInput(session, "j_val", selected = "None")
    updateSelectInput(session, "m_val", selected = "None")
    updateSelectInput(session, "a_val", selected = "None")
  })
  
  # Render posterior for B and E
  output$posterior <- renderTable({
    q <- querygrain(netWithEvidence(), nodes = c("B", "E"), type = "marginal")
    do.call(rbind, lapply(names(q), function(v) {
      data.frame(
        Variable = v,
        State = names(q[[v]]),
        Probability = round(as.vector(q[[v]]), 4)
      )
    }))
  })
  
  
  output$heatmapPlot <- renderPlot({
    q <- querygrain(netWithEvidence(), nodes = c("B", "E"), type = "marginal")
    
    df <- do.call(rbind, lapply(names(q), function(var) {
      data.frame(
        Variable = var,
        State = names(q[[var]]),
        Probability = as.vector(q[[var]])
      )
    }))
    
    ggplot(df, aes(x = Variable, y = State, fill = Probability)) +
      geom_tile(color = "white", linewidth = 1) +
      geom_text(aes(label = round(Probability, 3)), color = "black", size = 5) +
      scale_fill_gradient(low = "white", high = "steelblue") +
      labs(title = "Heatmap of Posterior Probabilities", x = "", y = "") +
      theme_minimal(base_size = 14) +
      theme(panel.grid = element_blank())
  })
}







shinyApp(ui, server)
