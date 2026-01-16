`timescale 1ns / 1ps

module top(input [22:0] read_address,
           input [31:0] wrDataProc,
           input wrEnProc,
           input clk,reset,
           output [31:0] read_data,
           input valid_cpu_request,
           output valid,
           output hold);

 wire wrEn;
 wire [9:0] wrAddr;
 wire [31:0] wrData;
 wire [9:0] rdData;
 wire [(1024*11)-1:0] tags0,tags1, tags2, tags3;
 wire [1023:0] valid_bits0, valid_bits1, valid_bits2, valid_bits3;
 wire [1023:0] dirty_bits0, dirty_bits1, dirty_bits2, dirty_bits3;
 
 wire cache_miss;
 wire writeBackToCache0, writeBackToCache1, writeBackToCache2, writeBackToCache3;
 wire rdEnToCache0, rdEnToCache1, rdEnToCache2, rdEnToCache3, rdEnToRam;
 wire WrEntoRam;
 
wire [31:0] dataBackFromCache0, dataBackFromCache1, dataBackFromCache2, dataBackFromCache3, dataBackFromRAM;
wire [10:0] TagWrite;
wire [22:0] AddrToRam;
wire [31:0] wrDataToRam;

wire inTagValid,in_dirty_bit;
//wire valid;

cache c0(.clk(clk), .reset(reset), .wrEn(writeBackToCache0), .Addr(wrAddr), .wrData(wrData), .rdData(dataBackFromCache0), .tags(tags0), .rdEnable(rdEnToCache0), .valid_bits(valid_bits0), .dirty_bits(dirty_bits0), .tag(TagWrite), .inTagValid(inTagValid), .in_dirty_bit(in_dirty_bit));
cache c1(.clk(clk), .reset(reset), .wrEn(writeBackToCache1), .Addr(wrAddr), .wrData(wrData), .rdData(dataBackFromCache1), .tags(tags1), .rdEnable(rdEnToCache1), .valid_bits(valid_bits1), .dirty_bits(dirty_bits1), .tag(TagWrite), .inTagValid(inTagValid), .in_dirty_bit(in_dirty_bit));
cache c2(.clk(clk), .reset(reset), .wrEn(writeBackToCache2), .Addr(wrAddr), .wrData(wrData), .rdData(dataBackFromCache2), .tags(tags2), .rdEnable(rdEnToCache2), .valid_bits(valid_bits2), .dirty_bits(dirty_bits2), .tag(TagWrite), .inTagValid(inTagValid), .in_dirty_bit(in_dirty_bit));
cache c3(.clk(clk), .reset(reset), .wrEn(writeBackToCache3), .Addr(wrAddr), .wrData(wrData), .rdData(dataBackFromCache3), .tags(tags3), .rdEnable(rdEnToCache3), .valid_bits(valid_bits3), .dirty_bits(dirty_bits3), .tag(TagWrite), .inTagValid(inTagValid), .in_dirty_bit(in_dirty_bit));

ram r0(.clk(clk),.reset(reset), .wrEn(WrEntoRam), .wrAddr(AddrToRam), .wrData(wrDataToRam), .rdAddr(AddrToRam), .rdData(dataBackFromRAM), .rdEnable(rdEnToRam));
//cache_controller cc0(.clk(clk), .Addr(read_address),.wrData(wrDataProc),.rdAddress(wrAddr), .DataWrite(wrData), .tags(tags), .valid_bits(valid_bits), .dirty_bits(dirty_bits), .writeBackToCache(writeBackToCache), .rdEn(rdEn), 
//.dataBackFromCache(dataBackFromCache), .dataBackFromRAM(dataBackFromRAM), .dataToProc(read_data), .TagWrite(TagWrite), .AddrToRam(AddrToRam), .wrDataToRam(wrDataToRam), .outTagValid(inTagValid), .out_dirty_bit(in_dirty_bit), .WrEntoRam(WrEntoRam), .WrEnProc(wrEnProc));

cache_fsm cc0(.clk(clk), .reset(reset), .Addr(read_address),.wrData(wrDataProc),.rdAddress(wrAddr), .DataWrite(wrData), .tags0(tags0), .tags1(tags1), .tags2(tags2), .tags3(tags3), .valid_bits0(valid_bits0), .valid_bits1(valid_bits1), .valid_bits2(valid_bits2), .valid_bits3(valid_bits3),
.dirty_bits0(dirty_bits0), .dirty_bits1(dirty_bits1), .dirty_bits2(dirty_bits2), .dirty_bits3(dirty_bits3), .writeBackToCache0(writeBackToCache0), .writeBackToCache1(writeBackToCache1), .writeBackToCache2(writeBackToCache2), .writeBackToCache3(writeBackToCache3), 
.rdEnToCache0(rdEnToCache0), .rdEnToCache1(rdEnToCache1), .rdEnToCache2(rdEnToCache2), .rdEnToCache3(rdEnToCache3), .dataBackFromCache0(dataBackFromCache0), .dataBackFromCache1(dataBackFromCache1), .dataBackFromCache2(dataBackFromCache2), .dataBackFromCache3(dataBackFromCache3),
.dataBackFromRAM(dataBackFromRAM), .dataToProc(read_data), .TagWrite(TagWrite), .AddrToRam(AddrToRam), .wrDataToRam(wrDataToRam), .outTagValid(inTagValid), .out_dirty_bit(in_dirty_bit), .WrEntoRam(WrEntoRam), .WrEnProc(wrEnProc),
.valid_cpu_request(valid_cpu_request), .rdEnToRam(rdEnToRam), .valid(valid), .hold(hold));

endmodule
