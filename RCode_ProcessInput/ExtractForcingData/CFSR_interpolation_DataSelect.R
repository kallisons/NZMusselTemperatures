#Bilinearly interpolate Climate Forecasting System Reanlaysis data from a netcdf file to a single location (latitude, longitude) text file. 

#K. Allison Smith
#Last Updated: December 11, 2013

#Still using 32 bit R version

# pressfc 199311, 199312
# q2m 199311, 199312
# tmp2m 199311, 199312
# wnd10m 199311, 199312

#Required functions and packages
source("/Users/kasmith/Documents/BallantineReef/RCode/weichert.interp_function.R")
require(ncdf)
require(RNetCDF)
utinit.nc()

#Put all netcdf files in this folder
folder<-paste("/Volumes/HELIOS/CFSR_Data_NZ/", sep="")

#years<-c(1990,1991,1992,1993,1994,1995,1996,1997,1998,1999,2000,2001,2002,2003,2004,2005,2006,2007,2008,2009)

years<-c(1995,1996,1997,1998,1999,2000,2001,2002,2003,2004,2005,2006,2007,2008,2009)

for(j in 1:length(years)){

year<-years[j]

filenames<-list.files(path=paste(folder, year, "/", sep=""), pattern=NULL, full.names=FALSE, recursive=FALSE)

for(i in 1:length(filenames)){


nc<-open.ncdf(paste(folder, year, "/", filenames[i], sep=""))

#Latitude and Longitude of Sites
NZAKER<-c("NZAKER", -36.26963, 174.79453)
sites<-rbind(NZAKER)
sites<-sites[,-1]
class(sites)<-"numeric"
sites[2]<-sites[2]

times<-as.data.frame(nc$dim$time$vals)
colnames(times)<-"Time"
times$NZAKER<-rep(NA)


dims<-nc$var[[1]]$ndim
if(dims==3){
for(n in 1:nrow(times)){
	lats<-nc$dim$lat$vals
	lats<-sort(lats)
	lons<-nc$dim$lon$vals
	z<-get.var.ncdf(nc, nc$var[[1]], start=c(1,1,n), count=c(49,52,1))
	z<-z[,52:1]
	obj<-list(lats, lons, z)
	sitevalue<-weichert.interp(obj, sites)
	times[n,2]<-sitevalue
	}
}

if(dims==4){
for(n in 1:nrow(times)){
	lats<-nc$dim$lat$vals
	lats<-sort(lats)
	lons<-nc$dim$lon$vals
	z<-get.var.ncdf(nc, nc$var[[1]], start=c(1,1,1,n), count=c(49,52,1,1))
	z<-z[,52:1]
	obj<-list(lats, lons, z)
	sitevalue<-weichert.interp(obj, sites)
	times[n,2]<-sitevalue
	}
}



tunits<-nc$dim$time$units
dates<-utcal.nc(tunits, times$Time)
unix_units<-"seconds since 1970-1-1 00:00:0.0"
times$Unix<-utinvcal.nc(unix_units, dates)
jday_units<-paste("days since ",year],"-1-1 00:00:0.0",sep="")
times$jday<-floor(utinvcal.nc(jday_units, dates))+1)

ER<-times[,c("Unix", "jday", "NZAKER")]
#ER$NZAKER<-round(ER$NZAKER, digits=4)

colnames(ER)[3]<-nc$var[[1]]$name

outfile<-paste("/Volumes/HELIOS/CFSR_Data_NZ/EReef/", year, "/", filenames[i], sep="")

ER_outfile<-gsub("grb2.nc", "NZ_EReef.txt", outfile)
write.table(ER, ER_outfile, row.names=FALSE, col.names=TRUE, quote=FALSE, sep="\t")

close(nc)
}
}

