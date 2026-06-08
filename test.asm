; test_branch.asm
LDI R1, 3
LDI R2, 1
SUB R1, R1, R2
BNE R1, R3, -1
HALT
