module imem(
            input wire [15:0]  addr,
            output wire [15:0] instruction
            );
   reg [15:0] mem [0:255];
   initial begin
      // mem[0] = 16'hAAAA;
      // mem[1] = 16'hBBBB;
      // mem[2] = 16'hCCCC;
      // mem[3] = 16'hDDDD;
      // mem[0] = 16'hC20A;
      // mem[1] = 16'hC414;
      // mem[2] = 16'h0650;
      // mem[3] = 16'hB000;
      // mem[4] = 16'hB000;
      // mem[5] = 16'hB000;
      $readmemh("out.hex",mem);
   end
   assign instruction = mem[addr];

endmodule // imen
