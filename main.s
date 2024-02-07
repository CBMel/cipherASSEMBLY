TITLE grp8_project.asm
;//Program Description: Cipher Thing
;//Programmed by: Group 8 (Cory, Kye, Phillip, Ivan)
;//Due Date: 12/09/22
INCLUDE Irvine32.inc

;// procedures****************************************************


DisplayMenu PROTO, UserOption1 : DWORD
PickAProc PROTO,  UserOption2:DWORD, PhraseToUse2:DWORD, KeyToUse2:DWORD, KeyLength2:DWORD, PhraseLength2:DWORD
Encrypt PROTO, PhraseToUse3:DWORD, PhraseLength3 : DWORD, KeyToUse3 : DWORD, KeyLength3 : DWORD
;Decrypt PROTO, PhraseToUse4:DWORD, PhraseLength4 : DWORD, KeyToUse4 : DWORD, KeyLength4 : DWORD
EnterString1 PROTO, PhraseToUse3:DWORD, PhraseLength3 : DWORD
AlphaNums  PROTO, PhraseToUse5:DWORD, PhraseLength5 : DWORD
PrintString PROTO, PhraseToUse6:DWORD, PhraseLength6 : DWORD

ClearRegs PROTO

.data

newLine EQU <0ah, 0dh>
errorMsg BYTE "You have selected an invalid option.", newline,   ;//Data block for messages to user
"Please try again.", newline, newLine, 0h
Goodbye BYTE "Goodbye! ", 2, newLine, 0
MaxLength = 150d;// max length for phrase AND key

.code

main PROC
.data
    userOption BYTE 0
    phrasetouse byte 150 dup (?)
    keytouse byte "DOG123",0
    phraselength byte 0
    keylength byte 0
.code
    StartHere :                     ;//Label for the return to the beginnign of the original menu display
    call ClrScr
    INVOKE clearRegs
    mov EBX, OFFSET userOption
    INVOKE DisplayMenu, offset userOption

    cmp byte ptr [ebx], 1d
    jb invalid
    cmp byte ptr [ebx], 4d          ;//Compares users input to determine where to direct it
    jb driver
    cmp byte ptr [ebx], 4d
    je done

    invalid:
        mov EDX, OFFSET errorMsg
        call WriteString            ;//Error message if the user does not enter a value that is listed
        call WaitMsg
        jmp StartHere

    driver :                        ;//This is the driver that invokes PickAProc
    INVOKE PickAProc, offset userOption, offset phrasetouse, offset keytouse, offset keylength, offset phraselength
    jmp StartHere                   

    Done :
    mov EDX, OFFSET Goodbye         ;//The code will exit here of the user elects to exit the code
    call WriteString

exit
main ENDP

clearRegs PROC;//
;//---------------------------------------------------------
;// clears registers
;// Receives: the registers long enough to clear them
;// Returns: clean registers
;//---------------------------------------------------------	
    mov EAX, 0h
    mov EBX, 0h
    mov ECX, 0h
    mov EDX, 0h
    mov ESI, 0h
    mov EDI, 0h

ret
clearRegs ENDP

DisplayMenu PROC, UserOption1 : DWORD
;//---------------------------------------------------------
;// Displays Menu
;// Receives:
;// Returns:
;//---------------------------------------------------------

.data
    MainMenu BYTE "Main Menu", newLine,
    "1.  Enter a Phrase", newLine,
    "2.  Encrypt Phrase", newLine,
    "3.  Decrypt Phrase", newLine,                   ;//Message block 
    "4.  Exit", newLine,
    "         Please make a selection ==>   ", 0h

.code
    ; push EDX
    mov EDX, OFFSET MainMenu;//string for WriteString in EDX
    call WriteString                                          ;//Simple main menu 
    call ReadDec; user choice for menu - stores in EAX
    mov edx, UserOption1
    mov byte ptr [edx], AL;// MAD
    ; pop EDX; no stack
    mov edx, 0; don't need anymore

ret
DisplayMenu ENDP

PickAProc PROC,
 UserOption2:DWORD, PhraseToUse2:DWORD, KeyToUse2:DWORD, KeyLength2:DWORD, PhraseLength2:DWORD
;//---------------------------------------------------------
;// Sends User to Correct Proc
;// Receives: UserOption from menu thing
;// Returns:
;//---------------------------------------------------------
.data
    invalStr BYTE "NOT A VALID ENTRY, Try Again", newLine, 0h
    ENCSelect BYTE newLine, "YOU HAVE CHOSEN ENCRYPTION!", newLine, 0h
    DECSelect BYTE newLine, "YOU HAVE CHOSEN DECRYPTION!", newLine, 0h
    entString BYTE "Please enter the string you'd like to encrypt", newLine, "==>  ", 0h

