CREATE TABLE `ISA_Tab` (
        Accession               VARCHAR(10) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL
    );
ALTER TABLE `ISA_Tab` ADD CONSTRAINT `ISA_Tab_PK` PRIMARY KEY (Accession);

CREATE TABLE Study
  (
    ID                          VARCHAR(10) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL ,
    `ISA_Tab_Accession`         VARCHAR(10) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL
  ) ;
ALTER TABLE Study ADD CONSTRAINT Study_PK PRIMARY KEY (ID) ;

CREATE TABLE Keyword
  (
    Label                       VARCHAR(100) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL ,
    Text                        TEXT CHARACTER SET utf8 COLLATE utf8_bin
  );
ALTER TABLE Keyword ADD CONSTRAINT Keyword_PK PRIMARY KEY (Label);


CREATE TABLE Protocol
  (
    PType                       VARCHAR(100) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL,
    Description                 TEXT CHARACTER SET utf8 COLLATE utf8_bin ,
    Study_ID                    VARCHAR(10) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL
  );
ALTER TABLE Protocol ADD CONSTRAINT Protocol_PK PRIMARY KEY ( PType, Study_ID ) ;


CREATE TABLE Tag
  ( 
    Label                       VARCHAR(100) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL , 
    Text                        TEXT CHARACTER SET utf8 COLLATE utf8_bin NOT NULL
  ) ;
ALTER TABLE Tag ADD CONSTRAINT Tag_PK PRIMARY KEY ( Label ) ;


CREATE TABLE Protocol_Token
  (
    Protocol_PType              VARCHAR(100) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL ,
    Protocol_Study_ID           VARCHAR(10) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL ,
    Word                        VARCHAR(50) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL ,
    Position                    INTEGER NOT NULL NOT NULL
  ) ;
ALTER TABLE Protocol_Token ADD CONSTRAINT Protocol_Token_PK PRIMARY KEY ( Protocol_PType, Protocol_Study_ID, Word, Position) ;


CREATE TABLE Keyword_Tag_Mapping
  (
    Tag_Label                   VARCHAR(100) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL ,
    Keyword_Label               VARCHAR(100) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL ,
    Bernoulli_Probability       FLOAT
  ) ;
ALTER TABLE Keyword_Tag_Mapping ADD CONSTRAINT Keyword_Tag_Mapping_PK PRIMARY KEY ( Tag_Label, Keyword_Label) ;


CREATE TABLE has_keyword
  (
    Keyword_Label               VARCHAR(100) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL ,
    `ISA_Tab_Accession`         VARCHAR(10) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL 
  ) ;
ALTER TABLE has_keyword ADD CONSTRAINT has_keyword_PK PRIMARY KEY ( Keyword_Label, `ISA_Tab_Accession`) ;


CREATE TABLE has_tag
  (
    Protocol_PType    VARCHAR(100) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL ,
    Protocol_Study_ID VARCHAR(10) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL ,
    Tag_Label         VARCHAR(100) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL
  ) ;
ALTER TABLE has_tag ADD CONSTRAINT has_tag_PK PRIMARY KEY ( Protocol_PType, Protocol_Study_ID, Tag_Label ) ;


ALTER TABLE Protocol ADD CONSTRAINT Protocol_Study_FK FOREIGN KEY ( Study_ID ) REFERENCES Study ( ID ) ;

ALTER TABLE Study ADD CONSTRAINT `Study_ISA_Tab_FK` FOREIGN KEY ( `ISA_Tab_Accession` ) REFERENCES `ISA_Tab` ( Accession ) ;

ALTER TABLE Protocol_Token ADD CONSTRAINT Protocol_Token_Protocol_FK FOREIGN KEY ( Protocol_PType, Protocol_Study_ID ) REFERENCES Protocol ( PType, Study_ID ) ;

ALTER TABLE Keyword_Tag_Mapping ADD CONSTRAINT Keyword_Tag_Mapping_Keyword_FK FOREIGN KEY ( Keyword_Label) REFERENCES Keyword ( Label ) ;

ALTER TABLE Keyword_Tag_Mapping ADD CONSTRAINT Keyword_Tag_Mapping_Tag_FK FOREIGN KEY ( Tag_Label) REFERENCES Tag ( Label ) ;

ALTER TABLE has_keyword ADD CONSTRAINT `has_keyword_ISA_Tab_FK` FOREIGN KEY ( `ISA_Tab_Accession`) REFERENCES `ISA_Tab` ( Accession ) ;

ALTER TABLE has_keyword ADD CONSTRAINT `has_keyword_Keyword_FK` FOREIGN KEY ( Keyword_Label) REFERENCES Keyword ( Label ) ;

ALTER TABLE has_tag ADD CONSTRAINT has_tag_Protocol_FK FOREIGN KEY ( Protocol_PType, Protocol_Study_ID ) REFERENCES Protocol ( PType, Study_ID ) ;

ALTER TABLE has_tag ADD CONSTRAINT has_tag_Tag_FK FOREIGN KEY ( Tag_Label ) REFERENCES Tag ( Label ) ;

-- Zusammenfassungsbericht für Oracle SQL Developer Data Modeler: 
-- 
-- CREATE TABLE                             7
-- CREATE INDEX                             0
-- ALTER TABLE                             14
-- CREATE VIEW                              0
-- ALTER VIEW                               0
-- CREATE PACKAGE                           0
-- CREATE PACKAGE BODY                      0
-- CREATE PROCEDURE                         0
-- CREATE FUNCTION                          0
-- CREATE TRIGGER                           0
-- ALTER TRIGGER                            0
-- CREATE COLLECTION TYPE                   0
-- CREATE STRUCTURED TYPE                   0
-- CREATE STRUCTURED TYPE BODY              0
-- CREATE CLUSTER                           0
-- CREATE CONTEXT                           0
-- CREATE DATABASE                          0
-- CREATE DIMENSION                         0
-- CREATE DIRECTORY                         0
-- CREATE DISK GROUP                        0
-- CREATE ROLE                              0
-- CREATE ROLLBACK SEGMENT                  0
-- CREATE SEQUENCE                          0
-- CREATE MATERIALIZED VIEW                 0
-- CREATE SYNONYM                           0
-- CREATE TABLESPACE                        0
-- CREATE USER                              0
-- 
-- DROP TABLESPACE                          0
-- DROP DATABASE                            0
-- 
-- REDACTION POLICY                         0
-- 
-- ORDS DROP SCHEMA                         0
-- ORDS ENABLE SCHEMA                       0
-- ORDS ENABLE OBJECT                       0
-- 
-- ERRORS                                   0
-- WARNINGS                                 0
