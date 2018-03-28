#Assembly: CFSR, MODAS SST, WW3-Global(nww2, multi_1), OTPS Tides
options(scipen=15)

site<-"NZAKER"
lat<--36.26963
lon<-174.79453
height<-0.5

airFolder<-paste("/Users/kasmith/Documents/BallantineReef/Data/WeatherData/tmp/", sep="")
airFiles<-list.files(path=airFolder, pattern=NULL, full.names=FALSE, recursive=FALSE)

dlwrfFolder<-paste("/Users/kasmith/Documents/BallantineReef/Data/WeatherData/dlwsfc/", sep="")
dlwrfFiles<-list.files(path=dlwrfFolder, pattern=NULL, full.names=FALSE, recursive=FALSE)

dswrfFolder<-paste("/Users/kasmith/Documents/BallantineReef/Data/WeatherData/dswsfc/", sep="")
dswrfFiles<-list.files(path=dswrfFolder, pattern=NULL, full.names=FALSE, recursive=FALSE)

prateFolder<-paste("/Users/kasmith/Documents/BallantineReef/Data/WeatherData/prate/", sep="")
prateFiles<-list.files(path=prateFolder, pattern=NULL, full.names=FALSE, recursive=FALSE)

presFolder<-paste("/Users/kasmith/Documents/BallantineReef/Data/WeatherData/pressfc/", sep="")
presFiles<-list.files(path=presFolder, pattern=NULL, full.names=FALSE, recursive=FALSE)

rhumFolder<-paste("/Users/kasmith/Documents/BallantineReef/Data/WeatherData/RH/", sep="")
rhumFiles<-list.files(path=rhumFolder, pattern=NULL, full.names=FALSE, recursive=FALSE)

uwndFolder<-paste("/Users/kasmith/Documents/BallantineReef/Data/WeatherData/uwnd/", sep="")
uwndFiles<-list.files(path=uwndFolder, pattern=NULL, full.names=FALSE, recursive=FALSE)

vwndFolder<-paste("/Users/kasmith/Documents/BallantineReef/Data/WeatherData/vwnd/", sep="")
vwndFiles<-list.files(path=vwndFolder, pattern=NULL, full.names=FALSE, recursive=FALSE)

for(a in 1:length(airFiles)){
	air<-read.table(paste(airFolder, airFiles[a], sep=""), header=TRUE)
	assign(airFiles[a], air)
	dlwrf<-read.table(paste(dlwrfFolder, dlwrfFiles[a], sep=""), header=TRUE)
	assign(dlwrfFiles[a], dlwrf)
	dswrf<-read.table(paste(dswrfFolder, dswrfFiles[a], sep=""), header=TRUE)
	assign(dswrfFiles[a], dswrf)
	prate<-read.table(paste(prateFolder, prateFiles[a], sep=""), header=TRUE)
	assign(prateFiles[a], prate)
	pres<-read.table(paste(presFolder, presFiles[a], sep=""), header=TRUE)
	assign(presFiles[a], pres)
	rhum<-read.table(paste(rhumFolder, rhumFiles[a], sep=""), header=TRUE)
	assign(rhumFiles[a], rhum)
	uwnd<-read.table(paste(uwndFolder, uwndFiles[a], sep=""), header=TRUE)
	assign(uwndFiles[a], uwnd)
	vwnd<-read.table(paste(vwndFolder, vwndFiles[a], sep=""), header=TRUE)
	assign(vwndFiles[a], vwnd)
	
	}
	
air<-do.call("rbind", lapply(airFiles, as.name))
dlwrf<-do.call("rbind", lapply(dlwrfFiles, as.name))
dswrf<-do.call("rbind", lapply(dswrfFiles, as.name))
prate<-do.call("rbind", lapply(prateFiles, as.name))
pres<-do.call("rbind", lapply(presFiles, as.name))
rhum<-do.call("rbind", lapply(rhumFiles, as.name))
uwnd<-do.call("rbind", lapply(uwndFiles, as.name))
vwnd<-do.call("rbind", lapply(vwndFiles, as.name))

weather<-merge(air, dlwrf, all=TRUE)
weather<-merge(weather, dswrf, all=TRUE)
weather<-merge(weather, prate, all=TRUE)
weather<-merge(weather, pres, all=TRUE)
weather<-merge(weather, rhum, all=TRUE)
weather<-merge(weather, uwnd, all=TRUE)
weather<-merge(weather, vwnd, all=TRUE)

