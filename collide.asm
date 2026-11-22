INCLUDE game.inc

.code
CheckCollisions PROC USES eax ebx ecx edx esi edi
    ; ---------- part 1: bullets against enemies ----------
    mov esi, 0                  ; ESI = bullet number
    mov ecx, MAX_BULLETS
bulletLoop:
    cmp bulletOn[esi], 0
    je  nextBullet
    push ecx                    ; the inner loop also needs ECX
    mov edi, 0                  ; EDI = enemy number
    mov ecx, MAX_ENEMIES
enemyLoop:
    cmp enemyOn[edi], 0
    je  nextEnemy
    mov al, bulletX[esi]        ; same column?
    cmp al, enemyX[edi]
    jne nextEnemy
    mov al, bulletY[esi]        ; same row?
    cmp al, enemyY[edi]
    jne nextEnemy
    mov bulletOn[esi], 0        ; HIT: remove both
    mov enemyOn[edi], 0
    mov dl, enemyX[edi]
    mov dh, enemyY[edi]
    mov al, ' '
    call PutCharAt              ; wipe it from the screen
    call UpdateScore            ; +10 points
    jmp bulletFinished
nextEnemy:
    inc edi
    loop enemyLoop
bulletFinished:
    pop ecx
nextBullet:
    inc esi
    loop bulletLoop

    ; ---------- part 2: enemy shots against the ship ----------
    ; Ship covers columns shipX-1 .. shipX+1 on row SHIP_Y.
    mov edi, 0
    mov ecx, MAX_EBULLETS
shipLoop:
    cmp shotOn[edi], 0
    je  nextShip
    cmp shotY[edi], SHIP_Y
    jne nextShip
    movzx eax, shotX[edi]
    movzx ebx, shipX
    sub eax, ebx                ; column difference: -1, 0, +1 means a hit
    add eax, 1                  ; now 0, 1, 2 means a hit
    cmp eax, 2
    ja  nextShip                ; unsigned compare: negative numbers are huge
    mov shotOn[edi], 0            ; HIT: the shot is gone, we lose a life
    mov dl, shotX[edi]
    mov dh, shotY[edi]
    mov al, ' '
    call PutCharAt
    call UpdateLives
nextShip:
    inc edi
    dec ecx                     ; (LOOP is too short for some jumps)
    jnz shipLoop
    ret
CheckCollisions ENDP

END