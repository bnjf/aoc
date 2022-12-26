
%{
  #include <stdio.h>
  #include <stdlib.h>
  #include <limits.h>

  extern int yylineno;
  int yylex(void);
  int yyerror(const char *s);

  static int a[1000], b[1000];
  static int *p; //, *pa, *pb;
  static int *stack[1000],**sp;
  static int pair;
  static int q1();
%}

%token NUMBER

%%

file        : file '\n' rec | rec ;
rec         : rec_l rec_r ;
rec_l       : list '\n' { *p = ~INT_MAX; sp = stack; p = b; } ;
rec_r       : list '\n' { *p = ~INT_MAX; printf("result: %d %d\n", pair++, q1(a, b)); sp = stack; p = a; } ;
list        : list_begin list_body list_end ;
list_begin  : '[' { *sp++ = p++; } ;
list_end    : ']' { sp--; **sp = *sp - p; } ;
list_body   : list_tail | /* empty */ ;
list_tail   : list_tail ',' list_items | list_items ;
list_items  : list | NUMBER { *p++ = $1; } ;

%%

enum q1_result { LT=-1, EQ=0, GT=1 };

struct {
  int *pa, *pb;
  int **skipa;
  int **skipb;
} s = {.skipa = (int **)&(int *[1000]){}, .skipb = (int **)&(int *[1000]){}};

int q1_step() {
  int result;
  fprintf(stderr, "%d,%d\n", *s.pa, *s.pb);
  if (*s.pb == ~INT_MAX) { return 1; } // rhs empty
  else if (*s.pa == ~INT_MAX) { return -1; } // lhs empty
  else if (*s.pa >= -1 && *s.pb >= -1) {
    return *s.pa++ - *s.pb++;
  }
  else if (*s.pa < -1 && *s.pb < -1) {
    *(s.skipa++) = s.pa - *s.pa;
    *(s.skipb++) = s.pb - *s.pb;
    s.pa++;
    s.pb++;
    return 0;
  }
  else if (*s.pb < -1) {
    // compare atom `a` against list `b`
    *s.skipb++ = s.pb - *s.pb;
    s.pb++;
    if ((result = q1_step()) == 0) {
      fprintf(stderr, "skip: %d,%d -- pb:%lu => %lu\n", 
        *s.pa, *s.pb, 
        s.pb-b, *(s.skipb-1)-b);
      s.pb = *(--s.skipb);
      return -1;
    }
    --s.skipb;
    return result;
  } 
  else if (*s.pa < -1) {
    // compare atom `b` against list `a`
    *s.skipa++ = s.pa - *s.pa;
    s.pa++;
    result = q1_step();
    if (result == 0) {
      s.pa = *(--s.skipa);
      return 1;
    }
    return result;
  } 
  abort();
}

int q1(int *pa, int *pb) {
  s.pa=pa; s.pb=pb;
  int result;
  while ((result=q1_step()) == 0) {
    //fprintf(stderr, "%d,%d\n", *s.pa, *s.pb);
  }
  return result;
}

int yyerror(const char *s) { return fprintf(stderr, "line %d: %s\n", yylineno, s); }

int main() {
  //yydebug=1;
  p = a;
  sp = stack;
  pair = 1;
  return yyparse();
}
