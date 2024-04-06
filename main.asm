.data
#DATA SECTION
midgame_rows:	.space 42
midgame_abilities:	.space 10
backup_data:	.space 52
midgame_turn:	.space 1
midgame_xo:	.space 1
midgame_name1:	.space 10
midgame_name2:	.space 10
misc_mem:	.space 20

#TEXT SECTION
#GAME ELEMENTS
undo: .asciiz "Undo left:"
violation: .asciiz "Violations:"

#INITIALIZATION
introduction:	.asciiz "Welcome to Four in a row.\nThis version is built by Nguyen Huu Hao, a Computer Engineering student at the HCMUT.\nPlease have a great time enjoying the game.\nNote: Please input everything according to instructions, don't use the enter button.\n"
start_x:	.asciiz "X turns.\n"
start_o:	.asciiz "O turns.\n"
start_player1:	.asciiz "Player 1:"
start_player2:	.asciiz "Player 2:"
start_player_x:	.asciiz "You are X."
start_player_o:	.asciiz "You are O."
start_name:	.asciiz "Please enter name (9 characters) for"
start_confirm_setting:	.asciiz	"Press any key to accept your move, press '1' to undo.\n"
start_your_turn:	.asciiz "Your turn.\n"
start_game:	.asciiz "Press anykey to continue.\n"
start_exit:	.asciiz "Press 1 to play again, press any other keys to exit.\n"
start_input:	.asciiz "Input your move in any column from 1 to 7: "
start_input_first_move:	.asciiz "This is your first move, so you have to drop on column 4.\n"
start_input_undo_ask:	.asciiz "This is what the board is like after your move.\n"
start_input_undo_success:	.asciiz "You have successfully undo your previous move.\n"
start_input_remove:	.asciiz "You still have 1 time to remove 1 piece of the opponent, input 'R' to use it.\n"
start_input_remove_coordinate:	.asciiz "Please input the coordinate of the piece you want to remove.\n"
remove_coordinate_x:	.asciiz "Row number: "
remove_coordinate_y:	.asciiz "Column number: "
remove_escape:	.asciiz "Input 2 to not use the remove.\n"
remove_success:	.asciiz "You have successfully removed your opponent's piece.\n"
start_input_block:	.asciiz "You still have 1 time to block opponent's next move, input 'B' to use it.\n"
start_is_blocked:	.asciiz "Is being blocked.\n"
start_block_success:	.asciiz "You have successfully blocked your opponent's next move.\n"

#MISCELANEOUS
x:	.asciiz "X"
o:	.asciiz "O"
eol:	.asciiz "\n"
_:	.asciiz "_"
colon:	.asciiz ":"
cursor:	.asciiz "^"
barrier:	.asciiz "|"
space:	.asciiz " "
tab:	.asciiz "\t"
exit:	.asciiz "EXIT"

#ENDGAME
game_tie:	.asciiz "The game is tied.\n"
wins:	.asciiz "is won.\n"
lose_violation:	.asciiz "You have violated game rules 3 times. You have lost.\n"

#ERROR
error_undo:	.asciiz "You can not undo any further.\n"
error_wrong_string:	.asciiz "You have input the wrong format.\n"
error_full_row:	.asciiz "The row you have entered is full.\n"
error_block:	.asciiz "Your opponent has 3 consecutive pieces so you can not block your opponent.\n"
error_first:	.asciiz "You can not use it because this is your first move.\n"
error_used:	.asciiz "You have used up this ability, you can not use it any further.\n"
error_yours:	.asciiz "The coordinate you entered belongs to you.\n"
error_empty:	.asciiz "The coordinate you entered is empty.\n"

#COLOR
ColorTable:	.word 0x0000FF,0xFF0000,0xE5C420,0xFFFFFF	#0: Blue	1: Red	2: Gold	3: White

.text
START:
	addi $v0,$zero,4
	la $a0,introduction
	syscall
	add $t0,$zero,$zero
	add $t1,$zero,52
RESET_LOOP:
	beq $t0,$t1,RESET_END
	sb $zero,midgame_rows($t0)
	addi $t0,$t0,1
	j RESET_LOOP
RESET_END:
	jal GUI_INIT    #draw the blue background in the board
	la $s0,midgame_rows
	la $s1,midgame_abilities	#0, 4: undo	    1, 5: remove	2, 6: block	    3, 7: violation     8, 9: blocked status
	la $s2,midgame_turn	#turn 0 is player 1, turn 1 is player 2
	la $s3,midgame_xo
	ori $t0,$zero,3	#3 undos to use
	sb $t0,($s1)
	sb $t0,4($s1)
	ori $t0,$zero,1	#1 remove and 1 block
	sb $t0,1($s1)
	sb $t0,2($s1)
	sb $t0,5($s1)
	sb $t0,6($s1)
	#enter name for player 1
	addi $v0,$zero,4
	la $a0,start_name   #let the player know this is for entering name
	syscall
	la $a0,space
	syscall
	la $a0,start_player1    #let the player know it is their turn
	syscall
	la $a0,eol
	syscall
	la $a0,midgame_name1
	addi $a1,$zero,10
	addi $v0,$zero,8
	syscall
	addi $v0,$zero,4
	la $a0,eol
	syscall
	#enter name for player 2
	addi $v0,$zero,4
	la $a0,start_name
	syscall
	la $a0,space
	syscall
	la $a0,start_player2
	syscall
	la $a0,eol
	syscall
	la $a0,midgame_name2
	addi $a1,$zero,10
	addi $v0,$zero,8
	syscall
	addi $v0,$zero,4
	la $a0,eol
	syscall
	#generate random number 0-1
	ori $a1,$zero,2 #the range of random number generated is 0-1
	ori $v0,$zero,42    #system call signifying generate a random number with range in $a1
	syscall			#with 0 meaning player 1 is X
	sb $a0,($s3)		#1 meaning player 1 is O
	addi $v0,$zero,4    #get ready to print
	beq $a0,$zero,P1X   #proceeding to the corresponding situation, with function P1X just the reverse of the following code lines
	la $a0,start_player1    #Proceed as player 1 is O
	syscall
	la $a0,space
	syscall
	la $a0,start_player_o
	syscall
	la $a0,eol
	syscall
	la $a0,start_player2
	syscall
	la $a0,space
	syscall
	la $a0,start_player_x
	syscall
	la $a0,eol
	syscall
	j START_ENT #waiting for the player to press enter for confirmation
