;/**************************************************************************\
;*                                                                          *
;*                         SLALOM játékprogram V1.0                         *
;*                                                                          *
;*                                  Írta :                                  *
;*                                                                          *
;*                              Török Viktor                                *
;*                                                                          *
;*                           ANNO DOMINI MCMXCVI                            *
;*                                                                          *
;\**************************************************************************/

;------------------------------ Stackszegmens -------------------------------

STACK_SEG SEGMENT STACK

 db 256 dup (' ')

STACK_SEG ENDS

;------------------------------ Adatszegmens --------------------------------

DATA_SEG SEGMENT

 Bevezeto_szoveg db 'SLALOM',0

 Iro_neve db 'Written by Török Viktor',0
 Datum    db 'ANNO DOMINI MCMXCVI',0
 Tovabb   db 'Press Space to continue...',0

 NehFokSz db 'Choose the difficulty level, please :',0
 NehF1    db '1 : Easy',0
 NehF2    db '2 : Medium',0
 NehF3    db '3 : Hard',0

 NehFok dw 10  ; A játék nehézségi fokozata

 pos dw 0  ; Pályageneráló rutin segédváltozója

 Your  db 'Your',0
 Score db 'score :',0
 Grat  db 'Congratulations',0
 scr   dw 0  ; A pontszámot tartalmazó változó

 Name_text db 'Please enter your name :',0
 Name_     db 22 dup (?)
 Namlen    db 0

 xk dw 0
 yk dw 0  ; A játékos koordinátái
 pl dw 0  ; A pályán megtett út  

DATA_SEG ENDS

;------------------------------- Kódszegmens --------------------------------

CODE_SEG SEGMENT

 ASSUME CS : CODE_SEG, DS : DATA_SEG, SS : STACK_SEG, ES : CODE_SEG

 EXTRN Clear_Screen : PROC, Write_Big_Text : PROC
 EXTRN CursorOn : PROC, CursorOff : PROC, Raster_ : PROC, Write_Text_ : PROC
 EXTRN Randomize : PROC, Random : PROC, Write_Number_ : PROC
 EXTRN Editor : PROC

 Palyahossz EQU 1000

;****************************************
; A bevezető képsor
;****************************************

 Bevezeto_kepek PROC

  mov dl,15
  call Clear_Screen

  call CursorOff

  push ds
  pop es
  mov di,offset Bevezeto_szoveg

  mov bx,17
  mov cx,4
  call Write_Big_Text

  mov bx,30
  mov cx,15
  lea si,Iro_neve
  call Write_Text_

  mov bx,32
  mov cx,17
  lea si,Datum
  call Write_Text_

  mov bx,29
  mov cx,19
  lea si,Tovabb
  call Write_Text_

  call Raster_

  ret

 Bevezeto_kepek ENDP

;*********************************************
; A játék nehézségi fokozatának kiválasztása
;*********************************************

 Nehezsegi_fokozat PROC

  mov dl,15
  call Clear_Screen

  mov bx,1
  mov cx,1
  lea si,NehFokSz
  call Write_Text_

  mov bx,2
  mov cx,3
  lea si,NehF1
  call Write_Text_

  mov cx,5
  lea si,NehF2
  call Write_Text_

  mov cx,7
  lea si,NehF3
  call Write_Text_

 @Neh_bill :
  mov ah,8
  int 21h

  cmp al,'1'
  jne @T1
  mov ax,15
  mov NehFok,ax
  jmp @Neh_kilep

 @T1 :
  cmp al,'2'
  jne @T2
  mov ax,10
  mov NehFok,ax
  jmp @Neh_kilep

 @T2 :
  cmp al,'3'
  jne @Neh_bill
  mov ax,5
  mov NehFok,ax

 @Neh_kilep :

  ret

 Nehezsegi_fokozat ENDP

;**************************************
; A játékos nevének bekérése
;**************************************

 Nev_bekerese PROC

  push bx
  push cx
  push dx
  push si

  mov dl,15
  call Clear_Screen

  mov bx,4
  mov cx,2
  lea si,Name_text
  call Write_Text_

  mov bx,29
  mov cx,2
  mov dx,20
  lea si,Name_
  call Editor

  mov Namlen,dh

  pop si
  pop dx
  pop cx
  pop bx

  ret

 Nev_bekerese ENDP

