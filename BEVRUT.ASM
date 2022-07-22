;/**************************************************************************\
;*                                                                          *
;*                    SLALOM játékprogram néhány rutinja                    *
;*                                                                          *
;*                                   Írta :                                 *
;*                                                                          *
;*                               Török Viktor                               *
;*                                                                          *
;*                            ANNO DOMINI MCMXCVI                           *
;*                                                                          *
;\**************************************************************************/

;-------------------------------- Adatszegmens -----------------------------

_DATA SEGMENT

 BIGX dw 0         ; a szöveg X koordinátája

 BIGY dw 0         ; a szöveg Y koordinátája

 kseg dw 0
 kofs dw 0

 cim dw 0

 pl dw 4

_DATA ENDS

;------------------------------ Stackszegmens ------------------------------

_STACK SEGMENT STACK

 db 256 dup (' ')

_STACK ENDS

;------------------------------- Kódszegmens --------------------------------

_CODE SEGMENT

 ASSUME CS : _CODE, DS : _DATA, ES : _CODE; SS : _STACK

;***************************************************
; Nagy karakterek kiírása
;
; Bemenő adatok : BX    - a szöveg X koordinátája
;                 CX    - a szöveg Y koordinátája
;                 ES:DI - a szöveg címe
;
; A szöveget 0-val kell lezárni.
;***************************************************

 PUBLIC Write_Big_Text

 ;--------------------------------------
 ; Karakterkészlet címének lekérdezése
 ;--------------------------------------

 Karakterek_cime PROC

  push es
  push bp

  mov ax,1130h
  mov bh,3
  int 10h

  mov kseg,es
  mov kofs,bp

  pop bp
  pop es

  ret

 Karakterek_cime ENDP

 ;--------------------------------------
 ; Egy karakter kiírása
 ; Bemenő adatok : al - karakter kódja
 ;                 bx - pozíció
 ;--------------------------------------

 Karakter_kiirasa PROC

  push ax
  push bx
  push cx
  push dx
  push es
  push ds
  push di
  push si
  push bp

  mov ah,0
  mov dx,8
  mul dx
  mov cim,ax

  mov ax,0b800h
  mov es,ax

  mov ax,160
  mul BIGY
  mov di,BIGX
  shl bx,3
  add di,bx
  shl di,1
  add di,ax

  mov si,kofs
  add si,cim
  mov ds,kseg

  mov dl,'█'
  mov cx,8

 @E :
  mov bx,0
  mov bp,0
  mov al,ds:[si]

 @A :
  mov dh,0
  shl al,1
  jnc @T

  mov dh,15

 @T :
  mov es:[di+bp],dx

  inc bp
  inc bp
  inc bx
  cmp bx,8
  jne @A

  add di,160
  inc si
  loop @E

  pop bp
  pop si
  pop di
  pop ds
  pop es
  pop dx
  pop cx
  pop bx
  pop ax

  ret

 Karakter_kiirasa ENDP

 ;----------------------------------
 ; A szövegkiíró eljárás
 ;----------------------------------

 Write_Big_Text PROC

  push ax
  push bx
  push ds
  push es
  push di

  mov ax,_DATA
  mov ds,ax

  mov BIGX,bx
  mov BIGY,cx

  call Karakterek_cime

  mov bx,0

 @Kezdet :
  mov al,es:[di+bx]
  cmp al,0
  je @EXIT
  call Karakter_kiirasa

  inc bx
  cmp bx,10
  je @EXIT

  jmp @Kezdet

 @EXIT :

  pop di
  pop es
  pop ds
  pop bx
  pop ax

  ret

 Write_Big_Text ENDP

;*******************************
; Rasztercsík rajzolása
;*******************************

 ;--------------------------------------
 ; Várakozás az elektronsugárra
 ;--------------------------------------

 RasterWait PROC

  push ax
  push dx

  mov dx,03dah
 @V :
  in al,dx
  test al,8
  je @V

  pop dx
  pop ax

  ret

 RasterWait ENDP

 ;--------------------------------------
 ; Vízszintes visszafutás
 ;--------------------------------------

 HorizRasterWait PROC

  push ax
  push dx

  mov dx,03dah

 @AA :
  in al,dx
  test al,1
  jne @AA

 @B :
  in al,dx
  test al,1
  je @B

  pop dx
  pop ax

  ret

 HorizRasterWait ENDP

 ;-------------------------------
 ; Rasztercsík rajzolása
 ;-------------------------------

 PUBLIC Raster_

 Raster_ PROC

  push ax
  push bx
  push cx
  push dx
  push ds

  cli   	       ; Megszakítások tiltása

  mov ax,_DATA
  mov ds,ax

  mov cx,10

 @Eleje :

  call RasterWait

  push cx

 @HW :
  call HorizRasterWait   ; cx-szer várunk a vízszintes visszafutásra
  loop @HW

  pop cx

  mov bx,0

 @PL1 :                       ; A paletta állítása
  mov dx,03c8h
  mov al,0
  out dx,al

  mov dx,03c9h
  mov al,bl
  out dx,al
  mov al,0
  out dx,al

  call HorizRasterWait

  out dx,al

  inc bx
  cmp bx,64
  jne @PL1

  mov bx,63

 @PL2 :                ; Ismét állítjuk a palettát
  mov dx,03c8h
  mov al,0
  out dx,al

  mov dx,03c9h
  mov al,bl
  out dx,al
  mov al,0
  out dx,al

  call HorizRasterWait

  out dx,al

  dec bx
  jnz @PL2

  call HorizRasterWait

  mov dx,03c8h                ; Ezentúl fekete szín kell
  mov al,0
  out dx,al

  mov dx,03c9h
  out dx,al
  out dx,al
  out dx,al

  add cx,pl                   ; cx változtatása
  
  cmp cx,10
  ja @Tovabb
  mov ax,4
  mov pl,ax
  jmp @Bill

 @Tovabb :
  cmp cx,260
  jb @Bill
  mov ax,-4
  mov pl,ax 

 @Bill :
  in al,60h                  ; SPACE-re kilépünk
  cmp al,57
  jne @Eleje

  sti                        ; Megszakítások engedélyezése

  pop ds
  pop dx
  pop cx
  pop bx
  pop ax

  ret

 Raster_ ENDP

_CODE ENDS

 END
