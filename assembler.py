#!/usr/bin/env python3

import sys

REGISTERS = {
    'R0':0,
    'R1':1,
    'R2':2,
    'R3':3,
    'R4':4,
    'R5':5,
    'R6':6,
    'R7':7
}

OPCODES = {
    'ADD': 0b0000,
    'SUB': 0b0001,
    'MUL': 0b0010,
    'NAND': 0b0011,
    'NOR': 0b0100,
    'MOV': 0b0101,
    'LOAD': 0b0110,
    'STORE': 0b0111,
    'JMP': 0b1000,
    'BEQ': 0b1001,
    'BNE': 0b1010,
    'HALT': 0b1011,
    'LDI': 0b1100,
}

def parse_reg(s):
    s = s.strip().rstrip(',').upper()
    if s not in REGISTERS:
        raise ValueError(f"Unknown register:{s}")
    return REGISTERS[s]

def parse_imm(s, bits):
    s = s.strip()
    val = int(s,0)

    if val < 0:
        val = val & ((1<<bits)-1)
    if val >= (1<<bits):
        raise ValueError(f"Immediate {val} too large for {bits} bits")
    return val

def parse_addr(s):
    s = s.strip()
    if s.startswith('[') and s.endswith(']'):
        return parse_reg(s[1:-1])
    raise ValueError(f"Expected [Rx], got {s}")

def assemble(lines):
    output =[]

    for lineno, line in enumerate(lines, 1):
        line = line.split(';')[0].strip()
        if not line:
            continue

        parts = line.replace(',', ' ').split()
        mnemonic = parts[0].upper()

        if mnemonic not in OPCODES:
            raise ValueError(f"Line {lineno}: unknown instructions'{mnemonic}'")

        op = OPCODES[mnemonic]
        instructions = 0

        if mnemonic in ('ADD', 'SUB', 'MUL', 'NAND', 'NOR'):
            rd = parse_reg(parts[1])
            rs1 = parse_reg(parts[2])
            rs2 = parse_reg(parts[3])
            instructions = (op << 12) | (rd << 9) | (rs1 << 6) | (rs2 << 3)

        elif mnemonic == "MOV":
            rd = parse_reg(parts[1])
            rs1 = parse_reg(parts[2])
            instructions = (op<<12) | (rd<<9) | (rs1<<6)
        elif mnemonic == 'LDI':
            rd  = parse_reg(parts[1])
            imm = parse_imm(parts[2], 8)
            instructions = (op << 12) | (rd << 9) | imm

        elif mnemonic == 'LOAD':
            rd  = parse_reg(parts[1])
            rs  = parse_addr(parts[2])
            instructions = (op << 12) | (rd << 9) | (rs << 6)

        elif mnemonic == 'STORE':
            rs  = parse_reg(parts[1])
            rd  = parse_addr(parts[2])
            instructions = (op << 12) | (rd << 9) | (rs << 6)

        elif mnemonic == 'JMP':
            addr = parse_imm(parts[1], 12)
            instructions = (op << 12) | addr

        elif mnemonic == 'BEQ':
            rs1    = parse_reg(parts[1])
            rs2    = parse_reg(parts[2])
            offset = parse_imm(parts[3], 6)
            instructions  = (op << 12) | (rs1 << 9) | (rs2 << 6) | offset

        elif mnemonic == 'BNE':
            rs1    = parse_reg(parts[1])
            rs2    = parse_reg(parts[2])
            offset = parse_imm(parts[3], 6)
            instructions  = (op << 12) | (rs1 << 9) | (rs2 << 6) | offset

        elif mnemonic == 'HALT':
            instructions = (op << 12)

        output.append(f"{instructions:04X}")

    return output


if len(sys.argv) != 3:
    print("Usage: python3 assembler.py program.asm program.hex")
    sys.exit(1)

input_file = sys.argv[1]
output_file = sys.argv[2]

with open(input_file, "r") as f:
    lines = f.readlines()

try:
    hex_output = assemble(lines)
except ValueError as e:
    print(f"Assembler error:{e}")
    sys.exit(1)

with open(output_file, 'w') as f:
    for line in hex_output:
        f.write(line + '\n')

print(f"assembled {len(hex_output)} instructions to {output_file}")
for i, h in enumerate(hex_output):
    print(f"[{i}] {h}")
