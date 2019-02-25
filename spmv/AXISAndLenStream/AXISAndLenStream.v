module ElasticBufferRegExportAXISAndLenStream( // @[:@3.2]
  input        clock, // @[:@4.4]
  input        reset, // @[:@5.4]
  output       io_in_ready, // @[:@6.4]
  input        io_in_valid, // @[:@6.4]
  input  [1:0] io_in_bits, // @[:@6.4]
  input        io_out_ready, // @[:@6.4]
  output       io_out_valid, // @[:@6.4]
  output [1:0] io_out_bits // @[:@6.4]
);
  reg [1:0] outerRegData; // @[AXISAndLenStream.scala 34:27:@8.4]
  reg [31:0] _RAND_0;
  reg  outerRegValid; // @[AXISAndLenStream.scala 35:32:@9.4]
  reg [31:0] _RAND_1;
  reg [1:0] innerRegData; // @[AXISAndLenStream.scala 36:27:@10.4]
  reg [31:0] _RAND_2;
  reg  innerRegValid; // @[AXISAndLenStream.scala 37:32:@11.4]
  reg [31:0] _RAND_3;
  reg  readyReg; // @[AXISAndLenStream.scala 38:23:@12.4]
  reg [31:0] _RAND_4;
  wire  _T_40; // @[AXISAndLenStream.scala 45:59:@18.6]
  wire  _T_41; // @[AXISAndLenStream.scala 45:57:@19.6]
  wire  _T_42; // @[AXISAndLenStream.scala 45:42:@20.6]
  wire  _T_43; // @[AXISAndLenStream.scala 45:40:@21.6]
  wire  _GEN_2; // @[AXISAndLenStream.scala 41:5:@14.4]
  wire  _GEN_3; // @[AXISAndLenStream.scala 41:5:@14.4]
  assign _T_40 = ~ io_out_valid; // @[AXISAndLenStream.scala 45:59:@18.6]
  assign _T_41 = io_out_ready | _T_40; // @[AXISAndLenStream.scala 45:57:@19.6]
  assign _T_42 = ~ _T_41; // @[AXISAndLenStream.scala 45:42:@20.6]
  assign _T_43 = outerRegValid & _T_42; // @[AXISAndLenStream.scala 45:40:@21.6]
  assign _GEN_2 = readyReg ? io_in_valid : outerRegValid; // @[AXISAndLenStream.scala 41:5:@14.4]
  assign _GEN_3 = readyReg ? _T_43 : innerRegValid; // @[AXISAndLenStream.scala 41:5:@14.4]
  assign io_in_ready = readyReg; // @[AXISAndLenStream.scala 50:17:@33.4]
  assign io_out_valid = readyReg ? outerRegValid : innerRegValid; // @[AXISAndLenStream.scala 48:18:@29.4]
  assign io_out_bits = readyReg ? outerRegData : innerRegData; // @[AXISAndLenStream.scala 47:17:@26.4]
`ifdef RANDOMIZE_GARBAGE_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_INVALID_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_REG_INIT
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_MEM_INIT
`define RANDOMIZE
`endif
`ifdef RANDOMIZE
  integer initvar;
  initial begin
    `ifndef verilator
      #0.002 begin end
    `endif
  `ifdef RANDOMIZE_REG_INIT
  _RAND_0 = {1{$random}};
  outerRegData = _RAND_0[1:0];
  `endif // RANDOMIZE_REG_INIT
  `ifdef RANDOMIZE_REG_INIT
  _RAND_1 = {1{$random}};
  outerRegValid = _RAND_1[0:0];
  `endif // RANDOMIZE_REG_INIT
  `ifdef RANDOMIZE_REG_INIT
  _RAND_2 = {1{$random}};
  innerRegData = _RAND_2[1:0];
  `endif // RANDOMIZE_REG_INIT
  `ifdef RANDOMIZE_REG_INIT
  _RAND_3 = {1{$random}};
  innerRegValid = _RAND_3[0:0];
  `endif // RANDOMIZE_REG_INIT
  `ifdef RANDOMIZE_REG_INIT
  _RAND_4 = {1{$random}};
  readyReg = _RAND_4[0:0];
  `endif // RANDOMIZE_REG_INIT
  end
