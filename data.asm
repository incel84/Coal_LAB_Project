INCLUDE game.inc

.data
; ---------- the game that is being played right now ----------
gameScore   DWORD 0
gameLives   DWORD START_LIVES
gameKills   DWORD 0                         ; enemies destroyed this game
gameShots   DWORD 0                         ; bullets fired this game
shipX       BYTE  (FIELD_LEFT + FIELD_RIGHT) / 2   ; middle of the ship
quitFlag    BYTE  0                         ; 1 = player pressed Q
newHigh     BYTE  0                         ; 1 = this game beat the high score
spawnTimer  BYTE  0                         ; counts frames until next enemy
enemyTimer  BYTE  0                         ; counts frames until enemies slide
shotTimer     BYTE  0                         ; counts frames until enemy shots fall
fileFound   BYTE  0                         ; 1 = stats.dat was read OK

; ---------- bullets: slot i uses bulletX[i], bulletY[i], bulletOn[i] ----------
bulletX     BYTE MAX_BULLETS DUP(0)
bulletY     BYTE MAX_BULLETS DUP(0)
bulletOn    BYTE MAX_BULLETS DUP(0)         ; 1 = slot is in use

; ---------- enemies ----------
enemyX      BYTE MAX_ENEMIES DUP(0)
enemyY      BYTE MAX_ENEMIES DUP(0)
enemyOn     BYTE MAX_ENEMIES DUP(0)
enemyDir    BYTE MAX_ENEMIES DUP(0)         ; 0 = sliding left, 1 = sliding right

; ---------- enemy bullets (shots that fall down) ----------
shotX         BYTE MAX_EBULLETS DUP(0)
shotY         BYTE MAX_EBULLETS DUP(0)
shotOn        BYTE MAX_EBULLETS DUP(0)

; ---------- saved stats ----------
; These fields are written to / read from stats.dat as ONE block.
; Keep them together and in this order (STATS_SIZE = 11 * 4 + 16 = 60).
statMagic   DWORD 0                         ; must equal STATS_MAGIC
statHigh    DWORD 0                         ; best score ever
statGames   DWORD 0                         ; games played
statKills   DWORD 0                         ; total enemies destroyed
statShots   DWORD 0                         ; total bullets fired
statScore   DWORD 0                         ; total of all scores
statRecent  DWORD 5 DUP(0)                  ; last 5 scores, newest first
statName    BYTE 16 DUP(0)                  ; player name, ends with a 0 byte

; ---------- the whole stats.dat file (written / read as ONE block) ----------
; The stat fields above are the copy of the player who is playing now.
; 'profiles' holds all saved players, one 60-byte record each.
fileMagic   DWORD 0                         ; must equal FILE_MAGIC
curPlayer   DWORD 0                         ; slot of the current player (0 .. MAX_PLAYERS-1)
profiles    BYTE MAX_PLAYERS * STATS_SIZE DUP(0)

END