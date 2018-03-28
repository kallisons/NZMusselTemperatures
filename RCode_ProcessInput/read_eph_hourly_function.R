read_eph_hourly<-function(latitude,longitude,startdate,duration)
{
p<-paste("/Users/kasmith/Code/BaseCode/ephemerishourly/eph --lat ",latitude," --lon ",longitude," --date ",startdate," --duration ",duration," --time 0 ",sep="")
read.table(pipe(p),col.names=c("date","time","TZ","sun_az","sun_el"))
}

 


 