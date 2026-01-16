`timescale 1ns / 1ps

module tb_top();

       integer i;
reg [22:0] read_address;
reg [31:0] wrDataProc;
reg wrEnProc;
reg clk,reset;
wire [31:0] read_data;
reg valid_cpu_request;
wire valid;
wire hold;
reg [10:0] read_address_tag;

top t(.read_address(read_address),
            .wrDataProc(wrDataProc),
            .wrEnProc(wrEnProc), //wrEn
            .clk(clk), .reset(reset), .read_data(read_data), .valid_cpu_request(valid_cpu_request), .valid(valid), .hold(hold));
            
initial
    begin
        valid_cpu_request = 1'b1;
        read_address = 23'b0;
        wrDataProc = 32'b0;
        clk = 0;
        
        reset = 1'b1;
        #5
        reset = 1'b0;
    end

initial
    begin
        read_address_tag = 11'b1101_0101_010;
        wrEnProc = 1'b1;
        
       //#130 wrEnProc = 1'b0;
        //#20 wrEnProc = 1'b0;
        #100 $stop;
    end
   
always
    begin
        #1.25; clk <= ~clk;
        
        cache_fsm_tb;
    end
//always
//    begin
//        @(posedge clk);
//        cache_fsm_tb;
//     end
//always @(posedge clk)
//    begin
//        cache_fsm_tb;
//    end
//always@(posedge clk)
//    initial
//    begin


          //read_address <= (read_address + 4)%100;
//Write as Verilog task and call the task
//task()
//
//@(posedge clk);
//#2;
//
 
task cache_fsm_tb;
begin
    if(hold != 1)
    begin
        read_address_tag = read_address_tag + 10;
        read_address = {read_address_tag, 12'b1011101111_10};
        //read_address <= read_address + 4;
        wrDataProc = wrDataProc + 1;
        $display("ISSUING NEW ADDRESS %d at %f", read_address, $time);
    end
 end
 endtask
        //TB for 4 way replacement
//        @(posedge clk);
//        read_address <= 23'h6AABBE;
//        @(posedge clk);
//         read_address <= 23'h6ABBBE;
//        @(posedge clk);
//         read_address <= 23'h6AFBBE;
//        @(posedge clk);
//         read_address <= 23'h6ACBBE;
//        @(posedge clk);
//         read_address <= 23'h6ADBBE;
//        @(posedge clk);
//         read_address <= 23'h6BFBBE;
        
//        #10 read_address <= 23'h6BFBBE;
//        #10 read_address <= 23'h6BCBBE;
//        #10 read_address <= 23'h6FFBBE;
//        #10 read_address <= 23'h6FCBBE;
//        #10 read_address <= 23'h7BFBBE;
//        #10 read_address <= 23'h63CBBE;
//        #10 read_address <= 23'h7EFBBE;
//        #10 read_address <= 23'h7FEBBE;
        
        
        
//        #1.25 read_address <= 23'h6AABBE;
//        #25 read_address <= 23'h4CEC78;
//        #25;
//        #1.25 read_address <= 23'h6AABBE;
//        #25 read_address <= 23'h4CEC78;
//        #1.25 read_address <= 23'h6AABBE;
//        #25 read_address <= 23'h4CEC78;
//        #25;
//        #1.25 read_address <= 23'h6AABBE;
//        #25 read_address <= 23'h4CEC78;
//        #25;
//        #2.5 read_address <= 23'h6AABBE;
//        #2.5 read_address <= 23'h4CEC78;
//        #2.5 read_address = 23'h55387F;
//        #2.5 read_address = 23'h4F77EA;
//        #2.5 read_address = 23'h6AABBA; //(SAME TAG, DIFF INDEX)
//        #2.5 read_address = 23'h6ABBBE; //(DIFF TAG, SAME INDEX) 
//                #2.5 read_address = 23'h6AABBE;
//        #2.5 read_address = 23'h4CEC78;
//        #2.5 read_address = 23'h55387F;
//        #2.5 read_address = 23'h4F77EA;
//        #2.5 read_address = 23'h6AABBA; //(SAME TAG, DIFF INDEX)
//        #2.5 read_address = 23'h6ABBBE; //(DIFF TAG, SAME INDEX) 
//                #2.5 read_address = 23'h6AABBE;
//        #2.5 read_address = 23'h4CEC78;
//        #2.5 read_address = 23'h55387F;
//        #2.5 read_address = 23'h4F77EA;
//        #2.5 read_address = 23'h6AABBA; //(SAME TAG, DIFF INDEX)
//        #2.5 read_address = 23'h6ABBBE; //(DIFF TAG, SAME INDEX) 
//                #2.5 read_address = 23'h6AABBE;
//        #2.5 read_address = 23'h4CEC78;
//        #2.5 read_address = 23'h55387F;
//        #2.5 read_address = 23'h4F77EA;
//        #2.5 read_address = 23'h6AABBA; //(SAME TAG, DIFF INDEX)
//        #2.5 read_address = 23'h6ABBBE; //(DIFF TAG, SAME INDEX) 
//                #2.5 read_address = 23'h6AABBE;
//        #2.5 read_address = 23'h4CEC78;
//        #2.5 read_address = 23'h55387F;
//        #2.5 read_address = 23'h4F77EA;
//        #2.5 read_address = 23'h6AABBA; //(SAME TAG, DIFF INDEX)
//        #2.5 read_address = 23'h6ABBBE; //(DIFF TAG, SAME INDEX) 
        
//                #2.5 read_address = 23'h6AABBE;
//        #2.5 read_address = 23'h4CEC78;
//        #2.5 read_address = 23'h55387F;
//        #2.5 read_address = 23'h4F77EA;
//        #2.5 read_address = 23'h6AABBA; //(SAME TAG, DIFF INDEX)
//        #2.5 read_address = 23'h6ABBBE; //(DIFF TAG, SAME INDEX) 
//                #2.5 read_address = 23'h6AABBE;
//        #2.5 read_address = 23'h4CEC78;
//        #2.5 read_address = 23'h55387F;
//        #2.5 read_address = 23'h4F77EA;
//        #2.5 read_address = 23'h6AABBA; //(SAME TAG, DIFF INDEX)
//        #2.5 read_address = 23'h6ABBBE; //(DIFF TAG, SAME INDEX) 
//                #2.5 read_address = 23'h6AABBE;
//        #2.5 read_address = 23'h4CEC78;
//        #2.5 read_address = 23'h55387F;
//        #2.5 read_address = 23'h4F77EA;
//        #2.5 read_address = 23'h6AABBA; //(SAME TAG, DIFF INDEX)
//        #2.5 read_address = 23'h6ABBBE; //(DIFF TAG, SAME INDEX) 
//                #2.5 read_address = 23'h6AABBE;
//        #2.5 read_address = 23'h4CEC78;
//        #2.5 read_address = 23'h55387F;
//        #2.5 read_address = 23'h4F77EA;
//        #2.5 read_address = 23'h6AABBA; //(SAME TAG, DIFF INDEX)
//        #2.5 read_address = 23'h6ABBBE; //(DIFF TAG, SAME INDEX) 
//                #2.5 read_address = 23'h6AABBE;
//        #2.5 read_address = 23'h4CEC78;
//        #2.5 read_address = 23'h55387F;
//        #2.5 read_address = 23'h4F77EA;
//        #2.5 read_address = 23'h6AABBA; //(SAME TAG, DIFF INDEX)
        //$finish;
    //end
endmodule
