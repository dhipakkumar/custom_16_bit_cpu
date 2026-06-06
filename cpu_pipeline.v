/*
 IF stage:
  - reads PC
  - fetches instruction from imem
  - latches into IF_ID register

ID stage:
  - reads from IF_ID register
  - decodes opcode → control signals
  - reads register file
  - latches into ID_EX register

EX stage:
  - reads from ID_EX register
  - ALU computes result
  - latches into EX_MEM register

MEM stage:
  - reads from EX_MEM register
  - LOAD/STORE to data memory
  - latches into MEM_WB register

WB stage:
  - reads from MEM_WB register
  - writes result back to register file

// IF/ID — carries raw instruction and PC
IF_ID_instruction
IF_ID_pc

// ID/EX — carries decoded values and control signals
ID_EX_pc
ID_EX_read1      // register file output rs1
ID_EX_read2      // register file output rs2
ID_EX_imm8       // immediate for LDI
ID_EX_rd         // destination register
ID_EX_rs1        // source reg 1 (needed for forwarding)
ID_EX_rs2        // source reg 2 (needed for forwarding)
ID_EX_alu_op     // which ALU operation
ID_EX_alu_src    // register or immediate
ID_EX_reg_write  // should we write to register?
ID_EX_mem_read   // is this a LOAD?
ID_EX_mem_write  // is this a STORE?
ID_EX_is_branch  // is this a branch?
ID_EX_opcode     // needed for branch type

// EX/MEM — carries ALU result and control signals
EX_MEM_alu_result
EX_MEM_read2     // for STORE — value to write to memory
EX_MEM_rd
EX_MEM_zero_flag
EX_MEM_reg_write
EX_MEM_mem_read
EX_MEM_mem_write

// MEM/WB — carries data to write back
MEM_WB_data      // either ALU result or memory read data
MEM_WB_rd
MEM_WB_reg_write
MEM_WB_mem_read  // needed to select correct writeback data
MEM_WB_alu_result
 */
