#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    https://shiny.posit.co/
#

library(shiny)
library(dplyr)


ui <- fluidPage(
  selectInput("dataset", label = "Dataset", choices = ls("package:datasets")),
  verbatimTextOutput("glimpse"),
  verbatimTextOutput("summary"),
  tableOutput("table")
)




server <- function(input, output, session) {
  
  output$glimpse <- renderPrint({
    dataset <- get(input$dataset, "package:datasets")
    glimpse(dataset)
  })
  
  
  output$summary <- renderPrint({
    dataset <- get(input$dataset, "package:datasets")
    summary(dataset)
  })
  
}

# Run the application 
shinyApp(ui = ui, server = server)
