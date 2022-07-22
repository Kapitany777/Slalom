;/**************************************************************************\
;*                                                                          *
;*                           Véletlenszámgenerátor                          *
;*                                                                          *
;*                                    Írta :                                *
;*                                                                          *
;*                                Török Viktor                              *
;*                                                                          *
;*                     A C-- programban talált rutin alapján                *
;*                                                                          *
;*                             ANNO DOMINI MCMXCVI                          *
;*                                                                          *
;\**************************************************************************/

_DATA SEGMENT

 RandSeed0 dw 0
 RandSeed1 dw 0

_DATA ENDS

_CODE SEGMENT

 ASSUME CS : _CODE, DS : _DATA

;-------------------------------------
; Random függvény inicializálása
;-------------------------------------

 PUBLIC Randomize

 Randomize PROC

  push ax
  push es
  push di
  push ds

  mov ax,_DATA
  mov ds,ax

  mov ax,0
  mov es,ax
  mov di,046ch
  mov ax,es:[di]
  mov RandSeed0,ax
  mov ax,es:[di+2]
  mov RandSeed1,ax

  pop ds
  pop di
  pop es
  pop ax

  ret

 Randomize ENDP

;-----------------------------------
; Véletlenszámgenerátor
; ax-ben adja vissza a számot
;-----------------------------------

 PUBLIC Random

 Random PROC

  push bx
  push cx
  push ds

  mov ax,_DATA
  mov ds,ax

  mov bx,RandSeed0
  mov cx,RandSeed1
  mov al,bh
  mov bh,bl
  mov bl,ch
  mov ch,cl
  mov cl,0
  rcr al,1
  rcr bx,1
  rcr cx,1
  add cx,RandSeed0
  adc bx,RandSeed1
  add cx,62e9h
  adc bx,3619h
  mov RandSeed0,bx
  mov RandSeed1,cx
  mov ax,bx

  pop ds
  pop cx
  pop bx

  ret

 Random ENDP

_CODE ENDS

 END
