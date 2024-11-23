#include <iostream>

using namespace std;

/*capacitatea de stocare a dispozitivului este data si fixata la 8MB
capacitatea de stocare a dispozitivului este impartita in blocuri de cate 8kB fiecare*/

// 8MB = 8 * 1024KB = 8192KB pt dispozitiv => deci are 1024 (8192/8KB=1024 nr_blocuri) de blocuri de cate 8KB
// iar 1KB = 1024 bytes
// un singur fisier stocat in bloc (daca dim fisierului e mai mica, ramane spatiu neocupat in bloc)
// in schimb aceste dimensiuni sunt supraevaluate (vezi exemplu functionare pdf)
// 8KB se reduce la un 8 bytes
// noile dimensiuni
// dim_dispozitiv = 8192KB => 8192 bytes => deci are 1024 de blocuri de cate 8 bytes = 64 biti (stochez pe doi registrii alaturati)
// descriptor fisier intre 1 si 255 deci el va fi stocat ca sa poate curpinde toate valorile pe 8 biti adica 1 byte

int no_total_blocks = 10;
int memory[10] = {0};
int block_size = 8;

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
    if(no_blocks_file < 2)
    {
        no_blocks_file = 2;
    }
    cout<<"Numarul de blocuri necesare fisier curent: "<<no_blocks_file<<endl;


    // de aici am modificat putin logica
    int next_available_block = -1;// stim de unde putem adauga fisierul (intr-o secventa de zerouri de oriunde din vectorul memory in care ar incapea ca marime)
    int free_count = 0;// pt a numara blocurile consecutive de zerouri care exista
    for(int i = 0; i < no_total_blocks; i++)
    {
        if(memory[i] == 0)// am agsit o secventa care incepe cu zero ocupand de cel putin un indice din memorie
        {
            if(next_available_block == -1)// daca inca nu am stabilit care e inceputul secventei, o marcam la prima aparitie a unui zero dupa valori diferite de zero
            {
                next_available_block = i;
            }
            free_count++;// incrementez pana la umratoare valoare diferita de zero
            if(free_count == no_blocks_file)
            {
                break;// iesim din loop daca zecventa de zerouri consecutive e suficient de mare, nu e nevoie de un end_index
            }
        } else// se reseteaza la blocuri deja folosite adica diferite de zero
        {
            next_available_block = -1;
            free_count = 0;
        }
    }

    // am modificat putin conditia
    if(next_available_block != -1)
    {
        for(int i = 0; i < no_blocks_file; i++)
        {
            memory[next_available_block + i] = id;
        }
        // am sters conditia next_available_block += no_blocks_file
    } else
    {
        cout<<"nu e destula memorie pentru adaugare fisier "<<id<<" pe "<<f_size<<" KB"<<endl;
    }
}
//verific in primul rand cate blocuri sunt asociate cu acel file descriptor
void et_delete_file_from_memory(int id)
{
    bool found_file_to_delete = false;
    for(int i = 0; i < no_total_blocks; i++)
    {
        if(memory[i] == id)
        {
            memory[i] = 0;
            found_file_to_delete = true;
        }
    }

    if(found_file_to_delete)
    {
        cout<<"fisierul "<<id<<" a fost sters"<<endl;
    } else
    {
        cout<<"fisierul nu a fost gasit"<<endl;
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
    cout<<"Numar de fisiere de testat stergerea: ";// btw in cerinta se va sterge un fisier at one time deci nu are ce sa caute loop-ul cu for
    cin>>k;
    for(int i = 0; i < k; i++)
    {
        cout<<"id: "; cin>>file_descriptor;
        et_delete_file_from_memory(file_descriptor);
        cout<<"Starea memoriei dupa stergerea fisierului: ";
        for(int i = 0; i < no_total_blocks; i++)
        {
            cout<<memory[i]<<" ";
        }
        cout<<endl;
    }
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