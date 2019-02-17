

library(lubridate)
library(stringr)
library(dplyr)

inpdata0<- read.csv("arrsets.csv",stringsAsFactors = F)
inpdata0$zip<- inpdata0$PD
inpdata0$zip[inpdata0$zip %in% c("Champaign","")] <- "61822"
inpdata0$zip[inpdata0$zip %in% c("Urbana","UI")] <- "61801"

inpdata0$LOCATION_OF_ARREST<- paste(inpdata0$LOCATION_OF_ARREST,inpdata0$PD,paste("Illinois",inpdata0$zip,sep = " "),sep = ", ")
inpdata0<- distinct(inpdata0)
inpdata<- inpdata0[,c(3,4,6,10)]
inpdata$DATE_OF_ARREST<- parse_date_time(inpdata$DATE_OF_ARREST,orders = c("mdy"))
inpdata<- inpdata[!is.na(inpdata$DATE_OF_ARREST),]

inpdata$day_of_week<- weekdays(inpdata$DATE_OF_ARREST)
inpdata$time_of_day<- as.numeric(str_split_fixed(inpdata$TIME_OF_ARREST,":",2)[,1])

############################## getting Lat Long ##############################
# Geocoding script for large list of addresses.
library(RDSTK)

for(i in 1:nrow(inpdata)){
  
  x<- tryCatch(as.numeric(street2coordinates(inpdata$LOCATION_OF_ARREST[i])[,c(3,5)]), error=function(e) NULL)
  if(is.null(x)){
    
    x<- c(NA,NA)
  }
  inpdata$lat[i]<- x[1]
  inpdata$lon[i]<- x[2]
  cat(i," ")
}

temp<- inpdata[1:1200,]
temp<- temp[!is.na(temp$lat),]
temp<- temp[!is.na(temp$lon),]

# READ NEW DATA
temp<- read.csv("inpdata_final.csv",stringsAsFactors = F)
temp$echo<- NULL
temp$max.deparse.length<- NULL
temp<- temp[,4:8]

tb<- data.frame(table(temp$CRIME_CODE_CATEGORY_DESCRIPTION))
temp<- temp[temp$CRIME_CODE_CATEGORY_DESCRIPTION %in% as.character(tb$Var1[tb$Freq>100]),]

# temp$cnt<- 1
# temp<- stats::aggregate(cnt~.,temp,sum)
# temp_allAggr<- stats::aggregate(cnt~.,temp[,-1],sum)

# inpdata$lat<- runif(length(inpdata$lat),40,41)
# inpdata$lon<- runif(length(inpdata$lat),-89,-88)
# inpdata$Prob<- runif(length(inpdata$lat),0,1)
# write.csv(inpdata[1:5000,],"inpdata_temp.csv",row.names = F)

########################### Run Randomforest
library(randomForest)
temp$CRIME_CODE_CATEGORY_DESCRIPTION<- as.factor(temp$CRIME_CODE_CATEGORY_DESCRIPTION)
temp$day_of_week<- as.factor(temp$day_of_week)

train_idx<- sample(1:nrow(temp),40000,replace = F)
test_idx<- c(1:nrow(temp))[!1:nrow(temp) %in% train_idx]

rfModel<- randomForest(CRIME_CODE_CATEGORY_DESCRIPTION~.,temp[train_idx,])

# Var Importance
rfModel$importance

# Accuracy
1-mean(rfModel$err.rate[,1],na.rm = T)

# test accuracy 
out<- table(predict(rfModel,temp),temp$CRIME_CODE_CATEGORY_DESCRIPTION[test_idx])

# Test Accuracy
sum(diag(out))/sum(out)



full_output<- cbind(out,temp)


write.csv(full_output,"full_output.csv",row.names = F)
