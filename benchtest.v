module alu_tb;
    reg  [15:0] a;
    reg  [15:0] b;
    reg  [3:0]  op;
    wire [15:0] result;
    wire zero_flag;
    alu dut (
        .a(a),
        .b(b),
        .op(op),
        .result(result),
         .zero_flag(zero_flag)
    );

    initial begin
        $dumpfile("alu.vcd");
        $dumpvars(0, alu_tb);

        // ── ADD tests ──
        op = 4'b0000;
        a = 16'd10;   b = 16'd5;    #10;
        $display("ADD  %0d + %0d = %0d  (expect 15)",  a, b, result);

        a = 16'd1000; b = 16'd2000; #10;
        $display("ADD  %0d + %0d = %0d  (expect 3000)", a, b, result);

        a = 16'd65535; b = 16'd1;   #10;
        $display("ADD  overflow: %0d + %0d = %0d  (expect 0 wraparound)", a, b, result); // here zero_flag set to one?

        // ── SUB tests ──
        op = 4'b0001;
        a = 16'd20;  b = 16'd8;    #10;
        $display("SUB  %0d - %0d = %0d  (expect 12)",  a, b, result);

        a = 16'd5;   b = 16'd10;   #10;
        $display("SUB  %0d - %0d = %0d  (expect 65531 underflow)", a, b, result);

        a = 16'd100; b = 16'd100;  #10;
        $display("SUB  %0d - %0d = %0d  (expect 0)",   a, b, result); // also check if the zero_flag is set to 1 maybe?

       // mul
       op = 4'b0010;
       a = 16'd2;
       b = 16'd19;
       #10;
       $display("MUL %0d*%0d = %0d (2*19)", a, b, result);

       a = 16'd0;
       b = 16'd0;
       #10;
       $display("MUL %0d*%0d = %0d (0*0)", a, b, result); // check for zero_flag here too

       op = 4'b0011;
       a = 16'd10;
       b = 16'd11;
       #10;
       $display("NAND %0d, %0d = %0d", a,b,result);



        // ── default case ──
        op = 4'b1111;
        a = 16'd999; b = 16'd999;  #10;
        $display("DEF  op=1111 result = %0d  (expect 0)", result);

        $finish;
    end

endmodule
