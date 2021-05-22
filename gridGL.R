# install.package("dplyr")
# install.package("terra")
library(dplyr)
library(terra)

#setting lingkungan kerja
setwd("D:/Proyek/2021/dev/terra/")

# ambil file SHP grid Kecamatan dari materi sebelumnya
# dan file SHP Tutupan Lahan

gridkec <- vect("./hasil/gridkec.shp") 
gl <- vect("./data/TUTUPAN_LAHAN_AR.shp") 

#buat grid per Tutupan Lahan
gridgl<-intersect(gridkec,gl)

#hitung luas pada grid guna lahan
gridgl$luas<-expanse(gridgl)/10000

#untuk grid yang memiliki lebih dari 1 jenis tutupan lahan 
#dipilih jenis tutupannya, berdasarkan luas jenis tutupan lahan terbesar
dfgl<-as.data.frame(gridgl)
lahan<-dfgl %>%
  select(FID,KECAMATAN,plahan, luas) %>%
  group_by(FID) %>%
  summarise(KECAMATAN=first(KECAMATAN),plahan=first(plahan), luas2=max(luas))

gabung<-merge(gridkec,lahan,by=c("FID","KECAMATAN"))

head(gabung)

writeVector(gabung,"./hasil/gridgl.shp",overwrite=TRUE)

# PLOTTING
library(sf)
grid<-read_sf("hasil/gridgl.shp")

plot(grid['plahan'])

