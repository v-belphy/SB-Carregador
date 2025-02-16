.PHONY: all
all: carregador

carregador: carregador.c carregador.asm
	nasm -f elf -g carregador.asm -o carregador.o 
	gcc -m32 -g3 -o carregador carregador.o carregador.c

.PHONY: clean
clean:
	rm *.o carregador
