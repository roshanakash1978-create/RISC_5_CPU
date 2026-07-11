// cpu_top.v
`timescale 1ns / 1ps

module cpu_top(
    input  wire        clk,
    input  wire        reset,
    output wire [31:0] x1,
    output wire [31:0] x2,
    output wire [31:0] x3,
    output wire [31:0] pc_out,
    output wire [31:0] instr_out,
    output wire [31:0] alu_out,
    output wire        reg_write_out
);
    wire [31:0] pc;
    reg  [31:0] pc_next;
    wire [31:0] instr;
    wire [6:0] opcode = instr[6:0];
    wire [2:0] funct3 = instr[14:12];
    wire [6:0] funct7 = instr[31:25];
    wire [4:0] rd     = instr[11:7];
    wire [4:0] rs1    = instr[19:15];
    wire [4:0] rs2    = instr[24:20];
    wire [31:0] imm_i = {{20{instr[31]}}, instr[31:20]};
    wire [31:0] imm_b = {{19{instr[31]}},
                         instr[31],
                         instr[7],
                         instr[30:25],
                         instr[11:8],
                         1'b0};
    wire [31:0] imm_s = {{20{instr[31]}},
                         instr[31:25],
                         instr[11:7]};
    wire [31:0] imm_j = {{11{instr[31]}},
                         instr[31],
                         instr[19:12],
                         instr[20],
                         instr[30:21],
                         1'b0};
    wire [31:0] imm_u = {instr[31:12], 12'b0};
    wire [31:0] rd1;
    wire [31:0] rd2;
    wire [31:0] write_data;
    wire reg_write;
    reg  [31:0] alu_out_r;
    reg         reg_write_r;
    reg         mem_to_reg;
    wire [31:0] mem_read_data;
    wire mem_write;
    reg mem_write_r;
    pc PC0 (
        .clk(clk),
        .reset(reset),
        .pc_next(pc_next),
        .pc(pc)
    );
    instr_mem IMEM (
        .addr(pc),
        .instr(instr)
    );
    regfile RF (
        .clk(clk),
        .rs1(rs1),
        .rs2(rs2),
        .rd1(rd1),
        .rd2(rd2),
        .rd(rd),
        .wd(write_data),
        .reg_write(reg_write)
    );
    data_mem DMEM (
        .clk(clk),
        .mem_write(mem_write),
        .addr(alu_out_r),
        .write_data(rd2),
        .read_data(mem_read_data)
    );
    always @(*) 
      begin
        alu_out_r   = 32'd0;
        reg_write_r = 1'b0;
        mem_to_reg  = 1'b0;
        pc_next     = pc + 32'd4;
        mem_write_r = 1'b0;
        case (opcode)
            7'b0010011: begin
                if (funct3 == 3'b000) 
                  begin 
                    alu_out_r   = rd1 + imm_i;
                    reg_write_r = 1'b1;
                end 
              else if (funct3 == 3'b111) 
                  begin 
                    alu_out_r   = rd1 & imm_i;
                    reg_write_r = 1'b1;
                end 
              else if (funct3 == 3'b110) 
                  begin 
                    alu_out_r   = rd1 | imm_i;
                    reg_write_r = 1'b1;
                end 
              else if (funct3 == 3'b100) 
                  begin
                    alu_out_r   = rd1 ^ imm_i;
                    reg_write_r = 1'b1;
                  end 
              else if (funct3 == 3'b010) 
                    begin
                    alu_out_r   = ($signed(rd1) < $signed(imm_i)) ? 32'd1 : 32'd0;
                    reg_write_r = 1'b1;
                end 
              else if (funct3 == 3'b011) 
                  begin 
                    alu_out_r   = (rd1 < imm_i) ? 32'd1 : 32'd0;
                    reg_write_r = 1'b1;
                end
            end
            7'b0110011: begin
                if (funct3 == 3'b000 && funct7 == 7'b0000000) 
                  begin
                    alu_out_r   = rd1 + rd2; 
                    reg_write_r = 1'b1;
                end 
              else if (funct3 == 3'b000 && funct7 == 7'b0100000) 
                  begin
                    alu_out_r   = rd1 - rd2; 
                    reg_write_r = 1'b1;
                end 
              else if (funct3 == 3'b111) 
                  begin
                    alu_out_r   = rd1 & rd2; 
                    reg_write_r = 1'b1;
                end 
              else if (funct3 == 3'b110) 
                  begin
                    alu_out_r   = rd1 | rd2; 
                    reg_write_r = 1'b1;
                end 
              else if (funct3 == 3'b100) 
                  begin
                    alu_out_r   = rd1 ^ rd2; 
                    reg_write_r = 1'b1;
                end 
              else if (funct3 == 3'b001) 
                  begin
                    alu_out_r   = rd1 << rd2[4:0]; 
                    reg_write_r = 1'b1;
                end 
              else if (funct3 == 3'b101 && funct7 == 7'b0000000) 
                  begin
                    alu_out_r   = rd1 >> rd2[4:0]; 
                    reg_write_r = 1'b1;
                end 
              else if (funct3 == 3'b101 && funct7 == 7'b0100000) 
                  begin
                    alu_out_r   = $signed(rd1) >>> rd2[4:0]; 
                    reg_write_r = 1'b1;
                end
            end
            7'b1100011: 
              begin
                if (funct3 == 3'b000) 
                  begin 
                    if (rd1 == rd2)
                        pc_next = pc + imm_b;
                end 
                else if (funct3 == 3'b001) 
                  begin 
                    if (rd1 != rd2)
                        pc_next = pc + imm_b;
                end 
                else if (funct3 == 3'b100) 
                  begin 
                        if ($signed(rd1) < $signed(rd2))
                            pc_next = pc + imm_b;
                end 
                else if (funct3 == 3'b101) 
                  begin 
                        if ($signed(rd1) >= $signed(rd2))
                            pc_next = pc + imm_b;
                end 
                else if (funct3 == 3'b110) 
                begin 
                        if (rd1 < rd2)
                            pc_next = pc + imm_b;
                end 
                else if (funct3 == 3'b111) 
                begin 
                        if (rd1 >= rd2)
                            pc_next = pc + imm_b;
                end
                reg_write_r = 1'b0;
            end
            7'b0000011: 
            begin
                if (funct3 == 3'b010) 
                begin
                    alu_out_r   = rd1 + imm_i; 
                    reg_write_r = 1'b1;
                    mem_to_reg  = 1'b1;
                end
            end
            7'b0100011: 
            begin   
                if (funct3 == 3'b010) 
                begin 
                    alu_out_r    = rd1 + imm_s;  
                    mem_write_r = 1'b1;          
                    reg_write_r = 1'b0;          
                    mem_to_reg  = 1'b0;          
                end
            end
            7'b1101111: 
            begin
                alu_out_r   = pc + 32'd4;   
                reg_write_r = 1'b1;         
                mem_to_reg  = 1'b0;         
                pc_next     = pc + imm_j;   
            end
            7'b1100111: 
            begin
                if (funct3 == 000) 
                begin
                    alu_out_r   = pc + 32'd4;   
                    reg_write_r = 1'b1;         
                    mem_to_reg  = 1'b0;         
                    pc_next     = (rd1 + imm_i) & ~32'd1;   
                end
            end
            7'b0110111: 
            begin 
                alu_out_r   = imm_u;
                reg_write_r = 1'b1;
            end   
            7'b0010111: 
            begin
                alu_out_r   = pc + imm_u;
                reg_write_r = 1'b1;
            end
        endcase
    end
    assign write_data = mem_to_reg ? mem_read_data : alu_out_r;
    assign reg_write  = reg_write_r;
    assign mem_write = mem_write_r;
    assign x1 = RF.regs[1];
    assign x2 = RF.regs[2];
    assign x3 = RF.regs[3];
    assign pc_out        = pc;
    assign instr_out     = instr;
    assign alu_out       = alu_out_r;
    assign reg_write_out = reg_write_r;
endmodule
