module dmem_tb;

   reg clk;
   reg write_enable;
   reg [15:0] addr;
   reg [15:0] write_data;
   wire [15:0] read_data;

   dmem dut (
             .clk(clk),
             .write_enable(write_enable),
             .addr(addr),
             .write_data(write_data),
             .read_data(read_data)
             );
   initial clk = 0;
   always #5 clk = ~clk;
   initial begin
      $dumpfile("dmem.vcd");
      $dumpvars(0, dmem_tb);

      addr = 16'd0;
      write_data = 16'd42;
      write_enable = 1;

      @(posedge clk);
      #1;
      write_enable = 0;
      $display("addr = %0d",read_data);
      $finish;

   end // initial begin
endmodule // dmem_tb
