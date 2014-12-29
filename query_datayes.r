require(RCurl)
source('API_datayes.r')

#set the requset access token
#httpheader <- c("Authorization"="Bearer 8aef3c023b90a3d71f24c8544ada4a20c59b5cbc44cc84636755d94f4c8d4e28");
#interactive imput for access token
#cat('Please update the datayes access token\n')
#httpheader <- c("Authorization"=paste("Bearer ",readline(),sep=''))
#set the base url
base_url <- "https://gw.wmcloud.com:443/data/"
#verify the parameter: stockID,startDate,endDate,field
cat('Download the info of stock',stockID,'from',startDate,'to',endDate,'...\n')

#construct the url by the parameter
dataurl <- paste('market/1.0.0/','getStockFactorsDateRange.csv?','stockID=',stockID,'&startDate=',startDate,'&endDate=',endDate,'&field=',field,'&callback=',callback,sep='')

#fetch the data from datayes via the API of getStockFactorsDateRange
result=getdata(dataurl)

#save the data to csv file
filename <- paste(getwd(),'/stock_info/',as.character(stockID),'.csv',sep='')
cat(result,file=filename)
cat('Download completed!\n\n')