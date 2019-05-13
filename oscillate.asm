.data
list1 dword 111 200 300 400		# list of dwords
list2 dword 333 400 100 300
listup dword -1 0 0 0	# move up
listdown dword 1 0 0 0	# move down
listleft dword 0 -1 0 0	# move left
listright dword 0 1 0 0	# move right
list3 dword 5 6 7 8		# list of dwords
.code
lload $l1 list1
lload $l2 list2

:startloop
lload $l1 list1
vgastore $l1
mov $d1 $d0
addi $d1 100000
:stalldown
addi $d1 -1
beq nextpos
jmp stalldown
:nextpos

lload $l2 list2
vgastore $l2
mov $d1 $d0
addi $d1 100000
:stallup
addi $d1 -1
beq startloop
jmp stallup
:continueup

