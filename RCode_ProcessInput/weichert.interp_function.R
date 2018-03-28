weichert.interp<- function (obj, loc) {
  # obj is a surface object like the list for contour or image.
  # loc is a matrix of (x, y) locations 
  x <- obj[[1]]
  y <- obj[[2]]
  x.new <- loc[1]
  y.new <- loc[2]
  z <- obj[[3]]

  ind.x <- findInterval(x.new, x, all.inside=T)
  ind.y <- findInterval(y.new, y, all.inside=T)

  ex <- (x.new - x[ind.x]) / (x[ind.x + 1] - x[ind.x])
  ey <- (y.new - y[ind.y]) / (y[ind.y + 1] - y[ind.y])

  # set weights for out-of-bounds locations to NA
  ex[ex < 0 | ex > 1] <- NA
  ey[ey < 0 | ey > 1] <- NA

  return(
      z[cbind(ind.y,     ind.x)]     * (1 - ex) * (1 - ey) +  # upper left
      z[cbind(ind.y + 1, ind.x)]     * (1 - ex) * ey       +  # lower left
      z[cbind(ind.y + 1, ind.x + 1)] * ex       * ey       +  # lower right
      z[cbind(ind.y,     ind.x + 1)] * ex       * (1 - ey)    # upper right
        )
}
