CC=clang
CFLAGS=-g3 -Wall

.PHONY : clean all

all : bminor

bminor : main.o parser.o scanner.o decl.o stmt.o expr.o param_list.o type.o print.o hash_table.o symbol.o scope.o
	${CC} ${CFLAGS} -o $@ $^

main.o : main.c flex.h bison.h
	${CC} -c ${CFLAGS} $< -o $@

%.o : %.c
	${CC} -c ${CFLAGS} $< -o $@

parser.c bison.h &: parser.y
	bison -Wall --debug --header=bison.h --output=parser.c $<

scanner.c flex.h &: scanner.l
	flex --debug --outfile=scanner.c --header-file=flex.h $<

clean :
	rm -f bminor *.o flex.h bison.h scanner.c parser.c parser.output
