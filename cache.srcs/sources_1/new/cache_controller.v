`timescale 1ns / 1ps


module cache_controller(
input	clk,
input [22:0]   Addr, //address for writing
input [31:0]   wrData, //Data to be written
//input   wrEn, //Should become high when you want to write to the memory,
output reg [9:0]  rdAddress,
output reg [31:0] DataWrite,
output reg [10:0] TagWrite,
input [(1024*11)-1:0] tags,
input [1023:0] valid_bits, dirty_bits,
//output reg cache_miss,
output reg writeBackToCache,
output reg rdEnToCache, //have another enable for ram?
input [31:0] dataBackFromCache,
input [31:0] dataBackFromRAM,
output reg [31:0] dataToProc,
output reg [22:0] AddrToRam,
output reg [31:0] wrDataToRam, //To clarify
output reg outTagValid,
output reg out_dirty_bit,
output reg WrEntoRam,
input WrEnProc,
output reg rdEnToRam
);

wire [10:0] received_tag;
wire [9:0] received_addr;
reg valid_bit;
reg cache_miss;

assign received_tag = Addr[22:12];
assign received_addr = Addr[11:2];
 //Writing to memory logic
    always @(posedge clk)
    begin
    $display("ADDR/Tag bits %d: %b, %d",received_addr, tags[(received_addr*11)+10 -:11],received_tag);
        //if(received_tag == c0.cache_mem[received_addr][41:31] && c0.valid_bits[received_addr] == 1)  begin
        if(received_tag == tags[(received_addr*11)+10 -:11] && valid_bits[received_addr] == 1)  begin  //if data found in cache
            //c0.rdData = c0.cache_mem[received_addr][31:0]; //data found in cache, how to signal cache to send datta to processor
            rdAddress <= #2 received_addr;
            $display("Wrote tag into loca %b %d", received_addr, received_addr);
            //rdData = wrData; 
            cache_miss <= #2 1'b0;
            writeBackToCache <= #2 1'b0;
            rdEnToCache <= #2 1;
            outTagValid <= #2 1'b0;
            //$display("Tag HIT! : TAG:%b %d ADDR:%d %b -- time: %d", received_tag, received_tag, received_addr, received_addr, $time);

        end
        else    begin  //if data not found in cache; tag doesnt match, write back into cache after RAM sendins data out
            //if(wrEn)    begin // because may be we don't need write enable for cache controller is should generate on its own
                //rdAddress <= #2 Addr; change made by sir during meet; but this rdAddress is actually going to cache block only, not RAM block read address signal. handled in line #79(last always block)
                rdAddress <= #2 received_addr;
                //DataWrite = {Addr[22:12], wrData};
                //DataWrite = wrData;
                //DataWrite <= #2 dataBackFromRAM;
                TagWrite <= #2 Addr[22:12];
                cache_miss <= #2 1'b1;
                writeBackToCache <= #2 1'b1;
                rdEnToCache <= #2 0;
                outTagValid <= #2 1'b1;
                if(dirty_bits[received_addr] == 1'b0) begin
                    DataWrite <= #2 dataBackFromRAM;
                    out_dirty_bit <= #2 1'b1;
                    end
                else begin
                    rdEnToCache <= 1;
                    AddrToRam = Addr;
                    wrDataToRam <=  dataBackFromCache;
                    DataWrite <=  dataBackFromRAM;
                    end 
                
            //end
            //let ram output data to processor
        end
         //if(wrEn)
         //$display("J");
              //mem[wrAddr] <=  wrData;
    end

    //Read logic
    //always @(posedge clk)
        //rdData <=  mem[rdAddr];
        
    always@(posedge clk) begin
        if (cache_miss == 0)    begin
            dataToProc = dataBackFromCache;
            //$display("FROM CACHE!");
            end
        else        begin
            AddrToRam = Addr;
            dataToProc = dataBackFromRAM;  
            //$display("FROM RAM!"); 
        end 
     end
endmodule

