#' @title plotTrack
#' @description Plot a flight track in lat-lon coordinates. 
#' @details The flight track is shown with appropriate geographic boundaries, and the lat-lon scales are adjusted to give rectilinear coordinates at the center of the plot. The center coordinates and size of the plot can be specified, or if omitted will be set to cover the range of data in the supplied coordinates. The range of indices to plot can  be supplied in the argument .Range or in the range of indices supplied with the arguments (lon, lat, Time). By default, labels are placed along the track every 15 min; this can be changed by the .Spacing argument.
#' @aliases plotTrack
#' @author William Cooper
#' @export plotTrack
#' @import maps
#' @importFrom stats median
#' @param lon A numeric vector of longitude coordinates (degrees). Optionally,
#' a data.frame containing the variables Time, LONC, LATC, WDC, WSC, in which
#' case the corresponding parameters below can be omitted. For a drifting plot (described
#' under optional parameter xc), the data.frame also needs TASX, THDG, SSLIP
#' @param lat A numeric vector of latitude coordinates (degrees) 
#' @param Time A POSIX-format vector of times corresponding to lat/lon
#' @param WDC A numeric vector of wind direction
#' @param WSC A numeric vector of wind speed
#' @param .Range A sequence of indices to use when plotting lat, lon, 
#' Time (default is 0 which causes the entire range of indices to be 
#' plotted.) 
#' @param xc An optional central longitude for the plot. If omitted, the range in 
#' lon[r] is used to determine the midpoint. If NA, this is a flag to plot a
#' dead-reckoning plot drifting with the wind with coordinates relative to the
#' starting point. This requires the calling format where a data.frame is supplied
#' because it needs additional variables (TASX, THDG, SSLIP) not supplied in the
#' normal argument list.
#' @param yc An optional central latitude for the plot. If omitted, the range in 
#' lat[r] is used to determine the midpoint.
#' @param sz An optional size in units of degrees for the plot. If omitted, the 
#' size is determined from 20\% more than the range of measurements.
#' @param .Spacing The spacing between time labels placed on the graph, 
#' in minutes. The default is 15 min.
#' @param .WindFlags A scale factor for wind flags placed along the track, 
#' in units of percentage of the plot size. The default is 0 which suppresses the flags. 
#' A common value is 5.
#' @param .Add A logical flag that, if true, does not generate the plot frame and axes
#' but instead just adds a new line to an existing track. This will not reset the
#' scales, so to span a full flight it may be useful to include the full flight in the
#' definition of the data.frame and then use .Range for individual plots with .Add=TRUE.
#' @param ... Additional arguments passed to the plot routine to control 
#' graphics parameters etc. 
#' @return none -- The result is the plot.
#' @examples 
#' plotTrack (RAFdata, sz=8, .Spacing=5)
#' plotTrack (RAFdata, sz=1, .Spacing=1, .WindFlags=2)

