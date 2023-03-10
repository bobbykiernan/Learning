

.libPaths("C:/Users/bkiernan002/Documents/R/win-library/4.1")  

#install.packages("ecb")
library(ecb)
library(readxl)

#metadata , all tables available in the ECB Stat Warehouse: 
#Datasets=ecb::get_dataflows()
#View(Datasets)
#write.csv(Datasets,"C:/temp/e.csv")

#Notable datasets: 
#SPF # survey of pro forecasters
#MPD # macro forecasts

#ecb::get_description("MPD")
#ecb::get_dimensions("MPD.A.U2") 
#example : 
#mpd = ecb::get_data("MPD.A.U2.YER.A.A22.0000")  # Database.Frequency.Region.Metric.Calculation.PublicationDate.000 (last key redundant)

# See ECB MetaData in the excel in the same folder as  this file for details of codes. 
setwd("E:/Shared drives/IE Credit Risk Group/Team Work/Thought Leadership and Research/2022.10 Macro Data Fetch/")
ECB_Metrics = readxl::read_xlsx("ECB MetaData - MPD database (macro projections).xlsx", sheet  = 'MetricKeys')

#setup sample table 
ECB =  rbind (
  ecb::get_data("MPD.A.U2.YER.A..0000"), 
  ecb::get_data("MPD.A.IE.YER.A..0000")
) 

#clear the table: 
ECB=ECB[ECB$freq=="",]

#Get EA stats: 
for (i in 1:nrow(ECB_Metrics) )
{
  print(ECB_Metrics[i,]$Key)
  key =paste0("MPD.A.U2." , ECB_Metrics[i,]$Key , "." , ECB_Metrics[i,]$CalcType , "..0000")
  tryCatch(
      expr = { 
          ECB =  rbind ( ECB, ecb::get_data(key))  
          } 
      , error = function(e){print (paste0("looks like this data is not available: ", key, " : ", ECB_Metrics[i,]$Description)) }
      , warning = function(e){print (e) }
  )
}

#Get IE stats: 
for (i in 1:nrow(ECB_Metrics) )
{
  print(ECB_Metrics[i,]$Key)
  key =paste0("MPD.A.IE." , ECB_Metrics[i,]$Key , "." , ECB_Metrics[i,]$CalcType , "..0000")
  tryCatch(
    expr = { 
      ECB =  rbind ( ECB, ecb::get_data(key))  
    } 
    , error = function(e){print (paste0("looks like this data is not available: ", key, " : ", ECB_Metrics[i,]$Description)) }
    , warning = function(e){print (e) }
  )
}

ECB$RefreshDt = today()

write.csv(ECB,"C:/Temp/Macros.csv",row.names = F)
        
