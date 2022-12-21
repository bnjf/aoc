
%{
  #include "y.tab.h"
%}

%%
[0-9]+    { yylval = atoi(yytext); return NUMBER; }
[,\]\[]   { return *yytext; }
\n        { return *yytext; }
.         { printf("unknown: %s\n", yytext); abort(); }
%%