P1X:
	la $a0,start_player1
	syscall
	la $a0,space
	syscall
	la $a0,start_player_x
	syscall
	la $a0,eol
	syscall
	la $a0,start_player2
	syscall
	la $a0,space
	syscall
	la $a0,start_player_o
	syscall
	la $a0,eol
	syscall
START_ENT:
	#press enter to start game
	addi $v0,$zero,4
	la $a0,start_game
	syscall
	la $a0,misc_mem
	addi $a1,$zero,1
	addi $v0,$zero,8
	syscall
	addi $v0,$zero,4
	la $a0,eol
	syscall
MOVE1:
	jal PRINT_GUI
	jal PRINT_BOARD
	jal PROC_MOVE1
	addi $t0,$zero,1
	sb $t0,($s2)
MOVE2:
	jal PRINT_GUI
	jal PRINT_BOARD
	jal PROC_MOVE2
	sb $zero,($s2)
MID_GAME:
	jal PRINT_GUI
	jal PRINT_BOARD
	jal PROCESS
CHECK_CHECK:
	jal WIN_CHECK
	lb $t0,($s2)    #0 is P1's turn, 1 is P2's turn
	beq $t0,$zero,CHANGE_TURN_0
	sb $zero,($s2)
	j MID_GAME
CHANGE_TURN_0:
	addi $t0,$t0,1
	sb $t0,($s2)
	j MID_GAME
END_GAME:
	addi $v0,$zero,4    #ask if the players wanted to restart
	addi $t1,$zero,49
	la $a0,start_exit
	syscall
	ori $v0,$zero,8
	la $a0,misc_mem
	addi $a1,$zero,2    #input
	syscall
	lb $t0,($a0)    #check for input
	beq $t0,$t1,START   #if 1 then restart
EXIT:
	ori $v0,$zero,10    #if not, exit
	syscall

GUI_INIT:
	add $t0,$zero,$zero #let $t0 and $t1 be the iterators
	add $t1,$zero,$zero #$t0: row iterator $t1: column iterator
GUI_OP:
	add $t2,$zero,$zero #$t2: inner row iterator
	add $t3,$zero,$zero #$t3: inner column iterator
GUI_OP_OP:
	lui $t5,0x1004  #load heap address
	add $t4,$zero,$t2   #add up all the iterators to have the address
	add $t4,$t4,$t3
	add $t4,$t4,$t0
	add $t4,$t4,$t1
	add $t5,$t5,$t4
	lw $t4,ColorTable   #load and store blue into each pixel
	sw $t4,($t5)
GUI_OP_COND:
	addi $t2,$t2,4  #jump to another pixel
	bne $t2,32,GUI_OP_OP    #end of 8 row pixels box
	add $t2,$zero,$zero
	addi $t3,$t3,256    #jump to another row
	bne $t3,2048,GUI_OP_OP  #end of 8 column pixels box
GUI_COND:
	addi $t0,$t0,32 #jump to another box
	bne $t0,256,GUI_OP  #end of row
	add $t0,$zero,$zero
	addi $t1,$t1,2048   #jump to box by 8 rows
	bne $t1,16384,GUI_OP    #the limit of the 64x64 board
	jr $ra

PRINT_BOARD:
	addi $t0,$zero,4    #row iterator from pixel 1 horizontally
	addi $t1,$zero,1280 #column iterator from pixel 6 vertically
	add $t3,$zero,$zero
PB_OP:
	lb $t9,midgame_rows($t3)    #loading data from array to determine which type to draw
	add $t4,$zero,$zero #$t4: inner column iterator
	add $t5,$zero,$zero #$t5: inner row iterator
PB_CONT:
	lui $t6,0x1004  #load heap address
	add $t7,$t4,$t5
	add $t7,$t7,$t0
	add $t7,$t7,$t1
	add $t6,$t6,$t7 #add all the iterators to get correct address
	beq $t9,3,PB_O  #if the data value loaded is 3 will draw O
	beq $t9,1,PB_X  #1 will draw X
	#BOX ONLY
	j PB_WHITE  #else just fill with white for empty box
PB_O:
	addi $t8,$zero,512  #checking if in rows 1, 2 (0 and 256)
	slt $s7,$t5,$t8
	beq $s7,1,PB_O_UP   #if yes, check further
	addi $t8,$zero,1280 #checking if in rows 7, 8 (1536 and 1792)
	slt $s7,$t8,$t5
	beq $s7,1,PB_O_UP   #if yes, check further
	addi $t8,$zero,8    #in remaining rows, check for columns 1, 2 (0 and 4)
	slt $s7,$t4,$t8
	beq $s7,1,PB_O_COND #if yes, fill color
	addi $t8,$zero,20   #checking for columns 7, 8 (24 and 28)
	slt $s7,$t8,$t4
	beq $s7,1,PB_O_COND #if yes, fill color
	j PB_WHITE
PB_O_UP:
	addi $t8,$zero,8    #checking for columns 1, 2 (0 and 4)
	slt $s7,$t4,$t8
	beq $s7,1,PB_WHITE  #if yes, filled with white
	addi $t8,$zero,20   #checking for columns 7, 8 (24 and 28)
	slt $s7,$t8,$t4
	beq $s7,1,PB_WHITE  #if yes, filled with white, the remaining is with color
PB_O_COND:
	lb $t8,($s3)    #load to determine which player shape
	beq $t8,1,PB_RED    #player 1 is O
	j PB_GOLD   #player 2 is O
PB_X:
	addi $t8,$zero,768  #checking if in rows 1-3 (0-512)
	slt $s7,$t5,$t8
	beq $s7,1,PB_X_UP   #if yes, check further
	addi $t8,$zero,1024 #checking if in rows 6-8 (1280-1792)
	slt $s7,$t8,$t5
	beq $s7,1,PB_X_UP   #if yes, check further
	addi $t8,$zero,12   #remaining rows, check for columns 1-3 (0-8)
	slt $s7,$t4,$t8
	beq $s7,1,PB_WHITE  #if yes, fill white
	addi $t8,$zero,16   #check for columns 6-8 (20-28)
	slt $s7,$t8,$t4
	beq $s7,1,PB_WHITE  #if yes, fill white
	j PB_X_COND #fill color with the remaining
