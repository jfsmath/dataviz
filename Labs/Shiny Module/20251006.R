## 1st component: loading libraries
library(shiny)



# UI: user interface
# controls what your app looks like

ui <- fluidPage(
  
  "Hello Data 350!",
  
  # selects datasets from base R
  # input control: allows us to pick a value
  selectInput(
    "dataset350",
    label = "Dataset to choose from",
    choices = ls("package:datasets")),
  
  ## naming convention for input
  ## {howToChoose}Input
  
  # example: slider input
  sliderInput(
    "my_number",
    "Choose your favorite number",
    value = 50, # gives a default
    min = 0,
    max = 100
    ),
  
  
  
  # output control
  # tells shiny where/how to render output
  
  # I want to produce a data summary for
  # the chosen dataset
  verbatimTextOutput("summary1106"),
  
  # testing the text output
  textOutput("summary1106_text"),
  
  # Exercise: output the selected number as text
  textOutput("fav_num"),
  
  # I want a data table
  tableOutput("table2025"),
  
  # I want a dynamic data table
  dataTableOutput("table2025_dynamic")
  
  
  # Naming convention for output:
  # <outputType>Output
)



## render{Type} examples:
## renderText: print text, paired with textOutput()
## renderPrint: print R output, paired with verbatimTextOuput()
## renderTable <---> tableOutput()
## renderDataTable <---> dataTableOutput(), dynamic 
## renderPlot() <---> plotOutput()
## many more




# server: controls the behavior of the app

server <- function(input, output, session) {
  # define the mechanism of the server function
  
  # I want to produce a data summary for
  # the chosen dataset
  output$summary1106 <- renderPrint({
    # extract this dataset according to user input
    # use the get() function
    df <- get(input$dataset350, "package:datasets")
    summary(df)
  })
  
  # the input id "table2025" should be matched here
  output$table2025 <- renderTable({
    df <- get(input$dataset350, "package:datasets")
    df
  })
  
  # text output
  output$summary1106_text <- renderText({
    df <- get(input$dataset350, "package:datasets")
    summary(df)
  })
  
  # dynamic data table
  output$table2025_dynamic <- renderDataTable({
    df <- get(input$dataset350, "package:datasets")
    df
  })
  
  # Exercise: output selected number
  output$fav_num <- renderText({
    input$my_number
  })
  

}




shinyApp(ui, server)