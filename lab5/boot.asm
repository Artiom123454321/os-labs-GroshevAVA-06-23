; Lab 5: MINI OS — NASM version of the 512-byte x86 boot sector
; Assemble: nasm -f bin boot.asm -o mini_os.img

bits 16
org 0x7C00

start:
    cli
    xor ax, ax
    mov ds, ax
    mov ss, ax
    mov sp, 0x7C00
    sti

    mov ax, 0x0003          ; BIOS: 80x25 text mode
    int 0x10
    mov ax, 0xB800          ; VGA color text memory
    mov es, ax
    cld

home:
    call clear
    mov di, 320             ; Row 2
    mov bl, 0x0B           ; Cyan
    mov si, logo
    call puts
    mov bl, 0x0E           ; Yellow
    mov si, menu
    call puts
    call key
    cmp al, '1'
    je game
    cmp al, '2'
    je about
    cmp al, '3'
    je reboot
    jmp home

game:
    call clear
    mov di, 320
    mov bl, 0x0E
    mov si, question
    call puts
    call key
    cmp al, '1'
    jne lost
    mov bl, 0x0E
    mov si, second_question
    call puts
    call key
    cmp al, '2'
    je won
lost:
    mov bl, 0x0C           ; Red
    mov si, lost_text
    jmp result
won:
    mov bl, 0x0A           ; Green
    mov si, won_text
result:
    call puts
    jmp back

about:
    call clear
    mov di, 320
    mov bl, 0x0B
    mov si, about_text
    call puts
back:
    mov bl, 0x07
    mov si, back_text
    call puts
    call key
    jmp home

reboot:
    int 0x19              ; BIOS: bootstrap again
    jmp home

clear:
    xor di, di
    mov ax, 0x0720        ; Space, white on black
    mov cx, 2000          ; 80 * 25 cells
    rep stosw
    ret

; DS:SI = zero-terminated text. ES:DI = destination.
; BL = text color. LF (10) means next row.
puts:
    lodsb
    test al, al
    jz puts_done
    cmp al, 10
    jne character
    mov ax, di
    xor dx, dx
    mov cx, 160            ; 80 chars * 2 bytes each
    div cx
    inc ax
    mul cx
    mov di, ax
    jmp puts
character:
    mov ah, bl
    stosw
    jmp puts
puts_done:
    ret

key:
    xor ah, ah
    int 0x16              ; BIOS keyboard, ASCII -> AL
    ret

logo:
    db ' __  __ ___ _  _ ___    ___  ___ ',10
    db '|  \/  |_ _| \| |_ _|  / _ \/ __|',10
    db '| |\/| || || .` || |  | (_) \__ \',10
    db '|_|  |_|___|_|\_|___|  \___/|___/',10
    db '           MINI OS',10,0
menu:
    db 10,' [1] GAME  [2] ABOUT  [3] REBOOT',10,' > ',0
question:
    db 'CAVE: tunnel 1 or 2? ',0
second_question:
    db 10,' Chests: 1 or 2? ',0
won_text:
    db 10,' TREASURE! YOU WIN!',10,0
lost_text:
    db 10,' TRAP! GAME OVER.',10,0
about_text:
    db 'MINI OS / x86 / 512B',10,0
back_text:
    db 10,' Press any key...',0

times 510 - ($ - $$) db 0
dw 0xAA55
