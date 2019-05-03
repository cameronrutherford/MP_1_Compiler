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
mov $d1 $d0
mov $d2 $d0
addi $d1 1
addi $d2 -1
add $d1 $d2			
beq no_lists_here	
:lists_here			
lload $l1 list1		
lload $l2 list3		
ladd $l1 $l2		
lstore $l1 list3	
jmp end				
:no_lists_here		
lw $d3 list1[2]		
mov $d2 $d3			
add  $d3 $d2		
sw $d3 list3[2]			
:end				
jmp start			