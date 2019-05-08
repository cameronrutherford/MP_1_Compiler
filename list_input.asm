.data
list1 dword 1 2 3 4		# list of dwords
list3 dword 5 6 8 7		# list of dwords
list2 dword 1 2 1 2
.code
:start
lload $l1 list1
lload $l3 list3
# land $l1, $l2
ladd $l1, $l3
ladd $l3, $l1

