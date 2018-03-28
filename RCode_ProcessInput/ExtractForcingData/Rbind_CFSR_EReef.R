folder<-paste("/Volumes/HELIOS/CFSR_Data_NZ/EReef/", sep="")
years<-list.files(folder)

for(a in 1:length(years)){
	
	vars<-list.files(paste(folder, years[a], sep=""))
	
	for(b in 1:length(vars)){
		
		files<-list.files(paste(folder, years[a], "/", vars[b], sep=""))
		
		for(c in 1:length(files)){
			
			data<-read.table(paste(folder, years[a], "/", vars[b], "/", files[c], sep=""), header=TRUE)			
			
			data<-data[-nrow(data),]
			
			assign(files[c], data)
	
			}
		
		all<-do.call("rbind", lapply(files, as.name))
		
		outfile<-paste("/Users/kasmith/Documents/BallantineReef/Data/WeatherData/", vars[b], "/", "NZ_EReef_", vars[b], "_", years[a], ".txt", sep="")
		write.table(all, outfile, quote=FALSE, row.names=FALSE, col.names=TRUE, sep="\t")
		}
	
	}