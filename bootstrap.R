#' ---
#' title: "CogCon Fit Compare Bootstrap Analyses"
#' author: "Laura Libby"
#' ---

#+ label="Let's go!"
# ***ALWAYS RUN THIS COMMAND FIRST TO SET TYPE III SUMS OF SQUARES***
options(contrasts = c("contr.sum", "contr.poly"))

# input data
datafilename="C:/Users/Laura Libby/Dropbox/CogCon/meansim_ROIs_factors.txt"
#datafilename="~/Dropbox/CogCon/meansim_ROIs.txt"
data=read.table(datafilename,header=T)

# look at data, make sure it's formatted correctly
summary(data)

###' Model comparison stuff for ant hip
hipphead <- subset(data, ROI=="Hipp_Head")
hipphead$ROI <- factor(hipphead$ROI)
require(car)
hipphead$conjunctive <- recode(hipphead$Sort, "'bothdiff'=-1 ; 'consame'=-1 ; 'objconsame'=3 ; 'objsame'=-1"
                               , as.factor.result=FALSE, as.numeric.result=TRUE)
hipphead$additive <- recode(hipphead$Sort, "'bothdiff'=-1 ; 'consame'=0 ; 'objconsame'=1 ; 'objsame'=0",
                            , as.factor.result=FALSE, as.numeric.result=TRUE)
hipphead$conjunctive2 <- recode(hipphead$Sort, "'bothdiff'=0 ; 'consame'=0 ; 'objconsame'=1 ; 'objsame'=0"
                                , as.factor.result=FALSE, as.numeric.result=TRUE)
hipphead$additive2 <- recode(hipphead$Sort, "'bothdiff'=0 ; 'consame'=1 ; 'objconsame'=2 ; 'objsame'=1",
                             , as.factor.result=FALSE, as.numeric.result=TRUE)
summary(hipphead)

require(lme4)
require(boot)
require(bootstrap)
require(gtools)
require(ggplot2)

#' conjunctive coding model
model.conjunctive.hem <- function(x) {
  lmer(Sim ~ conjunctive*Hem + (1|Subj/Hem), REML=FALSE, data=x)
}

#' additive coding model
model.additive.hem <- function(x) {
  lmer(Sim ~ additive*Hem + (1|Subj/Hem), REML=FALSE, data=x)
}

#' compare additive and conjunctive models (lower AIC and BIC is better)
getbic <- function(x) {
  compare <- anova(model.conjunctive.hem(x), model.additive.hem(x))
  return(compare$BIC)
}

#' generate 10000 unique permutations of subjects with replacement
set.seed(1)
N <- t(replicate(15000, sample(levels(hipphead$Subj),replace=TRUE)))
sum(duplicated(N))
order <- N[!(duplicated(N)), ][1:10000, ]
head(order)

#' run through each permutation
#niters=dim(order)[1]
niters=10000 #for troubleshooting
bics<-matrix(nrow=niters,ncol=2)
for (i in 1:niters) {
  #write(i,file="") # Turn off for notebook!
  tempdata<-data.frame()
  for (j in 1:dim(order)[2]) {
    tempdata <- rbind(tempdata, hipphead[hipphead$Subj==order[i,j],])
  }
    bics[i,]<-getbic(tempdata)
}
bics<-as.data.frame(bics)
names(bics)<-c("bic.con","bic.add")

#' reshape and plot density
bics.long <- reshape(bics, varying=c("bic.con","bic.add"), timevar="model", direction="long")
G <- ggplot() + geom_density(data=bics.long, aes(x=bic,y=..count..,fill=model, colour=model) ,alpha=0.5) +
  ggtitle(paste(niters, " iterations", collapse=""))
G

#' look at it with just 1000 permutations (just for fun)
bics.short<-bics[1:1000,]
dim(bics.short)
bics.short.long <-reshape(bics.short, varying=c("bic.con","bic.add"), timevar="model", direction="long")
Gshort <- ggplot() + geom_density(data=bics.short.long, aes(x=bic,y=..count.., fill=model, colour=model), alpha=0.5) + 
  ggtitle("1000 iterations")
Gshort

#' get descriptive stats
summary(bics)

#' calculate 95% confidence interval on the difference in BIC
bic.diff <- bics$bic.con - bics$bic.add
summary(bic.diff)
bic.ci <- c(sort(bic.diff)[niters*.025],sort(bic.diff)[niters*.975])
bic.ci <- as.data.frame(bic.ci)
row.names(bic.ci) <- c("lower","upper")
bic.ci

# #' do it on 1000 permutations (just for fun)
# #' calculate 95% confidence interval on the difference in BIC
# bic.short.diff <- bics.short$bic.con - bics.short$bic.add
# summary(bic.short.diff)
# bic.short.ci <- c(sort(bic.short.diff)[1000*.025],sort(bic.short.diff)[1000*.975])
# bic.short.ci <- as.data.frame(bic.short.ci)
# row.names(bic.short.ci) <- c("lower","upper")
# bic.short.ci

#' what proportion of the permutations have a negative difference???
sum(bic.diff<0)/niters

#' plot BIC difference distribution
Gdiff <- ggplot() + geom_density(aes(x=bic.diff, y=..count..), fill="green", colour="green", alpha=.5) +
  ggtitle("BIC difference (con - add) across models (10,000 iterations)")
Gdiff


