; ============================================================
; dashboard.asm - player dashboard (reads data saved in stats.dat)
; ============================================================
INCLUDE game.inc

.data
dTitle    BYTE "=== PLAYER DASHBOARD ===",0
dHigh     BYTE "High score      : ",0
dGames    BYTE "Games played    : ",0
dKills    BYTE "Enemies killed  : ",0
dShots    BYTE "Shots fired     : ",0
dAcc      BYTE "Accuracy        : ",0
dAvg      BYTE "Average score   : ",0
dPercent  BYTE " %",0
dPlayer   BYTE "Player          : ",0
dRecent   BYTE "Last 5 games (1 = newest)",0
dGameWord BYTE "  Game ",0
dScoreWord BYTE "   score ",0
dNoGames  BYTE "  No games played yet.",0
dFileOk   BYTE "Stats file: stats.dat loaded",0
dFileNew  BYTE "Stats file: stats.dat not found yet (made after your first game)",0
dHelp     BYTE "[N] Change name   [R] Reset all stats   [any other key] Back",0
dConfirm  BYTE "Delete ALL saved stats? Press Y to confirm, any other key to cancel.",0
rowNow    BYTE 0

.code
ShowDashboard PROC USES eax ebx ecx edx esi
dashTop:
    call LoadStats              ; read the file again so the numbers are fresh
    call Clrscr

    mov eax, lightCyan
    call SetTextColor
    mWriteAt 27, 1, dTitle

    ; ---------- totals ----------
    mov eax, lightGreen
    call SetTextColor
    mWriteAt 20, 2, dPlayer
    mov edx, OFFSET statName
    call WriteString
    mov eax, white
    call SetTextColor
    mWriteAt 20, 3, dHigh
    mov eax, statHigh
    call WriteDec
    mWriteAt 20, 4, dGames
    mov eax, statGames
    call WriteDec
    mWriteAt 20, 5, dKills
    mov eax, statKills
    call WriteDec
    mWriteAt 20, 6, dShots
    mov eax, statShots
    call WriteDec

    mWriteAt 20, 7, dAcc
    mov eax, statKills
    mov ebx, statShots
    call CalcPercent            ; kills * 100 / shots
    call WriteDec
    mov edx, OFFSET dPercent
    call WriteString

    mWriteAt 20, 8, dAvg
    mov eax, 0                  ; average = total score / games played
    cmp statGames, 0
    je  showAvg                 ; no games: average stays 0
    mov eax, statScore
    mov edx, 0
    div statGames
showAvg:
    call WriteDec

    ; ---------- last 5 games with a bar chart ----------
    mov eax, yellow
    call SetTextColor
    mWriteAt 20, 10, dRecent
    mov eax, white
    call SetTextColor

    mov rowNow, 11
    mov ecx, statGames          ; how many games to list: min(games, 5)
    cmp ecx, 5
    jbe countOk
    mov ecx, 5
countOk:
    cmp ecx, 0
    jne haveGames
    mWriteAt 20, 11, dNoGames
    jmp showFile

haveGames:
    mov esi, 0                  ; byte offset into statRecent
rowLoop:
    mov dl, 20
    mov dh, rowNow
    call Gotoxy
    mov edx, OFFSET dGameWord
    call WriteString
    mov eax, esi
    shr eax, 2                  ; byte offset / 4 = game index
    inc eax                     ; start counting at 1
    call WriteDec
    mov edx, OFFSET dScoreWord
    call WriteString
    mov eax, statRecent[esi]
    call WriteDec

    mov dl, 48                  ; bar starts at column 48
    mov dh, rowNow
    call Gotoxy
    mov eax, statRecent[esi]
    mov ebx, statHigh
    call CalcPercent            ; 0..100, how close to the high score
    shr eax, 2                  ; 0..25 characters
    push ecx                    ; save the row counter
    mov ecx, eax
    jecxz noBar                 ; zero length: draw nothing
    mov eax, lightGreen
    call SetTextColor
barLoop:
    mov al, '#'
    call WriteChar
    loop barLoop
noBar:
    pop ecx
    mov eax, white
    call SetTextColor
    inc rowNow
    add esi, 4
    dec ecx                     ; (LOOP is too short for this jump)
    jnz rowLoop

    ; ---------- file status and keys ----------
showFile:
    mov eax, gray
    call SetTextColor
    cmp fileFound, 1
    jne fileMissing
    mWriteAt 20, 17, dFileOk
    jmp showHelp
fileMissing:
    mWriteAt 20, 17, dFileNew
showHelp:
    mov eax, yellow
    call SetTextColor
    mWriteAt 20, 20, dHelp
    mov eax, white
    call SetTextColor

    call FlushKeys
    call ReadChar
    or  al, 20h
    cmp al, 'n'
    je  changeName
    cmp al, 'r'
    jne goBack

    mov eax, lightRed           ; R pressed: ask before deleting
    call SetTextColor
    mWriteAt 20, 22, dConfirm
    mov eax, white
    call SetTextColor
    call ReadChar
    or  al, 20h
    cmp al, 'y'
    jne dashTop                 ; cancelled: just redraw
    call ClearStats
    call AskName                ; reset also removed the name, ask again
    call SaveStats              ; write the new stats to the file
    jmp dashTop

changeName:
    call AskName
    call SaveStats
    jmp dashTop

goBack:
    ret
ShowDashboard ENDP

END