information = {}
information["movi"] =   ('10000000', 5, 16)
information["mov"]  =   ('00000000', 5,  5)
information["add"]  =   ('00000001', 5,  5)
information["addi"] =   ('10000001', 5, 16)
information["ladd"] =   ('00001000', 5,  5)
information["beq"]  =   ('01001011', 24, 0)
information["jmp"]  =   ('00100000', 24, 0)
information["loop"] =   ('00010000', 19, 5)
information["lw"]   =   ('10000100', 5, 16)
information["sw"]   =   ('10000101', 5, 16)

registers = {
    "$spt" : bin(0)[2:].zfill(5),
    "$ipt" : bin(1)[2:].zfill(5),
    "$zer" : bin(2)[2:].zfill(5),
    "$fpt" : bin(3)[2:].zfill(5),
    "$ctr" : bin(4)[2:].zfill(5),
    "$esr" : bin(5)[2:].zfill(5),
    "$d00" : bin(6)[2:].zfill(5),
    "$d0" : bin(6)[2:].zfill(5),
    "$d1" : bin(7)[2:].zfill(5),
    "$d2" : bin(8)[2:].zfill(5),
    "$d3" : bin(9)[2:].zfill(5),
    "$d4" : bin(10)[2:].zfill(5),
    "$d5" : bin(11)[2:].zfill(5),
    "$d6" : bin(12)[2:].zfill(5),
    "$d7" : bin(13)[2:].zfill(5),
    "$d8" : bin(14)[2:].zfill(5),
    "$d9" : bin(15)[2:].zfill(5),
    "$d10" : bin(16)[2:].zfill(5),
    "$d11" : bin(17)[2:].zfill(5),
    "$d12" : bin(18)[2:].zfill(5),
    "$d13" : bin(19)[2:].zfill(5),
    "$d14" : bin(20)[2:].zfill(5),
    "$d15" : bin(21)[2:].zfill(5),
    "$d16" : bin(22)[2:].zfill(5),
    "$d17" : bin(23)[2:].zfill(5),
    "$d18" : bin(24)[2:].zfill(5),
    "$d19" : bin(25)[2:].zfill(5),
    "$fra" : bin(26)[2:].zfill(5),
    "$flg" : bin(27)[2:].zfill(5)
    }

data = {}
lines = []
data_size_identifiers = { "dword" : 32, "word" : 16, "byte" : 8, "nibble" : 4, "bit" : 1}

# Get all the code without the comments
with open("input.txt") as f:
    for line in f:
        line = line.partition('#')[0].strip()
        if line != '':
            lines.append(line)

binary_tracker = ''

# If there is a data section
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
        data[var_name] = (var_size, offset_from_start)
    
hex_output = []

total_chars = ((len(binary_tracker) // 32) + 1) * 32
binary_tracker = binary_tracker.ljust(total_chars, '0')

# This works - appends all the data to hex_output as nice hex strings in order
while binary_tracker != '':
    current = binary_tracker[:32]
    binary_tracker = binary_tracker[32:]
    to_add = hex(int(current, 2))[2:]
    hex_output.append(to_add.ljust(8, '0'))


# Add the jump instruction at the start of our code
def jump(offset_from_current):
    opcode = information["jmp"][0]
    arg = bin(offset_from_current)[2:].ljust(24, '0')
    return hex(int(opcode + arg, 2))[2:]

tbj = jump(len(hex_output) + 1)
hex_output.insert(0, tbj)

if lines[0] == '.code':
    del lines[0]
else:
    print("NO CODE SECTION!")

# Labels are addressed by their name, and we return the offset from the start of the code section
labels = {}

count = len(hex_output)

for line in lines:
    next_hex = ''
    # Labels are on their own line starting with a colon, and only use the first word
    if line[0] == ':':   
        label = line.split(' ')[0][1:]
        labels[label] = count
        continue

    count += 1

    # Process the current instruction

    things = line.split()
    instr = things[0]
    args = things[1:]
    opcode = information[instr][0]

    if instr in information.keys():
        current_bin = ''
        if instr in ['mov', 'add']:
            current_bin = opcode + registers[args[0]] + registers[args[1]]
        elif instr in ['movi','addi']:
            current_bin = opcode + registers[args[0]] + bin(int(args[1]))[2:].zfill(19)
        elif instr in ['lw', 'sw']:
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
                if '[' in arg2 and ']' in arg2:
                    pass
                else:
                    arg2_bin = str(bin(data[arg2][1])[2:].zfill(19))
            current_bin = opcode + registers[args[0]] + arg2_bin
        if current_bin != '':
            next_hex = hex(int(current_bin.ljust(32, '0'), 2))[2:].zfill(8)
            hex_output.append(next_hex.upper())
            
    else:
        print("The function " + instr + "does not exist!")

with open("output.txt", "w") as f:
    for x in hex_output:
        f.write(x + '\n')