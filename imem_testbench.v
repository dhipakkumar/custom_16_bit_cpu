module imem_tb;

   reg [15:0] addr;
   wire [15:0] instruction;
   imem dut(
            .addr(addr),
            .instruction(instruction)
            );
   initial begin
      $dumpfile("instruction_mem.vcd");
      $dumpvars(0,imem_tb);
      addr = 16'b0;
      #10;
      $display("instruction at %0d = %h", addr, instruction);
      addr = 16'b1;
      #10;
      $display("instruction at %0d = %h", addr, instruction);

   end
endmodule // imem_tb