weather<-weather[order(weather$Unix),]

colnames(weather)<-c("Unix", "jday", "air", "dlwrf", "dswrf", "prate", "pres", "rh", "uwnd", "vwnd")

weather$wnd<-sqrt(weather$uwnd^2+weather$vwnd^2)
weather$prate<-weather$prate*1800/25.4
weather$pres<-weather$pres/100
weather$air<-weather$air-273
weather<-round(weather, digits=2)

DateConvert<-weather$Unix
class(DateConvert)<-"POSIXct"
DateExtract<-as.POSIXlt(DateConvert)
weather$Date<-as.character(DateExtract, format="%Y-%m-%d")
weather<-weather[order(weather$Unix),]
duration<-length(unique(weather$Date))
Ephemeris<-read.table(pipe(paste("~/ephemeris/eph", " --lat ", lat, " --lon ", lon, "  --date ", weather$Date[1], " --duration ", duration, " --time 0")))
Ephemeris<-Ephemeris[,c(1,2,5)]
colnames(Ephemeris)<-c("Date", "T", "Elev")
Ephemeris$T<-round(as.numeric(Ephemeris$T), digits=1)
Ephemeris$Hour<-floor(as.numeric(Ephemeris$T))
Ephemeris$Minute<-(as.numeric(Ephemeris$T)-floor(as.numeric(Ephemeris$T)))*60
Ephemeris$Minute<-round(Ephemeris$Minute, digits=0)
Ephemeris$DateTime<-paste(Ephemeris$Date, " ", Ephemeris$Hour, ":", Ephemeris$Minute, sep="")
Ephemeris<-subset(Ephemeris, Ephemeris$Minute==0 | Ephemeris$Minute==30)
store<-strptime(Ephemeris$DateTime, "%Y-%m-%d %H:%M")
store2<-as.POSIXct(store)
class(store2)<-("numeric")
Ephemeris$Unix<-store2
Ephemeris<-Ephemeris[,c("Unix", "Elev")]

weather<-merge(weather, Ephemeris, all=TRUE)
weather<-weather[order(weather$Unix),]
weather$dswrf<-ifelse(weather$Elev<=0, 0, weather$dswrf)

MODASfolder<-paste("/Users/kasmith/Documents/BallantineReef/Data/WeatherData/SST/", sep="")
MODASfiles<-list.files(path=MODASfolder, pattern=NULL, full.names=FALSE, recursive=FALSE)

for(c in 1:length(MODASfiles)){
	sst<-read.table(paste(MODASfolder, MODASfiles[c], sep=""), header=TRUE)
	sst<-round(sst, digits=2)
	assign(MODASfiles[c], sst)
	}
sst<-do.call("rbind", lapply(MODASfiles, as.name))
sst<-sst[,c("Unix", "Temp")]
colnames(sst)[2]<-"sst"
weather<-merge(weather, sst, all=TRUE)

weather<-weather[,c("Unix", "air", "dlwrf", "prate", "pres", "rh", "wnd", "dswrf", "sst")]
colnames(weather)<-gsub("rh", "rhum", colnames(weather))

x<-weather$Unix
y<-weather$air
a<-approx(x,y,x, rule=2)
weather$air<-a$y

y<-weather$dlwrf
lw<-approx(x,y,x, rule=2)
weather$dlwrf<-lw$y

y<-weather$prate
pt<-approx(x,y,x, rule=2)
weather$prate<-pt$y

y<-weather$pres
pr<-approx(x,y,x, rule=2)
weather$pres<-pr$y

y<-weather$rhum
rh<-approx(x,y,x, rule=2)
weather$rhum<-rh$y

y<-weather$wnd
wd<-approx(x,y,x, rule=2)
weather$wnd<-wd$y

y<-weather$dswrf
sol<-approx(x,y,x, rule=2)
weather$dswrf<-sol$y

y<-weather$sst
wt<-approx(x,y,x, rule=2)
weather$sst<-wt$y
weather$sst<-weather$sst+273

weather[,c("air","dlwrf", "pres", "wnd", "dswrf", "sst")]<-round(weather[,c("air","dlwrf", "pres", "wnd", "dswrf", "sst")], digits=2)
weather$prate<-round(weather$prate, digits=5)
weather$rhum<-round(weather$rhum, digits=0)

