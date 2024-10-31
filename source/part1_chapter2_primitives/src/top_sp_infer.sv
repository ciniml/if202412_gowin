`default_nettype none

module sp_infer (
    input  wire  clock,
    input  wire  reset,

    input  wire        wre,     // 書き込みイネーブル
    input  wire [10:0] address, // アドレス
    input  wire [7:0]  din,     // メモリの書き込みデータ
    output logic [7:0] dout     // メモリの読み出しデータ
);

logic [7:0]  mem[2047:0];   // メモリ (8ビットx2048)

initial begin
    int i;
    for(i = 0; i < 32; i++) begin   // 先頭256ビット(32バイト)をall-1に初期化
        mem[i] = 8'hff;
    end
end

always_ff @(posedge clock) begin
    if( reset ) begin
        dout <= 8'h00;              // リセット時は0を出力
    end
    else begin
        if( !wre ) begin
            dout <= mem[address];   // WRE=0なら読み出し
        end
    end
    if( wre ) begin
        mem[address] <= din;        // WRE=1なら書き込み
    end
end

endmodule

module top_infer (
    input  wire clock,
    output logic dout_check
);

logic        reset;
logic        wre;     // 書き込みイネーブル
logic [10:0] address; // アドレス
logic [7:0]  din;     // メモリの書き込みデータ
logic [7:0]  dout;    // メモリの読み出しデータ

sp_infer sp_inst(
    .clock  (clock),
    .reset  (reset),
    .wre    (wre),
    .address(address),
    .din    (din),
    .dout   (dout)
);

// リセット信号生成
logic [7:0] reset_reg = '1;
assign reset = reset_reg[0];

always @(posedge clock) begin
    reset_reg <= {1'b0, reset_reg[7:1]};
end 

initial begin
    dout_check = 0;
end

// テスト用のステートマシン
logic       is_read_state = 0;  // 読み出しフェーズ？
logic       check_enable = 0;   // 比較処理有効？
logic [7:0] expected_data;      // 期待値

// アドレスに対するテストデータ生成
function logic [7:0] address_to_data(input logic [10:0] byte_address);
begin
    return byte_address[7:0] ^ {byte_address[9:8], byte_address[10:8], byte_address[10:8]};    // アドレスに対するテストデータ生成
end
endfunction

assign din = address_to_data(address); // 書き込みデータ -> アドレスに対応するテストデータ

always_ff @(posedge clock) begin
    if( reset ) begin
        address <= 10'd0;
        wre <= 1'b1;
        is_read_state <= 0;
        check_enable <= 0;
        expected_data <= 8'h00;
        dout_check <= 0;
    end
    else begin
        address <= address + 11'd1;   // アドレスを1バイト分すすめる

        if( is_read_state ) begin   // 読み出し・比較フェーズ
            check_enable <= 1;  // 比較処理有効
            expected_data <= address_to_data(address); // 期待値を設定
        end
        else begin
            check_enable <= 0;  // 比較処理無効
            dout_check <= 0;    // 比較結果リセット
        end

        if( address == 11'd2047) begin
            wre <= !wre;
            is_read_state <= !is_read_state; // フェーズ切り替え
        end

        if( check_enable ) begin    // 比較処理
            if( dout != expected_data ) begin
                dout_check <= 1;
            end
        end
    end
end

endmodule
`default_nettype wire