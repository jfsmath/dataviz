library(shiny)

ui <- fluidPage(
  selectInput("my_year", "Select Manufacture Year", choices = unique(mpg$year), selected = mpg$year[1]),
  actionButton("generate_plot", "Plot it!"),
  plotOutput("plot")
)

server <- function(input, output, session) {
  
  data <- eventReactive(input$generate_plot, {mpg |> filter(year == input$my_year)})
  
  output$plot <- renderPlot({
    data() |> ggplot() + geom_point(aes(x = displ, y = hwy))
  })
  
}

shinyApp(ui, server)