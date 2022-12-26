
%{
  #include <limits.h>
  #include <stdio.h>
  #include <stdlib.h>

  extern int yylineno;
  int yylex(void);
  int yyerror(const char *s);

  static int a[1000], b[1000];
  static int *p, *pa, *pb;
  static int *stack[1000], **sp;
  static int pair;
  static int q1();
%}

%token NUMBER

%%

file        : file '\n' rec | rec
rec         : rec_l rec_r
rec_l       : list '\n'
  { *p = ~INT_MAX; sp = stack; p = b; }
rec_r       : list '\n'
  { *p = ~INT_MAX; printf("%d %d\n", pair++, q1()); sp = stack; p = a; }
list        : list_begin list_body list_end
list_begin  : '['
  { *sp++ = p++; }
list_end    : ']'
  { sp--; **sp = *sp - p; }
list_body   : list_tail | /* empty */
list_tail   : list_tail ',' list_items | list_items
list_items  : list | NUMBER
  { *p++ = $1; }

%%

static int q1_step() {
  int result, flag;

  if (*pa >= -1 && *pb >= -1)
    return *pa++ - *pb++;

  if ((result = -(*pa == ~INT_MAX)) || (result = (*pb == ~INT_MAX)))
    return result;

  if (*pa < -1 && *pb < -1) {
    pa++;
    pb++;
    return 0;
  }

  flag = *pa < -1;
  pa += flag;
  pb += !flag;
  return ((result = q1_step()) == 0) ? -1 + flag * 2 : result;
}

static int q1() {
  int result;
  pa = a;
  pb = b;
  while ((result = q1_step()) == 0)
    ;
  return result;
}

int yyerror(const char *s) {
  return fprintf(stderr, "line %d: %s\n", yylineno, s);
}

int main() {
  p = a;
  sp = stack;
  pair = 1;
  return yyparse();
}