.code
    push edx
    mov edx, useroption2
    cmp byte ptr [edx], 1
    jb notValid

    cmp byte ptr [edx], 1;// enter string
    je opt1

    cmp byte ptr [edx], 2;// encryption
    je opt2

    cmp byte ptr [edx], 3;// decryption
    je opt3

    cmp byte ptr [edx], 4;// exit
    je GoBack

    cmp byte ptr [edx], 4;// if above 4 invalid
    ja notValid

    opt1 :
    INVOKE EnterString1, PhraseToUse2, PhraseLength2
    jmp GoBack

    opt2 :
    mov edx, offset ENCSelect
    call writestring
    call crlf
    mov edx, 0
    mov eax, 0                       ;//This label block will invoke encrypt 
    mov eax, 3000
    call delay
    mov eax, 0
    INVOKE Encrypt, PhraseToUse2, PhraseLength2, KeyToUse2, KeyLength2
    jmp GoBack

    opt3 :
    mov edx, offset DECSelect
    call writestring
    call crlf
    mov edx, 0
    mov eax, 0                            ;//This block will invoke decrypt
    mov eax, 3000
    call delay
    mov eax, 0
    ;INVOKE Decrypt, PhraseToUse2, PhraseLength2, KeyToUse2, KeyLength2
    jmp GoBack

    notValid :
    mov dl, invalStr
    call writestring
    mov eax, 0
    mov edx, 0                        ;//If the user does not enter a valid option it will return to the menu
    mov eax, 3000
    call delay
    mov eax, 0
    call ClrScr

    GoBack :
    pop edx
    ret
PickAProc ENDP

AlphaNums  PROC, PhraseToUse5:DWORD, PhraseLength5 : DWORD
;//-------------------------------
;//Removes all non-alphanumeric elements from the phrase
;//-------------------------------
.code
    push EAX
    push ESI
    push ECX

    INVOKE Str_ucase, PhraseToUse5;//irvine procedure
    mov eax, 0
    mov ecx, 0
    mov ebx, phraselength5
    mov cl, byte ptr [ebx]
    AlphaNumLoop:
    mov bl, byte ptr[edx + esi]

    cmp bl, 30h; If ascii character below 30h('0')
    jb remove; Make it blank

    cmp bl, 39h; If ascii character above 39h('9')
    ja inBetweenCheck1; Check if below 41h('A')

    ;// otherwise, continue
    cont:
    inc esi
    loop AlphaNumLoop

    mov edx, phraselength5
    sub byte ptr [edx], al
    pop EAX
    pop ECX;// no stack
    pop ESI;// no stack
    ret

    inBetweenCheck1 :
    cmp bl, 41h;// If ascii character below 41h('A'), BUT above 39h('9')
    jb remove;// Make it blank

    cmp bl, 5Ah;// If ascii character above 5Ah('Z')
    ja inBetweenCheck2;// Check if below 61h('a')

    jmp cont;// otherwise, continue

    inBetweenCheck2:
    cmp bl, 61h;// If ascii character below 61h('a'), BUT above 5Ah('z')
    jb remove;// Make it blank

    cmp bl, 7Ah;// If ascii character above 7Ah('z')
    ja remove;// Make it blank

    jmp cont;// otherwise, continue

    remove:
    inc eax
    push EBX
    push ECX
    push ESI

    ;// Replaces char with what's in front of it for every character in the string
    moveOverLoop:
    mov bl, byte ptr[edx + esi + 1]
    mov byte ptr[edx + esi], bl
    inc esi
    loop moveOverLoop

    pop ESI
    pop ECX
    pop EBX

    dec esi;// Doesn't move ESI as the character has been replaced with character in front of it, which could also be non-alphanum

    jmp cont

    
ret
AlphaNums ENDP 


