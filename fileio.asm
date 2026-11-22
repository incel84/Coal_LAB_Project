INCLUDE game.inc

.data
statsFileName BYTE "stats.dat",0
fileHandle    DWORD 0
bytesRead     DWORD 0

.code
; ---------- ClearStats: empty the CURRENT player's stats (memory only) ----------
ClearStats PROC USES eax ecx edi
    cld
    mov edi, OFFSET statMagic
    mov ecx, STATS_SIZE
    mov al, 0
    rep stosb                   ; zero the whole record, name included
    mov statMagic, STATS_MAGIC  ; mark the slot as used
    ret
ClearStats ENDP

; ---------- LoadActive: copy the current player's record into the stat fields ----------
LoadActive PROC USES eax ecx esi edi
    cld
    imul eax, curPlayer, STATS_SIZE ; byte offset of the slot
    mov esi, OFFSET profiles
    add esi, eax
    mov edi, OFFSET statMagic
    mov ecx, STATS_SIZE
    rep movsb
    cmp statMagic, STATS_MAGIC
    je  activeOk
    call ClearStats             ; slot was never used: start empty
activeOk:
    ret
LoadActive ENDP

; ---------- StoreActive: copy the stat fields back into the current player's record ----------
StoreActive PROC USES eax ecx esi edi
    cld
    imul eax, curPlayer, STATS_SIZE
    mov edi, OFFSET profiles
    add edi, eax
    mov esi, OFFSET statMagic
    mov ecx, STATS_SIZE
    rep movsb
    ret
StoreActive ENDP

; ---------- ClearAll: forget every player (memory only) ----------
ClearAll PROC USES eax ecx edi
    cld
    mov edi, OFFSET fileMagic
    mov ecx, FILE_SIZE
    mov al, 0
    rep stosb
    mov fileMagic, FILE_MAGIC
    mov curPlayer, 0
    call LoadActive             ; slot 0 is empty, so this clears the stat fields
    ret
ClearAll ENDP

; ---------- LoadStats: read stats.dat, or start empty if it is missing/bad ----------
LoadStats PROC USES eax ecx edx
    mov fileFound, 0
    mov edx, OFFSET statsFileName
    call OpenInputFile          ; EAX = handle
    cmp eax, INVALID_HANDLE_VALUE
    je  startEmpty              ; no file yet

    mov fileHandle, eax
    mov edx, OFFSET fileMagic   ; read straight into the file block
    mov ecx, FILE_SIZE
    call ReadFromFile           ; EAX = bytes read, CF = 1 on error
    mov bytesRead, eax          ; (MOV does not change the carry flag)
    jc  badFile

    mov eax, fileHandle
    call CloseFile
    cmp bytesRead, FILE_SIZE    ; file must be complete ...
    jne startEmpty
    cmp fileMagic, FILE_MAGIC   ; ... and must be our file
    jne startEmpty
    cmp curPlayer, MAX_PLAYERS  ; ... with a sensible current player
    jae startEmpty
    mov fileFound, 1
    call LoadActive             ; fill the stat fields for the current player
    ret

badFile:
    mov eax, fileHandle
    call CloseFile
startEmpty:
    call ClearAll
    ret
LoadStats ENDP

; ---------- SaveStats: write all players to stats.dat ----------
SaveStats PROC USES eax ecx edx
    call StoreActive            ; current player's latest data goes into the array
    mov fileMagic, FILE_MAGIC
    mov edx, OFFSET statsFileName
    call CreateOutputFile       ; makes the file, or empties an old one
    cmp eax, INVALID_HANDLE_VALUE
    je  saveDone                ; could not create it, skip quietly

    mov fileHandle, eax
    mov edx, OFFSET fileMagic
    mov ecx, FILE_SIZE
    call WriteToFile
    mov eax, fileHandle
    call CloseFile
saveDone:
    ret
SaveStats ENDP

; ---------- RecordGame: add the finished game to this player's stats and save ----------
RecordGame PROC USES eax ecx esi
    inc statGames
    mov eax, gameKills
    add statKills, eax
    mov eax, gameShots
    add statShots, eax
    mov eax, gameScore
    add statScore, eax

    cmp eax, statHigh           ; EAX still holds this game's score
    jbe notHigh
    mov statHigh, eax
    mov newHigh, 1
notHigh:
    ; slide the last-5 list down by one: recent[4]=recent[3] ... recent[1]=recent[0]
    mov ecx, 4
    mov esi, 16                 ; byte offset of recent[4] (4 * 4)
slideDown:
    mov eax, statRecent[esi - 4]
    mov statRecent[esi], eax
    sub esi, 4
    loop slideDown
    mov eax, gameScore
    mov statRecent[0], eax      ; newest score goes in front

    call SaveStats
    ret
RecordGame ENDP

END