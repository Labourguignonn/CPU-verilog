                ST_SRAM: begin
                    if (Counter == 6'd0) begin
                        State = ST_SRAM;

                        PCWrite = 1'b0;
                        MemWrite = 1'b0;
                        instructRegWrite = 1'b0;
                        RegWrite = 1'b0;
                        RegAWrite = 1'b0;
                        RegBWrite = 1'b0;
                        AluOutWrite = 1'b1;
                        MDRWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        EPCWrite = 1'b0;
                        divControl = 1'b0;
                        multControl = 1'b0;
                        muxAControl = 1'b0;
                        muxBControl = 1'b0;
                        muxExtControl = 1'b1;
                        muxHiControl = 1'b0;
                        muxLoControl = 1'b0;
                        muxMemWrite = 1'b0;
                        MemRead = 1'b0;
                        RegAuxWrite = 1'b0;

                        //dois bits
                        ALU1Control = 2'b01;
                        ALU2Control = 2'b10; 
                        muxShamtControl = 2'b00;
                        muxShiftInControl = 2'b00;
                        storeSel = 2'b00;
                        loadSel = 2'b00;
                        exceptionControl = 2'b00;

                        //tres bits
                        ALUControl = 3'b001; 
                        muxDataControl = 3'b000;
                        muxPCControl = 3'b000;
                        muxRegControl = 3'b001;
                        muxAddressControl = 3'b000;
                        ShiftControl = 3'b000;
                       
                        rst = 1'b0;
                        Counter = Counter + 1;
                    end
                    else if (Counter == 6'd1) begin
                        State = ST_SRAM;

                        PCWrite = 1'b0;
                        MemWrite = 1'b0;
                        instructRegWrite = 1'b0;
                        RegWrite = 1'b0;
                        RegAWrite = 1'b0;
                        RegBWrite = 1'b0;
                        AluOutWrite = 1'b0; 
                        MDRWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        EPCWrite = 1'b0;
                        divControl = 1'b0;
                        multControl = 1'b0;
                        muxAControl = 1'b0;
                        muxBControl = 1'b0;
                        muxExtControl = 1'b0;
                        muxHiControl = 1'b0;
                        muxLoControl = 1'b0;
                        muxMemWrite = 1'b0;
                        MemRead = 1'b0;
                        RegAuxWrite = 1'b0;

                        //dois bits
                        ALU1Control = 2'b01;
                        ALU2Control = 2'b00; 
                        muxShamtControl = 2'b00;
                        muxShiftInControl = 2'b00;
                        storeSel = 2'b00;
                        loadSel = 2'b00;
                        exceptionControl = 2'b00;

                        //tres bits
                        ALUControl = 3'b000; 
                        muxDataControl = 3'b000;
                        muxPCControl = 3'b000;
                        muxRegControl = 3'b001;
                        muxAddressControl = 3'b100;
                        ShiftControl = 3'b000;
                       
                        rst = 1'b0;
                        Counter = Counter + 1;
                    end
                    else if (Counter == 6'd2) begin
                        State = ST_SRAM;

				        PCWrite = 1'b0;
                        MemWrite = 1'b0;
                        instructRegWrite = 1'b0;
                        RegWrite = 1'b0;
                        RegAWrite = 1'b1;
                        RegBWrite = 1'b1;
                        AluOutWrite = 1'b0; 
                        MDRWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        EPCWrite = 1'b0;
                        divControl = 1'b0;
                        multControl = 1'b0;
                        muxAControl = 1'b1;
                        muxBControl = 1'b1;
                        muxExtControl = 1'b0;
                        muxHiControl = 1'b0;
                        muxLoControl = 1'b0;
                        muxMemWrite = 1'b0;
                        MemRead = 1'b0;
                        RegAuxWrite = 1'b0;

                        //dois bits
                        ALU1Control = 2'b01;
                        ALU2Control = 2'b00; 
                        muxShamtControl = 2'b00;
                        muxShiftInControl = 2'b00;
                        storeSel = 2'b00;
                        loadSel = 2'b00;
                        exceptionControl = 2'b00;

                        //tres bits
                        ALUControl = 3'b000; 
                        muxDataControl = 3'b000;
                        muxPCControl = 3'b000;
                        muxRegControl = 3'b001;
                        muxAddressControl = 3'b000;
                        ShiftControl = 3'b000;
                       
                        rst = 1'b0;
                        Counter = Counter + 1;
				    end
				    else if (Counter == 6'd3) begin
                        State = ST_SRAM;

				        PCWrite = 1'b0;
                        MemWrite = 1'b0;
                        instructRegWrite = 1'b0;
                        RegWrite = 1'b0;
                        RegAWrite = 1'b0;
                        RegBWrite = 1'b0;
                        AluOutWrite = 1'b0; 
                        MDRWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        EPCWrite = 1'b0;
                        divControl = 1'b0;
                        multControl = 1'b0;
                        muxAControl = 1'b0;
                        muxBControl = 1'b0;
                        muxExtControl = 1'b0;
                        muxHiControl = 1'b0;
                        muxLoControl = 1'b0;
                        muxMemWrite = 1'b0;
                        MemRead = 1'b0;
                        RegAuxWrite = 1'b0;

                        //dois bits
                        ALU1Control = 2'b01;
                        ALU2Control = 2'b00; 
                        muxShamtControl = 2'b01;
                        muxShiftInControl = 2'b00;
                        storeSel = 2'b00;
                        loadSel = 2'b00;
                        exceptionControl = 2'b00;

                        //tres bits
                        ALUControl = 3'b000; 
                        muxDataControl = 3'b000;
                        muxPCControl = 3'b000;
                        muxRegControl = 3'b001;
                        muxAddressControl = 3'b000;
                        ShiftControl = 3'b001;
                       
                        rst = 1'b0;
                        Counter = Counter + 1;
				    end
                    else if (Counter == 6'd4) begin
                        State = ST_SRAM;

				        PCWrite = 1'b0;
                        MemWrite = 1'b0;
                        instructRegWrite = 1'b0;
                        RegWrite = 1'b0;
                        RegAWrite = 1'b0;
                        RegBWrite = 1'b0;
                        AluOutWrite = 1'b0; 
                        MDRWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        EPCWrite = 1'b0;
                        divControl = 1'b0;
                        multControl = 1'b0;
                        muxAControl = 1'b0;
                        muxBControl = 1'b0;
                        muxExtControl = 1'b0;
                        muxHiControl = 1'b0;
                        muxLoControl = 1'b0;
                        muxMemWrite = 1'b0;
                        MemRead = 1'b0;
                        RegAuxWrite = 1'b0;

                        //dois bits
                        ALU1Control = 2'b01;
                        ALU2Control = 2'b00; 
                        muxShamtControl = 2'b01;
                        muxShiftInControl = 2'b00;
                        storeSel = 2'b00;
                        loadSel = 2'b00;
                        exceptionControl = 2'b00;

                        //tres bits
                        ALUControl = 3'b000; 
                        muxDataControl = 3'b110;
                        muxPCControl = 3'b000;
                        muxRegControl = 3'b001;
                        muxAddressControl = 3'b000;
                        ShiftControl = 3'b100;
                       
                        rst = 1'b0;
                        Counter = Counter + 1;
				    end
                    else if (Counter == 6'd5) begin
                        State = ST_COMMON;

				        PCWrite = 1'b0;
                        MemWrite = 1'b0;
                        instructRegWrite = 1'b0;
                        RegWrite = 1'b1;
                        RegAWrite = 1'b0;
                        RegBWrite = 1'b0;
                        AluOutWrite = 1'b1; 
                        MDRWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        EPCWrite = 1'b0;
                        divControl = 1'b0;
                        multControl = 1'b0;
                        muxAControl = 1'b0;
                        muxBControl = 1'b0;
                        muxExtControl = 1'b1;
                        muxHiControl = 1'b0;
                        muxLoControl = 1'b0;
                        muxMemWrite = 1'b0;
                        MemRead = 1'b0;
                        RegAuxWrite = 1'b0;

                        //dois bits
                        ALU1Control = 2'b01;
                        ALU2Control = 2'b10; 
                        muxShamtControl = 2'b00;
                        muxShiftInControl = 2'b00;
                        storeSel = 2'b00;
                        loadSel = 2'b00;
                        exceptionControl = 2'b00;

                        //tres bits
                        ALUControl = 3'b001; 
                        muxDataControl = 3'b110;
                        muxPCControl = 3'b000;
                        muxRegControl = 3'b001;
                        muxAddressControl = 3'b000;
                        ShiftControl = 3'b000;
                       
                        rst = 1'b0;
                        Counter = 0;
				    end
                    else if (Counter == 6'd6) begin
				        State = ST_COMMON;

				        PCWrite = 1'b0;
                        MemWrite = 1'b0;
                        instructRegWrite = 1'b0;
                        RegWrite = 1'b0;
                        RegAWrite = 1'b0;
                        RegBWrite = 1'b0;
                        AluOutWrite = 1'b1; 
                        MDRWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        EPCWrite = 1'b0;
                        divControl = 1'b0;
                        multControl = 1'b0;
                        muxAControl = 1'b0;
                        muxBControl = 1'b0;
                        muxExtControl = 1'b1;
                        muxHiControl = 1'b0;
                        muxLoControl = 1'b0;
                        muxMemWrite = 1'b0;
                        MemRead = 1'b0;
                        RegAuxWrite = 1'b0;

                        //dois bits
                        ALU1Control = 2'b01;
                        ALU2Control = 2'b10; 
                        muxShamtControl = 2'b00;
                        muxShiftInControl = 2'b00;
                        storeSel = 2'b00;
                        loadSel = 2'b00;
                        exceptionControl = 2'b00;

                        //tres bits
                        ALUControl = 3'b001; 
                        muxDataControl = 3'b000;
                        muxPCControl = 3'b000;
                        muxRegControl = 3'b001;
                        muxAddressControl = 3'b000;
                        ShiftControl = 3'b000;
                       
                        rst = 1'b0;
                        Counter = 0;
				    end
                end