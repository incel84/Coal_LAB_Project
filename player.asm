INCLUDE game.inc

.code
; ---------- MovePlayer: AL = 'a' (left) or 'd' (right) ----------
MovePlayer PROC USES eax edx
    cmp al, 'a'
    je  goLeft
    cmp al, 'd'
    je  goRight
    jmp moveDone
goLeft:
    cmp shipX, SHIP_MIN_X
    jle moveDone                ; already at the left border
    call EraseShip              ; wipe the old picture first
    dec shipX
    jmp moveDone
goRight:
    cmp shipX, SHIP_MAX_X
    jge moveDone                ; already at the right border
    call EraseShip
    inc shipX
moveDone:
    ret
MovePlayer ENDP

; ---------- FireBullet: put a bullet in the first free slot ----------
FireBullet PROC USES eax ecx esi
    mov esi, 0
    mov ecx, MAX_BULLETS
findSlot:
    cmp bulletOn[esi], 0
    je  foundSlot
    inc esi
    loop findSlot
    jmp fireDone                ; all slots busy, no shot
foundSlot:
    mov bulletOn[esi], 1
    mov al, shipX
    mov bulletX[esi], al        ; bullet starts above the ship's middle
    mov bulletY[esi], SHIP_Y - 1
    inc gameShots
fireDone:
    ret
FireBullet ENDP

; ---------- UpdateBullets: move every active bullet one row up ----------
UpdateBullets PROC USES eax ecx edx esi
    mov esi, 0
    mov ecx, MAX_BULLETS
nextBullet:
    cmp bulletOn[esi], 0
    je  skipBullet
    mov dl, bulletX[esi]        ; erase the old spot
    mov dh, bulletY[esi]
    mov al, ' '
    call PutCharAt
    dec bulletY[esi]            ; move up
    cmp bulletY[esi], INNER_TOP
    jge skipBullet
    mov bulletOn[esi], 0        ; went past the top, free the slot
skipBullet:
    inc esi
    loop nextBullet
    ret
UpdateBullets ENDP

END
