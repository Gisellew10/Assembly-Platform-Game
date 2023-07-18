#####################################################################
#
# CSCB58 Summer 2023 Assembly Final Project
# University of Toronto, Scarborough
#
# Student: Giselle Wang
#
# Bitmap Display Configuration:
# - Unit width in pixels: 8 (update this as needed)
# - Unit height in pixels: 8 (update this as needed)
# - Display width in pixels: 512 (update this as needed)
# - Display height in pixels: 512 (update this as needed)
# - Base Address for Display: 0x10008000 ($gp)
#
# Which milestones have been reached in this submission?
# (See the assignment handout for descriptions of the milestones)
# - Milestone 3
#
# Which approved features have been implemented for milestone 3?
# (See the assignment handout for the list of additional features)
# 1. Health, track and show player health on screen
# 2. Win condition
# 3. Fail condition
# 4. Moving objects: Enemies patrol vertically
# 5. Double jump
# 6. Start menu
# 7. Disapearing and reappearing platforms
# ... (add more if necessary)
#
# Link to video demonstration for final submission:
# - (insert YouTube / MyMedia / other URL here). Make sure we can view it!
# YouTube: https://youtu.be/QEdpLzUSg5Y
#
# Are you OK with us sharing the video with people outside course staff?
# - yes / no / yes, and please share this project github link as well!
# # no
#
# Any additional information that the TA needs to know:
# - (write here, if any)
#
#####################################################################


.eqv BASE_ADDRESS 0x10008000
.eqv AZURE        0x5dade2
.eqv INDIGO       0x6600ff
.eqv PINK         0xcc3366
.eqv YELLOW       0xffff00
.eqv GREEN        0x9ccc65
.eqv ORANGE       0xffa000
.eqv RED          0xff0000
.eqv WHITE        0xffffff
.eqv BLACK        0x000000
.eqv GREY         0xaab7b8    
.eqv BLUE         0x66ffff 
.eqv LIME         0xccff00 
.eqv DARK_BLUE    0x0000ff
.eqv GREEN1 0xc8e6c9
.eqv GREEN2 0xa5d6a7
.eqv GREEN3 0x81c784
.eqv GREEN4 0x66bb6a
.eqv GREEN5 0x4caf4f
.eqv LEFT 97
.eqv RIGHT 100
.eqv UP 119
.eqv DOWN 115
.eqv P 112
.eqv Y 121
.eqv N 110
.eqv JUMP_FALL_TIME 100

.data
HEART:      .word    0x1000893c 0x10008838 0x10008840
STAR:       .word    0x1000b1f0 0x1000b0ec 0x1000b0f4
PLAYER:     .word    0x1000b314 0x1000b318 0x1000b210 0x1000b214 
HEALTH_BAR: .word    492
HEALTH:     .word    4
ENEMY:	    .word    420
ENEMY2:	    .word    452
FREEZE:	    .word    0

.text
.globl main

main: 
	#Start of the game
	j start_menu
	
start_menu:
	li $t0, BASE_ADDRESS
	
	jal black_screen
	j draw_start
	
black_screen:
	li $t1, BLACK
	add $t3, $t0, 16384 #load last pixel offset
	add $t4, $t0, 0 #load first pixel offset
	
	# use the loop to clear the screen
	clear_screen_loop: 
	bge $t4, $t3, clear_screen_done
	sw $t1, 0($t4)
	add $t4, $t4, 4
	j clear_screen_loop
	
	clear_screen_done:
	jr $ra
	
respond_to_n:
	# terminate the program gracefully
	li $v0, 10
	syscall
		
	li $t0, BASE_ADDRESS
	
	
# ------------------------------------------------------------------------
#Initialize player, platforms, and objects at the start of the game

reset:
	li $t0, BASE_ADDRESS
	
	jal black_screen
	
	
	# Reset player
	li $t1, GREEN
	la $t2, PLAYER
	
	# Read location of player, let $t6-9 store the offset
	# [ t8 | t9 ]
	     # [ t6 | t7 ]
	
	add $t6, $zero, 0x1000b314
	add $t7, $zero, 0x1000b318
	add $t8, $zero, 0x1000b210
	add $t9, $zero, 0x1000b214 
	
	# Save to array
	sw $t6, 0($t2)
	sw $t7, 4($t2)
	sw $t8, 8($t2)
	sw $t9, 12($t2)
  
  	#Draw player
  	lw $t3, 0($t2)
  	sw $t1, 0($t3)
  	lw $t3, 4($t2)
  	sw $t1, 0($t3)
  	lw $t3, 8($t2)
  	sw $t1, 0($t3)
  	lw $t3, 12($t2)
  	sw $t1, 0($t3)
	
	
	#Draw heart
	li $t1, RED
	la $t2, HEART
  
  	lw $t3, 0($t2)
  	sw $t1, 0($t3)
  	lw $t3, 4($t2)
  	sw $t1, 0($t3)
  	lw $t3, 8($t2)
  	sw $t1, 0($t3)
  	
  	#Draw stars
  	li $t1, YELLOW
	la $t2, STAR
 
  	lw $t3, 0($t2)
  	sw $t1, 0($t3)
  	lw $t3, 4($t2)
  	sw $t1, 0($t3)
  	lw $t3, 8($t2)
  	sw $t1, 0($t3)
  	  	
  	# Health bar
  	li $t1, ORANGE
	sw $t1,	504($t0)
	sw $t1,	500($t0)
	sw $t1,	496($t0)
	sw $t1,	492($t0)
	
	# Reset Health
	la $t5, HEALTH
	addi $t6, $zero, 4
	sw $t6, 0($t5)
	
	# Reset Freeze
	la $t5, FREEZE
	addi $t6, $zero, 0
	sw $t6, 0($t5)
	
  
  	#Draw platforms
	# Save $ra onto the stack
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	jal draw_platforms
	
	# Pop saved $ra from the stack
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	# Reset Health Bar
	la $t2, HEALTH_BAR
	addi $t6, $zero, 492
	sw $t6, 0($t2)
	
	# Reset Enemies
	la $t2, ENEMY
	addi $t6, $zero, 420
	sw $t6, 0($t2)
	
	la $t2, ENEMY2
	addi $t6, $zero, 452
	sw $t6, 0($t2)
  	
  	j loop

# ------------------------------------------------------------------------
#Handle keyboard

loop:
	# Check for  keypress
	li $t9, 0xffff0000  
	lw $t8, 0($t9) 
	beq $t8, 1, keypress_happened
	jal draw_platforms
	
	# Get location of enemy
	la $t2, ENEMY
	jal enemy_fall
	
	# Get location of enemy2
	la $t2, ENEMY2
	jal enemy2_fall
	
	j skip  	

draw_platforms:
	lw $t3, ENEMY
	
	#Draw long platform at the top
	li $t1, INDIGO
	sw $t1, 2600($t0) 
	sw $t1, 2604($t0)
	sw $t1, 2608($t0)
	sw $t1, 2612($t0)
	sw $t1, 2616($t0)
	sw $t1, 2620($t0)
	sw $t1, 2624($t0)
	sw $t1, 2628($t0)
	sw $t1, 2632($t0)
	sw $t1, 2636($t0)
	sw $t1, 2640($t0)
	sw $t1, 2644($t0)
	sw $t1, 2648($t0)
	
	#Draw regular size platforms
	sw $t1, 6228($t0)
	sw $t1, 6232($t0)
	sw $t1, 6236($t0)
	sw $t1, 6240($t0)
	sw $t1, 6244($t0)
	sw $t1, 6248($t0)
	sw $t1, 6252($t0)
	
	sw $t1, 6836($t0)
	sw $t1, 6840($t0)
	sw $t1, 6844($t0)
	sw $t1, 6848($t0)
	sw $t1, 6852($t0)
	sw $t1, 6856($t0)
	sw $t1, 6860($t0)
	sw $t1, 6864($t0)
	sw $t1, 6868($t0)
	
	sw $t1, 7972($t0)
	sw $t1, 7976($t0)
	sw $t1, 7980($t0)
	sw $t1, 7984($t0)
	sw $t1, 7988($t0)
	sw $t1, 7992($t0)
	sw $t1, 7996($t0)
	sw $t1, 8000($t0)
	sw $t1, 8004($t0)
	
	sw $t1, 10084($t0)
	sw $t1, 10088($t0)
	sw $t1, 10092($t0)
	sw $t1, 10096($t0)
	sw $t1, 10100($t0)
	sw $t1, 10104($t0)
	sw $t1, 10108($t0)
	sw $t1, 10112($t0)
	sw $t1, 10116($t0)
	
	sw $t1, 12096($t0)
	sw $t1, 12100($t0)
	sw $t1, 12104($t0)
	sw $t1, 12108($t0)
	sw $t1, 12112($t0)
	sw $t1, 12116($t0)
	sw $t1, 12120($t0)
	sw $t1, 12124($t0)
	sw $t1, 12128($t0)
	
	sw $t1, 12924($t0)
	sw $t1, 12928($t0)
	sw $t1, 12932($t0)
	sw $t1, 12936($t0)
	sw $t1, 12940($t0)
	sw $t1, 12944($t0)
	sw $t1, 12948($t0)
	sw $t1, 12952($t0)
	sw $t1, 12956($t0)
	sw $t1, 12960($t0)
	sw $t1, 12964($t0)
	sw $t1, 12968($t0)
	sw $t1, 12972($t0)
	
	
	#Draw small platforms
	
	sw $t1, 12992($t0)
	sw $t1, 12996($t0)
	sw $t1, 13000($t0)
	sw $t1, 13004($t0)
	
	
	sw $t1, 13032($t0)
	sw $t1, 13036($t0)
	sw $t1, 13040($t0)
	sw $t1, 13044($t0)
	sw $t1, 13048($t0)
	sw $t1, 13052($t0)
	
	#Draw initial platform
	sw $t1, 13312($t0)
	sw $t1, 13316($t0)
	sw $t1, 13320($t0)
	sw $t1, 13324($t0)
	sw $t1, 13328($t0)
	sw $t1, 13332($t0)
	sw $t1, 13336($t0)
	sw $t1, 13340($t0)
	sw $t1, 13344($t0)
	sw $t1, 13348($t0)
	sw $t1, 13352($t0)
	sw $t1, 13356($t0)
	
	#Draw end platform
	li $t1, AZURE
	sw $t1, 8160($t0)
	sw $t1, 8164($t0)
	sw $t1, 8168($t0)
	sw $t1, 8172($t0)
	sw $t1, 8176($t0)
	sw $t1, 8180($t0)
	sw $t1, 8184($t0)
	sw $t1, 8188($t0)
	
		
	# Check if player obtained star that can freeze platform
	# If FREEZE = 0, did not obtain freeze
	lw $t4, FREEZE
	
	bnez $t4, show_all_platforms
	
	# Use enemy's position to determine when will platform appear
	# If enemy reach position 2000: appear
	bgt $t3, 2000, appear 
	
	#Else: Make platform disppear
	li $t1, BLACK
	sw $t1, 4720($t0)
	sw $t1, 4724($t0)
	sw $t1, 4728($t0)
	sw $t1, 4732($t0)
	sw $t1, 4736($t0)
	sw $t1, 4740($t0)
	sw $t1, 4744($t0)
	sw $t1, 4748($t0)
	sw $t1, 4752($t0)
	
	jr $ra
		
appear: bgt $t3, 12000, disappear # If enemy reach position 12000: disappear	
	#platform appear
	li $t1, INDIGO
	sw $t1, 4720($t0)
	sw $t1, 4724($t0)
	sw $t1, 4728($t0)
	sw $t1, 4732($t0)
	sw $t1, 4736($t0)
	sw $t1, 4740($t0)
	sw $t1, 4744($t0)
	sw $t1, 4748($t0)
	sw $t1, 4752($t0)
	
	jr $ra
	
disappear:	
	#platform disppear
	li $t1, BLACK
	sw $t1, 4720($t0)
	sw $t1, 4724($t0)
	sw $t1, 4728($t0)
	sw $t1, 4732($t0)
	sw $t1, 4736($t0)
	sw $t1, 4740($t0)
	sw $t1, 4744($t0)
	sw $t1, 4748($t0)
	sw $t1, 4752($t0)
	
	jr $ra
	
show_all_platforms:
	#Disappeared platform
	li $t1, INDIGO
	sw $t1, 4720($t0)
	sw $t1, 4724($t0)
	sw $t1, 4728($t0)
	sw $t1, 4732($t0)
	sw $t1, 4736($t0)
	sw $t1, 4740($t0)
	sw $t1, 4744($t0)
	sw $t1, 4748($t0)
	sw $t1, 4752($t0)
	
	# Freeze platform indicator
	li $t2, YELLOW
	sw $t2, 476($t0)
	
	jr $ra


skip:
	# Timer to "animate" fall
	
	# Value 32 indicates that the program is requesting a "delay" or "sleep" 
	li $v0, 32
        li $a0, JUMP_FALL_TIME
        syscall
	
	jal gravity 
	
	j loop
					
keypress_happened:
	li $t9, 0xffff0000 
	# Check to see what key was pressed
	lw $t3, 4($t9)
	
	# Check left
	beq $t3, LEFT, respond_to_left
	# Check right
	beq $t3, RIGHT, respond_to_right
	# Check up
	beq $t3, UP, respond_to_up
	# Check restart
	beq $t3, P, respond_to_p
	
	j loop
	
	
respond_to_p:
	j main
	j loop
	
	
respond_to_left:
	# Get location of player
	la $t5, PLAYER
	
	# Read location of player, let $t6-9 store the offset
	# [ t8 | t9 ]
	     # [ t6 | t7 ]
	lw $t6, 0($t5)
	sub $t6, $t6, $t0
	lw $t7, 4($t5)
	sub $t7, $t7, $t0
	lw $t8, 8($t5)
	sub $t8, $t8, $t0
	lw $t9, 12($t5)
	sub $t9, $t9, $t0
	
	# Check if player is at the border, do nothing
	addi $t3, $zero, 512
	div $t8, $t3
	mfhi $t3
	beq $t3, $zero, loop
	
	# If player is about to touch the center of the heart
	li $t4, RED
	# Check t6
	add $t3, $t6, $t0
	add $t3, $t3, -4
	addi $a0, $t3, 0 # Load addr of 'center' into a0
	lw $t3, 0($t3)
	bne $t3, $t4, check_next_left # Check if t8 will touch heart
	jal obtain_heart
	
check_next_left:
	# Check t8
	add $t3, $t8, $t0
	add $t3, $t3, -4
	addi $a0, $t3, 0 # Load addr of 'center' into a0
	lw $t3, 0($t3)
	bne $t3, $t4, continue_left
	jal obtain_heart
	
continue_left:
	# Colour old location as black, let $t3 the address to draw on
	li $t1, BLACK
	add $t3, $t7, $t0
	sw $t1, 0($t3)
	add $t3, $t9, $t0
	sw $t1, 0($t3)

	# Redraw player in new location
	# Store new offset
	addi $t6, $t6, -4
	add $t6, $t6, $t0
	addi $t7, $t7, -4
	add $t7, $t7, $t0
	addi $t8, $t8, -4
	add $t8, $t8, $t0
	addi $t9, $t9, -4
	add $t9, $t9, $t0
	
	# Save new location to array
	sw $t6, 0($t5)
	sw $t7, 4($t5)
	sw $t8, 8($t5)
	sw $t9, 12($t5)
	
	# Get new address and draw new player
	li $t1, GREEN
	lw $t3, 0($t5)
  	sw $t1, 0($t3)
  	lw $t3, 8($t5)
  	sw $t1, 0($t3)
	
		
	j loop	
	
respond_to_right:
	# Get location of player
	la $t5, PLAYER
	
	# Read location of player, let $t6-9 store the offset
	# [ t8 | t9 ]
	     # [ t6 | t7 ]
	lw $t6, 0($t5)
	sub $t6, $t6, $t0
	lw $t7, 4($t5)
	sub $t7, $t7, $t0
	lw $t8, 8($t5)
	sub $t8, $t8, $t0
	lw $t9, 12($t5)
	sub $t9, $t9, $t0
		
	# If player is at the border, do not do anything
	addi $t3, $zero, 512
	subi $t4, $t7, 508
	div $t4, $t3
	mfhi $t4
	beq $t4, $zero, loop
	
	# If player is about to touch the center of the heart or star
	li $t4, RED
	
	# Check t9
	add $t3, $t9, $t0
	add $t3, $t3, 4
	addi $a0, $t3, 0 # Load addr of 'center' into a0
	lw $t3 0($t3)
	
	# Check for star
	li $t4, YELLOW
	beq $t3, $t4, obtain_freeze
	bne $t3, $t4, check_next_right
	
	# Check for heart
	li $t4, RED
	bne $t3, $t4, check_next_right
	jal obtain_heart
	
check_next_right:

	# Check t7
	addi $t3, $t3, 4
	add $t3, $t7, $t0
	lw $t2, 0($t3)
	
	# Check for star
	li $t4, YELLOW
	beq $t3, $t4, obtain_freeze
	bne $t2, $t4, continue_right
	
	# Check for heart
	li $t4, RED
	bne $t2, $t4, continue_right
	jal obtain_heart
	
continue_right:
	# Change old location's color to black
	li $t1, BLACK
	add $t3, $t6, $t0
	sw $t1, 0($t3)
	add $t3, $t8, $t0
	sw $t1, 0($t3)
	
	# Redraw player in new location
	# Store new offset
	addi $t6, $t6, 4
	add $t6, $t6, $t0
	addi $t7, $t7, 4
	add $t7, $t7, $t0
	addi $t8, $t8, 4
	add $t8, $t8, $t0
	addi $t9, $t9, 4
	add $t9, $t9, $t0
	
	# Save new location to array
	sw $t6, 0($t5)
	sw $t7, 4($t5)
	sw $t8, 8($t5)
	sw $t9, 12($t5)
		
	# Get new address and draw new player
	li $t1, GREEN
	lw $t3, 4($t5)
  	sw $t1, 0($t3)
  	lw $t3, 12($t5)
  	sw $t1, 0($t3)
	
	j loop	
	
jump:		
	# Get location of player
	la $t5, PLAYER
	
	# Read location of player, let $t6-9 store the offset
	# [ t8 | t9 ]
	     # [ t6 | t7 ]
	lw $t6, 0($t5)
	sub $t6, $t6, $t0
	lw $t7, 4($t5)
	sub $t7, $t7, $t0
	lw $t8, 8($t5)
	sub $t8, $t8, $t0
	lw $t9, 12($t5)
	sub $t9, $t9, $t0
	
	# If player is at the border, do not do anything
	subi $t3, $t9, 512
	blez $t3, loop
	
	# If player is about to touch the center of the heart
	li $t4, RED
	# Check t9
	add $t3, $t9, $t0
	add $t3, $t3, -256
	addi $a0, $t3, 0 # Load addr of 'center' into a0
	lw $t3, 0($t3)
	bne $t3, $t4, check_next_jump
	
	# Save $ra onto the stack
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	jal obtain_heart
	
	# Pop saved $ra from the stack
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
check_next_jump:
	# Check t8
	add $t3, $t8, $t0
	add $t3, $t3, -256
	addi $a0, $t3, 0 # Load addr of 'center' into a0
	lw $t3 0($t3)
	bne $t3, $t4, continue_jump
	
	# Save $ra onto the stack
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	jal obtain_heart
	
	# Pop saved $ra from the stack
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	
continue_jump:
	# Change old location's color to black
	li $t1, BLACK
	add $t3, $t6, $t0
	sw $t1, 0($t3)
	add $t3, $t7, $t0
	sw $t1, 0($t3)
	add $t3, $t8, $t0
	sw $t1, 0($t3)
	
	# Redraw player in new location
	# Store new offset
	addi $t6, $t6, -256
	add $t6, $t6, $t0
	addi $t7, $t7, -256
	add $t7, $t7, $t0
	addi $t8, $t8, -256
	add $t8, $t8, $t0
	addi $t9, $t9, -256
	add $t9, $t9, $t0
	
	# Save new location to array
	sw $t6, 0($t5)
	sw $t7, 4($t5)
	sw $t8, 8($t5)
	sw $t9, 12($t5)
		
	# Get new address and draw new player
	li $t1, GREEN
	lw $t3, 4($t5)
  	sw $t1, 0($t3)
  	lw $t3, 8($t5)
  	sw $t1, 0($t3)
  	lw $t3, 12($t5)
  	sw $t1, 0($t3)
	
	# Draw Platform
	# Save $ra onto the stack
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	jal draw_platforms
	
	# Pop saved $ra from the stack
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	# Timer to "animate" jump
	li $v0, 32
        li $a0, JUMP_FALL_TIME
        syscall
	
	jr $ra
	
respond_to_up:
	# Add to jump counter
	# s0 store jump counter
	addi $s0, $s0, 1
	addi $t3, $zero, 2
	
	# If jump counter == 2 then stop jumping
	bgt $s0, $t3, loop
	
	jal jump
	jal jump
	jal jump
	jal jump
	jal jump
	jal jump
	jal jump
	
	j loop

# ------------------------------------------------------------------------
#Handle falling

change:
	#Handle speed of animated effect when player obtain objects/get hit
	li $v0, 32
        li $a0, JUMP_FALL_TIME
        syscall
        
	jr $ra
			
gravity:
	# Get location of player
	la $t5, PLAYER
	
	# Read location of player, let $t6-9 store the offset
	# [ t8 | t9 ]
	     # [ t6 | t7 ]
	lw $t6, 0($t5)
	sub $t6, $t6, $t0
	lw $t7, 4($t5)
	sub $t7, $t7, $t0
	lw $t8, 8($t5)
	sub $t8, $t8, $t0
	lw $t9, 12($t5)
	sub $t9, $t9, $t0
	
	# If player is at the border, lose game
	subi $t3, $t6, 16124
	bgez $t3, fall_to_bottom
	
	# Check if pixel below is an indigo platform
	add $t3, $t6, $t0
	add $t3, $t3, 256
	lw $t3, 0($t3)
	li $t4, INDIGO
	beq $t3, $t4, hit_ground
	
	# Check if pixel below is an azure platform
	li $t4, AZURE
	beq $t3, $t4, hit_ground
	
	# Check if pixel2 below is an indigo platform
	add $t3, $t7, $t0
	add $t3, $t3, 256
	lw $t3, 0($t3)
	li $t4, INDIGO
	beq $t3, $t4, hit_ground
	
	# Check if pixel2 below is an azure platform
	li $t4, AZURE
	beq $t3, $t4, hit_ground

	# If player is about to touch the center of the heart
	li $t4, RED
	# Check t6
	add $t3, $t6, $t0
	add $t3, $t3, 256
	addi $a0, $t3, 0 # Load addr of 'center' into a0
	lw $t3, 0($t3)
	
	# Check for star
	li $t4, YELLOW
	beq $t3, $t4, obtain_freeze
	bne $t3, $t4, check_next_gravity
	
	# Check for heart
	li $t4, RED
	bne $t3, $t4, check_next_gravity
	
	# Save $ra onto the stack
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	jal obtain_heart
	
	# Pop saved $ra from the stack
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
check_next_gravity:
	# Check t7
	add $t3, $t7, $t0
	add $t3, $t3, 256
	addi $a0, $t3, 0 # Load addr of 'center' into a0
	lw $t3, 0($t3)
	
	# Check for star
	li $t4, YELLOW
	beq $t3, $t4, obtain_freeze
	bne $t3, $t4, continue_gravity
	
	# Check for heart
	li $t4, RED
	bne $t3, $t4, continue_gravity
	# Save $ra onto the stack
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	jal obtain_heart
	
	# Pop saved $ra from the stack
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
		
continue_gravity:
	# Colour old location as black, let $t3 the address to draw on
	li $t1, BLACK
	add $t3, $t7, $t0
	sw $t1, 0($t3)
	add $t3, $t8, $t0
	sw $t1, 0($t3)
	add $t3, $t9, $t0
	sw $t1, 0($t3)

	# Redraw player in new location
	# Store new offset
	addi $t6, $t6, 256
	add $t6, $t6, $t0
	addi $t7, $t7, 256
	add $t7, $t7, $t0
	addi $t8, $t8, 256
	add $t8, $t8, $t0
	addi $t9, $t9, 256
	add $t9, $t9, $t0
	
	# Save new location to array
	sw $t6, 0($t5)
	sw $t7, 4($t5)
	sw $t8, 8($t5)
	sw $t9, 12($t5)
	
	# Get new address and draw new player
	li $t1, GREEN
	lw $t3, 0($t5)
  	sw $t1, 0($t3)
	lw $t3, 4($t5)
  	sw $t1, 0($t3)
  	lw $t3, 8($t5)
  	sw $t1, 0($t3)
	
	# Timer to "animate" fall
	li $v0, 32
        li $a0, JUMP_FALL_TIME
        syscall
        
        jr $ra
        
hit_ground:
	#Check for win - reach azure platform
	li $t4, AZURE
	beq $t3, $t4, win
	
	# Clear jump counter
	addi $s0, $zero, 0
	
	j loop
	
fall_to_bottom:
	# Subtract all health from player
	la $t4, HEALTH	
	lw $t3, 0($t4)	
	addi $t3, $zero, 0
	sw $t3, 0($t4)
	
	# Update Health Bar
	li $t1, GREY
	sw $t1,	504($t0)
	sw $t1,	500($t0)
	sw $t1,	496($t0)
	sw $t1,	492($t0)
		
	j lose
	
# ------------------------------------------------------------------------
#Handle enemy

enemy_fall:	
	# Read location of enemy, let $t6 store the offset
	#[t6|x]
	#[x |x]
	
	la $t5, ENEMY
	lw $t6, 0($t5)
	
	# Colour top old location as black, let $t3 the address to draw on
	li $t1, BLACK
	add $t3, $t6, $t0
	sw $t1, 0($t3)
	addi $t3, $t3, 4
	sw $t1, 0($t3)
	addi $t3, $t3, -256
	sw $t1, 0($t3)
	addi $t3, $t3, -4
	sw $t1, 0($t3)
	
	#set $t6 to bottom pixel
	#[x   |x]
	#[$t6 |x]
	addi $t6, $t6, 256
	# If enemy is at the border, reset position to the top
	subi $t3, $t6, 16292
	bltz $t3, continue_enemy_fall
	
	#reset
	addi $t6, $zero, 420
	sw $t6, 0($t5)
	
	
continue_enemy_fall:
	# Redraw enemy in new location and save new offset
	addi $t6, $t6, 256
	sw $t6, 0($t5)
	
	# Get new address and draw new enemy
	li $t2, DARK_BLUE
	li $t4, GREEN
	
	add $t6, $t6, $t0
	
	# If enemy bottom pixel1 is about to touch player
	lw $t3, 0($t6)
	beq $t3, $t4, lose_health1
	sw $t2,	0($t6)
	
	addi $t6, $t6, 4
	# If enemy bottom pixel2 is about to touch player
	lw $t3, 0($t6)
	beq $t3, $t4, lose_health1
	sw $t2,	0($t6)
	
	addi $t6, $t6, -256
	# If enemy top pixel2 is about to touch player
	lw $t3, 0($t6)
	beq $t3, $t4, lose_health1
	sw $t2,	0($t6)
	
	addi $t6, $t6, -4
	# If enemy top pixel1 is about to touch player
	lw $t3, 0($t6)
	beq $t3, $t4, lose_health1
	sw $t2,	0($t6)
	        
	jr $ra
	
enemy2_fall:	
	# Read location of enemy, let $t6 store the offset
	#[t6|x]
	#[x |x]
	
	la $t5, ENEMY2
	lw $t6, 0($t5)
	
	# Colour top old location as black, let $t3 the address to draw on
	li $t1, BLACK
	add $t3, $t6, $t0
	sw $t1, 0($t3)
	addi $t3, $t3, 4
	sw $t1, 0($t3)
	addi $t3, $t3, -256
	sw $t1, 0($t3)
	addi $t3, $t3, -4
	sw $t1, 0($t3)
	
	#set $t6 to bottom pixel
	#[x   |x]
	#[$t6 |x]
	addi $t6, $t6, 256
	# If enemy is at the border, reset position to the top
	subi $t3, $t6, 16324
	bltz $t3, continue_enemy2_fall
	
	#reset
	addi $t6, $zero, 452
	sw $t6, 0($t5)
	
	
continue_enemy2_fall:
	# Redraw enemy2 in new location and save new offset
	addi $t6, $t6, 256
	sw $t6, 0($t5)
	
	# Get new address and draw new enemy2
	li $t2, DARK_BLUE
	li $t4, GREEN
	
	add $t6, $t6, $t0
	
	# If enemy2 bottom pixel1 is about to touch player
	lw $t3, 0($t6)
	beq $t3, $t4, lose_health2
	sw $t2,	0($t6)
	
	addi $t6, $t6, 4
	# If enemy2 bottom pixel2 is about to touch player
	lw $t3, 0($t6)
	beq $t3, $t4, lose_health2
	sw $t2,	0($t6)
	
	addi $t6, $t6, -256
	# If enemy2 top pixel2 is about to touch player
	lw $t3, 0($t6)
	beq $t3, $t4, lose_health2
	sw $t2,	0($t6)
	
	addi $t6, $t6, -4
	# If enemy2 top pixel1 is about to touch player
	lw $t3, 0($t6)
	beq $t3, $t4, lose_health2
	sw $t2,	0($t6)
	        
	jr $ra
	
lose_health1:
	# Enemy1
	# Colour previous enemy black
	# Read location of enemy, let $t6 store the offset
	li $t1, BLACK
	la $t5, ENEMY
	lw $t6, 0($t5)
	add $t6, $t6, $t0
	sw $t1,	0($t6)
	add $t6, $t6, 4
	sw $t1,	0($t6)
	add $t6, $t6, 256
	sw $t1,	0($t6)
	add $t6, $t6, -4
	sw $t1,	0($t6)

	# Reset enemy1 to the top
	addi $t6, $zero, 420
	sw $t6, 0($t5)
	
	
	# Subtract one health from player
	la $t4, HEALTH	
	lw $t3, 0($t4)	
	subi $t3, $t3, 1
	sw $t3, 0($t4)
	
	# Update Health Bar
	la $t4, HEALTH_BAR
	lw $t3, 0($t4)
	addi $t3, $t3 4 # New offset
	sw $t3 0($t4) # Save new offset
	subi $t3, $t3 4 # Draw old offset
	add $t3, $t3, $t0 #Get location
	li $t2, GREY
	sw $t2, 0($t3) # Draw to Health Bar
	
	
	# Animate player
	# Get location of player
	la $t5, PLAYER
	# Read location of player, let $t6-9 store the offset
	# [ t8 | t9 ]
	     # [ t6 | t7 ]
	lw $t6, 0($t5)
	sub $t6, $t6, $t0
	lw $t7, 4($t5)
	sub $t7, $t7, $t0
	lw $t8, 8($t5)
	sub $t8, $t8, $t0
	lw $t9, 12($t5)
	sub $t9, $t9, $t0
	
	#Color effect of player when it gets hit
	li $t2, BLUE
	add $t3, $t7, $t0
	sw $t2,	0($t3)
	jal change
	add $t3, $t6, $t0
	sw $t2,	0($t3)
	jal change
	add $t3, $t9, $t0
	sw $t2,	0($t3)
	jal change
	add $t3, $t8, $t0
	sw $t2,	0($t3)
	
	li $t2, GREEN
	jal change
	add $t3, $t7, $t0
	sw $t2,	0($t3)
	jal change
	add $t3, $t6, $t0
	sw $t2,	0($t3)
	jal change
	add $t3, $t9, $t0
	sw $t2,	0($t3)
	jal change
	add $t3, $t8, $t0
	sw $t2,	0($t3)
	jal change
	
	# Check if health == 0
	la $t4, HEALTH
	lw $t3, 0($t4)	
	blez $t3, lose
	
	j loop
	
