;/**************************************************************************\
;*                                                                          *
;*                         Nagyon egyszerű soreditor                        *
;*                                                                          *
;*                                   Írta :                                 *
;*                                                                          *
;*                               Török Viktor                               *
;*                                                                          *
;*                            ANNO DOMINI MCMXCVI                           *
;*                                                                          *
;\**************************************************************************/

_STACK SEGMENT STACK

  db 256 dup (' ')

_STACK ENDS

_CODE SEGMENT

 ASSUME CS : _CODE, SS : _STACK

;------------------------------------------------
; Sorditor eljárás
;
; Paraméterek : DS:SI - a szövegterület címe
;               BX    - x koordináta
;               CX    - y koordináta
;               DL    - a szöveg max.hossza
;               DH    - a beírt szöveg hossza
;------------------------------------------------

 PUBLIC Editor

 Editor PROC

  push ax
  push bx
  push cx
  push es
  push di

  mov ax,0b800h
  mov es,ax

  push dx

  mov ax,160
  mul cx
  mov di,bx
  shl di,1
  add di,ax

  pop dx

  shl dx,1

  mov bx,0

  mov dh,0

 @Ed_kezd :

  mov ah,8
  int 21h

  cmp al,0
  jne @Tova_1

 ; Kettős kódú billentyű
  int 21h
  jmp @Ed_kezd

 @Tova_1 :

  cmp al,13  ; ENTER
  je @Ed_Vege

  cmp al,27
  je @Ed_kezd  ; ESC : ne írja ki

  cmp al,9
  je @Ed_kezd  ; Tab : ne írja ki

  cmp al,8   ; BakcSpace
  jne @Tova_2

  cmp bl,0
  je @Ed_kezd
  dec bx
  dec bx
  mov al,' '
  mov es:[di+bx],al
  jmp @Ed_kezd

 @Tova_2 :

  cmp bx,dx
  je @Ed_kezd

  mov es:[di+bx],al
  shr bx,1
  mov ds:[si+bx],al
  shl bx,1
  inc bx
  inc bx
  jmp @Ed_kezd

 @Ed_vege :

  mov al,0
  shr bx,1
  mov ds:[si+bx],al
  mov dh,bl

  pop di
  pop es
  pop cx
  pop bx
  pop ax

  ret

 Editor ENDP

_CODE ENDS

 END
