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
vgastore $l1
ladd $l1 $kb
vgastore $l1

ladd $l1 $kb
vgastore $l1

ladd $l1 $kb
vgastore $l1

ladd $l1 $kb
vgastore $l1
