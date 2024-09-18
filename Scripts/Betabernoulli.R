# Simple script for Bayes Classification 
library(RMySQL)


# Proof of concept Beta Bernoulli function
# Reads in and classifies the supplied dataset

# Parameters:
# tokenize_res:   Result from Tokenize_DB
# alpha, beta:    Parameters of the beta distribution
# user, password: MySQL login
# dbname:         The Mysql database in which the ISATab data is stored
#                (according to the defined DB model)
# filename:       Storage name for the RData object (will be stored in ./Results/BetaBern_[filename].RData)
# w:              Weights w_j unity value
# ptags:          Should only one certain tag be classified? If yes, name the tag
# ptype:          If ptags is set, name the protocol type of that tag

# Returns: No value, but saves results in ./Results/BetaBern_[filename].RData
# Results are:
# SCORES: All scores of all documents of both classifiers of all runs
# trainingIndices: list of length 50 (number of runs)
# contains indices of training docs for each run
# Classes: Contains classes of all documents regarding each tag
# topTenWordsTRUE: Contains ten most-occurring words for each tag for each run for the positive Class
# topTenWordsFALSE: Contains ten least-occurring words for each tag for each run for the negative Class

BetaBernoulli <- function(tokenize_res, alpha = 0.01, beta = 0.1, user, password, dbname, filename, w=1, ptags=NA, ptype=NA){
    
    con <- dbConnect(RMySQL::MySQL(), user=user, password=password, dbname = dbname)
    countrs <- dbSendQuery(con, "SELECT count(*) FROM has_tag")
    count <- dbFetch(countrs)
    rs <- dbSendQuery(con, "SELECT * FROM has_tag")
    tags <- dbFetch(rs, n=count[1,1])
    dbClearResult(countrs)
    dbClearResult(rs)
    dbDisconnect(con)
    
    tags <- split(tags,toupper(tags[,1]))
    
    typelist <-  toupper(c("Sample Collection", "Extraction", "Chromatography", "Mass spectrometry", "Metabolite Identification"))

    for(type in typelist){
        if(!all(tags[[type]][,2] %in% tokenize_res$tokens[[type]][,2])){
            tags[[type]] <- tags[[type]][-which(!(tags[[type]][,2] %in% tokenize_res$tokens[[type]][,2])),]
        }
    }
    
    
    if(!is.na(ptype)){
        typelist <- toupper(ptype)
    }
    
    tags <- lapply(tags, function(x){
        TABLE <- table(x[,3])
        n <- nrow(unique(x[,1:2]))
        removal <- names(which((TABLE/n) < 0.05))
        return(x[-which(x$Tag_Label %in% removal),])
    })
    
    SCORES <- list()
    Classes <- list()
    trainingIndices <- list()
    topTenWordsTRUE <- list()
    topTenWordsFALSE <- list()
    MCVratio <- 0.75
    
     # For each protocol type
    for(type in typelist){
        currentTokens <- tokenize_res$tokens[[type]]
       
        currentTokens[,-c(1,2)] <- t(apply(currentTokens[,-c(1,2)],1,function(row){ 
            row[which(row > 1)] <- 1
            return(row)
        }))
        currentTags <- tags[[type]]
        currentProtocols <- currentTokens[,2]
        SCORES[[type]] <- list()
        Classes[[type]] <- list()
        trainingIndices[[type]] <- list()
        topTenWordsTRUE[[type]] <- list()
        topTenWordsFALSE[[type]] <- list()
        taglist <- unique(currentTags[,3])
        if(!is.na(ptags)){
            taglist <- ptags
        }
        # Go through all tags for every protocol type
        for(tag in taglist){
            print(tag)
            SCORES[[type]][[tag]] <- list()
            trainingIndices[[type]][[tag]] <- list()
            topTenWordsTRUE[[type]][[tag]] <- list()
            topTenWordsFALSE[[type]][[tag]] <- list()
            # Get all protocols with the current tag
            protocolsWithTag <- currentTags[which(currentTags[,3] == tag),2]
            n <- nrow(currentTokens)
            # Get tag classes for documents
            Classes[[type]][[tag]] <- rep(FALSE,n)
            Classes[[type]][[tag]][which(currentTokens[,2] %in% protocolsWithTag)] <- TRUE
            ClassRatio <- length(which(Classes[[type]][[tag]]))/n
            # Monte Carlo CV runs
            for(run in 1:30){
                if(!(run %% 10)){
                    print(run)
                }
                # Training Dataset indices (randomly sampled from all except one)
                trainingIndices[[type]][[tag]][[run]] <- c(sample(which(Classes[[type]][[tag]]),MCVratio*n*ClassRatio),sample(which(!Classes[[type]][[tag]]),MCVratio*n*(1-ClassRatio)))
                nTest <- length(Classes[[type]][[tag]][-trainingIndices[[type]][[tag]][[run]]])
                nTraining <- length(Classes[[type]][[tag]][trainingIndices[[type]][[tag]][[run]]])
                
                
                # Get document tokens as a data frame
                tokenDataFrame <- data.matrix(currentTokens[,-c(1,2)])
                
                # Estimate parameters, first: Count occurrences in classes for every word
                mvk <- lapply(c(TRUE,FALSE),function(x) {
                    apply(tokenDataFrame[trainingIndices[[type]][[tag]][[run]],][which(Classes[[type]][[tag]][trainingIndices[[type]][[tag]][[run]]] == x),,drop=FALSE],2,sum)
                })
                topTenWordsTRUE[[type]][[tag]][[run]]  <-  sort(mvk[[1]], TRUE)[1:10]
                topTenWordsFALSE[[type]][[tag]][[run]] <-  sort(mvk[[2]], TRUE)[1:10]
                names(mvk) <- c("TRUE","FALSE")
                
                # Get total number of documents for every class
                Nk <- table(factor(Classes[[type]][[tag]][trainingIndices[[type]][[tag]][[run]]]))
                
                # Estimate the parameters, add a "word count" of 0.1 to every word,
                # because we don't have a very big number of training data points and there will almost certainly be words
                # in the test data which are not in the training data (hence beta-bernoulli)
                muvk <- lapply(names(mvk),function(i) (mvk[[i]] + alpha)/(Nk[i] + alpha + beta))
                names(muvk) <- c("TRUE","FALSE")
                
                # Calculate scores
                # The evidence P(d) is a constant
                # So in this case P(c|d) is proportional to P(d|c)
                # This not a probability calculation and only valid
                # for classification purposes!
                SCORES[[type]][[tag]][[run]] <- apply(tokenDataFrame,1,function(row){
                                products <- lapply(names(muvk),function(mu){ 
                                    c(Nk[mu]/sum(Nk),muvk[[mu]][which(row != 0)]^w,(1-muvk[[mu]][which(row == 0)])^w)
                                })
                                
                                return(sapply(products, function(product){
                                    sum(log(product))
                                }))
                })
            }
        }
        names(SCORES[[type]]) <- taglist
    }
    save(list=c("SCORES","trainingIndices","Classes","topTenWordsTRUE","topTenWordsFALSE"), file=paste0("./Results/BetaBern_",filename,".RData"))
}

# pdf(paste0("Results/MC_Tokenizer_",type,".pdf"))
# dev.off()

#source("Classification/Betabagging.R")

# for(type in toupper(c("Sample Collection", "Extraction", "Chromatography", "Mass spectrometry", "Metabolite Identification"))){
#     currentTags <- names(Classes[[type]])
#     for(tag in currentTags){
#         
#     }
#     dev.off()
# }
