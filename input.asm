.data
# Change the arrays to be variable length
error dword 999999999
list dword 1 2 3 4 5 6 7

.code
# Labels are on their own line starting with a colon, and only use the first word
:start <- This is the start
mov $d0 $d1        # mov zero into the first data register
jmp loaddata        # skip to the load data section
movi $d2 1234      # change the instruction pointer to 1234. This should never execute
:loaddata           # load data from memory
lw $d1 list         # copy the first element from list into $d1
lw $d1 list[4]      # copy the fifth element from list into $d1
lw $d2 0x34578      # copy the element in memory location 0x34578 into $d2
:addloop            # add some stuff       
add $d0 $d1         # add $d1 to $d0 and store in $d1
beq addloop         # if the result of the prior calculation was 0, loop
addi $d0 15         # add 15 to $d0 and store it in $d0