;**************************************
; Alappálya kirajzolása
;**************************************

 Slalom_alappalya PROC

  mov ax,0b800h
  mov es,ax
  mov di,0
  mov cx,80*25

  cld

  mov ax,176+(15+16)*256

  rep stosw

  call Randomize

  mov ax,35
  mov pos,ax

  mov cx,0

 @Palya_eleje :

  call Random
  and ax,3

  cmp ax,0
  jne @P_T1
  dec pos
  jmp @P_R

 @P_T1 :
  cmp ax,1
  jne @P_R
  inc pos

 @P_R :

  mov ax,cx
  mov bx,160
  mul bx
  mov di,pos
  shl di,1
  add di,ax

  mov es:[di],219+15*256

  push cx

  inc di
  inc di
  mov ax,32+(15+3*16)*256
  mov cx,NehFok
  rep stosw

  pop cx

  mov es:[di],219+15*256

  inc cx
  cmp cx,25
  jne @Palya_eleje

  mov di,80+12*160
  mov es:[di],'#'+15*256

  ret

 Slalom_alappalya ENDP

;***************************************
; A képernyő görgetését végző eljárás
;***************************************

 Gorget PROC

  push ax
  push cx
  push ds
  push di
  push si

  mov ax,0b800h
  mov es,ax
  mov di,0
  mov ds,ax
  mov si,160
  mov cx,80*24
  cld

  rep movsw

  pop si
  pop di
  pop ds
  pop cx
  pop ax

  ret

 Gorget ENDP

;************************************
; A játékot kezelő eljárás
;************************************

 Jatek PROC

  mov ax,40
  mov xk,ax
  mov ax,12
  mov yk,ax
  mov ax,0
  mov scr,ax
  mov pl,0

  mov ax,0b800h
  mov es,ax

  call Randomize

  cli

 @Jatek_eleje :

  mov ax,160
  mul yk
  mov di,xk
  shl di,1
  add di,ax

  mov es:[di],' '+(15+16)*256

  call Gorget
  inc pl

  mov di,pos
  shl di,1
  add di,24*160
  mov es:[di],176+(15+16)*256

  call Random
  and ax,3

  cmp ax,0
  jne @J_T1
  cmp pos,0
  je @J_V
  dec pos
  jmp @J_V

 @J_T1 :
  cmp ax,1
  jne @J_V
  cmp pos,63
  je @J_V
  inc pos
  jmp @J_V

 @J_V :

  mov di,pos
  shl di,1
  add di,24*160

  mov es:[di],219+15*256

  inc di
  inc di

  mov ax,32+(15+3*16)*256
  mov cx,NehFok
  rep stosw

  mov es:[di],219+15*256
  mov es:[di+2],176+(15+16)*256

  in al,60h

  cmp al,32             ; 'd' billentyű lenyomása
  jne @B_T1
  cmp xk,0
  je @Jatek_tovabb
  dec xk
  jmp @Jatek_tovabb

 @B_T1 :
  cmp al,38             ; 'l' billentyű lenyomása
  jne @B_T2
  cmp xk,78
  je @Jatek_tovabb
  inc xk
  jmp @Jatek_tovabb

 @B_T2:                 ; Esc billentyű lenyomása
  cmp al,1
  je @Jatek_vege

 @Jatek_tovabb :

  mov ax,160
  mul yk
  mov di,xk
  shl di,1
  add di,ax

  mov al,es:[di]
  cmp al,' '
  jne @J_K
  inc scr

 @J_K :
  mov es:[di],'#'+(15+5*16)*256

  mov cx,65535

 @Delay :
  nop
  nop
  loop @Delay

  cmp pl,Palyahossz           ; A pálya véget ért
  je @Jatek_vege

  jmp @Jatek_eleje

 @Jatek_vege :

  sti

; Itt jön a pontozás

  mov dl,15
  call Clear_Screen

  push ds
  pop es

  mov di,offset Your
  mov bx,24
  mov cx,5
  call Write_Big_Text

  mov di,offset Score
  mov bx,17
  mov cx,13
  call Write_Big_Text

  mov ax,scr
  mov bx,38
  mov cx,23
  call Write_Number_

  mov al,Namlen
  mov ah,0
  mov bx,64
  sub bx,ax
  shr bx,1
  mov cx,2
  lea si,Grat
  call Write_Text_

  add bx,16
  mov cx,2
  lea si,Name_
  call Write_Text_

  cli

 @J_Bill :
  in al,60h
  cmp al,57
  jne @J_Bill

  sti

  ret

 Jatek ENDP

;************************************
; A főprogram
;************************************

 START :

  mov ax,DATA_SEG
  mov ds,ax

  mov ax,3
  int 10h

  call Bevezeto_kepek

  call Nehezsegi_fokozat

  call Nev_bekerese

  call Slalom_alappalya

  call Jatek

  call CursorOn

  mov dl,15
  call Clear_Screen

  mov ah,4ch
  int 21h

CODE_SEG ENDS

 END START
