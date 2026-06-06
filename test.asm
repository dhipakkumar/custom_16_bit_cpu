; test_hazard.asm
LDI R1, 10
ADD R3, R1, R1   ; uses R1 immediately — hazard!
ADD R4, R3, R1   ; uses R3 immediately — hazard!
HALT
