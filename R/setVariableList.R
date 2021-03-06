
#' @title setVariableList
#' @description GUI for selecting from available netCDF variables (under development)
#' @details A display of buttons for all the available variables in a netCDF
#' file is generated, with variables already in 'VarList' highlighted.
#' Clicking on buttons highlights them also, and when the File->Set Selections
#' menu item is selected the highlighted list is written to 'VarList'. This
#' routine does some dangerous things with scope to make the tcltk structure
#' work, including assuming that 'VarList' exists in the global environment
#' and, at the end, writing to that variable list. It will over-write an 
#' existing 'VarList'.
#' @aliases setVariables
#' @author William Cooper
#' @export setVariableList
#' @import tcltk
#' @param fname The name of a netCDF file containing variables.
#' @param VarList A vector of character names to be selected before user interaction.
#' This might be the result of a call to Ranadu::standardVariables(), for example.
#' @param single A logical flag indicating if only one selection should be returned and
#' the function should return immediately after the first selection is made.
#' @return A vector of character names of the selected variables.
#' @examples 
#' \dontrun{setVariableList("/scr/raf_data/WINTER/WINTERrf11.nc", c("ATX", "PSXC"))}

setVariableList <- function (fname, VarList=vector(), single=FALSE) {
  
  requireNamespace("tcltk")
  ## callback functions:
  varClick <- function(v) {
    # print (sprintf("entry to varClick, argument %s", v))
    n <- as.integer(v)
    if (vnSel[n]) {
      vnSel[n] <<- FALSE
      eval(parse(text=sprintf("tkconfigure (lbl%d, foreground='black', background='gray90')", n)))
      VarNames <<- VarNames[-match(vn[n], VarNames)]
    } else {
      vnSel[n] <<- TRUE
      eval(parse(text=sprintf("tkconfigure (lbl%d, foreground='blue', background='yellow')", n)))
      VarNames[length(VarNames)+1] <<- vn[n]
    }
    #tclvalue(labelName[2]) <- paste(v,"#", sep='')
    #label1 <- tklabel(guiVar, text = tclvalue(labelText))
    #tkmessageBox (message = sprintf("Clicked button %s", v))
    if (single) {tkdestroy (guiVar)}
  }
  GoBack <- function () {
    # assign("VarList", VarNames, envir=.GlobalEnv)
    tkdestroy (guiVar)
  }
  SelectAll <- function () {
    VarNames <<- vn
    for (m in 1:length(vn)) {
      vnSel[m] <<- TRUE
      eval(parse(text=sprintf("tkconfigure (lbl%d, foreground='blue', background='yellow')", m)))
    }
  }
  RemoveAll <- function () {
    VarNames <<- vector()
    for (m in 1:length(vn)) {
      vnSel[m] <<- FALSE
      eval(parse(text=sprintf("tkconfigure (lbl%d, foreground='black', background='gray90')", m)))
    }
  }
  ## start of main tcltk function
  netCDFfile <- nc_open (fname)
  vn <- sort (names (netCDFfile$var))
  vnSel <- vector ("logical", length(vn))
  nc_close (netCDFfile)
  VarNames <- VarList
  ## exclusions:
  iw1 <- which(grepl('MTP$', vn))
  iw2 <- which(grepl('^IRIG', vn))
  if (length(iw1) > 0) {
    vn <- vn[-iw1]
  }
  if (length(iw2) > 0) {
    vn <- vn[-iw2]
  }
  guiVar <- tktoplevel()
  tktitle(guiVar) <- sprintf ("Available Variables")
  topMenu <- tkmenu(guiVar)           # Create a menu
  tkconfigure(guiVar, menu = topMenu) # Add it to the 'guiVar' window
  #txt <- tktext(guiVar)       # Create a text widget
  #tkgrid(txt)             #
  fileMenu <- tkmenu(topMenu, tearoff = FALSE)
  allMenu <- tkmenu (topMenu, tearoff=FALSE)
  noneMenu <- tkmenu (topMenu, tearoff=FALSE)
  tkadd(fileMenu, "command", label = "Return Selections and Hide Window", command = function () GoBack())
  tkadd (fileMenu, "command", label = "Select ALL variables", command = function () SelectAll ())
  tkadd (fileMenu, "command", label = "Clear ALL selections", command = function () RemoveAll ())
  tkadd(fileMenu, "command", label = "Quit without saving", command = function() tkdestroy(guiVar))
  tkadd(topMenu, "cascade", label = "Actions", menu = fileMenu)
  myFont <- tkfont.create(family="times",size=7, weight='bold')
  NC <- 16
  for (i in seq(0,length(vn),NC)) {
    for (j in 1:NC) {
      eval(parse(text=sprintf("lbl%d <- tkbutton (guiVar, text=vn[%d], font=myFont, 
                              command=function() varClick(%d))", i+j, i+j, i+j)))
      if (vn[i+j] %in% VarList) {
        vnSel[i+j] <- TRUE
        eval(parse(text=sprintf("tkconfigure (lbl%d, foreground='blue', background='yellow')", i+j)))
      }
    }
    eval (parse (text=sprintf("tkgrid(lbl%d, lbl%d, lbl%d, lbl%d, lbl%d, lbl%d, lbl%d, lbl%d, lbl%d, lbl%d, lbl%d, lbl%d, lbl%d, lbl%d, lbl%d, lbl%d)",
                              i+1, i+2, i+3, i+4, i+5, i+6, i+7, i+8, i+9, i+10, i+11, i+12, i+13, i+14, i+15, i+16)))
  }
  tkfocus(guiVar)
  tkwait.window(guiVar)
  return (VarNames)
}
#  tkbind(lbl1, "<1>", varClick(i+1))


# Project <- "WINTER"
# Flight <- "rf11"
# VarList <- standardVariables ()
# fname = sprintf ("%s%s/%s%s.nc", DataDirectory(), Project, Project, Flight)
# vnames <- setVariableList (fname, VarList)
# ## cat (vnames)

