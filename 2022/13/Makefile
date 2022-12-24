
LDFLAGS=-ll
CFLAGS?=-Wall -Wno-unused-function -O

all: q1
.PHONY: all

clean:
	@rm -f q1 q1.o q1.h lex.yy.c y.tab.c y.tab.h q1.c

q1: q1.l q1.y
	$(LEX) q1.l
	$(YACC) -d q1.y
	$(CC) $(CFLAGS) lex.yy.c y.tab.c -ll -o $@

