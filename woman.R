xrange = c(-15, 15)
yrange = c(0, 16)
plot(0, xlim = xrange, ylim = yrange, type = "n")
#plot(xrange, yrange, type="n", ann=FALSE, axes=FALSE)
yr = seq(yrange[1], yrange[2], len = 50)
offsetFn = function(y) {
    2 * sin(0 + y/3)
}
offset = offsetFn(yr)
leftE = function(y) {
    -10 - offsetFn(y)
}
rightE = function(y) {
    10 + offsetFn(y)
}
xp = c(leftE(yr), rev(rightE(yr)))
yp = c(yr, rev(yr))
polygon(xp, yp, col = "#ffeecc", border = NA)
h = 9
xt = seq(0, rightE(h), len = 100)
yt = log(1 + log(1 + log(xt + 1)))
yt = yt - min(yt)
yt = h * yt/max(yt)
x = c(leftE(h), rightE(h), rev(xt), -xt)
y = c(h, h, rev(yt), yt)
polygon(x, y, col = "red", border = NA)
