// UVM
// EXPECT: output type=item2
// EXPECT: output compare=1
// EXPECT: output event seen
// EXPECT: output desired=1 cfg_val=42
// EXPECT: output Number of demoted UVM_ERROR reports  :    1
// EXPECT: output UVM_ERROR :    0
// EXPECT: output UVM_FATAL :    0
// EXPECT: output uvm_tlm_analysis_fifo
// Tested UVM features: field macros (print/clone/compare), uvm_do_with, factory type override,
// virtual sequence with p_sequencer, TLM analysis FIFO, uvm_event_pool, uvm_config_db, register
// model (uvm_reg_block/uvm_reg/uvm_reg_field set/get), report catcher, drain time, print_topology.
`timescale 1ns/1ps
package feat_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class item extends uvm_sequence_item;
    rand bit [7:0] data;
    rand bit [3:0] addr;
    string tag = "t";
    `uvm_object_utils_begin(item)
      `uvm_field_int(data, UVM_ALL_ON)
      `uvm_field_int(addr, UVM_ALL_ON)
      `uvm_field_string(tag, UVM_ALL_ON)
    `uvm_object_utils_end
    function new(string name = "item"); super.new(name); endfunction
  endclass

  class item2 extends item;            // used by a factory override
    `uvm_object_utils(item2)
    constraint c { data == 8'hAA; }
    function new(string name = "item2"); super.new(name); endfunction
  endclass

  class seq extends uvm_sequence #(item);
    `uvm_object_utils(seq)
    function new(string name = "seq"); super.new(name); endfunction
    task body();
      `uvm_do_with(req, { addr == 3; })
      `uvm_do(req)
    endtask
  endclass

  class vseqr extends uvm_sequencer; `uvm_component_utils(vseqr)
    uvm_sequencer #(item) s; function new(string n, uvm_component p); super.new(n, p); endfunction endclass

  class vseq extends uvm_sequence; `uvm_object_utils(vseq) `uvm_declare_p_sequencer(vseqr)
    function new(string name = "vseq"); super.new(name); endfunction
    task body(); seq s = seq::type_id::create("s"); s.start(p_sequencer.s); endtask
  endclass

  class drv extends uvm_driver #(item); `uvm_component_utils(drv)
    uvm_analysis_port #(item) ap;
    function new(string n, uvm_component p); super.new(n, p); endfunction
    function void build_phase(uvm_phase phase); ap = new("ap", this); endfunction
    task run_phase(uvm_phase phase);
      forever begin seq_item_port.get_next_item(req); #10; ap.write(req); seq_item_port.item_done(); end
    endtask
  endclass

  class catcher extends uvm_report_catcher; `uvm_object_utils(catcher)
    function new(string name = "catcher"); super.new(name); endfunction
    function action_e catch(); if (get_id() == "DEMOTE") set_severity(UVM_INFO); return THROW; endfunction
  endclass

  // tiny register model
  class ctrl_reg extends uvm_reg; `uvm_object_utils(ctrl_reg)
    rand uvm_reg_field en;
    function new(string name = "ctrl_reg"); super.new(name, 8, UVM_NO_COVERAGE); endfunction
    function void build(); en = uvm_reg_field::type_id::create("en"); en.configure(this, 1, 0, "RW", 0, 0, 1, 1, 0); endfunction
  endclass
  class blk extends uvm_reg_block; `uvm_object_utils(blk)
    rand ctrl_reg ctrl;
    function new(string name = "blk"); super.new(name, UVM_NO_COVERAGE); endfunction
    function void build();
      ctrl = ctrl_reg::type_id::create("ctrl"); ctrl.configure(this); ctrl.build();
      default_map = create_map("map", 0, 1, UVM_LITTLE_ENDIAN); default_map.add_reg(ctrl, 'h0, "RW"); lock_model();
    endfunction
  endclass

  class test extends uvm_test; `uvm_component_utils(test)
    vseqr vs; uvm_sequencer #(item) sqr; drv d; uvm_tlm_analysis_fifo #(item) fifo; blk regs; uvm_event ev; int cfg_val;
    function new(string n, uvm_component p); super.new(n, p); endfunction
    function void build_phase(uvm_phase phase);
      item::type_id::set_type_override(item2::get_type());
      uvm_config_db#(int)::set(this, "", "cfg_val", 42);
      vs = vseqr::type_id::create("vs", this); sqr = new("sqr", this); d = drv::type_id::create("d", this);
      fifo = new("fifo", this); regs = blk::type_id::create("regs"); regs.build();
      ev = uvm_event_pool::get_global("ev");
      if (!uvm_config_db#(int)::get(this, "", "cfg_val", cfg_val)) `uvm_error("CFG", "get failed")
    endfunction
    function void connect_phase(uvm_phase phase);
      d.seq_item_port.connect(sqr.seq_item_export); d.ap.connect(fifo.analysis_export); vs.s = sqr;
    endfunction
    function void end_of_elaboration_phase(uvm_phase phase); uvm_top.print_topology(); endfunction
    task run_phase(uvm_phase phase);
      vseq v = vseq::type_id::create("v"); item got; item a, b; catcher c = new;
      phase.raise_objection(this); phase.phase_done.set_drain_time(this, 20);
      uvm_report_cb::add(null, c);
      v.start(vs);
      fifo.get(got); `uvm_info("FIFO", $sformatf("got data=%0h addr=%0d type=%s", got.data, got.addr, got.get_type_name()), UVM_NONE)
      a = item::type_id::create("a"); void'(a.randomize()); $cast(b, a.clone());
      `uvm_info("FIELD", $sformatf("compare=%0d\n%s", a.compare(b), a.sprint()), UVM_NONE)
      fork begin #5 ev.trigger(); end join_none ev.wait_trigger(); `uvm_info("EVENT", "event seen", UVM_NONE)
      regs.ctrl.en.set(1); `uvm_info("RAL", $sformatf("desired=%0d cfg_val=%0d", regs.ctrl.get(), cfg_val), UVM_NONE)
      `uvm_error("DEMOTE", "this error is demoted to info by the report catcher")
      phase.drop_objection(this);
    endtask
  endclass
endpackage

module tb; import uvm_pkg::*; import feat_pkg::*; initial run_test("test"); endmodule
