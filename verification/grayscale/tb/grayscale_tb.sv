`timescale 1ns / 1ps

import design_1_axi_vip_0_0_pkg::*;
// axi4-stream vip
import design_1_axi4stream_vip_0_0_pkg::*;
import design_1_axi4stream_vip_1_0_pkg::*;
import axi4stream_vip_pkg::*;
// axi4-lite vip
import axi_vip_pkg::*;


module grayscale_tb ();

    localparam AXIS_CLK_PERIOD = 3;
    localparam AXIL_CLK_PERIOD = 5;
    localparam RST_PERIOD = 10;

    design_1_axi4stream_vip_0_0_mst_t axis_master_agent;
    design_1_axi4stream_vip_1_0_slv_t axis_slave_agent;
    axi4stream_ready_gen axis_ready;
    design_1_axi_vip_0_0_mst_t axi_master_agent;

    // Axi4 Stream
    logic aclk = 0;
    logic aresetn = 0;

    // Axi4 Lite
    logic AxiLiteClk = 0;
    logic aAxiLiteReset_n = 0;

    // dut
    design_1_wrapper dut(
        .aclk            (aclk),
        .aresetn         (aresetn)
    );

    // リセット処理
    initial begin
        #(RST_PERIOD);
        aresetn = 1;
        aAxiLiteReset_n = 1;
    end

    always #(AXIS_CLK_PERIOD) aclk = ~aclk;

    task wait_clk(int n);
        repeat(n) @(posedge aclk);
    endtask

    task init_agent();
        // axi4-lite agent
        axi_master_agent = new("AXI master agent", dut.design_1_i.axi_vip_0.inst.IF);
        axi_master_agent.start_master();

        // axi4-stream agent
        axis_master_agent = new("AXIS master agent", dut.design_1_i.axi4stream_vip_0.inst.IF);
        axis_slave_agent = new("AXIS slave agent", dut.design_1_i.axi4stream_vip_1.inst.IF);
        axis_master_agent.vif_proxy.set_dummy_drive_type(XIL_AXI4STREAM_VIF_DRIVE_NONE);
        axis_slave_agent.vif_proxy.set_dummy_drive_type(XIL_AXI4STREAM_VIF_DRIVE_NONE);
        axis_master_agent.start_master();
        axis_slave_agent.start_slave();

        // ready signal
        ready_gen();
    endtask

    task ready_gen();
        axis_ready = axis_slave_agent.driver.create_ready("ready_gen");
        axis_ready.set_ready_policy(XIL_AXI4STREAM_READY_GEN_OSC);
        axis_ready.set_low_time(0);
        axis_ready.set_high_time(0);
        axis_slave_agent.driver.send_tready(axis_ready);
    endtask

    task wr_tansaction(input logic [31:0] data, input logic user, input logic last);
        axi4stream_transaction wr_trans;
        wr_trans = axis_master_agent.driver.create_transaction("write transaction");
        wr_trans.set_data_beat(data);
        wr_trans.set_user_beat(user);
        wr_trans.set_last(last);
        wr_trans.set_delay(0);
        axis_master_agent.driver.send(wr_trans);
    endtask

    task write_register(bit [31:0] addr, bit [31:0] data);
        xil_axi_resp_t resp;
        axi_master_agent.AXI4LITE_WRITE_BURST(addr, 0, data, resp);
    endtask


    bit [31:0] addr = 32'h0000;
    bit [31:0] data = 32'h0000;

    // シナリオ
    initial begin
        init_agent();

        addr = 32'h44A00000;
        data = 32'h00000001;
        write_register(addr, data);

        for (int i = 0; i < 100; i++) begin
            if (i == 99) begin
                wr_tansaction(i, 1, 1);
            end else begin
                wr_tansaction(i, 1, 0);
            end
        end
        $finish();
    end
endmodule
