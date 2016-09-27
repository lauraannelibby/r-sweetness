# r-sweetness
R code from various projects

## [bootstrap.bic](https://github.com/lauraannelibby/r-sweetness/tree/master/bootstrap.bic)
Bootstrapped model fit comparison on fMRI pattern similarity estimates from anterior hippocampus (Libby, Ragland, and Ranganath, under review).
* Here's the [code](https://github.com/lauraannelibby/r-sweetness/blob/master/bootstrap.bic/bootstrap.R)
* Here's the [pretty output](https://rawgit.com/lauraannelibby/r-sweetness/master/bootstrap.bic/bootstrap.html)

## [libbyr](https://github.com/lauraannelibby/r-sweetness/tree/master/libbyr)
An R package containing helpful custom functions.
* __newscript()__ Opens a new .R script with an Rmd header and some basic initialization parameters (e.g. require packages). Header title is entered manually; date is auto-generated. 
  + Usage:
 ```
    newscript(filepath,title)
    # filepath is the full path to your new .R file 
    # title is what you want the title of your Rmd file to be.
```
  + Example:
 ```
    newscript('mypath/myscript.R','Brand New Script')
 ```
  + Edit the template file like this:
 ```
    temppath <- find.package("libbyr")
    file.edit(paste0(temppath,'/templates/tempscript.txt'))
 ```
* _More to come?_
