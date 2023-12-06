#Title: Custom Crypto Screener

# *** NOTE: due to API rate limitations, this file takes about 6 minutes to run
# *** NOTE: to use the file yourself, you will need to generate a free API key from coinalyze.net 
#           and paste it in lines 49 and 52



#load relevant packages. Note: make sure they are installed first
library(httr)
library(httr2)
library(lubridate)
library(jsonlite)
library(dplyr)
library(quantmod)

rm(list = ls()) # Clear environment so data doesn't get mixed up 

#get current time and round down so that the two API calls later will not become staggered
now = as.numeric(Sys.time())                     |>      # Get the current time in UNIX seconds format
  as.POSIXct(origin = "1970-01-01", tz = "UTC") |>      # Convert the UNIX timestamp to a POSIXct object                            |>      # Get the timestamp for the lookback period 
  floor_date(unit = "1 minutes")                        # Round down to the nearest minute
then <- as.numeric(now - hours(30))                      # Get the "then" timestamp based on a number of hours ago. Convert back to UNIX
now <- as.numeric(now)                                   # Convert the "now" timestamp back to UNIX

# To get around the Coinalyze API rate limitations, we have to break up the large list of symbols
# into a several shorter lists of symbols
# Note that the data type of these lists is not list, but they are standalone character objects. 
# When we combine them into All_tickers, THAT is a list of characters. 
list1 <- "ILVUSDT_PERP.6, XRPUSDT_PERP.A, LPTUSDT_PERP.A, TRBUSDT_PERP.A, SOLUSDT_PERP.A, AGLDUSDT_PERP.A, DOGEUSDT_PERP.A, KASUSDT_PERP.6, BNBUSDT_PERP.A, MATICUSDT_PERP.A, LINKUSDT_PERP.A, MASKUSDT_PERP.A, BCHUSDT_PERP.A, MKRUSDT_PERP.A, FTTUSDT_PERP.Y, APTUSDT_PERP.A, RAYUSDT_PERP.Y, LTCUSDT_PERP.A, RUNEUSDT_PERP.A, ADAUSDT_PERP.A"
list2 <- "XLMUSDT_PERP.A, SUIUSDT_PERP.A, TRXUSDT_PERP.A, LUNCUSDT_PERP.Y, AVAXUSDT_PERP.A, ARBUSDT_PERP.A, ARUSDT_PERP.A, DASHUSDT_PERP.A, PERPUSDT_PERP.A, APEUSDT_PERP.A, OPUSDT_PERP.A, AKROUSDT_PERP.A, UNFIUSDT_PERP.A, INJUSDT_PERP.A, STORJUSDT_PERP.A, ENSUSDT_PERP.A, UMAUSDT_PERP.A, CFXUSDT_PERP.A, MTLUSDT_PERP.A, REQUSDT_PERP.6"
list3 <- "COMPUSDT_PERP.A, FLMUSDT_PERP.A, FTMUSDT_PERP.A, DOTUSDT_PERP.A, ETCUSDT_PERP.A, ATOMUSDT_PERP.A, SPELLUSDT_PERP.A, STMXUSDT_PERP.A, FRONTUSDT_PERP.A, HBARUSDT_PERP.A, GLMRSDT_PERP.A, RNDRUSDT_PERP.A, KNCUSDT_PERP.A, LINAUSDT_PERP.A, ALGOUSDT_PERP.A, BICOUSDT_PERP.A, OGNUSDT_PERP.A, MANAUSDT_PERP.A, AAVEUSDT_PERP.A, NEARUSDT_PERP.A"
list4 <- "GTCUSDT_PERP.A, MAGICUSDT_PERP.A, GRTUSDT_PERP.A, BLZUSDT_PERP.A, EGLDUSDT_PERP.A, VETUSDT_PERP.A, BANDUSDT_PERP.A, ZILUSDT_PERP.A, ZRXUSDT_PERP.A, FITFIUSDT_PERP.6, AUDIOUSDT_PERP.A, FXSUSDT_PERP.A, MINAUSDT_PERP.A, KLAYUSDT_PERP.A, NKNUSDT_PERP.A, ALPHAUSDT_PERP.A, ICXUSDT_PERP.A, RSRUSDT_PERP.A, JOEUSDT_PERP.A, 1INCHUSDT_PERP.A"
list5 <- "API3USDT_PERP.A, REEFUSDT_PERP.A, ICPUSDT_PERP.A, HOOKUSDT_PERP.A, PENDLEUSDT_PERP.A, SNXUSDT_PERP.A, ONTUSDT_PERP.A, GMTUSDT_PERP.A, ARPAUSDT_PERP.A, C98USDT_PERP.A, ANTUSDT_PERP.A, NEOUSDT_PERP.A, LITUSDT_PERP.A, ENJUSDT_PERP.A, COTIUSDT_PERP.A, SUSHIUSDT_PERP.A, EOSUSDT_PERP.A, UNIUSDT_PERP.A, CHRUSDT_PERP.A, CHRUSDT_PERP.A"
list6 <- "BNTUSDT_PERP.A, WLDUSDT_PERP.A, FILUSDT_PERP.A GALAUSDT_PERP.A, ARKUSDT_PERP.A, LEVERUSDT_PERP.A, XTZUSDT_PERP.A, CRVUSDT_PERP.A, AMBUSDT_PERP.A, BAKEUSDT_PERP.A, SANDUSDT_PERP.A, WAVESUSDT_PERP.A, LQTYUSDT_PERP.A XVSUSDT_PERP.A, IDEXUSDT_PERP.A, LOOMUSDT_PERP.6, OGUSDT_PERP.A, BNXUSDT_PERP.A, STPTUSDT_PERP.6, PAXGUSDT_PERP.A"
list7 <- "RPLUSDT_PERP.6, HFTUSDT_PERP.A"
All_tickers=list(list1, list2, list3, list4, list5, list6, list7)

