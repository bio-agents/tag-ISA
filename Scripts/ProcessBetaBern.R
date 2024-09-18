# Function that automatically processes
# the results and stores performance measures

# Parameters:
# filename: Storage name for the RData object (that is stored in ./Results/BetaBern_[filename].RData)
# ptype: if the file only contains results from a single tag, supply the protocol type of that tag

# Returns:
# no value, but stores 4 variables with paths
# "./Results/[filename]/BetaBernoulli_[filename]_[X].RData"
# where X is "Sens", "Spec", "Prec", "FMea"
# which stand for "Sensitivity", "Specificity", "Precision" and "F-Measure"
# respectively
# The Variable names are "allSens", "allSpec", "allPrec" and "allFMea"
# and contain their respective average measurements over all documents for all tags and all runs

ProcessBetaBernResults <- function(filename,ptype = NA){

    if(!is.na(ptype)){
        typelist <- ptype
    } else{typelist <-toupper(c("Sample Collection", "Extraction", "Chromatography", "Mass spectrometry", "Metabolite Identification"))}
    allSpec <- list()
    allSens <- list()
    allPrec <- list()
    allFMea <- list()
    
    path <- paste0("./Results/",filename)
    if(!dir.exists(path)){
        dir.create(path)
    }
    load(paste0("./Results/","BetaBern_",filename,".RData"))
    
    pdf(paste0(path,"/BetaBern_",filename,".pdf"))
    # For each protocol type
    for(type in typelist){
        allSpec[[type]] <- list()
        allSens[[type]] <- list()
        allPrec[[type]] <- list()
        allFMea[[type]] <- list()
        for(tag in names(Classes[[type]])){
            currentScore <- list()
            Specifity <- vector()
            Sensitivity <- vector()
            Precision <- vector()
            FMeas <- vector()
            for(run in 1:30){
                currentClasses <- Classes[[type]][[tag]][-trainingIndices[[type]][[tag]][[run]]]
                currentScore[[run]] <- SCORES[[type]][[tag]][[run]][1,-trainingIndices[[type]][[tag]][[run]]]-SCORES[[type]][[tag]][[run]][2,-trainingIndices[[type]][[tag]][[run]]]
                Classification <- rep(FALSE, length(currentScore[[run]]))
                Classification[which(currentScore[[run]] > 0)] <- TRUE
                TP <- length(which(Classification & currentClasses))
                TN <- length(which(!Classification & !currentClasses))
                FP <- length(which(Classification & !currentClasses))
                FN <- length(which(!Classification & currentClasses))
                Sensitivity[run] <- TP/(FN+TP)
                Specifity[run] <- TN/(FP+TN)
                Precision[run] <- TP/(TP+FP)
                if(is.nan(Precision[run])){
                    Precision[run] <- 0
                }
                
                FMeas[run] <- 2*(Sensitivity[run] * Precision[run])/(Sensitivity[run] + Precision[run])
                if(is.nan(FMeas[run])){
                    FMeas[run] <- 0
                }
            }
            allSens[[type]][[tag]] <- Sensitivity
            allSpec[[type]][[tag]] <- Specifity
            allPrec[[type]][[tag]] <- Precision
            allFMea[[type]][[tag]] <- FMeas
        }
        names(allSens[[type]]) <- names(Classes[[type]])
        names(allSpec[[type]]) <- names(Classes[[type]])
        names(allPrec[[type]]) <- names(Classes[[type]])
        names(allFMea[[type]]) <- names(Classes[[type]])
    }
    dev.off()
    if(is.na(ptype)){
        for(type in typelist){
            pdf(paste0(path,"/BetaBernoulli_",filename,"_Sens_",type,".pdf"),width = 30, height = 8)
            par(mar = c(9,4,4,2) + 0.1)
            half <- floor(length(allSens[[type]])/2)
            boxplot(allSens[[type]][1:half],las=2)
            boxplot(allSens[[type]][(half+1):length(allSens[[type]])],las=2)
            dev.off()
        }
        
        for(type in typelist){
            pdf(paste0(path,"/BetaBernoulli_",filename,"_Spec_",type,".pdf"),width = 30, height = 8)
            par(mar = c(9,4,4,2) + 0.1)
            half <- floor(length(allSens[[type]])/2)
            boxplot(allSpec[[type]][1:half],las=2)
            boxplot(allSpec[[type]][(half+1):length(allSens[[type]])],las=2)
            dev.off()
        }
    }
    save(list="allSens", file=paste0(path,"/BetaBernoulli_",filename,"_Sens.RData"))
    save(list="allSpec", file=paste0(path,"/BetaBernoulli_",filename,"_Spec.RData"))
    save(list="allPrec", file=paste0(path,"/BetaBernoulli_",filename,"_Prec.RData"))
    save(list="allFMea", file=paste0(path,"/BetaBernoulli_",filename,"_FMea.RData"))
}