PB_X_UP:
	addi $t8,$zero,12   #check for columns 1-3 (0-8)
	slt $s7,$t4,$t8
	beq $s7,1,PB_X_COND #if yes, fill color
	addi $t8,$zero,16   #check for columns 6-8 (20-28)
	slt $s7,$t8,$t4
	beq $s7,1,PB_X_COND #if yes, fill color
	j PB_WHITE
PB_X_COND:
	lb $t8,($s3)    #load to determine which player shape
	beq $t8,1,PB_GOLD   #if yes, X belongs to player 2
PB_RED:
	addi $t8,$zero,4    #get the second word for red
	lw $t7,ColorTable($t8)
	sw $t7,($t6)
	j PB_BOX_COND
PB_GOLD:
	addi $t8,$zero,8    #the third word for gold
	lw $t7,ColorTable($t8)
	sw $t7,($t6)
	j PB_BOX_COND
PB_WHITE:
	addi $t8,$zero,12   #the fourth word for white
	lw $t7,ColorTable($t8)
	sw $t7,($t6)
PB_BOX_COND:
	addi $t4,$t4,4  #the same condition as the background
	bne $t4,32,PB_CONT
	add $t4,$zero,$zero
	addi $t5,$t5,256
	bne $t5,2048,PB_CONT
PB_COND:
	addi $t3,$t3,1  #get another byte of data
	addi $t0,$t0,36 
	bne $t0,256,PB_OP
	addi $t0,$zero,4    #the outer column increase by 1 more pixel
	addi $t1,$t1,2304   #the outer row increase by 1 more pixel
	bne $t1,15104,PB_OP #6 row boxes
	addi $v0,$zero,4
	la $a0,eol
	syscall
	la $a0,tab
	syscall
	jr $ra

WIN_CHECK:
	addi $t0,$zero,0	#t0: row iterator	t1: column iterator	t2: row condition	t3: column condition & winning condition
	addi $t1,$zero,0	#t4: position variable	t5: continuous check	t6: X or O (1 X; 2 O)	t7: current value
	addi $t2,$zero,4	#t8: row pos		t9: column pos		a2: X high chance	a3: O high chance
	addi $t3,$zero,5
	addi $a0,$zero,7
	addi $a2,$zero,0    #a2: X high chance
	addi $a3,$zero,0    #a3: O high chance
WIN_CHECK_OP:
	#check diagonally left and right conditions first
	slt $a1,$t0,$t2 #if exceed these conditions, skip diagonally
	beq $a1,$zero,WIN_CHECK_HOR_REP
	slt $a1,$t1,$t3 #if exceed, skip also horizontally
	beq $a1,$zero,WIN_CHECK_VERT_REP
	#check diagonally left
	addi $t6,$zero,0    #preparing conditional variables
	addi $t5,$zero,0
	add $t8,$zero,$t0
	add $t9,$zero,$t1
WIN_CHECK_DIAG_L:
	mul $t4,$t8,$a0 #get the address of the byte
	add $t4,$t4,$t9
	lb $t7,midgame_rows($t4)
	beq $t7,0,WIN_CHECK_DIAG_R_REP  #if empty, go to another function
	beq $t7,1,WIN_CHECK_DIAG_L_X_CONT
	#O continuous
	beq $t6,1,WIN_CHECK_DIAG_R_REP  #is X, skip this iteration
	beq $t6,2,WIN_CHECK_DIAG_L_O_CONT_NEXT
	addi $t6,$zero,2
WIN_CHECK_DIAG_L_O_CONT_NEXT:
	addi $t5,$t5,1  #increase continuous
	beq $t5,4,O_WIN
	beq $t5,3,WIN_CHECK_DIAG_L_O_HIGH_CHANCE
	j WIN_CHECK_DIAG_L_COND
WIN_CHECK_DIAG_L_O_HIGH_CHANCE:
	addi $a3,$zero,1
	j WIN_CHECK_DIAG_L_COND
WIN_CHECK_DIAG_L_X_CONT:
	beq $t6,2,WIN_CHECK_DIAG_R_REP  #is O, skip this iteration
	beq $t6,1,WIN_CHECK_DIAG_L_X_CONT_NEXT
	addi $t6,$zero,1
WIN_CHECK_DIAG_L_X_CONT_NEXT:
	addi $t5,$t5,1
	beq $t5,4,X_WIN
	beq $t5,3,WIN_CHECK_DIAG_L_X_HIGH_CHANCE
	j WIN_CHECK_DIAG_L_COND
WIN_CHECK_DIAG_L_X_HIGH_CHANCE:
	addi $a2,$zero,1
WIN_CHECK_DIAG_L_COND:
	addi $t8,$t8,1  #another round
	addi $t9,$t9,1  #until empty
	beq $t8,6,WIN_CHECK_DIAG_R_REP  #or exceed 6 rows
	beq $t9,$a0,WIN_CHECK_DIAG_R_REP    #or exceed 7 columns
	j WIN_CHECK_DIAG_L
	#check diagonally from right
WIN_CHECK_DIAG_R_REP:
	addi $t6,$zero,0    #again, preparing conditional variables
	addi $t5,$zero,0
	add $t8,$zero,$t0
	ori $t9,$zero,6 #start from right to left
	sub $t9,$t9,$t1 #subtract to have corresponding position
WIN_CHECK_DIAG_R:
	mul $t4,$t8,$a0
	add $t4,$t4,$t9
	lb $t7,midgame_rows($t4)    #get adress of the current byte
	beq $t7,0,WIN_CHECK_HOR_REP #is empty, skip
	beq $t7,1,WIN_CHECK_DIAG_R_X_CONT
	#O continuous
	beq $t6,1,WIN_CHECK_HOR_REP #is X, skip
	beq $t6,2,WIN_CHECK_DIAG_R_O_CONT_NEXT
	addi $t6,$zero,2
WIN_CHECK_DIAG_R_O_CONT_NEXT:
	addi $t5,$t5,1
	beq $t5,4,O_WIN
	beq $t5,3,WIN_CHECK_DIAG_R_O_HIGH_CHANCE
	j WIN_CHECK_DIAG_R_COND
WIN_CHECK_DIAG_R_O_HIGH_CHANCE:
	addi $a3,$zero,1
	j WIN_CHECK_DIAG_R_COND
