library(shiny)
library(gapminder)
library(ggplot2)
library(tidyverse)


# the plotly library is for interactivity with the plots
library(plotly) 



ui <- fluidPage(
  
  titlePanel("Gapminder Dataset EDA Example App"),
  
  sidebarLayout(
    
    
    # sidebar for variable selections
    sidebarPanel(
      
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
      
      # a dropdown for choosing regression model
      # Dropdown for selecting regression model
      selectInput(
        inputId = "reg_model",
        label = "Choose Regression Model:",
        choices = c("Linear Model" = "lm", 
                    "LOESS" = "loess", 
                    "Generalized Additive Model" = "gam", 
                    "None" = "none"),
        selected = "lm"
      ),
      
      
    ),
    
    
    
    # main panel for plotting and statistical summary
    # display the plot and some statistics using summary()
    
    mainPanel(
      fluidRow(h3("ScatterPlot Visualization"), plotlyOutput("scatterPlot")),
      fluidRow(
        # half of the column for data summary
        column(6, h3("Data Summary"), verbatimTextOutput("dataSummary")),
        # the other half for regression statistics
        column(6, h3("Regression Statistics"), verbatimTextOutput("dataStat"))
      )
      
    )
    
    
  )
  
)



server <- function(input, output, session) {
  
  # need to filter the data according to the input
  # pipeline!
  
  filtered_data <- reactive({
    # code goes here
    data <- gapminder |> 
      filter(continent %in% input$continents_select) |>
      filter(year >= input$year_range[1] & year <= input$year_range[2])
    return(data)
  })
  
  # render the plot and the data summary
  
  
  # a dictory for labeling
  dyna_labels <- c(
    lifeExp = "Life Expectancy (in years)",
    pop = "Population",
    gdpPercap = "GDP per Capita (in $)"
  )
  
  
  # plot rending
  # renderPlot is now renderPlotly
  output$scatterPlot <- renderPlotly({
    
    # code goes here
    
    data <- filtered_data()
    
    gg <- ggplot(data,
                 aes(
                   x = .data[[input$x_var]], # .data is the placeholder in the pipeline
                   y = .data[[input$y_var]],
                   color = continent,
                   size = pop,
                 )) + 
      geom_point(aes(text = paste("Country:", country)), alpha = 0.3) + 
      labs(
        x = dyna_labels[[input$x_var]],
        y = dyna_labels[[input$y_var]],
        title = "Gapminder Data Visualization",
        caption = "Source: gapminder dataset",
        color = "Continents",
        size = "Population"
      ) + 
      theme_bw()
    
    # conditional structure for scaling the x-axis according to the input
    if (input$log_scaleX) {gg <- gg + scale_x_log10()}
    
    # conditional structure for regression model
    if (input$regression) {gg <- gg + stat_smooth(
      se = input$std_err,
      method = input$reg_model,
      size = 0.8,
    )}
    
    
    # this converts a ggplot to ggplotly
    # the tooltip displays the text aesthetics (country name)
    # along with the x and y aesthetics being plotted
    ggplotly(gg, tooltip = c("text","x","y"))
    
    
    
    
  })
  
  
  
  
  
  
  
  
  ## the statistics output for the plot
  # one for data summary
  # the other one for regression statitistcs
  
  
  output$dataSummary <- renderPrint({
    
    # code goes here
    
    data <- filtered_data()
    data |> select(lifeExp, pop, gdpPercap) |> summary()
  })
  
  
  
  # code for regression statistics for geom_smooth
  output$dataStat <- renderPrint({
    data <- filtered_data()
    
    # Check if smoothing method is "none"
    if (input$reg_model == "none") {
      return("No smoothing model applied.")
    }
    
    # Fit the model based on the selected method
    model_formula <- as.formula(paste(input$y_var, "~", input$x_var))
    
    
    results <- data |>
      group_by(continent) |>  # Group by continent first
      group_map(~ {
        df <- .
        continent_name <- unique(df$continent)
        
        if (input$reg_model == "lm") {
          model <- lm(model_formula, data = df)
          list(
            Continent = continent_name,
            Summary = summary(model)
          )
        } else if (input$reg_model == "loess") {
          model <- loess(model_formula, data = df)
          list(
            Continent = continent_name,
            Summary = list(
              "LOESS Model Summary" = summary(model),
              "Smoothing Parameters" = model$span
            )
          )
        } else if (input$reg_model == "gam") {
          library(mgcv) # GAM models require mgcv package
          model <- gam(model_formula, data = df)
          list(
            Continent = continent_name,
            Summary = summary(model)
          )
        } else {
          list(
            Continent = continent_name,
            Summary = "Unsupported smoothing method."
          )
        }
      })
    
    # Printing the result
    for (result in results) {
      continent_name <- result$Continent
      cat("Continent:", continent_name, "\n")
      print(result$Summary)
      cat("\n-----------------------------\n")
    }
  })
  
}

shinyApp(ui, server)