Encrypt PROC, PhraseToUse3:DWORD, PhraseLength3 : DWORD, KeyToUse3 : DWORD, KeyLength3 : DWORD
;//---------------------------------------------------------
;// Encryption of the Given String
;// Receives: The key from user
;// Returns: The decrypted string
;//---------------------------------------------------------
.code

  push esi
  push edi
  push ecx
  push eax
  push ebx
  push edx

  mov ebx, 0 
  mov edi, KeyToUse3         ;//Moves the offset of the key to edi
  mov esi, Phrasetouse3      ;//Moves the offset of the key to esi

  mov ebx, phraselength3
  mov cl, byte ptr [ebx]      ;//PLaces the legnth of the phrase into ecx for the loop 
  EncryptLoop:
    cmp byte ptr[esi], 41h      ;//Compares the character to see if it is possibly within the paramterts of a letter
    ja LetterUpper              ;//Jumps to check if it satisfies the upper parameter of letter
    jmp Next ;//  
  LetterUpper:                ;//This block checks if the character iterated over is a letter 
    cmp byte ptr[esi], 5Ah      ;// Checks the upper ascii bound of letter
    jb LetterChar               ;//If it is a letter, it will jump 
  jmpNext:                    ;// If it isnt a letter, checks to make sure it is a number


  Next:  
    cmp byte ptr[esi], 30h      ;// Checks the lower bound of number
    ja NumberUpper              ;//
  NumberUpper:                ;//This block checks if the charactert is a number
  cmp byte ptr[esi], 39h      ;//
  jb NumberChar               ;// jumbs to the section where it will encrypt a number               

  LetterChar:
    mov al, [edi]              ;//offset of user key
    mov ah, 0
    push ebx                   ;//ensures we can use ebx as a counter for the iteration of key length
    mov bl, 1Ah                ;// 26
    div bl                     ;//divides so that we can find the mod stored in ah
    pop ebx                    ;//brings back the counter value for the iteration of the key 
    mov dl, [esi]              ;// line 322 you clear ESI
    sub dl, ah                 ;//Subtracts the mod from the letter 
    cmp dl, 41h                ;//Checks to make sure it didnt drop below the lower parameter of letters 
    jb AdjustLet               ;// If it did it will add 1Ah to it
    mov byte ptr[esi], dl      ;// if it was within bounds before correction it will move the encypted letter to the phrase esi location
    jmp Done    
  AdjustLet:
    add dl, 1Ah             ;//Adjustment label
    mov byte ptr[esi], dl
    jmp Done

  NumberChar:
    mov al, [edi]     ;//Does the same stuff as the letter ones but for numbers
    mov ah, 0
    push ebx
    mov bl, 0Ah;// 10
    div bl
    pop ebx
    mov dl, [esi]
    sub dl, ah
    cmp dl, 30h
    jb AdjustNum
    mov byte ptr[esi], dl
    jmp Done
    AdjustNum :
    add dl, 0Ah
    mov byte ptr[esi], dl
    jmp Done


  Done:
    inc esi
    cmp bl, byte ptr [KeyLength3]  ;//Checks if the lkey has been iterated over the full length
    jae ResetEDI   ;//Jumps if it has been
    inc edi
    inc ebx
    jmp TrulyDone

ResetEDI:
mov ebx, 0 ;//Restarts the counter for key iteration
mov edi, KeyToUse3     ;//moves edi back to the beginning of the phrase

TrulyDone:

loop EncryptLoop
  
  pop edx
  pop ebx
  pop eax
  pop ecx
  pop edi
  pop esi
  INVOKE PrintString, PhraseToUse3, PhraseLength3
  ret
Encrypt ENDP

EnterString1 PROC, PhraseToUse3:DWORD, PhraseLength3 : DWORD
;// ------------------
;// returns: PhraseToUse
;// ------------------
.data
  entString3 BYTE "Please enter the string you'd like to encrypt", newLine, "==>  ", 0h

.code
    pushad
    mov edx, 0
    mov ecx, 150d
    mov EDX, OFFSET entString3
    call WriteString
    mov edx, phrasetouse3
    mov eax, 0
    call ReadString
    mov ebx, phraselength3
    mov byte ptr [ebx], al
    INVOKE AlphaNums, PhraseToUse3, PhraseLength3
    popad
    ret
EnterString1 ENDP

StringCheck PROC;//
; PhraseToUse:DWORD, PhraseLength : DWORD
;// -----------------
;// checks to see if they want to use string or enter new one
;//------------------
.data
    wantUse BYTE newLine, "Do you want to use this string?", newline,
    "1.  Yes", newline, "2.  Enter new string", newline,
    "         Please make a selection ==>   ", 0
    invInput BYTE "Please enter 1 or 2.", newline, 0
    ;// make new submenu proc for this??
    .code

    cmp PhraseToUse, 0;// filled with 0s unless it got filled with something
    ja nice

    cmp PhraseToUse, 0;// if = 0, empty
    je nope


    nice :
    mov eax, 0
    mov edx, 0
    ;mov edx, PhraseToUse;//dont use offset here it gets weird
    call writestring
    call crlf
    mov edx, 0

    mov edx, OFFSET wantUse
    call WriteString
    mov edx, 0
    call ReadDec
    cmp eax, 1
    jb invalid

    cmp eax, 1
    je GoBack;//Equivalent to doit, removed doit as it just leads to GoBack anyway

    cmp eax, 2
    je nope

    cmp eax, 2
    ja invalid

    nope :
    ;INVOKE EnterString1, 0, 0
    jmp GoBack

    invalid :
    mov edx, 0
    mov dl, invInput
    call WriteString
    mov edx, 0
    ; INVOKE StringCheck, PhraseToUse, PhraseLength
    ;INVOKE StringCheck, 0, 0
    jmp GoBack

    GoBack :
ret
StringCheck ENDP

EnterKey PROC;//
; KeyToUse:DWORD, KeyLength : DWORD
;// ------------------
;// returns: KeyToUse
;// ------------------
.data
    entKey2 BYTE "Please enter the string you'd like to encrypt", newLine, "==>  ", 0h
    testKey2 BYTE "D3AtH* 2 r0BoTt$", 0h ;//REMOVETHIS ASAP! XD
    ; \\ NOTE: entString and testString have already been defined
    ; \\ these include the 2 in order for that error to be fixed, rename them properly later
    ;//heard that :D
.code
    mov edx, 0
    mov ecx, 150d
    mov EDX, OFFSET entKey2
    call WriteString;
    ; mov edx, 0
    ; mov eax, 0
    call ReadString
    call crlf
    call writestring;//4 checking
    call crlf
    ;mov KeyToUse, edx
    INVOKE Str_length, ADDR KeyToUse
    ;mov KeyLength, DWORD PTR eax; size of the key

