require(ncdf)
require(RNetCDF)
require(psych)


var<-"dp"

folder<-paste("/Volumes/HELIOS/WaveWatch3_multi_NZ/", var, "/", sep="")
filenames<-list.files(path=folder, pattern=NULL, full.names=FALSE, recursive=FALSE)

#Latitude and Longitude of SST pixel closest to site
sitelat<--36
sitelon<-175

for(i in 1:length(filenames)){

nc<-open.ncdf(paste(folder, filenames[i], sep=""))
lats<-nc$dim$lat$vals
lons<-nc$dim$lon$vals

times<-as.data.frame(nc$dim$time$vals)
colnames(times)<-"Time"
lt<-as.matrix(abs(lons-sitelon))
ll<-as.matrix(abs(lats-sitelat))
lt<-lt^2
ll<-ll^2
distance<-sqrt(lt %+% t(ll))
pt<-match(min(distance),distance)

xdim<-nrow(distance)
xx<-pt%%xdim
yy<-pt%/%xdim+1

data<-get.var.ncdf(nc, nc$var[[1]], start=c(xx,yy,1), count=c(1,1,nrow(times)))
	
data<-round(data, digits=2)
print(lons[xx])
print(lats[yy])
	
times<-cbind(times, data)
colnames(times)<-c("Time", var)
	
tunits<-nc$dim$time$units
dates<-utcal.nc(tunits, times$Time)
unix_units<-"seconds since 1970-1-1 00:00:0.0"
times$Unix<-utinvcal.nc(unix_units, dates)
DateConvert<-times$Unix
class(DateConvert)<-"POSIXct"
DateExtract<-as.POSIXlt(DateConvert)
times$jday<-as.character(DateExtract, format="%j")
times$jday<-as.numeric(times$jday)

times<-times[,c("Unix", "jday", var)]


outfile<-paste("/Volumes/HELIOS/WaveWatch3_multi_NZ/EReef_", var, "/", filenames[i], sep="")

outfile<-gsub(".grb2.nc", "_NZ_EReef.txt", outfile)


write.table(times, outfile, row.names=FALSE, col.names=TRUE, quote=FALSE, sep="\t")

close.ncdf(nc)

}


