module simple_adder (
    input [31:0] a,      // First Operand
    input [31:0] b,      // Second Operand
    output [31:0] sum    // Sum Output
);

    assign sum = a + b;

endmodule
