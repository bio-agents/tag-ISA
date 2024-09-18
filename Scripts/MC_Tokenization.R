library(tm)
library(RMySQL)

# Function that tokenizes all protocols from the
# database according to the DB model

# Parameters:
# user, password: MySQL login
# dbname:         The Mysql database in which the ISATab data is stored
#                (according to the defined DB model)
# ctrl: tokenization parameter list according to tm::termFreq
# rmduplicates: Should duplicate protocols be removed from the dataset?

# Returns:
# List with two elements:
# vocabulary contains the vocabulary
# tokens contains the token matrix

Tokenize_DB <- function(user, password, dbname, ctrl = list(removePunctuation = TRUE,
                                                            stopwords = TRUE), rmduplicates=FALSE){
    
    # Connect to mysql db and retrieve protocols
    con <- dbConnect(RMySQL::MySQL(), user=user, password=password, dbname = dbname)
    countrs <- dbSendQuery(con, "SELECT count(*) FROM Protocol")
    count <- dbFetch(countrs)
    rs <- dbSendQuery(con, "SELECT PType,Description,Study_ID FROM Protocol")
    protocolTable <- dbFetch(rs, n=count[1,1])
    dbClearResult(countrs)
    dbClearResult(rs)
    dbDisconnect(con)
    
    # Remove protocols without description and with classes that only turn up rarely
    types <- c("Sample collection", "Extraction", "Chromatography", "Mass spectrometry", "Metabolite identification")
    protocolTable <- protocolTable[which(protocolTable[,2]!=""),]
    protocolTable <- protocolTable[which(protocolTable[,2]!="N/A"),]
    protocolTable <- protocolTable[which(toupper(protocolTable[,1]) %in% toupper(types)),]
    
    if(rmduplicates){
        rmindex <- vector()
        for(i in 1:nrow(protocolTable)){
            if(i %in% rmindex){
                print(i)
                next;
            }
            
            if(any(protocolTable[-c(i,rmindex),2] == protocolTable[i,2])){
                rmindex <- c(rmindex,i)
            }
        }
        protocolTable <- protocolTable[-rmindex,]
    }
    
    # Protocol types and IDs
    typeNames <- as.character(protocolTable[,1])
    protocols <- as.character(protocolTable[,2])
    IDs <- as.character(protocolTable[,3])
    
    #Split by protocol type
    splitNames <- split(typeNames,toupper(typeNames))
    splitProtocols  <- split(protocols,toupper(typeNames))
    splitIDs <- split(IDs,toupper(typeNames))
    
    # Tokenize every protocol type using the MC_tokenizer from package "tm"
    # And find vocabulary for every protocol type
    tokens <- list()
    vocabulary <- list()
    
    for(type in toupper(types)){
        
        # Generate DTM
        currentDTM <- DocumentTermMatrix(Corpus(VectorSource(splitProtocols[[type]])), control = ctrl)
        
        # Write vocabulary for every protocol type
        vocabulary[[type]] <- currentDTM$dimnames$Terms
        
        # Get token table
        trash <- capture.output(tokens[[type]] <- as.data.frame(cbind(splitNames[[type]],splitIDs[[type]],inspect(currentDTM))))
    }
    return(list(vocabulary=vocabulary, tokens=tokens))
}













