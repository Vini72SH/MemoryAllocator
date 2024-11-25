# Definições de Compilação e Ligação
AS = as
GCC = gcc 
LD = ld
LD_FLAGS = -dynamic-linker /lib/x86_64-linux-gnu/ld-linux-x86-64.so.2 /usr/lib/x86_64-linux-gnu/crt1.o /usr/lib/x86_64-linux-gnu/crti.o /usr/lib/x86_64-linux-gnu/crtn.o -lc
DEBUG = -g

.PHONY: all

all: exec

exec: 
	$(GCC) -c exemplo.c $(DEBUG) 
	$(AS) -o meuAlocador.o meuAlocador.s $(DEBUG)
	$(LD) exemplo.o meuAlocador.o -o MeuAlocador $(LD_FLAGS) $(DEBUG)

clean:
	rm -f *.o

purge:
	rm -f *.o MeuAlocador