`timescale 1ns / 1ps


module cache #(parameter Width=32, Depth=1024)(
    input	clk,reset,
    input   wrEn, //Should become high when you want to write to the memory
    input [$clog2(Depth)-1:0]   Addr, //cacheline addr
    input [Width-1:0]   wrData, //Data to be written
    output reg [31:0]  rdData,
    output reg [(1024*11)-1:0] tags,
    input [10:0] tag,
    input inTagValid,in_dirty_bit,
    output reg [1023:0] valid_bits,  dirty_bits,
    input rdEnable
);
reg [Width-1:0] cache_mem[Depth-1:0];

integer k;
/*genvar i;
generate
for (i=0; i<1023; i=i+1)   begin
    //assign tags[(i*11)+10:i*11] = cache_mem[i][41:31];
   //assign valid_bits[i] = valid_bits_reg[i];
end
endgenerate*/

    always@(posedge reset)
    begin
        dirty_bits = 1024'b0;   //Changed by PMN on 31st March, replaced 1'b0 by 1024'b0
        for (k=0; k<1024; k=k+1)    begin
            cache_mem[k] = 32'b0;
        end
    end

    //Writing to memory logic
    always @(posedge clk)
    begin
         if(wrEn)   begin
              $display("Updating cache memory");
              cache_mem[Addr] <= #2 wrData;
              valid_bits[Addr] <= #2 1'b1;
              if(in_dirty_bit) dirty_bits[Addr] <= #2 1'b1;
         end
    end
    
    //updating tag if needed
    always @(posedge clk)
    begin
         if(wrEn & inTagValid)   begin
              tags[(Addr*11)+:11] <= #2 tag;
              valid_bits[Addr] <= #2 1'b1;
              $display("Tag updated at: %b %d %d %f", tag, tag, Addr, $time);
         end
    end

    //Read logic
    always @(posedge clk)
        if(rdEnable)    begin   
            rdData <= #2 cache_mem[Addr];
        end
    
endmodule