WIN_CHECK_DIAG_R_X_CONT:
	beq $t6,2,WIN_CHECK_HOR_REP #is O, skip
	beq $t6,1,WIN_CHECK_DIAG_R_X_CONT_NEXT 
	addi $t6,$zero,1
WIN_CHECK_DIAG_R_X_CONT_NEXT:
	addi $t5,$t5,1
	beq $t5,4,X_WIN
	beq $t5,3,WIN_CHECK_DIAG_R_X_HIGH_CHANCE
	j WIN_CHECK_DIAG_R_COND
WIN_CHECK_DIAG_R_X_HIGH_CHANCE:
	addi $a2,$zero,1
WIN_CHECK_DIAG_R_COND:
	addi $t8,$t8,1  #increase row but decrease column
	addi $t9,$t9,-1
	beq $t8,6,WIN_CHECK_HOR_REP #exceed row, skip
	beq $t9,-1,WIN_CHECK_HOR_REP    #exceed column, skip
	j WIN_CHECK_DIAG_R
WIN_CHECK_HOR_REP:
	slt $a1,$t1,$t3
	beq $a1,$zero,WIN_CHECK_VERT_REP    #exceed conditions, skip to vertical
	addi $t6,$zero,0    #preparing conditional variables
	addi $t5,$zero,0
	add $t8,$zero,$t0
	add $t9,$zero,$t1
WIN_CHECK_HOR:
	mul $t4,$t8,$a0
	add $t4,$t4,$t9
	lb $t7,midgame_rows($t4)
	beq $t7,0,WIN_CHECK_VERT_REP    #empty, skip
	beq $t7,1,WIN_CHECK_HOR_X_CONT
	#O continuous
	beq $t6,1,WIN_CHECK_VERT_REP    #is X, skip
	beq $t6,2,WIN_CHECK_HOR_O_CONT_NEXT
	addi $t6,$zero,2
WIN_CHECK_HOR_O_CONT_NEXT:
	addi $t5,$t5,1
	beq $t5,4,O_WIN
	beq $t5,3,WIN_CHECK_HOR_O_HIGH_CHANCE
	j WIN_CHECK_HOR_COND
WIN_CHECK_HOR_O_HIGH_CHANCE:
	addi $a3,$zero,1
	j WIN_CHECK_HOR_COND
WIN_CHECK_HOR_X_CONT:
	beq $t6,2,WIN_CHECK_VERT_REP    #is O, skip
	beq $t6,1,WIN_CHECK_HOR_X_CONT_NEXT
	addi $t6,$zero,1
WIN_CHECK_HOR_X_CONT_NEXT:
	addi $t5,$t5,1
	beq $t5,4,X_WIN
	beq $t5,3,WIN_CHECK_HOR_X_HIGH_CHANCE
	j WIN_CHECK_HOR_COND
WIN_CHECK_HOR_X_HIGH_CHANCE:
	addi $a2,$zero,1
WIN_CHECK_HOR_COND:
	addi $t9,$t9,1  #increase column
	beq $t9,$a0,WIN_CHECK_VERT_REP
	j WIN_CHECK_HOR
WIN_CHECK_VERT_REP:
	slt $a1,$t0,$t2
	beq $a1,$zero,WIN_CHECK_COND    #exceed condition, skip
	addi $t6,$zero,0    #preparing conditional variables
	addi $t5,$zero,0
	add $t8,$zero,$t0
	add $t9,$zero,$t1
WIN_CHECK_VERT:
	mul $t4,$t8,$a0 #get the correct address
	add $t4,$t4,$t9
	lb $t7,midgame_rows($t4)    #get byte
	beq $t7,0,WIN_CHECK_COND    #empty, skip
	beq $t7,1,WIN_CHECK_VERT_X_CONT
	#O continuous
	beq $t6,1,WIN_CHECK_COND    #is X, skip
	beq $t6,2,WIN_CHECK_VERT_O_CONT_NEXT
	addi $t6,$zero,2
WIN_CHECK_VERT_O_CONT_NEXT:
	addi $t5,$t5,1
	beq $t5,4,O_WIN
	beq $t5,3,WIN_CHECK_VERT_O_HIGH_CHANCE
	j WIN_CHECK_VERT_COND
WIN_CHECK_VERT_O_HIGH_CHANCE:
	addi $a3,$zero,1
	j WIN_CHECK_VERT_COND
WIN_CHECK_VERT_X_CONT:
	beq $t6,2,WIN_CHECK_COND    #is O, skip
	beq $t6,1,WIN_CHECK_VERT_X_CONT_NEXT
	addi $t6,$zero,1
WIN_CHECK_VERT_X_CONT_NEXT:
	addi $t5,$t5,1
	beq $t5,4,X_WIN
	beq $t5,3,WIN_CHECK_VERT_X_HIGH_CHANCE
	j WIN_CHECK_VERT_COND
WIN_CHECK_VERT_X_HIGH_CHANCE:
	addi $a2,$zero,1
WIN_CHECK_VERT_COND:
	addi $t8,$t8,1  #increase the row
	bne $t8,6,WIN_CHECK_VERT
WIN_CHECK_COND:
	addi $t1,$t1,1
	bne $t1,7,WIN_CHECK_OP  #condition checking for iteration
	addi $t1,$zero,0
	addi $t0,$t0,1
	bne $t0,6,WIN_CHECK_OP
	#begin checking for the tie condition
	add $t0,$zero,$zero
	add $t1,$zero,$zero
TIE_CHECK_OP:
	lb $t2,midgame_rows($t1)    #load  byte
	beq $t2,0,TIE_CHECK_EXIT   #if empty, return to game
	addi $t0,$t0,1
	addi $t1,$t1,1  #increase the iterator by 1
	bne $t1,42,TIE_CHECK_OP #condition checking
	beq $t0,$t1,TIE
TIE_CHECK_EXIT:
	jr $ra

TIE:
	addi $v0,$zero,4
	la $a0,game_tie #the game is tied
	syscall
	j END_GAME

