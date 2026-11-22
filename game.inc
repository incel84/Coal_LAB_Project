INCLUDE Irvine32.inc

; ---------- play area (console columns and rows) ----------
FIELD_LEFT    = 20                          ; left border column
FIELD_RIGHT   = 59                          ; right border column
FIELD_TOP     = 1                           ; top border row (row 0 is the HUD)
FIELD_BOTTOM  = 23                          ; bottom border row
INNER_LEFT    = FIELD_LEFT + 1              ; first free column inside
INNER_RIGHT   = FIELD_RIGHT - 1             ; last free column inside
INNER_TOP     = FIELD_TOP + 1               ; first free row inside
INNER_BOTTOM  = FIELD_BOTTOM - 1            ; last free row inside
INNER_WIDTH   = INNER_RIGHT - INNER_LEFT + 1
SHIP_Y        = INNER_BOTTOM                ; the ship lives on the last row
SHIP_MIN_X    = INNER_LEFT + 1              ; ship is 3 wide, so keep 1 col spare
SHIP_MAX_X    = INNER_RIGHT - 1

; ---------- game settings (one fixed medium difficulty) ----------
MAX_BULLETS     = 5                         ; bullets on screen at once
MAX_ENEMIES     = 5                         ; enemies on screen at once
MAX_EBULLETS    = 6                         ; enemy shots on screen at once
START_LIVES     = 3
POINTS_PER_KILL = 10
FRAME_DELAY     = 50                        ; milliseconds per frame
ENEMY_DELAY     = 5                         ; enemies slide sideways every 5 frames
EBULLET_DELAY   = 2                         ; enemy shots fall one row every 2 frames
FIRE_CHANCE     = 50                        ; each enemy shoots about once per 50 frames
SPAWN_DELAY     = 20                        ; a new enemy every 20 frames

; ---------- stats file ----------
STATS_SIZE    = 60                          ; 11 DWORDs + 16 name bytes (see data.asm)
STATS_MAGIC   = 53534832h                   ; marks a valid stats.dat
NAME_MAX      = 15                          ; longest player name
NAME_OFFSET   = 44                          ; where the name starts inside one player record
MAX_PLAYERS   = 5                           ; how many players can be saved
FILE_SIZE     = 8 + MAX_PLAYERS * STATS_SIZE ; whole stats.dat: 2 DWORDs + all players
FILE_MAGIC    = 53534833h                   ; marks a valid stats.dat file

; ---------- macro: print a string at column px, row py ----------
; (changes DL, DH and EDX)
mWriteAt MACRO px, py, txt
    mov dl, px
    mov dh, py
    call Gotoxy
    mov edx, OFFSET txt
    call WriteString
ENDM

; ---------- procedures (each lives in one .asm file) ----------
; main.asm
; menu.asm
ShowMenu         PROTO
ShowInstructions PROTO
ShowGameOver     PROTO
AskName          PROTO
SelectPlayer     PROTO
FlushKeys        PROTO
WaitForKey       PROTO
; gameloop.asm
RunGame          PROTO
InitializeGame   PROTO
HandleInput      PROTO
PauseGame        PROTO
; player.asm
MovePlayer       PROTO
FireBullet       PROTO
UpdateBullets    PROTO
; enemy.asm
SpawnEnemies     PROTO
UpdateEnemies    PROTO
FireEnemyBullet  PROTO
UpdateEnemyBullets PROTO
; collide.asm
CheckCollisions  PROTO
; score.asm
UpdateScore      PROTO
UpdateLives      PROTO
CalcPercent      PROTO
; draw.asm
PutCharAt        PROTO
DrawGame         PROTO
DrawHUD          PROTO
DrawShip         PROTO
EraseShip        PROTO
DrawEntities     PROTO
; fileio.asm
LoadStats        PROTO
SaveStats        PROTO
ClearStats       PROTO
ClearAll         PROTO
LoadActive       PROTO
StoreActive      PROTO
RecordGame       PROTO
; dashboard.asm
ShowDashboard    PROTO

; ---------- shared data (defined in data.asm) ----------
EXTERNDEF gameScore:DWORD, gameLives:DWORD, gameKills:DWORD, gameShots:DWORD
EXTERNDEF shipX:BYTE, quitFlag:BYTE, newHigh:BYTE, fileFound:BYTE
EXTERNDEF spawnTimer:BYTE, enemyTimer:BYTE
EXTERNDEF bulletX:BYTE, bulletY:BYTE, bulletOn:BYTE
EXTERNDEF enemyX:BYTE, enemyY:BYTE, enemyOn:BYTE, enemyDir:BYTE
EXTERNDEF shotX:BYTE, shotY:BYTE, shotOn:BYTE, shotTimer:BYTE
EXTERNDEF statMagic:DWORD, statHigh:DWORD, statGames:DWORD
EXTERNDEF statKills:DWORD, statShots:DWORD, statScore:DWORD
EXTERNDEF statRecent:DWORD, statName:BYTE
EXTERNDEF fileMagic:DWORD, curPlayer:DWORD, profiles:BYTE
