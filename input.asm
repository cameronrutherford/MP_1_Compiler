.data
list1 dword 1 2 3 4
list3 dword 5 6 8 7
.code
:start
jmp test1
mov $d1 $d0
:test1
jmp test2
mov $d1 $d0
:test2
jmp test3
mov $d1 $d0
:test3
mov $d1 $d0		#00080000
mov $d2 $d0		#00100000
addi $d1 1		#81080001
addi $d2 -1			#8117ffff
add $d1 $d2			#01088000
beq no_lists_here	#4000000c
:lists_here			
lload $l1 list1		#92000020
lload $l2 list3		#920800a0
ladd $l1 $l2		#11004000
lstore $l1 list3	#930800a0
jmp end				#2000000c
:no_lists_here		
lw $d3 list1[2]		#84180060
mov $d2 $d3			#0010c000
add  $d3 $d2		#01188000
sw $d3 list3[2]		#851800e0
jmp lists_here		#20ffffd8
:end				
jmp start			#20ffffc0