lose_health2:	
	# Enemy2
	la $t5, ENEMY2
	lw $t6, 0($t5)
	add $t6, $t6, $t0
	sw $t1,	0($t6)
	add $t6, $t6, 4
	sw $t1,	0($t6)
	add $t6, $t6, 256
	sw $t1,	0($t6)
	add $t6, $t6, -4
	sw $t1,	0($t6)
	
	# Reset enemy2 to the top
	addi $t6, $zero, 452
	sw $t6, 0($t5)
	
	# Subtract one health from player
	la $t4, HEALTH	
	lw $t3, 0($t4)	
	subi $t3, $t3, 1
	sw $t3, 0($t4)
	
	# Update Health Bar
	la $t4, HEALTH_BAR
	lw $t3, 0($t4)
	addi $t3, $t3 4 # New offset
	sw $t3 0($t4) # Save new offset
	subi $t3, $t3 4 # Draw old offset
	add $t3, $t3, $t0 #Get location
	li $t2, GREY
	sw $t2, 0($t3) # Draw to Health Bar
	
	
	# Animate player
	# Get location of player
	la $t5, PLAYER
	# Read location of player, let $t6-9 store the offset
	# [ t8 | t9 ]
	     # [ t6 | t7 ]
	lw $t6, 0($t5)
	sub $t6, $t6, $t0
	lw $t7, 4($t5)
	sub $t7, $t7, $t0
	lw $t8, 8($t5)
	sub $t8, $t8, $t0
	lw $t9, 12($t5)
	sub $t9, $t9, $t0
	
	#Color effect of player when it gets hit
	li $t2, BLUE
	add $t3, $t7, $t0
	sw $t2,	0($t3)
	jal change
	add $t3, $t6, $t0
	sw $t2,	0($t3)
	jal change
	add $t3, $t9, $t0
	sw $t2,	0($t3)
	jal change
	add $t3, $t8, $t0
	sw $t2,	0($t3)
	
	li $t2, GREEN
	jal change
	add $t3, $t7, $t0
	sw $t2,	0($t3)
	jal change
	add $t3, $t6, $t0
	sw $t2,	0($t3)
	jal change
	add $t3, $t9, $t0
	sw $t2,	0($t3)
	jal change
	add $t3, $t8, $t0
	sw $t2,	0($t3)
	jal change
	
	# Check if health == 0
	la $t4, HEALTH
	lw $t3, 0($t4)	
	blez $t3, lose
	
	j loop

# ------------------------------------------------------------------------
#Handle obtain objects

obtain_heart:
	#Color the heart black
	li $t2, BLACK
	sw $t2, 0($a0)
	addi $a0, $a0, 256
	subi $a0, $a0, 4
	sw $t2, 0($a0)
	subi $a0, $a0, 256
	subi $a0, $a0, 4
	sw $t2, 0($a0)
	
	# Add one heart to health
	la $t4, HEALTH	
	lw $t3, 0($t4)	
	addi $t3, $t3, 1
	sw $t3, 0($t4)
	
	# Update Health Bar
	la $t4, HEALTH_BAR
	lw $t3, 0($t4)
	
	#check if health bar is in full condition, do nothing
	beq $t3, 492, full
	
	#else: increase in health bar
	addi $t3, $t3 -4 # New offset
	sw $t3, 0($t4) # Save new offset
	
	add $t3, $t3, $t0 # New location
	li $t2, ORANGE
	sw $t2, 0($t3) # Draw to Health Bar
	
	# Save $ra onto the stack
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	j full
	
	full:	
	#Color effect of player when it obatins heart
	li $t2, PINK
	add $t3, $t7, $t0
	sw $t2,	0($t3)
	jal change
	add $t3, $t6, $t0
	sw $t2,	0($t3)
	jal change
	add $t3, $t9, $t0
	sw $t2,	0($t3)
	jal change
	add $t3, $t8, $t0
	sw $t2,	0($t3)
	
	li $t2, GREEN
	jal change
	add $t3, $t7, $t0
	sw $t2,	0($t3)
	jal change
	add $t3, $t6, $t0
	sw $t2,	0($t3)
	jal change
	add $t3, $t9, $t0
	sw $t2,	0($t3)
	jal change
	add $t3, $t8, $t0
	sw $t2,	0($t3)
	jal change
	
	# Pop saved $ra from the stack
	lw $ra, 0($sp)
	addi $sp, $sp, 4

	j loop
	
obtain_freeze:
	# Color the star black
	li $t2, BLACK
	la $t2, STAR
  	lw $t3, 0($t2)
  	sw $t1, 0($t3)
  	lw $t3, 4($t2)
  	sw $t1, 0($t3)
  	lw $t3, 8($t2)
  	sw $t1, 0($t3)
  		
	# Enable freeze platforms
	la $t4, FREEZE
	addi $t3, $zero, 1
	sw $t3, 0($t4)
	
	# Animate player
	# Get location of player
	la $t5, PLAYER
	# Read location of player, let $t6-9 store the offset
	# [ t8 | t9 ]
	     # [ t6 | t7 ]
	lw $t6, 0($t5)
	sub $t6, $t6, $t0
	lw $t7, 4($t5)
	sub $t7, $t7, $t0
	lw $t8, 8($t5)
	sub $t8, $t8, $t0
	lw $t9, 12($t5)
	sub $t9, $t9, $t0
	
	#Color effect of player when it gets the star
	li $t2, YELLOW
	add $t3, $t7, $t0
	sw $t2,	0($t3)
	jal change
	add $t3, $t6, $t0
	sw $t2,	0($t3)
	jal change
	add $t3, $t9, $t0
	sw $t2,	0($t3)
	jal change
	add $t3, $t8, $t0
	sw $t2,	0($t3)
	
	li $t2, GREEN
	jal change
	add $t3, $t7, $t0
	sw $t2,	0($t3)
	jal change
	add $t3, $t6, $t0
	sw $t2,	0($t3)
	jal change
	add $t3, $t9, $t0
	sw $t2,	0($t3)
	jal change
	add $t3, $t8, $t0
	sw $t2,	0($t3)
	jal change
	
	j loop

		
win:
	li $t9, 0xffff0000 
	# Check to see what key was pressed
	lw $t3, 4($t9)

	# Check p
	beq $t3, P, respond_to_p
	
	#Draw WIN screen
	li $t1, LIME
	#W
	sw $t1, 7240($t0)
	sw $t1, 7496($t0)
	sw $t1, 7496($t0)
	sw $t1, 7756($t0)
	sw $t1, 8012($t0)
	sw $t1, 8268($t0)
	sw $t1, 8524($t0)
	sw $t1, 8784($t0)
	sw $t1, 9040($t0)
	sw $t1, 9296($t0)
	sw $t1, 9044($t0)
	sw $t1, 8788($t0)
	sw $t1, 8532($t0)
	sw $t1, 8280($t0)
	sw $t1, 8024($t0)
	sw $t1, 7768($t0)
	sw $t1, 7516($t0)
	sw $t1, 7260($t0)
	sw $t1, 7776($t0)
	sw $t1, 8032($t0)
	sw $t1, 8288($t0)
	sw $t1, 8548($t0)
	sw $t1, 8804($t0)
	sw $t1, 9060($t0)
	sw $t1, 9316($t0)
	sw $t1, 9320($t0)
	sw $t1, 9064($t0)
	sw $t1, 8808($t0)
	sw $t1, 8556($t0)
	sw $t1, 8300($t0)
	sw $t1, 8044($t0)
	sw $t1, 7788($t0)
	sw $t1, 7536($t0)
	sw $t1, 7280($t0)
	
	#I
	sw $t1, 7292($t0)
	sw $t1, 7548($t0)
	sw $t1, 7804($t0)
	sw $t1, 8060($t0)
	sw $t1, 8316($t0)
	sw $t1, 8572($t0)
	sw $t1, 8828($t0)
	sw $t1, 9084($t0)
	sw $t1, 9340($t0)
	
	#N
	sw $t1, 7304($t0)
	sw $t1, 7560($t0)
	sw $t1, 7816($t0)
	sw $t1, 8072($t0)
	sw $t1, 8328($t0)
	sw $t1, 8584($t0)
	sw $t1, 8840($t0)
	sw $t1, 9096($t0)
	sw $t1, 9352($t0)
	
	sw $t1, 7308($t0)
	sw $t1, 7564($t0)
	sw $t1, 7824($t0)
	sw $t1, 8084($t0)
	sw $t1, 8340($t0)
	sw $t1, 8600($t0)
	sw $t1, 8860($t0)
	sw $t1, 9116($t0)
	sw $t1, 9120($t0)
	sw $t1, 9376($t0)
	sw $t1, 9380($t0)
	sw $t1, 9124($t0)
	sw $t1, 8868($t0)
	sw $t1, 8612($t0)
	sw $t1, 8356($t0)
	sw $t1, 8100($t0)
	sw $t1, 7844($t0)
	sw $t1, 7588($t0)
	sw $t1, 7332($t0)
		
	j win
	
	
lose:
	li $t9, 0xffff0000 
	# Check to see what key was pressed
	lw $t3, 4($t9)

	# Check p
	beq $t3, P, respond_to_p
	
	#Draw END screen
	li $t1, LIME
	
	#E
	sw $t1, 7232($t0)
	sw $t1, 7236($t0)
	sw $t1, 7240($t0)
	sw $t1, 7244($t0)
	sw $t1, 7248($t0)
	sw $t1, 7252($t0)
	
	sw $t1, 8512($t0)
	sw $t1, 8516($t0)
	sw $t1, 8520($t0)
	sw $t1, 8524($t0)
	sw $t1, 8528($t0)
	sw $t1, 8532($t0)
	
	sw $t1, 9792($t0)
	sw $t1, 9796($t0)
	sw $t1, 9800($t0)
	sw $t1, 9804($t0)
	sw $t1, 9808($t0)
	sw $t1, 9812($t0)
	
	sw $t1, 7488($t0)
	sw $t1, 7744($t0)
	sw $t1, 8000($t0)
	sw $t1, 8256($t0)
	
	sw $t1, 8512($t0)
	sw $t1, 8768($t0)
	sw $t1, 9024($t0)
	sw $t1, 9280($t0)
	sw $t1, 9536($t0)
	
	#N
	sw $t1, 7264($t0)
	sw $t1, 7520($t0)
	sw $t1, 7776($t0)
	sw $t1, 8032($t0)
	sw $t1, 8288($t0)
	sw $t1, 8544($t0)
	sw $t1, 8800($t0)
	sw $t1, 9056($t0)
	sw $t1, 9312($t0)
	sw $t1, 9568($t0)
	sw $t1, 9824($t0)
	
	sw $t1, 7292($t0)
	sw $t1, 7548($t0)
	sw $t1, 7804($t0)
	sw $t1, 8060($t0)
	sw $t1, 8316($t0)
	sw $t1, 8572($t0)
	sw $t1, 8828($t0)
	sw $t1, 9084($t0)
	sw $t1, 9340($t0)
	sw $t1, 9596($t0)
	sw $t1, 9852($t0)
	
	sw $t1, 7268($t0)
	sw $t1, 7524($t0)
	sw $t1, 7784($t0)
	sw $t1, 8040($t0)
	sw $t1, 8044($t0)
	sw $t1, 8300($t0)
	sw $t1, 8304($t0)
	sw $t1, 8560($t0)
	sw $t1, 8564($t0)
	sw $t1, 8820($t0)
	sw $t1, 9076($t0)
	sw $t1, 9332($t0)
	sw $t1, 9336($t0)
	sw $t1, 9592($t0)
	sw $t1, 9848($t0)
	
	#D
	sw $t1, 7304($t0)
	sw $t1, 7560($t0)
	sw $t1, 7816($t0)
	sw $t1, 8072($t0)
	sw $t1, 8328($t0)
	sw $t1, 8584($t0)
	sw $t1, 8840($t0)
	sw $t1, 9096($t0)
	sw $t1, 9352($t0)
	sw $t1, 9608($t0)
	sw $t1, 9864($t0)
	
	sw $t1, 7308($t0)
	sw $t1, 7312($t0)
	sw $t1, 7316($t0)
	sw $t1, 7320($t0)
	sw $t1, 7576($t0)
	sw $t1, 7580($t0)
	sw $t1, 7584($t0)
	sw $t1, 7840($t0)
	sw $t1, 7844($t0)
	
	sw $t1, 8100($t0)
	sw $t1, 8356($t0)
	sw $t1, 8612($t0)
	sw $t1, 8868($t0)
	sw $t1, 9124($t0)
	sw $t1, 9380($t0)
	
	sw $t1, 9376($t0)
	sw $t1, 9632($t0)
	sw $t1, 9628($t0)
	
	sw $t1, 9884($t0)
	sw $t1, 9880($t0)
	sw $t1, 9876($t0)
	sw $t1, 9872($t0)
	sw $t1, 9868($t0)
	
        jr $ra	
  			
	j lose
	
draw_start:

	li $v0, 32		# syscall for sleeping for 30 ms
	li $a0, 30
	addi $t4, $zero, BASE_ADDRESS
	addi $t3, $t4, 0
	li $t5, 0x757575
	sw $t5, 0($t3)
	addi $t3, $t4, 4
	li $t5, 0x050505
	sw $t5, 0($t3)
	addi $t3, $t4, 8
	li $t5, 0x080808
	sw $t5, 0($t3)
	addi $t3, $t4, 12
	li $t5, 0x050505
	sw $t5, 0($t3)
	addi $t3, $t4, 16
	sw $t5, 0($t3)
	addi $t3, $t4, 20
	sw $t5, 0($t3)
	addi $t3, $t4, 24
	sw $t5, 0($t3)
	addi $t3, $t4, 28
	sw $t5, 0($t3)
	addi $t3, $t4, 32
	sw $t5, 0($t3)
	addi $t3, $t4, 36
	sw $t5, 0($t3)
	addi $t3, $t4, 40
	sw $t5, 0($t3)
	addi $t3, $t4, 44
	sw $t5, 0($t3)
	addi $t3, $t4, 48
	sw $t5, 0($t3)
	addi $t3, $t4, 52
	sw $t5, 0($t3)
	addi $t3, $t4, 56
	sw $t5, 0($t3)
	addi $t3, $t4, 60
	sw $t5, 0($t3)
	addi $t3, $t4, 64
	sw $t5, 0($t3)
	addi $t3, $t4, 68
	sw $t5, 0($t3)
	addi $t3, $t4, 72
	sw $t5, 0($t3)
	addi $t3, $t4, 76
	sw $t5, 0($t3)
	addi $t3, $t4, 80
	sw $t5, 0($t3)
	addi $t3, $t4, 84
	sw $t5, 0($t3)
	addi $t3, $t4, 88
	sw $t5, 0($t3)
	addi $t3, $t4, 92
	sw $t5, 0($t3)
	addi $t3, $t4, 96
	sw $t5, 0($t3)
	addi $t3, $t4, 100
	sw $t5, 0($t3)
	addi $t3, $t4, 104
	sw $t5, 0($t3)
	addi $t3, $t4, 108
	sw $t5, 0($t3)
	addi $t3, $t4, 112
	sw $t5, 0($t3)
	addi $t3, $t4, 116
	sw $t5, 0($t3)
	addi $t3, $t4, 120
	sw $t5, 0($t3)
	addi $t3, $t4, 124
	sw $t5, 0($t3)
	addi $t3, $t4, 128
	sw $t5, 0($t3)
	addi $t3, $t4, 132
	sw $t5, 0($t3)
	addi $t3, $t4, 136
	sw $t5, 0($t3)
	addi $t3, $t4, 140
	sw $t5, 0($t3)
	addi $t3, $t4, 144
	sw $t5, 0($t3)
	addi $t3, $t4, 148
	sw $t5, 0($t3)
	addi $t3, $t4, 152
	sw $t5, 0($t3)
	addi $t3, $t4, 156
	sw $t5, 0($t3)
	addi $t3, $t4, 160
	sw $t5, 0($t3)
	addi $t3, $t4, 164
	sw $t5, 0($t3)
	addi $t3, $t4, 168
	sw $t5, 0($t3)
	addi $t3, $t4, 172
	sw $t5, 0($t3)
	addi $t3, $t4, 176
	sw $t5, 0($t3)
	addi $t3, $t4, 180
	sw $t5, 0($t3)
	addi $t3, $t4, 184
	sw $t5, 0($t3)
	addi $t3, $t4, 188
	sw $t5, 0($t3)
	addi $t3, $t4, 192
	sw $t5, 0($t3)
	addi $t3, $t4, 196
	sw $t5, 0($t3)
	addi $t3, $t4, 200
	sw $t5, 0($t3)
	addi $t3, $t4, 204
	sw $t5, 0($t3)
	addi $t3, $t4, 208
	sw $t5, 0($t3)
	addi $t3, $t4, 212
	sw $t5, 0($t3)
	addi $t3, $t4, 216
	sw $t5, 0($t3)
	addi $t3, $t4, 220
	sw $t5, 0($t3)
	addi $t3, $t4, 224
	sw $t5, 0($t3)
	addi $t3, $t4, 228
	sw $t5, 0($t3)
	addi $t3, $t4, 232
	sw $t5, 0($t3)
	addi $t3, $t4, 236
	sw $t5, 0($t3)
	addi $t3, $t4, 240
	sw $t5, 0($t3)
	addi $t3, $t4, 244
	li $t5, 0x080808
	sw $t5, 0($t3)
	addi $t3, $t4, 248
	li $t5, 0x050505
	sw $t5, 0($t3)
	addi $t3, $t4, 252
	li $t5, 0x666666
	sw $t5, 0($t3)
	syscall      # sleeps for 30 ms
	addi $t3, $t4, 256
	li $t5, 0x717171
	sw $t5, 0($t3)
	addi $t3, $t4, 260
	addi $t3, $t4, 264
	li $t5, 0x020202
	sw $t5, 0($t3)
	addi $t3, $t4, 268
	addi $t3, $t4, 272
	addi $t3, $t4, 276
	addi $t3, $t4, 280
	addi $t3, $t4, 284
	addi $t3, $t4, 288
	addi $t3, $t4, 292
	addi $t3, $t4, 296
	addi $t3, $t4, 300
	addi $t3, $t4, 304
	addi $t3, $t4, 308
	addi $t3, $t4, 312
	addi $t3, $t4, 316
	addi $t3, $t4, 320
	addi $t3, $t4, 324
	addi $t3, $t4, 328
	addi $t3, $t4, 332
	addi $t3, $t4, 336
	addi $t3, $t4, 340
	addi $t3, $t4, 344
	addi $t3, $t4, 348
	addi $t3, $t4, 352
	addi $t3, $t4, 356
	addi $t3, $t4, 360
	addi $t3, $t4, 364
	addi $t3, $t4, 368
	addi $t3, $t4, 372
	addi $t3, $t4, 376
	addi $t3, $t4, 380
	addi $t3, $t4, 384
	addi $t3, $t4, 388
	addi $t3, $t4, 392
	addi $t3, $t4, 396
	addi $t3, $t4, 400
	addi $t3, $t4, 404
	addi $t3, $t4, 408
	addi $t3, $t4, 412
	addi $t3, $t4, 416
	addi $t3, $t4, 420
	addi $t3, $t4, 424
	addi $t3, $t4, 428
	addi $t3, $t4, 432
	addi $t3, $t4, 436
	addi $t3, $t4, 440
	addi $t3, $t4, 444
	addi $t3, $t4, 448
	addi $t3, $t4, 452
	addi $t3, $t4, 456
	addi $t3, $t4, 460
	addi $t3, $t4, 464
	addi $t3, $t4, 468
	addi $t3, $t4, 472
	addi $t3, $t4, 476
	addi $t3, $t4, 480
	addi $t3, $t4, 484
	addi $t3, $t4, 488
	addi $t3, $t4, 492
	addi $t3, $t4, 496
	addi $t3, $t4, 500
	sw $t5, 0($t3)
	addi $t3, $t4, 504
	addi $t3, $t4, 508
	li $t5, 0x626262
	sw $t5, 0($t3)
	syscall      # sleeps for 30 ms
	addi $t3, $t4, 512
	li $t5, 0x727272
	sw $t5, 0($t3)
	addi $t3, $t4, 516
	addi $t3, $t4, 520
	li $t5, 0x030303
	sw $t5, 0($t3)
	addi $t3, $t4, 524
	addi $t3, $t4, 528
	addi $t3, $t4, 532
	addi $t3, $t4, 536
	addi $t3, $t4, 540
	addi $t3, $t4, 544
	addi $t3, $t4, 548
	addi $t3, $t4, 552
	addi $t3, $t4, 556
	addi $t3, $t4, 560
	addi $t3, $t4, 564
	addi $t3, $t4, 568
	addi $t3, $t4, 572
	addi $t3, $t4, 576
	addi $t3, $t4, 580
	addi $t3, $t4, 584
	addi $t3, $t4, 588
	addi $t3, $t4, 592
	addi $t3, $t4, 596
	addi $t3, $t4, 600
	addi $t3, $t4, 604
	addi $t3, $t4, 608
	addi $t3, $t4, 612
	addi $t3, $t4, 616
	addi $t3, $t4, 620
	addi $t3, $t4, 624
	addi $t3, $t4, 628
	addi $t3, $t4, 632
	addi $t3, $t4, 636
	addi $t3, $t4, 640
	addi $t3, $t4, 644
	addi $t3, $t4, 648
	addi $t3, $t4, 652
	addi $t3, $t4, 656
	addi $t3, $t4, 660
	addi $t3, $t4, 664
	addi $t3, $t4, 668
	addi $t3, $t4, 672
	addi $t3, $t4, 676
	addi $t3, $t4, 680
	addi $t3, $t4, 684
	addi $t3, $t4, 688
	addi $t3, $t4, 692
	addi $t3, $t4, 696
	addi $t3, $t4, 700
	addi $t3, $t4, 704
	addi $t3, $t4, 708
	addi $t3, $t4, 712
	addi $t3, $t4, 716
	addi $t3, $t4, 720
	addi $t3, $t4, 724
	addi $t3, $t4, 728
	addi $t3, $t4, 732
	addi $t3, $t4, 736
	addi $t3, $t4, 740
	addi $t3, $t4, 744
	addi $t3, $t4, 748
	addi $t3, $t4, 752
	addi $t3, $t4, 756
	sw $t5, 0($t3)
	addi $t3, $t4, 760
	addi $t3, $t4, 764
	li $t5, 0x636363
	sw $t5, 0($t3)
	syscall      # sleeps for 30 ms
	addi $t3, $t4, 768
	li $t5, 0x727272
	sw $t5, 0($t3)
	addi $t3, $t4, 772
	addi $t3, $t4, 776
	li $t5, 0x030303
	sw $t5, 0($t3)
	addi $t3, $t4, 780
	addi $t3, $t4, 784
	addi $t3, $t4, 788
	addi $t3, $t4, 792
	addi $t3, $t4, 796
	addi $t3, $t4, 800
	addi $t3, $t4, 804
	addi $t3, $t4, 808
	addi $t3, $t4, 812
	addi $t3, $t4, 816
	addi $t3, $t4, 820
	addi $t3, $t4, 824
	addi $t3, $t4, 828
	addi $t3, $t4, 832
	addi $t3, $t4, 836
	addi $t3, $t4, 840
	addi $t3, $t4, 844
	addi $t3, $t4, 848
	addi $t3, $t4, 852
	addi $t3, $t4, 856
	addi $t3, $t4, 860
	addi $t3, $t4, 864
	addi $t3, $t4, 868
	addi $t3, $t4, 872
	addi $t3, $t4, 876
	addi $t3, $t4, 880
	addi $t3, $t4, 884
	addi $t3, $t4, 888
	addi $t3, $t4, 892
	addi $t3, $t4, 896
	addi $t3, $t4, 900
	addi $t3, $t4, 904
	addi $t3, $t4, 908
	addi $t3, $t4, 912
	addi $t3, $t4, 916
	addi $t3, $t4, 920
	addi $t3, $t4, 924
	addi $t3, $t4, 928
	addi $t3, $t4, 932
	addi $t3, $t4, 936
	addi $t3, $t4, 940
	addi $t3, $t4, 944
	addi $t3, $t4, 948
	addi $t3, $t4, 952
	addi $t3, $t4, 956
	addi $t3, $t4, 960
	addi $t3, $t4, 964
	addi $t3, $t4, 968
	addi $t3, $t4, 972
	addi $t3, $t4, 976
	addi $t3, $t4, 980
	addi $t3, $t4, 984
	addi $t3, $t4, 988
	addi $t3, $t4, 992
	addi $t3, $t4, 996
	addi $t3, $t4, 1000
	addi $t3, $t4, 1004
	addi $t3, $t4, 1008
	addi $t3, $t4, 1012
	sw $t5, 0($t3)
	addi $t3, $t4, 1016
	addi $t3, $t4, 1020
	li $t5, 0x636363
	sw $t5, 0($t3)
	syscall      # sleeps for 30 ms
	addi $t3, $t4, 1024
	li $t5, 0x727272
	sw $t5, 0($t3)
	addi $t3, $t4, 1028
	addi $t3, $t4, 1032
	li $t5, 0x030303
	sw $t5, 0($t3)
	addi $t3, $t4, 1036
	addi $t3, $t4, 1040
	addi $t3, $t4, 1044
	addi $t3, $t4, 1048
	addi $t3, $t4, 1052
	addi $t3, $t4, 1056
	addi $t3, $t4, 1060
	addi $t3, $t4, 1064
	addi $t3, $t4, 1068
	addi $t3, $t4, 1072
	addi $t3, $t4, 1076
	addi $t3, $t4, 1080
	addi $t3, $t4, 1084
	addi $t3, $t4, 1088
	addi $t3, $t4, 1092
addi $t3, $t4, 1096
addi $t3, $t4, 1100
addi $t3, $t4, 1104
addi $t3, $t4, 1108
addi $t3, $t4, 1112
addi $t3, $t4, 1116
addi $t3, $t4, 1120
addi $t3, $t4, 1124
addi $t3, $t4, 1128
addi $t3, $t4, 1132
addi $t3, $t4, 1136
addi $t3, $t4, 1140
addi $t3, $t4, 1144
addi $t3, $t4, 1148
addi $t3, $t4, 1152
addi $t3, $t4, 1156
addi $t3, $t4, 1160
addi $t3, $t4, 1164
addi $t3, $t4, 1168
addi $t3, $t4, 1172
addi $t3, $t4, 1176
addi $t3, $t4, 1180
addi $t3, $t4, 1184
addi $t3, $t4, 1188
addi $t3, $t4, 1192
addi $t3, $t4, 1196
addi $t3, $t4, 1200
addi $t3, $t4, 1204
addi $t3, $t4, 1208
addi $t3, $t4, 1212
addi $t3, $t4, 1216
addi $t3, $t4, 1220
addi $t3, $t4, 1224
addi $t3, $t4, 1228
addi $t3, $t4, 1232
addi $t3, $t4, 1236
addi $t3, $t4, 1240
addi $t3, $t4, 1244
addi $t3, $t4, 1248
addi $t3, $t4, 1252
addi $t3, $t4, 1256
addi $t3, $t4, 1260
addi $t3, $t4, 1264
addi $t3, $t4, 1268
sw $t5, 0($t3)
addi $t3, $t4, 1272
addi $t3, $t4, 1276
li $t5, 0x636363
sw $t5, 0($t3)
syscall      # sleeps for 30 ms

