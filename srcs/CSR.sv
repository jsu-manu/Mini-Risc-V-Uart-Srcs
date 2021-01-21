`timescale 1ns / 1ps 

module CSR (
	main_bus bus
	);

    logic clk, wea, rst;
    logic[31:0] din, dout; 
    logic [11:0] r_addr, w_addr;
    
    always_comb begin: bus_stuff
        clk = bus.clk;
        rst = bus.Rst;
        wea = bus.EX_CSR_write;
        din = bus.EX_CSR_res;
        r_addr = bus.IF_ID_CSR_addr;
        w_addr = bus.EX_CSR_addr; 
        bus.IF_ID_CSR = dout;
    end
    
//    enum logic[11:0] {
//        mstatus     = 12'h300, 
//        misa        = 12'h301,
//        mie         = 12'h304,
//        mtvec       = 12'h305, 
        
//        mscratch    = 12'h340,
//        mepc        = 12'h341, 
//        mcause      = 12'h342, 
//        mtval       = 12'h343, 
//        mip         = 12'h344
//        } csr_list;
        
//	logic [31:0] csr[256];
	
	logic [31:0] mstatus, misa, mie, mtvec, mscratch, mepc, mcause, mtval, mip; 

    function logic[31:0] build_mcause();
    begin
//        return {1'b0, bus.uart_IRQ, 30'h0};
		if (bus.ecall) return {1'b1, 31'h3};
		else if (bus.uart_IRQ) return 31;
    end
    endfunction
    
    always_comb begin

//		dout = csr[r_addr[7:0]];
//        bus.mtvec = csr[5];
		bus.mtvec = mtvec;
		bus.mepc = mepc;
//        bus.mepc = csr[8'h41];
        
        case (r_addr[11:0])
        	12'h300: dout = mstatus; 
        	12'h301: dout = misa;
        	12'h304: dout = mie; 
        	12'h305: dout = mtvec;
        	12'h340: dout = mscratch; 
        	12'h341: dout = mepc; 
        	12'h342: dout = mcause;
        	12'h343: dout = mtval;
        	12'h344: dout = mip;
        	default: dout = 0; 
        endcase
    end
    
//    event triggered;
    
    
    always_ff @(posedge clk or posedge bus.trigger_trap) begin
        if (rst) begin
        
        end else begin
            if (bus.trigger_trap) begin
//               csr[mepc] <= bus.IF_ID_pres_addr; 
//               ->triggered;
//				bus.trap <= 0;
//               csr[mcause] <= build_mcause();
//               triggerTrap();
//				csr[8'h41] <= bus.IF_ID_pres_addr; 
//				csr[8'h42] <= build_mcause(); 
				mepc <= bus.IF_ID_pres_addr;
				mcause <= build_mcause(); 
			
            end

                if (wea) begin
//						csr[w_addr[7:0]] <= din;
					case(w_addr[11:0])
						12'h300: mstatus <= din;
						12'h301: misa <= din;
						12'h304: mie <= din;
						12'h305: mtvec <= din;
						12'h340: mscratch <= din;
						12'h341: mepc <= din;
						12'h342: mcause <= din;
						12'h343: mtval <= din;
						12'h344: mip <= din;
					default:;
					endcase
            end
        end
    end
    
//    always @(posedge bus.stack_mismatch) begin
//        triggerTrap();
//    end
    
//    always @(posedge bus.ecall) triggerTrap();
    

    
//    task triggerTrap();
//    begin
//        if (~bus.trapping) begin
////        csr[mcause] <= build_mcause();
//			csr[12'h41] <= bus.IF_ID_pres_addr;
//			csr[12'h42] <= build_mcause();
//			bus.trap <= 1;
//        end
////        @ (triggered); 
////        bus.trap = 0;
//    end
//    endtask

endmodule : CSR