# 第1部第2章 プリミティブの使い方

## 概要

プリミティブの使い方の実験用ソースコードです。
合成用のプロジェクトと、すべての記述で同じ動作となることを確認するためのテストが含まれています。

## テストの実行

### 事前準備

テストを実行するには、事前にGOWIN EDAとIcarus Verilogのインストールが必要です。

GOWIN EDAのインストールは小冊子 vol.3で紹介した手順に従ってください。
https://interface.cqpub.co.jp/vol4_install/

GOWIN EDAインストール後、環境変数 `GOWIN_HOME` にGOWIN EDAインストールディレクトリへのパスを指定してください。

```
export GOWIN_HOME=/path/to/gowin/eda
```

正しいパスの場合、 `$GOWIN_HOME/IDE` および `$GOWIN_HOME/Progammer` が存在します。

例えば、 `/home/user/gowin/1.9.10.01` にインストールしている場合は、

```
export GOWIN_HOME=/home/user/gowin/1.9.10.01
```

となります。

Icarus VerilogはUbuntu Linux環境下では以下のコマンドでインストール可能です。

```shell
sudo apt install iverilog
```

また、テスト結果の波形確認にGTK Waveを使用しますのでこちらもインストールしておきます。

```shell
sudo apt install gtkwave
```

### テスト一覧

* tb_sp-default    - プリミティブを使った実装に対するテストを実行します。
* tb_sp-infer      - 推論対象の記述をモジュールに切り出した実装に対するテストを実行します。
* tb_sp-infer_full - 推論対象の記述をテスト対象のトップモジュールに組み込んで推論する実装に対するテストを実行します。

### テスト実行

[source/part1_chapter2_primitives/test](./test) を開き、以下のコマンドを実行します。

```
make
```

テストに問題なければ、コマンドが正常に終了します。

### 波形確認

```
make view-(テストケース名)
```

を実行すると、GTK Waveを起動してテスト時の波形を表示します。
