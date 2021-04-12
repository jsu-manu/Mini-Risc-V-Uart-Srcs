`timescale 1ns / 1ps

typedef enum bit[2:0] {
    NONE=0, READ=1, WRITE=2, HASH=3, CHECK=4
    } photon_opcode;
typedef enum bit[1:0] {
    WAIT=0, INPUT=1, EXEC=2, OUTPUT=3
    } photon_state;
    
interface photon_bus (
        input  logic clk,
        input  logic rst // Reset all registers to 0
    );
    photon_opcode opcode;
    logic [ 2:0] addr; // 8 inputs regs, 8 output regs
    logic [31:0] data_in; // Data to be written
    logic [31:0] data_out; // Output of last read register
    logic ready;
endinterface

module photon(photon_bus bus); 
    
    logic [31:0] reg_input [7:0];
    logic [31:0] reg_output [7:0];
    photon_state state;
    integer register_index;
        
    assign bus.ready = (state == WAIT);
    assign bus.data_out = bus.opcode == READ ? reg_output[bus.addr] : bus.opcode == CHECK ? { 31'h00000000, bus.ready } : 32'h00000000;
    
    logic lwh_clk, lwh_init, lwh_nReset, lwh_nBlock;
    logic [31:0] lwh_input, lwh_output;
    logic lwh_outReady;

    lwh lwh0(lwh_clk, lwh_init, lwh_nReset, lwh_nBlock,
        lwh_input, lwh_output, lwh_outReady);
        
    assign lwh_clk = bus.clk;
//    assign lwh_nReset = !bus.rst;
    assign lwh_input = register_index < 8 ? reg_input[register_index] : 32'h00000000;
    
    always_ff @(posedge bus.clk) begin
        if (bus.rst) begin
            // Reset
            for (int i = 0; i <= $size(reg_input); i++)
                reg_input[i] <= 32'h0000;
            for (int i = 0; i <= $size(reg_output); i++)
                reg_output[i] <= 32'h0000;
            state = WAIT;
            register_index = 0;
            lwh_nBlock = 0;
            lwh_init = 0;
            lwh_nReset = 0;
        end
        else if (bus.opcode == WRITE) begin
            reg_input[bus.addr] <= bus.data_in;
        end
        else if (bus.opcode == HASH && state == WAIT) begin
            $display($time, " Transferring data into Photon");
            lwh_nBlock = 1;
            lwh_nReset = 1;
            register_index = 0;
            state = INPUT;
        end
        else if (state == INPUT && register_index <= 8) begin
            $display($time, " Transferred register %d %h", register_index, reg_input[register_index]);
            register_index = register_index + 1;
            if (register_index >= 8) begin
                $display($time, " Finished transferring register");
                $display($time, " Starting hash");
                lwh_nBlock = 0;
                lwh_init = 1;
                state = EXEC;
            end
        end
        else if (state == INPUT && register_index == 7) begin
        end
        else if (state == EXEC && lwh_outReady) begin
            $display($time, " Finishing hash");
            register_index = 0;
            reg_output[register_index] = lwh_output;
            state = OUTPUT;
            $display($time, " Storing hash output %h", lwh_output);
        end
        else if (state == OUTPUT && register_index < 7) begin
            $display($time, " Storing hash output %h", lwh_output);
            register_index = register_index + 1;
            reg_output[register_index] = lwh_output;
        end
        else if (state == OUTPUT && register_index >= 7) begin
            $display($time, " Finished reading hash output");
            lwh_nBlock = 0;
            lwh_init = 0;
            state = WAIT;
            lwh_nReset = 0;
        end
    end
endmodule
