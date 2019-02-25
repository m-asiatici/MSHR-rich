module TLASTGenerator( // @[:@3.2]
  input         clock, // @[:@4.4]
  input         reset, // @[:@5.4]
  output        io_mult_res_ready, // @[:@6.4]
  input         io_mult_res_valid, // @[:@6.4]
  input  [31:0] io_mult_res_bits, // @[:@6.4]
  output        io_row_len_ready, // @[:@6.4]
  input         io_row_len_valid, // @[:@6.4]
  input  [31:0] io_row_len_bits, // @[:@6.4]
  input         io_out_ready, // @[:@6.4]
  output        io_out_valid, // @[:@6.4]
  output [31:0] io_out_bits_data, // @[:@6.4]
  output        io_out_bits_last // @[:@6.4]
);
  reg  state; // @[TLASTGenerator.scala 21:24:@8.4]
  reg [31:0] _RAND_0;
  reg [31:0] count; // @[TLASTGenerator.scala 23:20:@9.4]
  reg [31:0] _RAND_1;
  wire  _T_37; // @[Conditional.scala 37:30:@10.4]
  wire  _T_39; // @[TLASTGenerator.scala 26:55:@12.6]
  wire  _T_40; // @[TLASTGenerator.scala 26:35:@13.6]
  wire  _T_41; // @[TLASTGenerator.scala 26:64:@14.6]
  wire  _T_42; // @[TLASTGenerator.scala 26:85:@15.6]
  wire  _T_44; // @[TLASTGenerator.scala 26:121:@16.6]
  wire  _T_45; // @[TLASTGenerator.scala 26:101:@17.6]
  wire  _GEN_0; // @[TLASTGenerator.scala 26:131:@18.6]
  wire  _T_47; // @[TLASTGenerator.scala 31:31:@25.8]
  wire [32:0] _T_49; // @[TLASTGenerator.scala 31:82:@26.8]
  wire [32:0] _T_50; // @[TLASTGenerator.scala 31:82:@27.8]
  wire [31:0] _T_51; // @[TLASTGenerator.scala 31:82:@28.8]
  wire  _T_52; // @[TLASTGenerator.scala 31:62:@29.8]
  wire  _T_53; // @[TLASTGenerator.scala 31:52:@30.8]
  wire  _GEN_1; // @[TLASTGenerator.scala 31:90:@31.8]
  wire  _GEN_2; // @[Conditional.scala 39:67:@24.6]
  wire  _GEN_3; // @[Conditional.scala 40:58:@11.4]
  wire  _T_61; // @[TLASTGenerator.scala 47:38:@44.8]
  wire  _T_67; // @[TLASTGenerator.scala 55:57:@55.12]
  wire [32:0] _T_73; // @[TLASTGenerator.scala 61:42:@64.16]
  wire [31:0] _T_74; // @[TLASTGenerator.scala 61:42:@65.16]
  wire [31:0] _GEN_5; // @[TLASTGenerator.scala 58:55:@60.14]
  wire  _GEN_7; // @[TLASTGenerator.scala 56:40:@57.12]
  wire [31:0] _GEN_8; // @[TLASTGenerator.scala 56:40:@57.12]
  wire  _GEN_11; // @[TLASTGenerator.scala 52:48:@52.10]
  wire  _GEN_12; // @[TLASTGenerator.scala 52:48:@52.10]
  wire  _GEN_13; // @[TLASTGenerator.scala 52:48:@52.10]
  wire [31:0] _GEN_14; // @[TLASTGenerator.scala 52:48:@52.10]
  wire [31:0] _GEN_15; // @[TLASTGenerator.scala 47:47:@45.8]
  wire  _GEN_16; // @[TLASTGenerator.scala 47:47:@45.8]
  wire  _GEN_17; // @[TLASTGenerator.scala 47:47:@45.8]
  wire  _GEN_18; // @[TLASTGenerator.scala 47:47:@45.8]
  wire  _GEN_19; // @[TLASTGenerator.scala 47:47:@45.8]
  wire [31:0] _GEN_20; // @[TLASTGenerator.scala 47:47:@45.8]
  wire [31:0] _GEN_21; // @[TLASTGenerator.scala 46:36:@43.6]
  wire  _GEN_22; // @[TLASTGenerator.scala 46:36:@43.6]
  wire  _GEN_23; // @[TLASTGenerator.scala 46:36:@43.6]
  wire  _GEN_24; // @[TLASTGenerator.scala 46:36:@43.6]
  wire  _GEN_25; // @[TLASTGenerator.scala 46:36:@43.6]
  wire [31:0] _GEN_26; // @[TLASTGenerator.scala 46:36:@43.6]
  wire [31:0] _GEN_28; // @[TLASTGenerator.scala 73:55:@87.10]
  wire [31:0] _GEN_31; // @[TLASTGenerator.scala 68:53:@76.8]
  wire  _GEN_32; // @[TLASTGenerator.scala 68:53:@76.8]
  wire  _GEN_34; // @[Conditional.scala 39:67:@74.6]
  wire [31:0] _GEN_35; // @[Conditional.scala 39:67:@74.6]
  wire  _GEN_36; // @[Conditional.scala 39:67:@74.6]
  assign _T_37 = 1'h0 == state; // @[Conditional.scala 37:30:@10.4]
  assign _T_39 = io_row_len_bits != 32'h0; // @[TLASTGenerator.scala 26:55:@12.6]
  assign _T_40 = io_row_len_valid & _T_39; // @[TLASTGenerator.scala 26:35:@13.6]
  assign _T_41 = _T_40 & io_mult_res_valid; // @[TLASTGenerator.scala 26:64:@14.6]
  assign _T_42 = _T_41 & io_out_ready; // @[TLASTGenerator.scala 26:85:@15.6]
  assign _T_44 = io_row_len_bits != 32'h1; // @[TLASTGenerator.scala 26:121:@16.6]
  assign _T_45 = _T_42 & _T_44; // @[TLASTGenerator.scala 26:101:@17.6]
  assign _GEN_0 = _T_45 ? 1'h1 : state; // @[TLASTGenerator.scala 26:131:@18.6]
  assign _T_47 = io_out_ready & io_mult_res_valid; // @[TLASTGenerator.scala 31:31:@25.8]
  assign _T_49 = io_row_len_bits - 32'h1; // @[TLASTGenerator.scala 31:82:@26.8]
  assign _T_50 = $unsigned(_T_49); // @[TLASTGenerator.scala 31:82:@27.8]
  assign _T_51 = _T_50[31:0]; // @[TLASTGenerator.scala 31:82:@28.8]
  assign _T_52 = count == _T_51; // @[TLASTGenerator.scala 31:62:@29.8]
  assign _T_53 = _T_47 & _T_52; // @[TLASTGenerator.scala 31:52:@30.8]
  assign _GEN_1 = _T_53 ? 1'h0 : state; // @[TLASTGenerator.scala 31:90:@31.8]
  assign _GEN_2 = state ? _GEN_1 : state; // @[Conditional.scala 39:67:@24.6]
  assign _GEN_3 = _T_37 ? _GEN_0 : _GEN_2; // @[Conditional.scala 40:58:@11.4]
  assign _T_61 = io_row_len_bits == 32'h0; // @[TLASTGenerator.scala 47:38:@44.8]
  assign _T_67 = io_row_len_bits == 32'h1; // @[TLASTGenerator.scala 55:57:@55.12]
  assign _T_73 = count + 32'h1; // @[TLASTGenerator.scala 61:42:@64.16]
  assign _T_74 = _T_73[31:0]; // @[TLASTGenerator.scala 61:42:@65.16]
  assign _GEN_5 = _T_67 ? 32'h0 : _T_74; // @[TLASTGenerator.scala 58:55:@60.14]
  assign _GEN_7 = io_out_ready ? _T_67 : 1'h0; // @[TLASTGenerator.scala 56:40:@57.12]
  assign _GEN_8 = io_out_ready ? _GEN_5 : 32'h0; // @[TLASTGenerator.scala 56:40:@57.12]
  assign _GEN_11 = io_mult_res_valid ? _T_67 : 1'h0; // @[TLASTGenerator.scala 52:48:@52.10]
  assign _GEN_12 = io_mult_res_valid ? io_out_ready : 1'h0; // @[TLASTGenerator.scala 52:48:@52.10]
  assign _GEN_13 = io_mult_res_valid ? _GEN_7 : 1'h0; // @[TLASTGenerator.scala 52:48:@52.10]
  assign _GEN_14 = io_mult_res_valid ? _GEN_8 : 32'h0; // @[TLASTGenerator.scala 52:48:@52.10]
  assign _GEN_15 = _T_61 ? 32'h0 : io_mult_res_bits; // @[TLASTGenerator.scala 47:47:@45.8]
  assign _GEN_16 = _T_61 ? 1'h1 : _GEN_11; // @[TLASTGenerator.scala 47:47:@45.8]
  assign _GEN_17 = _T_61 ? 1'h1 : io_mult_res_valid; // @[TLASTGenerator.scala 47:47:@45.8]
  assign _GEN_18 = _T_61 ? io_out_ready : _GEN_13; // @[TLASTGenerator.scala 47:47:@45.8]
  assign _GEN_19 = _T_61 ? 1'h0 : _GEN_12; // @[TLASTGenerator.scala 47:47:@45.8]
  assign _GEN_20 = _T_61 ? 32'h0 : _GEN_14; // @[TLASTGenerator.scala 47:47:@45.8]
  assign _GEN_21 = io_row_len_valid ? _GEN_15 : io_mult_res_bits; // @[TLASTGenerator.scala 46:36:@43.6]
  assign _GEN_22 = io_row_len_valid ? _GEN_16 : 1'h0; // @[TLASTGenerator.scala 46:36:@43.6]
  assign _GEN_23 = io_row_len_valid ? _GEN_17 : 1'h0; // @[TLASTGenerator.scala 46:36:@43.6]
  assign _GEN_24 = io_row_len_valid ? _GEN_18 : 1'h0; // @[TLASTGenerator.scala 46:36:@43.6]
  assign _GEN_25 = io_row_len_valid ? _GEN_19 : 1'h0; // @[TLASTGenerator.scala 46:36:@43.6]
  assign _GEN_26 = io_row_len_valid ? _GEN_20 : 32'h0; // @[TLASTGenerator.scala 46:36:@43.6]
  assign _GEN_28 = _T_52 ? 32'h0 : _T_74; // @[TLASTGenerator.scala 73:55:@87.10]
  assign _GEN_31 = _T_47 ? _GEN_28 : count; // @[TLASTGenerator.scala 68:53:@76.8]
  assign _GEN_32 = _T_47 ? _T_52 : 1'h0; // @[TLASTGenerator.scala 68:53:@76.8]
  assign _GEN_34 = state ? _T_47 : 1'h0; // @[Conditional.scala 39:67:@74.6]
  assign _GEN_35 = state ? _GEN_31 : count; // @[Conditional.scala 39:67:@74.6]
  assign _GEN_36 = state ? _GEN_32 : 1'h0; // @[Conditional.scala 39:67:@74.6]
  assign io_mult_res_ready = _T_37 ? _GEN_25 : _GEN_34; // @[TLASTGenerator.scala 42:23:@39.4 TLASTGenerator.scala 57:43:@58.14 TLASTGenerator.scala 72:35:@82.10]
  assign io_row_len_ready = _T_37 ? _GEN_24 : _GEN_36; // @[TLASTGenerator.scala 41:22:@38.4 TLASTGenerator.scala 51:38:@49.10 TLASTGenerator.scala 59:44:@61.16 TLASTGenerator.scala 75:38:@89.12]
  assign io_out_valid = _T_37 ? _GEN_23 : _GEN_34; // @[TLASTGenerator.scala 40:18:@37.4 TLASTGenerator.scala 50:34:@48.10 TLASTGenerator.scala 54:34:@54.12 TLASTGenerator.scala 70:30:@78.10]
  assign io_out_bits_data = _T_37 ? _GEN_21 : io_mult_res_bits; // @[TLASTGenerator.scala 38:22:@35.4 TLASTGenerator.scala 48:38:@46.10 TLASTGenerator.scala 53:38:@53.12 TLASTGenerator.scala 69:34:@77.10]
  assign io_out_bits_last = _T_37 ? _GEN_22 : _GEN_36; // @[TLASTGenerator.scala 39:22:@36.4 TLASTGenerator.scala 49:38:@47.10 TLASTGenerator.scala 55:38:@56.12 TLASTGenerator.scala 74:38:@88.12]
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
  count = _RAND_1[31:0];
  `endif // RANDOMIZE_REG_INIT
  end
`endif // RANDOMIZE
  always @(posedge clock) begin
    if (reset) begin
      state <= 1'h0;
    end else begin
      if (_T_37) begin
        if (_T_45) begin
          state <= 1'h1;
        end
      end else begin
        if (state) begin
          if (_T_53) begin
            state <= 1'h0;
          end
        end
      end
    end
    if (_T_37) begin
      if (io_row_len_valid) begin
        if (_T_61) begin
          count <= 32'h0;
        end else begin
          if (io_mult_res_valid) begin
            if (io_out_ready) begin
              if (_T_67) begin
                count <= 32'h0;
              end else begin
                count <= _T_74;
              end
            end else begin
              count <= 32'h0;
            end
          end else begin
            count <= 32'h0;
          end
        end
      end else begin
        count <= 32'h0;
      end
    end else begin
      if (state) begin
        if (_T_47) begin
          if (_T_52) begin
            count <= 32'h0;
          end else begin
            count <= _T_74;
          end
        end
      end
    end
  end
endmodule
