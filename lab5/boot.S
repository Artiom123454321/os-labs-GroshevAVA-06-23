/* Lab 5: MINI OS, a 512-byte real-mode x86 boot sector.
   GNU assembler (GAS), Intel syntax. */
.code16
.intel_syntax noprefix
.section .text
.global _start

_start:
    cli
    xor ax, ax
    mov ds, ax
    mov ss, ax
    mov sp, 0x7c00
    sti

    mov ax, 0x0003           /* BIOS 80x25 text mode */
    int 0x10
    mov ax, 0xb800           /* Color video RAM */
    mov es, ax
    cld

home:
    call clear
    mov di, 320              /* Start at row 2 */
    mov bl, 0x0b            /* Light cyan */
    mov si, offset logo
    call puts
    mov bl, 0x0e            /* Yellow */
    mov si, offset menu
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
    mov bl, 0x0e
    mov si, offset question
    call puts
    call key
    cmp al, '1'
    jne lost
    mov bl, 0x0e
    mov si, offset second_question
    call puts
    call key
    cmp al, '2'
    je won
lost:
    mov bl, 0x0c            /* Red */
    mov si, offset lost_text
    jmp result
won:
    mov bl, 0x0a            /* Green */
    mov si, offset won_text
result:
    call puts
    jmp back

about:
    call clear
    mov di, 320
    mov bl, 0x0b
    mov si, offset about_text
    call puts
back:
    mov bl, 0x07
    mov si, offset back_text
    call puts
    call key
    jmp home

reboot:
    int 0x19                /* BIOS bootstrap */
    jmp home

/* Clear the entire 80x25 screen with gray-on-black spaces. */
clear:
    xor di, di
    mov ax, 0x0720
    mov cx, 2000
    rep stosw
    ret

/* Print 0-terminated bytes from DS:SI to ES:DI in color BL.
   Byte 10 starts the next text row. */
puts:
    lodsb
    test al, al
    jz puts_done
    cmp al, 10
    jne character
    mov ax, di
    xor dx, dx
    mov cx, 160
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

/* Read one key, return ASCII in AL. */
key:
    xor ah, ah
    int 0x16
    ret

logo:
    .ascii " __  __ ___ _  _ ___    ___  ___ \n"
    .ascii "|  \\/  |_ _| \\| |_ _|  / _ \\/ __|\n"
    .ascii "| |\\/| || || .` || |  | (_) \\__ \\\n"
    .ascii "|_|  |_|___|_|\\_|___|  \\___/|___/\n"
    .asciz "           MINI OS\n"
menu:
    .asciz "\n [1] GAME  [2] ABOUT  [3] REBOOT\n > "
question:
    .asciz "CAVE: tunnel 1 or 2? "
second_question:
    .asciz "\n Chests: 1 or 2? "
won_text:
    .asciz "\n TREASURE! YOU WIN!\n"
lost_text:
    .asciz "\n TRAP! GAME OVER.\n"
about_text:
    .asciz "MINI OS / x86 / 512B\n"
back_text:
    .asciz "\n Press any key..."

.org 510, 0
.word 0xaa55
