;proj4B
%include "asm_io.inc"

SECTION .data

   err1: db "N too big",10,0
   err: db "incorrect parameter",10,0


SECTION .bss
   arr: resd 1
   ele: resd 1
   disk: resd 1
   space: resd 1

   peg1: resd 9
   peg2: resd 9
   peg3: resd 9

   pegList: resd 3

SECTION .text
   global  asm_main
   extern exit

; subroutine set_arrays
; expects a single parameter on the stack N
; N should be in the range 0 to 8
; if it is not, an error message is displayed and the 
; subroutine terminates
; N is used to set values of peg1
; the array is set from the right end: the last item
; is alwas set to 9, the previous one to N, the previous one to N-1
; etc. until 0 and it is continued with 0.
; E.g. if N=0, then peg1 is set to 0,0,0,0,0,0,0,0,9
; if N=1, then peg1 is set to 0,0,0,0,0,0,0,1,9
; if N=2, then peg1 is set to 0,0,0,0,0,0,1,2,9
; if N=3, then peg1 is set to 0,0,0,0,0,1,2,3,9
; etc.
; if N=8, then peg1 is set to 1,2,3,4,5,6,7,8,9

set_arrays:
   enter 0,0             ; setup routine
   pusha                 ; save all registers

   mov edx, [ebp+8]      ; the parameter, i.e. N
   cmp edx, dword 8      ; check it
   ja Nerr

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
   
   Nerr:
   mov eax, err1
   call print_string

  set_arrays_end:
   popa
   leave
   ret


; subroutine display_array
; expects one parameter on stack, either index 1 or 2
; if it is 1 or 2, it displays the contents of peg1 or peg2
; seperated by space
; otherwise it displays error message and terminate
display_array:
   enter 0,0             ; setup routine
   pusha                 ; save all registers

   ; mov eax, [ebp+8]      ; the parameter
   ; cmp eax, dword 1
   ; jne NOT1
   ; ; so it is 1
   ; mov ebx, peg1
   ; jmp display
   ; NOT1: cmp eax, dword 2
   ; jne NOT2
   ; ; so it is 2
   ; mov ebx, peg2
   ; jmp display
   ; NOT2: cmp eax, dword 3
   ; jne NOT3
   ; ; so it is 3
   ; mov ebx, peg3
   ; jmp display
   ; NOT3:       ; so it is neither 1 nor 2 nor 3
   ; mov eax, err
   ; call print_string
   ; jmp display_array_end

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

            ; mov eax, 'e'
            ; call print_char
            ; mov eax, ecx
            ; call print_int
            ; call print_nl


         ; which peg to draw
         COMPARE:   
            mov edx, [arr]
            ; mov eax, edx
            ; call print_int

            cmp edx, dword 2
            jg NEXT_ELE
            imul edx, dword 4
            ; mov eax, edx
            ; call print_int
            mov ebx, dword [pegList+edx]

            DLOOP:
               ; mov eax, 'p'
               ; call print_char
               ; mov eax, edx
               ; call print_int
               ; mov eax, ' '
               ; call print_char

               ; element offset
               mov eax, ecx
               sub eax, dword 1
               imul eax, dword 4
               add eax, ebx
               ; eax has the disk number
               mov eax, dword [eax]
               mov [disk], eax
               mov edx, dword 9
               ; eax has the space number
               sub edx, eax
               ; save them
               mov [space], edx

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


               ; call print_int
               ; mov eax, ' '
               ; call print_char

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

asm_main:
   enter 0,0             ; setup routine
   pusha                 ; save all registers

   ; put address of each peg array in pegList
   mov [pegList], dword peg1
   mov [pegList+4], dword peg2
   mov [pegList+8], dword peg3

   ; address of 1st argument = name of the program is at address ebp+12
   ; address of 2nd argument = address of 1st argument + 4

   mov eax, dword [ebp+12]   ; put address of first argument into register eax
   add eax, 4                ; increment to get to address of second argument
   mov edx, dword [eax]      ; put value that is in eax into edx
   
   ; convert string to int and then print
   mov ecx, 0
   mov cl, byte [edx]
   sub ecx, '0'    ;convert to int
   mov eax, ecx
   call print_int
   call print_nl
   add esp, 8                ; remove the 2 parameters

   push ecx
   call set_arrays
   add esp, 4

   call display_array
   add esp, 4

 asm_main_end:
   popa                  ; restore all registers
   leave                     
   ret
   call exit
