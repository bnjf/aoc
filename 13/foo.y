
%{
  #include <stdio.h>
  extern int yylineno;
  int yylex(void);
  int yyerror(const char *s);
%}

%token NUMBER
%debug

%%

file: record { ; }
    | file '\n' record { ; }
record: record_left record_right { printf("[%d] record done\n\n", yylineno / 3); }
record_left: list '\n' { puts("record_left"); }
record_right: list '\n' { puts("record_right"); }

list: '[' list_head ']';
list_head: /* empty */
         | list_tail;
list_tail: list_items
         | list_tail ',' list_items;
list_items: NUMBER {printf("%d ", $1);}
          | list;

/* alist: '[' list_head list_tail ']' */
/* list_head: | list | NUMBER ; */
/* list_tail: | ',' list_tail | ',' list | ',' NUMBER ; */

/* list: '[' list_empty ']' { printf("nil. "); } */
/*     | '[' list_items ']' { printf(". "); } */
/* list_empty: /1* nada *1/ ; */
/* list_items: list_items ',' list */
/*             | list_items ',' NUMBER { printf("%d ", $3); } */
/*             | list */
/*             | NUMBER { printf("%d ", $1); } */
/*             ; */
%%

int yyerror(const char *s) {
  fprintf(stderr, "line %d: %s\n", yylineno, s);
}

int main() {
  //yydebug=1;
  return yyparse();
}
