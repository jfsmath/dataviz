library(shiny)
library(ggplot2)
library(dplyr)
library(sf)
library(readr)
library(leaflet)

# Placeholder data loading (replace with real-time CDC or API calls)
measles_cases <- read_csv("measles_cases.csv")  # must have columns: State, Week, Cases
vaccination_data <- read_csv("measles_deaths_vax.csv")  # columns: Week, DeathRate, VaccinationStatus
states_sf <- st_read("us_states_shapefile.shp")  # must have 'STATE_NAME'

# Merge spatial and case data for leaflet
latest_cases <- measles_cases %>%
  filter(Week == max(Week)) %>%
  group_by(State) %>%
  summarise(Cases = sum(Cases, na.rm = TRUE))

map_data <- left_join(states_sf, latest_cases, by = c("STATE_NAME" = "State"))

ui <- fluidPage(
  titlePanel("Real-Time US Measles Dashboard"),
  sidebarLayout(
    sidebarPanel(
      selectInput("group_by", "Group Time Series By:",
                  choices = c("State", "Region"), selected = "State")
    ),
    mainPanel(
      tabsetPanel(
        tabPanel("Geospatial", leafletOutput("measles_map", height = 600)),
        tabPanel("Cases Over Time", plotOutput("time_series_plot")),
        tabPanel("Death Rates", plotOutput("death_rate_plot"))
      )
    )
  )
)

server <- function(input, output, session) {
  
  output$measles_map <- renderLeaflet({
    leaflet(data = map_data) %>%
      addProviderTiles("CartoDB.Positron") %>%
      addPolygons(fillColor = ~colorNumeric("YlOrRd", Cases)(Cases),
                  fillOpacity = 0.7, color = "white", weight = 1,
                  label = ~paste0(STATE_NAME, ": ", Cases, " cases"))
  })
  
  output$time_series_plot <- renderPlot({
    time_data <- measles_cases
    
    if (input$group_by == "Region") {
      region_map <- data.frame(
        State = state.name,
        Region = state.region
      )
      time_data <- left_join(time_data, region_map, by = "State") %>%
        group_by(Week, Region) %>%
        summarise(Cases = sum(Cases, na.rm = TRUE), .groups = 'drop')
      ggplot(time_data, aes(x = Week, y = Cases, color = Region)) +
        geom_line() + theme_minimal() + labs(title = "Measles Cases by Region")
    } else {
      ggplot(time_data, aes(x = Week, y = Cases, color = State)) +
        geom_line() + theme_minimal() + labs(title = "Measles Cases by State")
    }
  })
  
  output$death_rate_plot <- renderPlot({
    ggplot(vaccination_data, aes(x = Week, y = DeathRate, color = VaccinationStatus)) +
      geom_line() +
      theme_minimal() +
      labs(title = "Death Rates by Vaccination Status",
           y = "Deaths per 100,000")
  })
}

shinyApp(ui, server)
