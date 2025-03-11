module booth_multiplier_3bit (
    input signed [2:0] A, B,
    output reg signed [5:0] Product
);
    reg signed [5:0] P;
    reg [3:0] M, Q;  // Extend multiplicand and multiplier
    reg Q_1;
    integer i;

    always @(*) begin
        // Initialize values
        P = 6'b0;
        M = {A[2], A};  // Sign-extend A
        Q = {B[2], B};  // Sign-extend B
        Q_1 = 1'b0;      // Q[-1] starts as 0

        // Booth's Algorithm for 3-bit multiplication
        for (i = 0; i < 3; i = i + 1) begin
            case ({Q[0], Q_1})  
                2'b01: P = P + (M << i); // Add Multiplicand
                2'b10: P = P - (M << i); // Subtract Multiplicand
            endcase
            Q_1 = Q[0];
            Q = Q >> 1;
        end
    end

    assign Product = P;

endmodule
module kogge_stone_adder_3bit (
    input [2:0] A, B,
    input Cin,
    output [2:0] Sum,
    output Cout
);
    wire [2:0] G, P, C;  // Generate, Propagate, and Carry

    // Step 1: Generate and Propagate
    assign G = A & B;  // Generate
    assign P = A ^ B;  // Propagate

    // Step 2: Compute Carry
    assign C[0] = Cin;
    assign C[1] = G[0] | (P[0] & C[0]);
    assign C[2] = G[1] | (P[1] & G[0]) | (P[1] & P[0] & C[0]);
    assign Cout = G[2] | (P[2] & G[1]) | (P[2] & P[1] & G[0]) | (P[2] & P[1] & P[0] & C[0]);

    // Step 3: Compute Sum
    assign Sum = P ^ C;

endmodule
module kogge_stone_booth (
    input [2:0] A, B,
    input enable,
    output reg [2:0] Sum,
    output reg Carry,
    output reg [5:0] Product
);
    wire [2:0] Sum_KSA;
    wire Carry_KSA;
    wire [5:0] Product_Booth;

    // Kogge-Stone Adder Implementation (3-bit)
    kogge_stone_adder_3bit KSA (.A(A), .B(B), .Cin(1'b0), .Sum(Sum_KSA), .Cout(Carry_KSA));

    // Booth Multiplier Implementation (3-bit)
    booth_multiplier_3bit BM (.A(A), .B(B), .Product(Product_Booth));

    // Selecting operation based on enable signal
    always @(*) begin
        if (enable) begin
            Sum = 3'b000;  // No addition when multiplication is enabled
            Carry = 1'b0;
            Product = Product_Booth;
        end else begin
            Sum = Sum_KSA;
            Carry = Carry_KSA;
            Product = 6'b000000;  // No multiplication when addition is enabled
        end
    end

endmodule
