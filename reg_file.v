module regfile(
               input wire       clk,
               input wire       write_enable,
               input wire [2:0] rs1,
               input wire [2:0] rs2,
               input wire [2:0] rd,
               input wire [15:0] write_data,
               output wire [15:0] read1, // this is reading from rs1
               output wire [15:0] read2 // this is for reading from rs2
               );
   reg [15:0] registers [0:7];
   integer    i;
   initial begin
      for (i = 0; i < 8; i = i + 1)
        registers[i] = 16'b0;
   end
   assign read1 = (rs1 == 3'b000) ? 16'b0 : registers[rs1]; // if rs1 == 0th register then save 0 on it
   assign read2 = (rs2 == 3'b000) ? 16'b0 : registers[rs2];

   always @(posedge clk) begin
      if (write_enable && rd != 3'b000) // which enables write only for all registers - rs0
        registers[rd] <= write_data;
   end
endmodule // regfile
