#' New script generation from a template
#'
#' Generates a new script with custom Rmd header from a template, updates it with your titles and current date, and opens it for editing.
#' @name newscript
#' @param filepath full path to file, including file name
#' @param title title for Rmd output
#' @keywords file open template
#' @export
#' @examples
#' newscript(paste0(mypath, 'newfxn.R'),'Auto-generated R script')

newscript <- function(filepath,title) {
  
  temppath <- find.package("libbyr")
  
  file.copy(paste0(temppath,'/templates/tempscript.txt'),filepath)
  
  z <- readLines(filepath)
  z2 <- gsub('XXX',title,z)
  z2 <- gsub('YYY',date(),z2)
  
  writeLines(z2, filepath)
  
  file.edit(filepath)
  
}