for (i in 1:length(All_tickers)) {
  #Create the list of parameters to use for the API call
  params = list(          
    symbols = All_tickers[[i]],       #use each list of 20 tickers 1 by 1 
    interval = "1hour",                #Options: 5min, 15min, 1hour, 2hour, 4hour, daily
    from = then,
    to = now
  )
  
  #make the API call to get open interest data
  response = GET("https://api.coinalyze.net/v1/open-interest-history?api_key=   ", query=params)
  OI_json <- content(response, "parsed")  #retrieve the data from the API call in json format
  #make the API call to get open interest data
  response = GET("https://api.coinalyze.net/v1/ohlcv-history?api_key=    ", query=params)
  price_json <- content(response, "parsed")  #retrieve the data from the API call in json format
  
  #Tidy the data
  Master_Data = list()                               # Initialize a list to store the relevant data
  #Tidy and keep some of the OI data
  for (ticker in OI_json) {                          # Iterate through each list within the OI_json list Each nested list will temporarily be called 'ticker' in this loop. 
    symbol = ticker$symbol                           # Store the name of the ticker for the current iteration. 
    history = ticker$history                         # Extract the OI history of the ticker for the current iteration
    symbol_df = data.frame(                          # create a temporary data frame to store OI history for each ticker
      timestamp = sapply(history, function(x) x$t),  # Keep the UNIX timestamps from 't' and rename them "timestamp"
      OI_Close = sapply(history, function(x) x$c)    # OI candle close
    )
    symbol_df <- symbol_df |> arrange(timestamp)     # Redundancy - ensure that things are in chronological order
    Master_Data[[symbol]] <- symbol_df               # Add the data frame to the list of data frames
  }
  #Tidy and keep some of the price data
  for (ticker in price_json) {
    symbol = ticker$symbol                           # Store the name of the ticker for the current iteration
    history = ticker$history                         # Extract the OI history of the ticker for the current iteration
    symbol_df = data.frame(                          # create a temporary data frame to store OI history for each ticker
      timestamp = sapply(history, function(x) x$t),  # Keep the UNIX timestamps from 't' and rename them "timestamp"
      Price_Close = sapply(history, function(x) x$c) # OI candle close
    )
    symbol_df <- symbol_df |> arrange(timestamp)     #Redundancy - ensure that things are in chronological order
    #endless screaming to combine price and OI into one dataset
    Master_Data[[symbol]] <- mutate(Master_Data[[symbol]], symbol_df$Price_Close) #Add the price close data to the dataframe frmo earlier
    #endless screaming
    colnames(Master_Data[[symbol]]) <- c("Timestamp", "OI_close", "Price_close")  #rename column names so the final column isnt names "symbol_df$Price_Close"
  }
  
  #now have to calculate the trend for price and OI
  #for (i in seq_along(Master_Data)) {                          iterate through each data frame within Master_Data
     #OI_RSI = RSI((Master_Data[[i]]$OI_close), n=14)            Calculate the relative strength of the OI trend
     #OI_RSI[is.na(OI_RSI)] <- 0
     # Master_Data[[i]] <- mutate(Master_Data[[i]], OI_RSI)      Add OI the RSI to the master dataset
     # Price_RSI = RSI((Master_Data[[i]]$Price_close), n=14)     Calculate the price relative trend strength
     # Master_Data[[i]] <- mutate(Master_Data[[i]], Price_RSI)   Add the Price RSI to the master data
        #  For some reason the above line won't work even though I did the exact same thing two lines above that???
        # Endless screaming
  #}
  
  # Attempt 2 at the RSI for Price and OI
  for (i in seq_along(Master_Data)) {                                     # iterate along every list inside the outer list, Master_Data
    Master_Data[[i]]$OI_RSI <- RSI(Master_Data[[i]]$OI_close, n=14)       # Access the OI_close list inside each list inside Master_Data, calculate its RSI, and create a new column for it
    Master_Data[[i]]$Price_RSI <- RSI(Master_Data[[i]]$Price_close, n=14) # Access the Price_close list inside each list inside Master_Data, calculate its RSI, and create a new column for it
  }
  # It worked! So simple too. At least relative to the first attempt. 
  
  # Now, trim the data some more. We need at least 22 time series data units for calculations, but we only need to keep the most revent few.
  for (i in seq_along(Master_Data)) {                                     # iterate along every list inside the outer list, Master_Data
    Master_Data[[i]] <- Master_Data[[i]] <- tail(Master_Data[[i]], 8)
  }
  
  # The culmination! 
  # Check for simultaneous strong trends in price & OI
  for (i in seq_along(Master_Data)) {                                                   # iterate along every coin for which we have data
    ticker_name <- sub("USDT.*$", "", names(Master_Data)[i])                         #Get the name of the ticker for the current iteration, & truncate the useless characters  
    value1 = Master_Data[[i]]$OI_RSI[1]
    value2 = Master_Data[[i]]$OI_RSI[length(Master_Data[[i]])]
    OI_percent_diff = 100*(value2 - value1)/(abs(value1))                               #calculate percent change in OI from two hours ago
    if   (any(Master_Data[[i]]$OI_RSI > 68) & any(Master_Data[[i]]$Price_RSI > 68))     # Check for rising OI and price
      print(paste(ticker_name, "may be out for a rip! The trend is strong! Consider a continuation trade!"))
    if (any(Master_Data[[i]]$OI_RSI < 25) & any(Master_Data[[i]]$Price_RSI > 70))       # Check for falling OI and rising price
      print(paste(ticker_name, "May be forming the Glass Staircase! Look above for resistance."))
    if (any(Master_Data[[i]]$OI_RSI < 32) & any(Master_Data[[i]]$Price_RSI < 28))       # Check for falling OI and price
      print(paste(ticker_name, "has been falling for a while. Look for the nearest STRONG support, and consider scalping the bounce!"))
  }
  Sys.sleep(61)       #Wait 61 seconds before making the next round of API calls due to API rate limitations
}