plotTrack <- function (lon, lat=NULL, Time=NULL, WDC=NULL, 
                       WSC=NULL, .Range=0, xc=NULL, yc=NULL, 
                       sz=NULL, .Spacing=15, .WindFlags=0, .Add=FALSE, ...) {
  DRIFT <- FALSE
  # suppressMessages (library ("maps"))
  
  if (is.data.frame (lon)) {
    df <- lon
    lat <- df$LATC
    Time <- df$Time
    if (length(.Range) < 2) {
      .Range <- 1:length(Time)
    }
    
    WDC <- df$WDC
    WSC <- df$WSC
    lon <- df$LONC
    if (!is.null(xc) && is.na(xc)) {
      DRIFT <- TRUE
      # find the data.rate
      data.rate <- 1
      if (df$Time[2] - df$Time[1] <= 0.04) {data.rate <- 25}
      if (df$Time[2] - df$Time[1] <= 0.02) {data.rate <- 50}
      # df <- df[.Range, ]
      THDG <- (df$THDG + df$SSLIP) * pi / 180
      TASX <- df$TASX
      ## try to interpolate for missing values
      TASX <- zoo::na.approx (as.vector(TASX), maxgap=1000, na.rm = TRUE)
      THDG <- zoo::na.approx (as.vector(THDG), maxgap=1000, na.rm = TRUE)
      xp <- 0
      yp <- 0
      xa <- vector ("numeric", nrow(df))
      ya <- vector ("numeric", nrow(df))
      for (i in 1:nrow(df)) {
        xa[i] <- xp <- xp + TASX[i] * sin (THDG[i]) / data.rate
        ya[i] <- yp <- yp + TASX[i] * cos (THDG[i]) / data.rate
      }
      xa <- xa * 0.001
      ya <- ya * 0.001
      xlow <- suppressWarnings (min (xa, na.rm=TRUE))
      xhigh <- suppressWarnings (max (xa, na.rm=TRUE))
      ylow <- suppressWarnings (min (ya, na.rm=TRUE))
      yhigh <- suppressWarnings (max (ya, na.rm=TRUE))
      if (is.null (sz)) {
        xl <- c(xlow-0.05*(xhigh-xlow), xhigh+0.05*(xhigh-xlow))
        yl <- c(ylow-0.05*(yhigh-ylow), yhigh+0.05*(yhigh-ylow))
      } else {
        xc <- (xhigh + xlow) / 2
        yc <- (yhigh + ylow) / 2
        xl <- c(xc-sz/2, xc+sz/2)
        yl <- c(yc-sz/2, yc+sz/2)
      }
      if (.Add) {
        lines (xa[.Range], ya[.Range], ...)
      } else {
        plot (xa[.Range], ya[.Range], type='l', xlim=xl, ylim=yl, asp=1, lwd=2, col='blue',
              xlab="distance east [km]", ylab="distance north [km]", ...)
      }
      ltm <- as.POSIXlt(Time)
      inx <- 1:length(ltm)
      ltime <- Time[(ltm$min %% .Spacing == 0) & (ltm$sec == 0)]
      ltime <- ltime[!is.na(ltime)]
      #print(ltime)
      #print (sprintf (" length(ltime)=%d, length (inx)=%d", length(ltime), length(inx)))
      #print (ltime)
      for (lt in ltime) {
        ix <- inx[(Time == lt)]
        ix <- ix[!is.na(ix)]
        ## print (sprintf("ix=%d .Range[1]=%d, .Range[L]=%d",  ix, .Range[1], .Range[length(.Range)]))
        if ((ix >= .Range[1]) && (ix <= .Range[length(.Range)])) {
          lbl <- sprintf ("%02d%02d", ltm$hour[ix], ltm$min[ix])
          text (xa[ix], ya[ix], lbl, col='red', pos=4)
          points (xa[ix], ya[ix], pch=16, col='RED')
        }
      }
    } 
  }
  if (!DRIFT) {
    if (length(.Range) < 2) {
      .Range <- 1:length(Time)
    }
    xlow <- suppressWarnings (min (lon[.Range], na.rm=TRUE))
    xhigh = suppressWarnings (max (lon[.Range], na.rm=TRUE))
    ylow <- suppressWarnings (min (lat[.Range], na.rm=TRUE))
    yhigh = suppressWarnings (max (lat[.Range], na.rm=TRUE))
    if (is.null (xc)) {xc <- (xlow + xhigh) / 2}
    if (is.null (yc)) {yc <- (ylow + yhigh) / 2}
    if (is.null (sz)) {
      xt <- max (xhigh - xc, xc - xlow)
      yt <- max (yhigh - yc, yc - ylow)
      xl <- c (xc - xt*1.1, xc + xt*1.1)
      yl <- c (yc - yt*1.1, yc + yt*1.1)
    } else {
      xl <- c (xc-sz/2, xc+sz/2)
      yl <- c (yc-sz/2, yc+sz/2)
    }
    
    sz <- max (xl[2] - xl[1], yl[2] - yl[1])
    
    ap <- 1. / cos (median (lat[.Range], na.rm=TRUE)*pi/180.)
    if (.Add) {
      lines (lon[.Range], lat[.Range], ...)
    } else {
      plot (lon[.Range], lat[.Range], type='n', xlim=xl, ylim=yl, asp=ap, pty='s',
            xlab=expression(paste("Longitude [",degree,
                                  "]")), ylab=expression(paste("Latitude [",degree,"]")), ...)
      suppressWarnings (
        if ((min(lon[.Range], na.rm=TRUE) < -130) 
            | (max(lon[.Range], na.rm=TRUE) > -70.)
            | (min(lat[.Range], na.rm=TRUE) < 30.) 
            | (max(lat[.Range], na.rm=TRUE) > 50.)) {
          if (requireNamespace("maps", quietly=TRUE)) {
            maps::map("world", add=TRUE, fill=FALSE, col="black", lty=2)
          }
        } else {
          if (requireNamespace ("maps", quietly=TRUE)) {
            maps::map('state', add=TRUE, fill=FALSE, col="black", lty=2)
          }
        }
      )
      points (lon[.Range], lat[.Range], type='l', col='blue', 
              xlab='Latitude [deg.]', ylab='Longitude [deg.]', ...)
    }
    ltm <- as.POSIXlt(Time)
    inx <- 1:length(ltm)
    ltime <- Time[(ltm$min %% .Spacing == 0) & (ltm$sec == 0)]
    ltime <- ltime[!is.na(ltime)]
    #print(ltime)
    #print (sprintf (" length(ltime)=%d, length (inx)=%d", length(ltime), length(inx)))
    #print (ltime)
    for (lt in ltime) {
      ix <- inx[(Time == lt)]
      ix <- ix[!is.na(ix)]
      ## print (sprintf("ix=%d .Range[1]=%d, .Range[L]=%d",  ix, .Range[1], .Range[length(.Range)]))
      if ((ix >= .Range[1]) && (ix <= .Range[length(.Range)])) {
        lbl <- sprintf ("%02d%02d", ltm$hour[ix], ltm$min[ix])
        text (lon[ix], lat[ix], lbl, col='red', pos=4)
        points (lon[ix], lat[ix], pch=16, col='RED')
      }
    }
    # plot 50 wind flags along track:
    if (.WindFlags > 0.) {
      skip <- length(Time[.Range]) / 50
      if (skip < 1) {skip <- 1}
      rw <- seq (.Range[1], .Range[length(.Range)], by=skip)
      for (l in rw) {
        wfx <- -1. * WSC[l] * sin (WDC[l] * pi/180.)
        wfy <- -1. * WSC[l] * cos (WDC[l] * pi / 180.)
        dlt <- 0.001 * .WindFlags * wfy * sz
        dlg <- 0.001 * .WindFlags * wfx * sz * ap
        lines (c(lon[l], lon[l]+dlg), c(lat[l], lat[l]+dlt), 
               lty=1, col='forestgreen')
      }
    }
  }
}


