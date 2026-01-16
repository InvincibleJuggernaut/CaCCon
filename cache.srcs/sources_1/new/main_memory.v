`timescale 1ns / 1ps


module ram #(parameter Width=32, Depth=2*1024*1024)(
input	clk,reset,
input   wrEn, //Should become high when you want to write to the memory
input [$clog2(Depth)-1:0]   wrAddr, //address for writing
input [Width-1:0]   wrData, //Data to be written
input [$clog2(Depth)-1:0]   rdAddr,
output reg [Width-1:0]  rdData,
input rdEnable
);
integer i;

reg [Width-1:0] main_mem[Depth-1:0];

//    //Intializing
    always@(posedge reset)
    begin
    $readmemh("cache/main_mem.mem", main_mem);
    $display("Data at lcoation 1 : %b", main_mem[1]);
    $display("Data at lcoation 200: %b", main_mem[200]);
    end
    //Writing to memory logic
    always @(posedge clk)
    begin
         if(wrEn)
              main_mem[wrAddr] <= #2 wrData;
    end

    //Read logic
    always @(posedge clk)
        if(rdEnable)    begin  
            rdData <= #2 main_mem[rdAddr];
        end
    
endmodule

