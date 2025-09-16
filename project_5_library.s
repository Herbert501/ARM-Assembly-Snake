text
	.global read_character
	.global output_character
	.global output_string
	.global read_character2
	.global timer_init
	.global gpio_init
	.global Timer_Handler
	.global UART0_Handler
	.global Switches_Handler




U0FR: 	.equ 0x18	; UART0 Flag Register

output_string:
	PUSH {lr, r4-r11}    ; Store register lr on stack

		; Your code for your output_string routine is placed here
	MOV r4, r0

loop_output:

	LDRB r0, [r4], #1    ;load character in memory add 1

	CMP r0, #0       ; check for null
	BEQ output_end   ; if equal to null end

	BL output_character  ; branch to output_character


	B loop_output        ; repreat and ADD

output_end:

	POP {lr, r4-r11}
	mov pc, lr



read_character:
	PUSH {lr, r4-r11}    ; Store register lr on stack

		; Your code for your read_character routine is placed here

    ; UARTDR address

	MOV r3, #0xC000   ; move C000 to r3
	MOVT r3, #0x4000  ; move C000 to the top of r3
                      ; r3 = 0x4000C000
loop_read:

	LDRB r1, [r3, #U0FR] ; load flag
	AND r1, r1, #16   ; check if buffer is empty
	CMP r1, #0        ; check for null
	BNE loop_read     ; if not equal branch loop_read

	B load
load:

	LDRB r0, [r3]     ; load the character to r0

	POP {lr, r4-r11}
	mov pc, lr


output_character:
	PUSH {lr, r4-r11}    ; Store register lr on stack

		; Your code for your output_character routine is placed here

	; UARTDR address

	MOV r3, #0xC000   ; move C000 TO r3
	MOVT r3, #0x4000  ; move C000 to the top of r3
	                  ; r3 = 0x4000C000

loop_character:

	LDRB r1, [r3, #U0FR]  ; load flag
	AND r1, r1, #32       ; check if buffer full


	CMP r1, #0        ; check for null
	BNE loop_character  ; if not equal branch loop_character

	B store


store:

	STRB r0, [r3]       ; store the character to r0


	POP {lr, r4-r11}
	mov pc, lr

timer_init:
	; Enable Clock for Timer 0
	mov r0, #0xE000
	movt r0, #0x400F
	ldrb r1, [r0, #0x604]
	orr r1, r1, #1
	strb r1, [r0, #0x604]

	; Disable Timer0
	mov r0, #0
	movt r0, #0x4003
	ldrb r1, [r0, #0x00C]
	bic r1, r1, #1
	strb r1, [r0, #0x00C]


	; Put Timer in 32-bit Mode
	mov r0, #0
	movt r0, #0x4003
	mov r1, #0
	strb r1, [r0]

	; Put Timer in Periodic MOde
	mov r0, #0
	movt r0, #0x4003
	ldrb r1, [r0, #0x004]
	bic r1, r1, #1
	orr r1, r1, #2
	strb r1, [r0, #0x004]

	; Setup Interval Period
	mov r0, #0
	movt r0, #0x4003
	mov r1, #0x1200
	movt r1, #0x7A
	str r1, [r0, #0x028]

	; Enable Timer to Interrupt Processor
	mov r0, #0
	movt r0, #0x4003
	ldrb r1, [r0, #0x018]
	orr r1, r1, #1
	str r1, [r0, #0x018]


	; Configure Processor to Allow Timer to Interrupt Processor
	mov r0, #0xE000
	movt r0, #0xE000
	ldr r1, [r0, #0x100]
	orr r1, r1, #0x80000
	str r1, [r0, #0x100]

	; Enable Timer0
	mov r0, #0
	movt r0, #0x4003
	ldrb r1, [r0, #0x00C]
	orr r1, r1, #1
	strb r1, [r0, #0x00C]

	mov pc, lr


read_character2:

	MOV r1, #0xC000	; UARTDR address
    MOVT r1, #0x4000
   	LDRB r0, [r1]

	mov pc, lr	; Return

gpio_init:

	; Enable Clock for Port F
	mov r0, #0xE000
	movt r0, #0x400F
	ldrb r1, [r0, #0x608]
	orr r1, r1, #0x20
	strb r1, [r0, #0x0608]

	; Set Direction
	mov r0, #0x5000
	movt r0, #0x4002
	ldrb r1, [r0, #0x400]
	orr r1, r1, #0xE
	bic r1,r1, #0x10
	strb r1, [r0, #0x400]

	; Enable Digital
	mov r0, #0x5000
	movt r0, #0x4002
	ldrb r1, [r0, #0x51C]
	orr r1, r1, #0x1E
	strb r1, [r0, #0x051C]


	; Enable Pull-Up Resistor
	mov r0, #0x5000
	movt r0, #0x4002
	ldrb r1, [r0, #0x510]
	orr r1, r1, #0x10
	strb r1, [r0, #0x0510]

	; Return
	mov pc,lr

	.end
