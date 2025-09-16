	.data

	.global board

board: 	.string "+--------------------+", 0xA, 0xD
		.string "|                    |", 0xA, 0xD
		.string "|                    |", 0xA, 0xD
		.string "|                    |", 0xA, 0xD
		.string "|                    |", 0xA, 0xD
		.string "|          *         |", 0xA, 0xD
		.string "|                    |", 0xA, 0xD
		.string "|                    |", 0xA, 0xD
		.string "|                    |", 0xA, 0xD
		.string "|                    |", 0xA, 0xD
		.string "|                    |", 0xA, 0xD
		.string "+--------------------+", 0x0

hailMary: 			.string 27,"[2J",0
hailMary1: 			.string 27,"[0;0H",0



StartGame: 	.string "", 0xA, 0xD
			.string "Press the 'G' key to start then (a)left (d)right (w)up (s)down", 0xA, 0xD
			.string "",0x0

GameOver: 	.string "", 0xA, 0xD
			.string "GAME OVER", 0xA, 0xD
			.string "YOU LOSE!",0x0

GameScore:	.cstring "         Score: "
GameScore2: .cstring "                                 "
GameScore3: .cstring "\r\n"



fandom: .word 0xACE1

asterisk_position: .word 0
current_direction: .word 0
score:   .word 0

	.text

	.global project5
	.global read_character
	.global output_character
	.global output_string
	.global read_character2
	.global timer_init
	.global gpio_init
	.global Timer_Handler
	.global UART0_Handler
	.global Switches_Handler

	.global generate_bounded_random

ptr_hailMary: 		.word hailMary
ptr_hailMary1:		.word hailMary1


decimal_buffer: .space 12

ptr_board:	   .word board
ptr_random:	   .word fandom


ptr_StartGame: .word StartGame
ptr_GameOver:  .word GameOver
ptr_GameScore: .word GameScore
ptr_GameScore2: .word GameScore2
ptr_GameScore3: .word GameScore3
ptr_score:     .word score
ptr_decimal:     .word decimal_buffer
position:      .word asterisk_position
direction:     .word current_direction

project5:
    PUSH {lr, r4-r11}

    ;BL gpio_init

    ldr r1, ptr_StartGame
	mov r0, r1
	BL output_string

    LDR r4, ptr_board
    MOV r0, r4
    BL output_string

wait_for_g:

    BL read_character

    cmp r0, #'g'
    BNE wait_for_g

    ;BEQ continue

