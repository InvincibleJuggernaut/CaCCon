`timescale 1ns / 1ps

module cache_fsm(
input	clk,reset,
input [22:0]   Addr, //address for writing
input [31:0]   wrData, //Data to be written
output reg [9:0]  rdAddress,
output reg [31:0] DataWrite,
output reg [10:0] TagWrite,
input [(1024*11)-1:0] tags0, tags1, tags2, tags3,
input [1023:0] valid_bits0, valid_bits1, valid_bits2, valid_bits3, 
input [1023:0] dirty_bits0, dirty_bits1, dirty_bits2, dirty_bits3,
output reg writeBackToCache0, writeBackToCache1, writeBackToCache2, writeBackToCache3,
output reg rdEnToCache0, rdEnToCache1, rdEnToCache2, rdEnToCache3, 
output reg rdEnToRam, 
input [31:0] dataBackFromCache0, dataBackFromCache1, dataBackFromCache2, dataBackFromCache3, 
input [31:0] dataBackFromRAM,
output reg [31:0] dataToProc,
output reg [22:0] AddrToRam,
output reg [31:0] wrDataToRam, 
output reg outTagValid,
output reg out_dirty_bit,
output reg WrEntoRam,
input WrEnProc,
input valid_cpu_request,
output reg valid,
output reg hold
    );
    
reg [2:0] PS;
reg [2:0] NS; 
parameter IDLE = 0, COMPARE_TAG = 1, ALLOCATE = 2, WRITE_BACK = 3;

wire [10:0] received_tag;
wire [9:0] received_addr;

assign received_tag = Addr[22:12];
assign received_addr = Addr[11:2];
reg cache_miss;

reg cache0_miss, cache1_miss, cache2_miss, cache3_miss;
reg cache0_wb, cache1_wb, cache2_wb, cache3_wb;

reg [2:0] plru_bits [1023:0];
integer j;
always @(posedge reset)
    begin
        for(j=0; j<1024; j=j+1) begin
            plru_bits[j] = 3'd0;
        end
    end
//reg compulsory_miss;

 always@(posedge clk)
     begin
     //Default initializations
     valid <= 1'b0;
//     DataWrite <= 32'b0;
//     out_dirty_bit <= 1'b0;
//     outTagValid <= 1'b0;
//     TagWrite <= 11'b0;
     
//     rdEnToCache0 <= 1'b0;
//     rdEnToCache1 <= 1'b0;
//     rdEnToCache2 <= 1'b0;
//     rdEnToCache3 <= 1'b0;
//     writeBackToCache0 <= 1'b0;
//     writeBackToCache1 <= 1'b0;
//     writeBackToCache2 <= 1'b0;
//     writeBackToCache3 <= 1'b0;
     
//     rdAddress <= 32'b0;
//     dataToProc <= 32'b0;
     
//     rdEnToRam <= 1'b0;
//     WrEntoRam <= 1'b0;
//     AddrToRam <= 32'b0;
//     wrDataToRam <= 32'b0;
     
      if (reset)    begin 
        PS <= IDLE;
        valid <= 0;
        hold = 1'b0;
        //$display("Reset state: %d", PS);  
      end
      
   
      else  begin
        //$display("Current state: %d", PS);
      case (PS)
      
        IDLE: begin
        
          hold = 0;
          #1.25; hold = 1;
           //$display("Entered IDLE");
          PS <= valid_cpu_request ? COMPARE_TAG : IDLE;
          valid <= 0;
          $display("AM AT IDLE! %f", $time);
          
          writeBackToCache0 <= 1'b0;
          writeBackToCache1 <= 1'b0;
          writeBackToCache2 <= 1'b0;
          writeBackToCache3 <= 1'b0; 
          out_dirty_bit <= 1'b0;
         end
        
        COMPARE_TAG: begin
            hold = 1;
            cache0_miss = 1'b1;
            cache1_miss = 1'b1;
            cache2_miss = 1'b1;
            cache3_miss = 1'b1;
            
            cache0_wb = 1'b1;
            cache1_wb = 1'b1;
            cache2_wb = 1'b1;
            cache3_wb = 1'b1;
            //$display("Entered COMPARE_TAG");
            //$display("%d %d, %d, %d", $time, received_tag, tags[(received_addr*11)+10 -:11], valid_bits[received_addr]);
           
           //CACHE 0 HIT
            if(received_tag == tags0[(received_addr*11)+10 -:11] && valid_bits0[received_addr] == 1)  begin  //check cache hit
                if(WrEnProc)    begin //cache hit but new data to be written
                    $display("Entered 1: Cache0 write hit! %h %h %f", received_tag, received_addr, $time); 
                    DataWrite <= wrData;
                    writeBackToCache0 <= 1'b1;
                    out_dirty_bit <= 1'b1;
                    outTagValid <= 1'b1;
                    rdAddress <= received_addr; //added since addres sseemed to be missing in writ ehit case, read hit case had it present - PMN
                                       
                    plru_bits[received_addr] <= plru_bits[received_addr] ^ 3'b101; 
                    $display("PLRU changed to %d", plru_bits[received_addr]);
                    
                    valid <= 1;
                    
                    //rdEnToCache <= 1'b0;
                    //rdEnToRam <= 1'b0;
                end
                else    begin   //cache hit but data to be read
                $display("Entered 2:  Cache0 read hit! %h %h %f", received_tag, received_addr, $time); 
                    rdAddress <= received_addr;
                    rdEnToCache0 <= 1'b1;
                    dataToProc <= dataBackFromCache0;
                    valid <= 1;
                    writeBackToCache0 <= 1'b0;
                    
                    plru_bits[received_addr] <= plru_bits[received_addr] ^ 3'b101; 
                    $display("PLRU changed to %d", plru_bits[received_addr]);
                    
                    //rdEnToRam <= 1'b0;
                end
                PS <= IDLE;
                cache0_miss = 1'b0;
             end

            //CACHE 1 HIT
             if(received_tag == tags1[(received_addr*11)+10 -:11] && valid_bits1[received_addr] == 1)  begin  //check cache hit
                 if(WrEnProc)    begin //cache hit but new data to be written
                     $display("Entered 3: Cache1 write hit! %h %h %d", received_tag, received_addr, $time);
                     DataWrite <= wrData;
                     writeBackToCache1 <= 1'b1;
                     out_dirty_bit <= 1'b1;
                     outTagValid <= 1'b1;
                     rdAddress <= received_addr; //added since addres sseemed to be missing in writ ehit case, read hit case had it present - PMN
                     
                     plru_bits[received_addr] <= plru_bits[received_addr] ^ 3'b101; 
                     $display("PLRU changed to %d", plru_bits[received_addr]);
                     
                     valid <= 1;
                     //rdEnToCache <= 1'b0;
                     //rdEnToRam <= 1'b0;
                 end
                 else    begin   //cache hit but data to be read
                 $display("Entered 4:  Cache1 read hit! %h %h %d", received_tag, received_addr, $time);
                     rdAddress <= received_addr;
                     rdEnToCache1 <= 1'b1;
                     dataToProc <= dataBackFromCache1;
                     valid <= 1;
                     writeBackToCache1 <= 1'b0;
                     
                     plru_bits[received_addr] <= plru_bits[received_addr] ^ 3'b101; 
                     $display("PLRU changed to %d", plru_bits[received_addr]);
                     
                     //rdEnToRam <= 1'b0;
                 end
                 PS <= IDLE;
                 cache1_miss = 1'b0;
              end

             //CACHE 2 HIT
              if(received_tag == tags2[(received_addr*11)+10 -:11] && valid_bits2[received_addr] == 1)  begin  //check cache hit
                  if(WrEnProc)    begin //cache hit but new data to be written
                      $display("Entered 5: Cache2 write hit! %h %h %f", received_tag, received_addr, $time);
                      DataWrite <= wrData;
                      writeBackToCache2 <= 1'b1;
                      out_dirty_bit <= 1'b1;
                      outTagValid <= 1'b1;
                      rdAddress <= received_addr; //added since addres sseemed to be missing in writ ehit case, read hit case had it present - PMN
                      
                      plru_bits[received_addr] <= plru_bits[received_addr] ^ 3'b110;  
                      $display("PLRU changed to %d", plru_bits[received_addr]);
                      
                      valid <= 1;

                      //rdEnToCache <= 1'b0;
                      //rdEnToRam <= 1'b0;
                  end
                  else    begin   //cache hit but data to be read
                  $display("Entered 6:  Cache2 read hit! %h %h %f", received_tag, received_addr, $time);
                      rdAddress <= received_addr;
                      rdEnToCache2 <= 1'b1;
                      dataToProc <= dataBackFromCache2;
                      valid <= 1;
                      writeBackToCache2 <= 1'b0;
                      
                      plru_bits[received_addr] <= plru_bits[received_addr] ^ 3'b110; 
                      $display("PLRU changed to %d", plru_bits[received_addr]); 
                      
                      //rdEnToRam <= 1'b0;
                  end
                  PS <= IDLE;
                  cache2_miss = 1'b0;
               end

           //CACHE 3 HIT
           if(received_tag == tags3[(received_addr*11)+10 -:11] && valid_bits3[received_addr] == 1)  begin  //check cache hit
               if(WrEnProc)    begin //cache hit but new data to be written
                   $display("Entered 7: Cache3 write hit! %h %h %d", received_tag, received_addr, $time);
                   DataWrite <= wrData;
                   writeBackToCache3 <= 1'b1;
                   out_dirty_bit <= 1'b1;
                   outTagValid <= 1'b1;
                   rdAddress <= received_addr; //added since addres sseemed to be missing in writ ehit case, read hit case had it present - PMN
                    
                    plru_bits[received_addr] <= plru_bits[received_addr] ^ 3'b110;  
                    $display("PLRU changed to %d", plru_bits[received_addr]);
                    
                    valid <= 1;
                   //rdEnToCache <= 1'b0;
                   //rdEnToRam <= 1'b0;
               end
               else    begin   //cache hit but data to be read
               $display("Entered 8:  Cache3 read hit! %h %h %d", received_tag, received_addr, $time);
                   rdAddress <= received_addr;
                   rdEnToCache3 <= 1'b1;
                   dataToProc <= dataBackFromCache3;
                   valid <= 1;
                   writeBackToCache3 <= 1'b0;
                   
                   plru_bits[received_addr] <= plru_bits[received_addr] ^ 3'b110; 
                   $display("PLRU changed to %d", plru_bits[received_addr]); 
                   //rdEnToRam <= 1'b0;
               end
               PS <= IDLE;
               cache3_miss = 1'b0;
            end
        
            //else begin  //cache miss
            if((cache0_miss && cache1_miss && cache2_miss && cache3_miss) == 1)  begin
                $display("MISS_REHGISTERS: %d, %d %d %d %d %f", cache0_miss, cache1_miss,cache2_miss, cache3_miss, (cache0_miss && cache1_miss && cache2_miss && cache3_miss),  $time);
                //$display("%f Cache miss for %d", $time, Addr);
                if(dirty_bits0[received_addr] == 1'b1 && (plru_bits[received_addr] == 3'd0 || plru_bits[received_addr] == 3'd2)) begin //cache miss and dirty
                $display("%f Cache miss for PLUR matches for cache 0 %d", $time, Addr);
    //                DataWrite <= wrData;
    //                writeBackToCache0 <= 1'b1;
    //                out_dirty_bit <= 1'b1;
    //                outTagValid <= 1'b1;
                    
                    PS <= WRITE_BACK;
                    cache0_wb = 1'b0;
                    //rdEnToCache0 <= 1'b0;
                    //rdEnToRam <= 1'b0;
                 end
                 if(dirty_bits1[received_addr] == 1'b1 && (plru_bits[received_addr] == 3'd1 || plru_bits[received_addr] == 3'd3)) begin //cache miss and dirty
                    $display("%f Cache miss for PLUR matches for cache 1 %d", $time, Addr);
                    PS <= WRITE_BACK;
                    cache1_wb = 1'b0;
                 end
                 if(dirty_bits2[received_addr] == 1'b1 && (plru_bits[received_addr] == 3'd4 || plru_bits[received_addr] == 3'd5)) begin //cache miss and dirty
                    $display("%f Cache miss for PLUR matches for cache 2 %d", $time, Addr);
                    PS <= WRITE_BACK;
                    cache2_wb = 1'b0;
                 end
                 if(dirty_bits3[received_addr] == 1'b1 && (plru_bits[received_addr] == 3'd6 || plru_bits[received_addr] == 3'd7)) begin //cache miss and dirty
                    $display("%f Cache miss for PLUR matches for cache 3 %d", $time, Addr);
                    PS <= WRITE_BACK;
                    cache3_wb = 1'b0;
                 end
                 
                 
                 //else    begin   //cache miss and not dirty
                 if((cache0_wb && cache1_wb && cache2_wb && cache3_wb) == 1)  begin
                 
                    $display("Send fromt he last else stataemtn %f", $time);
                    PS <= ALLOCATE;

                    //rdEnToCache0 <= 1'b0;
                    //rdEnToRam <= 1'b0;
               end
            end
    
          //new changes because initally dont care condition
    
          end
        ALLOCATE: begin
        hold = 1;
        
        $display("Entered ALLOCATE");
        
            //read RAM
            rdEnToRam <= 1'b1;
            AddrToRam <= Addr;
            dataToProc <= dataBackFromRAM; 
            
            if(plru_bits[received_addr] == 3'd0 || plru_bits[received_addr] == 3'd2)    begin
                writeBackToCache0 <= 1'b1;
                outTagValid <= 1'b1;
                TagWrite <= Addr[22:12];
                rdAddress <= received_addr;
                DataWrite <= dataBackFromRAM;
                plru_bits[received_addr] <= plru_bits[received_addr] ^ 3'b101; 
            end
            if(plru_bits[received_addr] == 3'd1 || plru_bits[received_addr] == 3'd3)    begin
                writeBackToCache1 <= 1'b1;
                outTagValid <= 1'b1;
                TagWrite <= Addr[22:12];
                rdAddress <= received_addr;
                DataWrite <= dataBackFromRAM;
                plru_bits[received_addr] <= plru_bits[received_addr] ^ 3'b101; 
            end
            if(plru_bits[received_addr] == 3'd4 || plru_bits[received_addr] == 3'd5)    begin
                writeBackToCache2 <= 1'b1;
                outTagValid <= 1'b1;
                TagWrite <= Addr[22:12];
                rdAddress <= received_addr;
                DataWrite <= dataBackFromRAM;
                plru_bits[received_addr] <= plru_bits[received_addr] ^ 3'b110;             
            end
            if(plru_bits[received_addr] == 3'd6 || plru_bits[received_addr] == 3'd7)    begin
                writeBackToCache3 <= 1'b1;
                outTagValid <= 1'b1;
                TagWrite <= Addr[22:12];
                rdAddress <= received_addr;
                DataWrite <= dataBackFromRAM; 
                plru_bits[received_addr] <= plru_bits[received_addr] ^ 3'b110;            
            end
            
            
            //write to cache //Original conditions (next 5 lines) for writing into cache
//            writeBackToCache0 <= 1'b1;
//            outTagValid <= 1'b1;
//            TagWrite <= Addr[22:12];
//            rdAddress <= received_addr;
//            DataWrite <= dataBackFromRAM;
            
            //cache_miss <= 1'b1;
             PS <= IDLE; //changed from COMPARE_TAG on 31st March by PMN
             
             valid <= 1'b0;
             //rdEnToCache0 <= 1'b0;
        end
        
        WRITE_BACK: begin
            hold = 1;
            $display("Entered WRITE_BACK");
            
            if(cache0_wb == 1'b0)   begin
            //read cache
                rdEnToCache0 <= 1'b1;
                rdAddress <= received_addr;
                
                //write to RAM
                WrEntoRam <= 1'b1;
                AddrToRam <= Addr;
                wrDataToRam <= dataBackFromCache0;
            end
            if(cache1_wb == 1'b0)   begin
            //read cache
                rdEnToCache1 <= 1'b1;
                rdAddress <= received_addr;
                
                //write to RAM
                WrEntoRam <= 1'b1;
                AddrToRam <= Addr;
                wrDataToRam <= dataBackFromCache1;
            end 
            if(cache2_wb == 1'b0)   begin
            //read cache
                rdEnToCache2 <= 1'b1;
                rdAddress <= received_addr;
                
                //write to RAM
                WrEntoRam <= 1'b1;
                AddrToRam <= Addr;
                wrDataToRam <= dataBackFromCache2;
            end 
            if(cache3_wb == 1'b0)   begin
            //read cache
                rdEnToCache3 <= 1'b1;
                rdAddress <= received_addr;
                
                //write to RAM
                WrEntoRam <= 1'b1;
                AddrToRam <= Addr;
                wrDataToRam <= dataBackFromCache3;
            end 
            
            
    
            //?handshake sig needed???
            
            //writeBackToCache0 <= 1'b0;
            //outTagValid <= 1'b0;
    
            PS <= ALLOCATE;
            
            writeBackToCache0 <= 1'b0;
            
            //new additions while adding replacement bits for remainign caches. NEED TO CHECK THE NEED FOR TURNING THIS SIGNAL OFF FOR THE CACHES
            writeBackToCache1 <= 1'b0;
            writeBackToCache2 <= 1'b0;
            writeBackToCache3 <= 1'b0;
            //rdEnToRam <= 1'b0;
            
            valid <= 1'b0;
        end
    
        endcase 
        end
     end

endmodule
