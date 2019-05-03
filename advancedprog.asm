.data
list1 dword 1 2 3 4 5
list2 dword 294967296 294967296 294967296 294967296 294967296
.code
mov $d1 $d0
addi $d1 5			#d1 = 5 //is the loop counter
lload $l1 list1		#l1 = [1, 2, 3, 4, 5]
lload $l2 list2		#l2 = [294967296, 294967296, 294967296, 294967296, 294967296]
:loopinglabel
ladd $l1 $l2		#l1 += l2
lstore $l1 list1
lw $d5 list1		#d5 = l1[0]
addi $d1 -1			#d1 -= 1 			//Decrement the loop counter
mov $d2 $d0			#d2 = 0
add $d2 $d1			#if d1 == d2 == 0
beq getmeoutofhere	#					//exit the loop

add $d0 $d0			#					//if 0 == 0
beq loopinglabel	#jmp loopinglabel 	//keep looping
:getmeoutofhere