ret
EnterKey ENDP

KeyCheck PROC
; KeyToUse:DWORD, KeyLength : DWORD
;// ---------------- -
;// is there a key ? do you want one ?
;// ------------------
.data
    wantUsekey BYTE newLine, "Do you want to use this key?", newLine,
    "1. Yes", newLine, "2. Enter new key (literally do whatever you want)", newLine,
    "         Please make a selection ==>   ", 0
    invInputkey BYTE "Please enter 1 or 2.", newLine, 0
.code
    cmp KeyToUse, 0; filled with 0s unless it got filled with something
    ja nice

    cmp KeyToUse, 0
    je nope


    nice :
    mov eax, 0
    mov edx, 0
    ;mov edx, KeyToUse;//dont use offset here it gets weird
    call writestring
    call crlf
    mov edx, OFFSET wantUsekey
    call WriteString
    call ReadDec
    cmp eax, 1
    jb invalid

    cmp eax, 1
    je GoBack;//Equivalent to doit, removed doit as it just leads to GoBack anyway

    cmp eax, 2
    je nope

    cmp eax, 2
    ja invalid

    nope :
    ;INVOKE EnterKey, KeyToUse, KeyLength
    jmp GoBack

    invalid :
    mov edx, 0
    mov dl, invInputKey
    call WriteString
    mov edx, 0
    ;INVOKE KeyCheck, KeyToUse, KeyLength

    GoBack :
ret
KeyCheck ENDP

Decrypt PROC, PhraseToUse4:DWORD, PhraseLength4 : BYTE, KeyToUse4 : DWORD, KeyLength4 : BYTE;//
;//---------------------------------------------------------
;// Decryption of the Given String
;// Receives: Encrypted phrase
;// Returns: Decrypted phrase
;//---------------------------------------------------------
.code

push esi  
push edi
push ecx  ;//moves current values in registers on the stack
push eax
push ebx
push edx

mov ebx, 0
mov edi, OFFSET KeyToUse   ;//Moves the offset of the key to edi
mov esi, OFFSET PhraseToUse   ;//Moves the offset of the key to esi


mov cl, PhraseLength;//PLaces the legnth of the phrase into ecx for the loop 
EncryptLoop:
cmp byte ptr[esi], 41h;//
ja LetterUpper;//
jmp Next;//  
LetterUpper:;//This block checks if the character iterated over is a letter 
cmp byte ptr[esi], 5Ah;//
jb LetterChar;//
jmpNext:;//


Next:
cmp byte ptr[esi], 30h;//
ja NumberUpper;//
NumberUpper:;//This block checks if the charactert is a number
cmp byte ptr[esi], 39h;//
jb NumberChar;//                

LetterChar:
mov al, [edi]; offset of offset of user key
push ebx  ;//ensures we can use ebx as a counter for the iteration of key length
mov bl, 1Ah;// 26
div bl  ;//
pop ebx   
mov dl, [esi];// line 322 you clear ESI
add dl, 0ah  ;//Adds to the mod so that the encrytion is reversed
cmp dl, 5Ah  ;//Compares to make sure the addition didnt put it over the upper bound of the scii character
ja AdjustLet  ;//If the above it true it will jump
mov byte ptr[esi], dl
jmp Done
AdjustLet :
sub dl, 1Ah           ;//Adjustment block
mov byte ptr[esi], dl
jmp Done

NumberChar :
mov al, [edi]
push ebx
mov bl, 0Ah;// 10
div bl
pop ebx
mov dl, [esi]                ;//This block does the same as the letter block 
add dl, 0ah
cmp dl, 39h
ja AdjustNum
mov byte ptr[esi], dl
jmp Done
AdjustNum :
sub dl, 0Ah
mov byte ptr[esi], dl
jmp Done


Done :

inc esi
cmp bl, KeyLength   ;//Compares to make sure the key repeats if the number of times it has been iterated equals the length
jae ResetEDI
inc edi
inc ebx
jmp TrulyDone

ResetEDI :
mov ebx, 0               ;//For key reset iteration 
mov edi, OFFSET KeyToUse

TrulyDone :

loop EncryptLoop


pop esi
pop edi
pop ecx
pop eax
pop ebx
pop edx



ret
Decrypt ENDP

PrintString PROC, PhraseToUse6:DWORD, PhraseLength6 : DWORD

pushad
mov esi, 0
mov ebx, 0
mov ecx, 0
mov ebx, phraselength6
mov cl, byte ptr [ebx]
mov ebx, 0
mov edx, phrasetouse6
printLoop:
    cmp ebx, 7
    je reset
    mov al, byte ptr [edx+esi]
    call writechar
    jmp go
    reset:
        push ecx
        push edx
        mov ecx, 0 
        mov ecx, 3
        resetLoop:
            mov eax, " "
            call writechar
            loop resetLoop
        pop edx
        pop ecx
    go:
        inc ebx
        inc esi
    loop printLoop
