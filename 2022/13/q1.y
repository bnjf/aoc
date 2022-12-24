
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
  static int pair=1;
%}

%token NUMBER
%debug

%%

file: record            { p = a; }
    | file '\n' record  { p = a; }

record: record_left record_right;

record_left: list '\n'  { p = b; }
record_right: list '\n' { printf("%d %d\n", pair++, q1(a, b)); p = a; }

list: list_begin list_body list_end;

list_begin: '['         { $$ = *p++ = ENTER; };
list_end: ']'           { $$ = *p++ = LEAVE; };

list_body: /* empty */
         | list_tail;
list_tail: list_items
         | list_tail ',' list_items;
list_items: NUMBER { *p++ = $1; }
          | list; 
%%

int q1(int *pa, int *pb) {
  if (*pa >= 0 && *pb >= 0) {
    int tmp = *pa - *pb;
    if (tmp == 0) { return q1(++pa, ++pb); }
    else { return tmp; }
  }
  if (*pa == LEAVE && *pb == LEAVE) { return 0; }
  if (*pa == ENTER && *pb == ENTER) { return q1(++pa, ++pb); }
  if (*pb == ENTER) { int tmp[] = {ENTER,*pa,LEAVE}; return q1(tmp, pb); }
  if (*pb == LEAVE) { return 1; }
  if (*pa == LEAVE) { return 0; }
  if (*pa == ENTER) { int tmp[] = {ENTER,*pb,LEAVE}; return q1(pa, tmp); }
  printf("\n%d %d\n", *pa, *pb);
  fflush(stdout);
  abort();
}

int yyerror(const char *s) { return fprintf(stderr, "line %d: %s\n", yylineno, s); }

int main() {
  //yydebug=1;
  p = a;
  return yyparse();
}
