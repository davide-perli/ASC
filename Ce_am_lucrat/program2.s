.data

sum: .space 4
dif: .space 4
prod: .space 4
cat: .space  4
rest: .space 4
n: .long 5
v: .long 10, 20, 30, 40, 50


;// String cu mesaj
x: .asciz "Program asssembly scris de mine cu talent\n"

;// Operatii
y: .asciz "Operatii\n"

;// Endlinee
z: .asciz "\n"

;// Adunare
a: .asciz "Adunare: %d\n"

;// Scadere
b: .asciz "Scadere: %d\n"

;// Inmultire
c: .asciz "Inmultire: %ld\n"

;// Cat impartire
d: .asciz "Cat impartire: %ld\n"

;// Rest impartire
e: .asciz "Rest impartire: %ld\n"

;// Mesaj vector
vector_mesaj: .asciz "Afisare element vector la indexul dorit"

;// Elemente vector la indicele dorit
vector: .asciz "  V[%ld] = %ld\n"

;// Mesaj parcurgere vector

parc_vector: .asciz "Parecurgere vector"


.text

.global main
main:

;// Afisare endline z

mov $4, %eax
mov $1, %ebx
mov $z, %ecx
mov $2, %edx
int $0x80

;// Sys call pentru afisare ecran
;// Afisare string x

mov $4, %eax
mov $1, %ebx
mov $x, %ecx
mov $42, %edx
int $0x80

;// Afisare endline z

mov $4, %eax
mov $1, %ebx
mov $z, %ecx
mov $2, %edx
int $0x80

;// Afisare string y

mov $4, %eax
mov $1, %ebx
mov $y, %ecx
mov $10, %edx
int $0x80

;// Afisare endline z

mov $4, %eax
mov $1, %ebx
mov $z, %ecx
mov $2, %edx
int $0x80

;// Afisare endline z

mov $4, %eax
mov $1, %ebx
mov $z, %ecx
mov $2, %edx
int $0x80

;// Adunare 10 + 21

mov $10, %eax
add $21, %eax
mov %eax, sum


;// Afisare adunare

pusha
push sum            
push $a 
call printf
add $8, %esp
popa

;// Afisare endline z

mov $4, %eax
mov $1, %ebx
mov $z, %ecx
mov $2, %edx
int $0x80

;// Scadere 100 - 31
mov $100, %eax
sub $31, %eax
mov %eax, dif

;// Afisare scadere 

pusha
push dif
push $b
call printf
add $8, %esp
popa

;// Afisare endline z

mov $4, %eax
mov $1, %ebx
mov $z, %ecx
mov $2, %edx
int $0x80

;// Inmultire  13 * 13
mov $13, %eax
mov $13, %ebx
imul %ebx
mov %eax, prod

;// Afisare inmultire 
pusha
pushl prod
pushl $c 
call printf
add $8, %esp
popa

;// Afisare endline z

mov $4, %eax
mov $1, %ebx
mov $z, %ecx
mov $2, %edx
int $0x80

;// Impartire 145 / 2
mov $145, %eax
mov $2, %ebx
mov $0, %edx
idiv %ebx
mov %eax, cat
mov %edx, rest

;// Afisare cat impartire
pusha
pushl cat
pushl $d
call printf
add $8, %esp
popa

;// Afisare rest impartire
pusha
pushl rest
pushl $e
call printf
add $8, %esp
popa

;// Afisare endline z

mov $4, %eax
mov $1, %ebx
mov $z, %ecx
mov $2, %edx
int $0x80

;// Afisare mesaj vector

mov $4, %eax
mov $1, %ebx
mov $vector_mesaj, %ecx
mov $40, %edx
int $0x80

;// Afisare endline z

mov $4, %eax
mov $1, %ebx
mov $z, %ecx
mov $2, %edx
int $0x80

;// Element vector la indexul dorit
lea v, %edi
mov $3, %ecx
movl (%edi, %ecx, 4), %edx

;// Afisare element vector la indexul dorit
pusha
pushl %edx
pushl %ecx
pushl $vector
call printf
add $8, %esp
popa
popa

;// Afisare endline z

mov $4, %eax
mov $1, %ebx
mov $z, %ecx
mov $2, %edx
int $0x80

;// Afisare mesaj vector

mov $4, %eax
mov $1, %ebx
mov $parc_vector, %ecx
mov $18, %edx
int $0x80

;// Afisare endline z

mov $4, %eax
mov $1, %ebx
mov $z, %ecx
mov $2, %edx
int $0x80

;// Parecurgere vector  in ordine crescatoare

lea v, %edi
mov n, %ecx
mov $0, %ebx

etloop:
    cmp $0, %ecx
    jle end_loop

    mov n, %eax
    sub %ecx, %eax
    movl (%edi, %eax, 4), %edx

    ;// Afisare elemente vector in ordine descrescatoare
    pusha
    push %edx
    push %ebx
    push $vector
    call printf
    add $12, %esp
    popa

    dec %ecx
    add $1, %ebx

    jmp etloop

end_loop:

;// System call pentru incheierea programului
mov $1, %eax       
xor %ebx, %ebx      
int $0x80      
     