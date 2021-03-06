% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/ggplotWAC.R
\name{ggplotWAC}
\alias{ggplotWAC}
\title{ggplotWAC}
\usage{
ggplotWAC(.data, col = "blue", xlab = "TIME [UTC]", ylab = "",
  lwd = 1, lty = 1, logxy = "", position = NA, lmargin = NA,
  ylim = NA, legend.position = c(0.5, 0.92), panels = 1,
  labelL = NA, labelP = NA, gtitle = NA, theme.version = 0, ...)
}
\arguments{
\item{.data}{A data.frame containing vectors to plot. The first will be the
abscissa and the remainder ordinate vectors to plot vs the abscissa.}

\item{col}{Color to pass to plot (default: blue). Can be multiple values
to set colors for multiple variables in data.frame mode. There are defaults
('blue', 'forestgreen', 'red', 'skyblue', 'darkorange') but values provided with
this parameter precede that sequence of colors.}

\item{xlab}{Label for the abscissa, to pass to plot (default: "TIME [UTC]")}

\item{ylab}{Label for the ordinate, to pass to plot (default: second
variable name)}

\item{lwd}{Line width to pass to plot (default: 1); can be a vector}

\item{lty}{Line type to pass to plot (default: 1). Can be a vector.
variables provided in data.frame mode.}

\item{logxy}{Set to 'y' for log axes. This is provided (vs log='y') because it
makes possible translation of axis labels to 10^i format.}

\item{position}{An optional 2-element numeric vector specifying the
panel number (1 at the bottom) and the number of panels. Default is NA,
in which case the plot definition is returned; if specified, the plot
is instead plotted in an appropriate viewport. If further changes are
desired before plotting, this parameter should be left NA and the
appropriate viewport will then have to be defined and the plot inserted
via, e.g., print(g, vp=VP). To use this, include library(grid) and call
grid.newpage() before defining the first panel.}

\item{lmargin}{Specification for the left margin. Default is NA, in
which case the left margin in theme_WAC(), currently 1.3, will be used.
This is provided to help adjust multiple-panel plots when the size of
the axis labels varies, so that the body of the plots can remain aligned.}

\item{ylim}{A two-element numeric vector specifying the limits to use
for the ordinate. The default is NA, in which case the limits will be
determined from the range of values in the plotted variables.}

\item{legend.position}{This parameter specifies the position for the 
legend. The default is c(0.5, 0.92), inside but at the top of the plot.
The legend can also be suppressed by setting this parameter to NA. Then 
a legend can still be added after the ggplotWAC call.}

\item{panels}{The integer number of panels (facets) to be displayed. Default is 1,
in which case no faceting will be used. To display a set of panels aligned
vertically, e.g., to show multiple time-series plots, use this in conjunction
with the next three parameters, and call with a data.frame that contains
Time and N variables ordered in sets so that the first N/panels 
variables will be plotted in the top panel, etc. For faceted plots, the
resulting plot definition is returned for possible further modification
prior to printing, and viewports are not used internally by ggplotWAC.}

\item{labelL}{For N variables (excluding the first, which is often Time),
a character vector of length N/panels specifying 
the labels for the individual lines in each panel. These labels will appear
in the legend. The default is NA, in which case the legend will be suppressed.}

\item{labelP}{A character vector of length "panels" specifying the names 
of each panel. These labels will appear at the right side of each panel. The
default is NA, in which case generic "panel1", "panel2", etc., names will
be used.}

\item{gtitle}{The title to appear above the plot (default NA).}

\item{theme.version}{The theme version to pass to theme_WAC; default is 0.}

\item{...}{Additional arguments to pass to plot(), but don't include col, xlab, ylab, lwd, type, xaxt or yaxt}
}
\description{
Convenience routine for plots
}
\details{
Sets some plot defaults and calls ggplot and theme_WAC()
}
\examples{
\dontrun{ggplotWAC(RAFdata[, c("Time", "ATX", "DPXC")])}
\dontrun{with(RAFdata, ggplotWAC (data.frame ("Time"=Time, "TASX"=TASX), ylab="TAS"))}
}
\author{
William Cooper
}
