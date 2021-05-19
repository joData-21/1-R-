#jika belum terinstall 
# 1. install.package("terra")
# 2. install.package("dplyr")

#setting lingkungan kerja

library("terra")
setwd("D:/Proyek/2021/dev/terra/")

# ambil file SHP grid Extent dari materi sebelumnya
# dan file SHP bataskab dan bataskec

gridExtent <- vect("./data/gridExtent.shp") 
bts_kab <- vect("./data/BatasKab.shp") 
bts_kec <- vect("./data/BatasKec.shp") 

#buat grid per Adm Kab dan Adm Kec
gridkab<-intersect(gridExtent,bts_kab)
gridkec<-intersect(gridkab,bts_kec)

#hitung luas pada grid kabupaten
gridkab$luas<-expanse(gridkab)/10000

#hitung luas pada grid Kecamatan
gridkec$luas2<-expanse(gridkec)/10000

library(dplyr)

#disolve grid yg mencakup 2 adm kecamatan 
#pada perbatasan kecamatan
#berdasarkan luas
d<-as.data.frame(gridkec)

kec<-d %>%
  select(FID_1,KECAMATAN, JLHPDDK, luas2) %>%
  group_by(FID_1) %>%
  summarise(KECAMATAN=first(KECAMATAN),JLHPDDK=first(JLHPDDK), luas=max(luas2))

#hasil penentuan adm kecamatan dan hitungan luas 
gabung<-merge(gridkab,kec,by="FID_1")  

head(gabung)

writeVector(gabung,"./hasil/gridkec.shp",overwrite=TRUE)

# PLOTTING
library(sf)
grid<-read_sf("hasil/gridkec.shp")

plot(grid['KECAMATAN'])