PROC_MOVE1:
	addi $v0,$zero,4
	lb $t0,($s2)
	la $a0,start_player1
	syscall #signifying player 1's turn
	la $a0,space
	syscall
	la $a0,start_your_turn
	syscall
	la $a0,start_input_first_move
	syscall #this is your first move
	la $a0,start_input
	syscall
	addi $v0,$zero,8
	la $a0,misc_mem
	addi $a1,$zero,2
	syscall
	addi $v0,$zero,4
	lb $t3,($a0)
	la $a0,eol
	syscall
	addi $t0,$zero,82   #trying to use ability is violation
	beq $t3,$t0,PROC_ERR_ABILITY_M1
	addi $t0,$zero,66
	beq $t3,$t0,PROC_ERR_ABILITY_M1
	addi $t0,$zero,52   #not column 4 is violation
	bne $t3,$t0,PROC_ERR_M1
	lb $t1,($s3)
	addi $t2,$zero,1
	addi $t3,$zero,3
	beq $t1,0,M1_X_SET  #set according to their pieces
	sb $t3,38($s0)  #set to (3,5)
	jr $ra
M1_X_SET:
	sb $t2,38($s0)	#set to column (3,5)
	jr $ra

PROC_MOVE2:
	addi $v0,$zero,4
	lb $t0,($s2)
	la $a0,start_player2
	syscall	#signifying player 2's turn
	la $a0,space
	syscall
	la $a0,start_your_turn
	syscall
	la $a0,start_input_first_move
	syscall	#this is your first move
	la $a0,start_input
	syscall
	addi $v0,$zero,8
	la $a0,misc_mem
	addi $a1,$zero,2
	syscall
	addi $v0,$zero,4
	lb $t3,($a0)
	la $a0,eol
	syscall
	addi $t0,$zero,82	#trying to use ability is violation
	beq $t3,$t0,PROC_ERR_ABILITY_M2
	addi $t0,$zero,66
	beq $t3,$t0,PROC_ERR_ABILITY_M2
	addi $t0,$zero,52	#not column 4 is violation
	bne $t3,$t0,PROC_ERR_M2
	lb $t1,($s3)
	addi $t2,$zero,1
	addi $t3,$zero,3
	beq $t1,1,M2_X_SET	#set according to their pieces
	sb $t3,31($s0)	#set to (3,4)
	jr $ra
M2_X_SET:
	sb $t2,31($s0)	#set to column (3,4)
	jr $ra

PROCESS:
	#backup the entire data set
	add $t0,$zero,$zero
	addi $t1,$zero,52
	beq $s6,$zero,BACKUP_OP #s6 means someone have recently used undo
	addi $v0,$zero,4
	la $a0,start_input_undo_success
	syscall
	la $a0,tab
	syscall
	add $s6,$zero,$zero
BACKUP_OP:
	lb $t2,midgame_rows($t0)
	sb $t2,backup_data($t0)
	addi $t0,$t0,1
	bne $t0,$t1,BACKUP_OP
	#checking for whose turn, is blocked or not
	addi $v0,$zero,4
	lb $t0,($s2)
	beq $t0,1,P2_TURN
	lb $t0,8($s1)
	beq $t0,$zero,P1_TURN
	la $a0,start_player1
	syscall
	la $a0,space
	syscall
	la $a0,start_is_blocked
	syscall
	addi $t0,$zero,1    #is blocked, so change turn to another player 2's
	sb $t0,($s2)
	sb $zero,8($s1) #already lost a move, return the normal status
	j P2_TURN_START
P1_TURN:
	addi $v0,$zero,4
	la $a0,start_player1
	syscall
	la $a0,space
	syscall
	la $a0,start_your_turn
	syscall
	lb $t0,1($s1)
	beq $t0,$zero,P1_SKIP_REM   #if used remove, do not print use remove
	la $a0,start_input_remove
	syscall
P1_SKIP_REM:
	lb $t0,2($s1)
	beq $t0,$zero,PROC_CONT
	la $a0,start_input_block    #if used block, do not print use block
	syscall
	j PROC_CONT
P2_TURN:
	addi $v0,$zero,4    #checking if p2 is blocked or not
	lb $t0,9($s1)
	beq $t0,$zero,P2_TURN_START
	la $a0,start_player2
	syscall
	la $a0,space
	syscall
	la $a0,start_is_blocked
	syscall
	sb $zero,($s2)  #change turn to p1's
	sb $zero,9($s1) #blocked, changed turn so return p2 the normal status
	j P1_TURN
P2_TURN_START:
	addi $v0,$zero,4
	la $a0,start_player2
	syscall
	la $a0,space
	syscall
	la $a0,start_your_turn
	syscall
	lb $t0,5($s1)
	beq $t0,$zero,P2_SKIP_REM   #if used remove, dont print use remove
	la $a0,start_input_remove
	syscall
P2_SKIP_REM:
	lb $t0,6($s1)
	beq $t0,$zero,PROC_CONT #if used block, dont print use block
	la $a0,start_input_block
	syscall
PROC_CONT:
	la $a0,start_input
	syscall
	addi $v0,$zero,8
	la $a0,misc_mem
	addi $a1,$zero,2    #input column or ability to use
	syscall
	addi $v0,$zero,4
	lb $t3,($a0)
	la $a0,eol
	syscall
	addi $t0,$zero,82   #82 is R
	beq $t3,$t0,PROC_REM
	addi $t0,$zero,66   #66 is B
	bne $t3,$t0,PROC_SKIP_BLOCK
	#block opponent
	addi $v0,$zero,4
	lb $t0,($s2)
	beq $t0,$zero,PROC_P1_BLOCK_P2
	#P2 block P1
	lb $t0,6($s1)
	beq $t0,$zero,PROC_ERR_USED #check if it is used or not
	lb $t9,($s3)
	beq $t9,$zero,PROC_P2_BLOCK_P1_X	#P1 is X
	bne $a3,$zero,PROC_ERR_BLOCK	#P1 is O so if P1 have high chance, cant block
	j PROC_P2_BLOCK_P1_SKIP
PROC_P2_BLOCK_P1_X:
	bne $a2,$zero,PROC_ERR_BLOCK    #P1 is X so if P1 have high chance, cant block
