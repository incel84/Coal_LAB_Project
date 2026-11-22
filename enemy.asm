INCLUDE game.inc

.data
moveNow BYTE 0                  ; 1 = enemies slide sideways this frame

.code
; ---------- SpawnEnemies: every SPAWN_DELAY frames add one enemy at the top ----------
SpawnEnemies PROC USES eax ecx esi
    inc spawnTimer
    cmp spawnTimer, SPAWN_DELAY
    jb  spawnDone               ; not time yet
    mov spawnTimer, 0

    mov esi, 0
    mov ecx, MAX_ENEMIES
findFree:
    cmp enemyOn[esi], 0
    je  foundFree
    inc esi
    dec ecx
    jnz findFree
    jmp spawnDone               ; all enemy slots are busy
foundFree:
    mov eax, INNER_WIDTH
    call RandomRange            ; EAX = 0 .. INNER_WIDTH-1
    add eax, INNER_LEFT         ; turn it into a real column
    mov enemyX[esi], al
    mov enemyY[esi], INNER_TOP  ; always the top row
    mov eax, 2
    call RandomRange            ; 0 or 1 = start sliding left or right
    mov enemyDir[esi], al
    mov enemyOn[esi], 1
spawnDone:
    ret
SpawnEnemies ENDP

; ---------- UpdateEnemies: every frame maybe shoot, every ENEMY_DELAY frames slide ----------
UpdateEnemies PROC USES eax ecx edx esi
    mov moveNow, 0
    inc enemyTimer
    cmp enemyTimer, ENEMY_DELAY
    jb  enemyLoopStart
    mov enemyTimer, 0
    mov moveNow, 1

enemyLoopStart:
    mov esi, 0
    mov ecx, MAX_ENEMIES
nextEnemy:
    cmp enemyOn[esi], 0
    je  skipEnemy

    mov eax, FIRE_CHANCE        ; random 0 .. FIRE_CHANCE-1, shoot when it is 0
    call RandomRange
    cmp eax, 0
    jne noShot
    call FireEnemyBullet        ; ESI = which enemy shoots
noShot:
    cmp moveNow, 0
    je  skipEnemy

    mov dl, enemyX[esi]         ; erase the old spot
    mov dh, enemyY[esi]
    mov al, ' '
    call PutCharAt
    cmp enemyDir[esi], 0
    je  slideLeft

    inc enemyX[esi]             ; slide right
    cmp enemyX[esi], INNER_RIGHT
    jb  skipEnemy
    mov enemyX[esi], INNER_RIGHT    ; hit the wall: stay inside and turn around
    mov enemyDir[esi], 0
    jmp skipEnemy
slideLeft:
    dec enemyX[esi]             ; slide left
    cmp enemyX[esi], INNER_LEFT
    ja  skipEnemy
    mov enemyX[esi], INNER_LEFT
    mov enemyDir[esi], 1
skipEnemy:
    inc esi
    dec ecx                     ; (LOOP is too short for this jump)
    jnz nextEnemy
    ret
UpdateEnemies ENDP

; ---------- FireEnemyBullet: ESI = enemy number, put a shot under it ----------
FireEnemyBullet PROC USES eax ecx edi
    mov edi, 0
    mov ecx, MAX_EBULLETS
findShot:
    cmp shotOn[edi], 0
    je  foundShot
    inc edi
    loop findShot
    jmp fireDone                ; no free slot, enemy holds fire
foundShot:
    mov shotOn[edi], 1
    mov al, enemyX[esi]
    mov shotX[edi], al
    mov al, enemyY[esi]
    inc al                      ; start one row below the enemy
    mov shotY[edi], al
fireDone:
    ret
FireEnemyBullet ENDP

; ---------- UpdateEnemyBullets: every EBULLET_DELAY frames move shots one row down ----------
UpdateEnemyBullets PROC USES eax ecx edx esi
    inc shotTimer
    cmp shotTimer, EBULLET_DELAY
    jb  shotsDone
    mov shotTimer, 0

    mov esi, 0
    mov ecx, MAX_EBULLETS
nextShot:
    cmp shotOn[esi], 0
    je  skipShot
    mov dl, shotX[esi]            ; erase the old spot
    mov dh, shotY[esi]
    mov al, ' '
    call PutCharAt
    inc shotY[esi]                ; move down
    cmp shotY[esi], SHIP_Y
    jbe skipShot
    mov shotOn[esi], 0            ; fell past the ship row: gone
skipShot:
    inc esi
    loop nextShot
shotsDone:
    ret
UpdateEnemyBullets ENDP

END