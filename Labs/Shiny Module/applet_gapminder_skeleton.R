library(shiny)
library(gapminder)
library(ggplot2)
library(dplyr)





ui <- fluidPage(
  
  titlePanel("Gapminder Dataset EDA Example App"),
  
  sidebarLayout(
    
    
    # sidebar for variable selections
    sidebarPanel(
      
      # specify the width
      width = 2,
      
      # header for the sidebar
      h3("Variable Selections"),
      
      
      # want: 
      # checkboxes for continents
      # double slider for years
      # dropdown for x and y variables 
      
      
      # Continents Selection
      # Consider the unique() function
      # Group allows you to select multiple --> a list of characters
      checkboxGroupInput(
        inputId = "continents_select",
        label = "Select Continents:",
        # choices = c("Asia", "Americas", etc.)
        choices = unique(gapminder$continent),
        selected = unique(gapminder$continent) # default selection
      ),
      
      
      
      # Year Range Selection
      # consider the min() and max() functions
      # this will produce c(min, max)
      sliderInput(
        inputId = "year_range",
        label = "Select Year Range:",
        min = min(gapminder$year),
        max = max(gapminder$year),
        value = c(min(gapminder$year), max(gapminder$year)), # default choice
        step = 5 # the jump when you slide, see from unique(gapminder$year)
      ),
      
      # X variable selection
      selectInput(
        inputId = "x_var",
        label = "Select X-axis Variable:",
        
        # use a dictionary so that the variable name makes sense to the users
        # good practice, WILL DEDUCT POINTS
        choices = c("Life Expectancy" = "lifeExp", 
                    "GDP per Capita" = "gdpPercap", 
                    "Population" = "pop"), 
        
        selected = "gdpPercap"
        
      ),
      
      selectInput(
        inputId = "y_var",
        label = "Select Y-axis Variable:",
        choices = c("Life Expectancy" = "lifeExp", 
                    "GDP per Capita" = "gdpPercap", 
                    "Population" = "pop"),
        selected = "lifeExp"
      ),
      
      # a checkbox for scaling the x-axis
      checkboxInput("log_scaleX", "Use logarithmic scale for the x-asis", TRUE),
      
      h4("Smoothing Model"),
      
      # a checkbox for trend analysis (regression)
      fluidRow(
        column(5, checkboxInput("regression", "Plot regression model", TRUE)),
        column(5, checkboxInput("std_err", "Plot standard error", FALSE)),
      ),
      
      # a checkbox for grouping the continent
      checkboxInput("group_continent", "Group by Continents", FALSE),
      
      # a dropdown for choosing regression model
      # Dropdown for selecting regression model
      selectInput(
        inputId = "reg_model",
        label = "Choose Regression Model:",
        choices = c("Linear Model" = "lm", 
                    "LOESS" = "loess", 
                    "Generalized Additive Model" = "gam", 
                    "None" = "none"),
        selected = "gam"
      ),

    ),
    
    
    
    # main panel for plotting and statistical summary
    # display the plot and some statistics using summary()
    
    mainPanel(
      fluidRow(
        column(8, 
               fluidRow(h3("Visualization Panel"), plotOutput("scatterPlot")),
               fluidRow(h3("Data Summary"), verbatimTextOutput("dataSummary")))),
    )
    
    
  )
  
)



server <- function(input, output, session) {
  
  # filter the data according to the input
  filtered_data <- reactive({
    # Your code
  })
  
  # a named vector for labeling
  dyna_labels <- c(
    lifeExp = "Life Expectancy (in years)",
    pop = "Population",
    gdpPercap = "GDP per Capita (in $)")
  
  
  
  # render the plot and the data summary
  
  
  # data summary for life exp, pop, and gdppercap
  output$dataSummary <- renderPrint({
    # Your code
  })
  
  
  
  ## plot rendering
  output$scatterPlot <- renderPlot({ 
    # Your Code 
    })
  
  
}

shinyApp(ui, server)