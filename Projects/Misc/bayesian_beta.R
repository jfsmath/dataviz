# More Involved Bayesian Updating Shiny App
library(shiny)
library(ggplot2)

ui <- fluidPage(
  titlePanel("Bayesian Updating for Beta-Binomial"),
  sidebarLayout(
    sidebarPanel(
      numericInput("alpha", "Prior α (alpha)", value = 1, min = 0.1, step = 0.1),
      numericInput("beta", "Prior β (beta)", value = 1, min = 0.1, step = 0.1),
      sliderInput("true_p", "True Probability of Success (θ)", min = 0, max = 1, value = 0.6, step = 0.01),
      actionButton("takeShot", "Take 1 Shot"),
      actionButton("take10Shots", "Take 10 Shots"),
      actionButton("reset", "Reset"),
      verbatimTextOutput("status")
    ),
    mainPanel(
      plotOutput("distPlot", height = "500px")
    )
  )
)

server <- function(input, output, session) {
  # Reactive values to track state
  values <- reactiveValues(
    hits = 0,
    misses = 0,
    results = c(),
    count = 0
  )
  
  observeEvent(input$takeShot, {
    shot <- rbinom(1, 1, input$true_p)
    values$count <- values$count + 1
    values$results <- c(values$results, shot)
    if (shot == 1) values$hits <- values$hits + 1 else values$misses <- values$misses + 1
  })
  
  observeEvent(input$take10Shots, {
    shots <- rbinom(10, 1, input$true_p)
    values$count <- values$count + 10
    values$results <- c(values$results, shots)
    values$hits <- values$hits + sum(shots)
    values$misses <- values$misses + sum(1 - shots)
  })
  
  observeEvent(input$reset, {
    values$hits <- 0
    values$misses <- 0
    values$count <- 0
    values$results <- c()
  })
  
  output$status <- renderText({
    if (values$count == 0) return("No shots taken yet.")
    paste("Shots taken:", values$count,
          "| Hits:", values$hits,
          "| Misses:", values$misses)
  })
  
  output$distPlot <- renderPlot({
    theta <- seq(0, 1, length.out = 500)
    prior <- dbeta(theta, input$alpha, input$beta)
    
    if (values$count == 0) {
      # No shots yet — only plot the prior
      ggplot(data.frame(theta = theta, density = prior), aes(x = theta, y = density)) +
        geom_line(color = "black", size = 1.5) +
        labs(x = expression(theta), y = "Density",
             title = "Prior Distribution Only",
             subtitle = paste("Prior: Beta(", input$alpha, ",", input$beta, ")")) +
        theme_minimal() +
        theme(text = element_text(size = 14))
    } else {
      # Plot prior and posterior together
      posterior <- dbeta(theta, input$alpha + values$hits, input$beta + values$misses)
      
      df <- data.frame(
        theta = rep(theta, 2),
        density = c(prior, posterior),
        type = factor(rep(c("Prior", "Posterior"), each = length(theta)),
                      levels = c("Prior", "Posterior"))
      )
      
      ggplot(df, aes(x = theta, y = density, color = type)) +
        geom_line(size = 1.5) +
        labs(x = expression(theta), y = "Density",
             title = "Bayesian Updating",
             subtitle = paste("Shots:", values$count,
                              "| Hits:", values$hits,
                              "| Misses:", values$misses)) +
        scale_color_manual(values = c("Prior" = "red", "Posterior" = "blue")) +
        theme_minimal() +
        theme(legend.title = element_blank(), text = element_text(size = 14))
    }
  })
}

shinyApp(ui, server)