continue:
	MOV r4, #0xC000
	MOVT r4, #0x4000
	LDR r5, [ r4, #0x038]
	ORR r5, r5, #0x10
	STR r5, [ r4, #0x038]

	MOV r4, #0xE000
	MOVT r4, #0xE000
	LDR r5, [ r4, #0x100]
	ORR r5, r5, #0x20
	STR r5, [ r4, #0x100]


    LDR r0, ptr_hailMary	; clear board
	BL output_string

	LDR r0, ptr_hailMary1	; clear board
	BL output_string

    ldr r4, ptr_board
    mov r5, r4
    add r6, r4, #244

search_loop:
    cmp r5, r6
    beq end_search
    ldrb r3, [r5]   ; Load byte at current position
    cmp r3, #'*'
    bne next_position  ; If not, go to next position
    mov r3, #' '
    strb r3, [r5]   ; Store space in place of the asterisk
    b end_search



next_position:
    add r5, #1      ; Move to the next position
    b search_loop   ; Continue the loop

end_search:
	BL random_position

	LDR r4, ptr_board
    ADD r4, r4, r0  ; Calculate address of the new random position
    MOV r3, #'*'
    STRB r3, [r4]   ; Place the asterisk at the random position

    ldr r1, ptr_GameScore
	mov r0, r1
	BL output_string

	ldr r1, ptr_GameScore2
	mov r0, r1
	BL output_string

	ldr r1, ptr_GameScore3
	mov r0, r1
	BL output_string

    ldr r4, ptr_board
    mov r0, r4
    BL output_string

    BL timer_init

loop:

	B loop


    POP {lr, r4-r11}
    mov pc, lr


random_position:
    PUSH {lr, r4-r11}

    LDR r2, ptr_random
    LDR r2, [r2]
    MOV r3, r2
    LSL r3, r3, #13
    EOR r2, r2, r3
    LSR r3, r3, #17
    EOR r2, r2, r3
    LSL r3, r3, #5
    EOR r2, r2, r3
    ldr r4, ptr_random
    STR r2, [r4]

    AND r2, r2, #0x0FF
    mov r3, #244
    MUL r2, r2, r3
    LSR r2, r2, #8
    ADD r0, r2, #1

    ldr r2, position
    str r0, [r2]



    POP {lr, r4-r11}
    BX lr

random_direction:
	PUSH {lr, r4-r11}

	ldr r3, direction
	mov r2, #0
	str r2, [r3]

	POP {lr, r4-r11}
    BX lr



Timer_Handler:
	PUSH {lr, r4-r11}
	mov r0, #0
	movt r0, #0x4003
	ldrb r1, [r0, #0x024]
	orr r1, r1, #1
	strb r1, [r0, #0x024]


	LDR r4, position
    LDR r4, [r4]

    LDR r7, direction
    LDR r7, [r7]

    MOV r3, #24

    CMP r7, #0
    BEQ move_up

    CMP r7, #1
    BEQ move_down

    CMP r7, #2
    BEQ move_left

    CMP r7, #3
    BEQ move_right

move_up:
    SUB r4, r4, r3
    B update_add_star

move_down:
    ADD r4, r4, r3
    B update_add_star

move_left:
    SUB r4, r4, #1
    B update_add_star

move_right:
    ADD r4, r4, #1
    B update_add_star


update_add_star:
	ldr r6, ptr_board
	add r5, r6, r4
	ldrb r8, [r5]   ;Load byte at current position
    cmp r8, #' '
    BNE collision



    mov r8, #'*'
    strb r8, [r5]

    ldr r5, position
    str r4, [r5]

    ldr r5, ptr_score
    ldr r4, [r5]
    add r4, r4, #1
    str r4, [r5]

    BL draw_board

    BL output_score






	POP {lr, r4-r11}
	BX lr

Switches_Handler:
	PUSH {lr, r4-r11}

	POP {lr, r4-r11}
	BX lr


UART0_Handler:
    PUSH {lr, r4-r11}

    ; clear interrupt
	MOV r4, #0xC000
	MOVT r4, #0x4000
	LDR r5, [ r4, #0x044]
	ORR r5, r5, #16
	STR r5, [ r4, #0x044]

    BL read_character2

    CMP r0, #'w'
    BEQ set_up
    CMP r0, #'s'
    BEQ set_down
    CMP r0, #'a'
    BEQ set_left
    CMP r0, #'d'
    BEQ set_right

set_up:
    MOV r1, #0
    B change_direction

set_down:
    MOV r1, #1
    B change_direction

set_left:
    MOV r1, #2
    B change_direction

set_right:
    MOV r1, #3
    B change_direction

change_direction:
    LDR r2, direction
    STR r1, [r2]
    POP {r4-r11, lr}
    BX lr


collision:

    LDR r0, ptr_GameOver
    BL output_string
    POP {lr, r4-r11}
    BX lr

output_score:
	PUSH {lr, r4-r11}

	ldr r1, ptr_GameScore
	mov r0, r1
	bl output_string

	ldr r0, ptr_score
	ldr r0, [r0]



    ldr r1, ptr_GameScore3  ; Load and output the newline/carriage return
    mov r0, r1
    bl output_string


	POP {r4-r11, lr}
    BX lr


draw_board:
    PUSH {lr, r4-r11}

    LDR r0, ptr_hailMary	; clear board
	BL output_string

	LDR r0, ptr_hailMary1	; clear board
	BL output_string


    LDR r4, ptr_board
    MOV r0, r4
    BL output_string      ; Assume output_string handles the entire board drawing
    POP {r4-r11, lr}
    BX lr


    .end