#************************************************************
#Subset dates from January 30, 1997 onwards
#weather<-subset(weather, weather$Unix>=854582400)
#************************************************************

wavesfolder<-paste("/Users/kasmith/Documents/BallantineReef/Data/WeatherData/waves/", sep="")
wavesfiles<-list.files(path=wavesfolder, pattern=NULL, full.names=FALSE, recursive=FALSE)

for(d in 1:length(wavesfiles)){
	w<-read.table(paste(wavesfolder, wavesfiles[d], sep=""), header=TRUE, stringsAsFactors=FALSE)
	assign(wavesfiles[d], w)
	}
Wave<-do.call("rbind", lapply(wavesfiles, as.name))

slope<-20
slope<-tan(slope*(pi/180))
Wave$L<-(9.8*(Wave$tp^2))/(2*pi)
Wave$I<-slope/sqrt(Wave$hs/Wave$L)
Wave$I<-ifelse(Wave$hs==0, 0, Wave$I)
Wave$Runup<-Wave$hs*0.60*(Wave$I^0.34)
Wave<-Wave[,c("Unix", "Runup", "dp")]
Wave<-Wave[order(Wave$Unix),]

tides<-read.table(paste("/Users/kasmith/Documents/BallantineReef/Data/WeatherData/tides/OTPS_MLLW_NZ_EReef.txt", sep=""), header=TRUE)
tides$DateTime<-paste(tides$Date, tides$Time)
store<-strptime(tides$DateTime, "%m.%d.%Y %H:%M:%S")
store2<-as.POSIXct(store)
class(store2)<-("numeric")
tides$Unix<-store2
tides<-tides[,c("Unix", "Tide")]

#************************************************************
#Subset dates from January 30, 1997 onwards
#tides<-subset(tides, tides$Unix>=854582400)
#************************************************************

#WaveTide<-merge(Wave, tides, all=TRUE)

#x<-WaveTide$Unix
#y<-WaveTide$Runup
#ru<-approx(x,y,x, rule=2)
#WaveTide$Runup<-ru$y

#dir<-WaveTide$dp
#d<-approx(x,dir,x, rule=2)
#WaveTide$dp<-d$y

##Site Specific Effect of Wave Direction
#a<-135 #Degrees
#b<-248 #Degrees

#if(b>a){WaveTide$Runup<-ifelse(WaveTide$dp>a & WaveTide$dp<b, WaveTide$Runup, 0)}
#if(b<a){WaveTide$Runup<-ifelse(WaveTide$dp>a | WaveTide$dp<b, WaveTide$Runup, 0)}

#WaveTide$Runup<-round(WaveTide$Runup, digits=3)

#WaveTide$Tide<-WaveTide$Tide+WaveTide$Runup

#WaveTide$tideflag<-as.numeric(WaveTide$Tide<height)

tides$tideflag<-as.numeric(tides$Tide<height)

#TideFlag<-WaveTide[,c("Unix","tideflag")]
TideFlag<-tides[,c("Unix","tideflag")]
NOAH<-merge(weather, TideFlag)
NOAH<-NOAH[order(NOAH$Unix),]

DateConvert<-NOAH$Unix
class(DateConvert)<-"POSIXct"
DateExtract<-as.POSIXlt(DateConvert)
NOAH$hhmm<-as.character(DateExtract, format="%H%M")
class(NOAH$hhmm)<-"numeric"
NOAH$year<-as.character(DateExtract, format="%Y")
class(NOAH$year)<-"numeric"
allyears<-unique(NOAH$year)

for(y in 1:length(allyears)){
	final<-subset(NOAH, NOAH$year==allyears[y])
	DateConvert<-final$Unix
	class(DateConvert)<-"POSIXct"
	DateExtract<-as.POSIXlt(DateConvert)
	final$jday<-as.character(DateExtract, format="%j")
	class(final$jday)<-"numeric"
	final<-final[order(final$Unix),]
	final<-unique(final)
	final<-final[,c("jday", "hhmm", "wnd", "air", "rhum", "pres", "dswrf", "dlwrf", "prate", "sst", "tideflag")]
	print(site) 
	print(allyears[y])
	print(nrow(final))
	
	height2<-height*100
	
	write.table(final, paste("/Users/kasmith/Documents/BallantineReef/Model/Input/", site, "_", allyears[y], ".in", sep=""), quote=FALSE, row.names=FALSE, col.names=FALSE)

	}
