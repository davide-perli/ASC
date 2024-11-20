.data
    nr_total_blocks : .long 10              # Numar total de blocuri dupa exemplu

    memory : .long 0, 0, 0, 0, 0, 0, 0, 0, 0, 0         

    block_size : .long 8                    # capacitatea de stocare a dispozitivului este data si fixata la 8MB. Capacitatea de stocare a dispozitivului este impartita in blocuri de cate 8kB fiecare

    next_available_block : .long 0

    aux: .long 0


    # Endline
    z: .asciz "\n"

    a: .asciz "Introducere date"


    d: .asciz "Introduceti numarul de fisiere de testat adaugarea: "

    nr_fisiere: .space 4

    c: .asciz "%ld"

    b: .asciz "Numar de fisiere de testat adaugarea: %ld\n"

    e: .asciz "ID: "
    
    file_descriptor: .space 4

    input_id: .asciz "%ld"

    

.text

.global main

main:

# Afisare endline z
mov $4, %eax
mov $1, %ebx
mov $z, %ecx
mov $2, %edx
int $0x80

# Afisare string a

mov $4, %eax
mov $1, %ebx
mov $a, %ecx
mov $17, %edx
int $0x80

# Afisare endline z
mov $4, %eax
mov $1, %ebx
mov $z, %ecx
mov $2, %edx
int $0x80

# Afisare endline z
mov $4, %eax
mov $1, %ebx
mov $z, %ecx
mov $2, %edx
int $0x80

# Afisare string d
pusha
push $d
call printf
add $4, %esp
popa


# Input tastatura nr_fisiere
pusha
push $nr_fisiere
push $c
call scanf 
add $8, %esp
popa

# Output nr_fisiere
pusha
push nr_fisiere
push $b
call printf
add $8, %esp
popa


movl nr_fisiere, %ecx
parcurgere_dimensiune_fisiere:

    
    # Afisare string e
    pusha
    push $e
    call printf
    add $4, %esp
    popa

    # Input tastatura file_descriptor
    pusha
    push $file_descriptor
    push $input_id
    call scanf 
    add $8, %esp
    popa

    loop parcurgere_dimensiune_fisiere
    jmp continue

continue:


    # Sys call pentru incheierea programului
    mov $1, %eax       
    xor %ebx, %ebx      
    int $0x80      
