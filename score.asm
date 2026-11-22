INCLUDE game.inc

.code
UpdateScore PROC
    add gameScore, POINTS_PER_KILL
    inc gameKills
    call DrawHUD
    ret
UpdateScore ENDP

UpdateLives PROC
    cmp gameLives, 0
    je  livesDone
    dec gameLives
livesDone:
    call DrawHUD
    ret
UpdateLives ENDP

; ---------- CalcPercent ----------
; In : EAX = part, EBX = total
; Out: EAX = part * 100 / total   (0 if total is 0)
CalcPercent PROC USES ebx edx
    cmp ebx, 0
    je  percentZero
    mov edx, 100
    mul edx                     ; EDX:EAX = part * 100
    div ebx                     ; EAX = result
    ret
percentZero:
    mov eax, 0
    ret
CalcPercent ENDP

END
