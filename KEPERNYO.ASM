;/**************************************************************************\
;*                                                                          *
;*                     Alapvető képernyőkezelő rutinok                      *
;*                                                                          *
;*                                  Írta :                                  *
;*                                                                          *
;*                              Török Viktor                                *
;*                                                                          *
;*                           ANNO DOMINI MCMXCVI                            *
;*                                                                          *
;\**************************************************************************/

;------------------------------ Stackszegmens ------------------------------

_STACK SEGMENT STACK

 db 256 dup (' ')

_STACK ENDS

;------------------------------- Kódszegmens -------------------------------

_CODE SEGMENT

 ASSUME CS : _CODE, DS : _CODE, ES : _CODE, SS : _STACK

;---------------------------------------
; Képernyőtörlés
; Bemenő adatok : dl - a háttérszín
;---------------------------------------

 PUBLIC Clear_Screen

 Clear_Screen PROC

  push ax
  push cx
  push es
  push di

  mov ax,0b800h
  mov es,ax
  mov di,0

  mov al,' '
  mov ah,dl
  mov cx,80*25
  cld

  rep stosw

  pop di
  pop es
  pop cx
  pop ax

  ret

 Clear_Screen ENDP

;-------------------------------
; Kurzor kikapcsolása
;-------------------------------

 PUBLIC CursorOff

 CursorOff PROC

  push ax
  push cx

  mov ah,1
  mov cx,2020h
  int 10h

  pop cx
  pop ax

  ret

 CursorOff ENDP

;-------------------------------
; Kurzor bekapcsolása
;-------------------------------

 PUBLIC CursorOn

 CursorOn PROC

  push ax
  push cx

  mov ah,1
  mov cx,0A0Bh
  int 10h

  pop cx
  pop ax

  ret

 CursorOn ENDP

;--------------------------------------------------
; Szöveg kiírása
;
; Bemenő adatok : BX    - szöveg X koordinátája
;                 CX    - szöveg Y koordinátája   
;                 DS:SI - a szöveg címe
;
; A szöveget 0-val kell lezárni
;--------------------------------------------------

 PUBLIC Write_Text_

 Write_Text_ PROC

  push ax
  push bx
  push cx
  push ds
  push es
  push di
  push si
  push bp

  mov ax,0b800h
  mov es,ax

  mov ax,160
  mul cx
  shl bx,1
  add ax,bx
  mov di,ax

  mov bx,0
  mov bp,0
  mov ah,15

 @Kezdet_ :
  mov al,ds:[si+bx]
  cmp al,0
  je @EXIT_
  mov es:[di+bp],ax
  inc bx
  cmp bx,80
  je @EXIT_
  inc bp
  inc bp
  jmp @Kezdet_

 @EXIT_ :

  pop bp
  pop si
  pop di
  pop es
  pop ds
  pop cx
  pop bx
  pop ax

  ret

 Write_Text_ ENDP

;----------------------------------------------
; Szám kiírása
;
; Bemenő adatok : AX - a szám
;                 BX - a szám X koordinátája
;                 CX - a szám Y koordinátája
;----------------------------------------------

 PUBLIC Write_Number_

 Write_Number_ PROC

  mov si,ax

  mov ax,0b800h
  mov es,ax

  mov ax,160
  mul cx
  mov di,bx
  shl di,1
  add di,ax

  mov ax,si

  mov si,0ah     ; 10-zel osztunk
  mov cx,00h     ; vermelt számjegyek száma

 Nem_nulla :
  mov dx,00h
  div si         ; osztunk
  push dx        ; ez a maradék
  inc cx         ; +1 számjegy
  cmp ax,00h     ; nem fogyott még el?
  jne Nem_nulla

 Kiiras :
  pop dx
  add dx,30h
  add dx,15*256
  mov es:[di],dx
  inc di
  inc di
  loop Kiiras

  ret

 Write_Number_ ENDP

_CODE ENDS

 END
 