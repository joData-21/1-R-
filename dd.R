setwd("../data/") # disesuaikan folder workspace
bts_admin <- vect("./BATAS_ADMINISTRASI_AR.shp") 
plot(bts_admin)
e=ext(bts_admin)
xmin=x[1]
xmax=x[2]
ymin=x[3]
ymax=x[4]

selah=15/(3600)

lintang=as.integer((ymax-ymin)/selah)
bujur=as.integer((xmax-xmin)/selah)

x=xmin
y=ymin
kotak<-list()
scrs="+proj=longlat +datum=WGS84"

dat <- lapply(1:200, function(i){
    res<-list(xx=c(x+selah*(i-1),x+selah*(i),x+selah*(i),x+selah*(i-1)),
              yy=c(y,y,y+selah,y+selah))  
    print(res)
    return(res)
})
plot(97.9:99,2.8:4.3,type="n")
lapply(dat,function(x){polygon(x$xx,x$yy,col="gray",border="red")})
print(dat)



for (i in 1:2){
  a<-c(x,x+selah,x+selah,x)
  b<-c(y,y,y+selah,y+selah)
  lonlat <- cbind(a,b)
  kotak[length(kotak)+1]<-lonlat
  x<-x+selah
}
p <- vect(kotak, type="polygons", crs=scrs)
plot(p)