popad

PrintString ENDP

END main
END
TITLE grp8_project.asm
;//Program Description: Cipher Thing
;//Programmed by: Group 8 (Cory, Kye, Phillip, Ivan)
;//Due Date: 12/09/22
INCLUDE Irvine32.inc

;// procedures****************************************************


DisplayMenu PROTO, UserOption1 : DWORD
PickAProc PROTO,  UserOption2:DWORD, PhraseToUse2:DWORD, KeyToUse2:DWORD, KeyLength2:DWORD, PhraseLength2:DWORD
Encrypt PROTO, PhraseToUse3:DWORD, PhraseLength3 : DWORD, KeyToUse3 : DWORD, KeyLength3 : DWORD
;Decrypt PROTO, PhraseToUse4:DWORD, PhraseLength4 : DWORD, KeyToUse4 : DWORD, KeyLength4 : DWORD
EnterString1 PROTO, PhraseToUse3:DWORD, PhraseLength3 : DWORD
AlphaNums  PROTO, PhraseToUse5:DWORD, PhraseLength5 : DWORD
PrintString PROTO, PhraseToUse6:DWORD, PhraseLength6 : DWORD

ClearRegs PROTO

.data

newLine EQU <0ah, 0dh>
errorMsg BYTE "You have selected an invalid option.", newline,   ;//Data block for messages to user
"Please try again.", newline, newLine, 0h
Goodbye BYTE "Goodbye! ", 2, newLine, 0
MaxLength = 150d;// max length for phrase AND key

.code

main PROC
.data
    userOption BYTE 0
    phrasetouse byte 150 dup (?)
    keytouse byte "DOG123",0
    phraselength byte 0
    keylength byte 0
.code
    StartHere :                     ;//Label for the return to the beginnign of the original menu display
    call ClrScr
    INVOKE clearRegs
    mov EBX, OFFSET userOption
    INVOKE DisplayMenu, offset userOption

    cmp byte ptr [ebx], 1d
    jb invalid
    cmp byte ptr [ebx], 4d          ;//Compares users input to determine where to direct it
    jb driver
    cmp byte ptr [ebx], 4d
    je done

    invalid:
        mov EDX, OFFSET errorMsg
        call WriteString            ;//Error message if the user does not enter a value that is listed
        call WaitMsg
        jmp StartHere

    driver :                        ;//This is the driver that invokes PickAProc
    INVOKE PickAProc, offset userOption, offset phrasetouse, offset keytouse, offset keylength, offset phraselength
    jmp StartHere                   

    Done :
    mov EDX, OFFSET Goodbye         ;//The code will exit here of the user elects to exit the code
    call WriteString

exit
main ENDP

clearRegs PROC;//
;//---------------------------------------------------------
;// clears registers
;// Receives: the registers long enough to clear them
;// Returns: clean registers
;//---------------------------------------------------------	
    mov EAX, 0h
    mov EBX, 0h
    mov ECX, 0h
    mov EDX, 0h
    mov ESI, 0h
    mov EDI, 0h

ret
clearRegs ENDP

DisplayMenu PROC, UserOption1 : DWORD
;//---------------------------------------------------------
;// Displays Menu
;// Receives:
;// Returns:
;//---------------------------------------------------------

.data
    MainMenu BYTE "Main Menu", newLine,
    "1.  Enter a Phrase", newLine,
    "2.  Encrypt Phrase", newLine,
    "3.  Decrypt Phrase", newLine,                   ;//Message block 
    "4.  Exit", newLine,
    "         Please make a selection ==>   ", 0h

.code
    ; push EDX
    mov EDX, OFFSET MainMenu;//string for WriteString in EDX
    call WriteString                                          ;//Simple main menu 
    call ReadDec; user choice for menu - stores in EAX
    mov edx, UserOption1
    mov byte ptr [edx], AL;// MAD
    ; pop EDX; no stack
    mov edx, 0; don't need anymore

ret
DisplayMenu ENDP

PickAProc PROC,
 UserOption2:DWORD, PhraseToUse2:DWORD, KeyToUse2:DWORD, KeyLength2:DWORD, PhraseLength2:DWORD
;//---------------------------------------------------------
;// Sends User to Correct Proc
;// Receives: UserOption from menu thing
;// Returns:
;//---------------------------------------------------------
.data
    invalStr BYTE "NOT A VALID ENTRY, Try Again", newLine, 0h
    ENCSelect BYTE newLine, "YOU HAVE CHOSEN ENCRYPTION!", newLine, 0h
    DECSelect BYTE newLine, "YOU HAVE CHOSEN DECRYPTION!", newLine, 0h
    entString BYTE "Please enter the string you'd like to encrypt", newLine, "==>  ", 0h

