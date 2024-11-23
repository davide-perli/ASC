.data
    nr_total_blocks: .long 10              # Numar total de blocuri dupa exemplu

    memory: .long 0, 0, 0, 0, 0, 0, 0, 0, 0, 0         

    block_size : .long 8                    # capacitatea de stocare a dispozitivului este data si fixata la 8MB. Capacitatea de stocare a dispozitivului este impartita in blocuri de cate 8kB fiecare

    next_available_block: .long 0

    nr_blocks_file: .space 4

    remainder_blocks_file: .space 4

    nr_operatii: .space 4

    tipul_operatiei: .space 4

    # Endline
    z: .asciz "\n"

    a: .asciz "Introducere date"

    k: .asciz "Introduceti numarul de operatii care se vor efectua: "

    l: .asciz "Introduceti tipul operatiei (1-ADD; 2-GET; 3-DELETE; 4-DEFRAGMENTATION ): "

    m: .asciz "Introduceti o operatie valida\n"

    d: .asciz "Introduceti numarul de fisiere de testat adaugarea: "

    nr_fisiere: .space 4

    c: .asciz "%ld"

    b: .asciz "Numar de fisiere de testat adaugarea: %ld\n"

    e: .asciz "ID: "
    
    file_descriptor: .space 4

    input_id: .asciz "%ld"

    f: .asciz "Size (kb): "

    file_size: .space 4

    input_file_size: .asciz "%ld"

    g: .asciz "Numarul de blocuri necesare fisier curent: %ld\n"

    h: .asciz "Nu este suficienta memorie pentru a adauga fisierul %ld cu dimensiunea %ld KB.\n"

    i: .asciz "Starea memoriei dupa adaugarea fisierului: "

    j: .asciz "%ld "

.text

.global main

main:

    # Afisare endline z
    pusha
    push $z
    call printf
    add $4, %esp
    popa

    # Afisare string a
    pusha
    push $a
    call printf
    add $4, %esp
    popa

    # Afisare endline z
    pusha
    push $z
    call printf
    add $4, %esp
    popa

    # Afisare string k
    pusha
    push $k
    call printf
    add $4, %esp
    popa

    # Input numar opertii
    pusha
    push $nr_operatii
    push $c
    call scanf
    add $8, %esp
    popa


    # Daca am 0 operatii automat sar direct la eticheta iesire si termin prograamul
    mov nr_operatii, %eax
    cmp $0, %eax
    jz iesire

    efectuare_operatii:

        # Afisare string l
        pusha
        push $l
        call printf
        add $4, %esp
        popa

        # Input tipul operatiei
        pusha
        push $tipul_operatiei
        push $c
        call scanf
        add $8, %esp
        popa  

        # Afisare endline z
        pusha
        push $z
        call printf
        add $4, %esp
        popa

        mov tipul_operatiei, %eax
        cmp $1, %eax
        je add

        cmp $2, %eax
        je get

        cmp $3, %eax
        je stergere_fisiere

        cmp $4, %eax
        je defragmentation

        eroare_tip_operatie:

            # Afisare string m
            pusha
            push $m
            call printf
            add $4, %esp
            popa

            jmp efectuare_operatii

        add: 

            # Afisare string d
            pusha
            push $d
            call printf
            add $4, %esp
            popa

            # Input numar fisiere
            pusha
            push $nr_fisiere
            push $c
            call scanf
            add $8, %esp
            popa


            mov nr_fisiere, %ecx 
            parcurgere_fisiere:
                mov $0, %eax
                mov %eax, nr_blocks_file
                mov $0, %eax
                mov %eax, remainder_blocks_file

                cmp $0, %ecx          
                je iesire

                # Afisare si input ID fisier

                pusha
                push $e
                call printf
                add $4, %esp
                popa

                pusha
                push $file_descriptor
                push $input_id
                call scanf
                add $8, %esp
                popa

                # Afisare si input dimensiune fisier
                pusha
                push $f
                call printf
                add $4, %esp
                popa

                pusha
                push $file_size
                push $input_file_size
                call scanf
                add $8, %esp
                popa

                # Calcul numar de blocuri necesare
                mov file_size, %eax   
                mov block_size, %ebx  
                xor %edx, %edx       
                idiv %ebx           
                mov %eax, nr_blocks_file
                mov %edx, remainder_blocks_file
                cmp $0, %edx
                jz skip_increment
                # Daca e rest adaug un bloc
                mov nr_blocks_file, %eax
                inc %eax
                mov %eax, nr_blocks_file

                skip_increment:

                # Afisare numar blocuri necesare
                pusha
                push nr_blocks_file
                push $g
                call printf
                add $8, %esp
                popa

                # Verificare memorie suficienta
                mov next_available_block, %eax
                add nr_blocks_file, %eax
                cmp nr_total_blocks, %eax
                jg memorie_insuficienta       # doar ">" decat ">="


                # Adaugare ID fisier in memorie
                mov next_available_block, %esi
                mov nr_blocks_file, %edx

                adaugare_blocuri:
                    cmp $0, %edx
                    je actualizare_bloc_liber

                    mov file_descriptor, %eax
                    mov %eax, memory(,%esi,4)  # Salvare id in bloc curemt
                    inc %esi                   # Next bloc

                    dec %edx
                    jmp adaugare_blocuri

                actualizare_bloc_liber:
                    mov next_available_block, %eax
                    add nr_blocks_file, %eax         
                    mov %eax, next_available_block   

                    jmp afisare_memorie 


                memorie_insuficienta:
                    pusha
                    push file_size
                    push file_descriptor
                    push $h
                    call printf
                    add $12, %esp
                    popa
                    jmp decrement_nr_fisiere

                # Afisare mesaj i
                afisare_memorie:
                    pusha
                    push $i
                    call printf
                    add $4, %esp
                    popa

                mov $0, %edi            
                loop_afisare_memorie:
                    cmp nr_total_blocks, %edi
                    je afisare_endline
                    mov memory(,%edi,4), %eax

                    # Afisare stare memorie, catve un element al vectorului pe rand
                    pusha
                    push %eax
                    push $j
                    call printf
                    add $8, %esp
                    popa
                    inc %edi  

                

                    jmp loop_afisare_memorie

                    
                    afisare_endline:
                        pusha
                        push $z
                        call printf
                        add $4, %esp
                        popa


                decrement_nr_fisiere:
                    dec %ecx
                    jmp parcurgere_fisiere




        stergere_fisiere:
        get:
        defragmentation:


iesire:

    mov $1, %eax       
    xor %ebx, %ebx      
    int $0x80