`endif // RANDOMIZE
  always @(posedge clock) begin
    if (readyReg) begin
      outerRegData <= io_in_bits;
    end
    if (reset) begin
      outerRegValid <= 1'h0;
    end else begin
      if (readyReg) begin
        outerRegValid <= io_in_valid;
      end
    end
    if (readyReg) begin
      innerRegData <= outerRegData;
    end
    if (reset) begin
      innerRegValid <= 1'h0;
    end else begin
      if (readyReg) begin
        innerRegValid <= _T_43;
      end
    end
    readyReg <= io_out_ready | _T_40;
  end
endmodule
module ElasticBufferAXISAndLenStream( // @[:@40.2]
  input        clock, // @[:@41.4]
  input        reset, // @[:@42.4]
  output       io_in_ready, // @[:@43.4]
  input        io_in_valid, // @[:@43.4]
  input  [1:0] io_in_bits, // @[:@43.4]
  input        io_out_ready, // @[:@43.4]
  output       io_out_valid, // @[:@43.4]
  output [1:0] io_out_bits // @[:@43.4]
);
  wire  fullBuffer_clock; // @[AXISAndLenStream.scala 21:28:@45.4]
  wire  fullBuffer_reset; // @[AXISAndLenStream.scala 21:28:@45.4]
  wire  fullBuffer_io_in_ready; // @[AXISAndLenStream.scala 21:28:@45.4]
  wire  fullBuffer_io_in_valid; // @[AXISAndLenStream.scala 21:28:@45.4]
  wire [1:0] fullBuffer_io_in_bits; // @[AXISAndLenStream.scala 21:28:@45.4]
  wire  fullBuffer_io_out_ready; // @[AXISAndLenStream.scala 21:28:@45.4]
  wire  fullBuffer_io_out_valid; // @[AXISAndLenStream.scala 21:28:@45.4]
  wire [1:0] fullBuffer_io_out_bits; // @[AXISAndLenStream.scala 21:28:@45.4]
  ElasticBufferRegExportAXISAndLenStream fullBuffer ( // @[AXISAndLenStream.scala 21:28:@45.4]
    .clock(fullBuffer_clock),
    .reset(fullBuffer_reset),
    .io_in_ready(fullBuffer_io_in_ready),
    .io_in_valid(fullBuffer_io_in_valid),
    .io_in_bits(fullBuffer_io_in_bits),
    .io_out_ready(fullBuffer_io_out_ready),
    .io_out_valid(fullBuffer_io_out_valid),
    .io_out_bits(fullBuffer_io_out_bits)
  );
  assign io_in_ready = fullBuffer_io_in_ready; // @[AXISAndLenStream.scala 22:22:@50.4]
  assign io_out_valid = fullBuffer_io_out_valid; // @[AXISAndLenStream.scala 23:12:@52.4]
  assign io_out_bits = fullBuffer_io_out_bits; // @[AXISAndLenStream.scala 23:12:@51.4]
  assign fullBuffer_clock = clock; // @[:@46.4]
  assign fullBuffer_reset = reset; // @[:@47.4]
  assign fullBuffer_io_in_valid = io_in_valid; // @[AXISAndLenStream.scala 22:22:@49.4]
  assign fullBuffer_io_in_bits = io_in_bits; // @[AXISAndLenStream.scala 22:22:@48.4]
  assign fullBuffer_io_out_ready = io_out_ready; // @[AXISAndLenStream.scala 23:12:@53.4]
endmodule
module ElasticBufferRegExportAXISAndLenStream_2( // @[:@107.2]
  input         clock, // @[:@108.4]
  input         reset, // @[:@109.4]
  output        io_in_ready, // @[:@110.4]
  input         io_in_valid, // @[:@110.4]
  input  [31:0] io_in_bits, // @[:@110.4]
  input         io_out_ready, // @[:@110.4]
  output        io_out_valid, // @[:@110.4]
  output [31:0] io_out_bits // @[:@110.4]
);
  reg [31:0] outerRegData; // @[AXISAndLenStream.scala 34:27:@112.4]
  reg [31:0] _RAND_0;
  reg  outerRegValid; // @[AXISAndLenStream.scala 35:32:@113.4]
  reg [31:0] _RAND_1;
  reg [31:0] innerRegData; // @[AXISAndLenStream.scala 36:27:@114.4]
  reg [31:0] _RAND_2;
  reg  innerRegValid; // @[AXISAndLenStream.scala 37:32:@115.4]
  reg [31:0] _RAND_3;
  reg  readyReg; // @[AXISAndLenStream.scala 38:23:@116.4]
  reg [31:0] _RAND_4;
  wire  _T_40; // @[AXISAndLenStream.scala 45:59:@122.6]
  wire  _T_41; // @[AXISAndLenStream.scala 45:57:@123.6]
  wire  _T_42; // @[AXISAndLenStream.scala 45:42:@124.6]
  wire  _T_43; // @[AXISAndLenStream.scala 45:40:@125.6]
  wire  _GEN_2; // @[AXISAndLenStream.scala 41:5:@118.4]
  wire  _GEN_3; // @[AXISAndLenStream.scala 41:5:@118.4]
  assign _T_40 = ~ io_out_valid; // @[AXISAndLenStream.scala 45:59:@122.6]
  assign _T_41 = io_out_ready | _T_40; // @[AXISAndLenStream.scala 45:57:@123.6]
  assign _T_42 = ~ _T_41; // @[AXISAndLenStream.scala 45:42:@124.6]
  assign _T_43 = outerRegValid & _T_42; // @[AXISAndLenStream.scala 45:40:@125.6]
  assign _GEN_2 = readyReg ? io_in_valid : outerRegValid; // @[AXISAndLenStream.scala 41:5:@118.4]
  assign _GEN_3 = readyReg ? _T_43 : innerRegValid; // @[AXISAndLenStream.scala 41:5:@118.4]
  assign io_in_ready = readyReg; // @[AXISAndLenStream.scala 50:17:@137.4]
  assign io_out_valid = readyReg ? outerRegValid : innerRegValid; // @[AXISAndLenStream.scala 48:18:@133.4]
  assign io_out_bits = readyReg ? outerRegData : innerRegData; // @[AXISAndLenStream.scala 47:17:@130.4]
`ifdef RANDOMIZE_GARBAGE_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_INVALID_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_REG_INIT
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_MEM_INIT
`define RANDOMIZE
`endif
`ifdef RANDOMIZE
  integer initvar;
  initial begin
    `ifndef verilator
      #0.002 begin end
    `endif
  `ifdef RANDOMIZE_REG_INIT
  _RAND_0 = {1{$random}};
  outerRegData = _RAND_0[31:0];
  `endif // RANDOMIZE_REG_INIT
  `ifdef RANDOMIZE_REG_INIT
  _RAND_1 = {1{$random}};
  outerRegValid = _RAND_1[0:0];
  `endif // RANDOMIZE_REG_INIT
  `ifdef RANDOMIZE_REG_INIT
  _RAND_2 = {1{$random}};
  innerRegData = _RAND_2[31:0];
  `endif // RANDOMIZE_REG_INIT
  `ifdef RANDOMIZE_REG_INIT
  _RAND_3 = {1{$random}};
  innerRegValid = _RAND_3[0:0];
  `endif // RANDOMIZE_REG_INIT
  `ifdef RANDOMIZE_REG_INIT
  _RAND_4 = {1{$random}};
  readyReg = _RAND_4[0:0];
  `endif // RANDOMIZE_REG_INIT
  end
`endif // RANDOMIZE
  always @(posedge clock) begin
    if (readyReg) begin
      outerRegData <= io_in_bits;
    end
    if (reset) begin
      outerRegValid <= 1'h0;
    end else begin
      if (readyReg) begin
        outerRegValid <= io_in_valid;
      end
    end
    if (readyReg) begin
      innerRegData <= outerRegData;
    end
    if (reset) begin
      innerRegValid <= 1'h0;
    end else begin
      if (readyReg) begin
        innerRegValid <= _T_43;
      end
    end
    readyReg <= io_out_ready | _T_40;
  end
