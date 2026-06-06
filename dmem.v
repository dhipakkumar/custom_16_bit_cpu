module dmem(
            input wire         clk,
            input wire         write_enable,
            input wire [15:0]  addr,
            input wire [15:0]  write_data,
            output wire [15:0] read_data
            );

   reg [15:0] mem [0:255];
   assign read_data = mem[addr];

   always @(posedge clk) begin
      if (write_enable)
        mem[addr] <= write_data;
   end
endmodule // dmem
