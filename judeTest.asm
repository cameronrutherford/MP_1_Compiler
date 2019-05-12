.data
list1 dword 1 2 3 4		# list of dwords
listup dword -1 0 0 0	# move up
listdown dword 1 0 0 0	# move down
listleft dword 0 -1 0 0	# move left
listright dword 0 1 0 0	# move right
list3 dword 5 6 7 8		# list of dwords
.code
lload $l1 list1
lload $l2 listdown
lload $l3 listup
:startloop

mov $d2 $d0
addi $d2 1000
:downloop
ladd $l1 $l2
vgastore $l1
mov $d1 $d0
addi $d1 100000
:stalldown
addi $d1 -1
beq continuedown
jmp stalldown
:continuedown
addi $d2 -1
beq startuploop
jmp downloop


:startuploop
mov $d2 $d0
addi $d2 1000
:uploop
ladd $l1 $l3
vgastore $l1
mov $d1 $d0
addi $d1 100000
:stallup
addi $d1 -1
beq continueup
jmp stallup
:continueup
addi $d2 -1
beq startloop
jmp uploop
