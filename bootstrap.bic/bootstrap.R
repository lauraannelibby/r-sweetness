#' ---
#' title: "Model Fit Comparison Bootstrap Analysis"
#' author: "[Laura A Libby](lauraannelibby.github.io)"
#' date: "April 6, 2016"
#' output:
#'  html_document:
#'   toc: true
#'   toc_float: true
#' ---
#' _Project/publication:_ Libby, Ragland, and Ranaganth (Under review). 
#' The hippocampus generalizes across memories that share item and context information.
#'
#' _Details:_ This script compares the fit of additive (linear) versus 
#' conjunctive (threshold) models for item-in-context coding
#' in anterior hippocampus (hippocampal head) using Bayesian 
#' Information  Criterion (BIC). A confidence interval for the difference in 
#' model fit is determined by generating a null distribution using a bootstrap approach.
#' 

#' ## Initialize settings

#' ### **Important:** Set number of iterations
#' Troubleshooting? Set a minimum of 50. Running for real? At least 1000, or even better 10,000.
niters=10000

#' ### Load packages
suppressMessages(require(car))
suppressMessages(require(gtools))
suppressMessages(require(ggplot2))
suppressMessages(require(lme4))

#' ### Input data
datafilename="C:/Users/Laura Libby/Dropbox/CogCon/meansim_ROIs_factors.txt"
data=read.table(datafilename,header=T)

#' ### Make sure data is formatted correctly
summary(data)

#' ## Data manipulation

#' Select only hippocampus head data
hipphead <- subset(data, ROI=="Hipp_Head")
hipphead$ROI <- factor(hipphead$ROI)

#' Create dummy variables for additive and conjunctive coding
hipphead$conjunctive <- recode(hipphead$Sort, "'bothdiff'=-1 ; 'consame'=-1 ; 'objconsame'=3 ; 'objsame'=-1"
                               , as.factor.result=FALSE, as.numeric.result=TRUE)
hipphead$additive <- recode(hipphead$Sort, "'bothdiff'=-1 ; 'consame'=0 ; 'objconsame'=1 ; 'objsame'=0",
                            , as.factor.result=FALSE, as.numeric.result=TRUE)
summary(hipphead)


#' ## Define models 

#' ### Conjunctive coding model
model.conjunctive.hem <- function(x) {
  lmer(Sim ~ conjunctive*Hem + (1|Subj/Hem), REML=FALSE, data=x)
}

#' ### Additive coding model
model.additive.hem <- function(x) {
  lmer(Sim ~ additive*Hem + (1|Subj/Hem), REML=FALSE, data=x)
}

#' ### Define model comparison function 
#' (Note: Lower AIC and BIC is better)
getbic <- function(x) {
  compare <- anova(model.conjunctive.hem(x), model.additive.hem(x))
  return(compare$BIC)
}

#' ## Start iterating

#' ### Generate 10000 unique combinations of subjects with replacement
set.seed(1)
N <- t(replicate(15000, sample(levels(hipphead$Subj),replace=TRUE)))
sum(duplicated(N))
order <- N[!(duplicated(N)), ][1:niters, ]
#' Take a sneak peek at the first 10 "samples"
head(order)

#' ### Initialize output
bics<-matrix(nrow=niters,ncol=2)

#' ### Loop through iterations to generate BIC distributions
#' Hm, probably there are more R-like ways of doing this without for loops...
tictoc <- system.time({
  for (i in 1:niters) {
    #write(i,file="") # Verbose output - Turn off for notebook!
    tempdata<-data.frame()
    for (j in 1:dim(order)[2]) {
      # Generate temporary data for iteration 
      tempdata <- rbind(tempdata, hipphead[hipphead$Subj==order[i,j],])
    }
      # Calculate BICs for temp data
      bics[i,]<-getbic(tempdata)
  }
})
 
#' ### Get elapsed time
#' In seconds.
tictoc[3]

#' ## Results

#' ### Check it out
bics<-as.data.frame(bics)
names(bics)<-c("bic.con","bic.add")
summary(bics)

#' ### Plot BIC distribution for each model
bics.long <- reshape(bics, varying=c("bic.con","bic.add"), timevar="model", direction="long")
G <- ggplot() + geom_density(data=bics.long, aes(x=bic,y=..count..,fill=model, colour=model) ,alpha=0.5) +
  ggtitle(paste0("BIC for con and add models (", niters, " iterations)"))
G

#' ### Calculate the difference in BIC for each iteration
bic.diff <- bics$bic.con - bics$bic.add
summary(bic.diff)

#' ### Plot BIC difference distribution
Gdiff <- ggplot() + geom_density(aes(x=bic.diff, y=..count..), fill="green", colour="green", alpha=.5) +
  ggtitle(paste0("BIC difference (con - add) across models (",niters," iterations)"))
Gdiff

#' ### Calculate 95% confidence interval for BIC difference
bic.ci <- c(sort(bic.diff)[round(niters*.025)],sort(bic.diff)[round(niters*.975)])
bic.ci <- as.data.frame(bic.ci)
row.names(bic.ci) <- c("lower","upper")
bic.ci

#' ### Calculate proportion of permutations with negative BIC difference
sum(bic.diff<0)/niters