.code
    push edx
    mov edx, useroption2
    cmp byte ptr [edx], 1
    jb notValid

    cmp byte ptr [edx], 1;// enter string
    je opt1

    cmp byte ptr [edx], 2;// encryption
    je opt2

    cmp byte ptr [edx], 3;// decryption
    je opt3

    cmp byte ptr [edx], 4;// exit
    je GoBack

    cmp byte ptr [edx], 4;// if above 4 invalid
    ja notValid

    opt1 :
    INVOKE EnterString1, PhraseToUse2, PhraseLength2
    jmp GoBack

    opt2 :
    mov edx, offset ENCSelect
    call writestring
    call crlf
    mov edx, 0
    mov eax, 0                       ;//This label block will invoke encrypt 
    mov eax, 3000
    call delay
    mov eax, 0
    INVOKE Encrypt, PhraseToUse2, PhraseLength2, KeyToUse2, KeyLength2
    jmp GoBack

    opt3 :
    mov edx, offset DECSelect
    call writestring
    call crlf
    mov edx, 0
    mov eax, 0                            ;//This block will invoke decrypt
    mov eax, 3000
    call delay
    mov eax, 0
    ;INVOKE Decrypt, PhraseToUse2, PhraseLength2, KeyToUse2, KeyLength2
    jmp GoBack

    notValid :
    mov dl, invalStr
    call writestring
    mov eax, 0
    mov edx, 0                        ;//If the user does not enter a valid option it will return to the menu
    mov eax, 3000
    call delay
    mov eax, 0
    call ClrScr

    GoBack :
    pop edx
    ret
PickAProc ENDP

AlphaNums  PROC, PhraseToUse5:DWORD, PhraseLength5 : DWORD
;//-------------------------------
;//Removes all non-alphanumeric elements from the phrase
;//-------------------------------
.code
    push EAX
    push ESI
    push ECX

    INVOKE Str_ucase, PhraseToUse5;//irvine procedure
    mov eax, 0
    mov ecx, 0
    mov ebx, phraselength5
    mov cl, byte ptr [ebx]
    AlphaNumLoop:
    mov bl, byte ptr[edx + esi]

    cmp bl, 30h; If ascii character below 30h('0')
    jb remove; Make it blank

    cmp bl, 39h; If ascii character above 39h('9')
    ja inBetweenCheck1; Check if below 41h('A')

    ;// otherwise, continue
    cont:
    inc esi
    loop AlphaNumLoop

    mov edx, phraselength5
    sub byte ptr [edx], al
    pop EAX
    pop ECX;// no stack
    pop ESI;// no stack
    ret

    inBetweenCheck1 :
    cmp bl, 41h;// If ascii character below 41h('A'), BUT above 39h('9')
    jb remove;// Make it blank

    cmp bl, 5Ah;// If ascii character above 5Ah('Z')
    ja inBetweenCheck2;// Check if below 61h('a')

    jmp cont;// otherwise, continue

    inBetweenCheck2:
    cmp bl, 61h;// If ascii character below 61h('a'), BUT above 5Ah('z')
    jb remove;// Make it blank

    cmp bl, 7Ah;// If ascii character above 7Ah('z')
    ja remove;// Make it blank

    jmp cont;// otherwise, continue

    remove:
    inc eax
    push EBX
    push ECX
    push ESI

    ;// Replaces char with what's in front of it for every character in the string
    moveOverLoop:
    mov bl, byte ptr[edx + esi + 1]
    mov byte ptr[edx + esi], bl
    inc esi
    loop moveOverLoop

    pop ESI
    pop ECX
    pop EBX

    dec esi;// Doesn't move ESI as the character has been replaced with character in front of it, which could also be non-alphanum

    jmp cont

    
ret
AlphaNums ENDP 


Encrypt PROC, PhraseToUse3:DWORD, PhraseLength3 : DWORD, KeyToUse3 : DWORD, KeyLength3 : DWORD
;//---------------------------------------------------------
;// Encryption of the Given String
;// Receives: The key from user
;// Returns: The decrypted string
;//---------------------------------------------------------
.code

  push esi
  push edi
  push ecx
  push eax
  push ebx
  push edx

  mov ebx, 0 
  mov edi, KeyToUse3         ;//Moves the offset of the key to edi
  mov esi, Phrasetouse3      ;//Moves the offset of the key to esi

  mov ebx, phraselength3
  mov cl, byte ptr [ebx]      ;//PLaces the legnth of the phrase into ecx for the loop 
  EncryptLoop:
    cmp byte ptr[esi], 41h      ;//Compares the character to see if it is possibly within the paramterts of a letter
    ja LetterUpper              ;//Jumps to check if it satisfies the upper parameter of letter
    jmp Next ;//  
  LetterUpper:                ;//This block checks if the character iterated over is a letter 
    cmp byte ptr[esi], 5Ah      ;// Checks the upper ascii bound of letter
    jb LetterChar               ;//If it is a letter, it will jump 
  jmpNext:                    ;// If it isnt a letter, checks to make sure it is a number


  Next:  
    cmp byte ptr[esi], 30h      ;// Checks the lower bound of number
    ja NumberUpper              ;//
  NumberUpper:                ;//This block checks if the charactert is a number
  cmp byte ptr[esi], 39h      ;//
  jb NumberChar               ;// jumbs to the section where it will encrypt a number               

  LetterChar:
    mov al, [edi]              ;//offset of user key
    push ebx                   ;//ensures we can use ebx as a counter for the iteration of key length
    mov bl, 1Ah                ;// 26
    div bl                     ;//divides so that we can find the mod stored in ah
    pop ebx                    ;//brings back the counter value for the iteration of the key 
    mov dl, [esi]              ;// line 322 you clear ESI
    sub dl, ah                 ;//Subtracts the mod from the letter 
    cmp dl, 41h                ;//Checks to make sure it didnt drop below the lower parameter of letters 
    jb AdjustLet               ;// If it did it will add 1Ah to it
    mov byte ptr[esi], dl      ;// if it was within bounds before correction it will move the encypted letter to the phrase esi location
    jmp Done    
  AdjustLet:
    add dl, 1Ah             ;//Adjustment label
    mov byte ptr[esi], dl
    jmp Done

  NumberChar:
    mov al, [edi]     ;//Does the same stuff as the letter ones but for numbers
    push ebx
    mov bl, 0Ah;// 10
    div bl
    pop ebx
    mov dl, [esi]
    sub dl, ah
    cmp dl, 30h
    jb AdjustNum
    mov byte ptr[esi], dl
    jmp Done
    AdjustNum :
    add dl, 0Ah
    mov byte ptr[esi], dl
    jmp Done


  Done:
    inc esi
    cmp bl, byte ptr [KeyLength3]  ;//Checks if the lkey has been iterated over the full length
    jae ResetEDI   ;//Jumps if it has been
    inc edi
    inc ebx
    jmp TrulyDone

