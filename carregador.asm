SECTION .data

MSG_NAO_CABE db "O programa nao cabe em memoria."
MSG_NAO_CABE_SIZE EQU $-MSG_NAO_CABE
MSG_CABE db "O programa cabe na memoria e está localizado no:"
MSG_CABE_SIZE EQU $-MSG_CABE
MSG_BLOCO db 0xA, "Bloco "
MSG_BLOCO_SIZE EQU $-MSG_BLOCO
MSG_ENDERECO_INICIAL db ": endereço inicial = "
MSG_ENDERECO_INICIAL_SIZE EQU $-MSG_ENDERECO_INICIAL
MSG_ENDERECO_FINAL db " | endereco final = "
MSG_ENDERECO_FINAL_SIZE EQU $-MSG_ENDERECO_FINAL
MSG_ENDL db 0xA

SECTION .bss

BLOCO_IDX resb 4
ENDERECO_INICIAL resb 4
ENDERECO_FINAL resb 4
BLOCO_IDX_STR resb 10
ENDERECO_INICIAL_STR resb 10
ENDERECO_FINAL_STR resb 10
TAMANHO_DA_MSG resb 4

SECTION .text

%define PROG_SIZE DWORD [EBP+8]

%define B1_START DWORD [EBP+12]
%define B1_SIZE DWORD [EBP+16]

%define B2_START DWORD [EBP+20]
%define B2_SIZE DWORD [EBP+24]

%define B3_START DWORD [EBP+28]
%define B3_SIZE DWORD [EBP+32]

%define B4_START DWORD [EBP+36]
%define B4_SIZE DWORD [EBP+40]

GLOBAL carrega

carrega:
push EBP
mov EBP, ESP

;CASO 1) Programa nao cabe na memoria
mov EAX, B1_SIZE
add EAX, B2_SIZE
add EAX, B3_SIZE
add EAX, B4_SIZE
cmp PROG_SIZE, EAX
jg nao_cabe

;CASO 2) Programa cabe inteiramente em algum bloco
push MSG_CABE_SIZE
push MSG_CABE
call print_string

mov ECX, 0 ;index
loop_1:
mov EBX, EBP 
add EBX, 12 ;base endereco
mov EDX, EBP
add EDX, 16 ;base tamanho
mov EAX, PROG_SIZE
cmp [EDX + ECX * 8], EAX
jge cabe
inc ECX
cmp ECX, 4
jl loop_1

;CASO 3) Programa cabe divido em blocos
mov ECX, 0 ;index
loop_2:
mov EBX, EBP 
add EBX, 12 ;base endereco
mov EDX, EBP
add EDX, 16 ;base tamanho
jmp cabe
CONTINUA_LOOP:
inc ECX
cmp ECX, 4
jl loop_2

jmp carrega_fim

;Coloca o programa no bloco, setando os resultados: BLOCO_IDX, ENDERECO_INICIAL e ENDERECO_FINAL
cabe:
mov [BLOCO_IDX], ECX
inc DWORD [BLOCO_IDX]
mov EAX, [EBX + ECX * 8]
mov [ENDERECO_INICIAL], EAX
mov EAX, [ENDERECO_INICIAL]
mov [ENDERECO_FINAL], EAX
mov EAX, [EDX + ECX * 8] 
cmp EAX, PROG_SIZE
jl auxiliar
mov EAX, PROG_SIZE
auxiliar:
add [ENDERECO_FINAL], EAX
dec DWORD [ENDERECO_FINAL]

;chama a funcao que converte int para string e depois chama a funcao para printar o resultado e MSG correspondente
push DWORD [BLOCO_IDX]
push BLOCO_IDX_STR
call int_to_string
push DWORD MSG_BLOCO_SIZE
push MSG_BLOCO
call print_string
push DWORD [TAMANHO_DA_MSG]
push BLOCO_IDX_STR
call print_string

push DWORD [ENDERECO_INICIAL]
push ENDERECO_INICIAL_STR
call int_to_string
push DWORD MSG_ENDERECO_INICIAL_SIZE
push MSG_ENDERECO_INICIAL
call print_string
push DWORD [TAMANHO_DA_MSG]
push ENDERECO_INICIAL_STR
call print_string

push DWORD [ENDERECO_FINAL]
push ENDERECO_FINAL_STR
call int_to_string
push DWORD MSG_ENDERECO_FINAL_SIZE
push MSG_ENDERECO_FINAL
call print_string
push DWORD [TAMANHO_DA_MSG]
push ENDERECO_FINAL_STR
call print_string

;verifica se ainda há programa para ser armazenado, se sim, continua o LOOP
mov EAX, [EDX + ECX * 8]
sub PROG_SIZE, EAX
jg CONTINUA_LOOP
jmp carrega_fim

;;;;;;;;;;;;;;;;;;;;;;;;

nao_cabe:
push MSG_NAO_CABE_SIZE
push MSG_NAO_CABE
call print_string
jmp carrega_fim

;;;;;;;;;;;;;;;;;;;;;;;;

carrega_fim:
push DWORD 1
push MSG_ENDL
call print_string
mov ESP, EBP
pop EBP
ret

;;;;;;;;;;;;;;;;;;;;;;;;

int_to_string:
push EBP
mov EBP, ESP
pusha

;divide por 10, pega módulo, coloca na pilha, salva o tamanho da MSG e depois vai desempilhando colocando na MSG.
mov EAX, [EBP + 12]
mov ESI, [EBP + 8]
mov EBX, 10
mov ECX, 0
loop_3:
cdq
idiv EBX
add EDX, 0x30
push EDX
inc ECX
cmp EAX, 0
jg loop_3
mov [TAMANHO_DA_MSG], ECX 
loop_4:
pop EDX
mov [ESI], DL
inc ESI
dec ECX
cmp ECX, 0
jg loop_4

popa
mov ESP, EBP
pop EBP
ret 8

;;;;;;;;;;;;;;;;;;;;;;;;

print_string:
push EBP
mov EBP, ESP
pusha

mov EAX, 4
mov EBX, 1
mov ECX, [EBP+8]
mov EDX, [EBP+12]
int 0x80

popa
mov ESP, EBP
pop EBP
ret 8
