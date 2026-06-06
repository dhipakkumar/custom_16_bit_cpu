/*
ADD   0000    reg_write=1, alu_op=ADD
SUB   0001    reg_write=1, alu_op=SUB
MUL   0010    reg_write=1, alu_op=MUL
NAND  0011    reg_write=1, alu_op=NAND
NOR   0100    reg_write=1, alu_op=NOR
MOV   0101    reg_write=1, alu_op=passthrough
LDI   1100    reg_write=1, alu_src=immediate
LOAD  0110    reg_write=1, mem_read=1
STORE 0111    mem_write=1
JMP   1000    branch=1
BEQ   1001    branch=1, alu_op=SUB (compare by subtracting)
BNE   1010    branch=1, alu_op=SUB
HALT  1011    halt=1
*/
module cpu(
           input wire clk,
           input wire reset
           );
   reg [15:0] pc; // 16 bit program counter

   // assigning the bit wise fields for the opcodes registers etc
   wire [15:0] instruction;
   wire [3:0]  opcode = instruction[15:12];
   wire [2:0]  rd = instruction[11:9];
   wire [2:0]  rs1 = instruction[8:6];
   wire [2:0]  rs2 = instruction[5:3];
   wire [7:0]  imm8    = instruction[7:0];   // for LDI load immediate load the constant value present in the instruction to the register
   wire [11:0] addrj  = instruction[11:0];  // for JMP
   wire [5:0]  offset6 = instruction[5:0];   // for BEQ/BNE
   wire [2:0] branch_rs1 = instruction[11:9];
   wire [2:0] branch_rs2 = instruction[8:6];

   // main control signals
   reg         reg_write;
   reg         mem_read;
   reg         mem_write;
   reg         alu_src;
   reg         is_branch;
   reg         is_halt;
   reg [3:0]   alu_op;

   // wires connecting to the modules
   wire [15:0] read1, read2;
   wire [15:0] alu_result;
   wire        zero_flag;
   wire [15:0] mem_read_data;


   wire [15:0] alu_b = alu_src ? {8'b0, imm8} : read2;
   wire [15:0] write_data = mem_read ? mem_read_data : alu_result;
   wire [2:0] alu_rs1 = is_branch ? branch_rs1 : rs1;
   wire [2:0] alu_rs2 = is_branch ? branch_rs2 : rs2;
   // then importing those shitty ahh things that i wrote for gods sake this is gonna be a pain

   imem imem0(
              .addr(pc),
              .instruction(instruction)
              );
   regfile rf0(
               .clk(clk),
               .write_enable(reg_write),
               .rs1(alu_rs1),      // use muxed version
               .rs2(alu_rs2),      // use muxed version
               .rd(rd),
               .write_data(write_data),
               .read1(read1),
               .read2(read2)
               );
   alu alu0(
            .a(read1),
            .b(alu_b),
            .op(alu_op),
            .result(alu_result),
            .zero_flag(zero_flag)
            );
   dmem dmem0(
              .clk(clk),
              .write_enable(mem_write),
              .addr(alu_result),
              .write_data(read2),
              .read_data(mem_read_data)
              );

   always @(*) begin
      // make sure that all of the signals are set to default values aka 0
      reg_write = 0;
      mem_read = 0;
      mem_write = 0;
      alu_src   = 0;
      is_branch = 0;
      is_halt   = 0;
      alu_op    = 4'b0000;

      case (opcode)
        4'b0000: begin reg_write=1; alu_op=4'b0000; end  // ADD
        4'b0001: begin reg_write=1; alu_op=4'b0001; end  // SUB
        4'b0010: begin reg_write=1; alu_op=4'b0010; end  // MUL
        4'b0011: begin reg_write=1; alu_op=4'b0011; end  // NAND
        4'b0100: begin reg_write=1; alu_op=4'b0100; end  // NOR
        4'b0101: begin reg_write=1; alu_op=4'b0000; end  // MOV (rs2=R0 so result=rs1)
        4'b1100: begin reg_write=1; alu_src=1;      end  // LDI
        4'b0110: begin reg_write=1; mem_read=1;     end  // LOAD
        4'b0111: begin mem_write=1;                 end  // STORE
        4'b1000: begin is_branch=1;                 end  // JMP
        4'b1001: begin is_branch=1; alu_op=4'b0001; end  // BEQ
        4'b1010: begin is_branch=1; alu_op=4'b0001; end  // BNE
        4'b1011: begin is_halt=1;                   end  // HALT
      endcase // case (opcode)
   end // always @ (*)

   always @(posedge clk) begin
      if (reset) begin
         pc <= 16'b0;
      end else if (is_halt) begin
         pc <= pc; // this would apparently freeze the cpu cool shit
      end else if (opcode == 4'b1000) begin // this is a JMP instruction
         pc <= {4'b0, addrj};
      end else if (opcode == 4'b1001) begin // this is a BEQ instruction
         pc <= pc + {{10{offset6[5]}}, offset6};
      end else if (opcode == 4'b1010 && !zero_flag) begin // this is a BNE instruction
         pc <= pc + {{10{offset6[5]}}, offset6};
      end else begin
         pc <= pc+1;
      end
   end // always @ (posedge clk)
endmodule // cpu
