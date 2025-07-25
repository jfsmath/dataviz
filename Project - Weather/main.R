library(httr)
library(jsonlite)
library(lubridate)


# Define URL and parameters
url <- "https://api.open-meteo.com/v1/forecast"

params <- list(
  latitude = 39.02,
  longitude = 77.01,
  hourly = "temperature_2m,relative_humidity_2m,rain",
  timezone = "America/New_York",
  past_days = 7,
  wind_speed_unit = "mph",
  temperature_unit = "fahrenheit",
  precipitation_unit = "inch"
)

# Make GET request
response <- GET(url, query = params)

# Parse JSON content
weather_data <- fromJSON(content(response, "text"))

# View data structure
str(weather_data)

# Example: Convert hourly data into a dataframe
hourly_data <- weather_data$hourly
df <- as.data.frame(hourly_data)
df$time <- ymd_hm(df$time, tz = "America/New_York")


now <- Sys.time()
df$diff <- abs(difftime(df$time, now, units = "mins"))
current_row <- df[which.min(df$diff), ]



# Plot the temperature
g <- ggplot(df, aes(x = time, y = temperature_2m)) + 
  geom_line(linewidth=0.5, linetype = 1, color = "steelblue") + 
  geom_smooth(color = "darkgreen") + 
  geom_point(data = current_row, shape = 17, size = 5, color = "red") + 
  geom_text(data = current_row, 
            aes(x = time, y = temperature_2m, 
                label = paste0("Now: ", round(temperature_2m, 1), "°F")),
            vjust = -1, color = "red", fontface = "bold") +
  labs(
    title = "Temperature in Four Corners (+/- 7 days)",
    x = "Time and Date", 
    y = "Temperature (Fahrenheit)",
    caption = "Source: Open-Meteo weather data"
    ) + 
  theme_bw()
g
