INCLUDE game.inc

.data
selTitle  BYTE "=== SELECT PLAYER ===",0
selOpen   BYTE "[",0
selClose  BYTE "]  ",0
selEmpty  BYTE "<empty slot - create new player>",0
selBest   BYTE "   best: ",0
selCur    BYTE "   <- playing now",0
selHelp1  BYTE "Press 1 to 5 to choose a player (an empty slot makes a new player)",0
selHelp2  BYTE "Press ESC to go back",0

.code
SelectPlayer PROC USES eax ebx ecx edx esi edi
    call SaveStats              ; make sure the saved list has the latest data
    call Clrscr
    mov eax, lightCyan
    call SetTextColor
    mWriteAt 27, 2, selTitle
    mov eax, white
    call SetTextColor

    mov edi, 0                  ; EDI = slot number 0 .. MAX_PLAYERS-1
    mov esi, 0                  ; ESI = byte offset of that slot in 'profiles'
slotLoop:
    mov dl, 18                  ; row = 5 + slot * 2
    mov eax, edi
    add eax, eax
    add eax, 5
    mov dh, al
    call Gotoxy

    mov edx, OFFSET selOpen     ; "[1]  "
    call WriteString
    mov eax, edi
    add eax, '1'
    call WriteChar
    mov edx, OFFSET selClose
    call WriteString

    cmp DWORD PTR profiles[esi], STATS_MAGIC
    jne emptySlot               ; slot never used
    lea edx, profiles[esi + NAME_OFFSET]
    call WriteString            ; the player's name
    mov edx, OFFSET selBest
    call WriteString
    mov eax, DWORD PTR profiles[esi + 4]    ; second DWORD of a record = high score
    call WriteDec
    jmp afterSlot
emptySlot:
    mov edx, OFFSET selEmpty
    call WriteString
afterSlot:
    cmp edi, curPlayer
    jne nextSlot
    mov edx, OFFSET selCur
    call WriteString
nextSlot:
    add esi, STATS_SIZE
    inc edi
    cmp edi, MAX_PLAYERS
    jb  slotLoop

    mov eax, gray
    call SetTextColor
    mWriteAt 18, 17, selHelp1
    mWriteAt 18, 18, selHelp2
    mov eax, white
    call SetTextColor

    call FlushKeys
waitKey:
    call ReadChar
    cmp al, 27                  ; ESC = go back, no change
    je  selDone
    cmp al, '1'
    jb  waitKey
    cmp al, '1' + MAX_PLAYERS - 1
    ja  waitKey
    sub al, '1'                 ; '3' -> slot 2
    movzx eax, al
    mov curPlayer, eax
    call LoadActive             ; bring that player's stats into the game
    cmp statName[0], 0
    jne selDone                 ; existing player, done
    call AskName                ; empty slot: ask the new player's name
    call SaveStats
selDone:
    ret
SelectPlayer ENDP

END