ResetEDI:
mov ebx, 0 ;//Restarts the counter for key iteration
mov edi, KeyToUse3     ;//moves edi back to the beginning of the phrase

TrulyDone:

loop EncryptLoop


  pop esi
  pop edi
  pop ecx
  pop eax
  pop ebx
  pop edx
  INVOKE PrintString, PhraseToUse3, PhraseLength3
  ret
Encrypt ENDP

EnterString1 PROC, PhraseToUse3:DWORD, PhraseLength3 : DWORD
;// ------------------
;// returns: PhraseToUse
;// ------------------
.data
  entString3 BYTE "Please enter the string you'd like to encrypt", newLine, "==>  ", 0h

.code
    pushad
    mov edx, 0
    mov ecx, 150d
    mov EDX, OFFSET entString3
    call WriteString
    mov edx, phrasetouse3
    mov eax, 0
    call ReadString
    mov ebx, phraselength3
    mov byte ptr [ebx], al
    INVOKE AlphaNums, PhraseToUse3, PhraseLength3
    popad
    ret
EnterString1 ENDP

StringCheck PROC;//
; PhraseToUse:DWORD, PhraseLength : DWORD
;// -----------------
;// checks to see if they want to use string or enter new one
;//------------------
.data
    wantUse BYTE newLine, "Do you want to use this string?", newline,
    "1.  Yes", newline, "2.  Enter new string", newline,
    "         Please make a selection ==>   ", 0
    invInput BYTE "Please enter 1 or 2.", newline, 0
    ;// make new submenu proc for this??
    .code

    cmp PhraseToUse, 0;// filled with 0s unless it got filled with something
    ja nice

    cmp PhraseToUse, 0;// if = 0, empty
    je nope


    nice :
    mov eax, 0
    mov edx, 0
    ;mov edx, PhraseToUse;//dont use offset here it gets weird
    call writestring
    call crlf
    mov edx, 0

    mov edx, OFFSET wantUse
    call WriteString
    mov edx, 0
    call ReadDec
    cmp eax, 1
    jb invalid

    cmp eax, 1
    je GoBack;//Equivalent to doit, removed doit as it just leads to GoBack anyway

    cmp eax, 2
    je nope

    cmp eax, 2
    ja invalid

    nope :
    ;INVOKE EnterString1, 0, 0
    jmp GoBack

    invalid :
    mov edx, 0
    mov dl, invInput
    call WriteString
    mov edx, 0
    ; INVOKE StringCheck, PhraseToUse, PhraseLength
    ;INVOKE StringCheck, 0, 0
    jmp GoBack

    GoBack :
ret
StringCheck ENDP

EnterKey PROC;//
; KeyToUse:DWORD, KeyLength : DWORD
;// ------------------
;// returns: KeyToUse
;// ------------------
.data
    entKey2 BYTE "Please enter the string you'd like to encrypt", newLine, "==>  ", 0h
    testKey2 BYTE "D3AtH* 2 r0BoTt$", 0h ;//REMOVETHIS ASAP! XD
    ; \\ NOTE: entString and testString have already been defined
    ; \\ these include the 2 in order for that error to be fixed, rename them properly later
    ;//heard that :D
.code
    mov edx, 0
    mov ecx, 150d
    mov EDX, OFFSET entKey2
    call WriteString;
    ; mov edx, 0
    ; mov eax, 0
    call ReadString
    call crlf
    call writestring;//4 checking
    call crlf
    ;mov KeyToUse, edx
    INVOKE Str_length, ADDR KeyToUse
    ;mov KeyLength, DWORD PTR eax; size of the key

