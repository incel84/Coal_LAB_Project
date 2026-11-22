; ============================================================
; gameloop.asm - setup, the main game loop, keyboard, pause
; ============================================================
INCLUDE game.inc

.data
pauseMsg1 BYTE "** PAUSED **",0
pauseMsg2 BYTE "Press P to resume",0

.code
; ---------- RunGame: plays one full game ----------
RunGame PROC
    call InitializeGame
    call DrawGame
    call FlushKeys              ; ignore the key used to start the game

gameLoop:
    call UpdateBullets          ; 1. move our bullets up
    call UpdateEnemyBullets     ;    move enemy shots down
    call HandleInput            ; 2. read keys: move, fire, pause, quit
    cmp quitFlag, 1
    je  endGame
    call CheckCollisions        ; 3. our bullets vs enemies, enemy shots vs ship
    call SpawnEnemies           ; 4. maybe add a new enemy
    call UpdateEnemies          ; 5. enemies slide sideways and shoot
    call CheckCollisions        ;    check again after the enemies moved
    call DrawEntities           ; 6. draw enemies, bullets, ship
    cmp gameLives, 0
    je  endGame
    mov eax, FRAME_DELAY
    call Delay                  ; 7. wait, so the game runs at a fixed speed
    jmp gameLoop

endGame:
    call RecordGame             ; update stats and save them to stats.dat
    call ShowGameOver
    ret
RunGame ENDP

; ---------- InitializeGame: reset everything for a new game ----------
InitializeGame PROC USES eax ecx edi
    cld                         ; rep stosb must count upwards
    mov gameScore, 0
    mov gameLives, START_LIVES
    mov gameKills, 0
    mov gameShots, 0
    mov shipX, (FIELD_LEFT + FIELD_RIGHT) / 2
    mov quitFlag, 0
    mov newHigh, 0
    mov spawnTimer, 0
    mov enemyTimer, 0
    mov shotTimer, 0

    mov al, 0                   ; clear the "active" flags of all slots
    mov edi, OFFSET bulletOn
    mov ecx, MAX_BULLETS
    rep stosb
    mov edi, OFFSET enemyOn
    mov ecx, MAX_ENEMIES
    rep stosb
    mov edi, OFFSET shotOn
    mov ecx, MAX_EBULLETS
    rep stosb
    ret
InitializeGame ENDP

; ---------- HandleInput: reads every waiting key without blocking ----------
HandleInput PROC USES eax edx
readNext:
    call ReadKey
    jz   noKey                  ; ZF = 1: no key waiting
    cmp al, 0
    je   readNext               ; arrow / function keys give 0, ignore them
    or  al, 20h                 ; make letters lower case: 'A' -> 'a'
    cmp al, 'a'
    je  doMove
    cmp al, 'd'
    je  doMove
    cmp al, ' '
    je  doFire
    cmp al, 'p'
    je  doPause
    cmp al, 'q'
    je  doQuit
    jmp readNext
doMove:
    call MovePlayer             ; AL tells it left or right
    jmp readNext
doFire:
    call FireBullet
    jmp readNext
doPause:
    call PauseGame
    jmp readNext
doQuit:
    mov quitFlag, 1
noKey:
    ret
HandleInput ENDP

; ---------- PauseGame: wait for P, then redraw the whole screen ----------
PauseGame PROC USES eax edx
    mov eax, yellow
    call SetTextColor
    mWriteAt 33, 11, pauseMsg1
    mWriteAt 31, 12, pauseMsg2
waitP:
    call ReadChar
    or  al, 20h
    cmp al, 'p'
    jne waitP
    call DrawGame               ; the message covered the field, so redraw it
    ret
PauseGame ENDP

END