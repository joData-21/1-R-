# setting library dan lingkungan kerja
library(sf)
library(raster)
setwd("D:/Proyek/2021/dev/terra/")

# ambil SHP administrasi dan koordinat extent
bts_kab <- st_read("./data/BatasKab.shp")
e <- extent(bts_kab)
xmin=e[1]
xmax=e[2]
ymin=e[3]
ymax=e[4]

# hitung ukuran grid dan jumlah grid 
selah=15/3600
lintang=as.integer((ymax-ymin)/selah)
bujur=as.integer((xmax-xmin)/selah)

# buat koordinat grid dalam dataframe
df<-data.frame(
               x1=xmin,
               y1=ymin,
               x2=xmin+selah,
               y2=ymin+selah)
for (i in 0:lintang+1)
  for (j in 0:bujur+1)
    df<-rbind(df,c(xmin+(selah*(j-1)),ymin+selah*(i-1),xmin+(selah*(j)),ymin+(selah*(i))))

# buat feature spasial dari dataframe
lst <- lapply(1:nrow(df), function(x){
  res <- matrix(c(df[x, 'x1'], df[x, 'y1'],
                  df[x, 'x2'], df[x, 'y1'],
                  df[x, 'x2'], df[x, 'y2'],
                  df[x, 'x1'], df[x, 'y2'],
                  df[x, 'x1'], df[x, 'y1'])
                , ncol =2, byrow = T
  )
  st_polygon(list(res))
  
})

sfdf <- st_sf(st_sfc(lst))
st_crs(sfdf) = 4326

#plotting 
plot(sfdf)
plot(bts_kab,add=TRUE)

#simpan grid dalam SHP
st_write(sfdf, "./hasil/gridextent.shp",delete_layer = TRUE)
