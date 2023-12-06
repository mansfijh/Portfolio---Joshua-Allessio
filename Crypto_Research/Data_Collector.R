#load relevant packages. Note: make sure they are installed first
library(httr)
library(httr2)
library(lubridate)
library(jsonlite)
library(dplyr)


#get current time and round down so that the two API calls later will not become staggered
now = as.numeric(Sys.time())                     |>      # Get the current time in UNIX seconds format
  as.POSIXct(origin = "1970-01-01", tz = "UTC") |>       # Convert the UNIX timestamp to a POSIXct object                            |>      # Get the timestamp for the lookback period 
  floor_date(unit = "1 minutes")                         # Round down to the nearest minute
then <- as.numeric(now - hours(26))                      # Get the "then" timestamp based on a number of hours ago. Convert back to UNIX
now <- as.numeric(now)                                  # Convert the "now" timestamp back to UNIX

#Create the parameters for the API call
params = list(          
  symbols = "PEPEUSDT_PERP.3",    
  interval = "1min",                #Options: 5min, 15min, 1hour, 2hour, 4hour, daily
  from = then,
  to = now
)
  
# make the API call to get open interest data
#Note: insert your own free API key from  Coinalyze.net
response = GET("https://api.coinalyze.net/v1/open-interest-history?api_key=   ", query=params)
OI_json <- content(response, "parsed")  #retrieve the data from the API call in json format
print(response$status_code)
# smake the API call to get open interest data
response2 = GET("https://api.coinalyze.net/v1/ohlcv-history?api_key=9f210431-8b81-4509-bd40-0b2190cd9856", query=params)
price_json <- content(response2, "parsed")  #retrieve the data from the API call in json format
print(response2$status_code)

#Tidy the OI data 
for (i in OI_json) {
  history = i$history
  OI_df = data.frame(
    OI_open <- sapply(history, function(x) x$o),
    OI_close <- sapply(history, function(x) x$c),
    timestamp <- sapply(history, function(x) x$t)
  )
}
colnames(OI_df) <- c("OI_open", "OI_close", "timestamp") #rename the columns of the OI data frame

#Tidy the prcie data
for (j in price_json) {
  history = j$history
  price_df = data.frame(
    price_open <- sapply(history, function(x) x$o),
    price_close <- sapply(history, function(x) x$c),
    timestamp <- sapply(history, function(x) x$t)
  )
}
colnames(price_df) <- c("price_open", "price_close", "timestamp") #rename the columns of the price data frame

combined_df <- full_join(OI_df, price_df, by = "timestamp")

# Take care of a good bit of NA values. I'll fill in the rest manually in Notepad. 
for (i in 2:(nrow(combined_df))) {
  if (is.na(combined_df$OI_open[i])) { # Find NA values in the OP_open column
    combined_df$OI_open[i] <- (combined_df$OI_close[i - 1]) # Fill OI open NA values with the previous OI close
  }
  if (is.na(combined_df$OI_close[i])) {
    combined_df$OI_close[i] <- (combined_df$OI_close[i - 1]) # Fill OI close NA values with the previous OI close
  }
  if (is.na(combined_df$price_open[i])) {
    combined_df$price_open[i] <- combined_df$price_close[i-1] #fill in NA price opens with the previous close
  }
  if (is.na(combined_df$price_close[i])) {
    combined_df$price_close[i] <- combined_df$price_open[i+1] # Fill in NA price values with next open
  }
}

# Save the data to my computer for later use
write.csv(combined_df, "C:/Users/jalle/Documents/AAA School Stuff/Fall2023/Crypto_Screenr/Data/1m/20231107_PEPE_OKX", row.names = FALSE)
print("data saved to files")

