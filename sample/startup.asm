extern init_idt, init_paging, init_vga
extern main
global start

BITS 32
start:
	; gdt
	lgdt [gdtr]
	mov eax, 0x28
	ltr ax

	mov ax, 0x10
	mov ds, ax
	mov ss, ax
	call 0x8:next
next:
	; idt
	cli
	call init_idt
	lidt [eax]
	sti

	; paging
	call init_paging
	mov cr3, eax

	mov eax, cr0
	or eax, 0x80000000
	mov cr0, eax

	call init_pic
	;call init_timer
	call init_key_mouse
	call init_vga

	mov ax, 0x23
	mov ds, ax
	mov ss, ax
	call 0x18:main
infinit:
	hlt
	jmp infinit

init_pic:
	cli
	mov al, 0x11
	out 0x20, al
	out 0xa0, al

	mov al, 0x20
	out 0x21, al
	mov al, 0x28
	out 0xa1, al

	mov al, 0x4
	out 0x21, al
	mov al, 2
	out 0xa1, al

	mov al, 0x3
	out 0x21, al
	out 0xa1, al

	mov al, 0xfb
	out 0x21, al
	mov al, 0xff
	out 0xa1, al
	sti
	ret

init_timer:
	; timer
	cli
	mov al, 0x34
	out 0x43, al
	mov al, 0x9c
	out 0x40, al
	mov al, 0x2e
	out 0x40, al

	in al, 0x21
	and al, 0xfe
	out 0x21, al
	sti
	ret

init_key_mouse:
	; keyboard
	cli
	mov al, 0x60
	out 0x64, al
	mov al, 0x47
	out 0x60, al

	in al, 0x21
	and al, 0xfd
	out 0x21, al

	; mouse
	mov al, 0xd4
	out 0x64, al
	mov al, 0xf4
	out 0x60, al

	in al, 0xa1
	and al, 0xef
	out 0xa1, al
	sti
	ret

align 8
gdtr:
	dw gdt_end - gdt -1
	dd gdt
align 8
gdt:
	dq 0

	dw 0x0100
	dw 0x0000
	db 0x00
	db 0x88
	db 0xc0
	db 0x00

	dw 0x0100
	dw 0x0000
	db 0x00
	db 0x82
	db 0xc0
	db 0x00

	dw 0x0100
	dw 0x0000
	db 0x00
	db 0xf8
	db 0xc0
	db 0x00

	dw 0x0100
	dw 0x0000
	db 0x00
	db 0xf2
	db 0xc0
	db 0x00

	dw 0x0080
	dw tss - start
	db 0x01
	db 0x01
	db 0x00
	db 0x00
gdt_end:

tss:
	dq 0
	dq 0
	dq 0
	dq 0
	dq 0
	dq 0
	dq 0
	dq 0
	dq 0
	dq 0
	dq 0
	dd 0
	dw 0x10
	dw 0
	dd 0x2000
