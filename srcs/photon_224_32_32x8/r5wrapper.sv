`timescale 1ns / 1ps

module photon_core(main_bus bus);

    photon_bus pho_bus(bus.clk, bus.Rst);
    photon pho0(pho_bus);
    
    photon_opcode photon_opcode;
    logic illegal_ins;
    
    assign bus.photon_data_out = pho_bus.data_out;
    assign bus.photon_busy = !pho_bus.ready;
    assign pho_bus.data_in = bus.IF_ID_dout_rs1;
    assign pho_bus.opcode = photon_opcode;
    assign illegal_ins = (bus.ins[6:0] != 7'b0101011); // @custom1
    
    always_comb begin
        bus.adr_photon_rs1 = 'd0;
        bus.addr_corereg_photon = 'd0;
        bus.photon_regwrite = 'b0;
        pho_bus.addr = 'd0;
        
        if (!illegal_ins) begin
            unique case (bus.ins[11:7])
                5'b00010: // Load/Write to Photon registers.
                // [31:27]=core_reg; [26:25]=unused ; [24:22]=Photon_reg; [21:12]=unused; [11:7]=00010; [6:0]=0101011
                begin
                    pho_bus.opcode = WRITE;
                    bus.adr_photon_rs1 = bus.ins[31:27];
                    pho_bus.addr = bus.ins[24:22];
                end
                
                5'b00001: // Read from Photon/Store to RISC-V core registers
                // [31:27]=core_reg; [26:25]=unused ; [24:22]=Photon_reg; [21:12]=unused; [11:7]=00001; [6:0]=0101011
                begin
                    pho_bus.opcode = READ;
                    pho_bus.addr = bus.ins[24:22];
                    bus.addr_corereg_photon = bus.ins[31:27];
                    bus.photon_regwrite = 'b1;
                end
                
                5'b00011: // Execute hash
                // [31:12]=unused; [11:7]=00011; [6:0]=0101011
                begin
                    pho_bus.opcode = HASH;
                end
                
                5'b00100: // Check ready
                // [31:27]=core_reg; [26:12]=unused; [11:7]=00100; [6:0]=0101011
                begin
                    pho_bus.opcode = CHECK;
                    bus.addr_corereg_photon = bus.ins[31:27];
                    bus.photon_regwrite = 'b1;
                end
                
                default:
                begin
                    pho_bus.opcode = NONE;
                end
            endcase
        end
    end
    
    // TODO Add instr. for bus.ins
    // TODO EX_MEM_lwhres for reading results
    // TODO ID_EX_lwhsel for running hash and writing inputs
    // TODO Add lwh_ready to main_bus
    //      Also EX_MEM_lwh_ready and MEM_WB_lwh_ready
    
endmodule
