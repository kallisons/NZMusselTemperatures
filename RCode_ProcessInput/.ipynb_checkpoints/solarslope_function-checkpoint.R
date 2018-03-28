solarslope<-function(lat, lon, slope, aspect, albedo, dswrf)
{
source("read_eph_hourly_function.R")

#The Input Table solardata needs to have 2 columns labeled "Unix", "dswrf"

timestore<-(dswrf$Unix)
class(timestore)<-c("POSIXct")
dswrf$date<-format(timestore, format="%Y-%m-%d")
dswrf<-dswrf[order(dswrf$Unix),]
startdate<-dswrf$date[1]
duration<-length(unique(dswrf$date))
dswrf<-dswrf[,c("Unix","dswrf")]
eph<-read_eph_hourly(lat,lon,startdate,duration)
eph<-eph[,c("date","time","sun_el")]
eph$date<-as.character(eph$date)
eph$time<-gsub(24, 0, eph$time)
eph$index<-as.numeric(rownames(eph))
eph$date<-ifelse(eph$time==0, eph$date[eph$index+1], eph$date)
eph$date<-paste(eph$date, eph$time, sep=" ")
store<-strptime(eph$date, "%Y-%m-%d %H")
store2<-as.POSIXct(store)
class(store2)<-("numeric")
eph$Unix<-store2
eph<-eph[,c("Unix","sun_el")]
solardata<-merge(dswrf, eph, all=TRUE, sort=TRUE)
solardata$dswrf<-ifelse(solardata$sun_el<=0, 0, solardata$dswrf)
x<-solardata$Unix
y<-solardata$dswrf
store<-approx(x,y,x, method="linear",rule=2)
solardata$dswrf<-round(store$y,digits=3)
timestore<-(solardata$Unix)
class(timestore)<-c("POSIXct")
solardata$hour<-as.numeric(format(timestore, format="%H"))
solardata$date<-format(timestore, format="%Y-%m-%d")
solardata$jday<-as.numeric(format(timestore, format="%j"))
solardata<-solardata[order(solardata$Unix),]
solardata<-solardata[,c("date","jday","hour","dswrf")]
colnames(solardata)<-c("Date", "Jday", "Hour", "Global")

DateStart<-solardata$Date[1]
Diff<-length(unique(solardata$Date))
Ephemeris<-read_eph_hourly(lat,lon,DateStart,Diff)
Ephemeris$time<-gsub(24, 0, Ephemeris$time)
Ephemeris$index<-as.numeric(rownames(Ephemeris))
Ephemeris$date<-as.character(Ephemeris$date)
Ephemeris$date<-ifelse(Ephemeris$time==0, Ephemeris$date[Ephemeris$index+1], Ephemeris$date)
Ephemeris$date<-paste(Ephemeris$date, Ephemeris$time, sep=" ")
store<-strptime(Ephemeris$date, "%Y-%m-%d %H")
store2<-as.POSIXct(store)
Ephemeris$Unix<-as.numeric(store2)

eph4<-Ephemeris[,c("Unix","sun_az","sun_el")]
store<-eph4$Unix
class(store)<-"POSIXct"
eph4$jday<-as.numeric(format(store, format="%j"))
eph4$hour<-as.numeric(format(store, "%H"))
eph4$date<-format(store, format="%Y-%m-%d")
eph5<-eph4[,c("Unix", "date","jday","hour","sun_az","sun_el")]
eph5$sun_el<-replace(eph5$sun_el, eph5$sun_el<0, 0)
colnames(eph5)<-c("Unix", "Date", "Jday", "Hour", "sun_az", "sun_el")


soleph<-merge(solardata, eph5, sort=TRUE)
soleph<-soleph[order(soleph$Unix),]
soleph$Global<-replace(soleph$Global, soleph$sun_el==0, 0)

##The Following Equations Require a table named sunslope with 5 columns with the column names: "Date", "Jday", "Hour", "Global", "Azimuth", "Solar_Elev"
sunslope<-soleph

#Convert variable from degrees to radians
lat<-lat*(pi/180)
slope<-slope*(pi/180)
#The line below is used to fix southern hemisphere equations from Tian page 73, south=0, north=180 
aspect<-ifelse(aspect<=180, 180-aspect, 540-aspect)
aspect<-aspect*(pi/180)

#Find the Zenith angle and convert to radians
sunslope$Zenith<-(90-sunslope$sun_el)*(pi/180)
sunslope$Azimuth<-(180-sunslope$sun_az)*(pi/180)

##This equation comes from Iqbal 1983 pg 61, it yields the instantaneous radiation for 1 hour centered around the Zenith angle for the midpoint of the hour
#Solar Constant in Watts per square meter
Isc<-1353
#E=eccentricity of the earth's orbit
sunslope$day_angle<-(pi*(sunslope$Jday-1))/180
sunslope$E<-1.000110+0.034221*cos(sunslope$day_angle)+0.001280*sin(sunslope$day_angle)+0.000719*cos(2*sunslope$day_angle)+0.000077*sin(2*sunslope$day_angle)

sunslope$I0<-Isc*sunslope$E*cos(sunslope$Zenith)
sunslope$I0<-replace(sunslope$I0, sunslope$I0<0.0001, 0)
sunslope$I0<-round(sunslope$I0, digits=3)

#Equations obtained from from Iqbal 1983 and Revfeim 1978

sunslope$cosz<-cos(sunslope$Zenith)
sunslope$cosz<-replace(sunslope$cosz, sunslope$cosz<0.0001, 0)

sunslope$cosz_arbitrary<-cos(slope)*cos(sunslope$Zenith)+sin(slope)*sin(sunslope$Zenith)*cos(sunslope$Azimuth-aspect)

sunslope$Rd<-sunslope$cosz_arbitrary/sunslope$cosz
sunslope$Rd<-replace(sunslope$Rd, sunslope$Rd<0, 0)

fb<-(1-(slope/pi))

##Sometimes (usually at dawn and dusk when the values have more error and can be artificially inflated by interpolation methods) the Global is measuring higher then the solar extraterrestrial.  The following equations correct for the problem.  There is a larger correction factor for solar_elevations less than 20 degrees which was calculated by taking the average of the ratio of Global to Extraterrestrial for Eugene, Oregon when the values for Global were less than Extraterrestrial*0.8.

sunslope$Global<-ifelse(sunslope$Global>sunslope$I0*0.8 & sunslope$sun_el>20, sunslope$I0*0.8, ifelse(sunslope$Global>sunslope$I0*0.8 & sunslope$sun_el<20, sunslope$I0*0.35, sunslope$Global))

##############################################


sunslope$S_Ratio<-sunslope$Global/sunslope$I0

#Use piece wise linear relationship calculated for data from Eugene, Oregon
sunslope$Kr<-ifelse((sunslope$Global/sunslope$I0)<=0.35 & (sunslope$Global/sunslope$I0)>0, (-0.205)*(sunslope$Global/sunslope$I0)+0.973, ifelse((sunslope$Global/sunslope$I0)<=0.7 & (sunslope$Global/sunslope$I0)>0.35, (-1.994)*(sunslope$Global/sunslope$I0)+1.631, ifelse((sunslope$Global/sunslope$I0)>0.7 & (sunslope$Global/sunslope$I0)<=1, 0.2297, NA)))


sunslope$direct<-sunslope$Global*sunslope$Rd*(1-sunslope$Kr)

sunslope$Ga<-sunslope$Global*(sunslope$Rd*(1-sunslope$Kr)+fb*sunslope$Kr+albedo*(1-fb))

final_solar<-sunslope[,c("Unix", "Ga")]
colnames(final_solar)<-c("Unix", "dswrf")

final_solar$dswrf<-round(replace(final_solar$dswrf, is.na(final_solar$dswrf), 0), digits=3)

maxtarg<-max(dswrf$Unix)
mintarg<-min(dswrf$Unix)

final_solar<-subset(final_solar, final_solar$Unix>=mintarg & final_solar$Unix<=maxtarg)

return(final_solar)
}