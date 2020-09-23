/*
 *  The scanner definition for COOL.
 */

/*
 *  Stuff enclosed in %{ %} in the first section is copied verbatim to the
 *  output, so headers and global definitions are placed here to be visible
 * to the code in the file.  Dont remove anything that was here initially
 */
%{
#include <cool-parse.h>
#include <stringtab.h>
#include <utilities.h>
#include <vector>

/* The compiler assumes these identifiers. */
#define yylval cool_yylval
#define yylex  cool_yylex
extern "C" int yylex();

/* Max size of string constants */
#define MAX_STR_CONST 1025
#define YY_NO_UNPUT   /* keep g++ happy */

extern FILE *fin; /* we read from this file */

/* define YY_INPUT so we read from the FILE fin:
 * This change makes it possible to use this scanner in
 * the Cool compiler.
 */
#undef YY_INPUT
#define YY_INPUT(buf,result,max_size) \
	if ( (result = fread( (char*)buf, sizeof(char), max_size, fin)) < 0) \
		YY_FATAL_ERROR( "read() in flex scanner failed");

char string_buf[MAX_STR_CONST]; /* to assemble string constants */
char *string_buf_ptr;

extern int curr_lineno;
extern int verbose_flag;

extern YYSTYPE cool_yylval;

/*
 *  Add Your own definitions here
 */

static int commentCaller;
static int stringCaller;

static std::vector<char> stringArray;

%}

  /*
  * Define names for regular expressions here.
  */

DARROW          =>
CLASS           class
ELSE            else
FI              fi
IF              if
IN              in
INHERITS        inherits
LET             let
LOOP            loop
POOL            pool
THEN            then
WHILE           while
CASE            case
ESAC            esac
OF              of
NEW             new
ISVOID          isvoid
ASSIGN          <-
NOT             not
LE              <=

  /*
  STR_CONST 
  INT_CONST 
  BOOL_CONST
  TYPEID 
  OBJECTID

  ERROR
  LET_STMT
  */

%x COMMENT
%x STRING
%x STRING_ESCAPE

%%

[ \t\f\r\v]  {}

    /*
    \(\*[^(\*\))]*[(\*\))<<EOF>>] {
    for (char *c = yytext; c - yytext != yyleng; ++c) {
        if (*c == '\n') {
            ++curr_lineno;
        } else if (*c == EOF) {
            char *msg = "EOF in commnet";
            cool_yylval.symbol = new Entry(msg, strlen(msg), 0);
            return (ERROR);
        }
    }
    }
    */
    /*
    \(\* {
        while (1) {
            int c = yyinput();
            // cout << (char)c;
            if (c == '*') {
                // find )
                while (1) {
                    c = yyinput();
                    if (c != '*') {
                        if (c == ')') {
                            // end of comment
                            return 1;
                        }
                        // not end of comment
                        break;
                    }
                }
            } else if (c == EOF) {
                char *msg = "EOF in commnet";
                cool_yylval.symbol = new Entry(msg, strlen(msg), 0);
                return (ERROR);
            } else if (c == '\n') {
                ++curr_lineno;
            }
        }
        return 1;
    }
    */
    /*
    [^(\(\*)]\*\) {
    char *msg = "Unmatched *)";
    cool_yylval.symbol = new Entry(msg, strlen(msg), 0);
    return (ERROR);
    }
    */

  /*
    Invalid Characters
  */
[\[\]\'>] {
    cool_yylval.error_msg = yytext;
    return (ERROR);
}
    /*
\[ {
  cool_yylval.error_msg = "[";
  return (ERROR);
}

\] {
  cool_yylval.error_msg = "]";
  return (ERROR);
}

' {
  cool_yylval.error_msg = "\'";
  return (ERROR);
}

> {
  cool_yylval.error_msg = ">";
  return (ERROR);
}
    */

 /*
  *  Nested comments
  */

"(*" {
	commentCaller = INITIAL;
    BEGIN(COMMENT);
}
<COMMENT><<EOF>> {
    BEGIN(commentCaller);
    cool_yylval.error_msg = "EOF in comment";
    return (ERROR);
}
<COMMENT>[^(\*\))] {
    if (yytext[0] == '\n') {
        ++curr_lineno;
    }
}
<COMMENT>"*)" {
    BEGIN(commentCaller);
}
\*\) {
    cool_yylval.error_msg = "Unmatched *)";
    return (ERROR);
}

  /* simple comments */
--.*$ { /*cout << "#single line commnet" << endl;*/ }

 /*
  *  The multiple-character operators.
  */
{DARROW} { return (DARROW); }
{CLASS} { return (CLASS); }
{ELSE} { return (ELSE); }
{FI} { return (FI); }
{IF} { return (IF); }
{IN} { return (IN); }
{INHERITS} { return (INHERITS); }
{LET} { return (LET); }
{LOOP} { return (LOOP); }
{POOL} { return (POOL); }
{THEN} { return (THEN); }
{WHILE} { return (WHILE); }
{CASE} { return (CASE); }
{ESAC} { return (ESAC); }
{OF} { return (OF); }
{NEW} { return (NEW); }
{ISVOID} { return (ISVOID); }
{ASSIGN} { return (ASSIGN); }
{NOT} { return (NOT); }
{LE} { return (LE); }

