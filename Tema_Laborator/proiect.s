.data
    nr_total_blocks: .long 10              # Numar total de blocuri dupa exemplu

    memory: .space 40       

    block_size : .long 8                    # capacitatea de stocare a dispozitivului este data si fixata la 8MB. Capacitatea de stocare a dispozitivului este impartita in blocuri de cate 8kB fiecare

    next_available_block: .space 4

    nr_blocks_file: .space 4

    remainder_blocks_file: .space 4

    nr_operatii: .space 4

    tipul_operatiei: .space 4

    free_count: .space 4

    contor:  .space 4

    nr_fisiere: .space 4

    found_file_to_delete: .space 4

    file_size: .space 4

    file_descriptor: .space 4

    file_descriptor_stergere: .space 4

    file_descriptor_get: .space 4

    start_poz: .space 4
    
    end_poz: .space 4

    # Endline
    z: .asciz "\n"

    a: .asciz "Introducere date"

    k: .asciz "Introduceti numarul de operatii care se vor efectua: "

    l: .asciz "Introduceti tipul operatiei (1-ADD; 2-GET; 3-DELETE; 4-DEFRAGMENTATION ): "

    m: .asciz "Introduceti o operatie valida\n"

    d: .asciz "Introduceti numarul de fisiere de testat adaugarea: "


    c: .asciz "%ld"

    b: .asciz "Numar de fisiere de testat adaugarea: %ld\n"

    e: .asciz "ID: "

    input_id: .asciz "%ld"

    delete_id: .asciz "%ld"

    get_id: .asciz "%ld"

    f: .asciz "Size (kb): "

    input_file_size: .asciz "%ld"

    g: .asciz "Numarul de blocuri necesare fisier curent: %ld\n"

    h: .asciz "Nu este suficienta memorie pentru a adauga fisierul %ld cu dimensiunea %ld KB.\n"

    i: .asciz "Starea memoriei dupa adaugarea fisierului: "

    j: .asciz "%ld "

    n: .asciz "Fisierul nu a fost gasit\n"

    o: .asciz "Fisierul cu id-ul %ld a fost gasit\n"

    p: .asciz "Starea memoriei dupa stergerea fisierului: "

    q: .asciz "%ld "

    r: .asciz "(%ld , %ld)\n"

    s: .asciz "(0, 0)\n"

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

        mov nr_operatii, %eax
        cmp $0, %eax
        jz iesire

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
                je repetare

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
                    mov nr_blocks_file, %eax
                    cmp $2, %eax
                    jg afisare_blocuri_necesare

                set_default_blocks:
                    mov $2, %eax
                    mov %eax, nr_blocks_file

                afisare_blocuri_necesare:
                # Afisare numar blocuri necesare (string g)
                pusha
                push nr_blocks_file
                push $g
                call printf
                add $8, %esp
                popa

                mov $-1, %eax
                mov %eax, next_available_block

                mov  $0, %eax
                mov %eax, free_count

                # Parcurgere vector

                mov $0, %eax
                mov %eax, contor

                cautare_next_available_block:
                    mov contor, %esi
                    mov nr_total_blocks, %ebx
                    cmp %esi, %ebx
                    je verificare

                    mov memory(,%esi,4), %eax
                    cmp $0, %eax
                    jnz reset_blocuri  
                    
                    mov next_available_block, %eax
                    cmp $-1, %eax
                    jne increment_free_count

                    mov contor, %eax
                    mov %eax, next_available_block

                    increment_free_count:
                        mov free_count, %eax
                        inc %eax
                        mov %eax, free_count

                    mov free_count, %eax
                    mov nr_blocks_file, %ebx
                    cmp %eax, %ebx
                    je verificare
                    jmp increment_contor


                    reset_blocuri:

                        mov $-1, %eax
                        mov %eax, next_available_block

                        mov $0, %eax
                        mov %eax, free_count            
                increment_contor:
                    mov contor, %eax
                    inc %eax
                    mov %eax, contor

                jmp cautare_next_available_block



                # Verificare memorie suficienta
                verificare: 
                    mov next_available_block, %eax
                    cmp $-1, %eax
                    je memorie_insuficienta       


                # Adaugare ID fisier in memorie
                mov next_available_block, %esi
                mov nr_blocks_file, %edx
                mov $0, %eax
                mov %eax, contor

                adaugare_blocuri:
                    mov contor, %eax
                    cmp %eax, %edx
                    je afisare_memorie

                    mov file_descriptor, %eax
                    mov %eax, memory(,%esi,4)  # Salvare id in bloc curemt
                    inc %esi                   # Next bloc

                    mov contor, %eax
                    inc %eax
                    mov %eax, contor

                    jmp adaugare_blocuri


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

        get:
            mov $-1, %eax
            mov %eax, start_poz

            mov $-1, %eax
            mov %eax, end_poz

            # Afisare input ID fiser get
            pusha
            push $e
            call printf
            add $4, %esp
            popa

            pusha
            push $file_descriptor_get
            push $get_id
            call scanf
            add $8, %esp
            popa

            parcurgere_fisiere_get: 
                # Get id din memorie
                mov $0, %esi
                mov nr_total_blocks, %edx

                get_blocuri:
                    cmp %esi, %edx
                    je afisare_memorie_get

                    mov memory(,%esi,4), %eax
                    cmp file_descriptor_get, %eax
                    jne iesire_get

                    mov start_poz, %eax
                    cmp $-1, %eax
                    jne modif_end

                    mov %esi, start_poz

                    modif_end:
                        mov %esi, end_poz
                        jmp incrementare_get

                    iesire_get:
                        mov start_poz, %eax
                        cmp $-1, %eax
                        jne afisare_memorie_get

                    incrementare_get:
                        inc %esi

                jmp get_blocuri

                afisare_memorie_get:
                    mov start_poz, %eax
                    cmp $-1, %eax
                    jne get_gasit

                    pusha
                    push $s
                    call printf
                    add $4, %esp
                    popa 

                    jmp repetare

                    get_gasit:
                        pusha
                        push end_poz
                        push start_poz
                        push $r
                        call printf
                        add $12, %esp
                        popa

                        jmp repetare



        # 0-fals, 1-true
        stergere_fisiere:
            mov $0, %eax
            mov %eax, found_file_to_delete

            mov $0, %eax
            mov %eax, contor

            # Afisare input ID fisier stergere
            pusha
            push $e
            call printf
            add $4, %esp
            popa

            pusha
            push $file_descriptor_stergere
            push $delete_id
            call scanf
            add $8, %esp
            popa

            parcurgere_fisiere_stergere: 
                # Stergere id din memorie
                mov $0, %esi
                mov nr_total_blocks, %edx

                stergere_blocuri:
                    cmp %esi, %edx
                    je afisare_memorie_stearsa

                    mov memory(,%esi,4), %eax
                    cmp file_descriptor_stergere, %eax
                    jne incrementare_contor_stergere

                    mov $0, %eax
                    mov %eax, memory(,%esi,4)  # Salvare 0 in bloc curemt
                    mov $1, %eax
                    mov %eax, found_file_to_delete

                    incrementare_contor_stergere:
                        inc %esi

                    jmp stergere_blocuri

                afisare_memorie_stearsa:
                    # Afisare mesaj p
                    pusha
                    push $p
                    call printf
                    add $4, %esp
                    popa

                mov $0, %edi 
                loop_afisare_memorie_stearsa:
                    cmp nr_total_blocks, %edi
                    je afisare_endline_stergere
                    mov memory(,%edi,4), %eax

                    # Afisare stare memorie, catve un element al vectorului pe rand
                    pusha
                    push %eax
                    push $q
                    call printf
                    add $8, %esp
                    popa
                    inc %edi  

                    jmp loop_afisare_memorie_stearsa

                    
                    afisare_endline_stergere:
                        pusha
                        push $z
                        call printf
                        add $4, %esp
                        popa


            afisare_mesaj_stergere:
                mov found_file_to_delete, %eax
                cmp $1, %eax
                je fisier_gasit

                pusha
                push $n
                call printf
                add $4, %esp
                popa

                jmp repetare

                fisier_gasit:
                    pusha
                    push file_descriptor_stergere
                    push $o
                    call printf
                    add $8, %esp
                    popa

                    jmp repetare



        defragmentation:

    repetare:
        mov nr_operatii, %eax
        dec %eax
        mov %eax, nr_operatii
        jmp efectuare_operatii


iesire:

    mov $1, %eax       
    xor %ebx, %ebx      
    int $0x80