PROC_P2_BLOCK_P1_SKIP:
	sb $zero,6($s1)
	addi $t0,$zero,1
	sb $t0,8($s1)
	addi $v0,$zero,4
	la $a0,start_block_success
	syscall #block success, get to drop a piece before end turn
	lb $t0,4($s1)
	beq $t0,$zero,P2_TURN_START
	la $a0,start_confirm_setting    #asked if the player wanted to undo or not
	syscall
	addi $v0,$zero,8
	addi $a1,$zero,2
	la $a0,misc_mem
	syscall
	lb $t0,($a0)
	addi $t1,$zero,49
	bne $t0,$t1,PROCESS
	lb $t0,backup_data+46   #wanted undo, so decrease number of undo before reloading data
	addi $t0,$t0,-1
	sb $t0,backup_data+46
	j UNDO
PROC_P1_BLOCK_P2:
	lb $t0,2($s1)
	beq $t0,$zero,PROC_ERR_USED
	lb $t9,($s3)
	bne $t9,$zero,PROC_P1_BLOCK_P2_X	#P2 is X
	bne $a3,$zero,PROC_ERR_BLOCK	#P2 is O so if P2 have high chance, cant block
	j PROC_P1_BLOCK_P2_SKIP
PROC_P1_BLOCK_P2_X:
	bne $a2,$zero,PROC_ERR_BLOCK    #P2 is X so if P2 have high chance, cant block
PROC_P1_BLOCK_P2_SKIP:
	sb $zero,2($s1)
	addi $t0,$zero,1
	sb $t0,9($s1)
	addi $v0,$zero,4
	la $a0,start_block_success
	syscall #block success, get to drop a piece before end turn
	lb $t0,($s1)
	beq $t0,$zero,P1_TURN
	la $a0,start_confirm_setting    #asked if the player wanted to undo or not
	syscall
	addi $v0,$zero,8
	addi $a1,$zero,2
	la $a0,misc_mem
	syscall
	lb $t0,($a0)
	addi $t1,$zero,49
	bne $t0,$t1,PROCESS
	lb $t0,backup_data+42   #wanted undo, so decrease number of undo before reloading data
	addi $t0,$t0,-1
	sb $t0,backup_data+42
	j UNDO
PROC_SKIP_BLOCK:
	addi $t0,$zero,49   #drop pieces normally
	addi $t1,$zero,55
	slt $t2,$t3,$t0	#row format checking
	bne $t2,$zero,PROC_ERR
	slt $t2,$t1,$t3
	bne $t2,$zero,PROC_ERR
	#check whether the column is full or not
	addi $t5,$t3,-7
PROC_LOOP2:	#Loop2: find empty spot
	addi $t5,$t5,-7
	slt $t1,$t5,$zero
	bne $t1,$zero,PROC_ERR_FULL_ROW
	lb $t7,midgame_rows($t5)
	beq $t7,0,PROC_LOOP2_EXIT
	j PROC_LOOP2
PROC_LOOP2_EXIT:
	lb $t0,($s2)
	lb $t1,($s3)
	addi $t2,$zero,1
	addi $t3,$zero,3
	beq $t0,1,P2_SET    #set location according to player
	beq $t1,0,X_SET #set location according to piece
	j O_SET
P2_SET:
	beq $t1,1,X_SET
O_SET:
	sb $t3,midgame_rows($t5)    #set location
	j PROC_CONT_CHECK
X_SET:
	sb $t2,midgame_rows($t5)
PROC_CONT_CHECK:
	lb $t0,($s2)	#check whose turn is it
	beq $t0,$zero,P1_TURN_UNDO
	lb $t0,4($s1)   #check if p2 have any undo left
	beq $t0,$zero,PROC_EXIT
	jal PRINT_GUI   #if yes, print GUI and board again
	jal PRINT_BOARD #then ask if he wanted to undo or not
	addi $v0,$zero,4
	la $a0,start_input_undo_ask
	syscall
	la $a0,start_confirm_setting
	syscall
	addi $v0,$zero,8
	la $a0,misc_mem
	addi $a1,$zero,2
	syscall
	lb $t0,($a0)
	addi $t1,$zero,49
	bne $t0,$t1,PROC_EXIT
	lb $t2,backup_data+46   #if yes, reduce number of undo and reload data
	addi $t2,$t2,-1
	sb $t2,backup_data+46
	j UNDO
P1_TURN_UNDO:
	lb $t0,($s1)    #check if p1 have any undo left
	beq $t0,$zero,PROC_EXIT
	jal PRINT_GUI   #if yes, print GUI and board again
	jal PRINT_BOARD #then ask if he wanted to undo or not
	addi $v0,$zero,4
	la $a0,start_input_undo_ask
	syscall
	la $a0,start_confirm_setting
	syscall
	addi $v0,$zero,8
	la $a0,misc_mem
	addi $a1,$zero,2
	syscall
	lb $t0,($a0)
	addi $t1,$zero,49
	bne $t0,$t1,PROC_EXIT
	lb $t2,backup_data+42   #if yes, reduce number of undo and reload data
	addi $t2,$t2,-1
	sb $t2,backup_data+42
UNDO:
	add $t0,$zero,$zero #undo iterator
	addi $t1,$zero,52   #undo loop condition
UNDO_OP:
	lb $t2,backup_data($t0) #load in backup and restore
	sb $t2,midgame_rows($t0)
	addi $t0,$t0,1
	bne $t0,$t1,UNDO_OP
	addi $s6,$zero,1
	jal PRINT_GUI
	jal PRINT_BOARD
	j PROCESS
PROC_EXIT:
	j CHECK_CHECK   #check winning condition and change turns

PROC_REM:
	lb $t0,($s2)    #check for whose turn
	beq $t0,$zero,P1_REMOVE #if it is P1's, its their removal
	#P2 remove
	lb $t0,5($s1)   #load the byte to check if it is used up
	beq $t0,$zero,PROC_ERR_USED
	addi $v0,$zero,4
	la $a0,start_input_remove_coordinate
	syscall
	la $a0,remove_coordinate_x
	syscall
	addi $v0,$zero,8    #enter the X coordinate
	la $a0,misc_mem
	addi $a1,$zero,2
	syscall
	lb $t1,($a0)
	addi $v0,$zero,4
	la $a0,eol
	syscall
	la $a0,remove_coordinate_y
	syscall
	addi $v0,$zero,8    #enter the Y coordinate
	la $a0,misc_mem
	syscall
	lb $t2,($a0)
	addi $v0,$zero,4
	la $a0,eol
	syscall
	slt $t5,$t1,$t4
	bne $t5,$zero,PROC_ERR
	addi $t4,$zero,54   #if row is not in range of 1-6, error
	slt $t5,$t4,$t1
	bne $t5,$zero,PROC_ERR
	addi $t4,$zero,49
	slt $t5,$t2,$t4
	bne $t5,$zero,PROC_ERR
	addi $t4,$zero,55   #if column is not in range of 1-7, error
	slt $t5,$t4,$t2
	bne $t5,$zero,PROC_ERR
	#load to check if it belongs to the other player or current player
	addi $t1,$t1,-49
	addi $t2,$t2,-49
	addi $t3,$zero,7
	mul $t5,$t1,$t3
	add $t5,$t5,$t2
	lb $t4,midgame_rows($t5)
	lb $t7,($s3)    #load X-O
	beq $t7,$zero,P2O_REM
	addi $t6,$zero,1    #P2 is X
	j P2REM_CONT
