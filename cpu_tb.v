module cpu_tb;
   reg clk;
   reg reset;

   cpu dut(
           .clk(clk),
           .reset(reset)
           );
   initial clk = 0;
   always #5 clk = ~clk;

   initial begin
      $dumpfile("cpu.vcd");
      $dumpvars(0, cpu_tb);

      reset = 1;
      @(posedge clk);
      #1;
      @(posedge clk);
      #1;
      reset = 0;
      repeat(10) begin
         @(posedge clk); #1;
         $display("PC=%0d | IF=%h | R1=%0d R2=%0d R3=%0d R4=%0d R5=%0d",
                  dut.pc,
                  dut.instruction,
                  dut.rf0.registers[1],
                  dut.rf0.registers[2],
                  dut.rf0.registers[3],
                  dut.rf0.registers[4],
                  dut.rf0.registers[5]
                  );
         // $display("PC=%0d | instr=%h | R1=%0d R2=%0d R3=%0d | zero=%b",
         //          dut.pc,
         //          dut.instruction,
         //          dut.rf0.registers[1],
         //          dut.rf0.registers[2],
         //          dut.rf0.registers[3],
         //          dut.zero_flag
         //          );
      end

      $finish;
   end // initial begin

endmodule // cpu_tb
