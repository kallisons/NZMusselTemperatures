#Neiburger, M, JG Edinger, and WD Bonner. 1982.  Understanding Our Atmospheric Environment. 2nd Edition.  W. H. Freeman and Company, San Francisco.

  
#CSFR Data

folder<-paste("/Users/kasmith/Documents/BallantineReef/Data/Humidity/")

AIRTnames<-list.files(path=paste(folder, "AIRT/", sep=""), pattern=NULL, full.names=FALSE, recursive=FALSE)

SHUMnames<-list.files(path=paste(folder, "SHUM/", sep=""), pattern=NULL, full.names=FALSE, recursive=FALSE)

PRESnames<-list.files(path=paste(folder, "PRES/", sep=""), pattern=NULL, full.names=FALSE, recursive=FALSE)


for(i in 1:length(AIRTnames)){
	AIRT<-read.table(paste(folder, "AIRT/", AIRTnames[i], sep=""), header=TRUE)
	SHUM<-read.table(paste(folder, "SHUM/", SHUMnames[i], sep=""), header=TRUE)
	PRES<-read.table(paste(folder, "PRES/", PRESnames[i], sep=""), header=TRUE)
	
	weather<-merge(AIRT, SHUM, all=TRUE)
	weather<-merge(weather, PRES, all=TRUE)
	
	#Calculate vapor density
	weather$ec<-10^(9.4041-(2.354*10^3)/weather$Temperature)
	weather$w<-weather$Specific_humidity/(1-weather$Specific_humidity)
	weather$ws<-0.622*(weather$ec/((weather$Pressure/100)-weather$ec))
	
	weather$rh<-(weather$w/weather$ws)*100
	
	weather<-weather[,c("Unix", "jday", "rh")]
	
	weather<-weather[order(weather$Unix),]
	
	weather$rh<-round(weather$rh, digits=0)
	
	weather$rh<-ifelse(weather$rh>100, 100, weather$rh)
	
	print(max(weather$rh))
	print(min(weather$rh))
	
	ER_outfile<-gsub("grb2.nc", "NZ_EReef.txt", outfile)
	
	outfile<-paste(folder, "RH/", SHUMnames[i],  sep="")
	
	outfile<-gsub("q2m", "rh2m", outfile)
	
	write.table(weather, outfile, quote=FALSE, col.names=TRUE, row.names=FALSE, sep="\t")

	}
  
    