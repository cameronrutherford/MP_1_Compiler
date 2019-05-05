.data
list1 dword 1 2 3 4		# list of dwords
list3 dword 5 6 8 7		# list of dwords
.code
:start
jmp test1				# test the jump command by skipping the next line
mov $d3 $d0				# zero the $d1 register. Should be skipped
:test1						
mov $d1 $d0				# zero the $d1 register
mov $d2 $d0				# zero the $d2 register
addi $d1 1				# add 1 to $d1 = 1
addi $d2 -1				# add -1 to $d2 = -1
add $d1 $d2				# sum $d1 and $d2, store result in $d2 = 0
beq lists_here			# branch to list instructions
mov $d1 $d0				# zero $d1, should be skipped
:lists_here			
lload $l1 list1			# load list1 into $l1		
lload $l2 list3			# load list3 into $l3
ladd $l1 $l2			# add the lists together and store the result in $l1
lstore $l1 list3		# store the result into list3					
lw $d3 list1[2]			# load the third element of list1 into $d3
mov $d2 $d3				# overwrite $d2 with $d3
add  $d3 $d2			# add $d2 into $d3
sw $d3 list3[2]			# store the value in $d3 into the third slot of list3	
