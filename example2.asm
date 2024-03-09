; BIOS functions / MSX constants----------------
WRTVDP: equ #0047
LDIRVM: equ #005c
CHGMOD: equ #005f
BEEP:   equ #00c0 
SPRTBL2: equ #3800   ; sprite pattern address          
SPRATR2: equ #1b00   ; sprite attribute address
CHSNS:  equ #009c
CHGET:  equ #009f
GTSTCK: equ #00d5

; ROM header -----------------------------------
    org #4000
    db "AB" ;   ROM signature
    dw Start  ; start address
    db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

Start:
    ld a, 2  ; Change screen mode (Screen 2)
    call CHGMOD
    ld bc, 0e201h  ; write e2h in VDP register 01h (activate sprites, generate interrupts, set 16x16 sprites)
    call WRTVDP

    ; Define sprite:
    ld de, SPRTBL2
    ld hl, shipsprite
    ld bc, 32
    call LDIRVM

    ; transfer sprite attributes to RAM:
    ld ix, spriteattributesRAM
    ld (ix), 64  ; y
    ld (ix+1), 64  ; x
    ld (ix+2), 0  ; sprite pattern
    ld (ix+3), 15  ; color

    call BEEP

loop:
    halt  ; make the program run at 50/60 frames per second

    ; scan joystick (or cursor keys)
    ld a, #0
    call GTSTCK
    ; a should 1 - up, 2 - up/right, 3 - right, 4 - right/down, 
    ; 5 - down, 6 - down/left, 7 - left, 8 - left/up
    cp #1
    jr z, move_up
    cp #2
    jr z, move_upright
    cp #3
    jr z, move_right
    cp #4
    jr z, move_rightdown
    cp #5
    jr z, move_down
    cp #6
    jr z, move_downleft
    cp #7
    jr z, move_left
    cp #8
    jr z, move_leftup
    jp setsprite

move_up:    
    ld hl, spriteattributesRAM
    dec (hl)  ; decrease y
    jp setsprite

move_upright:    
    ld hl, spriteattributesRAM
    dec (hl)  ; decrease y
    ld hl, spriteattributesRAM + 1
    inc (hl)  ; increase x
    jp setsprite

move_right:
    ld hl, spriteattributesRAM + 1
    inc (hl)  ; increase x
    jp setsprite

move_rightdown:
    ld hl, spriteattributesRAM
    inc (hl)  ; increase y
    ld hl, spriteattributesRAM + 1
    inc (hl)  ; increase x
    jp setsprite

move_down:
    ld hl, spriteattributesRAM
    inc (hl)  ; increase y
    jp setsprite

move_downleft:
    ld hl, spriteattributesRAM
    inc (hl)  ; increase y
    ld hl, spriteattributesRAM + 1
    dec (hl)  ; decrease x
    jp setsprite

move_left:
    ld hl, spriteattributesRAM + 1
    dec (hl)  ; decrease x
    jp setsprite

move_leftup:
    ld hl, spriteattributesRAM
    dec (hl)  ; decrease y
    ld hl, spriteattributesRAM + 1
    dec (hl)  ; decrease x

setsprite:
    ;; Update the sprite attributes in VRAM:
    ld hl, spriteattributesRAM
    ld de, SPRATR2
    ld bc, 4
    call LDIRVM

    jp loop

getch:
	call CHSNS      ; call CHSNS
	ld l, #0
	ret z
	call CHGET		; call CHGET
	ld l, a
	ret

shipsprite:
    db 00h, 00h, 01h, 01h, 01h, 03h, 03h, 07h, 07h, 0fh, 1fh, 3fh, 3ch, 18h, 00h, 00h
    db 00h, 00h, 80h, 80h, 80h,0c0h,0c0h,0e0h,0e0h,0f0h,0f8h,0fch, 3ch, 18h, 00h, 00h

    ds 8000h - $  ; fill the rest of the ROM (up to 16KB with 0s)

    org 0c000h  ; RAM
spriteattributesRAM:
    ds virtual 4