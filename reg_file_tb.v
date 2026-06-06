module regfile_tb;
   reg clk;
   reg write_enable;
   reg [2:0] rs1, rs2, rd;
   reg [15:0] write_data;
   wire [15:0] read1, read2;

   regfile dut (
               .clk(clk),
               .write_enable(write_enable),
               .rs1(rs1),
               .rs2(rs2),
               .rd(rd),
               .write_data(write_data),
               .read1(read1),
               .read2(read2)
               );
   initial clk = 0;
   always #5 clk = ~clk;

   initial begin
      $dumpfile("regfile.vcd");
      $dumpvars(0, regfile_tb);

      write_enable = 0;
      rs1 = 0;
      rs2 = 0;
      rd = 0;
      write_data = 0;
      #2;

      rd = 3'd1;
      write_data = 16'd42;
      write_enable = 1;
      @(posedge clk);
      #1;
      rs1 = 3'd1;
      $display("r1 = %0d", read1);

      rd = 3'd2;
      write_data = 16'd100;
      write_enable = 1;
      @(posedge clk);
      #1;

      rd = 3'd3;
      write_data = 16'd200;
      write_enable = 1;
      @(posedge clk);
      #1;
      rs1 = 3'd2;
      rs2 = 3'd3;
      #1;
      $display("r2 = %0d, r3 = %0d", read1, read2);


      rd = 3'd0;
      write_data = 16'd999;
      write_enable = 1;


        // // ── Test 3: try writing to R0, should stay 0 ──
        // rd = 3'd0; write_data = 16'd999; write_enable = 1;
        // @(posedge clk); #1;
        // rs1 = 3'd0;
        // #1;
        // $display("T3: R0 = %0d  (expect 0, R0 hardwired)", read1);

        // // ── Test 4: write_enable=0, nothing should change ──
        // rd = 3'd4; write_data = 16'd555; write_enable = 0;
        // @(posedge clk); #1;
        // rs1 = 3'd4;
        // #1;
        // $display("T4: R4 = %0d  (expect 0, write disabled)", read1);

        // // ── Test 5: overwrite R1 with new value ──
        // rd = 3'd1; write_data = 16'd777; write_enable = 1;
        // @(posedge clk); #1;
        // rs1 = 3'd1;
        // #1;
        // $display("T5: R1 = %0d  (expect 777, overwritten)", read1);

        // // ── Test 6: read two different regs simultaneously ──
        // rs1 = 3'd1; rs2 = 3'd2;
        // #1;
        // $display("T6: R1 = %0d  R2 = %0d  (expect 777, 100)", read1, read2);

        $finish;
    end

endmodule
