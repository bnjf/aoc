
%{
  #include <stdio.h>
  extern int yylineno;
  int yylex(void);
  int yyerror(const char *s);
%}

%token NUMBER

%%

file: record { ; }
    | file '\n' record { ; }
record: list '\n' list '\n' { printf("\n[%d] record done\n", yylineno); }
list: '[' list_empty ']' { puts("nil"); }
    | '[' list_items ']' { printf(". "); }
list_empty: /* nada */ ;
list_items: NUMBER ',' list_items { printf("%d ", $1); }
          | list ',' list_items
          | NUMBER { printf("%d ", $1); }
          | list

%%

int yyerror(const char *s) {
  fprintf(stderr, "line %d: %s\n", yylineno, s);
}

int main() {
  return yyparse();
}