\n { ++curr_lineno; }

 /*
  * Keywords are case-insensitive except for the values true and false,
  * which must begin with a lower-case letter.
  */

  /*
    Type Identifiers
    begin with a capital letter
  */

t[Rr][Uu][Ee] {
  cool_yylval.boolean = true;
  return (BOOL_CONST);
}

f[Aa][Ll][Ss][Ee] {
  cool_yylval.boolean = false;
  return (BOOL_CONST);
}

SELF_TYPE {
  cool_yylval.symbol = idtable.add_string("SELF_TYPE");
  return (TYPEID);
}

[A-Z_][A-Za-z0-9_]*  {
  cool_yylval.symbol = idtable.add_string(yytext, yyleng);
  return (TYPEID);
}
  /*
    Object Identifiers
    begins with a lower case letter
  */
self {
  cool_yylval.symbol = idtable.add_string(yytext, yyleng);
  return (OBJECTID);
}
[a-z_][A-Za-z0-9_]*  {
  cool_yylval.symbol = idtable.add_string(yytext, yyleng);
  return (OBJECTID);
}


  /* 
  * numbers 
  */
[0-9][0-9]* {
  // cout << "INT_CONST" << endl;
  cool_yylval.symbol = inttable.add_string(yytext, yyleng);
  return (INT_CONST);
}


 /*
  *  String constants (C syntax)
  *  Escape sequence \c is accepted for all characters c. Except for 
  *  \n \t \b \f, the result is c.
  *
  */


\" {
    stringCaller = INITIAL;
    stringArray.clear();
    BEGIN(STRING);
}

<STRING>[^\"\\]*\\ {
    // does not include the last character escape
    // cout << "escape !" << endl;
    stringArray.insert(stringArray.end(), yytext, yytext + yyleng - 1);
    BEGIN(STRING_ESCAPE);
}

<STRING>[^\"\\]*\" {
    // end of line with closing "
    // cout << "  string end !" << endl;
    // push back string
    // does not include the last character \"
    stringArray.insert(stringArray.end(), yytext, yytext + yyleng - 1);
    // setup string table
    cool_yylval.symbol = stringtable.add_string(&stringArray[0], stringArray.size());
    // exit
    BEGIN(stringCaller);
    return (STR_CONST);
}

<STRING>[^\"\\]*$ {
    // push first
    // contains the last character for yytext does not include \n
    stringArray.insert(stringArray.end(), yytext, yytext + yyleng);
    //setup error later
    cool_yylval.error_msg = "Unterminated string constant";
    BEGIN(stringCaller);
    ++curr_lineno;
    return (ERROR);
}

<STRING><<EOF>> {
    cool_yylval.error_msg = "EOF in string constant";
    BEGIN(stringCaller);
    return (ERROR);
}

    /* btnf */

<STRING_ESCAPE>n {
    // cout << "escape \\n !" << endl;
    stringArray.push_back('\n');
    BEGIN(STRING);
}

<STRING_ESCAPE>b {
    stringArray.push_back('\b');
    BEGIN(STRING);
}

<STRING_ESCAPE>t {
    stringArray.push_back('\t');
    BEGIN(STRING);
}

<STRING_ESCAPE>f {
    stringArray.push_back('\f');
    BEGIN(STRING);
}

<STRING_ESCAPE>0 {
    cool_yylval.error_msg = "String contains null character";
    BEGIN(STRING);
    return (ERROR);
}

<STRING_ESCAPE>\n {
    stringArray.push_back('\n');
    ++curr_lineno;
    BEGIN(STRING);
}

<STRING_ESCAPE><<EOF>> {
    cool_yylval.error_msg = "EOF in string constant";
    BEGIN(STRING);
    return (ERROR);
}

<STRING_ESCAPE>. {
    stringArray.push_back(yytext[0]);
    BEGIN(STRING);
}


    /*
\"[^\"]*\" {
    // must get rid of surrounding "
    char *begin = yytext + 1;
    int length = yyleng - 2;
    // count slashes
    int slashCount = 0;
    for (char *pc = begin; pc - begin != length; ++pc) {
        if (*pc == '\\') {
            ++slashCount;
        }
    }
    if (length - slashCount >= MAX_STR_CONST) {
        cool_yylval.error_msg = "String constant too long";
        return (ERROR);
    }
    char *content = new char [length - slashCount];
    int index = 0;

    for (char *pc = begin; pc - begin != length; ++pc) {
        if (*pc == '\\') {
            ++pc;
            switch(*pc) {
                case '0':
                    cool_yylval.error_msg = "String contains null character";
                    delete []content;
                    return (ERROR);
                case '\n':
                    ++curr_lineno;
                    break;
                case 'b':
                    content[index] = '\b';
                    break;
                case 't':
                    content[index] = '\t';
                    break;
                case 'n':
                    content[index] = '\n';
                    break;
                case 'f':
                    content[index] = '\f';
                    break;
                default:
                    cool_yylval.error_msg = "String contains invalid \\ character";
                    delete []content;
                    return (ERROR);
            }
        } else if (*pc == '\n') {
            cool_yylval.error_msg = "Unterminated string constant";
            delete []content;
            return (ERROR);
        } else {
            content[index] = *pc;
        }
        ++index;
    }
    cool_yylval.symbol = new Entry(content, length - slashCount, 0);
    delete []content;
    return (STR_CONST);
}
    */


. {
    return yytext[0];
}

%%
