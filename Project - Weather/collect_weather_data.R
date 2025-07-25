# This function collects weather data from open meteo https://api.open-meteo.com/v1/forecast
# Author: Fushuai Jiang
# There are two optional inputs
    # days: int, how many days into the past/future, default is a week
    # save_to_disk: logit, save the files locally or not, default is no
# There are two outputs, combined into a list
    # prediction: a range of weather data
    # current: weather data at the current moment
# The data collected include temperature, humidity, rain level, visibility, and wind speed



collect_weather_data <- function(days = 7, save_to_disk = FALSE) {
  
  library(httr)
  library(jsonlite)
  library(lubridate)
  
  
  url <- "https://api.open-meteo.com/v1/forecast"
  
  params <- list(
    latitude = 39.02,
    longitude = 77.01,
    hourly = "temperature_2m,relative_humidity_2m,rain,visibility,wind_speed_10m", # we select variables including temperature, humidity, rainfall, visibility, and windspeed. Make sure there is no space between the variable names
    current = "temperature_2m,relative_humidity_2m,rain",
    timezone = "America/New_York",
    past_days = days,
    wind_speed_unit = "mph",
    temperature_unit = "fahrenheit",
    precipitation_unit = "inch"
  )
  
  response <- GET(url, query = params)
  weather_data <- fromJSON(content(response, "text"))
  
  
  
  # Convert both data into dataframes
  df <- as.data.frame(weather_data$hourly)
  df_current <- as.data.frame(weather_data$current)
  
  
  # Standardize the time variable
  df$time <- ymd_hm(df$time, tz = "America/New_York")
  df_current$time <- ymd_hm(df_current$time, tz = "America/New_York")
  
  
  
  if (save_to_disk) {
    today_str <- format(Sys.Date(), "%Y%m%d")
    write.csv(df, file = paste0("weather_data_prediction", today_str,".csv"), row.names = FALSE)
    write.csv(df_current, file = paste0("weather_data_today", today_str,".csv"), row.names = FALSE)
    message("Data saved locally.")
  } else {}
  
  return(list(
    prediction = df,
    current = df_current
  ))
  
}