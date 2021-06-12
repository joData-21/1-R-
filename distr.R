#1. Setting Lingkungan Kerja dan Ambil Library yg Diperlukan

setwd("D:/Proyek/2021/dev/terra/")
library(sf)
library(raster)
library(dplyr)
library(readxl)         

#2. Ambil SHP hasil grid per GL
grid <- st_read("./hasil/gridgl.shp")
dfkecgl<-as.data.frame(grid)

#3. Ambil Data Tabel Pdddk dan Tabel Bobot Guna Lahan
pddk <- readxl::read_excel("./data/penduduk.xlsx") 
bobot<- readxl::read_excel("./data/bobotgl.xlsx")

#4. Summary Luas Lahan per GL tiap Kecamatan
kecgl<-dfkecgl %>%
  select(KECAMATAN,plahan, luas2) %>%
  group_by(KECAMATAN,plahan) %>%
  summarise(KECAMATAN=first(KECAMATAN),plahan=first(plahan), Ai=sum(luas2))

#5. Proses per Kecamatan
gabung<-as.data.frame(c())
for (i in 1:nrow(pddk)){
#   a. piliha masing2 Kecamatan dan Jumlah Penduduk Kecamatan 
  kec<-pddk[i,]$KECAMATAN
  pddkkec<-as.integer(pddk[i,]$JLHPDDK)

#   b. hitung luas total kecamatan
  luaskec<-sum(kecgl[kecgl$KECAMATAN==kec,]$Ai)

#   c. buat kolom tutupan, luas (Ai)
  tblkec<-kecgl[kecgl$KECAMATAN==kec,]

#   d. hitung A_i <- Ai x bobot_i
  colnames(bobot)[colnames(bobot)=="pl"]<-"plahan"
  tblgl<-merge(tblkec,bobot,by=c("plahan"))
  A_i<-tblgl[c('Ai','plahan')]
  A_i['KECAMATAN']<-kec
  A_i['A_i']<-tblgl['Ai']*tblgl['bobot']
  
#   e. hitung zai<-jumlah ZA_i
  Z_Ai<-sum(A_i['A_i'])

#   f. hitung A'i<-A'i dan azai<-A'/ZA'i
  A_i['AZA_i']<-A_i['A_i']/Z_Ai

#   g. hitung azaaai<-(Ai * A'/ZA'i)
  A_i['AZAA_i']<-A_i['Ai']*A_i['AZA_i']

#   h. hitung persen_ai(A'i * A'/ZA'i)/Z(A'i * A'/ZA'i)
  ZAZAA_i<-sum(A_i['AZAA_i'])
  A_i['AAZAA_i']<-A_i['AZAA_i']/ZAZAA_i
  
#   i. hitung pddkai<- persen_ai*pddk
  A_i['pddk']<-A_i['AAZAA_i']*pddkkec
  
#   j. hitung densai<- pddkai/ai
  A_i['padat']<-A_i['pddk']/A_i['Ai']

#   k. hitung jumlah pddk per grid pd GLGrid
  a<-merge(grid[grid$KECAMATAN %in% c(kec),],A_i[c('plahan','padat')],by=c('plahan'))
  a['pddk']<-as.integer(a$luas2 * a$padat)
  gabung<-rbind(gabung,a)

}

# SIMPAN HASIL GRID PENDUDUK
st_write(gabung, "./hasil/gridpddk.shp",delete_layer= TRUE)

# PROSES PLOTTING
#1. Klasifikasi berdasarkan jumlah penduduk
gabung<-within(gabung,{
pddk.kls <- NA
pddk.kls[pddk<50]<-"Sangat Rendah"
pddk.kls[pddk>=50 & pddk<100]<-"Rendah"
pddk.kls[pddk>=100 & pddk<250]<-"Sedang"
pddk.kls[pddk>=250 & pddk<500]<-"Tinggi"
pddk.kls[pddk>=500]<-"Sangat Tinggi"
})

#2. Setting Klasifikasi
kelas<-c("Sangat Tinggi","Tinggi","Sedang","Rendah","Sangat Rendah")
rentang<-c(">= 500 jiwa","250-500 jiwa","100-250 jiwa","50-100 jiwa","<50 jiwa")
gabung$pddk.kls<-factor(gabung$pddk.kls,levels=kelas)
warna <- c("#ffebcc","#ffd699","#ffad33","#b36b00","#331f00")

#3. Plotting
plot(gabung['pddk.kls'],col=warna[gabung$pddk.kls],
     main="Sebaran Penduduk perGrid")
legend("bottomleft",legend=kelas,col=1:5)


