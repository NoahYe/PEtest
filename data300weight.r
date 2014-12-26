#set working directory
setwd('C:\\Users\\Jianyu.Ye\\Documents\\R_in_action\\sina')
# conscode <- NA
index <- NA
cat('update the weight of data300\n')
data300weight <- read.csv('000300closeweight.csv',header=T)
data300weight <- data300weight[,c(4,7)]

cat('update the price of data300\n')
fun_weightprice<-function(stock){
	while(nchar(stock[1])<6){
		stock[1]<- paste('0',stock[1],sep='')
	}
	stockfile <- paste(stock[1],'.csv',sep='')
	price <- read.csv(stockfile,header=T)[1,4]
	return (price*stock[2])
}

conscode <- data300weight[,1]
for (index in 1:nrow(data300weight)){
	stock = data300weight[index,]
	data300weight[index,3] <- fun_weightprice(stock)
	
	# while(nchar(stock[1])<6){
		# stock[1]<- paste('0',stock[1],sep='')
	# }
	# stockfile <- paste(stock[1],'.csv',sep='')
	# price <- read.csv(stockfile,header=T)[1,4]
	# stock[3] <- price*stock[2]
	
}


# for(i in 1:length(filename)){
	# data300price[i] <- nrow(read.csv(filename[i],header=T))
	# }