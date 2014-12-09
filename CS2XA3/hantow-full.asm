; The Towers Of Hanoi 
; x86 Assembly 
; Copyright (C) 2014 Alic Jiang. All Rights Reserved. 
; 
; Tested under nasm 0.97 
; 
; N, the number of disks, is passed to main as argv[1] 
; Error checking is performed.
; The program is distributable with text above.

%include "asm_io.inc"

SECTION .data
   command db "move one disk from peg %d to peg %d", 10, 0

   fmtN: db "Parameter %d",10, 0
   fmtS: db "Parameter %s",10, 0
   t_range: db "Argument out of range", 0
   t_calc: db "Calculating", 0

   outOfRange: db "Argument out of range",10, 0
   tooManyArg: db "Too many arguments",10, 0
   tooLessArg: db "Too less arguments"
   argIncorrect: db "Incorrect argument",10, 0

SECTION .bss
   arr: resd 1
   ele: resd 1
   disk: resd 1
   space: resd 1

   fromPeg: resd 1
   toPeg: resd 1

   peg1: resd 9
   peg2: resd 9
   peg3: resd 9

   pegList: resd 3

SECTION .text
   global  asm_main

   extern read_char
   extern printf
   extern strlen
   extern sys_exit
   extern exit

set_arrays:
   enter 0,0             ; setup routine
   pusha                 ; save all registers

   mov edx, [ebp+8]      ; the parameter, i.e. N
   ; mov eax, edx
   ; call print_int

   mov ebx, dword 2  ; setting peg2

   ; set peg2     
   mov eax, peg2
   L0:
   add eax, 32
   mov [eax], dword 9
   sub eax, 4
   ; in a loop set 0 in the remaining items
   ; eax controls the loop, we end the loop when eax=peg2
   L1: mov [eax], dword 0
   ; see which peg is setting
   cmp ebx, dword 2
   je PEG2
         cmp eax, peg3
   jne NEXT
   jmp L2
   PEG2: cmp eax, peg2
   je L2
   NEXT: sub eax, 4
   jmp L1
   L2:

   inc ebx
   ; peg2 set, now peg3
   cmp ebx, dword 3
   jne PEG1
   mov eax, peg3
   je L0

   PEG1:
   ; set peg1
   mov eax, peg1
   add eax, 32
   mov [eax], dword 9
   sub eax, 4
   ; in a loop set edx in the remaining items
   ; eax controls the loop, we end the loop when eax=peg1
   L3: mov [eax], dword edx ; move edx to the memory location of current element
   cmp eax, peg1
   je L5
   sub eax, 4
   ; if edx > 0, decrement, otherwise keep it 0
   cmp edx, 0
   je L4
   dec edx
   L4: jmp L3
   L5: jmp set_arrays_end

  set_arrays_end:
   popa
   leave
   ret

display_array:
   enter 0,0             ; setup routine
   pusha                 ; save all registers

   display:
      ; ebx points to the beginning of the array
      ; we will use ecx to control the counting loop of 9
      ; edx indicates which array to draw
      ; ecx indecates which element to draw
      ; ebx is the address for that elements
      ; eax is the value to print (elements, spaces, etc)
      mov ecx, dword 1
      mov [arr], dword 0

      ; begin drawing each peg' ecx'th element
      BEGIN:
         cmp ecx, dword 9
         ; exit if ecx > 9
         jg display_array_end
         ; which peg to draw
         COMPARE:   
            mov edx, [arr]
            
            cmp edx, dword 2
            jg NEXT_ELE
            imul edx, dword 4

            mov ebx, dword [pegList+edx]

            DLOOP:
               ; element offset
               mov eax, ecx
               sub eax, dword 1
               imul eax, dword 4
               add eax, ebx
               ; eax has the disk('#') number
               mov eax, dword [eax]
               mov [disk], eax
               mov edx, dword 9
               ; eax has the space(' ') number
               sub edx, eax
               ; save them
               mov [space], edx

               ; the next three lines prints numbers
               ; call print_int
               ; mov eax, ' '
               ; call print_char

               ; the next 60ish lines prints the image
               DRAW_SPACE_1:
                  ; draw the space (' ')
                  cmp [space], dword 0
                  jle DRAW_DISK_1
                  mov eax, ' '
                  call print_char
                  sub [space], dword 1
                  jmp DRAW_SPACE_1

               DRAW_DISK_1:
                 ; draw the disk ('+')
                  cmp [disk], dword 0
                  jle DRAW_PEG
                  cmp ecx, dword 9
                  jne NORM1
                  mov eax, 'X'
                  jmp BASE1
                  NORM1: mov eax, '+'
                  BASE1: call print_char
                  sub [disk], dword 1
                  jmp DRAW_DISK_1

               DRAW_PEG:
                  cmp ecx, dword 9
                  jne NORM2
                  mov eax, 'X'
                  jmp BASE2
                  NORM2: mov eax, '|'
                  BASE2: call print_char

               mov [space], edx
               mov eax, dword 9
               sub eax, edx
               mov [disk], eax
               add [space], dword 5

               DRAW_DISK_2:
                  ; draw the disk ('+')
                  cmp [disk], dword 0
                  jle DRAW_SPACE_2
                  cmp ecx, dword 9
                  jne NORM3
                  mov eax, 'X'
                  jmp BASE3
                  NORM3: mov eax, '+'
                  BASE3: call print_char
                  sub [disk], dword 1
                  jmp DRAW_DISK_2

               DRAW_SPACE_2:
                  ; draw the space (' ')
                  cmp [space], dword 0
                  jle END_DRAW
                  mov eax, ' '
                  call print_char
                  sub [space], dword 1
                  jmp DRAW_SPACE_2

               call print_int
               mov eax, ' '
               call print_char

               END_DRAW:
               add [arr], dword 1
               jmp COMPARE

            NEXT_ELE:
               inc ecx
               mov [arr], dword 0
               call print_nl
               jmp BEGIN
         ; end of COMPARE
      ; end of BEGIN
      display_array_end:
         popa
         leave
         ret
   ; end of display

