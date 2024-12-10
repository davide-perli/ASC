.data

    nr_total_blocks: .long 1024              # Numar total de blocuri dupa exemplu (exemplu mic : 10)

    memory: .space 4096                      # Exemplu mic 40

    aux_memory: .space 4096                  # Exemply mic 40  

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

    m: .asciz "Introduceti o operatie valida\n"

    c: .asciz "%ld"

    b: .asciz "Numar de fisiere de testat adaugarea: %ld\n"

    e: .asciz "ID: "

    input_id: .asciz "%ld"

    delete_id: .asciz "%ld"

    get_id: .asciz "%ld"

    input_file_size: .asciz "%ld"

    h: .asciz "Nu este suficienta memorie pentru a adauga fisierul %ld cu dimensiunea %ld KB.\n"

    j: .asciz "%ld "

    q: .asciz "%ld "

    r: .asciz "%ld: (%ld, %ld)\n"

    g: .asciz "(%ld, %ld)\n"

    s: .asciz "(0, 0)\n"

    t: .asciz "Memorie modificata: "

    u: .asciz "%ld "

.text

.global main

main:

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

        # Input tipul operatiei
        pusha
        push $tipul_operatiei
        push $c
        call scanf
        add $8, %esp
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

                # Input ID fisier
                pusha
                push $file_descriptor
                push $input_id
                call scanf
                add $8, %esp
                popa

                # Input dimensiune fisier
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
                    je parcurgere_fisiere_get_add

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


                parcurgere_fisiere_get_add: 
                mov $-1, %eax
                mov %eax, start_poz

                mov $-1, %eax
                mov %eax, end_poz

                mov $0, %esi
                mov nr_total_blocks, %edx

                get_blocuri_add:
                    cmp %esi, %edx
                    je afisare_memorie_get_add

                    mov memory(,%esi,4), %eax
                    cmp file_descriptor, %eax
                    jne iesire_get_add

                    mov start_poz, %eax
                    cmp $-1, %eax
                    jne modif_end_add

                    mov %esi, start_poz

                    modif_end_add:
                        mov %esi, end_poz
                        jmp incrementare_get_add

                    iesire_get_add:
                        mov start_poz, %eax
                        cmp $-1, %eax
                        jne afisare_memorie_get_add

                    incrementare_get_add:
                        inc %esi

                jmp get_blocuri_add

                afisare_memorie_get_add:
                    pusha
                    push end_poz
                    push start_poz
                    push file_descriptor
                    push $r
                    call printf
                    add $16, %esp
                    popa


                decrement_nr_fisiere:
                    dec %ecx
                    jmp parcurgere_fisiere

        get:
            mov $-1, %eax
            mov %eax, start_poz

            mov $-1, %eax
            mov %eax, end_poz

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
                        push $g
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


                parcurgere_fisiere_get_delete: 
                mov $-1, %eax
                mov %eax, start_poz

                mov $-1, %eax
                mov %eax, end_poz

                mov $0, %esi
                mov nr_total_blocks, %edx

                get_blocuri_delete:
                    cmp %esi, %edx
                    je afisare_memorie_get_delete

                    mov memory(,%esi,4), %eax
                    cmp file_descriptor_stergere, %eax
                    jne iesire_get_delete

                    mov start_poz, %eax
                    cmp $-1, %eax
                    jne modif_end_delete

                    mov %esi, start_poz

                    modif_end_delete:
                        mov %esi, end_poz
                        jmp incrementare_get_delete

                    iesire_get_delete:
                        mov start_poz, %eax
                        cmp $-1, %eax
                        jne afisare_memorie_get_delete

                    incrementare_get_delete:
                        inc %esi

                jmp get_blocuri_delete

                afisare_memorie_get_delete:
                    pusha
                    push end_poz
                    push start_poz
                    push file_descriptor_stergere
                    push $r
                    call printf
                    add $16, %esp
                    popa


            jmp repetare


        defragmentation:
                mov $0, %eax
                mov %eax, contor
                
                mov $0, %esi
                mov nr_total_blocks, %edx

                sciere_memorie_aux:
                    cmp %esi, %edx
                    je modifica_memory

                    mov memory(,%esi,4), %eax
                    cmp $0, %eax
                    je incrementare_contor_org

                    mov memory(,%esi,4), %eax
                    mov contor, %ebx
                    mov %eax, aux_memory(,%ebx,4) #interschimbare valori din memorie org in memorie aux

                    mov contor, %eax
                    inc %eax
                    mov %eax, contor

                    incrementare_contor_org:
                        inc %esi

                    jmp sciere_memorie_aux

                
                modifica_memory:
                    mov $0, %esi
                    mov nr_total_blocks, %edx

                    actualizare_memorie:
                        cmp %esi, %edx
                        je afisare_memorie_modificata

                        mov contor, %ebx
                        cmp %esi, %ebx
                        jle memorie_zero

                        mov aux_memory(,%esi,4), %eax
                        mov %eax, memory(,%esi,4)

                        jmp incrementare_contor_modificare

                        memorie_zero:
                            mov $0, %eax
                            mov %eax, memory(,%esi,4)

                        incrementare_contor_modificare:
                            inc %esi 
                    
                    jmp actualizare_memorie


                afisare_memorie_modificata:
                    # Afisare mesaj t
                    pusha
                    push $t
                    call printf
                    add $4, %esp
                    popa

                parcurgere_fisiere_get_defragmentation: 
                mov $-1, %eax
                mov %eax, start_poz

                mov $-1, %eax
                mov %eax, end_poz

                mov $0, %esi
                mov nr_total_blocks, %edx

                get_blocuri_defragmentation:
                    cmp %esi, %edx
                    je afisare_memorie_get_defragmentation

                    mov memory(,%esi,4), %eax
                    cmp file_descriptor, %eax
                    jne iesire_get_defragmentation

                    mov start_poz, %eax
                    cmp $-1, %eax
                    jne modif_end_defragmentation

                    mov %esi, start_poz

                    modif_end_defragmentation:
                        mov %esi, end_poz
                        jmp incrementare_get_defragmentation

                    iesire_get_defragmentation:
                        mov start_poz, %eax
                        cmp $-1, %eax
                        jne afisare_memorie_get_defragmentation

                    incrementare_get_defragmentation:
                        inc %esi

                jmp get_blocuri_defragmentation

                afisare_memorie_get_defragmentation:
                    pusha
                    push end_poz
                    push start_poz
                    push file_descriptor
                    push $r
                    call printf
                    add $16, %esp
                    popa

                jmp repetare

    repetare:
        mov nr_operatii, %eax
        dec %eax
        mov %eax, nr_operatii
        jmp efectuare_operatii


iesire:

    mov $1, %eax       
    xor %ebx, %ebx      
    int $0x80
