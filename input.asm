.data
list1 dword 1 2 3 4		# list of dwords
list3 dword 5 6 8 7		# list of dwords
.code
:start
lload $l1 list1
lload $l2 list3
ladd $l1 $l2
lstore $l1 list1