P2O_REM:
	addi $t6,$zero,3
P2REM_CONT:
	beq $t6,$t4,PROC_ERR_YOURS  #if it is current player's piece, error
	beq $zero,$t4,PROC_ERR_EMPTY    #if it is empty, error
	sb $zero,5($s1) #else, success and deplete the use
	sb $zero,midgame_rows($t5)
	j REMOVED_SUCCESSFULLY
P1_REMOVE:
	lb $t0,1($s1)   #load the byte to check if it is used up
	beq $t0,$zero,PROC_ERR_USED
	addi $v0,$zero,4
	la $a0,start_input_remove_coordinate
	syscall
	la $a0,remove_coordinate_x
	syscall
	addi $v0,$zero,8    #input the X coordinate
	la $a0,misc_mem
	addi $a1,$zero,2
	syscall
	lb $t1,($a0)
	addi $v0,$zero,4
	la $a0,eol
	syscall
	la $a0,remove_coordinate_y
	syscall
	addi $v0,$zero,8    #input the Y coordinate
	la $a0,misc_mem
	syscall
	lb $t2,($a0)
	addi $v0,$zero,4
	la $a0,eol
	syscall
	slt $t5,$t1,$t4
	bne $t5,$zero,PROC_ERR
	addi $t4,$zero,54   #if row is not in range of 1-6, error
	slt $t5,$t4,$t1
	bne $t5,$zero,PROC_ERR
	addi $t4,$zero,49
	slt $t5,$t2,$t4
	bne $t5,$zero,PROC_ERR
	addi $t4,$zero,55   #if column is not in range of 1-7, error
	slt $t5,$t4,$t2
	bne $t5,$zero,PROC_ERR
	#load to check if it belongs to the other player or current player
	addi $t1,$t1,-49
	addi $t2,$t2,-49
	addi $t3,$zero,7
	mul $t5,$t1,$t3
	add $t5,$t5,$t2
	lb $t4,midgame_rows($t5)
	lb $t7,($s3)    #load X-O
	beq $t7,$zero,P1X_REM
	addi $t6,$zero,3    #P1 is O
	j P1REM_CONT
P1X_REM:
	addi $t6,$zero,1
P1REM_CONT:
	beq $t6,$t4,PROC_ERR_YOURS  #if it is current player's piece, error
	beq $zero,$t4,PROC_ERR_EMPTY    #if it is empty, error
	sb $zero,1($s1)  #else, success and deplete the use
	sb $zero,midgame_rows($t5)
REMOVED_SUCCESSFULLY:
	addi $v0,$zero,4
	la $a0,remove_success
	syscall
	addi $t0,$zero,6    #initialize condition to check for block falling, t0 is the last column
	addi $t1,$zero,5    #check last row first
	addi $t2,$zero,7
REM_SUC_OP:
	add $t5,$zero,$t1
REM_SUC_FALLS:
	mul $t3,$t2,$t5
	add $t3,$t3,$t0
	lb $t4,midgame_rows($t3)
	bne $t4,$zero,REM_SUC_COND  #if the place is occupied, skip
	addi $t6,$t3,-7 #the place is empty, check for any row above it is empty
	slt $t7,$t6,$zero   #stopping condition is when check full of row
	addi $t8,$zero,1
	beq $t7,$t8,REM_SUC_COND
	lb $t9,midgame_rows($t6)    #load the byte on top of the previously checked byte
	beq $t9,$zero,REM_SUC_COND  #if empty, skip
	sb $t9,midgame_rows($t3)    #not empty, falls down
	sb $zero,midgame_rows($t6)
	addi $t5,$t5,-1
	j REM_SUC_FALLS #also, check again to be sure
REM_SUC_COND:
	beq $t0,$zero,REM_SUC_OUT_COND
	addi $t0,$t0,-1 #gradually move to top
	j REM_SUC_OP
REM_SUC_OUT_COND:
	addi $t1,$t1,-1 #jump to adjacent left column
	beq $t1,$zero,REM_SUC_EXIT
	addi $t0,$zero,6    #recheck from bottom
	j REM_SUC_OP
REM_SUC_EXIT:
	j PROC_CONT_CHECK   #return to check the undo

PROC_ERR_ABILITY_M1:
	addi $v0,$zero,4
	la $a0,error_first
	syscall
	j RULES_VIOLATED_M1

PROC_ERR_M1:
	addi $v0,$zero,4
	la $a0,error_wrong_string
	syscall
	j RULES_VIOLATED_M1

RULES_VIOLATED_M1:
	la $a0,start_game
	syscall
	addi $v0,$zero,8
	la $a0,misc_mem
	addi $a1,$zero,1
	syscall
	lb $t0,($s2)
	beq $t0,$zero,PROC_ERR_P1_M1
	#player 2 is violating rules
	lb $t0,7($s1)
	addi $t0,$t0,1
	addi $t1,$zero,3
	beq $t0,$t1,P2_VIO_LOST
	sb $t0,7($s1)
	j MOVE1
PROC_ERR_P1_M1:
	lb $t0,3($s1)
	addi $t0,$t0,1
	addi $t1,$zero,3
	beq $t0,$t1,P1_VIO_LOST
	sb $t0,3($s1)
	j MOVE1

PROC_ERR_ABILITY_M2:
	addi $v0,$zero,4
	la $a0,error_first
	syscall
	j RULES_VIOLATED_M2

PROC_ERR_M2:
	addi $v0,$zero,4
	la $a0,error_wrong_string
	syscall
	j RULES_VIOLATED_M2

