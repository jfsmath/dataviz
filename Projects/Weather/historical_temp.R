retrieve_weekly_temperature_history <- function(
    latitude = 39.02,
    longitude = 77.01,
    start_month_day = Sys.Date()-13,
    end_month_day = Sys.Date()-7,
    start_year = 1950,
    end_year = 2025,
    save_to_disk = FALSE
) {
  library(httr)
  library(jsonlite)
  library(lubridate)
  library(dplyr)
  
  all_data <- list()
  
  for (year in start_year:end_year) {
    # Build start and end dates
    start_date <- paste0(year, "-", start_month_day)
    end_date <- paste0(year, "-", end_month_day)
    
    # Build params
    params <- list(
      latitude = latitude,
      longitude = longitude,
      start_date = start_date,
      end_date = end_date,
      hourly = "temperature_2m",
      timezone = "America/New_York",
      temperature_unit = "fahrenheit"
    )
    
    # Make API call to historical archive endpoint
    url <- "https://archive-api.open-meteo.com/v1/archive"
    response <- GET(url, query = params)
    
    # Parse JSON content
    weather_data <- fromJSON(content(response, "text", encoding = "UTF-8"))
    
    if (!is.null(weather_data$hourly)) {
      df_year <- as.data.frame(weather_data$hourly)
      df_year$time <- ymd_hm(df_year$time, tz = "America/New_York")
      df_year$year <- year
      all_data[[as.character(year)]] <- df_year
      message("Retrieved data for year: ", year)
    } else {
      warning("No data returned for year: ", year)
    }
    
    # Optional: polite pause to avoid rate limits
    Sys.sleep(0.3)
  }
  
  # Combine into one dataframe
  df_all <- bind_rows(all_data)
  
  # Optionally save
  if (save_to_disk) {
    today_str <- format(Sys.Date(), "%Y%m%d")
    filename <- paste0("weekly_temperature_history_", today_str, ".csv")
    write.csv(df_all, filename, row.names = FALSE)
    message("Saved data to file: ", filename)
  }
  
  return(df_all)
}