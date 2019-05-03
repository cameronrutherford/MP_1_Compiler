.data
list1 dword 1 2 3 4
list3 dword 5 6 8 7
.code
:start
movi $d0 -1			#
movi $d1 1			#
add $d0 $d1			#
beq no_lists_here	#
:lists_here			
lload $l0 list1		#
lload $l1 list3		#
ladd $l0 $l1		#
lstore $l1 list3	#
jmp end				#
:no_lists_here		
lw $d3 list1[2]		#
mov $d2 $d3			#
add  $d3 $d2		#
sw $d3 list3[2]		#
jmp lists_here		#
:end				
jmp start			#