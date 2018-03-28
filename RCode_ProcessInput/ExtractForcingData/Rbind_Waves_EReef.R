#--------------
# NWW
#-----------


folder<-paste("/Volumes/HELIOS/WaveWatch3_nww2_NZ/EReef/", sep="")
years<-list.files(folder)

for(a in 1:length(years)){
	
	files.dp<-list.files(paste(folder, years[a], "/dp/", sep=""))
	
	files.hs<-list.files(paste(folder, years[a], "/hs/", sep=""))
	
	files.tp<-list.files(paste(folder, years[a], "/tp/", sep=""))
	
		
	for(c in 1:length(files.dp)){
			
	data.dp<-read.table(paste(folder, years[a], "/dp/", files.dp[c], sep=""), header=TRUE)	
	
	data.dp<-data.dp[-nrow(data.dp),]
	
	assign(files.dp[c], data.dp)
	
	data.hs<-read.table(paste(folder, years[a], "/hs/", files.hs[c], sep=""), header=TRUE)	
	
	data.hs<-data.hs[-nrow(data.hs),]
		
	assign(files.hs[c], data.hs)

	data.tp<-read.table(paste(folder, years[a], "/tp/", files.tp[c], sep=""), header=TRUE)	
		
	data.tp<-data.tp[-nrow(data.tp),]
	
	assign(files.tp[c], data.tp)
	
			}
		
		all.dp<-do.call("rbind", lapply(files.dp, as.name))
		
		all.dp<-all.dp[-nrow(all.dp),]
		
		all.hs<-do.call("rbind", lapply(files.hs, as.name))
		
		all.hs<-all.hs[-nrow(all.hs),]
		
		all.tp<-do.call("rbind", lapply(files.tp, as.name))
		
		all.tp<-all.tp[-nrow(all.tp),]
		
		
		all<-merge(all.dp, all.hs, all=TRUE)
		
		all<-merge(all, all.tp, all=TRUE)
		
		all<-all[order(all$Unix),]
		
		outfile<-paste("/Users/kasmith/Documents/BallantineReef/Data/WeatherData/waves/nww3/", "NZ_EReef_nww3_", years[a], ".txt", sep="")
		write.table(all, outfile, quote=FALSE, row.names=FALSE, col.names=TRUE, sep="\t")

	
	}
	
#-------------
#  multi
#-------------	


folder<-paste("/Volumes/HELIOS/WaveWatch3_multi_NZ/EReef/", sep="")
years<-list.files(folder)

for(a in 1:length(years)){
	
	files.dp<-list.files(paste(folder, years[a], "/dp/", sep=""))
	
	files.hs<-list.files(paste(folder, years[a], "/hs/", sep=""))
	
	files.tp<-list.files(paste(folder, years[a], "/tp/", sep=""))
	
		
	for(c in 1:length(files.dp)){
			
	data.dp<-read.table(paste(folder, years[a], "/dp/", files.dp[c], sep=""), header=TRUE)	
	
	data.dp<-data.dp[-nrow(data.dp),]
		
	assign(files.dp[c], data.dp)
	
	data.hs<-read.table(paste(folder, years[a], "/hs/", files.hs[c], sep=""), header=TRUE)	
	
	data.hs<-data.hs[-nrow(data.hs),]
	
	assign(files.hs[c], data.hs)

	data.tp<-read.table(paste(folder, years[a], "/tp/", files.tp[c], sep=""), header=TRUE)	
	
	data.tp<-data.tp[-nrow(data.tp),]
	
	assign(files.tp[c], data.tp)
	
			}
		
		all.dp<-do.call("rbind", lapply(files.dp, as.name))
		
		all.dp<-all.dp[-nrow(all.dp),]
		
		all.hs<-do.call("rbind", lapply(files.hs, as.name))
		
		all.hs<-all.hs[-nrow(all.hs),]
		
		all.tp<-do.call("rbind", lapply(files.tp, as.name))
		
		all.tp<-all.tp[-nrow(all.tp),]
		
		
		all<-merge(all.dp, all.hs, all=TRUE)
		
		all<-merge(all, all.tp, all=TRUE)
		
		all<-all[order(all$Unix),]
		
		outfile<-paste("/Users/kasmith/Documents/BallantineReef/Data/WeatherData/waves/multi/", "NZ_EReef_multi_", years[a], ".txt", sep="")
		write.table(all, outfile, quote=FALSE, row.names=FALSE, col.names=TRUE, sep="\t")

	
	}
	
	