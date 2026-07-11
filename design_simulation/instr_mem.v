`timescale 1ns / 1ps

module instr_mem(
    input  wire [31:0] addr,
    output wire [31:0] instr
);

    reg [31:0] mem [0:255];
    integer i;

    initial begin
        mem[0]  = 32'h00A00093;
        mem[1]  = 32'hFFF00113;
        mem[2]  = 32'h00209193;
        mem[3]  = 32'h00215213;
        mem[4]  = 32'h40215293;
        mem[5]  = 32'h00112333;
        mem[6]  = 32'h001133B3;
        mem[7]  = 32'h00100413;
        mem[8]  = 32'h00640463;
        mem[9]  = 32'h0FF00193;
        mem[10] = 32'h00100493;

        for (i = 11; i < 256; i = i + 1)
            mem[i] = 32'h00000013;
    end

    assign instr = mem[addr[9:2]];

endmodule
