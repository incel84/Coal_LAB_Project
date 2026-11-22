INCLUDE game.inc

.code
main PROC
    call Randomize              ; seed the random numbers (enemy columns)
    call LoadStats              ; read stats.dat (or start empty)
    cmp statName[0], 0          ; no name saved yet?
    jne menuLoop
    call AskName
    call SaveStats

menuLoop:
    call ShowMenu               ; EAX = 1 Play, 2 Help, 3 Dashboard, 4 Change Player, 5 Quit
    cmp eax, 1
    je  playGame
    cmp eax, 2
    je  showHelp
    cmp eax, 3
    je  showDash
    cmp eax, 4
    je  changePlayer
    jmp quitGame

playGame:
    call RunGame
    jmp menuLoop
showHelp:
    call ShowInstructions
    jmp menuLoop
showDash:
    call ShowDashboard
    jmp menuLoop
changePlayer:
    call SelectPlayer
    jmp menuLoop

quitGame:
    call Clrscr
    exit
main ENDP
END main