funcHanoi:
   push ebp
   mov ebp,esp
   ; get n
   mov eax,[ebp+8]
   cmp eax, 0
   jle done
   dec eax
   ; stack for first recursive invocation
   ; to
   push dword [ebp+12]
   ; from
   push dword [ebp+16]
   ; using
   push dword [ebp+20]
   ; n
   push dword eax
   call funcHanoi
   add esp,16
   ; a disk moved, draw it
   ; to
   push dword [ebp+12]
   ; from
   push dword [ebp+16]
   call moveDisk
   add esp,8
   ; get n
   mov eax,[ebp+8]
   dec eax
   ; stack for second recursive invocation
   ; from
   push dword [ebp+16]  
   ; using
   push dword [ebp+20]
   ; to
   push dword [ebp+12]
   ; n
   push dword eax
   call funcHanoi
   add esp,16
done:
   mov esp,ebp
   pop ebp
   ret

moveDisk:
   enter 0,0
   pusha
   ; pause
   call read_char
   ; get arguments
   mov edx, dword [ebp+12]       ; from
   mov ecx, dword [ebp+8]        ; to
   ; offset
   imul edx, dword 4
   imul ecx, dword 4
   ; assign array adresses
   mov eax, dword pegList
   mov edx, [eax+edx]
   mov ecx, [eax+ecx]
   ; save the addresses
   mov [toPeg], edx
   mov [fromPeg], ecx

   ; loop through 'from' peg
   mov ebx, dword 0


   FROM_PEG:
      ; eax is for printing
      ; ebx indicates which element 
      ; ecx is the address offset for that element
      ; edx is to store the element's address

      cmp ebx, dword 8
      jge END_MOVING

      ; set address offset of the element
      mov ecx, dword ebx
      imul ecx, dword 4
;passed

      ; get the array address
      mov edx, dword [fromPeg]

      ; get the edx'th element's address
      add edx, ecx
      ; get the edx'th element
      mov eax, [edx]

      cmp eax, dword 0
      ; if it is 0, continue to next loop
      je FROM_PEG_INC
      ; otherwise take it, and replace it by 0
      mov [edx], dword 0
      ; reset element counter
      mov ebx, dword 0
      ; save the disk number
      mov [disk], eax
      jmp TO_PEG

   FROM_PEG_INC:
      inc ebx
      jmp FROM_PEG

   TO_PEG:
      ; ebx indicates which element 
      ; ecx is the address offset for that element
      ; edx is to store the element's address

      mov ecx, ebx
      imul ecx, dword 4
      ; get the array address
      mov edx, dword[toPeg]
      ; get the edx'th element's address
      add edx, ecx
      ; get the edx'th element
      mov eax, [edx]

      cmp eax, dword 0
      ; next element if it is 0
      je TO_PEG_INC
      ; if it is greater than 0, use the previous element
      sub edx, dword 4
      ; replace it by the disk number from FROM_PEG
      mov eax, [disk]
      mov [edx], eax
      ; leave
      jmp END_MOVING

   TO_PEG_INC:
      inc ebx,
      jmp TO_PEG

   END_MOVING:
      ; draw the array
      call display_array
      popa
      leave
      ret

; argument errors
ERR_TOO_MANY_ARG:
   mov eax, tooManyArg
   jmp ERR_PRINT
ERR_TOO_LESS_ARG:
   mov eax, tooLessArg
   jmp ERR_PRINT
ERR_ARG_INCORRECT:
   mov eax, argIncorrect
   jmp ERR_PRINT
ERR_OUT_OF_RANGE:
   mov eax, outOfRange

ERR_PRINT:
   call print_string
   jmp asm_main_end

asm_main:
   enter 0,0             ; setup routine
   pusha                 ; save all registers

   ; put address of each peg array in pegList
   mov [pegList], dword peg1
   mov [pegList+4], dword peg2
   mov [pegList+8], dword peg3

   ; address of 1st argument = name of the program is at address ebp+12
   ; address of 2nd argument = address of 1st argument + 4

   ; check argument count is 2 (program name and line argument)
   mov eax, dword [ebp+8]
   cmp eax, dword 2
   jg ERR_TOO_MANY_ARG
   jl ERR_TOO_LESS_ARG

   mov eax, dword [ebp+12]   ; put address of first argument into register eax
   add eax, 4                ; increment to get to address of second argument
   mov edx, dword [eax]      ; put value that is in eax into edx
   
   ; check length of string argument is 1 byte
   ; by checking the second byte
   mov bl, byte [edx+1]
   cmp bl, byte 0
   jne ERR_ARG_INCORRECT

   ; convert string to int
   mov ecx, 0
   mov cl, [edx]
   sub ecx, '0'
   mov eax, ecx
   ; remove the 2 parameters
   add esp, 8
   
   ; check if is in range
   cmp eax, 8
   jge ERR_OUT_OF_RANGE
   jg LOWER_BOUND
   LOWER_BOUND:
   cmp eax, 2
   jl ERR_OUT_OF_RANGE

   ; set up the arrays
   push eax
   call set_arrays
   add esp, 4
   ; display initial state
   call display_array
   ; setup stack for funcHanoi
   ; funcHanoi(n, to from, using)
   ; using
   push dword 2
   ; from
   push dword 0
   ; to
   push dword 1
   ; n
   push dword eax   
   call funcHanoi
   add esp,16

 asm_main_end:
   popa                  ; restore all registers
   call exit

