########################################
#  Root: pick namespace & create DBs   #
########################################
USE NS college;

DEFINE DATABASE cmt;
DEFINE DATABASE opt;
DEFINE DATABASE pst;

########################################
#  ---- Common schema fragment ----    #
#  We APPLY it three times, once       #
#  for each course-database            #
########################################
LET $schema = "
    -- ---------- TABLES ----------
    DEFINE TABLE student SCHEMAFULL;
    DEFINE TABLE module  SCHEMAFULL;

    -- ---------- STUDENT ----------
    DEFINE FIELD id          ON student TYPE string VALUE \$id;

    DEFINE FIELD registration ON student TYPE string
        ASSERT string::matches(\$value,
          '^[A-Z]{2,3}[0-9]{4}/[0-9]{4}/[0-9]{4}\$');

    DEFINE FIELD intake      ON student TYPE string
        ASSERT \$value =~ /^20[0-9]{2}-20[0-9]{2}\$/;

    DEFINE FIELD course      ON student TYPE string
        ASSERT \$value IN ['CMT','OPT','PST'];

    -- one row per registration number in this DB
    DEFINE INDEX uniq_regno ON TABLE student COLUMNS registration UNIQUE;

    -- ---------- MODULE ----------
    DEFINE FIELD code     ON module TYPE string VALUE \$value.uppercase();
    DEFINE FIELD semester ON module TYPE int
        ASSERT \$value >= 1 AND \$value <= 6;
    DEFINE FIELD tutor    ON module TYPE record(staff);
";


########################################
#  -- Apply fragment to CMT DB --
########################################
USE DB cmt;
EXECUTE $schema;

########################################
#  -- Apply fragment to OPT DB --
########################################
USE DB opt;
EXECUTE $schema;

########################################
#  -- Apply fragment to PST DB --
########################################
USE DB pst;
EXECUTE $schema;

########################################
#  Staff database (one shared DB)     #
########################################
USE DB staff;

DEFINE TABLE staff  SCHEMAFULL;

DEFINE FIELD id        ON staff TYPE string  VALUE $id;
DEFINE FIELD fullname  ON staff TYPE string  ASSERT $value != '';
DEFINE FIELD role      ON staff TYPE string  ASSERT $value IN ['tutor','support'];
DEFINE FIELD contract  ON staff TYPE string  ASSERT $value IN ['full-time','part-time'];

CREATE staff:admin CONTENT { fullname:'System Admin', role:'support', contract:'full-time' };