ret
EnterKey ENDP

KeyCheck PROC
; KeyToUse:DWORD, KeyLength : DWORD
;// ---------------- -
;// is there a key ? do you want one ?
;// ------------------
.data
    wantUsekey BYTE newLine, "Do you want to use this key?", newLine,
    "1. Yes", newLine, "2. Enter new key (literally do whatever you want)", newLine,
    "         Please make a selection ==>   ", 0
    invInputkey BYTE "Please enter 1 or 2.", newLine, 0
.code
    cmp KeyToUse, 0; filled with 0s unless it got filled with something
    ja nice

    cmp KeyToUse, 0
    je nope


    nice :
    mov eax, 0
    mov edx, 0
    ;mov edx, KeyToUse;//dont use offset here it gets weird
    call writestring
    call crlf
    mov edx, OFFSET wantUsekey
    call WriteString
    call ReadDec
    cmp eax, 1
    jb invalid

    cmp eax, 1
    je GoBack;//Equivalent to doit, removed doit as it just leads to GoBack anyway

    cmp eax, 2
    je nope

    cmp eax, 2
    ja invalid

    nope :
    ;INVOKE EnterKey, KeyToUse, KeyLength
    jmp GoBack

    invalid :
    mov edx, 0
    mov dl, invInputKey
    call WriteString
    mov edx, 0
    ;INVOKE KeyCheck, KeyToUse, KeyLength

    GoBack :
ret
KeyCheck ENDP

Decrypt PROC, PhraseToUse4:DWORD, PhraseLength4 : BYTE, KeyToUse4 : DWORD, KeyLength4 : BYTE;//
;//---------------------------------------------------------
;// Decryption of the Given String
;// Receives: Encrypted phrase
;// Returns: Decrypted phrase
;//---------------------------------------------------------
.code

push esi  
push edi
push ecx  ;//moves current values in registers on the stack
push eax
push ebx
push edx

mov ebx, 0
mov edi, OFFSET KeyToUse   ;//Moves the offset of the key to edi
mov esi, OFFSET PhraseToUse   ;//Moves the offset of the key to esi


mov cl, PhraseLength;//PLaces the legnth of the phrase into ecx for the loop 
EncryptLoop:
cmp byte ptr[esi], 41h;//
ja LetterUpper;//
jmp Next;//  
LetterUpper:;//This block checks if the character iterated over is a letter 
cmp byte ptr[esi], 5Ah;//
jb LetterChar;//
jmpNext:;//


Next:
cmp byte ptr[esi], 30h;//
ja NumberUpper;//
NumberUpper:;//This block checks if the charactert is a number
cmp byte ptr[esi], 39h;//
jb NumberChar;//                

LetterChar:
mov al, [edi]; offset of offset of user key
push ebx  ;//ensures we can use ebx as a counter for the iteration of key length
mov bl, 1Ah;// 26
div bl  ;//
pop ebx   
mov dl, [esi];// line 322 you clear ESI
add dl, 0ah  ;//Adds to the mod so that the encrytion is reversed
cmp dl, 5Ah  ;//Compares to make sure the addition didnt put it over the upper bound of the scii character
ja AdjustLet  ;//If the above it true it will jump
mov byte ptr[esi], dl
jmp Done
AdjustLet :
sub dl, 1Ah           ;//Adjustment block
mov byte ptr[esi], dl
jmp Done

NumberChar :
mov al, [edi]
push ebx
mov bl, 0Ah;// 10
div bl
pop ebx
mov dl, [esi]                ;//This block does the same as the letter block 
add dl, 0ah
cmp dl, 39h
ja AdjustNum
mov byte ptr[esi], dl
jmp Done
AdjustNum :
sub dl, 0Ah
mov byte ptr[esi], dl
jmp Done


Done :

inc esi
cmp bl, KeyLength   ;//Compares to make sure the key repeats if the number of times it has been iterated equals the length
jae ResetEDI
inc edi
inc ebx
jmp TrulyDone

ResetEDI :
mov ebx, 0               ;//For key reset iteration 
mov edi, OFFSET KeyToUse

TrulyDone :

loop EncryptLoop


pop esi
pop edi
pop ecx
pop eax
pop ebx
pop edx



ret
Decrypt ENDP

PrintString PROC, PhraseToUse6:DWORD, PhraseLength6 : DWORD

pushad
mov esi, 0
mov ebx, 0
mov ecx, 0
mov ebx, phraselength6
mov cl, byte ptr [ebx]
mov ebx, 0
mov edx, phrasetouse6
printLoop:
    cmp ebx, 7
    je reset
    mov al, byte ptr [edx+esi]
    call writechar
    jmp go
    reset:
        push ecx
        push edx
        mov ecx, 0 
        mov ecx, 3
        resetLoop:
            mov eax, " "
            call writechar
            loop resetLoop
        pop edx
        pop ecx
    go:
        inc ebx
        inc esi
    loop printLoop
popad

PrintString ENDP

END main
END
