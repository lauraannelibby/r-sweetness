#' ---
#' title: Test File
#' author: "[Laura A Libby](lauraannelibby.github.io)"
#' date: Tue Sep 27 07:57:14 2016
#' output:
#'  html_document:
#'   toc: true
#'   toc_float: true
#' ---
#'
#' _Details:_ 


#' ## Initial setup

#' ### Clean up
rm(list=ls())

#' ### Load necessary packages
#' Data manipulation
suppressMessages(require(plyr))
suppressMessages(require(dplyr))
suppressMessages(require(tidyr))
#' Analysis
suppressMessages(require(stats))
suppressMessages(require(pwr))
suppressMessages(require(effsize))
suppressMessages(require(lme4))
#' Visualization
suppressMessages(require(ggplot2))
