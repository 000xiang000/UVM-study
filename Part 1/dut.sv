// 文件：dut.sv
module dut(
    input              clk,
    input              rst_n,
    input        [7:0] rxd,
    input              rx_dv,
    output logic [7:0] txd,   // 直接在這裡宣告類型為 logic (等同於可以賦值的 reg)
    output logic       tx_en  // 同上
);

    always @(posedge clk) begin
        if (!rst_n) begin
            txd   <= 8'b0;
            tx_en <= 1'b0;
        end
        else begin
            txd   <= rxd;
            tx_en <= rx_dv;
        end
    end

endmodule 	
