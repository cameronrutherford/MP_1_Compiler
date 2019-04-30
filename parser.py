import re

# Information holds the opcode and argument lengths for every instruction
information = {}
information["mov"]  =   ('00000000', 5,  5)
information["add"]  =   ('00000001', 5,  5)
information["movi"] =   ('10000000', 5, 16)
information["addi"] =   ('10000001', 5, 16)
information["lw"]   =   ('10000100', 5, 16)
information["sw"]   =   ('10000101', 5, 16)
information["beq"]  =   ('01000000', 24, 0)
information["ladd"] =   ('00010001', 5,  5)
information["lload"] =  ('10010010', 5,  19)
information["lstore"] = ('10010011', 5,  19)
information["jmp"]  =   ('00100000', 24, 0)

# Registers maps the english name for the register to the binary value representing the
# register internally
registers = {
    "$d0" : bin(0)[2:].zfill(5),
    "$d1" : bin(1)[2:].zfill(5),
    "$d2" : bin(2)[2:].zfill(5),
    "$d3" : bin(3)[2:].zfill(5),
    "$d4" : bin(4)[2:].zfill(5),
    "$d5" : bin(5)[2:].zfill(5),
    "$d6" : bin(6)[2:].zfill(5),
    "$d7" : bin(7)[2:].zfill(5),
    "$d8" : bin(8)[2:].zfill(5),
    "$d9" : bin(9)[2:].zfill(5),
    "$d10" : bin(10)[2:].zfill(5),
    # List Processor 128 bit argument registers, l is for list
    "$l0" : bin(0)[2:].zfill(5),
    "$l1" : bin(1)[2:].zfill(5),
    "$l2" : bin(2)[2:].zfill(5),
    "$l3" : bin(3)[2:].zfill(5),
    "$l4" : bin(4)[2:].zfill(5),
    "$l5" : bin(5)[2:].zfill(5),
    "$l6" : bin(6)[2:].zfill(5),
    "$l7" : bin(7)[2:].zfill(5),
    # List Processor 128 bit result register 
    "$lr" : bin(8)[2:].zfill(5) 
}

# Data will hold the name and information of all our variables
data = {}
# lines holds the contents of the assembler code file
lines = []
# Translate variable types into number of bits
data_size_identifiers = { "dword" : 32, "word" : 16, "byte" : 8, "nibble" : 4, "bit" : 1}

# Get all the code without the comments
with open("input.asm") as f:
    for line in f:
        line = line.partition('#')[0].strip()
        if line != '':
            lines.append(line)

binary_tracker = ''

# If there is a data section, consume it and convert it to hex
if lines[0] == ".data":
    del lines[0]
    while lines[0] != ".code":
        line = lines.pop(0)
        things = line.split(' ')
        var_name = things.pop(0)
        var_size = things.pop(0)
        var_elements = things
        offset_from_start = len(binary_tracker) + 32 # maybe don't calculate this every time?
        for x in var_elements:
            binary_tracker += format(int(x), '0%db' % data_size_identifiers[var_size])
        data[var_name] = (data_size_identifiers[var_size], offset_from_start)

# contains the lines to be written to the machine code file 
hex_output = []

total_chars = (((len(binary_tracker) + 31) // 32)) * 32
binary_tracker = binary_tracker.ljust(total_chars, '0')

# This works - appends all the data to hex_output as nice hex strings in order
while binary_tracker != '':
    current = binary_tracker[:32]
    binary_tracker = binary_tracker[32:]
    to_add = hex(int(current, 2))[2:]
    hex_output.append(to_add.zfill(8))

# Now that we have the data all stored in hex output, write out to the dual_ram_init.coe file to initialize data memory

ram_loc = "Working_MP3\\mips.srcs\\sources_1\dual_ram_init.coe"
default = "memory_initialization_radix=16;\n"
s2 = "memory_initialization_vector="

with open(ram_loc, "w") as f:
    f.write(default)
    things = []
    things.append(s2)
    for hex_code in hex_output:
        things.append(hex_code)
    things.append(";")

    f.write(" ".join(things))

# Add the jump instruction at the start of our code
def jump(offset_from_current):
    opcode = information["jmp"][0]
    arg = bin(offset_from_current)[2:].zfill(24)
    return hex(int(opcode + arg, 2))[2:]

#tbj = jump(len(hex_output) + 1)
#hex_output.insert(0, tbj)
hex_output = []

# start assembling the code
if lines[0] == '.code':
    del lines[0]
else:
    print("NO CODE SECTION!")

# Walk through the code and consume all the labels, adding them to the label dictionary
# Labels are addressed by their name, and we return the offset from the start of the code section
labels = {}
count = len(hex_output)
for i, line in enumerate(lines):
    # Labels are on their own line starting with a colon, and only use the first word
    if line[0] == ':':   
        label = line.split(' ')[0][1:]
        labels[label] = count
        del lines[i]
        continue
    count += 1

for line in lines:
    next_hex = ''

    # Process the current instruction
    things = line.split()
    instr = things[0]
    args = things[1:]
    opcode = information[instr][0]

    # if we know about the instruction...
    if instr in information.keys():
        current_bin = ''
        # giant case statement 
        if instr in ['mov', 'add', 'ladd']:
            current_bin = opcode + registers[args[0]] + registers[args[1]]
        elif instr in ['movi','addi']:
            current_bin = opcode + registers[args[0]] + bin(int(args[1]))[2:].zfill(19)
        elif instr in ['lw', 'sw', 'll', 'sl']:
            arg2 = args[1]
            arg2_bin = ''
            # If we are dealing with an exact memory location
            if arg2[0:2] == '0x':
                arg2 = arg2[2:]
                arg2_bin = bin(int(arg2, 16))[2:].zfill(19)
            # If we are dealing with an exact memory location
            elif arg2[0].isdigit():
                arg2_bin = bin(int(arg2))[2:].zfill(19)
            # We are dealing with a variable
            else:
                matches = re.split('[\[ \]]', arg2)
                if len(matches) > 1: # we have a variable with an index
                    variable = matches[0]
                    offset = int(matches[1]) * data[variable][0] + data[variable][1]
                    arg2_bin = str(bin(offset)[2:].zfill(19))
                else: # plain old variable
                    arg2_bin = str(bin(data[arg2][1])[2:].zfill(19))
            current_bin = opcode + registers[args[0]] + arg2_bin
        elif instr in ['jmp', 'beq']:
            jLoc = args[0]
            # if we're jumping to a label
            if jLoc in labels.keys():
                print(jLoc)
                jLoc = (labels[jLoc] - len(hex_output)) * 4
                print(jLoc)
            else: # otherwise we're jumping a set number of instructions
                jLoc = int(jLoc) * 4
            if jLoc < 0:
                jLoc = (2 ** 24) + jLoc
            arg = bin(jLoc)[2:].zfill(24)
            print(arg)
            current_bin = opcode + arg
        if current_bin != '':
            next_hex = hex(int(current_bin.ljust(32, '0'), 2))[2:].zfill(8)
            hex_output.append(next_hex.upper())
    else:
        print("The function " + instr + "does not exist!")


memfile_loc = "Working_MP3\\mips.srcs\\sources_1\\imports\\new\\memfile.dat"

with open(memfile_loc, "w") as f:
    for x in hex_output:
        f.write(x + '\n')