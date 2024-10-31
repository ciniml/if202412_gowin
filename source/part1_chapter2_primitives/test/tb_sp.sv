// SPDX-License-Identifier: BSL-1.0
// Copyright Kenta Ida 2024.
// Distributed under the Boost Software License, Version 1.0.
//    (See accompanying file LICENSE_1_0.txt or copy at
//          https://www.boost.org/LICENSE_1_0.txt)
/**
 * @file  tb_sp.sv
 * @brief Test bench for SP module
 */

`timescale 1ns/1ps

module tb #(
    parameter int NUMBER_OF_TESTS = 16384/8*2,
    parameter int USE_INFER = 0 // 0: プリミティブ, 1: 推論, 2: 推論(組込み)
)();
    logic clock = 0;     // クロック
    logic dout_check;

// テスト対象の選択
generate 
    if( USE_INFER == 1 ) begin: dut_block
        top_infer dut(
            .clock(clock),
            .dout_check(dout_check)
        );
    end
    else if( USE_INFER == 2 ) begin: dut_block
        top_infer_full dut(
            .clock(clock),
            .dout_check(dout_check)
        );
    end
    else begin: dut_block
        top dut(
            .clock(clock),
            .dout_check(dout_check)
        );
    end
endgenerate

    int test_index = 0;
    
    always #(5) begin // クロック生成 (5[ns]*2 = 10[ns] period)
        clock = ~clock;
    end
    
    initial begin
        $dumpfile("trace.vcd");      // 波形ファイル出力
        $dumpvars(0, dut_block.dut); // ダンプ内容の指定

        repeat(8) @(posedge clock);

        while( test_index < NUMBER_OF_TESTS ) begin 
            @(posedge clock);
            if( dout_check ) begin  // dout_checkが1ならエラー
                $error("test failed at %d - %d", test_index, dout_check);
            end
            test_index++;
        end
        $finish;
    end
endmodule

module tb_default();
    tb #() tb_inst();
endmodule

module tb_infer();
    tb #(.USE_INFER(1)) tb_inst();
endmodule

module tb_infer_full();
    tb #(.USE_INFER(2)) tb_inst();
endmodule