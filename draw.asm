INCLUDE game.inc

.data
txtScore  BYTE "SCORE: ",0
txtLives  BYTE "LIVES: ",0
txtPad    BYTE "   ",0
txtHint   BYTE "A/D move   SPACE shoot   P pause   Q quit",0
shipArt   BYTE "/^\",0
shipBlank BYTE "   ",0

.code
; ---------- PutCharAt: DL = column, DH = row, AL = character ----------
PutCharAt PROC USES eax edx
    push eax                    ; keep AL safe while Gotoxy runs
    call Gotoxy
    pop  eax
    call WriteChar
    ret
PutCharAt ENDP

; ---------- DrawGame: full redraw (start of game, after pause) ----------
DrawGame PROC USES eax ecx edx
    call Clrscr

    mov eax, lightBlue
    call SetTextColor

    ; top and bottom border rows
    mov ecx, FIELD_RIGHT - FIELD_LEFT + 1
    mov dl, FIELD_LEFT
borderRow:
    mov al, '#'
    mov dh, FIELD_TOP
    call PutCharAt
    mov dh, FIELD_BOTTOM
    call PutCharAt
    inc dl
    loop borderRow

    ; left and right border columns
    mov ecx, FIELD_BOTTOM - FIELD_TOP + 1
    mov dh, FIELD_TOP
borderCol:
    mov al, '#'
    mov dl, FIELD_LEFT
    call PutCharAt
    mov dl, FIELD_RIGHT
    call PutCharAt
    inc dh
    loop borderCol

    mov eax, gray
    call SetTextColor
    mWriteAt FIELD_LEFT, FIELD_BOTTOM + 1, txtHint

    call DrawHUD
    call DrawEntities
    ret
DrawGame ENDP

; ---------- DrawHUD: score and lives on row 0 ----------
DrawHUD PROC USES eax edx
    mov eax, yellow
    call SetTextColor
    mWriteAt FIELD_LEFT, 0, txtScore
    mov eax, gameScore
    call WriteDec

    mov eax, lightGreen
    call SetTextColor
    mWriteAt FIELD_RIGHT - 9, 0, txtLives
    mov eax, gameLives
    call WriteDec
    mov edx, OFFSET txtPad
    call WriteString
    ret
DrawHUD ENDP

; ---------- DrawShip / EraseShip ----------
DrawShip PROC USES eax edx
    mov eax, lightCyan
    call SetTextColor
    mov dl, shipX
    dec dl                      ; ship is 3 wide, start one column left
    mov dh, SHIP_Y
    call Gotoxy
    mov edx, OFFSET shipArt
    call WriteString
    ret
DrawShip ENDP

EraseShip PROC USES eax edx
    mov dl, shipX
    dec dl
    mov dh, SHIP_Y
    call Gotoxy
    mov edx, OFFSET shipBlank
    call WriteString
    ret
EraseShip ENDP

; ---------- DrawEntities: enemies, bullets and ship ----------
DrawEntities PROC USES eax ecx edx esi
    mov eax, lightRed           ; enemies
    call SetTextColor
    mov esi, 0
    mov ecx, MAX_ENEMIES
drawEnemy:
    cmp enemyOn[esi], 0
    je  nextDrawEnemy
    mov dl, enemyX[esi]
    mov dh, enemyY[esi]
    mov al, 'W'
    call PutCharAt
nextDrawEnemy:
    inc esi
    loop drawEnemy

    mov eax, lightMagenta       ; enemy shots
    call SetTextColor
    mov esi, 0
    mov ecx, MAX_EBULLETS
drawShot:
    cmp shotOn[esi], 0
    je  nextDrawShot
    mov dl, shotX[esi]
    mov dh, shotY[esi]
    mov al, 'v'
    call PutCharAt
nextDrawShot:
    inc esi
    loop drawShot

    mov eax, yellow             ; our bullets
    call SetTextColor
    mov esi, 0
    mov ecx, MAX_BULLETS
drawBullet:
    cmp bulletOn[esi], 0
    je  nextDrawBullet
    mov dl, bulletX[esi]
    mov dh, bulletY[esi]
    mov al, '|'
    call PutCharAt
nextDrawBullet:
    inc esi
    loop drawBullet

    call DrawShip

    mov dl, 0                   ; park the cursor in the empty top-left corner
    mov dh, 0
    call Gotoxy
    ret
DrawEntities ENDP

END