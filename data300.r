# for (i in 1:10){
# conscode <- data_000300[i,4]
# while (nchar(conscode) < 6) {
# conscode <- paste("0", conscode, sep = "")
# }
# cntrade(conscode, start=20141217, end=20141217)
# filename<-paste(conscode,'.csv',sep='')
# data_temp <- read.csv(file=filename,header=T)
# if(i ==1){data_10<-data_temp}
# else{data_10<-rbind(data_10,data_temp)}
# }
#set working directory
setwd('C:\\Users\\Jianyu.Ye\\Documents\\R_in_action\\sina')
#load the cntrade function from sina.r
source('sina.r')

conscode <- NA
filename <- NA
testifnull <- NA
data_000300 <- read.csv('000300closeweight.csv',header=T)
step <- 50
origin <- 1


while(origin<300){
	cat('start download from', as.character(origin), ', step is ', as.character(step), 'files...\n')
	if(origin+step<300){
		conscode <-data_000300[origin:(origin+step),4]
	}else{
		conscode <-data_000300[origin:300,4]
	}
	for (i in 1:length(conscode)){
		while(nchar(conscode[i]) < 6){
			conscode[i] <- paste('0', conscode[i], sep='')
		}
	}
	cntrade(conscode, start=20141217, end=20141217)
	print(conscode)
	filename<-paste(conscode,'.csv',sep='')
	origin <- origin + step

}

#check which file is empty
cat('check if all files downloaded...\n')
for(i in 1:length(filename)){
	testifnull[i] <- nrow(read.csv(filename[i],header=T))
	}
#reload the data csv file
while(sum(testifnull)<length(conscode)){
	for (i in 1:length(conscode)){
		if (testifnull[i] == 0){
			cntrade(conscode[i], start=20141217, end=20141217)
		}
	}
	for(i in 1:length(filename)){
	testifnull[i] <- nrow(read.csv(filename[i],header=T))
	}
}
cat('All files downloaded!\n')
# while(nrow(testifnull)==0){
	# print('lalala')
		# download.file(url, destfile, quiet = TRUE)
	# }
	