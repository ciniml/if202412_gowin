# インターフェース 2024年12月号 別冊付録 サンプルコード

## 概要

本リポジトリは、インターフェース 2022年12月号 別冊付録 6000円ボードで開発スキルアップ Tang Primer 25KでFPGA開発 の第1部第2章、第1部第4章、第2部第2章で説明したデザインのソースコードを公開するためのものです。

## ディレクトリ構成

```
.
├── LICENSE                                                   --- ライセンスファイル
├── README.md                                                 --- このファイル 
└── source
    ├── part1_chapter2_primitives                             --- 第1部第2章 プリミティブ・推論の実験環境
    │   ├── primitives.gprj                                   --- プリミティブ・推論の合成用プロジェクトファイル
    │   ├── README.md                                         --- 使い方説明
    │   ├── src
    │   │   ├── tangprimer25k.cst                             --- TangPrimer25K用配置制約
    │   │   ├── top_sp_infer_full.sv                          --- 推論記述統合版のトップレベルデザイン
    │   │   ├── top_sp_infer.sv                               --- モジュール分離での推論記述版のトップレベルデザイン
    │   │   └── top_sp.sv                                     --- プリミティブでの記述版のトップレベルデザイン
    │   └── test
    │       ├── Makefile                                      --- テスト実行用Makefile
    │       └── tb_sp.sv                                      --- テストベンチ
    ├── part1_chapter4_valid_ready                            --- 第1部第4章 VALID・READYの実験環境
    │   ├── accumulator_handshake.sv                          --- ハンドシェイク付きの積算計算モジュール
    │   ├── accumulator.sv                                    --- ハンドシェイク無しの積算計算モジュール
    │   ├── counter_8bit_full.sv                              --- 8bitカウンタ (スループット1)
    │   ├── counter_8bit.sv                                   --- 8bitカウンタ (スループット1/2)
    │   ├── Makefile                                          --- テスト実行用Makefile
    │   ├── packet_sum.sv                                     --- パケット積算モジュール
    │   ├── register_slice_half.sv                            --- レジスタ・スライス (スループット1/2)
    │   ├── register_slice.sv                                 --- レジスタ・スライス (スループット1)
    │   ├── simple_fifo.sv                                    --- FIFO
    │   ├── tb_accumulator_handshake.sv                       --- ハンドシェイク付きの積算計算モジュールのテスト
    │   ├── tb_accumulator.sv                                 --- ハンドシェイク無しの積算計算モジュールのテスト
    │   ├── tb_counter_8bit_full.sv -> tb_counter_8bit.sv     --- 8bitカウンタのテスト (tb_counter_8bit.svへのシンボリックリンク)
    │   ├── tb_counter_8bit.sv                                --- 8bitカウンタのテスト
    │   ├── tb_packet_sum.sv                                  --- パケット積算モジュールのテスト
    │   └── tb_simple_fifo.sv                                 --- FIFOのテスト
    └── part2_chapter2_uart                                   --- 第2部第2章 UARTの実験環境
        ├── impl
        │   └── uart_process_config.json                      --- UARTプロジェクトの設定
        ├── Makefile                                          --- ビルド用Makefile
        ├── src
        │   ├── tangprimer25k.cst                             --- TangPrimer25Kの配置制約
        │   ├── top.sv                                        --- UARTのトップレベルデザイン
        │   ├── uart_rx.sv                                    --- UART受信モジュール
        │   ├── uart_tx_fixed.sv                              --- UART送信モジュール (固定データ)
        │   └── uart_tx.sv                                    --- UART送信モジュール (ストリーム入力)
        ├── test
        │   ├── Makefile                                      --- UARTのテスト実行用Makefile
        │   └── tb_uart.sv                                    --- UARTのテスト
        └── uart.gprj                                         --- UARTのプロジェクト

```

## ライセンス

本リポジトリに自体に含まれているHDLはすべてCC0の下で利用可能です。簡単にいうと、特にライセンス表記等も必要なく好きに使って問題ないということです。
詳しくはリポジトリに含まれている [LICENSE](./LICENSE)  か、Creative Commonsのサイトを確認してください (https://creativecommons.org/publicdomain/zero/1.0/)

但し、GOWIN EDAで再生成したGOWIN IPのHDL等に関しては、それぞれのライセンスに従います。
