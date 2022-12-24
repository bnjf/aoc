
%{
  #include <stdio.h>
  #include <stdlib.h>
  extern int yylineno;
  int yylex(void);
  int yyerror(const char *s);

  enum { ENTER = -1, LEAVE = -2 };
  static int a[1000], b[1000];
  static int *p;
  static int q1();
  static int pair;
%}

%token NUMBER

%%

file        : file '\n' rec | rec ;
rec         : rec_l rec_r ;
rec_l       : list '\n' { p = b; } ;
rec_r       : list '\n' { printf("%d %d\n", pair++, q1(a, b)); p = a; } ;
list        : list_begin list_body list_end ;
list_begin  : '[' { $$ = *p++ = ENTER; } ;
list_end    : ']' { $$ = *p++ = LEAVE; } ;
list_body   : list_tail | /* empty */ ;
list_tail   : list_tail ',' list_items | list_items ;
list_items  : list | NUMBER { *p++ = $1; } ;

%%

int q1(int *pa, int *pb) {
  if (*pa >= 0 && *pb >= 0) {
    int tmp = *pa - *pb;
    if (tmp == 0) { return q1(++pa, ++pb); }
    return tmp;
  }
  if (*pa == ENTER && *pb == ENTER) { return q1(++pa, ++pb); }

  /* if (*pa == LEAVE && *pb == LEAVE) { return 0; } */
  /* if (*pb == LEAVE) { return 1; } */
  /* if (*pa == LEAVE) { return 0; } */
  if (*pa == LEAVE || *pb == LEAVE) { return *pa - *pb; }

  int tmp[] = {ENTER, 0, LEAVE};
  if (*pb == ENTER) {
    tmp[1] = *pa; pa = tmp;
  } else if (*pa == ENTER) {
    tmp[1] = *pb; pb = tmp;
  } else {
    abort();
  }
  return q1(pa, pb);
  /* if (*pb == ENTER) { int tmp[] = {ENTER, *pa, LEAVE}; return q1(tmp, pb); } */
  /* if (*pa == ENTER) { int tmp[] = {ENTER, *pb, LEAVE}; return q1(pa, tmp); } */
  /* abort(); */
}

int yyerror(const char *s) { return fprintf(stderr, "line %d: %s\n", yylineno, s); }

int main() {
  //yydebug=1;
  p = a;
  pair = 1;
  return yyparse();
}
