.model small
.stack 100h
 
.data
indexul db 2 dup (0)
invalid db "Indexul introdus este invalid!",0,'$';invalid
string db 'Introduceti indexul numelui pe care doriti sa-l stergeti:',0,'$';stergere
punct db '.$'
prompt db 'Introduceti un nume:',0,'$';nume
list db 'Lista cu numele este:',0,'$';lista
nume db 54 dup(0)
numes dw 256;numarul de nume stocate
numeIndex db 13, 10, "1.$" ;index afisat in lista
 
numePointer dw 1280
menu db "Alege o optiune:",13,10
     db "1. Nume",13,10
     db "2. Lista cu numele",13,10
     db "3. Sterge un nume",13,10
     db "4. Exit",13,10,'$';meniu principal
 
.code
start:
    mov al, 0
   ;initializare segment de date
    mov  ax, @data
    mov  ds, ax
    mov es, ax; se declara segmenet extra pentru a muta cu movsb( move data from string to string ) , numele stocate in string.
    mov numePointer, offset nume; initializare pointer stiva
    call clear_screen
bucla:
    ;muta cursorul pe urmatoarea linie
    mov dl, 0dh
    mov ah, 2
    int 21h
    mov dl, 0ah
    int 21h
    ;afisare meniu
    call display_menu
    mov ah, 1
    int 21h
    cmp al, '1'; vede ce tasta s-a apasat de la tastatura
    je scrienume
    cmp al, '2'
    je lista
    cmp al, '3'
    je sterge
    cmp al, '4'
    je exit
    jmp bucla
   exit:
   ;incheiere program
    mov  ax, 4c00h
    int 21h;intrerupere
 
 
scrienume:
    call clear_screen
    mov  dx, offset prompt;afiseaza mesajul de introducere a unui nume
  mov  ah, 09h
  int  21h
  mov  cx, 5; cx= registru counter, mutam in cx valoarea 5 ( 5 caractere pentru un nume ), ca apoi sa putem citii exact 5 caractere de la tastatura.
  mov  si, numePointer; si= source index, pune in si valoarea stocata in numePointer, pentru a nu suprascrie numele, tine minte unde s-a terminat numele anterior.
  read_char:; citeste pe rand cate o litera de la tastatura, pana cand s-au introdus 5
  mov  ah, 01h
  int  21h
  mov  [si], al; muta litera apasata in numePointer pe pozitia si
  inc  si; pregateste pozitia pentru urmatoarea litera
  loop read_char; repeta pana cand cx=0// il scade pe cx mereu si verifica daca este 0.
  mov  byte ptr [si], '$'; adauga caracterul de terminare '$' dupa fiecare nume scris, pentru a le delimita
  inc  si; creste si pentru a pregati urmatoarea pozitie pentru urmatorul nume
  mov  numePointer, si ; numePointer= numePointer+6 pentru a trece la urmatorul nume in string
  jmp  bucla; revenire la meniu principal
 
 
 
 
 
lista:
call clear_screen
mov dx, offset list; afisare mesaj
mov ah, 09h
int 21h
mov  byte ptr [numeIndex + 2], "1"; incepe mereu afisarea indexilor de la 1, pentru a nu se marii atunci cand apasam 1, il muta 2 octeti pentru a nu se suprascrie cu altceva
  mov  dx, offset nume; muta in dx valoarea din memoria unde "nume" este stocat, dx+nume=0, incepe de la pozitia 0 sa le stocheze (vezi *)
print_names:
  push dx ; pune dx pe stiva                       ; (1)
  mov  dx, offset numeIndex; muta numele in segmentul de data
  mov  ah, 09h
  int  21h; afiseaza numele
  inc  byte ptr [numeIndex + 2]  ; "1" -> "2" -> "3" ... creste valoarea indexului pe masura ce un nume este afisat.
  pop  dx                        ; * pune ce e pe stiva in dx, in zona de memorie declarata anterior (offset nume)
 
  mov  ah, 09h
  int  21h
  add  dx, 5 + 1; pregateste scrierea unui nou nume in memorie 
  cmp  dx, numePointer ; verifica daca numele este ultimul
  jb   print_names; daca nu este ultimul sare inapoi la print_names
  jmp  bucla           ; se intoarce in bucla principala
 
 
 
sterge:
call clear_screen
    ; Cere indexul care va fi sters 
    mov dx, offset string
    mov ah, 09h
    int 21h
    ; citeste indexul 
    mov ah, 01h
    int 21h
    sub  al, 49      ; AL=["1","9"] 1-based input -> AL=[0,8] 0-based index//practic scade din al '49' adica scade 1 din al.
  mov  ah, 6
  mul  ah          ; -> AX = {0,6,12,18,24,30,36,42,48}
  add  ax, offset nume; calculeaza unde este stocat numele care va trebui sters
  cmp  ax, numePointer; verifica daca indexul este valid sau invalid, comparand pe ax cu valorea stocata in numePointer
  jnb  invalidPosition; daca este invalid sare la mesajul de display: invalid
  mov  di, ax; muta ax in registrul de destintatie
  lea  si, [di + 6]; dupa zona de memorie unde este stocat di, se adauga 6 bytes
  mov  cx, numePointer; pune in cx ce este in numePointer
  sub  cx, si; scadem din cx pe si, calculand cate litere trebuie sterse 
  cld
  rep movsb; muta din locatia aratata de si, ceea ce se afla in locatia aratata de di (muta sursa in destinatie)//practic va muta in primii n+6, urmatorii n+12, sarind peste un nume, stergandu-l
  mov  numePointer, di; mutam di in numePointer pentru a vedea exact unde sunt stocate numele
  dec  numes  ; -un nume
  jmp  bucla
  
invalidPosition:
    MOV dl, 10
MOV ah, 02h
INT 21h
MOV dl, 13
MOV ah, 02h
INT 21h; se printeaza linie noua
    mov dx, offset invalid; afisare mesaj invalid
    mov ah, 09h
    int 21h
    jmp bucla
 
 
;---------------------------------------------
display_menu proc
  mov  dx, offset menu
  mov  ah, 9
  int  21h
  ret
display_menu endp
 
clear_screen proc
  mov  ah, 0
  mov  al, 3
  int  10H
  ret
clear_screen endp
end start
