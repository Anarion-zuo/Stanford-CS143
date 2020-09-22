multicharList = [
"DARROW",
"CLASS",
"ELSE",
"FI",
"IF",
"IN",
"INHERITS",
"LET",
"LOOP",
"POOL",
"THEN",
"WHILE",
"CASE",
"ESAC",
"OF",
"NEW",
"ISVOID",
"ASSIGN",
"NOT",
"LE",
]

for sym in multicharList:
    print("{%s} { return (%s); }" % (sym, sym))
