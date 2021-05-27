#install.packages("readxl")
library(terra)
library("readxl")         

#1. set lingkungan kerja dan ambil file grid guna lahan
#   dan tabel penduduk per kecamatan

setwd("D:/Proyek/2021/dev/terra/")
gridgl <- vect("./hasil/gridgl.shp") 
pddk <- readxl::read_excel("data/penduduk.xlsx") 
View(pddk)

#2. Isikan jumlah pddk ke grid guna lahan
gabung<-merge(gridgl,pddk,by=c("KECAMATAN"))
View(as.data.frame(gabung))
# save kembali
writeVector(gabung,"./hasil/gridglpddk.shp",overwrite=TRUE)

#3. buat daftar jenis guna lahan
pl<-levels(as.factor(gridgl$plahan))
bobot<-rep("",length(pl))
bobotgl<-as.data.frame(cbind(cbind(pl,bobot)))
View(bobot)

#4. buat file excel bobotgl.xlsx
#install.packages("writexl")
library(writexl)
write_xlsx(koefgl,"./data/bobot.xlsx")

#5. Isikan besar bobot tiap jenis guna lahan 
#   pada file bobot.xlsx pada folder ./Data 

#6.jika sudah mengisi bobot pada file bobotgl.xlsx
#  akan dibaca kembali 
bobotgl <- readxl::read_excel("data/bobotgl.xlsx") 
View(bobotgl)

