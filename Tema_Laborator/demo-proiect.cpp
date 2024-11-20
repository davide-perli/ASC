#include <iostream>

using namespace std;

/*capacitatea de stocare a dispozitivului este data si fixata la 8MB
capacitatea de stocare a dispozitivului este impartita in blocuri de cate 8kB fiecare*/

// 8MB = 8 * 1024KB = 8192KB pt dispozitiv => deci are 1024 (8192/8KB=1024 nr_blocuri) de blocuri de cate 8KB
// iar 1KB = 1024 bytes3
// un singur fisier stocat in bloc (daca dim fisierului e mai mica, ramane spatiu neocupat in bloc)
// in schimb aceste dimensiuni sunt supraevaluate (vezi exemplu functionare pdf)
// 8KB se reduce la un 8 bytes
// noile dimensiuni
// dim_dispozitiv = 8192KB => 8192 bytes => deci are 1024 de blocuri de cate 8 bytes = 64 biti (stochez pe doi registrii alaturati)
// descriptor fisier intre 1 si 255 deci el va fi stocat ca sa poate curpinde toate valorile pe 8 biti adica 1 byte

int no_total_blocks = 10;
int memory[10] = {0};
int block_size = 8;
int next_available_block = 0;

void et_add_file_to_memory(int id, int f_size)
{
    int no_blocks_file;// pentru a adauga un fisier se calculeaza cate blocuri ocupa din cele 1024 valabile, prin aproximarea impartirii lui file_size la 8 (un bloc ocupa 8 bytes in termeni simplificati)
    int remainder_blocks_file;// restul impartirii de mai sus pentru aproximare (ex 2.5 devine 3 indecsi, 1.75 devine 2 indecsi)
    // no prescurtare number of
    no_blocks_file = f_size / block_size;// catul impartirii dimensiunii fisierului curent la 8 bytes
    remainder_blocks_file = f_size % block_size;// restul
    if(remainder_blocks_file > 0)// aproximarea prin adaos la unitati mereu e in favoarea valorii mai mari, deci se adauga un bloc pentru ca altfel fisierul nu ar incapea pe o dimensiune trunchiata
    {
        no_blocks_file += 1;
    }
    cout<<"Numarul de blocuri necesare fisier curent: "<<no_blocks_file<<endl;
    if(next_available_block + no_blocks_file <= no_total_blocks)
    {
        for(int i = 0; i < no_blocks_file; i++)
        {
            memory[next_available_block + i] = id;
        }
        next_available_block += no_blocks_file;
    } else
    {
        cout<<"nu e destula memorie pentru adaugare fisier "<<id<<" pe "<<f_size<<" KB"<<endl;
    }
}

int main()
{
    int file_descriptor, file_size;// file size de la tastatura se primeste in kb, deci necesita transformari
    int k;
    cout<<"Numar de fisiere de testat adaugarea: ";
    cin>>k;
    for(int i = 0; i < k; i++)
    {
        cout<<"id: "; cin>>file_descriptor;
        cout<<"size: "; cin>>file_size;
        et_add_file_to_memory(file_descriptor, file_size);
        cout<<"Starea memoriei dupa adaugarea fisierului: ";
        for(int i = 0; i < no_total_blocks; i++)
        {
            cout<<memory[i]<<" ";
        }
        cout<<endl;
    }
    return 0;
}