YACC_BIN := $(firstword $(wildcard /opt/homebrew/opt/bison/bin/bison) $(wildcard /usr/local/opt/bison/bin/bison) yacc)

myprog: myprog.y myprog.l
	$(YACC_BIN) -d -y myprog.y
	lex myprog.l
	gcc -o myprog y.tab.c lex.yy.c -ll

clean:
	rm -f myprog y.tab.c y.tab.h lex.yy.c
