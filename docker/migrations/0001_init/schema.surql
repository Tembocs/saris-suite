################################################################################
#  ▒▒  Course-specific databases: CMT / OPT / PST                             ▒▒
################################################################################
USE NS college;

DEFINE DATABASE cmt;
DEFINE DATABASE opt;
DEFINE DATABASE pst;

LET $common_schema = "
    ------------------------------------------------------------------------
    -- TABLES (strict)                                                     --
    ------------------------------------------------------------------------
    DEFINE TABLE student SCHEMAFULL;
    DEFINE TABLE module  SCHEMAFULL;

    ------------------------------------------------------------------------
    -- STUDENT FIELDS                                                      --
    ------------------------------------------------------------------------
    DEFINE FIELD id           ON student TYPE string VALUE \\$id;

    DEFINE FIELD registration ON student TYPE string
        ASSERT string::matches(\\$value,
          '^[A-Z]{2,3}[0-9]{4}/[0-9]{4}/[0-9]{4}$');

    DEFINE FIELD intake       ON student TYPE string
        ASSERT \\$value =~ /^20[0-9]{2}-20[0-9]{2}\$/;

    DEFINE FIELD course       ON student TYPE string
        ASSERT \\$value IN ['CMT','OPT','PST'];

    DEFINE FIELD level        ON student TYPE int
        ASSERT \\$value IN [4,5,6];

    DEFINE FIELD semester     ON student TYPE int
        ASSERT \\$value IN [1,2];               -- ⬅︎ ONLY Sem 1 or Sem 2

    DEFINE FIELD status       ON student TYPE string
        ASSERT \\$value IN ['first','repeat'];

    DEFINE INDEX uniq_reg     ON TABLE student COLUMNS registration UNIQUE;

    ------------------------------------------------------------------------
    -- MODULE FIELDS                                                       --
    ------------------------------------------------------------------------
    DEFINE FIELD code     ON module TYPE string VALUE \\$value.uppercase();
    DEFINE FIELD name     ON module TYPE string VALUE \\$value.uppercase();
    DEFINE FIELD credits  ON module TYPE int
        ASSERT \\$value >= 1 && \\$value <= 25;
    DEFINE FIELD semester ON module TYPE int
        ASSERT \\$value IN [1,2];               -- ⬅︎ match student constraint
    DEFINE FIELD tutor    ON module TYPE record(staff);
";


-------------------------------------------------------------------------------
-- Apply schema to each course database                                       --
-------------------------------------------------------------------------------
USE DB cmt; EXECUTE $common_schema;
USE DB opt; EXECUTE $common_schema;
USE DB pst; EXECUTE $common_schema;

################################################################################
#  ▒▒  Shared staff database                                                   ▒▒
################################################################################
USE DB staff;

DEFINE TABLE staff SCHEMAFULL;

DEFINE FIELD id        ON staff TYPE string VALUE $id;
DEFINE FIELD fullname  ON staff TYPE string ASSERT $value != '';
DEFINE FIELD role      ON staff TYPE string ASSERT $value IN ['tutor','support'];
DEFINE FIELD contract  ON staff TYPE string ASSERT $value IN ['full-time','part-time'];

CREATE staff:admin CONTENT { fullname:'System Admin', role:'support', contract:'full-time' };