module cpu_pipeline(
                    input wire clk,
                    input wire reset
                    );
   reg [15:0] pc; // program counter

   reg [15:0] IF_ID_instruction;
   reg [15:0] IF_ID_pc;

   reg [15:0] ID_EX_read1, ID_EX_read2;
   reg [7:0]  ID_EX_imm8;
   reg [2:0]  ID_EX_rd, ID_EX_rs1, ID_EX_rs2;
   reg [3:0]  ID_EX_alu_op;
   reg [3:0]  ID_EX_opcode;
   reg        ID_EX_alu_src;
   reg        ID_EX_reg_write, ID_EX_mem_read;
   reg        ID_EX_mem_write, ID_EX_is_branch;

   reg [15:0] EX_MEM_alu_result, EX_MEM_read2;
   reg [2:0]  EX_MEM_rd;
   reg        EX_MEM_zero_flag;
   reg        EX_MEM_reg_write, EX_MEM_mem_read, EX_MEM_mem_write;

   reg [15:0] MEM_WB_alu_result, MEM_WB_mem_data;
   reg [2:0]  MEM_WB_rd;
   reg        MEM_WB_reg_write, MEM_WB_mem_read;

   wire [15:0] instruction;
   wire [15:0] rf_read1, rf_read2;
   wire [15:0] alu_result;
   wire        zero_flag;
   wire [15:0] mem_read_data;


   wire [3:0] opcode  = IF_ID_instruction[15:12];
   wire [2:0] rd      = IF_ID_instruction[11:9];
   wire [2:0] rs1     = IF_ID_instruction[8:6];
   wire [2:0] rs2     = IF_ID_instruction[5:3];
   wire [7:0] imm8    = IF_ID_instruction[7:0];
   wire [5:0] offset6 = IF_ID_instruction[5:0];
   wire [11:0] addrj  = IF_ID_instruction[11:0];

   reg reg_write, mem_read, mem_write;
   reg alu_src, is_branch, is_halt;
   reg [3:0] alu_op;

   wire [15:0] alu_b = ID_EX_alu_src ? {8'b0, ID_EX_imm8} : ID_EX_read2;
   wire [15:0] wb_data = MEM_WB_mem_read ? MEM_WB_mem_data : MEM_WB_alu_result;

   imem imem0 (
               .addr(pc),
               .instruction(instruction)
               );

   regfile rf0 (
                .clk(clk),
                .write_enable(MEM_WB_reg_write),
                .rs1(rs1),
                .rs2(rs2),
                .rd(MEM_WB_rd),
                .write_data(wb_data),
                .read1(rf_read1),
                .read2(rf_read2)
                );

   alu alu0 (
             .a(ID_EX_read1),
             .b(alu_b),
             .op(ID_EX_alu_op),
             .result(alu_result),
             .zero_flag(zero_flag)
             );

   dmem dmem0 (
               .clk(clk),
               .write_enable(EX_MEM_mem_write),
               .addr(EX_MEM_alu_result),
               .write_data(EX_MEM_read2),
               .read_data(mem_read_data)
               );

   always @(posedge clk) begin
      if (reset) begin
         pc <= 16'b0;
         IF_ID_instruction <= 16'b0;
         IF_ID_pc <= 16'b0;
      end else begin
         IF_ID_instruction <= instruction;
         IF_ID_pc <= pc;
         pc <= pc + 1;
      end
   end // always @ (posedge clk)


   always @(*) begin
      reg_write = 0; mem_read = 0; mem_write = 0;
      alu_src = 0; is_branch = 0; is_halt = 0;
      alu_op = 4'b0000;

      case (opcode)
        4'b0000: begin reg_write=1; alu_op=4'b0000; end  // ADD
        4'b0001: begin reg_write=1; alu_op=4'b0001; end  // SUB
        4'b0010: begin reg_write=1; alu_op=4'b0010; end  // MUL
        4'b0011: begin reg_write=1; alu_op=4'b0011; end  // NAND
        4'b0100: begin reg_write=1; alu_op=4'b0100; end  // NOR
        4'b0101: begin reg_write=1; alu_op=4'b0000; end  // MOV
        4'b1100: begin reg_write=1; alu_src=1;      end  // LDI
        4'b0110: begin reg_write=1; mem_read=1;     end  // LOAD
        4'b0111: begin mem_write=1;                 end  // STORE
        4'b1000: begin is_branch=1;                 end  // JMP
        4'b1001: begin is_branch=1; alu_op=4'b0001; end  // BEQ
        4'b1010: begin is_branch=1; alu_op=4'b0001; end  // BNE
        4'b1011: begin is_halt=1;                   end  // HALT
      endcase
   end // always @ (*)

   always @(posedge clk) begin
      if (reset) begin
         ID_EX_read1    <= 0; ID_EX_read2  <= 0;
         ID_EX_imm8     <= 0; ID_EX_rd     <= 0;
         ID_EX_rs1      <= 0; ID_EX_rs2    <= 0;
         ID_EX_alu_op   <= 0; ID_EX_alu_src <= 0;
         ID_EX_reg_write <= 0; ID_EX_mem_read <= 0;
         ID_EX_mem_write <= 0; ID_EX_is_branch <= 0;
         ID_EX_opcode   <= 0;
      end else begin
         ID_EX_read1    <= rf_read1;
         ID_EX_read2    <= rf_read2;
         ID_EX_imm8     <= imm8;
         ID_EX_rd       <= rd;
         ID_EX_rs1      <= rs1;
         ID_EX_rs2      <= rs2;
         ID_EX_alu_op   <= alu_op;
         ID_EX_alu_src  <= alu_src;
         ID_EX_reg_write <= reg_write;
         ID_EX_mem_read  <= mem_read;
         ID_EX_mem_write <= mem_write;
         ID_EX_is_branch <= is_branch;
         ID_EX_opcode    <= opcode;
      end // else: !if(reset)
   end // always @ (posedge clk)

   always @(posedge clk) begin
      if (reset) begin
         EX_MEM_alu_result <= 0; EX_MEM_read2  <= 0;
         EX_MEM_rd         <= 0; EX_MEM_zero_flag <= 0;
         EX_MEM_reg_write  <= 0; EX_MEM_mem_read <= 0;
         EX_MEM_mem_write  <= 0;
      end else begin
         EX_MEM_alu_result <= alu_result;
         EX_MEM_read2      <= ID_EX_read2;
         EX_MEM_rd         <= ID_EX_rd;
         EX_MEM_zero_flag  <= zero_flag;
         EX_MEM_reg_write  <= ID_EX_reg_write;
         EX_MEM_mem_read   <= ID_EX_mem_read;
         EX_MEM_mem_write  <= ID_EX_mem_write;
      end // else: !if(reset)
   end // always @ (posedge clk)


   always @(posedge clk) begin
      if (reset) begin
         MEM_WB_alu_result <= 0; MEM_WB_mem_data <= 0;
         MEM_WB_rd         <= 0; MEM_WB_reg_write <= 0;
         MEM_WB_mem_read   <= 0;
      end else begin
         MEM_WB_alu_result <= EX_MEM_alu_result;
         MEM_WB_mem_data   <= mem_read_data;
         MEM_WB_rd         <= EX_MEM_rd;
         MEM_WB_reg_write  <= EX_MEM_reg_write;
         MEM_WB_mem_read   <= EX_MEM_mem_read;
      end // else: !if(reset)
   end // always @ (posedge clk)

endmodule
