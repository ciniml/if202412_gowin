.PHONY: all clean compile test view

MODULES_tb_sp := ../src/top_sp.sv ../src/top_sp_infer.sv ../src/top_sp_infer_full.sv $(GOWIN_HOME)/IDE/simlib/gw5a/prim_sim.v
TESTCASES_tb_sp := default infer infer_full

TESTBENCHES := tb_sp
IVERILOG ?= iverilog

all: $(addsuffix -all,$(addprefix test-, $(TESTBENCHES)))
	@echo "Done."

clean: 
	-@$(RM) -r run-*

define testbench-rule
test-$1-all: $(addprefix test-$1-, $(TESTCASES_$1))
	@echo "Done."
endef

define testcase-rule
run-$1-$2/test_bin: $1.sv $(MODULES_$1)
	$(info Compiling $1 $2)
	mkdir -p run-$1-$2
	cd run-$1-$2; $(IVERILOG) -g2012 -s tb_$2 $(abspath $1.sv) $(foreach module,$(MODULES_$1),$(abspath $(module))) -o test_bin

compile-$1-$2: run-$1-$2/test_bin

test-$1-$2: run-$1-$2/test_bin
	cd run-$1-$2; ./test_bin | tee test.log
	@if grep Error run-$1-$2/test.log; then echo "Error."; exit 1; fi

view-$1-$2: run-$1-$2/trace.vcd
	gtkwave run-$1-$2/trace.vcd&
endef

$(foreach testbench,$(TESTBENCHES),$(eval $(call testbench-rule,$(testbench))))
$(foreach testbench,$(TESTBENCHES),$(foreach testcase,$(TESTCASES_$(testbench)),$(eval $(call testcase-rule,$(testbench),$(testcase)))))