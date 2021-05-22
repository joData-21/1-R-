#jika belum terinstall 
# 1. install.package("terra")
# 2. install.package("dplyr")

#setting lingkungan kerja
library(dplyr)
library(terra)
setwd("D:/Proyek/2021/dev/terra/")

# ambil file SHP grid Extent dari materi sebelumnya
# dan file SHP bataskab dan bataskec

gridExtent <- vect("./hasil/gridExtent.shp") 
bts_kab <- vect("./data/BatasKab.shp") 
bts_kec <- vect("./data/BatasKec.shp") 

#buat grid per Adm Kab dan Adm Kec
gridkab<-intersect(gridExtent,bts_kab)
gridkec<-intersect(gridkab,bts_kec)

#hitung luas pada grid Kecamatan
gridkec$luas<-expanse(gridkec)/10000

#disolve grid yg mencakup 2 adm kecamatan 
#pada perbatasan kecamatan
#berdasarkan luas
d<-as.data.frame(gridkec)

kec<-d %>%
  select(FID,KECAMATAN, JLHPDDK, luas) %>%
  group_by(FID) %>%
  summarise(KECAMATAN=first(KECAMATAN),JLHPDDK=first(JLHPDDK), luas=max(luas))

#hasil penentuan adm kecamatan dan hitungan luas 
gabung<-merge(gridkab,kec,by="FID")  

head(gabung)

writeVector(gabung,"./hasil/gridkec.shp",overwrite=TRUE)

# PLOTTING
library(sf)
grid<-read_sf("hasil/gridkec.shp")

plot(grid['KECAMATAN'])

