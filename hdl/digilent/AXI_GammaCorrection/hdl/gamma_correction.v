module moduleName #(
    parameter AXIS_IN_DATA_WIDTH  = 32,
    parameter AXIS_OUT_DATA_WIDTH = 24,
    parameter BIT_DEPTH           = 10,
    parameter C_S_AXI_DATA_WIDTH  = 32,
    parameter C_S_AXI_ADDR_WIDTH  = 8
) (
    // クロック、リセット
    input  wire CLK_STREAM,
    input  wire CLK_LITE,
    input  wire RST_N,
    // S_AXI4-Stream
    output wire                            S_AXIS_VIDEO_TREADY,
    input  wire [AXIS_IN_DATA_WIDTH-1: 0]  S_AXIS_VIDEO_TDATA,
    input  wire                            S_AXIS_VIDEO_TVALID,
    input  wire                            S_AXIS_VIDEO_TUSER,
    input  wire                            S_AXIS_VIDEO_TLAST,
    // M_AXI4-Stream
    input  wire                            M_AXIS_VIDEO_TREADY,
    output wire [AXIS_OUT_DATA_WIDTH-1: 0] M_AXIS_VIDEO_TDATA,
    output wire                            M_AXIS_VIDEO_TVALID,
    output wire                            M_AXIS_VIDEO_TUSER,
    output wire                            M_AXIS_VIDEO_TLAST,

);
    
endmodule