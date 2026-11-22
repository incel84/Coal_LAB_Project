INCLUDE game.inc

.data
title1   BYTE "S P A C E   S H O O T E R",0
title2   BYTE "x86 Assembly  |  Irvine32",0
art1     BYTE "/^\",0
art2     BYTE "/___\",0
art3     BYTE "|_/ \_|",0
opt1     BYTE "[1]  Play",0
opt2     BYTE "[2]  Instructions",0
opt3     BYTE "[3]  Dashboard",0
opt4     BYTE "[4]  Change Player",0
opt5     BYTE "[5]  Quit",0
menuPlayer BYTE "Player: ",0
credit   BYTE "COAL Lab - Fall 2026 - Group 10 - BDS-3A",0

helpHead BYTE "HOW TO PLAY",0
help1    BYTE "A / D      move the ship left / right",0
help2    BYTE "SPACE      fire a bullet (5 bullets at a time)",0
help3    BYTE "P          pause / resume",0
help4    BYTE "Q          quit the game",0
help5    BYTE "Shoot the enemies (W) - each one is worth 10 points.",0
help6    BYTE "Enemies float at the top and shoot down at you (v).",0
help7    BYTE "You lose a life when a shot hits you. You have 3 lives.",0
help8    BYTE "Your results are saved in stats.dat (see the Dashboard).",0
anyKey   BYTE "Press any key to go back",0

namePrompt BYTE "Enter your name (max 15 letters): ",0
defaultName BYTE "Player",0

goTitle   BYTE "G A M E   O V E R",0
goScore   BYTE "Final score      : ",0
goKills   BYTE "Enemies destroyed: ",0
goShots   BYTE "Shots fired      : ",0
goAcc     BYTE "Accuracy         : ",0
goPercent BYTE " %",0
goHigh    BYTE "High score       : ",0
goNewHigh BYTE "** NEW HIGH SCORE! **",0
goPress   BYTE "Press any key to go back to the menu",0

.code
; ---------- ShowMenu: draws the menu, returns EAX = 1..5 ----------
ShowMenu PROC USES edx
    call Clrscr

    mov eax, lightCyan
    call SetTextColor
    mWriteAt 37, 2, art1
    mWriteAt 36, 3, art2
    mWriteAt 36, 4, art3

    mov eax, yellow
    call SetTextColor
    mWriteAt 27, 6, title1
    mov eax, gray
    call SetTextColor
    mWriteAt 27, 7, title2

    mov eax, white
    call SetTextColor
    mWriteAt 31, 10, opt1
    mWriteAt 31, 12, opt2
    mWriteAt 31, 14, opt3
    mWriteAt 31, 16, opt4
    mWriteAt 31, 18, opt5

    mov eax, lightGreen         ; who is playing
    call SetTextColor
    mWriteAt 31, 8, menuPlayer
    mov edx, OFFSET statName
    call WriteString

    mov eax, gray
    call SetTextColor
    mWriteAt 20, 21, credit
    mov eax, white
    call SetTextColor

waitChoice:                      ; wait until the key is 1 to 5
    call ReadChar
    cmp al, '1'
    jb  waitChoice
    cmp al, '5'
    ja  waitChoice
    sub al, '0'                 ; '3' -> 3
    movzx eax, al
    ret
ShowMenu ENDP

; ---------- ShowInstructions ----------
ShowInstructions PROC USES eax edx
    call Clrscr
    mov eax, lightCyan
    call SetTextColor
    mWriteAt 20, 2, helpHead

    mov eax, white
    call SetTextColor
    mWriteAt 20, 5, help1
    mWriteAt 20, 6, help2
    mWriteAt 20, 7, help3
    mWriteAt 20, 8, help4
    mWriteAt 20, 11, help5
    mWriteAt 20, 12, help6
    mWriteAt 20, 13, help7
    mWriteAt 20, 15, help8

    mov eax, gray
    call SetTextColor
    mWriteAt 20, 19, anyKey
    mov eax, white
    call SetTextColor
    call WaitForKey
    ret
ShowInstructions ENDP

; ---------- ShowGameOver: shows the result of the game just played ----------
ShowGameOver PROC USES eax ebx edx
    call Clrscr
    mov eax, lightRed
    call SetTextColor
    mWriteAt 31, 3, goTitle

    mov eax, white
    call SetTextColor
    mWriteAt 28, 6, goScore
    mov eax, gameScore
    call WriteDec
    mWriteAt 28, 7, goKills
    mov eax, gameKills
    call WriteDec
    mWriteAt 28, 8, goShots
    mov eax, gameShots
    call WriteDec

    mWriteAt 28, 9, goAcc
    mov eax, gameKills
    mov ebx, gameShots
    call CalcPercent            ; EAX = kills * 100 / shots
    call WriteDec
    mov edx, OFFSET goPercent
    call WriteString

    cmp newHigh, 1
    jne oldHigh
    mov eax, yellow
    call SetTextColor
    mWriteAt 29, 12, goNewHigh
    jmp finish
oldHigh:
    mWriteAt 28, 12, goHigh
    mov eax, statHigh
    call WriteDec
finish:
    mov eax, gray
    call SetTextColor
    mWriteAt 22, 15, goPress
    mov eax, white
    call SetTextColor
    call WaitForKey
    ret
ShowGameOver ENDP

; ---------- AskName: type a name, it is stored in statName ----------
; (the caller saves it with SaveStats)
AskName PROC USES eax ecx edx esi edi
    call Clrscr
    mov eax, lightCyan
    call SetTextColor
    mWriteAt 22, 9, namePrompt
    mov eax, white
    call SetTextColor
    mov edx, OFFSET statName
    mov ecx, NAME_MAX           ; room for 15 letters + the 0 at the end
    call ReadString             ; EAX = number of letters typed
    cmp eax, 0
    jne nameDone
    cld                         ; nothing typed: use "Player"
    mov esi, OFFSET defaultName
    mov edi, OFFSET statName
    mov ecx, 7                  ; "Player" + 0 byte
    rep movsb
nameDone:
    ret
AskName ENDP

; ---------- FlushKeys: throw away keys that are still waiting ----------
FlushKeys PROC USES eax edx
    mov eax, 300
    call Delay                  ; short pause so ReadKey sees all pending keys
flushLoop:
    call ReadKey
    jnz flushLoop               ; ZF = 0 means a key was read, keep going
    ret
FlushKeys ENDP

; ---------- WaitForKey: wait for any key (ignores old key presses) ----------
WaitForKey PROC USES eax edx
    call FlushKeys
    call ReadChar
    ret
WaitForKey ENDP

END