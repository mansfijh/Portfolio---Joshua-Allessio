library(readxl)
StatsProjectData <- read_excel("AAA School Stuff/STAT383/Final Project/StatsProjectData.xlsx")
View(StatsProjectData)

#Preparing Snow depth data 
SnowData=data.frame(StatsProjectData$DATE,StatsProjectData$SNWD_2005,StatsProjectData$SNWD_2020)
names(SnowData)=c("DATE","Y2005","Y2020")
SnowData=na.omit(SnowData, cols=c("DATE","Y2005", "Y2020"))
SnowData$DATE=as.factor(SnowData$DATE)

t.test(SnowData$`2020`,SnowData$`2005`,alternative = "less")

SnowAOV=stack(SnowData)
names(SnowAOV)=c("inches","year")
aov2005=aov(formula=inches~year,data=SnowAOV)
summary(aov2005)

SnowModel=lm(data=SnowData,formula=Y2020~Y2005)
summary(SnowModel)

library(ggplot2)
ggplot(data=SnowData,mapping=aes(x='Y2020',y='Y2005'))+geom_point()


#preparing precipitation data
PrecipData=data.frame(StatsProjectData$PRCP_2005,StatsProjectData$`2020_PRCP`)
names(PrecipData)=c("2005","2020")
PrecipData=na.omit(PrecipData,cols=c("2005","2020"))
t.test(PrecipData$`2005`,PrecipData$`2020`)
PrecipData=stack(PrecipData)
names(PrecipData)=c("inches","years")
ggplot(data=PrecipData,aes(x=inches,y=years,fill=years))+geom_boxplot(notch=TRUE,outlier.shape=NA)+
  scale_x_continuous(limits=c(0,1))+ggtitle("Comparison of Winter Rainfall")+
  theme(plot.title = element_text(hjust = 0.5))+labs(x="Daily Inches of Rainfall",y="Year")+
  theme(legend.position = "none")
  

#comparing daily temperature range between 2005 and 2020
TempRange=data.frame(StatsProjectData$TMIN_2005,StatsProjectData$TMAX_2005,StatsProjectData$TMIN_2020,StatsProjectData$TMAX_2020)
names(TempRange)=c("TMIN_2005","TMAX_2005","TMIN_2020","TMAX_2020")
TempRange=na.omit(TempRange,cols=c("TMIN_2005","TMAX_2005","TMIN_2020","TMAX_2020"))
MaxTemp=data.frame(TempRange$TMAX_2005,TempRange$TMAX_2020)
MinTemp=data.frame(TempRange$TMIN_2005,TempRange$TMIN_2020)
DailyTempRange=MaxTemp-MinTemp
names(DailyTempRange)=c("2005","2020")
t.test(DailyTempRange$`2020`,DailyTempRange$`2005`)

TempRange=stack(TempRange)
names(TempRange)=c("Temperature","Year")
ggplot(data=TempRange,aes(x=Temperature,y=Year,fill=Year))+geom_boxplot(notch=TRUE)+
  scale_fill_discrete(name = "Year", labels = c("2005 Minimum", "2005 Maximum", "2020 Minimum","2020 Maximum"))+
  guides(fill=guide_legend(title="Temperatures"))+
  theme(axis.text.y = element_blank())+theme(axis.title.y=element_blank()) +
  ggtitle("Max and Min Winter Temperatures")+theme(plot.title = element_text(hjust = 0.5))+
  labs(x="Temperature (°F)")+ guides(fill = guide_legend(reverse = TRUE))
  
#compatitle = #comparing maximum temperature 
t.test(TempRange$TMAX_2005,TempRange$TMAX_2020,alternative="less")


#exporting data
library(openxlsx)
write.xlsx(TempRange, "c:AAA School Stuff/STAT383/Final Project/TempRange.xlsx")
write.xlsx(SnowData, "c:AAA School Stuff/STAT383/Final Project/SnowData.xlsx")
write.xlsx(PrecipData, "c:AAA School Stuff/STAT383/Final Project/PrecipData.xlsx")
