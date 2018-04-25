#!/bin/sh
rm fnames.txt

filepathin=../modelinput/future/
#filepathout=../modeloutput/
filepathout=/Data/NZ_MusselModelOutput/modeloutput/future/
beddepth=5
for site in NZSIBT NZSINR  
do
for point in 050 060 070 080 090 100 110 120 130 140 150 160 170 180 190 200 210 220 230 240 250
do
for CNTCT in 0.5 
do
rm namelist_mussel_${beddepth}cm_bed.txt
	echo "&SOIL_VEG" > namelist_mussel_${beddepth}cm_bed.txt
	echo "LPARAM = .TRUE." >> namelist_mussel_${beddepth}cm_bed.txt
	echo "Z0_DATA(14)=0.008" >> namelist_mussel_${beddepth}cm_bed.txt
	echo "BEDDEPTH_DATA=5" >> namelist_mussel_${beddepth}cm_bed.txt
	echo "CNTCT_DATA =" ${CNTCT} >> namelist_mussel_${beddepth}cm_bed.txt
	echo "EMISSIVITY_DATA = 0.8" >> namelist_mussel_${beddepth}cm_bed.txt
	echo "/" >> namelist_mussel_${beddepth}cm_bed.txt
	echo " " >> namelist_mussel_${beddepth}cm_bed.txt
cp generic_initial_conditions.txt init_conds.txt
  for year in 1997 1998 1999 2000 2001 2002 2003 2004 2005 2006 2007 2008 2009
  do
     echo " " > fnames.txt
     echo "${filepathin}${site}/height${point}cm/${site}_${point}cm_${year}_cmip5.in" >> fnames.txt
     echo "${filepathin}${site}/height${point}cm/${site}_${point}cm_${year}_cmip5.in" >> fnames.txt
    
   if [ $year -eq 2000 ] || [ $year -eq 2004 ] || [ $year -eq 2008 ] 
    then
      echo $year 
      cp controlfile_top_leap_30min.txt controlfile_top.txt
    else
      echo $year
      cp controlfile_top_noleap_30min.txt controlfile_top.txt	
    fi
  cat controlfile_top.txt fnames.txt controlfile_bot_1.txt init_conds.txt controlfile_end.txt > controlfile.1
  ./LSMM2 controlfile.1 |awk -f get_initial_conditions.awk > init_conds.txt

#MAKE COMMENTS
  mkdir ${filepathout}${site}
  mkdir ${filepathout}${site}/height${point}cm/
  cp THERMO.TXT ${filepathout}${site}/height${point}cm/${site}_${point}cm_${year}_cmip5.out 
  
  rm 2.7.1_ET.tx
  rm 2.7.1_forcing.tx
  rm 2.7.1_SEB.tx
  rm 2.7.1_snow.tx
  rm 2.7.1_soilmoist.tx
  rm 2.7.1_tempsC.tx
  rm DAILY.TXT
  rm HYDRO.TXT
  rm OBS_DATA.TXT
  rm THERMO.TXT
  done
done
done
done