endmodule
module ElasticBufferAXISAndLenStream_2( // @[:@144.2]
  input         clock, // @[:@145.4]
  input         reset, // @[:@146.4]
  output        io_in_ready, // @[:@147.4]
  input         io_in_valid, // @[:@147.4]
  input  [31:0] io_in_bits, // @[:@147.4]
  input         io_out_ready, // @[:@147.4]
  output        io_out_valid, // @[:@147.4]
  output [31:0] io_out_bits // @[:@147.4]
);
  wire  fullBuffer_clock; // @[AXISAndLenStream.scala 21:28:@149.4]
  wire  fullBuffer_reset; // @[AXISAndLenStream.scala 21:28:@149.4]
  wire  fullBuffer_io_in_ready; // @[AXISAndLenStream.scala 21:28:@149.4]
  wire  fullBuffer_io_in_valid; // @[AXISAndLenStream.scala 21:28:@149.4]
  wire [31:0] fullBuffer_io_in_bits; // @[AXISAndLenStream.scala 21:28:@149.4]
  wire  fullBuffer_io_out_ready; // @[AXISAndLenStream.scala 21:28:@149.4]
  wire  fullBuffer_io_out_valid; // @[AXISAndLenStream.scala 21:28:@149.4]
  wire [31:0] fullBuffer_io_out_bits; // @[AXISAndLenStream.scala 21:28:@149.4]
  ElasticBufferRegExportAXISAndLenStream_2 fullBuffer ( // @[AXISAndLenStream.scala 21:28:@149.4]
    .clock(fullBuffer_clock),
    .reset(fullBuffer_reset),
    .io_in_ready(fullBuffer_io_in_ready),
    .io_in_valid(fullBuffer_io_in_valid),
    .io_in_bits(fullBuffer_io_in_bits),
    .io_out_ready(fullBuffer_io_out_ready),
    .io_out_valid(fullBuffer_io_out_valid),
    .io_out_bits(fullBuffer_io_out_bits)
  );
  assign io_in_ready = fullBuffer_io_in_ready; // @[AXISAndLenStream.scala 22:22:@154.4]
  assign io_out_valid = fullBuffer_io_out_valid; // @[AXISAndLenStream.scala 23:12:@156.4]
  assign io_out_bits = fullBuffer_io_out_bits; // @[AXISAndLenStream.scala 23:12:@155.4]
  assign fullBuffer_clock = clock; // @[:@150.4]
  assign fullBuffer_reset = reset; // @[:@151.4]
  assign fullBuffer_io_in_valid = io_in_valid; // @[AXISAndLenStream.scala 22:22:@153.4]
  assign fullBuffer_io_in_bits = io_in_bits; // @[AXISAndLenStream.scala 22:22:@152.4]
  assign fullBuffer_io_out_ready = io_out_ready; // @[AXISAndLenStream.scala 23:12:@157.4]
