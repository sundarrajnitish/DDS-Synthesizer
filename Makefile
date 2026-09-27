# DDS synthesizer - open-source formal verification flow
#
#   make            everything: formal flow + simulations + site data
#   make formal     equivalence matrix, bug repair, sequential equivalence,
#                   property proofs, mutants, theorems (+ simulation vs formal)
#   make quick      same, without the slow simulation-vs-formal experiment
#   make sim        GHDL self-checking testbench on every implementation
#   make repair     only the automatic diagnosis & repair of the buggy netlist
#   make site       regenerate docs/data/*.json for the web site
#   make serve      preview the web site on http://localhost:8000
#   make clean
#
# Needs: python3 (+ python-sat, z3-solver), ghdl (>= 3), yosys (>= 0.30).

PY ?= python3

.PHONY: all formal quick sim repair site serve lint clean deps

all: formal sim site

deps:
	$(PY) -m pip install -r requirements.txt

lint:
	$(PY) tools/liberty.py lib/class.lib --self-test
	$(PY) tools/gen_sine_lut.py --check rtl/original/sine_lut_10_x_10.vhd
	mkdir -p build/lint
	ghdl -a --std=93 --workdir=build/lint rtl/sine_lut_pkg.vhd rtl/dds_synthesizer.vhd rtl/dds_synthesizer_lean.vhd
	ghdl -a --std=08 --workdir=build/lint rtl/sine_lut_pkg.vhd rtl/dds_synthesizer.vhd rtl/dds_synthesizer_lean.vhd

formal:
	cd formal && $(PY) -m fv.run_all

quick:
	cd formal && $(PY) -m fv.run_all --quick

repair:
	cd formal && $(PY) -m fv.repair

sim:
	tb/run_sim.sh
	$(PY) tools/dds_model.py --compare build/sim/rtl/trace.csv

site:
	$(PY) tools/export_site_data.py

serve:
	cd docs && $(PY) -m http.server 8000

clean:
	rm -rf build
