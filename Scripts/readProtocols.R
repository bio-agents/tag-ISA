# Get files and file names
fileList <- list.files("public",recursive = TRUE,full.names = TRUE)
investigationFiles <- grep(x= fileList, pattern="^.*MTBLS[[:digit:]]+/i_Investigation.txt", value = TRUE)

# Generate empty tables
ISATabAccessions <- matrix(nrow=0,ncol=1)
studyTable <- matrix(nrow=0,ncol=2)
protocolTable <- matrix(nrow=0,ncol=3)
protocolTokenTable <- matrix(nrow=0,ncol=4)
keywordTable <- matrix(nrow=0,ncol=3)

# Iterate over all files
for(iFile in investigationFiles){
    
    # Extract file contents
    fileConn <- file(iFile)
    iFileContent <- readLines(fileConn)
    close(fileConn)
    
    # Get ISATab Accession
    ISATabID <- strsplit(grep("Study Identifier",iFileContent, value = TRUE),split="\t")[[1]][2]
    
    # Get protocol table contents
    protocolNames <- strsplit(grep("Study Protocol Name", iFileContent, value = TRUE),split = "\t")[[1]][-1]
    Keywords <- strsplit(grep("Study Design Type", iFileContent, value = TRUE),split = "\t")[[1]][-1]
    
    pDescriptionLine <- grep("Study Protocol Description", iFileContent)
    pDescriptionURILine <- grep("Study Protocol URI", iFileContent)
    protocolDescriptions <- strsplit(paste(iFileContent[pDescriptionLine:(pDescriptionURILine-1)], collapse=""), split = "\t")[[1]][-1]
    
    # Get keyword table contents
    #keyword <- strsplit(grep("Study Factor Type\t", iFileContent, value=TRUE), split = "\t")[[1]][-1]
    
    # Get protocol tokens
    #strsplit()
    
    # Extend the tables
    ISATabAccessions <- c(ISATabAccessions, ISATabID)
    studyTable <- rbind(studyTable,c(ISATabID,ISATabID))
    protocolTable <- rbind(protocolTable,cbind(protocolNames,protocolDescriptions,ISATabID))
    keywordTable <- rbind(keywordTable,cbind(Keywords, "", ISATabID))
    
}

# Remove leading and trailing quotes
ISATabAccessions <- gsub("^\"", "", ISATabAccessions)
ISATabAccessions <- gsub("\"$", "", ISATabAccessions)
studyTable <- gsub("^\"", "", studyTable)
studyTable <- gsub("\"$", "", studyTable)
protocolTable <- gsub("^\"", "", protocolTable)
protocolTable <- gsub("\"$", "", protocolTable)
keywordTable <- gsub("^\"", "", protocolTable)
keywordlTable <- gsub("\"$", "", protocolTable)

# Write tables to .csv files
write.table(ISATabAccessions, file = "./MYSQLData/ISA_Tab.csv", col.names = FALSE, row.names = FALSE, qmethod="double")
write.table(studyTable, file = "./MYSQLData/Study.csv", col.names = FALSE, row.names = FALSE, sep = ",", qmethod="double")
write.table(protocolTable, file = "./MYSQLData/Protocol.csv", col.names = FALSE, row.names = FALSE, sep = ",", qmethod="double")
write.table(keywordTable, file = "./MYSQLData/Keyword.csv", col.names = FALSE, row.names = FALSE, sep = ",", qmethod="double")
