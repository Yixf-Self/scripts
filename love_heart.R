n=50000;
r=0.7;r_e=(1-r*r)^.5;
X=rnorm(n);
Y=X*r+r_e*rnorm(n);
Y=ifelse(X>0,Y,-Y);
a<-sample(c(2,6,7,8),50000,T)
b<-sample(c(76,79,86,69),50000,T)
plot(X,Y,col=0)
text(X,Y,"LOVE",col=a)
