module alu(
           input wire [15:0] a,
           input wire [15:0] b,
           input wire [3:0] op,
           output reg [15:0] result,
           output wire zero_flag // this is for the bne beq ops when you compare two shits and see if the diff is zero or not zero
           );
   assign zero_flag = (result == 16'b0) ? 1'b1 : 1'b0;
   always @(*) begin
      case (op)
        4'b0000: result = a+b;
        4'b0001: result = a-b;
        4'b0010: result = a*b;
        4'b0011: result = ~(a&b);
        4'b0100: result = ~(a|b);
        default: result = 16'b0;
      endcase // case (op)
   end
endmodule
