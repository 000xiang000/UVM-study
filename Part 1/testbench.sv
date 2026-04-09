`include "uvm_macros.svh"      // 必須包含 UVM 宏定義
import uvm_pkg::*;             // 匯入 UVM 類別庫

class my_driver extends uvm_driver;
  	`uvm_component_utils(my_driver)
	function new(string name = "my_driver", uvm_component parent = null);
  		super.new(name, parent);
	endfunction

	extern virtual task main_phase(uvm_phase phase);
endclass
  
task my_driver::main_phase(uvm_phase phase);
    // --- 關鍵：提起動議，告訴 UVM 先別關機 ---
    phase.raise_objection(this);
  
    // 1. 初始化訊號
    top_tb.rxd   <= 8'b0;
    top_tb.rx_dv <= 1'b0;

    // 2. 等待重置結束 (等待 rst_n 從 0 變為 1)
    while(!top_tb.rst_n) begin
        @(posedge top_tb.clk);
    end

    // 3. 開始驅動 256 筆隨機數據
    for(int i = 0; i < 256; i++) begin
        @(posedge top_tb.clk);         // 每個時鐘上升沿執行一次
        top_tb.rxd   <= $urandom_range(0, 255); // 產生 0-255 的隨機 8-bit 數據
        top_tb.rx_dv <= 1'b1;          // 設為有效
        `uvm_info("my_driver", $sformatf("Data %0d is drived", i), UVM_LOW)
    end

    // 4. 結束驅動，恢復閒置狀態
    @(posedge top_tb.clk);
    top_tb.rx_dv <= 1'b0;
  
    // --- 關鍵：放下動議，告訴 UVM 我做完了，可以關機了 ---
    phase.drop_objection(this);
endtask

module top_tb;
    reg clk;
    reg rst_n;
    wire [7:0] txd;
    wire tx_en;
    reg [7:0] rxd;
    reg rx_dv;
  
	initial begin
        $dumpfile("dump.vcd");
        $dumpvars;
    end
  
    // 實例化你的 RTL (DUT)
    dut my_dut (
        .clk(clk),
        .rst_n(rst_n),
        .rxd(rxd),
        .rx_dv(rx_dv),
        .txd(txd),
        .tx_en(tx_en)
    );

    // 產生時鐘
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // 產生重置訊號
    initial begin
        rst_n = 0;
        #20 rst_n = 1;
    end

    // 啟動 UVM 測試
    initial begin
        run_test("my_driver"); 
    end
endmodule