addi $t3, $t4, 1280
li $t5, 0x727272
sw $t5, 0($t3)
addi $t3, $t4, 1284
addi $t3, $t4, 1288
li $t5, 0x030303
sw $t5, 0($t3)
addi $t3, $t4, 1292
addi $t3, $t4, 1296
addi $t3, $t4, 1300
addi $t3, $t4, 1304
addi $t3, $t4, 1308
addi $t3, $t4, 1312
addi $t3, $t4, 1316
addi $t3, $t4, 1320
addi $t3, $t4, 1324
addi $t3, $t4, 1328
addi $t3, $t4, 1332
addi $t3, $t4, 1336
addi $t3, $t4, 1340
addi $t3, $t4, 1344
li $t5, 0x000203
sw $t5, 0($t3)
addi $t3, $t4, 1348
addi $t3, $t4, 1352
addi $t3, $t4, 1356
sw $t5, 0($t3)
addi $t3, $t4, 1360
addi $t3, $t4, 1364
li $t5, 0x000101
sw $t5, 0($t3)
addi $t3, $t4, 1368
li $t5, 0x000202
sw $t5, 0($t3)
addi $t3, $t4, 1372
sw $t5, 0($t3)
addi $t3, $t4, 1376
li $t5, 0x000203
sw $t5, 0($t3)
addi $t3, $t4, 1380
li $t5, 0x000202
sw $t5, 0($t3)
addi $t3, $t4, 1384
sw $t5, 0($t3)
addi $t3, $t4, 1388
li $t5, 0x000101
sw $t5, 0($t3)
addi $t3, $t4, 1392
addi $t3, $t4, 1396
addi $t3, $t4, 1400
addi $t3, $t4, 1404
li $t5, 0x000203
sw $t5, 0($t3)
addi $t3, $t4, 1408
li $t5, 0x000101
sw $t5, 0($t3)
addi $t3, $t4, 1412
addi $t3, $t4, 1416
addi $t3, $t4, 1420
addi $t3, $t4, 1424
sw $t5, 0($t3)
addi $t3, $t4, 1428
li $t5, 0x000203
sw $t5, 0($t3)
addi $t3, $t4, 1432
li $t5, 0x000102
sw $t5, 0($t3)
addi $t3, $t4, 1436
li $t5, 0x000202
sw $t5, 0($t3)
addi $t3, $t4, 1440
li $t5, 0x000304
sw $t5, 0($t3)
addi $t3, $t4, 1444
li $t5, 0x000001
sw $t5, 0($t3)
addi $t3, $t4, 1448
addi $t3, $t4, 1452
li $t5, 0x000202
sw $t5, 0($t3)
addi $t3, $t4, 1456
sw $t5, 0($t3)
addi $t3, $t4, 1460
li $t5, 0x000203
sw $t5, 0($t3)
addi $t3, $t4, 1464
li $t5, 0x000202
sw $t5, 0($t3)
addi $t3, $t4, 1468
sw $t5, 0($t3)
addi $t3, $t4, 1472
li $t5, 0x000102
sw $t5, 0($t3)
addi $t3, $t4, 1476
addi $t3, $t4, 1480
addi $t3, $t4, 1484
addi $t3, $t4, 1488
addi $t3, $t4, 1492
addi $t3, $t4, 1496
addi $t3, $t4, 1500
addi $t3, $t4, 1504
addi $t3, $t4, 1508
addi $t3, $t4, 1512
addi $t3, $t4, 1516
addi $t3, $t4, 1520
addi $t3, $t4, 1524
li $t5, 0x030303
sw $t5, 0($t3)
addi $t3, $t4, 1528
addi $t3, $t4, 1532
li $t5, 0x636363
sw $t5, 0($t3)
syscall      # sleeps for 30 ms
addi $t3, $t4, 1536
li $t5, 0x727272
sw $t5, 0($t3)
addi $t3, $t4, 1540
addi $t3, $t4, 1544
li $t5, 0x030303
sw $t5, 0($t3)
addi $t3, $t4, 1548
addi $t3, $t4, 1552
addi $t3, $t4, 1556
addi $t3, $t4, 1560
addi $t3, $t4, 1564
addi $t3, $t4, 1568
addi $t3, $t4, 1572
addi $t3, $t4, 1576
addi $t3, $t4, 1580
addi $t3, $t4, 1584
addi $t3, $t4, 1588
addi $t3, $t4, 1592
addi $t3, $t4, 1596
li $t5, 0x000001
sw $t5, 0($t3)
addi $t3, $t4, 1600
addi $t3, $t4, 1604
addi $t3, $t4, 1608
addi $t3, $t4, 1612
addi $t3, $t4, 1616
sw $t5, 0($t3)
addi $t3, $t4, 1620
addi $t3, $t4, 1624
addi $t3, $t4, 1628
addi $t3, $t4, 1632
addi $t3, $t4, 1636
addi $t3, $t4, 1640
addi $t3, $t4, 1644
addi $t3, $t4, 1648
addi $t3, $t4, 1652
addi $t3, $t4, 1656
addi $t3, $t4, 1660
addi $t3, $t4, 1664
addi $t3, $t4, 1668
addi $t3, $t4, 1672
addi $t3, $t4, 1676
addi $t3, $t4, 1680
addi $t3, $t4, 1684
addi $t3, $t4, 1688
addi $t3, $t4, 1692
addi $t3, $t4, 1696
addi $t3, $t4, 1700
addi $t3, $t4, 1704
addi $t3, $t4, 1708
addi $t3, $t4, 1712
addi $t3, $t4, 1716
addi $t3, $t4, 1720
addi $t3, $t4, 1724
addi $t3, $t4, 1728
addi $t3, $t4, 1732
addi $t3, $t4, 1736
addi $t3, $t4, 1740
addi $t3, $t4, 1744
addi $t3, $t4, 1748
addi $t3, $t4, 1752
addi $t3, $t4, 1756
addi $t3, $t4, 1760
addi $t3, $t4, 1764
addi $t3, $t4, 1768
addi $t3, $t4, 1772
addi $t3, $t4, 1776
addi $t3, $t4, 1780
li $t5, 0x030303
sw $t5, 0($t3)
addi $t3, $t4, 1784
addi $t3, $t4, 1788
li $t5, 0x636363
sw $t5, 0($t3)
syscall      # sleeps for 30 ms
addi $t3, $t4, 1792
li $t5, 0x727272
sw $t5, 0($t3)
addi $t3, $t4, 1796
addi $t3, $t4, 1800
li $t5, 0x030303
sw $t5, 0($t3)
addi $t3, $t4, 1804
addi $t3, $t4, 1808
addi $t3, $t4, 1812
addi $t3, $t4, 1816
addi $t3, $t4, 1820
addi $t3, $t4, 1824
addi $t3, $t4, 1828
addi $t3, $t4, 1832
addi $t3, $t4, 1836
addi $t3, $t4, 1840
addi $t3, $t4, 1844
addi $t3, $t4, 1848
li $t5, 0x000102
sw $t5, 0($t3)
addi $t3, $t4, 1852
addi $t3, $t4, 1856
li $t5, 0x014a65
sw $t5, 0($t3)
addi $t3, $t4, 1860
li $t5, 0x0179a5
sw $t5, 0($t3)
addi $t3, $t4, 1864
sw $t5, 0($t3)
addi $t3, $t4, 1868
li $t5, 0x015473
sw $t5, 0($t3)
addi $t3, $t4, 1872
addi $t3, $t4, 1876
li $t5, 0x004a65
sw $t5, 0($t3)
addi $t3, $t4, 1880
li $t5, 0x007ba7
sw $t5, 0($t3)
addi $t3, $t4, 1884
li $t5, 0x00729b
sw $t5, 0($t3)
addi $t3, $t4, 1888
li $t5, 0x0078a3
sw $t5, 0($t3)
addi $t3, $t4, 1892
li $t5, 0x00719a
sw $t5, 0($t3)
addi $t3, $t4, 1896
li $t5, 0x007ca7
sw $t5, 0($t3)
addi $t3, $t4, 1900
li $t5, 0x013c52
sw $t5, 0($t3)
addi $t3, $t4, 1904
addi $t3, $t4, 1908
addi $t3, $t4, 1912
li $t5, 0x00080b
sw $t5, 0($t3)
addi $t3, $t4, 1916
li $t5, 0x0178a3
sw $t5, 0($t3)
addi $t3, $t4, 1920
li $t5, 0x001a24
sw $t5, 0($t3)
addi $t3, $t4, 1924
addi $t3, $t4, 1928
li $t5, 0x000304
sw $t5, 0($t3)
addi $t3, $t4, 1932
addi $t3, $t4, 1936
li $t5, 0x002e3f
sw $t5, 0($t3)
addi $t3, $t4, 1940
li $t5, 0x017ba8
sw $t5, 0($t3)
addi $t3, $t4, 1944
li $t5, 0x016c94
sw $t5, 0($t3)
addi $t3, $t4, 1948
li $t5, 0x01729b
sw $t5, 0($t3)
addi $t3, $t4, 1952
li $t5, 0x015675
sw $t5, 0($t3)
addi $t3, $t4, 1956
li $t5, 0x000202
sw $t5, 0($t3)
addi $t3, $t4, 1960
li $t5, 0x001c27
sw $t5, 0($t3)
addi $t3, $t4, 1964
li $t5, 0x0078a4
sw $t5, 0($t3)
addi $t3, $t4, 1968
li $t5, 0x00739c
sw $t5, 0($t3)
addi $t3, $t4, 1972
li $t5, 0x0077a2
sw $t5, 0($t3)
addi $t3, $t4, 1976
li $t5, 0x00749e
sw $t5, 0($t3)
addi $t3, $t4, 1980
li $t5, 0x0077a2
sw $t5, 0($t3)
addi $t3, $t4, 1984
li $t5, 0x00658a
sw $t5, 0($t3)
addi $t3, $t4, 1988
li $t5, 0x000304
sw $t5, 0($t3)
addi $t3, $t4, 1992
addi $t3, $t4, 1996
li $t5, 0x000101
sw $t5, 0($t3)
addi $t3, $t4, 2000
addi $t3, $t4, 2004
addi $t3, $t4, 2008
addi $t3, $t4, 2012
addi $t3, $t4, 2016
addi $t3, $t4, 2020
addi $t3, $t4, 2024
addi $t3, $t4, 2028
addi $t3, $t4, 2032
addi $t3, $t4, 2036
li $t5, 0x030303
sw $t5, 0($t3)
addi $t3, $t4, 2040
addi $t3, $t4, 2044
li $t5, 0x636363
sw $t5, 0($t3)
syscall      # sleeps for 30 ms
addi $t3, $t4, 2048
li $t5, 0x727272
sw $t5, 0($t3)
addi $t3, $t4, 2052
addi $t3, $t4, 2056
li $t5, 0x030303
sw $t5, 0($t3)
addi $t3, $t4, 2060
addi $t3, $t4, 2064
addi $t3, $t4, 2068
addi $t3, $t4, 2072
addi $t3, $t4, 2076
addi $t3, $t4, 2080
addi $t3, $t4, 2084
addi $t3, $t4, 2088
addi $t3, $t4, 2092
addi $t3, $t4, 2096
addi $t3, $t4, 2100
li $t5, 0x000202
sw $t5, 0($t3)
addi $t3, $t4, 2104
addi $t3, $t4, 2108
li $t5, 0x003041
sw $t5, 0($t3)
addi $t3, $t4, 2112
li $t5, 0x0183b2
sw $t5, 0($t3)
addi $t3, $t4, 2116
li $t5, 0x001219
sw $t5, 0($t3)
addi $t3, $t4, 2120
li $t5, 0x000f15
sw $t5, 0($t3)
addi $t3, $t4, 2124
li $t5, 0x0180ae
sw $t5, 0($t3)
addi $t3, $t4, 2128
li $t5, 0x01455e
sw $t5, 0($t3)
addi $t3, $t4, 2132
li $t5, 0x001219
sw $t5, 0($t3)
addi $t3, $t4, 2136
li $t5, 0x001f2b
sw $t5, 0($t3)
addi $t3, $t4, 2140
li $t5, 0x002e3e
sw $t5, 0($t3)
addi $t3, $t4, 2144
li $t5, 0x018fc3
sw $t5, 0($t3)
addi $t3, $t4, 2148
li $t5, 0x001d27
sw $t5, 0($t3)
addi $t3, $t4, 2152
li $t5, 0x00202b
sw $t5, 0($t3)
addi $t3, $t4, 2156
li $t5, 0x000f15
sw $t5, 0($t3)
addi $t3, $t4, 2160
li $t5, 0x000203
sw $t5, 0($t3)
addi $t3, $t4, 2164
addi $t3, $t4, 2168
li $t5, 0x00394e
sw $t5, 0($t3)
addi $t3, $t4, 2172
li $t5, 0x019fd8
sw $t5, 0($t3)
addi $t3, $t4, 2176
li $t5, 0x01516f
sw $t5, 0($t3)
addi $t3, $t4, 2180
addi $t3, $t4, 2184
li $t5, 0x000508
sw $t5, 0($t3)
addi $t3, $t4, 2188
addi $t3, $t4, 2192
li $t5, 0x00526f
sw $t5, 0($t3)
addi $t3, $t4, 2196
li $t5, 0x006b92
sw $t5, 0($t3)
addi $t3, $t4, 2200
li $t5, 0x00171f
sw $t5, 0($t3)
addi $t3, $t4, 2204
li $t5, 0x001f2b
sw $t5, 0($t3)
addi $t3, $t4, 2208
li $t5, 0x016c92
sw $t5, 0($t3)
addi $t3, $t4, 2212
li $t5, 0x016c93
sw $t5, 0($t3)
addi $t3, $t4, 2216
li $t5, 0x000608
sw $t5, 0($t3)
addi $t3, $t4, 2220
li $t5, 0x00232f
sw $t5, 0($t3)
addi $t3, $t4, 2224
li $t5, 0x001d28
sw $t5, 0($t3)
addi $t3, $t4, 2228
li $t5, 0x017fad
sw $t5, 0($t3)
addi $t3, $t4, 2232
li $t5, 0x004c67
sw $t5, 0($t3)
addi $t3, $t4, 2236
li $t5, 0x001e29
sw $t5, 0($t3)
addi $t3, $t4, 2240
li $t5, 0x001c26
sw $t5, 0($t3)
addi $t3, $t4, 2244
li $t5, 0x000101
sw $t5, 0($t3)
addi $t3, $t4, 2248
addi $t3, $t4, 2252
addi $t3, $t4, 2256
addi $t3, $t4, 2260
addi $t3, $t4, 2264
addi $t3, $t4, 2268
addi $t3, $t4, 2272
addi $t3, $t4, 2276
addi $t3, $t4, 2280
addi $t3, $t4, 2284
addi $t3, $t4, 2288
addi $t3, $t4, 2292
li $t5, 0x030303
sw $t5, 0($t3)
addi $t3, $t4, 2296
addi $t3, $t4, 2300
li $t5, 0x636363
sw $t5, 0($t3)
syscall      # sleeps for 30 ms
addi $t3, $t4, 2304
li $t5, 0x727272
sw $t5, 0($t3)
addi $t3, $t4, 2308
addi $t3, $t4, 2312
li $t5, 0x030303
sw $t5, 0($t3)
addi $t3, $t4, 2316
addi $t3, $t4, 2320
addi $t3, $t4, 2324
addi $t3, $t4, 2328
addi $t3, $t4, 2332
addi $t3, $t4, 2336
addi $t3, $t4, 2340
addi $t3, $t4, 2344
addi $t3, $t4, 2348
addi $t3, $t4, 2352
addi $t3, $t4, 2356
li $t5, 0x000304
sw $t5, 0($t3)
addi $t3, $t4, 2360
addi $t3, $t4, 2364
li $t5, 0x015676
sw $t5, 0($t3)
addi $t3, $t4, 2368
li $t5, 0x014760
sw $t5, 0($t3)
addi $t3, $t4, 2372
addi $t3, $t4, 2376
li $t5, 0x000101
sw $t5, 0($t3)
addi $t3, $t4, 2380
li $t5, 0x000c10
sw $t5, 0($t3)
addi $t3, $t4, 2384
li $t5, 0x001d28
sw $t5, 0($t3)
addi $t3, $t4, 2388
addi $t3, $t4, 2392
addi $t3, $t4, 2396
li $t5, 0x000d10
sw $t5, 0($t3)
addi $t3, $t4, 2400
li $t5, 0x017ba8
sw $t5, 0($t3)
addi $t3, $t4, 2404
addi $t3, $t4, 2408
addi $t3, $t4, 2412
addi $t3, $t4, 2416
li $t5, 0x000202
sw $t5, 0($t3)
addi $t3, $t4, 2420
addi $t3, $t4, 2424
li $t5, 0x01739c
sw $t5, 0($t3)
addi $t3, $t4, 2428
li $t5, 0x012b3a
sw $t5, 0($t3)
addi $t3, $t4, 2432
li $t5, 0x0175a0
sw $t5, 0($t3)
addi $t3, $t4, 2436
li $t5, 0x000608
sw $t5, 0($t3)
addi $t3, $t4, 2440
li $t5, 0x000202
sw $t5, 0($t3)
addi $t3, $t4, 2444
addi $t3, $t4, 2448
li $t5, 0x004e6a
sw $t5, 0($t3)
addi $t3, $t4, 2452
li $t5, 0x005473
sw $t5, 0($t3)
addi $t3, $t4, 2456
addi $t3, $t4, 2460
addi $t3, $t4, 2464
addi $t3, $t4, 2468
li $t5, 0x0188b9
sw $t5, 0($t3)
addi $t3, $t4, 2472
li $t5, 0x000c11
sw $t5, 0($t3)
addi $t3, $t4, 2476
addi $t3, $t4, 2480
addi $t3, $t4, 2484
li $t5, 0x01698f
sw $t5, 0($t3)
addi $t3, $t4, 2488
li $t5, 0x002e3f
sw $t5, 0($t3)
addi $t3, $t4, 2492
addi $t3, $t4, 2496
addi $t3, $t4, 2500
addi $t3, $t4, 2504
addi $t3, $t4, 2508
addi $t3, $t4, 2512
addi $t3, $t4, 2516
addi $t3, $t4, 2520
addi $t3, $t4, 2524
addi $t3, $t4, 2528
addi $t3, $t4, 2532
addi $t3, $t4, 2536
addi $t3, $t4, 2540
addi $t3, $t4, 2544
addi $t3, $t4, 2548
li $t5, 0x030303
sw $t5, 0($t3)
addi $t3, $t4, 2552
addi $t3, $t4, 2556
li $t5, 0x636363
sw $t5, 0($t3)
syscall      # sleeps for 30 ms
addi $t3, $t4, 2560
li $t5, 0x727272
sw $t5, 0($t3)
addi $t3, $t4, 2564
addi $t3, $t4, 2568
li $t5, 0x030303
sw $t5, 0($t3)
addi $t3, $t4, 2572
addi $t3, $t4, 2576
addi $t3, $t4, 2580
addi $t3, $t4, 2584
addi $t3, $t4, 2588
addi $t3, $t4, 2592
addi $t3, $t4, 2596
addi $t3, $t4, 2600
addi $t3, $t4, 2604
addi $t3, $t4, 2608
addi $t3, $t4, 2612
li $t5, 0x000203
sw $t5, 0($t3)
addi $t3, $t4, 2616
addi $t3, $t4, 2620
li $t5, 0x003143
sw $t5, 0($t3)
addi $t3, $t4, 2624
li $t5, 0x0189ba
sw $t5, 0($t3)
addi $t3, $t4, 2628
li $t5, 0x000e12
sw $t5, 0($t3)
addi $t3, $t4, 2632
addi $t3, $t4, 2636
addi $t3, $t4, 2640
addi $t3, $t4, 2644
li $t5, 0x000202
sw $t5, 0($t3)
addi $t3, $t4, 2648
li $t5, 0x000102
sw $t5, 0($t3)
addi $t3, $t4, 2652
li $t5, 0x00141a
sw $t5, 0($t3)
addi $t3, $t4, 2656
li $t5, 0x017fad
sw $t5, 0($t3)
addi $t3, $t4, 2660
li $t5, 0x000101
sw $t5, 0($t3)
addi $t3, $t4, 2664
li $t5, 0x000102
sw $t5, 0($t3)
addi $t3, $t4, 2668
li $t5, 0x000202
sw $t5, 0($t3)
addi $t3, $t4, 2672
addi $t3, $t4, 2676
li $t5, 0x001923
sw $t5, 0($t3)
addi $t3, $t4, 2680
li $t5, 0x017fad
sw $t5, 0($t3)
addi $t3, $t4, 2684
addi $t3, $t4, 2688
li $t5, 0x016e95
sw $t5, 0($t3)
addi $t3, $t4, 2692
li $t5, 0x003447
sw $t5, 0($t3)
addi $t3, $t4, 2696
addi $t3, $t4, 2700
addi $t3, $t4, 2704
li $t5, 0x00506c
sw $t5, 0($t3)
addi $t3, $t4, 2708
li $t5, 0x005371
sw $t5, 0($t3)
addi $t3, $t4, 2712
addi $t3, $t4, 2716
addi $t3, $t4, 2720
li $t5, 0x000507
sw $t5, 0($t3)
addi $t3, $t4, 2724
li $t5, 0x0189bb
sw $t5, 0($t3)
addi $t3, $t4, 2728
li $t5, 0x000a0e
sw $t5, 0($t3)
addi $t3, $t4, 2732
li $t5, 0x000203
sw $t5, 0($t3)
addi $t3, $t4, 2736
li $t5, 0x000101
sw $t5, 0($t3)
addi $t3, $t4, 2740
li $t5, 0x016d96
sw $t5, 0($t3)
addi $t3, $t4, 2744
li $t5, 0x003548
sw $t5, 0($t3)
addi $t3, $t4, 2748
li $t5, 0x000102
sw $t5, 0($t3)
addi $t3, $t4, 2752
li $t5, 0x000304
sw $t5, 0($t3)
addi $t3, $t4, 2756
addi $t3, $t4, 2760
addi $t3, $t4, 2764
addi $t3, $t4, 2768
addi $t3, $t4, 2772
addi $t3, $t4, 2776
addi $t3, $t4, 2780
addi $t3, $t4, 2784
addi $t3, $t4, 2788
addi $t3, $t4, 2792
addi $t3, $t4, 2796
addi $t3, $t4, 2800
addi $t3, $t4, 2804
li $t5, 0x030303
sw $t5, 0($t3)
addi $t3, $t4, 2808
addi $t3, $t4, 2812
li $t5, 0x636363
sw $t5, 0($t3)
syscall      # sleeps for 30 ms
addi $t3, $t4, 2816
li $t5, 0x727272
sw $t5, 0($t3)
addi $t3, $t4, 2820
addi $t3, $t4, 2824
li $t5, 0x030303
sw $t5, 0($t3)
addi $t3, $t4, 2828
addi $t3, $t4, 2832
addi $t3, $t4, 2836
addi $t3, $t4, 2840
addi $t3, $t4, 2844
addi $t3, $t4, 2848
addi $t3, $t4, 2852
addi $t3, $t4, 2856
addi $t3, $t4, 2860
addi $t3, $t4, 2864
addi $t3, $t4, 2868
addi $t3, $t4, 2872
li $t5, 0x000102
sw $t5, 0($t3)
addi $t3, $t4, 2876
addi $t3, $t4, 2880
li $t5, 0x015371
sw $t5, 0($t3)
addi $t3, $t4, 2884
li $t5, 0x018ebe
sw $t5, 0($t3)
addi $t3, $t4, 2888
li $t5, 0x016a8d
sw $t5, 0($t3)
addi $t3, $t4, 2892
li $t5, 0x00212d
sw $t5, 0($t3)
addi $t3, $t4, 2896
addi $t3, $t4, 2900
li $t5, 0x000202
sw $t5, 0($t3)
addi $t3, $t4, 2904
addi $t3, $t4, 2908
li $t5, 0x001319
sw $t5, 0($t3)
addi $t3, $t4, 2912
li $t5, 0x017fad
sw $t5, 0($t3)
addi $t3, $t4, 2916
addi $t3, $t4, 2920
addi $t3, $t4, 2924
li $t5, 0x000304
sw $t5, 0($t3)
addi $t3, $t4, 2928
addi $t3, $t4, 2932
li $t5, 0x015270
sw $t5, 0($t3)
addi $t3, $t4, 2936
li $t5, 0x004c68
sw $t5, 0($t3)
addi $t3, $t4, 2940
addi $t3, $t4, 2944
li $t5, 0x003143
sw $t5, 0($t3)
addi $t3, $t4, 2948
li $t5, 0x01688e
sw $t5, 0($t3)
addi $t3, $t4, 2952
addi $t3, $t4, 2956
addi $t3, $t4, 2960
li $t5, 0x004c67
sw $t5, 0($t3)
addi $t3, $t4, 2964
li $t5, 0x017099
sw $t5, 0($t3)
addi $t3, $t4, 2968
li $t5, 0x012937
sw $t5, 0($t3)
addi $t3, $t4, 2972
li $t5, 0x002836
sw $t5, 0($t3)
addi $t3, $t4, 2976
li $t5, 0x0178a4
sw $t5, 0($t3)
addi $t3, $t4, 2980
li $t5, 0x015473
sw $t5, 0($t3)
addi $t3, $t4, 2984
addi $t3, $t4, 2988
li $t5, 0x000506
sw $t5, 0($t3)
addi $t3, $t4, 2992
addi $t3, $t4, 2996
li $t5, 0x016d95
sw $t5, 0($t3)
addi $t3, $t4, 3000
li $t5, 0x003447
sw $t5, 0($t3)
addi $t3, $t4, 3004
addi $t3, $t4, 3008
li $t5, 0x000203
sw $t5, 0($t3)
addi $t3, $t4, 3012
addi $t3, $t4, 3016
addi $t3, $t4, 3020
addi $t3, $t4, 3024
addi $t3, $t4, 3028
addi $t3, $t4, 3032
addi $t3, $t4, 3036
addi $t3, $t4, 3040
addi $t3, $t4, 3044
addi $t3, $t4, 3048
addi $t3, $t4, 3052
addi $t3, $t4, 3056
addi $t3, $t4, 3060
li $t5, 0x030303
sw $t5, 0($t3)
addi $t3, $t4, 3064
addi $t3, $t4, 3068
li $t5, 0x636363
sw $t5, 0($t3)
syscall      # sleeps for 30 ms
addi $t3, $t4, 3072
li $t5, 0x727272
sw $t5, 0($t3)
addi $t3, $t4, 3076
addi $t3, $t4, 3080
li $t5, 0x030303
sw $t5, 0($t3)
addi $t3, $t4, 3084
addi $t3, $t4, 3088
addi $t3, $t4, 3092
addi $t3, $t4, 3096
addi $t3, $t4, 3100
addi $t3, $t4, 3104
addi $t3, $t4, 3108
addi $t3, $t4, 3112
addi $t3, $t4, 3116
addi $t3, $t4, 3120
addi $t3, $t4, 3124
addi $t3, $t4, 3128
addi $t3, $t4, 3132
li $t5, 0x000202
sw $t5, 0($t3)
addi $t3, $t4, 3136
addi $t3, $t4, 3140
li $t5, 0x000f14
sw $t5, 0($t3)
addi $t3, $t4, 3144
li $t5, 0x004962
sw $t5, 0($t3)
addi $t3, $t4, 3148
li $t5, 0x0193c8
sw $t5, 0($t3)
addi $t3, $t4, 3152
li $t5, 0x003345
sw $t5, 0($t3)
addi $t3, $t4, 3156
li $t5, 0x000001
sw $t5, 0($t3)
addi $t3, $t4, 3160
addi $t3, $t4, 3164
li $t5, 0x001319
sw $t5, 0($t3)
addi $t3, $t4, 3168
li $t5, 0x017fad
sw $t5, 0($t3)
addi $t3, $t4, 3172
addi $t3, $t4, 3176
addi $t3, $t4, 3180
li $t5, 0x000102
sw $t5, 0($t3)
addi $t3, $t4, 3184
addi $t3, $t4, 3188
li $t5, 0x0183b3
sw $t5, 0($t3)
addi $t3, $t4, 3192
li $t5, 0x013a50
sw $t5, 0($t3)
addi $t3, $t4, 3196
li $t5, 0x01202c
sw $t5, 0($t3)
addi $t3, $t4, 3200
li $t5, 0x002938
sw $t5, 0($t3)
addi $t3, $t4, 3204
li $t5, 0x018cbe
sw $t5, 0($t3)
addi $t3, $t4, 3208
li $t5, 0x000b10
sw $t5, 0($t3)
addi $t3, $t4, 3212
addi $t3, $t4, 3216
li $t5, 0x004863
sw $t5, 0($t3)
addi $t3, $t4, 3220
li $t5, 0x018fc2
sw $t5, 0($t3)
addi $t3, $t4, 3224
li $t5, 0x016184
sw $t5, 0($t3)
addi $t3, $t4, 3228
li $t5, 0x01a6e2
sw $t5, 0($t3)
addi $t3, $t4, 3232
li $t5, 0x01394e
sw $t5, 0($t3)
addi $t3, $t4, 3236
addi $t3, $t4, 3240
li $t5, 0x000102
sw $t5, 0($t3)
addi $t3, $t4, 3244
li $t5, 0x000303
sw $t5, 0($t3)
addi $t3, $t4, 3248
addi $t3, $t4, 3252
li $t5, 0x016d95
sw $t5, 0($t3)
addi $t3, $t4, 3256
li $t5, 0x003447
sw $t5, 0($t3)
addi $t3, $t4, 3260
addi $t3, $t4, 3264
li $t5, 0x000203
sw $t5, 0($t3)
addi $t3, $t4, 3268
addi $t3, $t4, 3272
addi $t3, $t4, 3276
addi $t3, $t4, 3280
addi $t3, $t4, 3284
addi $t3, $t4, 3288
addi $t3, $t4, 3292
addi $t3, $t4, 3296
addi $t3, $t4, 3300
addi $t3, $t4, 3304
addi $t3, $t4, 3308
addi $t3, $t4, 3312
addi $t3, $t4, 3316
li $t5, 0x030303
sw $t5, 0($t3)
addi $t3, $t4, 3320
addi $t3, $t4, 3324
li $t5, 0x636363
sw $t5, 0($t3)
syscall      # sleeps for 30 ms
addi $t3, $t4, 3328
li $t5, 0x727272
sw $t5, 0($t3)
addi $t3, $t4, 3332
addi $t3, $t4, 3336
li $t5, 0x030303
sw $t5, 0($t3)
addi $t3, $t4, 3340
addi $t3, $t4, 3344
addi $t3, $t4, 3348
addi $t3, $t4, 3352
addi $t3, $t4, 3356
addi $t3, $t4, 3360
addi $t3, $t4, 3364
addi $t3, $t4, 3368
addi $t3, $t4, 3372
addi $t3, $t4, 3376
addi $t3, $t4, 3380
addi $t3, $t4, 3384
addi $t3, $t4, 3388
addi $t3, $t4, 3392
addi $t3, $t4, 3396
addi $t3, $t4, 3400
addi $t3, $t4, 3404
li $t5, 0x002c3c
sw $t5, 0($t3)
addi $t3, $t4, 3408
li $t5, 0x017aa7
sw $t5, 0($t3)
addi $t3, $t4, 3412
addi $t3, $t4, 3416
addi $t3, $t4, 3420
li $t5, 0x001319
sw $t5, 0($t3)
addi $t3, $t4, 3424
li $t5, 0x017fad
sw $t5, 0($t3)
addi $t3, $t4, 3428
addi $t3, $t4, 3432
li $t5, 0x000102
sw $t5, 0($t3)
addi $t3, $t4, 3436
addi $t3, $t4, 3440
li $t5, 0x001f2a
sw $t5, 0($t3)
addi $t3, $t4, 3444
li $t5, 0x0096cd
sw $t5, 0($t3)
addi $t3, $t4, 3448
li $t5, 0x006c94
sw $t5, 0($t3)
addi $t3, $t4, 3452
li $t5, 0x006f97
sw $t5, 0($t3)
addi $t3, $t4, 3456
li $t5, 0x006b92
sw $t5, 0($t3)
addi $t3, $t4, 3460
li $t5, 0x0094ca
sw $t5, 0($t3)
addi $t3, $t4, 3464
li $t5, 0x003b51
sw $t5, 0($t3)
addi $t3, $t4, 3468
li $t5, 0x000001
sw $t5, 0($t3)
addi $t3, $t4, 3472
li $t5, 0x015270
sw $t5, 0($t3)
addi $t3, $t4, 3476
li $t5, 0x015371
sw $t5, 0($t3)
addi $t3, $t4, 3480
addi $t3, $t4, 3484
li $t5, 0x015d7f
sw $t5, 0($t3)
addi $t3, $t4, 3488
li $t5, 0x014e6a
sw $t5, 0($t3)
addi $t3, $t4, 3492
addi $t3, $t4, 3496
li $t5, 0x000203
sw $t5, 0($t3)
addi $t3, $t4, 3500
li $t5, 0x000303
sw $t5, 0($t3)
addi $t3, $t4, 3504
addi $t3, $t4, 3508
li $t5, 0x016d95
sw $t5, 0($t3)
addi $t3, $t4, 3512
li $t5, 0x003447
sw $t5, 0($t3)
addi $t3, $t4, 3516
addi $t3, $t4, 3520
li $t5, 0x000203
sw $t5, 0($t3)
addi $t3, $t4, 3524
addi $t3, $t4, 3528
addi $t3, $t4, 3532
addi $t3, $t4, 3536
addi $t3, $t4, 3540
addi $t3, $t4, 3544
addi $t3, $t4, 3548
addi $t3, $t4, 3552
addi $t3, $t4, 3556
addi $t3, $t4, 3560
addi $t3, $t4, 3564
addi $t3, $t4, 3568
addi $t3, $t4, 3572
li $t5, 0x030303
sw $t5, 0($t3)
addi $t3, $t4, 3576
addi $t3, $t4, 3580
li $t5, 0x636363
sw $t5, 0($t3)
syscall      # sleeps for 30 ms
addi $t3, $t4, 3584
li $t5, 0x727272
sw $t5, 0($t3)
addi $t3, $t4, 3588
addi $t3, $t4, 3592
li $t5, 0x030303
sw $t5, 0($t3)
addi $t3, $t4, 3596
addi $t3, $t4, 3600
addi $t3, $t4, 3604
addi $t3, $t4, 3608
addi $t3, $t4, 3612
addi $t3, $t4, 3616
addi $t3, $t4, 3620
addi $t3, $t4, 3624
addi $t3, $t4, 3628
addi $t3, $t4, 3632
addi $t3, $t4, 3636
li $t5, 0x000203
sw $t5, 0($t3)
addi $t3, $t4, 3640
addi $t3, $t4, 3644
li $t5, 0x014d6a
sw $t5, 0($t3)
addi $t3, $t4, 3648
li $t5, 0x002431
sw $t5, 0($t3)
addi $t3, $t4, 3652
addi $t3, $t4, 3656
addi $t3, $t4, 3660
li $t5, 0x001b25
sw $t5, 0($t3)
addi $t3, $t4, 3664
li $t5, 0x017aa6
sw $t5, 0($t3)
addi $t3, $t4, 3668
addi $t3, $t4, 3672
addi $t3, $t4, 3676
li $t5, 0x001319
sw $t5, 0($t3)
addi $t3, $t4, 3680
li $t5, 0x017daa
sw $t5, 0($t3)
addi $t3, $t4, 3684
addi $t3, $t4, 3688
li $t5, 0x000203
sw $t5, 0($t3)
addi $t3, $t4, 3692
addi $t3, $t4, 3696
li $t5, 0x016082
sw $t5, 0($t3)
addi $t3, $t4, 3700
li $t5, 0x014b66
sw $t5, 0($t3)
addi $t3, $t4, 3704
addi $t3, $t4, 3708
addi $t3, $t4, 3712
addi $t3, $t4, 3716
li $t5, 0x002e3e
sw $t5, 0($t3)
addi $t3, $t4, 3720
li $t5, 0x0178a3
sw $t5, 0($t3)
addi $t3, $t4, 3724
addi $t3, $t4, 3728
li $t5, 0x00506d
sw $t5, 0($t3)
addi $t3, $t4, 3732
li $t5, 0x015879
sw $t5, 0($t3)
addi $t3, $t4, 3736
li $t5, 0x000203
sw $t5, 0($t3)
addi $t3, $t4, 3740
li $t5, 0x000a0e
sw $t5, 0($t3)
addi $t3, $t4, 3744
li $t5, 0x0190c5
sw $t5, 0($t3)
addi $t3, $t4, 3748
li $t5, 0x00171f
sw $t5, 0($t3)
addi $t3, $t4, 3752
addi $t3, $t4, 3756
li $t5, 0x000406
sw $t5, 0($t3)
addi $t3, $t4, 3760
addi $t3, $t4, 3764
li $t5, 0x016b93
sw $t5, 0($t3)
addi $t3, $t4, 3768
li $t5, 0x003346
sw $t5, 0($t3)
addi $t3, $t4, 3772
addi $t3, $t4, 3776
li $t5, 0x000203
sw $t5, 0($t3)
addi $t3, $t4, 3780
addi $t3, $t4, 3784
addi $t3, $t4, 3788
addi $t3, $t4, 3792
addi $t3, $t4, 3796
addi $t3, $t4, 3800
addi $t3, $t4, 3804
addi $t3, $t4, 3808
addi $t3, $t4, 3812
addi $t3, $t4, 3816
addi $t3, $t4, 3820
addi $t3, $t4, 3824
addi $t3, $t4, 3828
li $t5, 0x030303
sw $t5, 0($t3)
addi $t3, $t4, 3832
addi $t3, $t4, 3836
li $t5, 0x636363
sw $t5, 0($t3)
syscall      # sleeps for 30 ms
addi $t3, $t4, 3840
li $t5, 0x727272
sw $t5, 0($t3)
addi $t3, $t4, 3844
addi $t3, $t4, 3848
li $t5, 0x030303
sw $t5, 0($t3)
addi $t3, $t4, 3852
addi $t3, $t4, 3856
addi $t3, $t4, 3860
addi $t3, $t4, 3864
addi $t3, $t4, 3868
addi $t3, $t4, 3872
addi $t3, $t4, 3876
addi $t3, $t4, 3880
addi $t3, $t4, 3884
addi $t3, $t4, 3888
addi $t3, $t4, 3892
li $t5, 0x000203
sw $t5, 0($t3)
addi $t3, $t4, 3896
addi $t3, $t4, 3900
li $t5, 0x00384d
sw $t5, 0($t3)
addi $t3, $t4, 3904
li $t5, 0x018cbe
sw $t5, 0($t3)
addi $t3, $t4, 3908
li $t5, 0x002c3d
sw $t5, 0($t3)
addi $t3, $t4, 3912
li $t5, 0x002634
sw $t5, 0($t3)
addi $t3, $t4, 3916
li $t5, 0x0180ae
sw $t5, 0($t3)
addi $t3, $t4, 3920
li $t5, 0x014660
sw $t5, 0($t3)
addi $t3, $t4, 3924
addi $t3, $t4, 3928
addi $t3, $t4, 3932
li $t5, 0x00141b
sw $t5, 0($t3)
addi $t3, $t4, 3936
li $t5, 0x0188ba
sw $t5, 0($t3)
addi $t3, $t4, 3940
addi $t3, $t4, 3944
li $t5, 0x000001
sw $t5, 0($t3)
addi $t3, $t4, 3948
li $t5, 0x00090c
sw $t5, 0($t3)
addi $t3, $t4, 3952
li $t5, 0x018ec1
sw $t5, 0($t3)
addi $t3, $t4, 3956
li $t5, 0x00131a
sw $t5, 0($t3)
addi $t3, $t4, 3960
li $t5, 0x000203
sw $t5, 0($t3)
addi $t3, $t4, 3964
li $t5, 0x000304
sw $t5, 0($t3)
addi $t3, $t4, 3968
sw $t5, 0($t3)
addi $t3, $t4, 3972
li $t5, 0x000506
sw $t5, 0($t3)
addi $t3, $t4, 3976
li $t5, 0x018ec1
sw $t5, 0($t3)
addi $t3, $t4, 3980
li $t5, 0x000d12
sw $t5, 0($t3)
addi $t3, $t4, 3984
li $t5, 0x004f6b
sw $t5, 0($t3)
addi $t3, $t4, 3988
li $t5, 0x015f82
sw $t5, 0($t3)
addi $t3, $t4, 3992
addi $t3, $t4, 3996
addi $t3, $t4, 4000
li $t5, 0x003f56
sw $t5, 0($t3)
addi $t3, $t4, 4004
li $t5, 0x0183b3
sw $t5, 0($t3)
addi $t3, $t4, 4008
li $t5, 0x000405
sw $t5, 0($t3)
addi $t3, $t4, 4012
sw $t5, 0($t3)
addi $t3, $t4, 4016
addi $t3, $t4, 4020
li $t5, 0x0175a0
sw $t5, 0($t3)
addi $t3, $t4, 4024
li $t5, 0x00384c
sw $t5, 0($t3)
addi $t3, $t4, 4028
addi $t3, $t4, 4032
li $t5, 0x000203
sw $t5, 0($t3)
addi $t3, $t4, 4036
addi $t3, $t4, 4040
addi $t3, $t4, 4044
addi $t3, $t4, 4048
addi $t3, $t4, 4052
addi $t3, $t4, 4056
addi $t3, $t4, 4060
addi $t3, $t4, 4064
addi $t3, $t4, 4068
addi $t3, $t4, 4072
addi $t3, $t4, 4076
addi $t3, $t4, 4080
addi $t3, $t4, 4084
li $t5, 0x030303
sw $t5, 0($t3)
addi $t3, $t4, 4088
addi $t3, $t4, 4092
li $t5, 0x636363
sw $t5, 0($t3)
syscall      # sleeps for 30 ms
addi $t3, $t4, 4096
li $t5, 0x727272
sw $t5, 0($t3)
addi $t3, $t4, 4100
addi $t3, $t4, 4104
li $t5, 0x030303
sw $t5, 0($t3)
addi $t3, $t4, 4108
addi $t3, $t4, 4112
addi $t3, $t4, 4116
addi $t3, $t4, 4120
addi $t3, $t4, 4124
addi $t3, $t4, 4128
addi $t3, $t4, 4132
addi $t3, $t4, 4136
addi $t3, $t4, 4140
addi $t3, $t4, 4144
addi $t3, $t4, 4148
addi $t3, $t4, 4152
li $t5, 0x000101
sw $t5, 0($t3)
addi $t3, $t4, 4156
addi $t3, $t4, 4160
li $t5, 0x013346
sw $t5, 0($t3)
addi $t3, $t4, 4164
li $t5, 0x016d94
sw $t5, 0($t3)
addi $t3, $t4, 4168
li $t5, 0x016e97
sw $t5, 0($t3)
addi $t3, $t4, 4172
li $t5, 0x014159
sw $t5, 0($t3)
addi $t3, $t4, 4176
addi $t3, $t4, 4180
li $t5, 0x000102
sw $t5, 0($t3)
addi $t3, $t4, 4184
addi $t3, $t4, 4188
li $t5, 0x000a0d
sw $t5, 0($t3)
addi $t3, $t4, 4192
li $t5, 0x01425b
sw $t5, 0($t3)
addi $t3, $t4, 4196
li $t5, 0x000101
sw $t5, 0($t3)
addi $t3, $t4, 4200
addi $t3, $t4, 4204
li $t5, 0x00131a
sw $t5, 0($t3)
addi $t3, $t4, 4208
li $t5, 0x01435b
sw $t5, 0($t3)
addi $t3, $t4, 4212
addi $t3, $t4, 4216
li $t5, 0x000101
sw $t5, 0($t3)
addi $t3, $t4, 4220
addi $t3, $t4, 4224
li $t5, 0x000102
sw $t5, 0($t3)
addi $t3, $t4, 4228
addi $t3, $t4, 4232
li $t5, 0x013a4f
sw $t5, 0($t3)
addi $t3, $t4, 4236
li $t5, 0x001923
sw $t5, 0($t3)
addi $t3, $t4, 4240
li $t5, 0x00222f
sw $t5, 0($t3)
addi $t3, $t4, 4244
li $t5, 0x012f40
sw $t5, 0($t3)
addi $t3, $t4, 4248
addi $t3, $t4, 4252
li $t5, 0x000202
sw $t5, 0($t3)
addi $t3, $t4, 4256
addi $t3, $t4, 4260
li $t5, 0x014d69
sw $t5, 0($t3)
addi $t3, $t4, 4264
li $t5, 0x001017
sw $t5, 0($t3)
addi $t3, $t4, 4268
addi $t3, $t4, 4272
addi $t3, $t4, 4276
li $t5, 0x01394e
sw $t5, 0($t3)
addi $t3, $t4, 4280
li $t5, 0x001b25
sw $t5, 0($t3)
addi $t3, $t4, 4284
addi $t3, $t4, 4288
li $t5, 0x000102
sw $t5, 0($t3)
addi $t3, $t4, 4292
addi $t3, $t4, 4296
addi $t3, $t4, 4300
addi $t3, $t4, 4304
addi $t3, $t4, 4308
addi $t3, $t4, 4312
addi $t3, $t4, 4316
addi $t3, $t4, 4320
addi $t3, $t4, 4324
addi $t3, $t4, 4328
addi $t3, $t4, 4332
addi $t3, $t4, 4336
addi $t3, $t4, 4340
li $t5, 0x030303
sw $t5, 0($t3)
addi $t3, $t4, 4344
addi $t3, $t4, 4348
li $t5, 0x636363
sw $t5, 0($t3)
syscall      # sleeps for 30 ms
addi $t3, $t4, 4352
li $t5, 0x727272
sw $t5, 0($t3)
addi $t3, $t4, 4356
addi $t3, $t4, 4360
li $t5, 0x030303
sw $t5, 0($t3)
addi $t3, $t4, 4364
addi $t3, $t4, 4368
addi $t3, $t4, 4372
addi $t3, $t4, 4376
addi $t3, $t4, 4380
addi $t3, $t4, 4384
addi $t3, $t4, 4388
addi $t3, $t4, 4392
addi $t3, $t4, 4396
addi $t3, $t4, 4400
addi $t3, $t4, 4404
addi $t3, $t4, 4408
addi $t3, $t4, 4412
li $t5, 0x000101
sw $t5, 0($t3)
addi $t3, $t4, 4416
addi $t3, $t4, 4420
addi $t3, $t4, 4424
addi $t3, $t4, 4428
addi $t3, $t4, 4432
sw $t5, 0($t3)
addi $t3, $t4, 4436
addi $t3, $t4, 4440
addi $t3, $t4, 4444
addi $t3, $t4, 4448
addi $t3, $t4, 4452
addi $t3, $t4, 4456
addi $t3, $t4, 4460
addi $t3, $t4, 4464
addi $t3, $t4, 4468
li $t5, 0x000001
sw $t5, 0($t3)
addi $t3, $t4, 4472
addi $t3, $t4, 4476
addi $t3, $t4, 4480
addi $t3, $t4, 4484
addi $t3, $t4, 4488
addi $t3, $t4, 4492
addi $t3, $t4, 4496
addi $t3, $t4, 4500
addi $t3, $t4, 4504
addi $t3, $t4, 4508
addi $t3, $t4, 4512
sw $t5, 0($t3)
addi $t3, $t4, 4516
addi $t3, $t4, 4520
addi $t3, $t4, 4524
addi $t3, $t4, 4528
addi $t3, $t4, 4532
addi $t3, $t4, 4536
addi $t3, $t4, 4540
addi $t3, $t4, 4544
addi $t3, $t4, 4548
addi $t3, $t4, 4552
addi $t3, $t4, 4556
addi $t3, $t4, 4560
addi $t3, $t4, 4564
addi $t3, $t4, 4568
addi $t3, $t4, 4572
addi $t3, $t4, 4576
addi $t3, $t4, 4580
addi $t3, $t4, 4584
addi $t3, $t4, 4588
addi $t3, $t4, 4592
addi $t3, $t4, 4596
li $t5, 0x030303
sw $t5, 0($t3)
addi $t3, $t4, 4600
addi $t3, $t4, 4604
li $t5, 0x636363
sw $t5, 0($t3)
syscall      # sleeps for 30 ms
addi $t3, $t4, 4608
li $t5, 0x727272
sw $t5, 0($t3)
addi $t3, $t4, 4612
addi $t3, $t4, 4616
li $t5, 0x030303
sw $t5, 0($t3)
addi $t3, $t4, 4620
addi $t3, $t4, 4624
addi $t3, $t4, 4628
addi $t3, $t4, 4632
addi $t3, $t4, 4636
addi $t3, $t4, 4640
addi $t3, $t4, 4644
addi $t3, $t4, 4648
addi $t3, $t4, 4652
addi $t3, $t4, 4656
addi $t3, $t4, 4660
addi $t3, $t4, 4664
addi $t3, $t4, 4668
addi $t3, $t4, 4672
li $t5, 0x000203
sw $t5, 0($t3)
addi $t3, $t4, 4676
sw $t5, 0($t3)
addi $t3, $t4, 4680
sw $t5, 0($t3)
addi $t3, $t4, 4684
sw $t5, 0($t3)
addi $t3, $t4, 4688
addi $t3, $t4, 4692
addi $t3, $t4, 4696
addi $t3, $t4, 4700
addi $t3, $t4, 4704
sw $t5, 0($t3)
addi $t3, $t4, 4708
addi $t3, $t4, 4712
addi $t3, $t4, 4716
li $t5, 0x000001
sw $t5, 0($t3)
addi $t3, $t4, 4720
li $t5, 0x000203
sw $t5, 0($t3)
addi $t3, $t4, 4724
addi $t3, $t4, 4728
addi $t3, $t4, 4732
addi $t3, $t4, 4736
addi $t3, $t4, 4740
addi $t3, $t4, 4744
sw $t5, 0($t3)
addi $t3, $t4, 4748
li $t5, 0x000101
sw $t5, 0($t3)
addi $t3, $t4, 4752
li $t5, 0x000102
sw $t5, 0($t3)
addi $t3, $t4, 4756
sw $t5, 0($t3)
addi $t3, $t4, 4760
addi $t3, $t4, 4764
addi $t3, $t4, 4768
addi $t3, $t4, 4772
li $t5, 0x000203
sw $t5, 0($t3)
addi $t3, $t4, 4776
addi $t3, $t4, 4780
addi $t3, $t4, 4784
addi $t3, $t4, 4788
li $t5, 0x000202
sw $t5, 0($t3)
addi $t3, $t4, 4792
li $t5, 0x000101
sw $t5, 0($t3)
addi $t3, $t4, 4796
addi $t3, $t4, 4800
addi $t3, $t4, 4804
addi $t3, $t4, 4808
addi $t3, $t4, 4812
addi $t3, $t4, 4816
addi $t3, $t4, 4820
addi $t3, $t4, 4824
addi $t3, $t4, 4828
addi $t3, $t4, 4832
addi $t3, $t4, 4836
addi $t3, $t4, 4840
addi $t3, $t4, 4844
addi $t3, $t4, 4848
addi $t3, $t4, 4852
li $t5, 0x030303
sw $t5, 0($t3)
addi $t3, $t4, 4856
addi $t3, $t4, 4860
li $t5, 0x636363
sw $t5, 0($t3)
syscall      # sleeps for 30 ms
addi $t3, $t4, 4864
li $t5, 0x727272
sw $t5, 0($t3)
addi $t3, $t4, 4868
addi $t3, $t4, 4872
li $t5, 0x030303
sw $t5, 0($t3)
addi $t3, $t4, 4876
addi $t3, $t4, 4880
addi $t3, $t4, 4884
addi $t3, $t4, 4888
addi $t3, $t4, 4892
addi $t3, $t4, 4896
addi $t3, $t4, 4900
addi $t3, $t4, 4904
addi $t3, $t4, 4908
addi $t3, $t4, 4912
addi $t3, $t4, 4916
addi $t3, $t4, 4920
addi $t3, $t4, 4924
addi $t3, $t4, 4928
addi $t3, $t4, 4932
addi $t3, $t4, 4936
addi $t3, $t4, 4940
addi $t3, $t4, 4944
addi $t3, $t4, 4948
addi $t3, $t4, 4952
addi $t3, $t4, 4956
addi $t3, $t4, 4960
addi $t3, $t4, 4964
addi $t3, $t4, 4968
addi $t3, $t4, 4972
addi $t3, $t4, 4976
addi $t3, $t4, 4980
addi $t3, $t4, 4984
addi $t3, $t4, 4988
addi $t3, $t4, 4992
addi $t3, $t4, 4996
addi $t3, $t4, 5000
addi $t3, $t4, 5004
addi $t3, $t4, 5008
addi $t3, $t4, 5012
addi $t3, $t4, 5016
addi $t3, $t4, 5020
addi $t3, $t4, 5024
addi $t3, $t4, 5028
addi $t3, $t4, 5032
addi $t3, $t4, 5036
addi $t3, $t4, 5040
addi $t3, $t4, 5044
addi $t3, $t4, 5048
addi $t3, $t4, 5052
addi $t3, $t4, 5056
addi $t3, $t4, 5060
addi $t3, $t4, 5064
addi $t3, $t4, 5068
addi $t3, $t4, 5072
addi $t3, $t4, 5076
addi $t3, $t4, 5080
addi $t3, $t4, 5084
addi $t3, $t4, 5088
addi $t3, $t4, 5092
addi $t3, $t4, 5096
addi $t3, $t4, 5100
addi $t3, $t4, 5104
addi $t3, $t4, 5108
sw $t5, 0($t3)
addi $t3, $t4, 5112
addi $t3, $t4, 5116
li $t5, 0x636363
sw $t5, 0($t3)
syscall      # sleeps for 30 ms
addi $t3, $t4, 5120
li $t5, 0x727272
sw $t5, 0($t3)
addi $t3, $t4, 5124
addi $t3, $t4, 5128
li $t5, 0x030303
sw $t5, 0($t3)
addi $t3, $t4, 5132
addi $t3, $t4, 5136
addi $t3, $t4, 5140
addi $t3, $t4, 5144
addi $t3, $t4, 5148
addi $t3, $t4, 5152
addi $t3, $t4, 5156
addi $t3, $t4, 5160
addi $t3, $t4, 5164
addi $t3, $t4, 5168
addi $t3, $t4, 5172
addi $t3, $t4, 5176
addi $t3, $t4, 5180
addi $t3, $t4, 5184
addi $t3, $t4, 5188
addi $t3, $t4, 5192
addi $t3, $t4, 5196
addi $t3, $t4, 5200
addi $t3, $t4, 5204
addi $t3, $t4, 5208
addi $t3, $t4, 5212
addi $t3, $t4, 5216
addi $t3, $t4, 5220
addi $t3, $t4, 5224
addi $t3, $t4, 5228
addi $t3, $t4, 5232
addi $t3, $t4, 5236
addi $t3, $t4, 5240
addi $t3, $t4, 5244
addi $t3, $t4, 5248
addi $t3, $t4, 5252
addi $t3, $t4, 5256
addi $t3, $t4, 5260
addi $t3, $t4, 5264
addi $t3, $t4, 5268
addi $t3, $t4, 5272
addi $t3, $t4, 5276
addi $t3, $t4, 5280
addi $t3, $t4, 5284
addi $t3, $t4, 5288
addi $t3, $t4, 5292
addi $t3, $t4, 5296
addi $t3, $t4, 5300
addi $t3, $t4, 5304
addi $t3, $t4, 5308
addi $t3, $t4, 5312
addi $t3, $t4, 5316
addi $t3, $t4, 5320
addi $t3, $t4, 5324
addi $t3, $t4, 5328
addi $t3, $t4, 5332
addi $t3, $t4, 5336
addi $t3, $t4, 5340
addi $t3, $t4, 5344
addi $t3, $t4, 5348
addi $t3, $t4, 5352
addi $t3, $t4, 5356
addi $t3, $t4, 5360
addi $t3, $t4, 5364
sw $t5, 0($t3)
addi $t3, $t4, 5368
addi $t3, $t4, 5372
li $t5, 0x636363
sw $t5, 0($t3)
syscall      # sleeps for 30 ms
addi $t3, $t4, 5376
li $t5, 0x727272
sw $t5, 0($t3)
addi $t3, $t4, 5380
addi $t3, $t4, 5384
li $t5, 0x030303
sw $t5, 0($t3)
addi $t3, $t4, 5388
addi $t3, $t4, 5392
addi $t3, $t4, 5396
addi $t3, $t4, 5400
addi $t3, $t4, 5404
addi $t3, $t4, 5408
addi $t3, $t4, 5412
addi $t3, $t4, 5416
addi $t3, $t4, 5420
addi $t3, $t4, 5424
addi $t3, $t4, 5428
addi $t3, $t4, 5432
addi $t3, $t4, 5436
addi $t3, $t4, 5440
addi $t3, $t4, 5444
addi $t3, $t4, 5448
addi $t3, $t4, 5452
addi $t3, $t4, 5456
addi $t3, $t4, 5460
addi $t3, $t4, 5464
addi $t3, $t4, 5468
addi $t3, $t4, 5472
addi $t3, $t4, 5476
addi $t3, $t4, 5480
addi $t3, $t4, 5484
addi $t3, $t4, 5488
addi $t3, $t4, 5492
addi $t3, $t4, 5496
addi $t3, $t4, 5500
addi $t3, $t4, 5504
addi $t3, $t4, 5508
addi $t3, $t4, 5512
addi $t3, $t4, 5516
addi $t3, $t4, 5520
addi $t3, $t4, 5524
addi $t3, $t4, 5528
addi $t3, $t4, 5532
addi $t3, $t4, 5536
addi $t3, $t4, 5540
addi $t3, $t4, 5544
addi $t3, $t4, 5548
addi $t3, $t4, 5552
addi $t3, $t4, 5556
addi $t3, $t4, 5560
addi $t3, $t4, 5564
addi $t3, $t4, 5568
addi $t3, $t4, 5572
addi $t3, $t4, 5576
addi $t3, $t4, 5580
addi $t3, $t4, 5584
addi $t3, $t4, 5588
addi $t3, $t4, 5592
addi $t3, $t4, 5596
addi $t3, $t4, 5600
addi $t3, $t4, 5604
addi $t3, $t4, 5608
addi $t3, $t4, 5612
addi $t3, $t4, 5616
addi $t3, $t4, 5620
sw $t5, 0($t3)
addi $t3, $t4, 5624
addi $t3, $t4, 5628
li $t5, 0x636363
sw $t5, 0($t3)
syscall      # sleeps for 30 ms
addi $t3, $t4, 5632
li $t5, 0x727272
sw $t5, 0($t3)
addi $t3, $t4, 5636
addi $t3, $t4, 5640
li $t5, 0x030303
sw $t5, 0($t3)
addi $t3, $t4, 5644
addi $t3, $t4, 5648
addi $t3, $t4, 5652
addi $t3, $t4, 5656
addi $t3, $t4, 5660
addi $t3, $t4, 5664
addi $t3, $t4, 5668
addi $t3, $t4, 5672
addi $t3, $t4, 5676
addi $t3, $t4, 5680
addi $t3, $t4, 5684
addi $t3, $t4, 5688
addi $t3, $t4, 5692
addi $t3, $t4, 5696
addi $t3, $t4, 5700
addi $t3, $t4, 5704
addi $t3, $t4, 5708
addi $t3, $t4, 5712
addi $t3, $t4, 5716
addi $t3, $t4, 5720
addi $t3, $t4, 5724
addi $t3, $t4, 5728
addi $t3, $t4, 5732
addi $t3, $t4, 5736
addi $t3, $t4, 5740
addi $t3, $t4, 5744
addi $t3, $t4, 5748
addi $t3, $t4, 5752
addi $t3, $t4, 5756
addi $t3, $t4, 5760
addi $t3, $t4, 5764
addi $t3, $t4, 5768
addi $t3, $t4, 5772
addi $t3, $t4, 5776
addi $t3, $t4, 5780
addi $t3, $t4, 5784
addi $t3, $t4, 5788
addi $t3, $t4, 5792
addi $t3, $t4, 5796
addi $t3, $t4, 5800
addi $t3, $t4, 5804
addi $t3, $t4, 5808
addi $t3, $t4, 5812
addi $t3, $t4, 5816
addi $t3, $t4, 5820
addi $t3, $t4, 5824
addi $t3, $t4, 5828
addi $t3, $t4, 5832
addi $t3, $t4, 5836
addi $t3, $t4, 5840
addi $t3, $t4, 5844
addi $t3, $t4, 5848
addi $t3, $t4, 5852
addi $t3, $t4, 5856
addi $t3, $t4, 5860
addi $t3, $t4, 5864
addi $t3, $t4, 5868
addi $t3, $t4, 5872
addi $t3, $t4, 5876
sw $t5, 0($t3)
addi $t3, $t4, 5880
addi $t3, $t4, 5884
li $t5, 0x636363
sw $t5, 0($t3)
syscall      # sleeps for 30 ms
addi $t3, $t4, 5888
li $t5, 0x727272
sw $t5, 0($t3)
addi $t3, $t4, 5892
addi $t3, $t4, 5896
li $t5, 0x030303
sw $t5, 0($t3)
addi $t3, $t4, 5900
addi $t3, $t4, 5904
addi $t3, $t4, 5908
addi $t3, $t4, 5912
addi $t3, $t4, 5916
addi $t3, $t4, 5920
addi $t3, $t4, 5924
addi $t3, $t4, 5928
addi $t3, $t4, 5932
addi $t3, $t4, 5936
addi $t3, $t4, 5940
addi $t3, $t4, 5944
addi $t3, $t4, 5948
addi $t3, $t4, 5952
addi $t3, $t4, 5956
addi $t3, $t4, 5960
addi $t3, $t4, 5964
addi $t3, $t4, 5968
addi $t3, $t4, 5972
addi $t3, $t4, 5976
addi $t3, $t4, 5980
addi $t3, $t4, 5984
addi $t3, $t4, 5988
addi $t3, $t4, 5992
addi $t3, $t4, 5996
addi $t3, $t4, 6000
addi $t3, $t4, 6004
addi $t3, $t4, 6008
addi $t3, $t4, 6012
addi $t3, $t4, 6016
addi $t3, $t4, 6020
addi $t3, $t4, 6024
addi $t3, $t4, 6028
addi $t3, $t4, 6032
addi $t3, $t4, 6036
addi $t3, $t4, 6040
addi $t3, $t4, 6044
addi $t3, $t4, 6048
addi $t3, $t4, 6052
addi $t3, $t4, 6056
addi $t3, $t4, 6060
addi $t3, $t4, 6064
addi $t3, $t4, 6068
addi $t3, $t4, 6072
addi $t3, $t4, 6076
addi $t3, $t4, 6080
addi $t3, $t4, 6084
addi $t3, $t4, 6088
addi $t3, $t4, 6092
addi $t3, $t4, 6096
addi $t3, $t4, 6100
addi $t3, $t4, 6104
addi $t3, $t4, 6108
addi $t3, $t4, 6112
addi $t3, $t4, 6116
addi $t3, $t4, 6120
addi $t3, $t4, 6124
addi $t3, $t4, 6128
addi $t3, $t4, 6132
sw $t5, 0($t3)
addi $t3, $t4, 6136
addi $t3, $t4, 6140
li $t5, 0x636363
sw $t5, 0($t3)
syscall      # sleeps for 30 ms
addi $t3, $t4, 6144
li $t5, 0x727272
sw $t5, 0($t3)
addi $t3, $t4, 6148
addi $t3, $t4, 6152
li $t5, 0x030303
sw $t5, 0($t3)
addi $t3, $t4, 6156
addi $t3, $t4, 6160
addi $t3, $t4, 6164
addi $t3, $t4, 6168
addi $t3, $t4, 6172
addi $t3, $t4, 6176
addi $t3, $t4, 6180
addi $t3, $t4, 6184
addi $t3, $t4, 6188
addi $t3, $t4, 6192
addi $t3, $t4, 6196
addi $t3, $t4, 6200
addi $t3, $t4, 6204
addi $t3, $t4, 6208
addi $t3, $t4, 6212
addi $t3, $t4, 6216
addi $t3, $t4, 6220
addi $t3, $t4, 6224
addi $t3, $t4, 6228
addi $t3, $t4, 6232
addi $t3, $t4, 6236
addi $t3, $t4, 6240
addi $t3, $t4, 6244
addi $t3, $t4, 6248
addi $t3, $t4, 6252
addi $t3, $t4, 6256
addi $t3, $t4, 6260
addi $t3, $t4, 6264
addi $t3, $t4, 6268
addi $t3, $t4, 6272
addi $t3, $t4, 6276
addi $t3, $t4, 6280
addi $t3, $t4, 6284
addi $t3, $t4, 6288
addi $t3, $t4, 6292
addi $t3, $t4, 6296
addi $t3, $t4, 6300
addi $t3, $t4, 6304
addi $t3, $t4, 6308
addi $t3, $t4, 6312
addi $t3, $t4, 6316
addi $t3, $t4, 6320
addi $t3, $t4, 6324
addi $t3, $t4, 6328
addi $t3, $t4, 6332
addi $t3, $t4, 6336
addi $t3, $t4, 6340
addi $t3, $t4, 6344
addi $t3, $t4, 6348
addi $t3, $t4, 6352
addi $t3, $t4, 6356
addi $t3, $t4, 6360
addi $t3, $t4, 6364
addi $t3, $t4, 6368
addi $t3, $t4, 6372
addi $t3, $t4, 6376
addi $t3, $t4, 6380
addi $t3, $t4, 6384
addi $t3, $t4, 6388
sw $t5, 0($t3)
addi $t3, $t4, 6392
addi $t3, $t4, 6396
li $t5, 0x636363
sw $t5, 0($t3)
syscall      # sleeps for 30 ms
addi $t3, $t4, 6400
li $t5, 0x727272
sw $t5, 0($t3)
addi $t3, $t4, 6404
addi $t3, $t4, 6408
li $t5, 0x030303
sw $t5, 0($t3)
addi $t3, $t4, 6412
addi $t3, $t4, 6416
addi $t3, $t4, 6420
addi $t3, $t4, 6424
addi $t3, $t4, 6428
addi $t3, $t4, 6432
addi $t3, $t4, 6436
addi $t3, $t4, 6440
addi $t3, $t4, 6444
addi $t3, $t4, 6448
addi $t3, $t4, 6452
addi $t3, $t4, 6456
addi $t3, $t4, 6460
addi $t3, $t4, 6464
addi $t3, $t4, 6468
addi $t3, $t4, 6472
addi $t3, $t4, 6476
addi $t3, $t4, 6480
addi $t3, $t4, 6484
addi $t3, $t4, 6488
addi $t3, $t4, 6492
addi $t3, $t4, 6496
addi $t3, $t4, 6500
addi $t3, $t4, 6504
addi $t3, $t4, 6508
addi $t3, $t4, 6512
addi $t3, $t4, 6516
addi $t3, $t4, 6520
addi $t3, $t4, 6524
addi $t3, $t4, 6528
addi $t3, $t4, 6532
addi $t3, $t4, 6536
addi $t3, $t4, 6540
addi $t3, $t4, 6544
addi $t3, $t4, 6548
addi $t3, $t4, 6552
addi $t3, $t4, 6556
addi $t3, $t4, 6560
addi $t3, $t4, 6564
addi $t3, $t4, 6568
addi $t3, $t4, 6572
addi $t3, $t4, 6576
addi $t3, $t4, 6580
addi $t3, $t4, 6584
addi $t3, $t4, 6588
addi $t3, $t4, 6592
addi $t3, $t4, 6596
addi $t3, $t4, 6600
addi $t3, $t4, 6604
addi $t3, $t4, 6608
addi $t3, $t4, 6612
addi $t3, $t4, 6616
addi $t3, $t4, 6620
addi $t3, $t4, 6624
addi $t3, $t4, 6628
addi $t3, $t4, 6632
addi $t3, $t4, 6636
addi $t3, $t4, 6640
addi $t3, $t4, 6644
sw $t5, 0($t3)
addi $t3, $t4, 6648
addi $t3, $t4, 6652
li $t5, 0x636363
sw $t5, 0($t3)
syscall      # sleeps for 30 ms
addi $t3, $t4, 6656
li $t5, 0x727272
sw $t5, 0($t3)
addi $t3, $t4, 6660
addi $t3, $t4, 6664
li $t5, 0x030303
sw $t5, 0($t3)
addi $t3, $t4, 6668
addi $t3, $t4, 6672
addi $t3, $t4, 6676
addi $t3, $t4, 6680
addi $t3, $t4, 6684
addi $t3, $t4, 6688
addi $t3, $t4, 6692
addi $t3, $t4, 6696
addi $t3, $t4, 6700
addi $t3, $t4, 6704
addi $t3, $t4, 6708
addi $t3, $t4, 6712
addi $t3, $t4, 6716
addi $t3, $t4, 6720
addi $t3, $t4, 6724
addi $t3, $t4, 6728
li $t5, 0x000101
sw $t5, 0($t3)
addi $t3, $t4, 6732
li $t5, 0x000102
sw $t5, 0($t3)
addi $t3, $t4, 6736
li $t5, 0x000101
sw $t5, 0($t3)
addi $t3, $t4, 6740
addi $t3, $t4, 6744
addi $t3, $t4, 6748
addi $t3, $t4, 6752
addi $t3, $t4, 6756
addi $t3, $t4, 6760
addi $t3, $t4, 6764
sw $t5, 0($t3)
addi $t3, $t4, 6768
addi $t3, $t4, 6772
addi $t3, $t4, 6776
addi $t3, $t4, 6780
addi $t3, $t4, 6784
sw $t5, 0($t3)
addi $t3, $t4, 6788
addi $t3, $t4, 6792
addi $t3, $t4, 6796
addi $t3, $t4, 6800
addi $t3, $t4, 6804
addi $t3, $t4, 6808
addi $t3, $t4, 6812
li $t5, 0x000001
sw $t5, 0($t3)
addi $t3, $t4, 6816
li $t5, 0x000101
sw $t5, 0($t3)
addi $t3, $t4, 6820
addi $t3, $t4, 6824
addi $t3, $t4, 6828
sw $t5, 0($t3)
addi $t3, $t4, 6832
sw $t5, 0($t3)
addi $t3, $t4, 6836
sw $t5, 0($t3)
addi $t3, $t4, 6840
sw $t5, 0($t3)
addi $t3, $t4, 6844
addi $t3, $t4, 6848
addi $t3, $t4, 6852
addi $t3, $t4, 6856
addi $t3, $t4, 6860
addi $t3, $t4, 6864
addi $t3, $t4, 6868
addi $t3, $t4, 6872
addi $t3, $t4, 6876
addi $t3, $t4, 6880
addi $t3, $t4, 6884
addi $t3, $t4, 6888
addi $t3, $t4, 6892
addi $t3, $t4, 6896
addi $t3, $t4, 6900
li $t5, 0x030303
sw $t5, 0($t3)
addi $t3, $t4, 6904
addi $t3, $t4, 6908
li $t5, 0x636363
sw $t5, 0($t3)
syscall      # sleeps for 30 ms
addi $t3, $t4, 6912
li $t5, 0x727272
sw $t5, 0($t3)
addi $t3, $t4, 6916
addi $t3, $t4, 6920
li $t5, 0x030303
sw $t5, 0($t3)
addi $t3, $t4, 6924
addi $t3, $t4, 6928
addi $t3, $t4, 6932
addi $t3, $t4, 6936
addi $t3, $t4, 6940
addi $t3, $t4, 6944
addi $t3, $t4, 6948
addi $t3, $t4, 6952
addi $t3, $t4, 6956
addi $t3, $t4, 6960
addi $t3, $t4, 6964
addi $t3, $t4, 6968
addi $t3, $t4, 6972
addi $t3, $t4, 6976
li $t5, 0x000101
sw $t5, 0($t3)
addi $t3, $t4, 6980
sw $t5, 0($t3)
addi $t3, $t4, 6984
addi $t3, $t4, 6988
addi $t3, $t4, 6992
addi $t3, $t4, 6996
li $t5, 0x000203
sw $t5, 0($t3)
addi $t3, $t4, 7000
addi $t3, $t4, 7004
addi $t3, $t4, 7008
addi $t3, $t4, 7012
addi $t3, $t4, 7016
addi $t3, $t4, 7020
addi $t3, $t4, 7024
addi $t3, $t4, 7028
addi $t3, $t4, 7032
addi $t3, $t4, 7036
addi $t3, $t4, 7040
addi $t3, $t4, 7044
addi $t3, $t4, 7048
addi $t3, $t4, 7052
addi $t3, $t4, 7056
addi $t3, $t4, 7060
addi $t3, $t4, 7064
addi $t3, $t4, 7068
addi $t3, $t4, 7072
addi $t3, $t4, 7076
addi $t3, $t4, 7080
addi $t3, $t4, 7084
addi $t3, $t4, 7088
addi $t3, $t4, 7092
addi $t3, $t4, 7096
addi $t3, $t4, 7100
addi $t3, $t4, 7104
addi $t3, $t4, 7108
addi $t3, $t4, 7112
addi $t3, $t4, 7116
addi $t3, $t4, 7120
addi $t3, $t4, 7124
addi $t3, $t4, 7128
addi $t3, $t4, 7132
addi $t3, $t4, 7136
addi $t3, $t4, 7140
addi $t3, $t4, 7144
addi $t3, $t4, 7148
addi $t3, $t4, 7152
addi $t3, $t4, 7156
li $t5, 0x030303
sw $t5, 0($t3)
addi $t3, $t4, 7160
addi $t3, $t4, 7164
li $t5, 0x636363
sw $t5, 0($t3)
syscall      # sleeps for 30 ms
addi $t3, $t4, 7168
li $t5, 0x727272
sw $t5, 0($t3)
addi $t3, $t4, 7172
addi $t3, $t4, 7176
li $t5, 0x030303
sw $t5, 0($t3)
addi $t3, $t4, 7180
addi $t3, $t4, 7184
addi $t3, $t4, 7188
addi $t3, $t4, 7192
addi $t3, $t4, 7196
addi $t3, $t4, 7200
addi $t3, $t4, 7204
addi $t3, $t4, 7208
addi $t3, $t4, 7212
addi $t3, $t4, 7216
addi $t3, $t4, 7220
addi $t3, $t4, 7224
addi $t3, $t4, 7228
li $t5, 0x000001
sw $t5, 0($t3)
addi $t3, $t4, 7232
addi $t3, $t4, 7236
addi $t3, $t4, 7240
li $t5, 0x001c26
sw $t5, 0($t3)
addi $t3, $t4, 7244
li $t5, 0x002633
sw $t5, 0($t3)
addi $t3, $t4, 7248
li $t5, 0x00090c
sw $t5, 0($t3)
addi $t3, $t4, 7252
addi $t3, $t4, 7256
li $t5, 0x000101
sw $t5, 0($t3)
addi $t3, $t4, 7260
addi $t3, $t4, 7264
addi $t3, $t4, 7268
addi $t3, $t4, 7272
li $t5, 0x000203
sw $t5, 0($t3)
addi $t3, $t4, 7276
li $t5, 0x000608
sw $t5, 0($t3)
addi $t3, $t4, 7280
addi $t3, $t4, 7284
addi $t3, $t4, 7288
addi $t3, $t4, 7292
addi $t3, $t4, 7296
li $t5, 0x00090c
sw $t5, 0($t3)
addi $t3, $t4, 7300
li $t5, 0x000203
sw $t5, 0($t3)
addi $t3, $t4, 7304
li $t5, 0x000001
sw $t5, 0($t3)
addi $t3, $t4, 7308
addi $t3, $t4, 7312
addi $t3, $t4, 7316
addi $t3, $t4, 7320
sw $t5, 0($t3)
addi $t3, $t4, 7324
li $t5, 0x000303
sw $t5, 0($t3)
addi $t3, $t4, 7328
li $t5, 0x00080b
sw $t5, 0($t3)
addi $t3, $t4, 7332
addi $t3, $t4, 7336
li $t5, 0x000101
sw $t5, 0($t3)
addi $t3, $t4, 7340
li $t5, 0x000d12
sw $t5, 0($t3)
addi $t3, $t4, 7344
li $t5, 0x00141c
sw $t5, 0($t3)
addi $t3, $t4, 7348
li $t5, 0x00141b
sw $t5, 0($t3)
addi $t3, $t4, 7352
li $t5, 0x00151d
sw $t5, 0($t3)
addi $t3, $t4, 7356
li $t5, 0x00070a
sw $t5, 0($t3)
addi $t3, $t4, 7360
addi $t3, $t4, 7364
addi $t3, $t4, 7368
addi $t3, $t4, 7372
addi $t3, $t4, 7376
addi $t3, $t4, 7380
addi $t3, $t4, 7384
addi $t3, $t4, 7388
addi $t3, $t4, 7392
addi $t3, $t4, 7396
addi $t3, $t4, 7400
addi $t3, $t4, 7404
addi $t3, $t4, 7408
addi $t3, $t4, 7412
li $t5, 0x030303
sw $t5, 0($t3)
addi $t3, $t4, 7416
addi $t3, $t4, 7420
li $t5, 0x636363
sw $t5, 0($t3)
syscall      # sleeps for 30 ms
addi $t3, $t4, 7424
li $t5, 0x727272
sw $t5, 0($t3)
addi $t3, $t4, 7428
addi $t3, $t4, 7432
li $t5, 0x030303
sw $t5, 0($t3)
addi $t3, $t4, 7436
addi $t3, $t4, 7440
addi $t3, $t4, 7444
addi $t3, $t4, 7448
addi $t3, $t4, 7452
addi $t3, $t4, 7456
addi $t3, $t4, 7460
addi $t3, $t4, 7464
addi $t3, $t4, 7468
addi $t3, $t4, 7472
addi $t3, $t4, 7476
addi $t3, $t4, 7480
li $t5, 0x000101
sw $t5, 0($t3)
addi $t3, $t4, 7484
sw $t5, 0($t3)
addi $t3, $t4, 7488
li $t5, 0x001117
sw $t5, 0($t3)
addi $t3, $t4, 7492
li $t5, 0x017daa
sw $t5, 0($t3)
addi $t3, $t4, 7496
li $t5, 0x017ba8
sw $t5, 0($t3)
addi $t3, $t4, 7500
li $t5, 0x01719a
sw $t5, 0($t3)
addi $t3, $t4, 7504
li $t5, 0x018abc
sw $t5, 0($t3)
addi $t3, $t4, 7508
li $t5, 0x01465f
sw $t5, 0($t3)
addi $t3, $t4, 7512
addi $t3, $t4, 7516
li $t5, 0x000102
sw $t5, 0($t3)
addi $t3, $t4, 7520
li $t5, 0x000304
sw $t5, 0($t3)
addi $t3, $t4, 7524
addi $t3, $t4, 7528
li $t5, 0x01516e
sw $t5, 0($t3)
addi $t3, $t4, 7532
li $t5, 0x0190c5
sw $t5, 0($t3)
addi $t3, $t4, 7536
li $t5, 0x000101
sw $t5, 0($t3)
addi $t3, $t4, 7540
sw $t5, 0($t3)
addi $t3, $t4, 7544
li $t5, 0x000102
sw $t5, 0($t3)
addi $t3, $t4, 7548
addi $t3, $t4, 7552
li $t5, 0x0086b7
sw $t5, 0($t3)
addi $t3, $t4, 7556
li $t5, 0x01668b
sw $t5, 0($t3)
addi $t3, $t4, 7560
addi $t3, $t4, 7564
li $t5, 0x000203
sw $t5, 0($t3)
addi $t3, $t4, 7568
addi $t3, $t4, 7572
sw $t5, 0($t3)
addi $t3, $t4, 7576
addi $t3, $t4, 7580
li $t5, 0x016f97
sw $t5, 0($t3)
addi $t3, $t4, 7584
li $t5, 0x007dab
sw $t5, 0($t3)
addi $t3, $t4, 7588
addi $t3, $t4, 7592
li $t5, 0x00171e
sw $t5, 0($t3)
addi $t3, $t4, 7596
li $t5, 0x0092c6
sw $t5, 0($t3)
addi $t3, $t4, 7600
li $t5, 0x0175a0
sw $t5, 0($t3)
addi $t3, $t4, 7604
li $t5, 0x01739c
sw $t5, 0($t3)
addi $t3, $t4, 7608
li $t5, 0x017ca8
sw $t5, 0($t3)
addi $t3, $t4, 7612
li $t5, 0x012a39
sw $t5, 0($t3)
addi $t3, $t4, 7616
addi $t3, $t4, 7620
li $t5, 0x000203
sw $t5, 0($t3)
addi $t3, $t4, 7624
addi $t3, $t4, 7628
addi $t3, $t4, 7632
addi $t3, $t4, 7636
addi $t3, $t4, 7640
addi $t3, $t4, 7644
addi $t3, $t4, 7648
addi $t3, $t4, 7652
addi $t3, $t4, 7656
addi $t3, $t4, 7660
addi $t3, $t4, 7664
addi $t3, $t4, 7668
li $t5, 0x030303
sw $t5, 0($t3)
addi $t3, $t4, 7672
addi $t3, $t4, 7676
li $t5, 0x636363
sw $t5, 0($t3)
syscall      # sleeps for 30 ms
addi $t3, $t4, 7680
li $t5, 0x727272
sw $t5, 0($t3)
addi $t3, $t4, 7684
addi $t3, $t4, 7688
li $t5, 0x030303
sw $t5, 0($t3)
addi $t3, $t4, 7692
addi $t3, $t4, 7696
addi $t3, $t4, 7700
addi $t3, $t4, 7704
addi $t3, $t4, 7708
addi $t3, $t4, 7712
addi $t3, $t4, 7716
addi $t3, $t4, 7720
addi $t3, $t4, 7724
addi $t3, $t4, 7728
addi $t3, $t4, 7732
addi $t3, $t4, 7736
li $t5, 0x000202
sw $t5, 0($t3)
addi $t3, $t4, 7740
li $t5, 0x000101
sw $t5, 0($t3)
addi $t3, $t4, 7744
li $t5, 0x0180ae
sw $t5, 0($t3)
addi $t3, $t4, 7748
li $t5, 0x014a65
sw $t5, 0($t3)
addi $t3, $t4, 7752
addi $t3, $t4, 7756
addi $t3, $t4, 7760
li $t5, 0x00131a
sw $t5, 0($t3)
addi $t3, $t4, 7764
li $t5, 0x018ec2
sw $t5, 0($t3)
addi $t3, $t4, 7768
li $t5, 0x00222e
sw $t5, 0($t3)
addi $t3, $t4, 7772
addi $t3, $t4, 7776
li $t5, 0x000102
sw $t5, 0($t3)
addi $t3, $t4, 7780
li $t5, 0x000507
sw $t5, 0($t3)
addi $t3, $t4, 7784
li $t5, 0x017099
sw $t5, 0($t3)
addi $t3, $t4, 7788
li $t5, 0x017ca9
sw $t5, 0($t3)
addi $t3, $t4, 7792
li $t5, 0x002f40
sw $t5, 0($t3)
addi $t3, $t4, 7796
addi $t3, $t4, 7800
li $t5, 0x000304
sw $t5, 0($t3)
addi $t3, $t4, 7804
addi $t3, $t4, 7808
li $t5, 0x017dab
sw $t5, 0($t3)
addi $t3, $t4, 7812
li $t5, 0x0194ca
sw $t5, 0($t3)
addi $t3, $t4, 7816
li $t5, 0x000b0e
sw $t5, 0($t3)
addi $t3, $t4, 7820
addi $t3, $t4, 7824
li $t5, 0x000102
sw $t5, 0($t3)
addi $t3, $t4, 7828
addi $t3, $t4, 7832
li $t5, 0x000d12
sw $t5, 0($t3)
addi $t3, $t4, 7836
li $t5, 0x0198cf
sw $t5, 0($t3)
addi $t3, $t4, 7840
li $t5, 0x0076a1
sw $t5, 0($t3)
addi $t3, $t4, 7844
addi $t3, $t4, 7848
li $t5, 0x00202b
sw $t5, 0($t3)
addi $t3, $t4, 7852
li $t5, 0x007dab
sw $t5, 0($t3)
addi $t3, $t4, 7856
addi $t3, $t4, 7860
addi $t3, $t4, 7864
addi $t3, $t4, 7868
addi $t3, $t4, 7872
addi $t3, $t4, 7876
addi $t3, $t4, 7880
addi $t3, $t4, 7884
addi $t3, $t4, 7888
addi $t3, $t4, 7892
addi $t3, $t4, 7896
addi $t3, $t4, 7900
addi $t3, $t4, 7904
addi $t3, $t4, 7908
addi $t3, $t4, 7912
addi $t3, $t4, 7916
addi $t3, $t4, 7920
addi $t3, $t4, 7924
li $t5, 0x030303
sw $t5, 0($t3)
addi $t3, $t4, 7928
addi $t3, $t4, 7932
li $t5, 0x636363
sw $t5, 0($t3)
syscall      # sleeps for 30 ms
addi $t3, $t4, 7936
li $t5, 0x727272
sw $t5, 0($t3)
addi $t3, $t4, 7940
addi $t3, $t4, 7944
li $t5, 0x030303
sw $t5, 0($t3)
addi $t3, $t4, 7948
addi $t3, $t4, 7952
addi $t3, $t4, 7956
addi $t3, $t4, 7960
addi $t3, $t4, 7964
addi $t3, $t4, 7968
addi $t3, $t4, 7972
addi $t3, $t4, 7976
addi $t3, $t4, 7980
addi $t3, $t4, 7984
addi $t3, $t4, 7988
li $t5, 0x000202
sw $t5, 0($t3)
addi $t3, $t4, 7992
addi $t3, $t4, 7996
li $t5, 0x002938
sw $t5, 0($t3)
addi $t3, $t4, 8000
li $t5, 0x0180ae
sw $t5, 0($t3)
addi $t3, $t4, 8004
addi $t3, $t4, 8008
li $t5, 0x000203
sw $t5, 0($t3)
addi $t3, $t4, 8012
li $t5, 0x000406
sw $t5, 0($t3)
addi $t3, $t4, 8016
addi $t3, $t4, 8020
li $t5, 0x000c10
sw $t5, 0($t3)
addi $t3, $t4, 8024
li $t5, 0x000a0e
sw $t5, 0($t3)
addi $t3, $t4, 8028
li $t5, 0x000202
sw $t5, 0($t3)
addi $t3, $t4, 8032
addi $t3, $t4, 8036
li $t5, 0x003042
sw $t5, 0($t3)
addi $t3, $t4, 8040
li $t5, 0x016387
sw $t5, 0($t3)
addi $t3, $t4, 8044
li $t5, 0x002634
sw $t5, 0($t3)
addi $t3, $t4, 8048
li $t5, 0x016d94
sw $t5, 0($t3)
addi $t3, $t4, 8052
addi $t3, $t4, 8056
li $t5, 0x000304
sw $t5, 0($t3)
addi $t3, $t4, 8060
addi $t3, $t4, 8064
li $t5, 0x01698f
sw $t5, 0($t3)
addi $t3, $t4, 8068
li $t5, 0x01719a
sw $t5, 0($t3)
addi $t3, $t4, 8072
li $t5, 0x00435b
sw $t5, 0($t3)
addi $t3, $t4, 8076
addi $t3, $t4, 8080
li $t5, 0x000507
sw $t5, 0($t3)
addi $t3, $t4, 8084
addi $t3, $t4, 8088
li $t5, 0x00455e
sw $t5, 0($t3)
addi $t3, $t4, 8092
li $t5, 0x016f98
sw $t5, 0($t3)
addi $t3, $t4, 8096
li $t5, 0x00678c
sw $t5, 0($t3)
addi $t3, $t4, 8100
addi $t3, $t4, 8104
li $t5, 0x001f2a
sw $t5, 0($t3)
addi $t3, $t4, 8108
li $t5, 0x007ba8
sw $t5, 0($t3)
addi $t3, $t4, 8112
addi $t3, $t4, 8116
addi $t3, $t4, 8120
addi $t3, $t4, 8124
addi $t3, $t4, 8128
addi $t3, $t4, 8132
addi $t3, $t4, 8136
addi $t3, $t4, 8140
addi $t3, $t4, 8144
addi $t3, $t4, 8148
addi $t3, $t4, 8152
addi $t3, $t4, 8156
addi $t3, $t4, 8160
addi $t3, $t4, 8164
addi $t3, $t4, 8168
addi $t3, $t4, 8172
addi $t3, $t4, 8176
addi $t3, $t4, 8180
li $t5, 0x030303
sw $t5, 0($t3)
addi $t3, $t4, 8184
addi $t3, $t4, 8188
li $t5, 0x636363
sw $t5, 0($t3)
syscall      # sleeps for 30 ms
addi $t3, $t4, 8192
li $t5, 0x727272
sw $t5, 0($t3)
addi $t3, $t4, 8196
addi $t3, $t4, 8200
li $t5, 0x030303
sw $t5, 0($t3)
addi $t3, $t4, 8204
addi $t3, $t4, 8208
addi $t3, $t4, 8212
addi $t3, $t4, 8216
addi $t3, $t4, 8220
addi $t3, $t4, 8224
addi $t3, $t4, 8228
addi $t3, $t4, 8232
addi $t3, $t4, 8236
addi $t3, $t4, 8240
addi $t3, $t4, 8244
li $t5, 0x000304
sw $t5, 0($t3)
addi $t3, $t4, 8248
addi $t3, $t4, 8252
li $t5, 0x014e6a
sw $t5, 0($t3)
addi $t3, $t4, 8256
li $t5, 0x015d7e
sw $t5, 0($t3)
addi $t3, $t4, 8260
li $t5, 0x000102
sw $t5, 0($t3)
addi $t3, $t4, 8264
li $t5, 0x000405
sw $t5, 0($t3)
addi $t3, $t4, 8268
addi $t3, $t4, 8272
addi $t3, $t4, 8276
addi $t3, $t4, 8280
addi $t3, $t4, 8284
li $t5, 0x000304
sw $t5, 0($t3)
addi $t3, $t4, 8288
addi $t3, $t4, 8292
li $t5, 0x01698f
sw $t5, 0($t3)
addi $t3, $t4, 8296
li $t5, 0x003d53
sw $t5, 0($t3)
addi $t3, $t4, 8300
li $t5, 0x000203
sw $t5, 0($t3)
addi $t3, $t4, 8304
li $t5, 0x0184b4
sw $t5, 0($t3)
addi $t3, $t4, 8308
li $t5, 0x000c10
sw $t5, 0($t3)
addi $t3, $t4, 8312
addi $t3, $t4, 8316
addi $t3, $t4, 8320
li $t5, 0x01729b
sw $t5, 0($t3)
addi $t3, $t4, 8324
li $t5, 0x013447
sw $t5, 0($t3)
addi $t3, $t4, 8328
li $t5, 0x01759f
sw $t5, 0($t3)
addi $t3, $t4, 8332
addi $t3, $t4, 8336
li $t5, 0x000203
sw $t5, 0($t3)
addi $t3, $t4, 8340
li $t5, 0x000101
sw $t5, 0($t3)
addi $t3, $t4, 8344
li $t5, 0x017099
sw $t5, 0($t3)
addi $t3, $t4, 8348
li $t5, 0x01364a
sw $t5, 0($t3)
addi $t3, $t4, 8352
li $t5, 0x00719a
sw $t5, 0($t3)
addi $t3, $t4, 8356
addi $t3, $t4, 8360
li $t5, 0x001f29
sw $t5, 0($t3)
addi $t3, $t4, 8364
li $t5, 0x007eac
sw $t5, 0($t3)
addi $t3, $t4, 8368
li $t5, 0x00070a
sw $t5, 0($t3)
addi $t3, $t4, 8372
li $t5, 0x00080b
sw $t5, 0($t3)
addi $t3, $t4, 8376
li $t5, 0x000709
sw $t5, 0($t3)
addi $t3, $t4, 8380
li $t5, 0x000001
sw $t5, 0($t3)
addi $t3, $t4, 8384
addi $t3, $t4, 8388
addi $t3, $t4, 8392
addi $t3, $t4, 8396
addi $t3, $t4, 8400
addi $t3, $t4, 8404
addi $t3, $t4, 8408
addi $t3, $t4, 8412
addi $t3, $t4, 8416
addi $t3, $t4, 8420
addi $t3, $t4, 8424
addi $t3, $t4, 8428
addi $t3, $t4, 8432
addi $t3, $t4, 8436
li $t5, 0x030303
sw $t5, 0($t3)
addi $t3, $t4, 8440
addi $t3, $t4, 8444
li $t5, 0x636363
sw $t5, 0($t3)
syscall      # sleeps for 30 ms
addi $t3, $t4, 8448
li $t5, 0x727272
sw $t5, 0($t3)
addi $t3, $t4, 8452
addi $t3, $t4, 8456
li $t5, 0x030303
sw $t5, 0($t3)
addi $t3, $t4, 8460
addi $t3, $t4, 8464
addi $t3, $t4, 8468
addi $t3, $t4, 8472
addi $t3, $t4, 8476
addi $t3, $t4, 8480
addi $t3, $t4, 8484
addi $t3, $t4, 8488
addi $t3, $t4, 8492
addi $t3, $t4, 8496
addi $t3, $t4, 8500
li $t5, 0x000304
sw $t5, 0($t3)
addi $t3, $t4, 8504
addi $t3, $t4, 8508
li $t5, 0x005777
sw $t5, 0($t3)
addi $t3, $t4, 8512
li $t5, 0x015371
sw $t5, 0($t3)
addi $t3, $t4, 8516
addi $t3, $t4, 8520
li $t5, 0x000203
sw $t5, 0($t3)
addi $t3, $t4, 8524
li $t5, 0x012430
sw $t5, 0($t3)
addi $t3, $t4, 8528
li $t5, 0x013d53
sw $t5, 0($t3)
addi $t3, $t4, 8532
li $t5, 0x01384d
sw $t5, 0($t3)
addi $t3, $t4, 8536
li $t5, 0x001219
sw $t5, 0($t3)
addi $t3, $t4, 8540
addi $t3, $t4, 8544
li $t5, 0x000a0e
sw $t5, 0($t3)
addi $t3, $t4, 8548
li $t5, 0x0178a4
sw $t5, 0($t3)
addi $t3, $t4, 8552
addi $t3, $t4, 8556
addi $t3, $t4, 8560
li $t5, 0x015777
sw $t5, 0($t3)
addi $t3, $t4, 8564
li $t5, 0x003f56
sw $t5, 0($t3)
addi $t3, $t4, 8568
li $t5, 0x000101
sw $t5, 0($t3)
addi $t3, $t4, 8572
addi $t3, $t4, 8576
li $t5, 0x017ba7
sw $t5, 0($t3)
addi $t3, $t4, 8580
li $t5, 0x000c11
sw $t5, 0($t3)
addi $t3, $t4, 8584
li $t5, 0x01739d
sw $t5, 0($t3)
addi $t3, $t4, 8588
li $t5, 0x002532
sw $t5, 0($t3)
addi $t3, $t4, 8592
li $t5, 0x000001
sw $t5, 0($t3)
addi $t3, $t4, 8596
li $t5, 0x002735
sw $t5, 0($t3)
addi $t3, $t4, 8600
li $t5, 0x01698f
sw $t5, 0($t3)
addi $t3, $t4, 8604
li $t5, 0x00141b
sw $t5, 0($t3)
addi $t3, $t4, 8608
li $t5, 0x0079a5
sw $t5, 0($t3)
addi $t3, $t4, 8612
addi $t3, $t4, 8616
li $t5, 0x001821
sw $t5, 0($t3)
addi $t3, $t4, 8620
li $t5, 0x009cd4
sw $t5, 0($t3)
addi $t3, $t4, 8624
li $t5, 0x0177a2
sw $t5, 0($t3)
addi $t3, $t4, 8628
li $t5, 0x0179a4
sw $t5, 0($t3)
addi $t3, $t4, 8632
li $t5, 0x016e95
sw $t5, 0($t3)
addi $t3, $t4, 8636
li $t5, 0x00070a
sw $t5, 0($t3)
addi $t3, $t4, 8640
addi $t3, $t4, 8644
li $t5, 0x000101
sw $t5, 0($t3)
addi $t3, $t4, 8648
addi $t3, $t4, 8652
addi $t3, $t4, 8656
addi $t3, $t4, 8660
addi $t3, $t4, 8664
addi $t3, $t4, 8668
addi $t3, $t4, 8672
addi $t3, $t4, 8676
addi $t3, $t4, 8680
addi $t3, $t4, 8684
addi $t3, $t4, 8688
addi $t3, $t4, 8692
li $t5, 0x030303
sw $t5, 0($t3)
addi $t3, $t4, 8696
addi $t3, $t4, 8700
li $t5, 0x636363
sw $t5, 0($t3)
syscall      # sleeps for 30 ms
addi $t3, $t4, 8704
li $t5, 0x727272
sw $t5, 0($t3)
addi $t3, $t4, 8708
addi $t3, $t4, 8712
li $t5, 0x030303
sw $t5, 0($t3)
addi $t3, $t4, 8716
addi $t3, $t4, 8720
addi $t3, $t4, 8724
addi $t3, $t4, 8728
addi $t3, $t4, 8732
addi $t3, $t4, 8736
addi $t3, $t4, 8740
addi $t3, $t4, 8744
addi $t3, $t4, 8748
addi $t3, $t4, 8752
addi $t3, $t4, 8756
li $t5, 0x000304
sw $t5, 0($t3)
addi $t3, $t4, 8760
addi $t3, $t4, 8764
li $t5, 0x01506d
sw $t5, 0($t3)
addi $t3, $t4, 8768
li $t5, 0x005b7c
sw $t5, 0($t3)
addi $t3, $t4, 8772
li $t5, 0x000102
sw $t5, 0($t3)
addi $t3, $t4, 8776
li $t5, 0x000202
sw $t5, 0($t3)
addi $t3, $t4, 8780
li $t5, 0x013a4f
sw $t5, 0($t3)
addi $t3, $t4, 8784
li $t5, 0x006083
sw $t5, 0($t3)
addi $t3, $t4, 8788
li $t5, 0x0088b9
sw $t5, 0($t3)
addi $t3, $t4, 8792
li $t5, 0x015371
sw $t5, 0($t3)
addi $t3, $t4, 8796
addi $t3, $t4, 8800
li $t5, 0x00394e
sw $t5, 0($t3)
addi $t3, $t4, 8804
li $t5, 0x0196cc
sw $t5, 0($t3)
addi $t3, $t4, 8808
li $t5, 0x014a66
sw $t5, 0($t3)
addi $t3, $t4, 8812
li $t5, 0x014c68
sw $t5, 0($t3)
addi $t3, $t4, 8816
li $t5, 0x01729b
sw $t5, 0($t3)
addi $t3, $t4, 8820
li $t5, 0x0178a4
sw $t5, 0($t3)
addi $t3, $t4, 8824
addi $t3, $t4, 8828
addi $t3, $t4, 8832
li $t5, 0x017ba8
sw $t5, 0($t3)
addi $t3, $t4, 8836
li $t5, 0x00080b
sw $t5, 0($t3)
addi $t3, $t4, 8840
li $t5, 0x003e55
sw $t5, 0($t3)
addi $t3, $t4, 8844
li $t5, 0x01658a
sw $t5, 0($t3)
addi $t3, $t4, 8848
addi $t3, $t4, 8852
li $t5, 0x016387
sw $t5, 0($t3)
addi $t3, $t4, 8856
li $t5, 0x003548
sw $t5, 0($t3)
addi $t3, $t4, 8860
li $t5, 0x001219
sw $t5, 0($t3)
addi $t3, $t4, 8864
li $t5, 0x0079a5
sw $t5, 0($t3)
addi $t3, $t4, 8868
addi $t3, $t4, 8872
li $t5, 0x001f2a
sw $t5, 0($t3)
addi $t3, $t4, 8876
li $t5, 0x007dab
sw $t5, 0($t3)
addi $t3, $t4, 8880
li $t5, 0x000507
sw $t5, 0($t3)
addi $t3, $t4, 8884
li $t5, 0x000608
sw $t5, 0($t3)
addi $t3, $t4, 8888
li $t5, 0x000506
sw $t5, 0($t3)
addi $t3, $t4, 8892
addi $t3, $t4, 8896
addi $t3, $t4, 8900
addi $t3, $t4, 8904
addi $t3, $t4, 8908
addi $t3, $t4, 8912
addi $t3, $t4, 8916
addi $t3, $t4, 8920
addi $t3, $t4, 8924
addi $t3, $t4, 8928
addi $t3, $t4, 8932
addi $t3, $t4, 8936
addi $t3, $t4, 8940
addi $t3, $t4, 8944
addi $t3, $t4, 8948
li $t5, 0x030303
sw $t5, 0($t3)
addi $t3, $t4, 8952
addi $t3, $t4, 8956
li $t5, 0x636363
sw $t5, 0($t3)
syscall      # sleeps for 30 ms
addi $t3, $t4, 8960
li $t5, 0x727272
sw $t5, 0($t3)
addi $t3, $t4, 8964
addi $t3, $t4, 8968
li $t5, 0x030303
sw $t5, 0($t3)
addi $t3, $t4, 8972
addi $t3, $t4, 8976
addi $t3, $t4, 8980
addi $t3, $t4, 8984
addi $t3, $t4, 8988
addi $t3, $t4, 8992
addi $t3, $t4, 8996
addi $t3, $t4, 9000
addi $t3, $t4, 9004
addi $t3, $t4, 9008
addi $t3, $t4, 9012
li $t5, 0x000202
sw $t5, 0($t3)
addi $t3, $t4, 9016
addi $t3, $t4, 9020
li $t5, 0x003041
sw $t5, 0($t3)
addi $t3, $t4, 9024
li $t5, 0x017ba8
sw $t5, 0($t3)
addi $t3, $t4, 9028
addi $t3, $t4, 9032
li $t5, 0x000506
sw $t5, 0($t3)
addi $t3, $t4, 9036
addi $t3, $t4, 9040
addi $t3, $t4, 9044
li $t5, 0x003b51
sw $t5, 0($t3)
addi $t3, $t4, 9048
li $t5, 0x015776
sw $t5, 0($t3)
addi $t3, $t4, 9052
addi $t3, $t4, 9056
li $t5, 0x01719a
sw $t5, 0($t3)
addi $t3, $t4, 9060
li $t5, 0x006386
sw $t5, 0($t3)
addi $t3, $t4, 9064
li $t5, 0x004863
sw $t5, 0($t3)
addi $t3, $t4, 9068
li $t5, 0x004a65
sw $t5, 0($t3)
addi $t3, $t4, 9072
li $t5, 0x004963
sw $t5, 0($t3)
addi $t3, $t4, 9076
li $t5, 0x018abd
sw $t5, 0($t3)
addi $t3, $t4, 9080
li $t5, 0x001219
sw $t5, 0($t3)
addi $t3, $t4, 9084
addi $t3, $t4, 9088
li $t5, 0x017aa7
sw $t5, 0($t3)
addi $t3, $t4, 9092
li $t5, 0x001319
sw $t5, 0($t3)
addi $t3, $t4, 9096
li $t5, 0x00080b
sw $t5, 0($t3)
addi $t3, $t4, 9100
li $t5, 0x0180af
sw $t5, 0($t3)
addi $t3, $t4, 9104
li $t5, 0x000e13
sw $t5, 0($t3)
addi $t3, $t4, 9108
li $t5, 0x017ba7
sw $t5, 0($t3)
addi $t3, $t4, 9112
li $t5, 0x000506
sw $t5, 0($t3)
addi $t3, $t4, 9116
li $t5, 0x001d27
sw $t5, 0($t3)
addi $t3, $t4, 9120
li $t5, 0x0077a2
sw $t5, 0($t3)
addi $t3, $t4, 9124
addi $t3, $t4, 9128
li $t5, 0x001f2a
sw $t5, 0($t3)
addi $t3, $t4, 9132
li $t5, 0x007ca9
sw $t5, 0($t3)
addi $t3, $t4, 9136
li $t5, 0x000102
sw $t5, 0($t3)
addi $t3, $t4, 9140
li $t5, 0x000203
sw $t5, 0($t3)
addi $t3, $t4, 9144
li $t5, 0x000202
sw $t5, 0($t3)
addi $t3, $t4, 9148
sw $t5, 0($t3)
addi $t3, $t4, 9152
addi $t3, $t4, 9156
addi $t3, $t4, 9160
addi $t3, $t4, 9164
addi $t3, $t4, 9168
addi $t3, $t4, 9172
addi $t3, $t4, 9176
addi $t3, $t4, 9180
addi $t3, $t4, 9184
addi $t3, $t4, 9188
addi $t3, $t4, 9192
addi $t3, $t4, 9196
addi $t3, $t4, 9200
addi $t3, $t4, 9204
li $t5, 0x030303
sw $t5, 0($t3)
addi $t3, $t4, 9208
addi $t3, $t4, 9212
li $t5, 0x636363
sw $t5, 0($t3)
syscall      # sleeps for 30 ms
addi $t3, $t4, 9216
li $t5, 0x727272
sw $t5, 0($t3)
addi $t3, $t4, 9220
addi $t3, $t4, 9224
li $t5, 0x030303
sw $t5, 0($t3)
addi $t3, $t4, 9228
addi $t3, $t4, 9232
addi $t3, $t4, 9236
addi $t3, $t4, 9240
addi $t3, $t4, 9244
addi $t3, $t4, 9248
addi $t3, $t4, 9252
addi $t3, $t4, 9256
addi $t3, $t4, 9260
addi $t3, $t4, 9264
addi $t3, $t4, 9268
addi $t3, $t4, 9272
li $t5, 0x000102
sw $t5, 0($t3)
addi $t3, $t4, 9276
li $t5, 0x000405
sw $t5, 0($t3)
addi $t3, $t4, 9280
li $t5, 0x018bbe
sw $t5, 0($t3)
addi $t3, $t4, 9284
li $t5, 0x003346
sw $t5, 0($t3)
addi $t3, $t4, 9288
addi $t3, $t4, 9292
addi $t3, $t4, 9296
addi $t3, $t4, 9300
li $t5, 0x016489
sw $t5, 0($t3)
addi $t3, $t4, 9304
li $t5, 0x014d6a
sw $t5, 0($t3)
addi $t3, $t4, 9308
li $t5, 0x000406
sw $t5, 0($t3)
addi $t3, $t4, 9312
li $t5, 0x018abc
sw $t5, 0($t3)
addi $t3, $t4, 9316
addi $t3, $t4, 9320
addi $t3, $t4, 9324
addi $t3, $t4, 9328
addi $t3, $t4, 9332
li $t5, 0x016083
sw $t5, 0($t3)
addi $t3, $t4, 9336
li $t5, 0x004d69
sw $t5, 0($t3)
addi $t3, $t4, 9340
addi $t3, $t4, 9344
li $t5, 0x017ba8
sw $t5, 0($t3)
addi $t3, $t4, 9348
li $t5, 0x001821
sw $t5, 0($t3)
addi $t3, $t4, 9352
addi $t3, $t4, 9356
li $t5, 0x015b7c
sw $t5, 0($t3)
addi $t3, $t4, 9360
li $t5, 0x01749e
sw $t5, 0($t3)
addi $t3, $t4, 9364
li $t5, 0x015776
sw $t5, 0($t3)
addi $t3, $t4, 9368
addi $t3, $t4, 9372
li $t5, 0x00222e
sw $t5, 0($t3)
addi $t3, $t4, 9376
li $t5, 0x0076a1
sw $t5, 0($t3)
addi $t3, $t4, 9380
addi $t3, $t4, 9384
li $t5, 0x00202b
sw $t5, 0($t3)
addi $t3, $t4, 9388
li $t5, 0x0077a3
sw $t5, 0($t3)
addi $t3, $t4, 9392
addi $t3, $t4, 9396
addi $t3, $t4, 9400
addi $t3, $t4, 9404
addi $t3, $t4, 9408
addi $t3, $t4, 9412
addi $t3, $t4, 9416
addi $t3, $t4, 9420
addi $t3, $t4, 9424
addi $t3, $t4, 9428
addi $t3, $t4, 9432
addi $t3, $t4, 9436
addi $t3, $t4, 9440
addi $t3, $t4, 9444
addi $t3, $t4, 9448
addi $t3, $t4, 9452
addi $t3, $t4, 9456
addi $t3, $t4, 9460
li $t5, 0x030303
sw $t5, 0($t3)
addi $t3, $t4, 9464
addi $t3, $t4, 9468
li $t5, 0x636363
sw $t5, 0($t3)
syscall      # sleeps for 30 ms
addi $t3, $t4, 9472
li $t5, 0x727272
sw $t5, 0($t3)
addi $t3, $t4, 9476
addi $t3, $t4, 9480
li $t5, 0x030303
sw $t5, 0($t3)
addi $t3, $t4, 9484
addi $t3, $t4, 9488
addi $t3, $t4, 9492
addi $t3, $t4, 9496
addi $t3, $t4, 9500
addi $t3, $t4, 9504
addi $t3, $t4, 9508
addi $t3, $t4, 9512
addi $t3, $t4, 9516
addi $t3, $t4, 9520
addi $t3, $t4, 9524
addi $t3, $t4, 9528
li $t5, 0x000102
sw $t5, 0($t3)
addi $t3, $t4, 9532
addi $t3, $t4, 9536
li $t5, 0x01212d
sw $t5, 0($t3)
addi $t3, $t4, 9540
li $t5, 0x0190c4
sw $t5, 0($t3)
addi $t3, $t4, 9544
li $t5, 0x01668c
sw $t5, 0($t3)
addi $t3, $t4, 9548
li $t5, 0x01516e
sw $t5, 0($t3)
addi $t3, $t4, 9552
li $t5, 0x01719a
sw $t5, 0($t3)
addi $t3, $t4, 9556
li $t5, 0x0178a4
sw $t5, 0($t3)
addi $t3, $t4, 9560
li $t5, 0x000a0e
sw $t5, 0($t3)
addi $t3, $t4, 9564
li $t5, 0x014c67
sw $t5, 0($t3)
addi $t3, $t4, 9568
li $t5, 0x01658a
sw $t5, 0($t3)
addi $t3, $t4, 9572
li $t5, 0x000101
sw $t5, 0($t3)
addi $t3, $t4, 9576
li $t5, 0x000507
sw $t5, 0($t3)
addi $t3, $t4, 9580
li $t5, 0x000405
sw $t5, 0($t3)
addi $t3, $t4, 9584
li $t5, 0x000304
sw $t5, 0($t3)
addi $t3, $t4, 9588
li $t5, 0x002533
sw $t5, 0($t3)
addi $t3, $t4, 9592
li $t5, 0x0182b2
sw $t5, 0($t3)
addi $t3, $t4, 9596
li $t5, 0x000101
sw $t5, 0($t3)
addi $t3, $t4, 9600
li $t5, 0x017eac
sw $t5, 0($t3)
addi $t3, $t4, 9604
li $t5, 0x001821
sw $t5, 0($t3)
addi $t3, $t4, 9608
li $t5, 0x000001
sw $t5, 0($t3)
addi $t3, $t4, 9612
li $t5, 0x00212d
sw $t5, 0($t3)
addi $t3, $t4, 9616
li $t5, 0x01b2f3
sw $t5, 0($t3)
addi $t3, $t4, 9620
li $t5, 0x001e29
sw $t5, 0($t3)
addi $t3, $t4, 9624
addi $t3, $t4, 9628
li $t5, 0x00212e
sw $t5, 0($t3)
addi $t3, $t4, 9632
li $t5, 0x007ba8
sw $t5, 0($t3)
addi $t3, $t4, 9636
addi $t3, $t4, 9640
li $t5, 0x001b24
sw $t5, 0($t3)
addi $t3, $t4, 9644
li $t5, 0x009ad1
sw $t5, 0($t3)
addi $t3, $t4, 9648
li $t5, 0x016082
sw $t5, 0($t3)
addi $t3, $t4, 9652
li $t5, 0x015e80
sw $t5, 0($t3)
addi $t3, $t4, 9656
li $t5, 0x016589
sw $t5, 0($t3)
addi $t3, $t4, 9660
li $t5, 0x013a4f
sw $t5, 0($t3)
addi $t3, $t4, 9664
addi $t3, $t4, 9668
li $t5, 0x000202
sw $t5, 0($t3)
addi $t3, $t4, 9672
addi $t3, $t4, 9676
addi $t3, $t4, 9680
addi $t3, $t4, 9684
addi $t3, $t4, 9688
addi $t3, $t4, 9692
addi $t3, $t4, 9696
addi $t3, $t4, 9700
addi $t3, $t4, 9704
addi $t3, $t4, 9708
addi $t3, $t4, 9712
addi $t3, $t4, 9716
li $t5, 0x030303
sw $t5, 0($t3)
addi $t3, $t4, 9720
addi $t3, $t4, 9724
li $t5, 0x636363
sw $t5, 0($t3)
syscall      # sleeps for 30 ms
addi $t3, $t4, 9728
li $t5, 0x727272
sw $t5, 0($t3)
addi $t3, $t4, 9732
addi $t3, $t4, 9736
li $t5, 0x030303
sw $t5, 0($t3)
addi $t3, $t4, 9740
addi $t3, $t4, 9744
addi $t3, $t4, 9748
addi $t3, $t4, 9752
addi $t3, $t4, 9756
addi $t3, $t4, 9760
addi $t3, $t4, 9764
addi $t3, $t4, 9768
addi $t3, $t4, 9772
addi $t3, $t4, 9776
addi $t3, $t4, 9780
addi $t3, $t4, 9784
addi $t3, $t4, 9788
li $t5, 0x000101
sw $t5, 0($t3)
addi $t3, $t4, 9792
addi $t3, $t4, 9796
li $t5, 0x00080b
sw $t5, 0($t3)
addi $t3, $t4, 9800
li $t5, 0x013f56
sw $t5, 0($t3)
addi $t3, $t4, 9804
li $t5, 0x014b65
sw $t5, 0($t3)
addi $t3, $t4, 9808
li $t5, 0x002f3f
sw $t5, 0($t3)
addi $t3, $t4, 9812
addi $t3, $t4, 9816
addi $t3, $t4, 9820
li $t5, 0x011d27
sw $t5, 0($t3)
addi $t3, $t4, 9824
li $t5, 0x000e13
sw $t5, 0($t3)
addi $t3, $t4, 9828
addi $t3, $t4, 9832
li $t5, 0x000101
sw $t5, 0($t3)
addi $t3, $t4, 9836
addi $t3, $t4, 9840
addi $t3, $t4, 9844
li $t5, 0x000001
sw $t5, 0($t3)
addi $t3, $t4, 9848
li $t5, 0x01212d
sw $t5, 0($t3)
addi $t3, $t4, 9852
li $t5, 0x000102
sw $t5, 0($t3)
addi $t3, $t4, 9856
li $t5, 0x011c26
sw $t5, 0($t3)
addi $t3, $t4, 9860
li $t5, 0x000507
sw $t5, 0($t3)
addi $t3, $t4, 9864
addi $t3, $t4, 9868
li $t5, 0x000102
sw $t5, 0($t3)
addi $t3, $t4, 9872
li $t5, 0x011f2a
sw $t5, 0($t3)
addi $t3, $t4, 9876
li $t5, 0x000101
sw $t5, 0($t3)
addi $t3, $t4, 9880
addi $t3, $t4, 9884
li $t5, 0x00070a
sw $t5, 0($t3)
addi $t3, $t4, 9888
li $t5, 0x001d27
sw $t5, 0($t3)
addi $t3, $t4, 9892
addi $t3, $t4, 9896
li $t5, 0x000406
sw $t5, 0($t3)
addi $t3, $t4, 9900
li $t5, 0x012c3d
sw $t5, 0($t3)
addi $t3, $t4, 9904
li $t5, 0x01384c
sw $t5, 0($t3)
addi $t3, $t4, 9908
li $t5, 0x01364a
sw $t5, 0($t3)
addi $t3, $t4, 9912
li $t5, 0x013b50
sw $t5, 0($t3)
addi $t3, $t4, 9916
li $t5, 0x01212e
sw $t5, 0($t3)
addi $t3, $t4, 9920
addi $t3, $t4, 9924
li $t5, 0x000101
sw $t5, 0($t3)
addi $t3, $t4, 9928
addi $t3, $t4, 9932
addi $t3, $t4, 9936
addi $t3, $t4, 9940
addi $t3, $t4, 9944
addi $t3, $t4, 9948
addi $t3, $t4, 9952
addi $t3, $t4, 9956
addi $t3, $t4, 9960
addi $t3, $t4, 9964
addi $t3, $t4, 9968
addi $t3, $t4, 9972
li $t5, 0x030303
sw $t5, 0($t3)
addi $t3, $t4, 9976
addi $t3, $t4, 9980
li $t5, 0x636363
sw $t5, 0($t3)
syscall      # sleeps for 30 ms
addi $t3, $t4, 9984
li $t5, 0x727272
sw $t5, 0($t3)
addi $t3, $t4, 9988
addi $t3, $t4, 9992
li $t5, 0x030303
sw $t5, 0($t3)
addi $t3, $t4, 9996
addi $t3, $t4, 10000
addi $t3, $t4, 10004
addi $t3, $t4, 10008
addi $t3, $t4, 10012
addi $t3, $t4, 10016
addi $t3, $t4, 10020
addi $t3, $t4, 10024
addi $t3, $t4, 10028
addi $t3, $t4, 10032
addi $t3, $t4, 10036
addi $t3, $t4, 10040
addi $t3, $t4, 10044
addi $t3, $t4, 10048
li $t5, 0x000102
sw $t5, 0($t3)
addi $t3, $t4, 10052
addi $t3, $t4, 10056
addi $t3, $t4, 10060
addi $t3, $t4, 10064
addi $t3, $t4, 10068
li $t5, 0x000001
sw $t5, 0($t3)
addi $t3, $t4, 10072
li $t5, 0x000101
sw $t5, 0($t3)
addi $t3, $t4, 10076
addi $t3, $t4, 10080
addi $t3, $t4, 10084
addi $t3, $t4, 10088
addi $t3, $t4, 10092
addi $t3, $t4, 10096
addi $t3, $t4, 10100
addi $t3, $t4, 10104
addi $t3, $t4, 10108
addi $t3, $t4, 10112
addi $t3, $t4, 10116
addi $t3, $t4, 10120
addi $t3, $t4, 10124
addi $t3, $t4, 10128
addi $t3, $t4, 10132
addi $t3, $t4, 10136
addi $t3, $t4, 10140
addi $t3, $t4, 10144
addi $t3, $t4, 10148
addi $t3, $t4, 10152
addi $t3, $t4, 10156
addi $t3, $t4, 10160
addi $t3, $t4, 10164
addi $t3, $t4, 10168
addi $t3, $t4, 10172
addi $t3, $t4, 10176
addi $t3, $t4, 10180
addi $t3, $t4, 10184
addi $t3, $t4, 10188
addi $t3, $t4, 10192
addi $t3, $t4, 10196
addi $t3, $t4, 10200
addi $t3, $t4, 10204
addi $t3, $t4, 10208
addi $t3, $t4, 10212
addi $t3, $t4, 10216
addi $t3, $t4, 10220
addi $t3, $t4, 10224
addi $t3, $t4, 10228
li $t5, 0x030303
sw $t5, 0($t3)
addi $t3, $t4, 10232
addi $t3, $t4, 10236
li $t5, 0x636363
sw $t5, 0($t3)
syscall      # sleeps for 30 ms
addi $t3, $t4, 10240
li $t5, 0x727272
sw $t5, 0($t3)
addi $t3, $t4, 10244
addi $t3, $t4, 10248
li $t5, 0x030303
sw $t5, 0($t3)
addi $t3, $t4, 10252
addi $t3, $t4, 10256
addi $t3, $t4, 10260
addi $t3, $t4, 10264
addi $t3, $t4, 10268
addi $t3, $t4, 10272
addi $t3, $t4, 10276
addi $t3, $t4, 10280
addi $t3, $t4, 10284
addi $t3, $t4, 10288
addi $t3, $t4, 10292
addi $t3, $t4, 10296
addi $t3, $t4, 10300
addi $t3, $t4, 10304
addi $t3, $t4, 10308
li $t5, 0x000101
sw $t5, 0($t3)
addi $t3, $t4, 10312
li $t5, 0x000203
sw $t5, 0($t3)
addi $t3, $t4, 10316
li $t5, 0x000304
sw $t5, 0($t3)
addi $t3, $t4, 10320
li $t5, 0x000202
sw $t5, 0($t3)
addi $t3, $t4, 10324
addi $t3, $t4, 10328
addi $t3, $t4, 10332
li $t5, 0x000102
sw $t5, 0($t3)
addi $t3, $t4, 10336
li $t5, 0x000101
sw $t5, 0($t3)
addi $t3, $t4, 10340
addi $t3, $t4, 10344
addi $t3, $t4, 10348
addi $t3, $t4, 10352
addi $t3, $t4, 10356
addi $t3, $t4, 10360
li $t5, 0x000202
sw $t5, 0($t3)
addi $t3, $t4, 10364
addi $t3, $t4, 10368
li $t5, 0x000102
sw $t5, 0($t3)
addi $t3, $t4, 10372
addi $t3, $t4, 10376
addi $t3, $t4, 10380
addi $t3, $t4, 10384
li $t5, 0x000202
sw $t5, 0($t3)
addi $t3, $t4, 10388
addi $t3, $t4, 10392
addi $t3, $t4, 10396
addi $t3, $t4, 10400
li $t5, 0x000102
sw $t5, 0($t3)
addi $t3, $t4, 10404
addi $t3, $t4, 10408
addi $t3, $t4, 10412
li $t5, 0x000203
sw $t5, 0($t3)
addi $t3, $t4, 10416
sw $t5, 0($t3)
addi $t3, $t4, 10420
sw $t5, 0($t3)
addi $t3, $t4, 10424
sw $t5, 0($t3)
addi $t3, $t4, 10428
li $t5, 0x000102
sw $t5, 0($t3)
addi $t3, $t4, 10432
addi $t3, $t4, 10436
addi $t3, $t4, 10440
addi $t3, $t4, 10444
addi $t3, $t4, 10448
addi $t3, $t4, 10452
addi $t3, $t4, 10456
addi $t3, $t4, 10460
addi $t3, $t4, 10464
addi $t3, $t4, 10468
addi $t3, $t4, 10472
addi $t3, $t4, 10476
addi $t3, $t4, 10480
addi $t3, $t4, 10484
li $t5, 0x030303
sw $t5, 0($t3)
addi $t3, $t4, 10488
addi $t3, $t4, 10492
li $t5, 0x636363
sw $t5, 0($t3)
syscall      # sleeps for 30 ms
addi $t3, $t4, 10496
li $t5, 0x727272
sw $t5, 0($t3)
addi $t3, $t4, 10500
addi $t3, $t4, 10504
li $t5, 0x030303
sw $t5, 0($t3)
addi $t3, $t4, 10508
addi $t3, $t4, 10512
addi $t3, $t4, 10516
addi $t3, $t4, 10520
addi $t3, $t4, 10524
addi $t3, $t4, 10528
addi $t3, $t4, 10532
addi $t3, $t4, 10536
addi $t3, $t4, 10540
addi $t3, $t4, 10544
addi $t3, $t4, 10548
addi $t3, $t4, 10552
addi $t3, $t4, 10556
addi $t3, $t4, 10560
addi $t3, $t4, 10564
addi $t3, $t4, 10568
addi $t3, $t4, 10572
addi $t3, $t4, 10576
addi $t3, $t4, 10580
addi $t3, $t4, 10584
addi $t3, $t4, 10588
addi $t3, $t4, 10592
addi $t3, $t4, 10596
addi $t3, $t4, 10600
addi $t3, $t4, 10604
addi $t3, $t4, 10608
addi $t3, $t4, 10612
addi $t3, $t4, 10616
addi $t3, $t4, 10620
addi $t3, $t4, 10624
addi $t3, $t4, 10628
addi $t3, $t4, 10632
addi $t3, $t4, 10636
addi $t3, $t4, 10640
addi $t3, $t4, 10644
addi $t3, $t4, 10648
addi $t3, $t4, 10652
addi $t3, $t4, 10656
addi $t3, $t4, 10660
addi $t3, $t4, 10664
addi $t3, $t4, 10668
addi $t3, $t4, 10672
addi $t3, $t4, 10676
addi $t3, $t4, 10680
addi $t3, $t4, 10684
addi $t3, $t4, 10688
addi $t3, $t4, 10692
addi $t3, $t4, 10696
addi $t3, $t4, 10700
addi $t3, $t4, 10704
addi $t3, $t4, 10708
addi $t3, $t4, 10712
addi $t3, $t4, 10716
addi $t3, $t4, 10720
addi $t3, $t4, 10724
addi $t3, $t4, 10728
addi $t3, $t4, 10732
addi $t3, $t4, 10736
addi $t3, $t4, 10740
sw $t5, 0($t3)
addi $t3, $t4, 10744
addi $t3, $t4, 10748
li $t5, 0x636363
sw $t5, 0($t3)
syscall      # sleeps for 30 ms
addi $t3, $t4, 10752
li $t5, 0x727272
sw $t5, 0($t3)
addi $t3, $t4, 10756
addi $t3, $t4, 10760
li $t5, 0x030303
sw $t5, 0($t3)
addi $t3, $t4, 10764
addi $t3, $t4, 10768
addi $t3, $t4, 10772
addi $t3, $t4, 10776
addi $t3, $t4, 10780
addi $t3, $t4, 10784
addi $t3, $t4, 10788
addi $t3, $t4, 10792
addi $t3, $t4, 10796
addi $t3, $t4, 10800
addi $t3, $t4, 10804
addi $t3, $t4, 10808
addi $t3, $t4, 10812
addi $t3, $t4, 10816
addi $t3, $t4, 10820
addi $t3, $t4, 10824
addi $t3, $t4, 10828
addi $t3, $t4, 10832
addi $t3, $t4, 10836
addi $t3, $t4, 10840
addi $t3, $t4, 10844
addi $t3, $t4, 10848
addi $t3, $t4, 10852
addi $t3, $t4, 10856
addi $t3, $t4, 10860
addi $t3, $t4, 10864
addi $t3, $t4, 10868
addi $t3, $t4, 10872
addi $t3, $t4, 10876
addi $t3, $t4, 10880
addi $t3, $t4, 10884
addi $t3, $t4, 10888
addi $t3, $t4, 10892
addi $t3, $t4, 10896
addi $t3, $t4, 10900
addi $t3, $t4, 10904
addi $t3, $t4, 10908
addi $t3, $t4, 10912
addi $t3, $t4, 10916
addi $t3, $t4, 10920
addi $t3, $t4, 10924
addi $t3, $t4, 10928
addi $t3, $t4, 10932
addi $t3, $t4, 10936
addi $t3, $t4, 10940
addi $t3, $t4, 10944
addi $t3, $t4, 10948
addi $t3, $t4, 10952
addi $t3, $t4, 10956
addi $t3, $t4, 10960
addi $t3, $t4, 10964
addi $t3, $t4, 10968
addi $t3, $t4, 10972
addi $t3, $t4, 10976
addi $t3, $t4, 10980
addi $t3, $t4, 10984
addi $t3, $t4, 10988
addi $t3, $t4, 10992
addi $t3, $t4, 10996
sw $t5, 0($t3)
addi $t3, $t4, 11000
addi $t3, $t4, 11004
li $t5, 0x636363
sw $t5, 0($t3)
syscall      # sleeps for 30 ms
addi $t3, $t4, 11008
li $t5, 0x727272
sw $t5, 0($t3)
addi $t3, $t4, 11012
addi $t3, $t4, 11016
li $t5, 0x030303
sw $t5, 0($t3)
addi $t3, $t4, 11020
addi $t3, $t4, 11024
addi $t3, $t4, 11028
addi $t3, $t4, 11032
addi $t3, $t4, 11036
addi $t3, $t4, 11040
addi $t3, $t4, 11044
addi $t3, $t4, 11048
addi $t3, $t4, 11052
addi $t3, $t4, 11056
addi $t3, $t4, 11060
addi $t3, $t4, 11064
addi $t3, $t4, 11068
addi $t3, $t4, 11072
addi $t3, $t4, 11076
addi $t3, $t4, 11080
addi $t3, $t4, 11084
addi $t3, $t4, 11088
addi $t3, $t4, 11092
addi $t3, $t4, 11096
addi $t3, $t4, 11100
addi $t3, $t4, 11104
addi $t3, $t4, 11108
addi $t3, $t4, 11112
addi $t3, $t4, 11116
addi $t3, $t4, 11120
addi $t3, $t4, 11124
addi $t3, $t4, 11128
addi $t3, $t4, 11132
addi $t3, $t4, 11136
addi $t3, $t4, 11140
addi $t3, $t4, 11144
addi $t3, $t4, 11148
addi $t3, $t4, 11152
addi $t3, $t4, 11156
addi $t3, $t4, 11160
addi $t3, $t4, 11164
addi $t3, $t4, 11168
addi $t3, $t4, 11172
addi $t3, $t4, 11176
addi $t3, $t4, 11180
addi $t3, $t4, 11184
addi $t3, $t4, 11188
addi $t3, $t4, 11192
addi $t3, $t4, 11196
addi $t3, $t4, 11200
addi $t3, $t4, 11204
addi $t3, $t4, 11208
addi $t3, $t4, 11212
addi $t3, $t4, 11216
addi $t3, $t4, 11220
addi $t3, $t4, 11224
addi $t3, $t4, 11228
addi $t3, $t4, 11232
addi $t3, $t4, 11236
addi $t3, $t4, 11240
addi $t3, $t4, 11244
addi $t3, $t4, 11248
addi $t3, $t4, 11252
sw $t5, 0($t3)
addi $t3, $t4, 11256
addi $t3, $t4, 11260
li $t5, 0x636363
sw $t5, 0($t3)
syscall      # sleeps for 30 ms
addi $t3, $t4, 11264
li $t5, 0x727272
sw $t5, 0($t3)
addi $t3, $t4, 11268
addi $t3, $t4, 11272
li $t5, 0x030303
sw $t5, 0($t3)
addi $t3, $t4, 11276
addi $t3, $t4, 11280
addi $t3, $t4, 11284
addi $t3, $t4, 11288
addi $t3, $t4, 11292
addi $t3, $t4, 11296
addi $t3, $t4, 11300
addi $t3, $t4, 11304
addi $t3, $t4, 11308
addi $t3, $t4, 11312
addi $t3, $t4, 11316
addi $t3, $t4, 11320
addi $t3, $t4, 11324
addi $t3, $t4, 11328
addi $t3, $t4, 11332
addi $t3, $t4, 11336
addi $t3, $t4, 11340
addi $t3, $t4, 11344
addi $t3, $t4, 11348
addi $t3, $t4, 11352
addi $t3, $t4, 11356
addi $t3, $t4, 11360
addi $t3, $t4, 11364
addi $t3, $t4, 11368
addi $t3, $t4, 11372
addi $t3, $t4, 11376
addi $t3, $t4, 11380
addi $t3, $t4, 11384
addi $t3, $t4, 11388
addi $t3, $t4, 11392
addi $t3, $t4, 11396
addi $t3, $t4, 11400
addi $t3, $t4, 11404
addi $t3, $t4, 11408
addi $t3, $t4, 11412
addi $t3, $t4, 11416
addi $t3, $t4, 11420
addi $t3, $t4, 11424
addi $t3, $t4, 11428
addi $t3, $t4, 11432
addi $t3, $t4, 11436
addi $t3, $t4, 11440
addi $t3, $t4, 11444
addi $t3, $t4, 11448
addi $t3, $t4, 11452
addi $t3, $t4, 11456
addi $t3, $t4, 11460
addi $t3, $t4, 11464
addi $t3, $t4, 11468
addi $t3, $t4, 11472
addi $t3, $t4, 11476
addi $t3, $t4, 11480
addi $t3, $t4, 11484
addi $t3, $t4, 11488
addi $t3, $t4, 11492
addi $t3, $t4, 11496
addi $t3, $t4, 11500
addi $t3, $t4, 11504
addi $t3, $t4, 11508
sw $t5, 0($t3)
addi $t3, $t4, 11512
addi $t3, $t4, 11516
li $t5, 0x636363
sw $t5, 0($t3)
syscall      # sleeps for 30 ms
addi $t3, $t4, 11520
li $t5, 0x727272
sw $t5, 0($t3)
addi $t3, $t4, 11524
addi $t3, $t4, 11528
li $t5, 0x030303
sw $t5, 0($t3)
addi $t3, $t4, 11532
addi $t3, $t4, 11536
addi $t3, $t4, 11540
addi $t3, $t4, 11544
addi $t3, $t4, 11548
addi $t3, $t4, 11552
addi $t3, $t4, 11556
addi $t3, $t4, 11560
addi $t3, $t4, 11564
addi $t3, $t4, 11568
addi $t3, $t4, 11572
addi $t3, $t4, 11576
addi $t3, $t4, 11580
addi $t3, $t4, 11584
addi $t3, $t4, 11588
addi $t3, $t4, 11592
addi $t3, $t4, 11596
addi $t3, $t4, 11600
addi $t3, $t4, 11604
addi $t3, $t4, 11608
addi $t3, $t4, 11612
addi $t3, $t4, 11616
addi $t3, $t4, 11620
addi $t3, $t4, 11624
addi $t3, $t4, 11628
addi $t3, $t4, 11632
addi $t3, $t4, 11636
addi $t3, $t4, 11640
addi $t3, $t4, 11644
addi $t3, $t4, 11648
addi $t3, $t4, 11652
addi $t3, $t4, 11656
addi $t3, $t4, 11660
addi $t3, $t4, 11664
addi $t3, $t4, 11668
addi $t3, $t4, 11672
addi $t3, $t4, 11676
addi $t3, $t4, 11680
addi $t3, $t4, 11684
addi $t3, $t4, 11688
addi $t3, $t4, 11692
addi $t3, $t4, 11696
addi $t3, $t4, 11700
addi $t3, $t4, 11704
addi $t3, $t4, 11708
addi $t3, $t4, 11712
addi $t3, $t4, 11716
addi $t3, $t4, 11720
addi $t3, $t4, 11724
addi $t3, $t4, 11728
addi $t3, $t4, 11732
addi $t3, $t4, 11736
addi $t3, $t4, 11740
addi $t3, $t4, 11744
addi $t3, $t4, 11748
addi $t3, $t4, 11752
addi $t3, $t4, 11756
addi $t3, $t4, 11760
addi $t3, $t4, 11764
sw $t5, 0($t3)
addi $t3, $t4, 11768
addi $t3, $t4, 11772
li $t5, 0x636363
sw $t5, 0($t3)
syscall      # sleeps for 30 ms
addi $t3, $t4, 11776
li $t5, 0x727272
sw $t5, 0($t3)
addi $t3, $t4, 11780
addi $t3, $t4, 11784
li $t5, 0x030303
sw $t5, 0($t3)
addi $t3, $t4, 11788
addi $t3, $t4, 11792
addi $t3, $t4, 11796
addi $t3, $t4, 11800
addi $t3, $t4, 11804
addi $t3, $t4, 11808
addi $t3, $t4, 11812
addi $t3, $t4, 11816
addi $t3, $t4, 11820
addi $t3, $t4, 11824
addi $t3, $t4, 11828
addi $t3, $t4, 11832
addi $t3, $t4, 11836
addi $t3, $t4, 11840
addi $t3, $t4, 11844
addi $t3, $t4, 11848
li $t5, 0x010100
sw $t5, 0($t3)
addi $t3, $t4, 11852
addi $t3, $t4, 11856
li $t5, 0x000100
sw $t5, 0($t3)
addi $t3, $t4, 11860
sw $t5, 0($t3)
addi $t3, $t4, 11864
addi $t3, $t4, 11868
addi $t3, $t4, 11872
addi $t3, $t4, 11876
addi $t3, $t4, 11880
addi $t3, $t4, 11884
addi $t3, $t4, 11888
addi $t3, $t4, 11892
addi $t3, $t4, 11896
addi $t3, $t4, 11900
addi $t3, $t4, 11904
addi $t3, $t4, 11908
addi $t3, $t4, 11912
addi $t3, $t4, 11916
addi $t3, $t4, 11920
addi $t3, $t4, 11924
addi $t3, $t4, 11928
addi $t3, $t4, 11932
addi $t3, $t4, 11936
li $t5, 0x010000
sw $t5, 0($t3)
addi $t3, $t4, 11940
addi $t3, $t4, 11944
addi $t3, $t4, 11948
sw $t5, 0($t3)
addi $t3, $t4, 11952
addi $t3, $t4, 11956
addi $t3, $t4, 11960
addi $t3, $t4, 11964
addi $t3, $t4, 11968
addi $t3, $t4, 11972
addi $t3, $t4, 11976
addi $t3, $t4, 11980
addi $t3, $t4, 11984
addi $t3, $t4, 11988
addi $t3, $t4, 11992
addi $t3, $t4, 11996
addi $t3, $t4, 12000
addi $t3, $t4, 12004
addi $t3, $t4, 12008
addi $t3, $t4, 12012
addi $t3, $t4, 12016
addi $t3, $t4, 12020
li $t5, 0x030303
sw $t5, 0($t3)
addi $t3, $t4, 12024
addi $t3, $t4, 12028
li $t5, 0x636363
sw $t5, 0($t3)
syscall      # sleeps for 30 ms
addi $t3, $t4, 12032
li $t5, 0x727272
sw $t5, 0($t3)
addi $t3, $t4, 12036
addi $t3, $t4, 12040
li $t5, 0x030303
sw $t5, 0($t3)
addi $t3, $t4, 12044
addi $t3, $t4, 12048
addi $t3, $t4, 12052
addi $t3, $t4, 12056
addi $t3, $t4, 12060
addi $t3, $t4, 12064
addi $t3, $t4, 12068
addi $t3, $t4, 12072
addi $t3, $t4, 12076
addi $t3, $t4, 12080
addi $t3, $t4, 12084
addi $t3, $t4, 12088
addi $t3, $t4, 12092
addi $t3, $t4, 12096
addi $t3, $t4, 12100
addi $t3, $t4, 12104
addi $t3, $t4, 12108
li $t5, 0x000100
sw $t5, 0($t3)
addi $t3, $t4, 12112
addi $t3, $t4, 12116
addi $t3, $t4, 12120
addi $t3, $t4, 12124
addi $t3, $t4, 12128
addi $t3, $t4, 12132
addi $t3, $t4, 12136
addi $t3, $t4, 12140
addi $t3, $t4, 12144
addi $t3, $t4, 12148
addi $t3, $t4, 12152
addi $t3, $t4, 12156
addi $t3, $t4, 12160
addi $t3, $t4, 12164
addi $t3, $t4, 12168
addi $t3, $t4, 12172
addi $t3, $t4, 12176
addi $t3, $t4, 12180
addi $t3, $t4, 12184
addi $t3, $t4, 12188
addi $t3, $t4, 12192
addi $t3, $t4, 12196
addi $t3, $t4, 12200
addi $t3, $t4, 12204
addi $t3, $t4, 12208
addi $t3, $t4, 12212
addi $t3, $t4, 12216
addi $t3, $t4, 12220
addi $t3, $t4, 12224
addi $t3, $t4, 12228
addi $t3, $t4, 12232
addi $t3, $t4, 12236
addi $t3, $t4, 12240
addi $t3, $t4, 12244
addi $t3, $t4, 12248
addi $t3, $t4, 12252
addi $t3, $t4, 12256
addi $t3, $t4, 12260
addi $t3, $t4, 12264
addi $t3, $t4, 12268
addi $t3, $t4, 12272
addi $t3, $t4, 12276
li $t5, 0x030303
sw $t5, 0($t3)
addi $t3, $t4, 12280
addi $t3, $t4, 12284
li $t5, 0x636363
sw $t5, 0($t3)
syscall      # sleeps for 30 ms
addi $t3, $t4, 12288
li $t5, 0x727272
sw $t5, 0($t3)
addi $t3, $t4, 12292
addi $t3, $t4, 12296
li $t5, 0x030303
sw $t5, 0($t3)
addi $t3, $t4, 12300
addi $t3, $t4, 12304
addi $t3, $t4, 12308
addi $t3, $t4, 12312
addi $t3, $t4, 12316
addi $t3, $t4, 12320
addi $t3, $t4, 12324
addi $t3, $t4, 12328
addi $t3, $t4, 12332
addi $t3, $t4, 12336
addi $t3, $t4, 12340
addi $t3, $t4, 12344
addi $t3, $t4, 12348
addi $t3, $t4, 12352
addi $t3, $t4, 12356
li $t5, 0x040502
sw $t5, 0($t3)
addi $t3, $t4, 12360
li $t5, 0x0d1307
sw $t5, 0($t3)
addi $t3, $t4, 12364
addi $t3, $t4, 12368
li $t5, 0x070a04
sw $t5, 0($t3)
addi $t3, $t4, 12372
li $t5, 0x0b1006
sw $t5, 0($t3)
addi $t3, $t4, 12376
addi $t3, $t4, 12380
li $t5, 0x000100
sw $t5, 0($t3)
addi $t3, $t4, 12384
addi $t3, $t4, 12388
addi $t3, $t4, 12392
addi $t3, $t4, 12396
addi $t3, $t4, 12400
addi $t3, $t4, 12404
addi $t3, $t4, 12408
addi $t3, $t4, 12412
addi $t3, $t4, 12416
addi $t3, $t4, 12420
addi $t3, $t4, 12424
addi $t3, $t4, 12428
addi $t3, $t4, 12432
addi $t3, $t4, 12436
addi $t3, $t4, 12440
li $t5, 0x010000
sw $t5, 0($t3)
addi $t3, $t4, 12444
addi $t3, $t4, 12448
li $t5, 0x1b0000
sw $t5, 0($t3)
addi $t3, $t4, 12452
li $t5, 0x040000
sw $t5, 0($t3)
addi $t3, $t4, 12456
li $t5, 0x010000
sw $t5, 0($t3)
addi $t3, $t4, 12460
li $t5, 0x140000
sw $t5, 0($t3)
addi $t3, $t4, 12464
li $t5, 0x040000
sw $t5, 0($t3)
addi $t3, $t4, 12468
addi $t3, $t4, 12472
addi $t3, $t4, 12476
addi $t3, $t4, 12480
addi $t3, $t4, 12484
addi $t3, $t4, 12488
addi $t3, $t4, 12492
addi $t3, $t4, 12496
addi $t3, $t4, 12500
addi $t3, $t4, 12504
addi $t3, $t4, 12508
addi $t3, $t4, 12512
addi $t3, $t4, 12516
addi $t3, $t4, 12520
addi $t3, $t4, 12524
addi $t3, $t4, 12528
addi $t3, $t4, 12532
li $t5, 0x030303
sw $t5, 0($t3)
addi $t3, $t4, 12536
addi $t3, $t4, 12540
li $t5, 0x636363
sw $t5, 0($t3)
syscall      # sleeps for 30 ms
addi $t3, $t4, 12544
li $t5, 0x727272
sw $t5, 0($t3)
addi $t3, $t4, 12548
addi $t3, $t4, 12552
li $t5, 0x030303
sw $t5, 0($t3)
addi $t3, $t4, 12556
addi $t3, $t4, 12560
addi $t3, $t4, 12564
addi $t3, $t4, 12568
addi $t3, $t4, 12572
addi $t3, $t4, 12576
addi $t3, $t4, 12580
addi $t3, $t4, 12584
addi $t3, $t4, 12588
addi $t3, $t4, 12592
addi $t3, $t4, 12596
addi $t3, $t4, 12600
addi $t3, $t4, 12604
addi $t3, $t4, 12608
li $t5, 0x010101
sw $t5, 0($t3)
addi $t3, $t4, 12612
li $t5, 0x040502
sw $t5, 0($t3)
addi $t3, $t4, 12616
li $t5, 0x456226
sw $t5, 0($t3)
addi $t3, $t4, 12620
li $t5, 0x040602
sw $t5, 0($t3)
addi $t3, $t4, 12624
li $t5, 0x3b5421
sw $t5, 0($t3)
addi $t3, $t4, 12628
li $t5, 0x16200c
sw $t5, 0($t3)
addi $t3, $t4, 12632
addi $t3, $t4, 12636
li $t5, 0x010100
sw $t5, 0($t3)
addi $t3, $t4, 12640
addi $t3, $t4, 12644
addi $t3, $t4, 12648
addi $t3, $t4, 12652
addi $t3, $t4, 12656
addi $t3, $t4, 12660
addi $t3, $t4, 12664
addi $t3, $t4, 12668
addi $t3, $t4, 12672
addi $t3, $t4, 12676
addi $t3, $t4, 12680
addi $t3, $t4, 12684
addi $t3, $t4, 12688
addi $t3, $t4, 12692
addi $t3, $t4, 12696
li $t5, 0x030000
sw $t5, 0($t3)
addi $t3, $t4, 12700
addi $t3, $t4, 12704
li $t5, 0x8c0101
sw $t5, 0($t3)
addi $t3, $t4, 12708
li $t5, 0x690101
sw $t5, 0($t3)
addi $t3, $t4, 12712
addi $t3, $t4, 12716
li $t5, 0x6a0100
sw $t5, 0($t3)
addi $t3, $t4, 12720
li $t5, 0x120000
sw $t5, 0($t3)
addi $t3, $t4, 12724
addi $t3, $t4, 12728
addi $t3, $t4, 12732
addi $t3, $t4, 12736
addi $t3, $t4, 12740
addi $t3, $t4, 12744
addi $t3, $t4, 12748
addi $t3, $t4, 12752
addi $t3, $t4, 12756
addi $t3, $t4, 12760
addi $t3, $t4, 12764
addi $t3, $t4, 12768
addi $t3, $t4, 12772
addi $t3, $t4, 12776
addi $t3, $t4, 12780
addi $t3, $t4, 12784
addi $t3, $t4, 12788
li $t5, 0x030303
sw $t5, 0($t3)
addi $t3, $t4, 12792
addi $t3, $t4, 12796
li $t5, 0x636363
sw $t5, 0($t3)
syscall      # sleeps for 30 ms
addi $t3, $t4, 12800
li $t5, 0x727272
sw $t5, 0($t3)
addi $t3, $t4, 12804
addi $t3, $t4, 12808
li $t5, 0x030303
sw $t5, 0($t3)
addi $t3, $t4, 12812
addi $t3, $t4, 12816
addi $t3, $t4, 12820
addi $t3, $t4, 12824
addi $t3, $t4, 12828
addi $t3, $t4, 12832
addi $t3, $t4, 12836
addi $t3, $t4, 12840
addi $t3, $t4, 12844
addi $t3, $t4, 12848
addi $t3, $t4, 12852
addi $t3, $t4, 12856
addi $t3, $t4, 12860
addi $t3, $t4, 12864
li $t5, 0x010201
sw $t5, 0($t3)
addi $t3, $t4, 12868
addi $t3, $t4, 12872
li $t5, 0x19230e
sw $t5, 0($t3)
addi $t3, $t4, 12876
li $t5, 0x4d6d2a
sw $t5, 0($t3)
addi $t3, $t4, 12880
li $t5, 0x31461b
sw $t5, 0($t3)
addi $t3, $t4, 12884
addi $t3, $t4, 12888
li $t5, 0x010201
sw $t5, 0($t3)
addi $t3, $t4, 12892
addi $t3, $t4, 12896
addi $t3, $t4, 12900
addi $t3, $t4, 12904
addi $t3, $t4, 12908
addi $t3, $t4, 12912
addi $t3, $t4, 12916
addi $t3, $t4, 12920
addi $t3, $t4, 12924
addi $t3, $t4, 12928
addi $t3, $t4, 12932
addi $t3, $t4, 12936
addi $t3, $t4, 12940
addi $t3, $t4, 12944
addi $t3, $t4, 12948
addi $t3, $t4, 12952
li $t5, 0x020000
sw $t5, 0($t3)
addi $t3, $t4, 12956
addi $t3, $t4, 12960
li $t5, 0x590101
sw $t5, 0($t3)
addi $t3, $t4, 12964
li $t5, 0x830101
sw $t5, 0($t3)
addi $t3, $t4, 12968
li $t5, 0x190000
sw $t5, 0($t3)
addi $t3, $t4, 12972
li $t5, 0x5b0100
sw $t5, 0($t3)
addi $t3, $t4, 12976
li $t5, 0x130000
sw $t5, 0($t3)
addi $t3, $t4, 12980
addi $t3, $t4, 12984
addi $t3, $t4, 12988
addi $t3, $t4, 12992
addi $t3, $t4, 12996
addi $t3, $t4, 13000
addi $t3, $t4, 13004
addi $t3, $t4, 13008
addi $t3, $t4, 13012
addi $t3, $t4, 13016
addi $t3, $t4, 13020
addi $t3, $t4, 13024
addi $t3, $t4, 13028
addi $t3, $t4, 13032
addi $t3, $t4, 13036
addi $t3, $t4, 13040
addi $t3, $t4, 13044
li $t5, 0x030303
sw $t5, 0($t3)
addi $t3, $t4, 13048
addi $t3, $t4, 13052
li $t5, 0x636363
sw $t5, 0($t3)
syscall      # sleeps for 30 ms
addi $t3, $t4, 13056
li $t5, 0x727272
sw $t5, 0($t3)
addi $t3, $t4, 13060
addi $t3, $t4, 13064
li $t5, 0x030303
sw $t5, 0($t3)
addi $t3, $t4, 13068
addi $t3, $t4, 13072
addi $t3, $t4, 13076
addi $t3, $t4, 13080
addi $t3, $t4, 13084
addi $t3, $t4, 13088
addi $t3, $t4, 13092
addi $t3, $t4, 13096
addi $t3, $t4, 13100
addi $t3, $t4, 13104
addi $t3, $t4, 13108
addi $t3, $t4, 13112
addi $t3, $t4, 13116
addi $t3, $t4, 13120
addi $t3, $t4, 13124
li $t5, 0x010201
sw $t5, 0($t3)
addi $t3, $t4, 13128
addi $t3, $t4, 13132
li $t5, 0x4e6f2b
sw $t5, 0($t3)
addi $t3, $t4, 13136
li $t5, 0x0f1508
sw $t5, 0($t3)
addi $t3, $t4, 13140
addi $t3, $t4, 13144
li $t5, 0x010100
sw $t5, 0($t3)
addi $t3, $t4, 13148
addi $t3, $t4, 13152
addi $t3, $t4, 13156
addi $t3, $t4, 13160
addi $t3, $t4, 13164
addi $t3, $t4, 13168
addi $t3, $t4, 13172
addi $t3, $t4, 13176
addi $t3, $t4, 13180
addi $t3, $t4, 13184
addi $t3, $t4, 13188
addi $t3, $t4, 13192
addi $t3, $t4, 13196
addi $t3, $t4, 13200
addi $t3, $t4, 13204
addi $t3, $t4, 13208
li $t5, 0x020000
sw $t5, 0($t3)
addi $t3, $t4, 13212
addi $t3, $t4, 13216
li $t5, 0x5b0101
sw $t5, 0($t3)
addi $t3, $t4, 13220
li $t5, 0x270000
sw $t5, 0($t3)
addi $t3, $t4, 13224
li $t5, 0x690100
sw $t5, 0($t3)
addi $t3, $t4, 13228
li $t5, 0x5b0100
sw $t5, 0($t3)
addi $t3, $t4, 13232
li $t5, 0x120000
sw $t5, 0($t3)
addi $t3, $t4, 13236
addi $t3, $t4, 13240
addi $t3, $t4, 13244
addi $t3, $t4, 13248
addi $t3, $t4, 13252
addi $t3, $t4, 13256
addi $t3, $t4, 13260
addi $t3, $t4, 13264
addi $t3, $t4, 13268
addi $t3, $t4, 13272
addi $t3, $t4, 13276
addi $t3, $t4, 13280
addi $t3, $t4, 13284
addi $t3, $t4, 13288
addi $t3, $t4, 13292
addi $t3, $t4, 13296
addi $t3, $t4, 13300
li $t5, 0x030303
sw $t5, 0($t3)
addi $t3, $t4, 13304
addi $t3, $t4, 13308
li $t5, 0x636363
sw $t5, 0($t3)
syscall      # sleeps for 30 ms
addi $t3, $t4, 13312
li $t5, 0x727272
sw $t5, 0($t3)
addi $t3, $t4, 13316
addi $t3, $t4, 13320
li $t5, 0x030303
sw $t5, 0($t3)
addi $t3, $t4, 13324
addi $t3, $t4, 13328
addi $t3, $t4, 13332
addi $t3, $t4, 13336
addi $t3, $t4, 13340
addi $t3, $t4, 13344
addi $t3, $t4, 13348
addi $t3, $t4, 13352
addi $t3, $t4, 13356
addi $t3, $t4, 13360
addi $t3, $t4, 13364
addi $t3, $t4, 13368
addi $t3, $t4, 13372
addi $t3, $t4, 13376
addi $t3, $t4, 13380
li $t5, 0x010201
sw $t5, 0($t3)
addi $t3, $t4, 13384
li $t5, 0x010100
sw $t5, 0($t3)
addi $t3, $t4, 13388
li $t5, 0x3b5421
sw $t5, 0($t3)
addi $t3, $t4, 13392
li $t5, 0x0b1006
sw $t5, 0($t3)
addi $t3, $t4, 13396
addi $t3, $t4, 13400
addi $t3, $t4, 13404
addi $t3, $t4, 13408
addi $t3, $t4, 13412
addi $t3, $t4, 13416
addi $t3, $t4, 13420
addi $t3, $t4, 13424
addi $t3, $t4, 13428
addi $t3, $t4, 13432
addi $t3, $t4, 13436
addi $t3, $t4, 13440
addi $t3, $t4, 13444
addi $t3, $t4, 13448
addi $t3, $t4, 13452
addi $t3, $t4, 13456
addi $t3, $t4, 13460
addi $t3, $t4, 13464
li $t5, 0x020000
sw $t5, 0($t3)
addi $t3, $t4, 13468
addi $t3, $t4, 13472
li $t5, 0x6e0101
sw $t5, 0($t3)
addi $t3, $t4, 13476
li $t5, 0x040000
sw $t5, 0($t3)
addi $t3, $t4, 13480
li $t5, 0x410100
sw $t5, 0($t3)
addi $t3, $t4, 13484
li $t5, 0xb30101
sw $t5, 0($t3)
addi $t3, $t4, 13488
li $t5, 0x050000
sw $t5, 0($t3)
addi $t3, $t4, 13492
addi $t3, $t4, 13496
addi $t3, $t4, 13500
addi $t3, $t4, 13504
addi $t3, $t4, 13508
addi $t3, $t4, 13512
addi $t3, $t4, 13516
addi $t3, $t4, 13520
addi $t3, $t4, 13524
addi $t3, $t4, 13528
addi $t3, $t4, 13532
addi $t3, $t4, 13536
addi $t3, $t4, 13540
addi $t3, $t4, 13544
addi $t3, $t4, 13548
addi $t3, $t4, 13552
addi $t3, $t4, 13556
li $t5, 0x030303
sw $t5, 0($t3)
addi $t3, $t4, 13560
addi $t3, $t4, 13564
li $t5, 0x636363
sw $t5, 0($t3)
syscall      # sleeps for 30 ms
addi $t3, $t4, 13568
li $t5, 0x727272
sw $t5, 0($t3)
addi $t3, $t4, 13572
addi $t3, $t4, 13576
li $t5, 0x030303
sw $t5, 0($t3)
addi $t3, $t4, 13580
addi $t3, $t4, 13584
addi $t3, $t4, 13588
addi $t3, $t4, 13592
addi $t3, $t4, 13596
addi $t3, $t4, 13600
addi $t3, $t4, 13604
addi $t3, $t4, 13608
addi $t3, $t4, 13612
addi $t3, $t4, 13616
addi $t3, $t4, 13620
addi $t3, $t4, 13624
addi $t3, $t4, 13628
addi $t3, $t4, 13632
addi $t3, $t4, 13636
li $t5, 0x000100
sw $t5, 0($t3)
addi $t3, $t4, 13640
addi $t3, $t4, 13644
li $t5, 0x1c2810
sw $t5, 0($t3)
addi $t3, $t4, 13648
li $t5, 0x050803
sw $t5, 0($t3)
addi $t3, $t4, 13652
addi $t3, $t4, 13656
addi $t3, $t4, 13660
addi $t3, $t4, 13664
addi $t3, $t4, 13668
addi $t3, $t4, 13672
addi $t3, $t4, 13676
addi $t3, $t4, 13680
addi $t3, $t4, 13684
addi $t3, $t4, 13688
addi $t3, $t4, 13692
addi $t3, $t4, 13696
addi $t3, $t4, 13700
addi $t3, $t4, 13704
addi $t3, $t4, 13708
addi $t3, $t4, 13712
addi $t3, $t4, 13716
addi $t3, $t4, 13720
li $t5, 0x010000
sw $t5, 0($t3)
addi $t3, $t4, 13724
addi $t3, $t4, 13728
li $t5, 0x2f0101
sw $t5, 0($t3)
addi $t3, $t4, 13732
li $t5, 0x080000
sw $t5, 0($t3)
addi $t3, $t4, 13736
addi $t3, $t4, 13740
li $t5, 0x510101
sw $t5, 0($t3)
addi $t3, $t4, 13744
li $t5, 0x040000
sw $t5, 0($t3)
addi $t3, $t4, 13748
addi $t3, $t4, 13752
addi $t3, $t4, 13756
addi $t3, $t4, 13760
addi $t3, $t4, 13764
addi $t3, $t4, 13768
addi $t3, $t4, 13772
addi $t3, $t4, 13776
addi $t3, $t4, 13780
addi $t3, $t4, 13784
addi $t3, $t4, 13788
addi $t3, $t4, 13792
addi $t3, $t4, 13796
addi $t3, $t4, 13800
addi $t3, $t4, 13804
addi $t3, $t4, 13808
addi $t3, $t4, 13812
li $t5, 0x030303
sw $t5, 0($t3)
addi $t3, $t4, 13816
addi $t3, $t4, 13820
li $t5, 0x636363
sw $t5, 0($t3)
syscall      # sleeps for 30 ms
addi $t3, $t4, 13824
li $t5, 0x727272
sw $t5, 0($t3)
addi $t3, $t4, 13828
addi $t3, $t4, 13832
li $t5, 0x030303
sw $t5, 0($t3)
addi $t3, $t4, 13836
addi $t3, $t4, 13840
addi $t3, $t4, 13844
addi $t3, $t4, 13848
addi $t3, $t4, 13852
addi $t3, $t4, 13856
addi $t3, $t4, 13860
addi $t3, $t4, 13864
addi $t3, $t4, 13868
addi $t3, $t4, 13872
addi $t3, $t4, 13876
addi $t3, $t4, 13880
addi $t3, $t4, 13884
addi $t3, $t4, 13888
addi $t3, $t4, 13892
addi $t3, $t4, 13896
addi $t3, $t4, 13900
addi $t3, $t4, 13904
addi $t3, $t4, 13908
addi $t3, $t4, 13912
addi $t3, $t4, 13916
addi $t3, $t4, 13920
addi $t3, $t4, 13924
addi $t3, $t4, 13928
addi $t3, $t4, 13932
addi $t3, $t4, 13936
addi $t3, $t4, 13940
addi $t3, $t4, 13944
addi $t3, $t4, 13948
addi $t3, $t4, 13952
addi $t3, $t4, 13956
addi $t3, $t4, 13960
addi $t3, $t4, 13964
addi $t3, $t4, 13968
addi $t3, $t4, 13972
addi $t3, $t4, 13976
addi $t3, $t4, 13980
addi $t3, $t4, 13984
addi $t3, $t4, 13988
addi $t3, $t4, 13992
addi $t3, $t4, 13996
addi $t3, $t4, 14000
addi $t3, $t4, 14004
addi $t3, $t4, 14008
addi $t3, $t4, 14012
addi $t3, $t4, 14016
addi $t3, $t4, 14020
addi $t3, $t4, 14024
addi $t3, $t4, 14028
addi $t3, $t4, 14032
addi $t3, $t4, 14036
addi $t3, $t4, 14040
addi $t3, $t4, 14044
addi $t3, $t4, 14048
addi $t3, $t4, 14052
addi $t3, $t4, 14056
addi $t3, $t4, 14060
addi $t3, $t4, 14064
addi $t3, $t4, 14068
sw $t5, 0($t3)
addi $t3, $t4, 14072
addi $t3, $t4, 14076
li $t5, 0x636363
sw $t5, 0($t3)
syscall      # sleeps for 30 ms
addi $t3, $t4, 14080
li $t5, 0x727272
sw $t5, 0($t3)
addi $t3, $t4, 14084
addi $t3, $t4, 14088
li $t5, 0x030303
sw $t5, 0($t3)
addi $t3, $t4, 14092
addi $t3, $t4, 14096
addi $t3, $t4, 14100
addi $t3, $t4, 14104
addi $t3, $t4, 14108
addi $t3, $t4, 14112
addi $t3, $t4, 14116
addi $t3, $t4, 14120
addi $t3, $t4, 14124
addi $t3, $t4, 14128
addi $t3, $t4, 14132
addi $t3, $t4, 14136
addi $t3, $t4, 14140
addi $t3, $t4, 14144
addi $t3, $t4, 14148
addi $t3, $t4, 14152
addi $t3, $t4, 14156
li $t5, 0x010101
sw $t5, 0($t3)
addi $t3, $t4, 14160
addi $t3, $t4, 14164
addi $t3, $t4, 14168
addi $t3, $t4, 14172
addi $t3, $t4, 14176
addi $t3, $t4, 14180
addi $t3, $t4, 14184
addi $t3, $t4, 14188
addi $t3, $t4, 14192
addi $t3, $t4, 14196
addi $t3, $t4, 14200
addi $t3, $t4, 14204
addi $t3, $t4, 14208
addi $t3, $t4, 14212
addi $t3, $t4, 14216
addi $t3, $t4, 14220
addi $t3, $t4, 14224
addi $t3, $t4, 14228
addi $t3, $t4, 14232
addi $t3, $t4, 14236
addi $t3, $t4, 14240
li $t5, 0x020000
sw $t5, 0($t3)
addi $t3, $t4, 14244
addi $t3, $t4, 14248
addi $t3, $t4, 14252
li $t5, 0x030000
sw $t5, 0($t3)
addi $t3, $t4, 14256
addi $t3, $t4, 14260
addi $t3, $t4, 14264
addi $t3, $t4, 14268
addi $t3, $t4, 14272
addi $t3, $t4, 14276
addi $t3, $t4, 14280
addi $t3, $t4, 14284
addi $t3, $t4, 14288
addi $t3, $t4, 14292
addi $t3, $t4, 14296
addi $t3, $t4, 14300
addi $t3, $t4, 14304
addi $t3, $t4, 14308
addi $t3, $t4, 14312
addi $t3, $t4, 14316
addi $t3, $t4, 14320
addi $t3, $t4, 14324
li $t5, 0x030303
sw $t5, 0($t3)
addi $t3, $t4, 14328
addi $t3, $t4, 14332
li $t5, 0x636363
sw $t5, 0($t3)
syscall      # sleeps for 30 ms
addi $t3, $t4, 14336
li $t5, 0x727272
sw $t5, 0($t3)
addi $t3, $t4, 14340
addi $t3, $t4, 14344
li $t5, 0x030303
sw $t5, 0($t3)
addi $t3, $t4, 14348
addi $t3, $t4, 14352
addi $t3, $t4, 14356
addi $t3, $t4, 14360
addi $t3, $t4, 14364
addi $t3, $t4, 14368
addi $t3, $t4, 14372
addi $t3, $t4, 14376
addi $t3, $t4, 14380
addi $t3, $t4, 14384
addi $t3, $t4, 14388
addi $t3, $t4, 14392
addi $t3, $t4, 14396
addi $t3, $t4, 14400
addi $t3, $t4, 14404
addi $t3, $t4, 14408
addi $t3, $t4, 14412
addi $t3, $t4, 14416
addi $t3, $t4, 14420
addi $t3, $t4, 14424
addi $t3, $t4, 14428
addi $t3, $t4, 14432
addi $t3, $t4, 14436
addi $t3, $t4, 14440
addi $t3, $t4, 14444
addi $t3, $t4, 14448
addi $t3, $t4, 14452
addi $t3, $t4, 14456
addi $t3, $t4, 14460
addi $t3, $t4, 14464
addi $t3, $t4, 14468
addi $t3, $t4, 14472
addi $t3, $t4, 14476
addi $t3, $t4, 14480
addi $t3, $t4, 14484
addi $t3, $t4, 14488
addi $t3, $t4, 14492
addi $t3, $t4, 14496
addi $t3, $t4, 14500
addi $t3, $t4, 14504
addi $t3, $t4, 14508
addi $t3, $t4, 14512
addi $t3, $t4, 14516
addi $t3, $t4, 14520
addi $t3, $t4, 14524
addi $t3, $t4, 14528
addi $t3, $t4, 14532
addi $t3, $t4, 14536
addi $t3, $t4, 14540
addi $t3, $t4, 14544
addi $t3, $t4, 14548
addi $t3, $t4, 14552
addi $t3, $t4, 14556
addi $t3, $t4, 14560
addi $t3, $t4, 14564
addi $t3, $t4, 14568
addi $t3, $t4, 14572
addi $t3, $t4, 14576
addi $t3, $t4, 14580
sw $t5, 0($t3)
addi $t3, $t4, 14584
addi $t3, $t4, 14588
li $t5, 0x636363
sw $t5, 0($t3)
syscall      # sleeps for 30 ms
addi $t3, $t4, 14592
li $t5, 0x727272
sw $t5, 0($t3)
addi $t3, $t4, 14596
addi $t3, $t4, 14600
li $t5, 0x030303
sw $t5, 0($t3)
addi $t3, $t4, 14604
addi $t3, $t4, 14608
addi $t3, $t4, 14612
addi $t3, $t4, 14616
addi $t3, $t4, 14620
addi $t3, $t4, 14624
addi $t3, $t4, 14628
addi $t3, $t4, 14632
addi $t3, $t4, 14636
addi $t3, $t4, 14640
addi $t3, $t4, 14644
addi $t3, $t4, 14648
addi $t3, $t4, 14652
addi $t3, $t4, 14656
addi $t3, $t4, 14660
addi $t3, $t4, 14664
addi $t3, $t4, 14668
addi $t3, $t4, 14672
addi $t3, $t4, 14676
addi $t3, $t4, 14680
addi $t3, $t4, 14684
addi $t3, $t4, 14688
addi $t3, $t4, 14692
addi $t3, $t4, 14696
addi $t3, $t4, 14700
addi $t3, $t4, 14704
addi $t3, $t4, 14708
addi $t3, $t4, 14712
addi $t3, $t4, 14716
addi $t3, $t4, 14720
addi $t3, $t4, 14724
addi $t3, $t4, 14728
addi $t3, $t4, 14732
addi $t3, $t4, 14736
addi $t3, $t4, 14740
addi $t3, $t4, 14744
addi $t3, $t4, 14748
addi $t3, $t4, 14752
addi $t3, $t4, 14756
addi $t3, $t4, 14760
addi $t3, $t4, 14764
addi $t3, $t4, 14768
addi $t3, $t4, 14772
addi $t3, $t4, 14776
addi $t3, $t4, 14780
addi $t3, $t4, 14784
addi $t3, $t4, 14788
addi $t3, $t4, 14792
addi $t3, $t4, 14796
addi $t3, $t4, 14800
addi $t3, $t4, 14804
addi $t3, $t4, 14808
addi $t3, $t4, 14812
addi $t3, $t4, 14816
addi $t3, $t4, 14820
addi $t3, $t4, 14824
addi $t3, $t4, 14828
addi $t3, $t4, 14832
addi $t3, $t4, 14836
sw $t5, 0($t3)
addi $t3, $t4, 14840
addi $t3, $t4, 14844
li $t5, 0x636363
sw $t5, 0($t3)
syscall      # sleeps for 30 ms
addi $t3, $t4, 14848
li $t5, 0x727272
sw $t5, 0($t3)
addi $t3, $t4, 14852
addi $t3, $t4, 14856
li $t5, 0x030303
sw $t5, 0($t3)
addi $t3, $t4, 14860
addi $t3, $t4, 14864
addi $t3, $t4, 14868
addi $t3, $t4, 14872
addi $t3, $t4, 14876
addi $t3, $t4, 14880
addi $t3, $t4, 14884
addi $t3, $t4, 14888
addi $t3, $t4, 14892
addi $t3, $t4, 14896
addi $t3, $t4, 14900
addi $t3, $t4, 14904
addi $t3, $t4, 14908
addi $t3, $t4, 14912
addi $t3, $t4, 14916
addi $t3, $t4, 14920
addi $t3, $t4, 14924
addi $t3, $t4, 14928
addi $t3, $t4, 14932
addi $t3, $t4, 14936
addi $t3, $t4, 14940
addi $t3, $t4, 14944
addi $t3, $t4, 14948
addi $t3, $t4, 14952
addi $t3, $t4, 14956
addi $t3, $t4, 14960
addi $t3, $t4, 14964
addi $t3, $t4, 14968
addi $t3, $t4, 14972
addi $t3, $t4, 14976
addi $t3, $t4, 14980
addi $t3, $t4, 14984
addi $t3, $t4, 14988
addi $t3, $t4, 14992
addi $t3, $t4, 14996
addi $t3, $t4, 15000
addi $t3, $t4, 15004
addi $t3, $t4, 15008
addi $t3, $t4, 15012
addi $t3, $t4, 15016
addi $t3, $t4, 15020
addi $t3, $t4, 15024
addi $t3, $t4, 15028
addi $t3, $t4, 15032
addi $t3, $t4, 15036
addi $t3, $t4, 15040
addi $t3, $t4, 15044
addi $t3, $t4, 15048
addi $t3, $t4, 15052
addi $t3, $t4, 15056
addi $t3, $t4, 15060
addi $t3, $t4, 15064
addi $t3, $t4, 15068
addi $t3, $t4, 15072
addi $t3, $t4, 15076
addi $t3, $t4, 15080
addi $t3, $t4, 15084
addi $t3, $t4, 15088
addi $t3, $t4, 15092
sw $t5, 0($t3)
addi $t3, $t4, 15096
addi $t3, $t4, 15100
li $t5, 0x636363
sw $t5, 0($t3)
syscall      # sleeps for 30 ms
addi $t3, $t4, 15104
li $t5, 0x727272
sw $t5, 0($t3)
addi $t3, $t4, 15108
addi $t3, $t4, 15112
li $t5, 0x030303
sw $t5, 0($t3)
addi $t3, $t4, 15116
addi $t3, $t4, 15120
addi $t3, $t4, 15124
addi $t3, $t4, 15128
addi $t3, $t4, 15132
addi $t3, $t4, 15136
addi $t3, $t4, 15140
addi $t3, $t4, 15144
addi $t3, $t4, 15148
addi $t3, $t4, 15152
addi $t3, $t4, 15156
addi $t3, $t4, 15160
addi $t3, $t4, 15164
addi $t3, $t4, 15168
addi $t3, $t4, 15172
addi $t3, $t4, 15176
addi $t3, $t4, 15180
addi $t3, $t4, 15184
addi $t3, $t4, 15188
addi $t3, $t4, 15192
addi $t3, $t4, 15196
addi $t3, $t4, 15200
addi $t3, $t4, 15204
addi $t3, $t4, 15208
addi $t3, $t4, 15212
addi $t3, $t4, 15216
addi $t3, $t4, 15220
addi $t3, $t4, 15224
addi $t3, $t4, 15228
addi $t3, $t4, 15232
addi $t3, $t4, 15236
addi $t3, $t4, 15240
addi $t3, $t4, 15244
addi $t3, $t4, 15248
addi $t3, $t4, 15252
addi $t3, $t4, 15256
addi $t3, $t4, 15260
addi $t3, $t4, 15264
addi $t3, $t4, 15268
addi $t3, $t4, 15272
addi $t3, $t4, 15276
addi $t3, $t4, 15280
addi $t3, $t4, 15284
addi $t3, $t4, 15288
addi $t3, $t4, 15292
addi $t3, $t4, 15296
addi $t3, $t4, 15300
addi $t3, $t4, 15304
addi $t3, $t4, 15308
addi $t3, $t4, 15312
addi $t3, $t4, 15316
addi $t3, $t4, 15320
addi $t3, $t4, 15324
addi $t3, $t4, 15328
addi $t3, $t4, 15332
addi $t3, $t4, 15336
addi $t3, $t4, 15340
addi $t3, $t4, 15344
addi $t3, $t4, 15348
sw $t5, 0($t3)
addi $t3, $t4, 15352
addi $t3, $t4, 15356
li $t5, 0x636363
sw $t5, 0($t3)
syscall      # sleeps for 30 ms
addi $t3, $t4, 15360
li $t5, 0x727272
sw $t5, 0($t3)
addi $t3, $t4, 15364
addi $t3, $t4, 15368
li $t5, 0x030303
sw $t5, 0($t3)
addi $t3, $t4, 15372
addi $t3, $t4, 15376
addi $t3, $t4, 15380
addi $t3, $t4, 15384
addi $t3, $t4, 15388
addi $t3, $t4, 15392
addi $t3, $t4, 15396
addi $t3, $t4, 15400
addi $t3, $t4, 15404
addi $t3, $t4, 15408
addi $t3, $t4, 15412
addi $t3, $t4, 15416
addi $t3, $t4, 15420
addi $t3, $t4, 15424
addi $t3, $t4, 15428
addi $t3, $t4, 15432
addi $t3, $t4, 15436
addi $t3, $t4, 15440
addi $t3, $t4, 15444
addi $t3, $t4, 15448
addi $t3, $t4, 15452
addi $t3, $t4, 15456
addi $t3, $t4, 15460
addi $t3, $t4, 15464
addi $t3, $t4, 15468
addi $t3, $t4, 15472
addi $t3, $t4, 15476
addi $t3, $t4, 15480
addi $t3, $t4, 15484
addi $t3, $t4, 15488
addi $t3, $t4, 15492
addi $t3, $t4, 15496
addi $t3, $t4, 15500
addi $t3, $t4, 15504
addi $t3, $t4, 15508
addi $t3, $t4, 15512
addi $t3, $t4, 15516
addi $t3, $t4, 15520
addi $t3, $t4, 15524
addi $t3, $t4, 15528
addi $t3, $t4, 15532
addi $t3, $t4, 15536
addi $t3, $t4, 15540
addi $t3, $t4, 15544
addi $t3, $t4, 15548
addi $t3, $t4, 15552
addi $t3, $t4, 15556
addi $t3, $t4, 15560
addi $t3, $t4, 15564
addi $t3, $t4, 15568
addi $t3, $t4, 15572
addi $t3, $t4, 15576
addi $t3, $t4, 15580
addi $t3, $t4, 15584
addi $t3, $t4, 15588
addi $t3, $t4, 15592
addi $t3, $t4, 15596
addi $t3, $t4, 15600
addi $t3, $t4, 15604
sw $t5, 0($t3)
addi $t3, $t4, 15608
addi $t3, $t4, 15612
li $t5, 0x636363
sw $t5, 0($t3)
syscall      # sleeps for 30 ms
addi $t3, $t4, 15616
li $t5, 0x727272
sw $t5, 0($t3)
addi $t3, $t4, 15620
li $t5, 0x010101
sw $t5, 0($t3)
addi $t3, $t4, 15624
li $t5, 0x040404
sw $t5, 0($t3)
addi $t3, $t4, 15628
li $t5, 0x010101
sw $t5, 0($t3)
addi $t3, $t4, 15632
sw $t5, 0($t3)
addi $t3, $t4, 15636
sw $t5, 0($t3)
addi $t3, $t4, 15640
sw $t5, 0($t3)
addi $t3, $t4, 15644
sw $t5, 0($t3)
addi $t3, $t4, 15648
sw $t5, 0($t3)
addi $t3, $t4, 15652
sw $t5, 0($t3)
addi $t3, $t4, 15656
sw $t5, 0($t3)
addi $t3, $t4, 15660
sw $t5, 0($t3)
addi $t3, $t4, 15664
sw $t5, 0($t3)
addi $t3, $t4, 15668
sw $t5, 0($t3)
addi $t3, $t4, 15672
sw $t5, 0($t3)
addi $t3, $t4, 15676
sw $t5, 0($t3)
addi $t3, $t4, 15680
sw $t5, 0($t3)
addi $t3, $t4, 15684
sw $t5, 0($t3)
addi $t3, $t4, 15688
sw $t5, 0($t3)
addi $t3, $t4, 15692
sw $t5, 0($t3)
addi $t3, $t4, 15696
sw $t5, 0($t3)
addi $t3, $t4, 15700
sw $t5, 0($t3)
addi $t3, $t4, 15704
sw $t5, 0($t3)
addi $t3, $t4, 15708
sw $t5, 0($t3)
addi $t3, $t4, 15712
sw $t5, 0($t3)
addi $t3, $t4, 15716
sw $t5, 0($t3)
addi $t3, $t4, 15720
sw $t5, 0($t3)
addi $t3, $t4, 15724
sw $t5, 0($t3)
addi $t3, $t4, 15728
sw $t5, 0($t3)
addi $t3, $t4, 15732
sw $t5, 0($t3)
addi $t3, $t4, 15736
sw $t5, 0($t3)
addi $t3, $t4, 15740
sw $t5, 0($t3)
addi $t3, $t4, 15744
sw $t5, 0($t3)
addi $t3, $t4, 15748
sw $t5, 0($t3)
addi $t3, $t4, 15752
sw $t5, 0($t3)
addi $t3, $t4, 15756
sw $t5, 0($t3)
addi $t3, $t4, 15760
sw $t5, 0($t3)
addi $t3, $t4, 15764
sw $t5, 0($t3)
addi $t3, $t4, 15768
sw $t5, 0($t3)
addi $t3, $t4, 15772
sw $t5, 0($t3)
addi $t3, $t4, 15776
sw $t5, 0($t3)
addi $t3, $t4, 15780
sw $t5, 0($t3)
addi $t3, $t4, 15784
sw $t5, 0($t3)
addi $t3, $t4, 15788
sw $t5, 0($t3)
addi $t3, $t4, 15792
sw $t5, 0($t3)
addi $t3, $t4, 15796
sw $t5, 0($t3)
addi $t3, $t4, 15800
sw $t5, 0($t3)
addi $t3, $t4, 15804
sw $t5, 0($t3)
addi $t3, $t4, 15808
sw $t5, 0($t3)
addi $t3, $t4, 15812
sw $t5, 0($t3)
addi $t3, $t4, 15816
sw $t5, 0($t3)
addi $t3, $t4, 15820
sw $t5, 0($t3)
addi $t3, $t4, 15824
sw $t5, 0($t3)
addi $t3, $t4, 15828
sw $t5, 0($t3)
addi $t3, $t4, 15832
sw $t5, 0($t3)
addi $t3, $t4, 15836
sw $t5, 0($t3)
addi $t3, $t4, 15840
sw $t5, 0($t3)
addi $t3, $t4, 15844
sw $t5, 0($t3)
addi $t3, $t4, 15848
sw $t5, 0($t3)
addi $t3, $t4, 15852
sw $t5, 0($t3)
addi $t3, $t4, 15856
sw $t5, 0($t3)
addi $t3, $t4, 15860
li $t5, 0x040404
sw $t5, 0($t3)
addi $t3, $t4, 15864
li $t5, 0x010101
sw $t5, 0($t3)
addi $t3, $t4, 15868
li $t5, 0x636363
sw $t5, 0($t3)
syscall      # sleeps for 30 ms
addi $t3, $t4, 15872
li $t5, 0x707070
sw $t5, 0($t3)
addi $t3, $t4, 15876
addi $t3, $t4, 15880
addi $t3, $t4, 15884
addi $t3, $t4, 15888
addi $t3, $t4, 15892
addi $t3, $t4, 15896
addi $t3, $t4, 15900
addi $t3, $t4, 15904
addi $t3, $t4, 15908
addi $t3, $t4, 15912
addi $t3, $t4, 15916
addi $t3, $t4, 15920
addi $t3, $t4, 15924
addi $t3, $t4, 15928
addi $t3, $t4, 15932
addi $t3, $t4, 15936
addi $t3, $t4, 15940
addi $t3, $t4, 15944
addi $t3, $t4, 15948
addi $t3, $t4, 15952
addi $t3, $t4, 15956
addi $t3, $t4, 15960
addi $t3, $t4, 15964
addi $t3, $t4, 15968
addi $t3, $t4, 15972
addi $t3, $t4, 15976
addi $t3, $t4, 15980
addi $t3, $t4, 15984
addi $t3, $t4, 15988
addi $t3, $t4, 15992
addi $t3, $t4, 15996
addi $t3, $t4, 16000
addi $t3, $t4, 16004
addi $t3, $t4, 16008
addi $t3, $t4, 16012
addi $t3, $t4, 16016
addi $t3, $t4, 16020
addi $t3, $t4, 16024
addi $t3, $t4, 16028
addi $t3, $t4, 16032
addi $t3, $t4, 16036
addi $t3, $t4, 16040
addi $t3, $t4, 16044
addi $t3, $t4, 16048
addi $t3, $t4, 16052
addi $t3, $t4, 16056
addi $t3, $t4, 16060
addi $t3, $t4, 16064
addi $t3, $t4, 16068
addi $t3, $t4, 16072
addi $t3, $t4, 16076
addi $t3, $t4, 16080
addi $t3, $t4, 16084
addi $t3, $t4, 16088
addi $t3, $t4, 16092
addi $t3, $t4, 16096
addi $t3, $t4, 16100
addi $t3, $t4, 16104
addi $t3, $t4, 16108
addi $t3, $t4, 16112
addi $t3, $t4, 16116
addi $t3, $t4, 16120
addi $t3, $t4, 16124
li $t5, 0x616161
sw $t5, 0($t3)
syscall      # sleeps for 30 ms
addi $t3, $t4, 16128
li $t5, 0x7b7b7b
sw $t5, 0($t3)
addi $t3, $t4, 16132
li $t5, 0x111111
sw $t5, 0($t3)
addi $t3, $t4, 16136
li $t5, 0x141414
sw $t5, 0($t3)
addi $t3, $t4, 16140
li $t5, 0x111111
sw $t5, 0($t3)
addi $t3, $t4, 16144
sw $t5, 0($t3)
addi $t3, $t4, 16148
sw $t5, 0($t3)
addi $t3, $t4, 16152
sw $t5, 0($t3)
addi $t3, $t4, 16156
sw $t5, 0($t3)
addi $t3, $t4, 16160
sw $t5, 0($t3)
addi $t3, $t4, 16164
sw $t5, 0($t3)
addi $t3, $t4, 16168
sw $t5, 0($t3)
addi $t3, $t4, 16172
sw $t5, 0($t3)
addi $t3, $t4, 16176
sw $t5, 0($t3)
addi $t3, $t4, 16180
sw $t5, 0($t3)
addi $t3, $t4, 16184
sw $t5, 0($t3)
addi $t3, $t4, 16188
sw $t5, 0($t3)
addi $t3, $t4, 16192
sw $t5, 0($t3)
addi $t3, $t4, 16196
sw $t5, 0($t3)
addi $t3, $t4, 16200
sw $t5, 0($t3)
addi $t3, $t4, 16204
sw $t5, 0($t3)
addi $t3, $t4, 16208
sw $t5, 0($t3)
addi $t3, $t4, 16212
sw $t5, 0($t3)
addi $t3, $t4, 16216
sw $t5, 0($t3)
addi $t3, $t4, 16220
sw $t5, 0($t3)
addi $t3, $t4, 16224
sw $t5, 0($t3)
addi $t3, $t4, 16228
sw $t5, 0($t3)
addi $t3, $t4, 16232
sw $t5, 0($t3)
addi $t3, $t4, 16236
sw $t5, 0($t3)
addi $t3, $t4, 16240
sw $t5, 0($t3)
addi $t3, $t4, 16244
sw $t5, 0($t3)
addi $t3, $t4, 16248
sw $t5, 0($t3)
addi $t3, $t4, 16252
sw $t5, 0($t3)
addi $t3, $t4, 16256
sw $t5, 0($t3)
addi $t3, $t4, 16260
sw $t5, 0($t3)
addi $t3, $t4, 16264
sw $t5, 0($t3)
addi $t3, $t4, 16268
sw $t5, 0($t3)
addi $t3, $t4, 16272
sw $t5, 0($t3)
addi $t3, $t4, 16276
sw $t5, 0($t3)
addi $t3, $t4, 16280
sw $t5, 0($t3)
addi $t3, $t4, 16284
sw $t5, 0($t3)
addi $t3, $t4, 16288
sw $t5, 0($t3)
addi $t3, $t4, 16292
sw $t5, 0($t3)
addi $t3, $t4, 16296
sw $t5, 0($t3)
addi $t3, $t4, 16300
sw $t5, 0($t3)
addi $t3, $t4, 16304
sw $t5, 0($t3)
addi $t3, $t4, 16308
sw $t5, 0($t3)
addi $t3, $t4, 16312
sw $t5, 0($t3)
addi $t3, $t4, 16316
sw $t5, 0($t3)
addi $t3, $t4, 16320
sw $t5, 0($t3)
addi $t3, $t4, 16324
sw $t5, 0($t3)
addi $t3, $t4, 16328
	sw $t5, 0($t3)
	addi $t3, $t4, 16332
	sw $t5, 0($t3)
	addi $t3, $t4, 16336
	sw $t5, 0($t3)
	addi $t3, $t4, 16340
	sw $t5, 0($t3)
	addi $t3, $t4, 16344
	sw $t5, 0($t3)
	addi $t3, $t4, 16348
	sw $t5, 0($t3)
	addi $t3, $t4, 16352
	sw $t5, 0($t3)
	addi $t3, $t4, 16356
	sw $t5, 0($t3)
	addi $t3, $t4, 16360
	sw $t5, 0($t3)
	addi $t3, $t4, 16364
	sw $t5, 0($t3)
	addi $t3, $t4, 16368
	sw $t5, 0($t3)
	addi $t3, $t4, 16372
	li $t5, 0x141414
	sw $t5, 0($t3)
	addi $t3, $t4, 16376
	li $t5, 0x111111
	sw $t5, 0($t3)
	addi $t3, $t4, 16380
	li $t5, 0x6e6e6e
	sw $t5, 0($t3)
	syscall      # sleeps for 30 ms

	
	# Check to see what key was pressed
	li $t9, 0xffff0000 
	lw $t3, 4($t9)
	# Check Y
	beq $t3, Y, reset
	# Check N
	beq $t3, N, respond_to_n
	
	j draw_start