endmodule
module AXISAndLenStream( // @[:@159.2]
  input         clock, // @[:@160.4]
  input         reset, // @[:@161.4]
  output        io_rdAddr_ready, // @[:@162.4]
  input         io_rdAddr_valid, // @[:@162.4]
  input  [1:0]  io_rdAddr_bits, // @[:@162.4]
  input         io_rdData_ready, // @[:@162.4]
  output        io_rdData_valid, // @[:@162.4]
  output [31:0] io_rdData_bits, // @[:@162.4]
  output        io_wrAddr_ready, // @[:@162.4]
  input         io_wrAddr_valid, // @[:@162.4]
  input  [1:0]  io_wrAddr_bits, // @[:@162.4]
  output        io_wrData_ready, // @[:@162.4]
  input         io_wrData_valid, // @[:@162.4]
  input  [31:0] io_wrData_bits, // @[:@162.4]
  output        io_wrAck, // @[:@162.4]
  output        io_offset_valid, // @[:@162.4]
  output [31:0] io_offset_bits, // @[:@162.4]
  output        io_nnz_valid, // @[:@162.4]
  output [31:0] io_nnz_bits, // @[:@162.4]
  output        io_outputSize_valid, // @[:@162.4]
  output [31:0] io_outputSize_bits, // @[:@162.4]
  output        io_running, // @[:@162.4]
  input         io_done, // @[:@162.4]
  output        io_rowPtrStream_ready, // @[:@162.4]
  input         io_rowPtrStream_valid, // @[:@162.4]
  input  [31:0] io_rowPtrStream_bits, // @[:@162.4]
  input         io_lenStream_ready, // @[:@162.4]
  output        io_lenStream_valid, // @[:@162.4]
  output [31:0] io_lenStream_bits // @[:@162.4]
);
  wire  ElasticBufferAXISAndLenStream_clock; // @[AXISAndLenStream.scala 8:23:@169.4]
  wire  ElasticBufferAXISAndLenStream_reset; // @[AXISAndLenStream.scala 8:23:@169.4]
  wire  ElasticBufferAXISAndLenStream_io_in_ready; // @[AXISAndLenStream.scala 8:23:@169.4]
  wire  ElasticBufferAXISAndLenStream_io_in_valid; // @[AXISAndLenStream.scala 8:23:@169.4]
  wire [1:0] ElasticBufferAXISAndLenStream_io_in_bits; // @[AXISAndLenStream.scala 8:23:@169.4]
  wire  ElasticBufferAXISAndLenStream_io_out_ready; // @[AXISAndLenStream.scala 8:23:@169.4]
  wire  ElasticBufferAXISAndLenStream_io_out_valid; // @[AXISAndLenStream.scala 8:23:@169.4]
  wire [1:0] ElasticBufferAXISAndLenStream_io_out_bits; // @[AXISAndLenStream.scala 8:23:@169.4]
  wire  ElasticBufferAXISAndLenStream_1_clock; // @[AXISAndLenStream.scala 8:23:@185.4]
  wire  ElasticBufferAXISAndLenStream_1_reset; // @[AXISAndLenStream.scala 8:23:@185.4]
  wire  ElasticBufferAXISAndLenStream_1_io_in_ready; // @[AXISAndLenStream.scala 8:23:@185.4]
  wire  ElasticBufferAXISAndLenStream_1_io_in_valid; // @[AXISAndLenStream.scala 8:23:@185.4]
  wire [1:0] ElasticBufferAXISAndLenStream_1_io_in_bits; // @[AXISAndLenStream.scala 8:23:@185.4]
  wire  ElasticBufferAXISAndLenStream_1_io_out_ready; // @[AXISAndLenStream.scala 8:23:@185.4]
  wire  ElasticBufferAXISAndLenStream_1_io_out_valid; // @[AXISAndLenStream.scala 8:23:@185.4]
  wire [1:0] ElasticBufferAXISAndLenStream_1_io_out_bits; // @[AXISAndLenStream.scala 8:23:@185.4]
  wire  ElasticBufferAXISAndLenStream_2_clock; // @[AXISAndLenStream.scala 8:23:@191.4]
  wire  ElasticBufferAXISAndLenStream_2_reset; // @[AXISAndLenStream.scala 8:23:@191.4]
  wire  ElasticBufferAXISAndLenStream_2_io_in_ready; // @[AXISAndLenStream.scala 8:23:@191.4]
  wire  ElasticBufferAXISAndLenStream_2_io_in_valid; // @[AXISAndLenStream.scala 8:23:@191.4]
  wire [31:0] ElasticBufferAXISAndLenStream_2_io_in_bits; // @[AXISAndLenStream.scala 8:23:@191.4]
  wire  ElasticBufferAXISAndLenStream_2_io_out_ready; // @[AXISAndLenStream.scala 8:23:@191.4]
  wire  ElasticBufferAXISAndLenStream_2_io_out_valid; // @[AXISAndLenStream.scala 8:23:@191.4]
  wire [31:0] ElasticBufferAXISAndLenStream_2_io_out_bits; // @[AXISAndLenStream.scala 8:23:@191.4]
  reg  state; // @[AXISAndLenStream.scala 79:24:@164.4]
  reg [31:0] _RAND_0;
  reg [31:0] regs_0; // @[AXISAndLenStream.scala 82:19:@167.4]
  reg [31:0] _RAND_1;
  reg [31:0] regs_1; // @[AXISAndLenStream.scala 82:19:@167.4]
  reg [31:0] _RAND_2;
  reg [31:0] regs_2; // @[AXISAndLenStream.scala 82:19:@167.4]
  reg [31:0] _RAND_3;
  wire  _T_95; // @[AXISAndLenStream.scala 87:54:@176.4]
  wire  _T_99; // @[Mux.scala 46:19:@177.4]
  wire [31:0] _T_100; // @[Mux.scala 46:16:@178.4]
  wire  _T_101; // @[Mux.scala 46:19:@179.4]
  wire [31:0] _T_102; // @[Mux.scala 46:16:@180.4]
  wire  _T_103; // @[Mux.scala 46:19:@181.4]
  wire  wrAddrDataAvailable; // @[AXISAndLenStream.scala 92:46:@197.4]
  wire  _T_110; // @[AXISAndLenStream.scala 99:26:@203.6]
  wire  _T_111; // @[AXISAndLenStream.scala 100:27:@205.8]
  wire  _GEN_1; // @[AXISAndLenStream.scala 99:35:@204.6]
  wire  start; // @[AXISAndLenStream.scala 98:31:@202.4]
  wire  _T_117; // @[AXISAndLenStream.scala 108:49:@213.4]
  wire  _T_118; // @[AXISAndLenStream.scala 108:32:@214.4]
  wire  _T_120; // @[AXISAndLenStream.scala 108:49:@218.4]
  wire  _T_121; // @[AXISAndLenStream.scala 108:32:@219.4]
  wire  _T_123; // @[AXISAndLenStream.scala 108:49:@223.4]
  wire  _T_124; // @[AXISAndLenStream.scala 108:32:@224.4]
  wire  _T_129; // @[Conditional.scala 37:30:@235.4]
  wire  _GEN_7; // @[AXISAndLenStream.scala 124:21:@237.6]
  wire  _GEN_9; // @[AXISAndLenStream.scala 133:23:@248.8]
  wire  _GEN_11; // @[Conditional.scala 39:67:@246.6]
  wire  _GEN_12; // @[Conditional.scala 40:58:@236.4]
  reg  delayedRowPtr_0_valid; // @[AXISAndLenStream.scala 142:32:@260.4]
  reg [31:0] _RAND_4;
  reg [31:0] delayedRowPtr_0_bits; // @[AXISAndLenStream.scala 142:32:@260.4]
  reg [31:0] _RAND_5;
  reg  delayedRowPtr_1_valid; // @[AXISAndLenStream.scala 142:32:@260.4]
  reg [31:0] _RAND_6;
  reg [31:0] delayedRowPtr_1_bits; // @[AXISAndLenStream.scala 142:32:@260.4]
  reg [31:0] _RAND_7;
  wire  _T_197; // @[AXISAndLenStream.scala 145:51:@261.4]
  wire  _T_198; // @[AXISAndLenStream.scala 145:49:@262.4]
  wire  _T_199; // @[AXISAndLenStream.scala 145:77:@263.4]
  wire  _T_200; // @[AXISAndLenStream.scala 145:75:@264.4]
  wire [31:0] _GEN_15; // @[AXISAndLenStream.scala 148:89:@274.6]
  wire  _GEN_16; // @[AXISAndLenStream.scala 148:89:@274.6]
  wire  _GEN_17; // @[AXISAndLenStream.scala 146:19:@266.4]
  wire [31:0] _GEN_18; // @[AXISAndLenStream.scala 146:19:@266.4]
  wire  _T_208; // @[AXISAndLenStream.scala 154:36:@283.6]
  wire [31:0] _GEN_19; // @[AXISAndLenStream.scala 154:63:@284.6]
  wire  _GEN_20; // @[AXISAndLenStream.scala 154:63:@284.6]
  wire  _GEN_21; // @[AXISAndLenStream.scala 152:19:@278.4]
  wire [31:0] _GEN_22; // @[AXISAndLenStream.scala 152:19:@278.4]
  wire [32:0] _T_210; // @[AXISAndLenStream.scala 158:49:@290.4]
  wire [32:0] _T_211; // @[AXISAndLenStream.scala 158:49:@291.4]
  ElasticBufferAXISAndLenStream ElasticBufferAXISAndLenStream ( // @[AXISAndLenStream.scala 8:23:@169.4]
    .clock(ElasticBufferAXISAndLenStream_clock),
    .reset(ElasticBufferAXISAndLenStream_reset),
    .io_in_ready(ElasticBufferAXISAndLenStream_io_in_ready),
    .io_in_valid(ElasticBufferAXISAndLenStream_io_in_valid),
    .io_in_bits(ElasticBufferAXISAndLenStream_io_in_bits),
    .io_out_ready(ElasticBufferAXISAndLenStream_io_out_ready),
    .io_out_valid(ElasticBufferAXISAndLenStream_io_out_valid),
    .io_out_bits(ElasticBufferAXISAndLenStream_io_out_bits)
  );
  ElasticBufferAXISAndLenStream ElasticBufferAXISAndLenStream_1 ( // @[AXISAndLenStream.scala 8:23:@185.4]
    .clock(ElasticBufferAXISAndLenStream_1_clock),
    .reset(ElasticBufferAXISAndLenStream_1_reset),
    .io_in_ready(ElasticBufferAXISAndLenStream_1_io_in_ready),
    .io_in_valid(ElasticBufferAXISAndLenStream_1_io_in_valid),
    .io_in_bits(ElasticBufferAXISAndLenStream_1_io_in_bits),
    .io_out_ready(ElasticBufferAXISAndLenStream_1_io_out_ready),
    .io_out_valid(ElasticBufferAXISAndLenStream_1_io_out_valid),
    .io_out_bits(ElasticBufferAXISAndLenStream_1_io_out_bits)
  );
  ElasticBufferAXISAndLenStream_2 ElasticBufferAXISAndLenStream_2 ( // @[AXISAndLenStream.scala 8:23:@191.4]
    .clock(ElasticBufferAXISAndLenStream_2_clock),
    .reset(ElasticBufferAXISAndLenStream_2_reset),
    .io_in_ready(ElasticBufferAXISAndLenStream_2_io_in_ready),
    .io_in_valid(ElasticBufferAXISAndLenStream_2_io_in_valid),
    .io_in_bits(ElasticBufferAXISAndLenStream_2_io_in_bits),
    .io_out_ready(ElasticBufferAXISAndLenStream_2_io_out_ready),
    .io_out_valid(ElasticBufferAXISAndLenStream_2_io_out_valid),
    .io_out_bits(ElasticBufferAXISAndLenStream_2_io_out_bits)
  );
  assign _T_95 = state == 1'h0; // @[AXISAndLenStream.scala 87:54:@176.4]
  assign _T_99 = 2'h3 == ElasticBufferAXISAndLenStream_io_out_bits; // @[Mux.scala 46:19:@177.4]
  assign _T_100 = _T_99 ? regs_2 : {{31'd0}, _T_95}; // @[Mux.scala 46:16:@178.4]
  assign _T_101 = 2'h2 == ElasticBufferAXISAndLenStream_io_out_bits; // @[Mux.scala 46:19:@179.4]
  assign _T_102 = _T_101 ? regs_1 : _T_100; // @[Mux.scala 46:16:@180.4]
  assign _T_103 = 2'h1 == ElasticBufferAXISAndLenStream_io_out_bits; // @[Mux.scala 46:19:@181.4]
  assign wrAddrDataAvailable = ElasticBufferAXISAndLenStream_1_io_out_valid & ElasticBufferAXISAndLenStream_2_io_out_valid; // @[AXISAndLenStream.scala 92:46:@197.4]
  assign _T_110 = ElasticBufferAXISAndLenStream_1_io_out_bits == 2'h0; // @[AXISAndLenStream.scala 99:26:@203.6]
  assign _T_111 = ElasticBufferAXISAndLenStream_2_io_out_bits[0]; // @[AXISAndLenStream.scala 100:27:@205.8]
  assign _GEN_1 = _T_110 ? _T_111 : 1'h0; // @[AXISAndLenStream.scala 99:35:@204.6]
  assign start = wrAddrDataAvailable ? _GEN_1 : 1'h0; // @[AXISAndLenStream.scala 98:31:@202.4]
  assign _T_117 = ElasticBufferAXISAndLenStream_1_io_out_bits == 2'h1; // @[AXISAndLenStream.scala 108:49:@213.4]
  assign _T_118 = wrAddrDataAvailable & _T_117; // @[AXISAndLenStream.scala 108:32:@214.4]
  assign _T_120 = ElasticBufferAXISAndLenStream_1_io_out_bits == 2'h2; // @[AXISAndLenStream.scala 108:49:@218.4]
  assign _T_121 = wrAddrDataAvailable & _T_120; // @[AXISAndLenStream.scala 108:32:@219.4]
  assign _T_123 = ElasticBufferAXISAndLenStream_1_io_out_bits == 2'h3; // @[AXISAndLenStream.scala 108:49:@223.4]
  assign _T_124 = wrAddrDataAvailable & _T_123; // @[AXISAndLenStream.scala 108:32:@224.4]
  assign _T_129 = 1'h0 == state; // @[Conditional.scala 37:30:@235.4]
  assign _GEN_7 = start ? 1'h1 : state; // @[AXISAndLenStream.scala 124:21:@237.6]
  assign _GEN_9 = io_done ? 1'h0 : state; // @[AXISAndLenStream.scala 133:23:@248.8]
  assign _GEN_11 = state ? _GEN_9 : state; // @[Conditional.scala 39:67:@246.6]
  assign _GEN_12 = _T_129 ? _GEN_7 : _GEN_11; // @[Conditional.scala 40:58:@236.4]
  assign _T_197 = ~ delayedRowPtr_0_valid; // @[AXISAndLenStream.scala 145:51:@261.4]
  assign _T_198 = io_lenStream_ready | _T_197; // @[AXISAndLenStream.scala 145:49:@262.4]
  assign _T_199 = ~ delayedRowPtr_1_valid; // @[AXISAndLenStream.scala 145:77:@263.4]
  assign _T_200 = _T_198 | _T_199; // @[AXISAndLenStream.scala 145:75:@264.4]
  assign _GEN_15 = _T_200 ? io_rowPtrStream_bits : delayedRowPtr_0_bits; // @[AXISAndLenStream.scala 148:89:@274.6]
  assign _GEN_16 = _T_200 ? io_rowPtrStream_valid : delayedRowPtr_0_valid; // @[AXISAndLenStream.scala 148:89:@274.6]
  assign _GEN_17 = io_done ? 1'h0 : _GEN_16; // @[AXISAndLenStream.scala 146:19:@266.4]
  assign _GEN_18 = io_done ? delayedRowPtr_0_bits : _GEN_15; // @[AXISAndLenStream.scala 146:19:@266.4]
  assign _T_208 = io_lenStream_ready | _T_199; // @[AXISAndLenStream.scala 154:36:@283.6]
  assign _GEN_19 = _T_208 ? delayedRowPtr_0_bits : delayedRowPtr_1_bits; // @[AXISAndLenStream.scala 154:63:@284.6]
  assign _GEN_20 = _T_208 ? delayedRowPtr_0_valid : delayedRowPtr_1_valid; // @[AXISAndLenStream.scala 154:63:@284.6]
  assign _GEN_21 = io_done ? 1'h0 : _GEN_20; // @[AXISAndLenStream.scala 152:19:@278.4]
  assign _GEN_22 = io_done ? delayedRowPtr_1_bits : _GEN_19; // @[AXISAndLenStream.scala 152:19:@278.4]
  assign _T_210 = delayedRowPtr_0_bits - delayedRowPtr_1_bits; // @[AXISAndLenStream.scala 158:49:@290.4]
  assign _T_211 = $unsigned(_T_210); // @[AXISAndLenStream.scala 158:49:@291.4]
  assign io_rdAddr_ready = ElasticBufferAXISAndLenStream_io_in_ready; // @[AXISAndLenStream.scala 9:17:@174.4]
  assign io_rdData_valid = ElasticBufferAXISAndLenStream_io_out_valid; // @[AXISAndLenStream.scala 88:21:@184.4]
  assign io_rdData_bits = _T_103 ? regs_0 : _T_102; // @[AXISAndLenStream.scala 87:20:@183.4]
  assign io_wrAddr_ready = ElasticBufferAXISAndLenStream_1_io_in_ready; // @[AXISAndLenStream.scala 9:17:@190.4]
  assign io_wrData_ready = ElasticBufferAXISAndLenStream_2_io_in_ready; // @[AXISAndLenStream.scala 9:17:@196.4]
  assign io_wrAck = ElasticBufferAXISAndLenStream_1_io_out_valid & ElasticBufferAXISAndLenStream_2_io_out_valid; // @[AXISAndLenStream.scala 97:14:@201.4 AXISAndLenStream.scala 104:16:@211.6]
  assign io_offset_valid = _T_129 ? start : 1'h0; // @[AXISAndLenStream.scala 118:21:@232.4 AXISAndLenStream.scala 126:27:@239.8]
  assign io_offset_bits = regs_2; // @[AXISAndLenStream.scala 115:24:@230.4]
  assign io_nnz_valid = _T_129 ? start : 1'h0; // @[AXISAndLenStream.scala 119:18:@233.4 AXISAndLenStream.scala 127:24:@240.8]
  assign io_nnz_bits = regs_0; // @[AXISAndLenStream.scala 113:24:@228.4]
  assign io_outputSize_valid = _T_129 ? start : 1'h0; // @[AXISAndLenStream.scala 120:25:@234.4 AXISAndLenStream.scala 128:31:@241.8]
  assign io_outputSize_bits = regs_1; // @[AXISAndLenStream.scala 114:24:@229.4]
  assign io_running = _T_129 ? 1'h0 : state; // @[AXISAndLenStream.scala 80:16:@166.4 AXISAndLenStream.scala 117:16:@231.4 AXISAndLenStream.scala 132:20:@247.8]
  assign io_rowPtrStream_ready = _T_198 | _T_199; // @[AXISAndLenStream.scala 145:27:@265.4]
  assign io_lenStream_valid = delayedRowPtr_1_valid & delayedRowPtr_0_valid; // @[AXISAndLenStream.scala 157:24:@289.4]
  assign io_lenStream_bits = _T_211[31:0]; // @[AXISAndLenStream.scala 158:24:@293.4]
  assign ElasticBufferAXISAndLenStream_clock = clock; // @[:@170.4]
  assign ElasticBufferAXISAndLenStream_reset = reset; // @[:@171.4]
  assign ElasticBufferAXISAndLenStream_io_in_valid = io_rdAddr_valid; // @[AXISAndLenStream.scala 9:17:@173.4]
  assign ElasticBufferAXISAndLenStream_io_in_bits = io_rdAddr_bits; // @[AXISAndLenStream.scala 9:17:@172.4]
  assign ElasticBufferAXISAndLenStream_io_out_ready = io_rdData_ready; // @[AXISAndLenStream.scala 86:20:@175.4]
  assign ElasticBufferAXISAndLenStream_1_clock = clock; // @[:@186.4]
  assign ElasticBufferAXISAndLenStream_1_reset = reset; // @[:@187.4]
  assign ElasticBufferAXISAndLenStream_1_io_in_valid = io_wrAddr_valid; // @[AXISAndLenStream.scala 9:17:@189.4]
  assign ElasticBufferAXISAndLenStream_1_io_in_bits = io_wrAddr_bits; // @[AXISAndLenStream.scala 9:17:@188.4]
  assign ElasticBufferAXISAndLenStream_1_io_out_ready = ElasticBufferAXISAndLenStream_2_io_out_valid; // @[AXISAndLenStream.scala 93:20:@198.4]
  assign ElasticBufferAXISAndLenStream_2_clock = clock; // @[:@192.4]
  assign ElasticBufferAXISAndLenStream_2_reset = reset; // @[:@193.4]
  assign ElasticBufferAXISAndLenStream_2_io_in_valid = io_wrData_valid; // @[AXISAndLenStream.scala 9:17:@195.4]
  assign ElasticBufferAXISAndLenStream_2_io_in_bits = io_wrData_bits; // @[AXISAndLenStream.scala 9:17:@194.4]
  assign ElasticBufferAXISAndLenStream_2_io_out_ready = ElasticBufferAXISAndLenStream_1_io_out_valid; // @[AXISAndLenStream.scala 94:20:@199.4]
`ifdef RANDOMIZE_GARBAGE_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_INVALID_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_REG_INIT
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_MEM_INIT
`define RANDOMIZE
`endif
`ifdef RANDOMIZE
  integer initvar;
  initial begin
    `ifndef verilator
      #0.002 begin end
    `endif
  `ifdef RANDOMIZE_REG_INIT
  _RAND_0 = {1{$random}};
  state = _RAND_0[0:0];
  `endif // RANDOMIZE_REG_INIT
  `ifdef RANDOMIZE_REG_INIT
  _RAND_1 = {1{$random}};
  regs_0 = _RAND_1[31:0];
  `endif // RANDOMIZE_REG_INIT
  `ifdef RANDOMIZE_REG_INIT
  _RAND_2 = {1{$random}};
  regs_1 = _RAND_2[31:0];
  `endif // RANDOMIZE_REG_INIT
  `ifdef RANDOMIZE_REG_INIT
  _RAND_3 = {1{$random}};
  regs_2 = _RAND_3[31:0];
  `endif // RANDOMIZE_REG_INIT
  `ifdef RANDOMIZE_REG_INIT
  _RAND_4 = {1{$random}};
  delayedRowPtr_0_valid = _RAND_4[0:0];
  `endif // RANDOMIZE_REG_INIT
  `ifdef RANDOMIZE_REG_INIT
  _RAND_5 = {1{$random}};
  delayedRowPtr_0_bits = _RAND_5[31:0];
  `endif // RANDOMIZE_REG_INIT
  `ifdef RANDOMIZE_REG_INIT
  _RAND_6 = {1{$random}};
  delayedRowPtr_1_valid = _RAND_6[0:0];
  `endif // RANDOMIZE_REG_INIT
  `ifdef RANDOMIZE_REG_INIT
  _RAND_7 = {1{$random}};
  delayedRowPtr_1_bits = _RAND_7[31:0];
  `endif // RANDOMIZE_REG_INIT
  end
`endif // RANDOMIZE
  always @(posedge clock) begin
    if (reset) begin
      state <= 1'h0;
    end else begin
      if (_T_129) begin
        if (start) begin
          state <= 1'h1;
        end
      end else begin
        if (state) begin
          if (io_done) begin
            state <= 1'h0;
          end
        end
      end
    end
    if (_T_118) begin
      regs_0 <= ElasticBufferAXISAndLenStream_2_io_out_bits;
    end
    if (_T_121) begin
      regs_1 <= ElasticBufferAXISAndLenStream_2_io_out_bits;
    end
    if (_T_124) begin
      regs_2 <= ElasticBufferAXISAndLenStream_2_io_out_bits;
    end
    if (reset) begin
      delayedRowPtr_0_valid <= 1'h0;
    end else begin
      if (io_done) begin
        delayedRowPtr_0_valid <= 1'h0;
      end else begin
        if (_T_200) begin
          delayedRowPtr_0_valid <= io_rowPtrStream_valid;
        end
      end
    end
    if (reset) begin
      delayedRowPtr_0_bits <= 32'h0;
    end else begin
      if (!(io_done)) begin
        if (_T_200) begin
          delayedRowPtr_0_bits <= io_rowPtrStream_bits;
        end
      end
    end
    if (reset) begin
      delayedRowPtr_1_valid <= 1'h0;
    end else begin
      if (io_done) begin
        delayedRowPtr_1_valid <= 1'h0;
      end else begin
        if (_T_208) begin
          delayedRowPtr_1_valid <= delayedRowPtr_0_valid;
        end
      end
    end
    if (reset) begin
      delayedRowPtr_1_bits <= 32'h0;
    end else begin
      if (!(io_done)) begin
        if (_T_208) begin
          delayedRowPtr_1_bits <= delayedRowPtr_0_bits;
        end
      end
    end
  end
endmodule
