information = {}
information["movi"] =   ('10000001', 5, 16)
information["add"]  =   ('00000010', 5, 5)
information["addi"] =   ('10000011', 5, 16)
information["ladd"] =   ('00001000', 5, 5)
information["beq"]  =   ('01001011', 5, 5)
information["beqi"] =   ('11001100', 5, 16)
information["jmp"]  =   ('00100000', 24, 0)
information["loop"] =   ('00010000', 19, 5)
information["lw"]   =   ('10010001', 5, 16)
information["sw"]   =   ('10010010', 5, 16)

data = {}
lines = []

with open("input.txt") as f:
    for line in f:
        line = line.partition('#')[0].strip()
        if line != '':
            lines.append(line)

if lines[0] == ".data":
    del lines[0]
    while lines[0] != ".code":
        line = lines.pop(0)
        things = line.split(' ')
        var_name = things.pop(0)
        var_size = things.pop(0)
        var_elements = things