RULES_VIOLATED_M2:
	la $a0,start_game
	syscall
	addi $v0,$zero,8
	la $a0,misc_mem
	addi $a1,$zero,1
	syscall
	lb $t0,($s2)
	beq $t0,$zero,PROC_ERR_P1_M2
	#player 2 is violating rules
	lb $t0,7($s1)
	addi $t0,$t0,1
	addi $t1,$zero,3
	beq $t0,$t1,P2_VIO_LOST
	sb $t0,7($s1)
	j MOVE2
PROC_ERR_P1_M2:
	lb $t0,3($s1)
	addi $t0,$t0,1
	addi $t1,$zero,3
	beq $t0,$t1,P1_VIO_LOST
	sb $t0,3($s1)
	j MOVE2

PROC_ERR_YOURS:
	#the piece is yours, can't remove
	addi $v0,$zero,4
	la $a0,error_yours
	syscall
	j RULES_VIOLATED

PROC_ERR_EMPTY:
	#location is empty, can't remove
	addi $v0,$zero,4
	la $a0,error_empty
	syscall
	j RULES_VIOLATED

PROC_ERR_FULL_ROW:
    #column is full
	addi $v0,$zero,4
	la $a0,error_full_row
	syscall
	j RULES_VIOLATED

PROC_ERR_BLOCK:
	#high chance of winning, cant block
	addi $v0,$zero,4
	la $a0,error_block
	syscall
	j RULES_VIOLATED

PROC_ERR_USED:
	#already used up the ability
	addi $v0,$zero,4
	la $a0,error_used
	syscall
	j RULES_VIOLATED

PROC_ERR:
	# wrong format error handling
	addi $v0,$zero,4
	la $a0,error_wrong_string
	syscall
	j RULES_VIOLATED

RULES_VIOLATED:
	la $a0,start_game   #press anykey to continue
	syscall
	addi $v0,$zero,8
	la $a0,misc_mem
	addi $a1,$zero,1
	syscall
	lb $t0,($s2)    #checking for whose turn to know who violates
	beq $t0,$zero,PROC_ERR_P1   #the code for p1 is similar to p2
	#player 2 is violating rules
	lb $t0,7($s1)   #get and increase the number of violation
	addi $t0,$t0,1
	addi $t1,$zero,3
	beq $t0,$t1,P2_VIO_LOST #if equal to 3, p2 lost
	sb $t0,7($s1)
	j MID_GAME
PROC_ERR_P1:
	lb $t0,3($s1)
	addi $t0,$t0,1
	addi $t1,$zero,3
	beq $t0,$t1,P1_VIO_LOST
	sb $t0,3($s1)
	j MID_GAME

P1_VIO_LOST:
	addi $v0,$zero,4    #p1 is lost due to 3 violations
	la $a0,start_player1    #this function is invoked by rule violation function
	syscall
	la $a0,space
	syscall
	la $a0,midgame_name1
	syscall
	la $a0,eol
	syscall
	la $a0,lose_violation
	syscall
	j P2_WIN

P2_VIO_LOST:
	addi $v0,$zero,4    #p2 is lost due to 3 violations
	la $a0,start_player2    #this function is invoked by rule violation function
	syscall
	la $a0,space
	syscall
	la $a0,midgame_name2
	syscall
	la $a0,eol
	syscall
	la $a0,lose_violation
	syscall
	j P1_WIN

X_WIN:
	lb $t0,($s3)    #this function is invoked by the winning condition checking function 
	beq $t0,0,P1_WIN
	j P2_WIN

O_WIN:
	lb $t0,($s3)    #this function is invoked by the winning condition checking function
	beq $t0,1,P1_WIN
	j P2_WIN

P1_WIN:
	addi $v0,$zero,4    #announce that p1 wins
	la $a0,start_player1
	syscall
	la $a0,space
	syscall
	la $a0,midgame_name1
	syscall
	la $a0,space
	syscall
	la $a0,wins
	syscall
	j END_GAME

P2_WIN:
	addi $v0,$zero,4    #announce that p2 wins
	la $a0,start_player2
	syscall
	la $a0,space
	syscall
	la $a0,midgame_name2
	syscall
	la $a0,space
	syscall
	la $a0,wins
	syscall
	j END_GAME

PRINT_GUI:
	addi $v0,$zero,4
	la $a0,tab  #indentation and print the first line as players names.
	syscall
	la $a0,start_player1
	syscall
	la $a0,space
	syscall
	la $a0,midgame_name1    #load their name address stored in memory
	syscall
	la $a0,tab
	syscall
	la $a0,start_player2
	syscall
	la $a0,space
	syscall
	la $a0,midgame_name2
	syscall
	la $a0,eol
	syscall
	la $a0,tab
	syscall
	lb $t0,($s3)    #load value to determine which player is X, which is O
	bne $t0,$zero,PG_1O #branch accordingly
PG_1X:
	la $a0,start_player_x   #print their pieces right below their names.
	syscall
	la $a0,tab
	syscall
	syscall
	la $a0,start_player_o
	syscall
	j PG_CONT   #skip the case of Player 1 is O and print undo and violation
PG_1O:
	la $a0,start_player_o
	syscall
	la $a0,tab
	syscall
	syscall
	la $a0,start_player_x
	syscall
PG_CONT:
	addi $v0,$zero,4
	la $a0,eol
	syscall
	la $a0,undo #print the announcement of undo left
	syscall
	la $a0,tab
	syscall
	addi $v0,$zero,1    #print the number of undo right below players' pieces
	lb $a0,($s1)    #the number of undo of player 1
	syscall
	addi $v0,$zero,4
	la $a0,tab
	syscall
	syscall
	addi $v0,$zero,1
	lb $a0,4($s1)   #the number of undo of player 2
	syscall
	addi $v0,$zero,4
	la $a0,eol
	syscall
	la $a0,violation    #the announcement for violation numbers
	syscall
	la $a0,tab
	syscall
	addi $v0,$zero,1    #again, print out the number of violation of each player right below their number of undo left
	lb $a0,3($s1)   #the number of violation of player 1
	syscall
	addi $v0,$zero,4
	la $a0,tab
	syscall
	syscall
	addi $v0,$zero,1
	lb $a0,7($s1)   #the number of violations of player 2
	syscall
	jr $ra
