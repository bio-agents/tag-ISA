# TagISA

version 0.4.0

# Requirements:
* MySQL
* R
* ftp mirror of metabolights

1. Load the .csv files from the MYSQLData folder into the MYSQL database
    For this purpose, the script "loader.sql" shows an example script where the paths
    can be changed to fit the local structure
2. Please note: The associative entities are not in the diagram (Barker Notation).
    The .DDL File contains the full model and the .dmd is also viewable in Oracle SQL Developer Data Modeler
3. Now the R functions "BetaBernoulli", "Tokenize_DB" and "ProcessBetaBern" are usable if all MySQL parameters are supplied
   and work as commentated in those files
   
Please note that this is built in the context of reasearch and therefore 
building the classifiers and the classification itself are not separated steps


Addendum 1:
The previous results folders is available on
https://www.dropbox.com/s/pc8pb4z2c3chgwu/Results.zip?dl=0

Addendum 2:
To set up with new Metabolights Data, download Metabolights mirror
Minimal example with lftp (only investigation files, downloads to current directory):

```
lftp -c mirror --no-empty-dirs --include="/[i]_.*\.[tc][xs][tv]$" ftp://ftp.ebi.ac.uk/pub/databases/metabolights/studies/public/
```

The Data should be stored in [local directory]/public
Now run "readProtocols.R" from the local directory, which should put the newly created

* ISA_TAB.csv
* Study.csv
* Protocol.csv
* Keyword.csv

into [local_directory]/MYSQLData

The tags for any additional protocols must be added to the "has_tag" table! 
Otherwise classification results will not be representative.