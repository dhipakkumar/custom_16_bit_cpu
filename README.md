# readme
this is a ongoing project done by crypticwrath77 on a custom 16 bit cpu which is gonna run doom hehehe

so basically the cpu would get the hexcode instructions from the `out.hex` file which is from the `test.asm` file converted to hexcode as per the ISA instructions that ive described in the `assembler.py`

this would go through all of the insturction present in the out.hex and run it accordingly 

this was compiled using iverilog and the commands are as follows 

```bash
iverilog -o sim cpu.v alu.v reg_file.v instruction_memory.v dmem.v cpu_tb.v
```

then use `vvp` to test out the simulation
```bash
vvp sim
```

for finding out the waveforms you can use `gtkwave` and if youre using a mac my sincere condolences cause fixing this would be a pain in the ass 

anyways there are lots more to come for this
1. i need to add a pipeline for the instructions so that all the instructions are run efficiently under less clock cycles.
2. this is a long term idea but since doom is a 32 bit written C game i might need to change the entire thing but that is something future crypticwrath77 should think about

anyways thats it bye bye imma sleep now
