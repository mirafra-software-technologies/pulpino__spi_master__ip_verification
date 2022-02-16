`ifndef PULPINO_SPI_MASTER_IP_SCOREBOARD_INCLUDED_
`define PULPINO_SPI_MASTER_IP_SCOREBOARD_INCLUDED_

//--------------------------------------------------------------------------------------------
// Class: pulpino_spi_master_ip_scoreboard
// Used to compare the data sent/received by the master with the slave's data sent/received
//--------------------------------------------------------------------------------------------
class pulpino_spi_master_ip_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(pulpino_spi_master_ip_scoreboard)

  //Variable : apb_master_tx_h
  //Declaring handle for apb_master_tx
  apb_master_tx apb_master_tx_h;

  //Variable : spi_slave_tx_h
  //Declaring handle for spi_slaver_tx
  spi_slave_tx spi_slave_tx_h;
  
  //Variable : apb_master_analysis_fifo
  //Used to store the apb_master_data
  uvm_tlm_analysis_fifo#(apb_master_tx) apb_master_analysis_fifo;

  //Variable : spi_slave_analysis_fifo
  //Used to store the spi_slave_data
  uvm_tlm_analysis_fifo#(spi_slave_tx) spi_slave_analysis_fifo;
  //uvm_tlm_analysis_fifo#(slave_tx) spi_slave_analysis_fifo[NO_OF_SLAVES];

  //Variable : apb_master_tx_count
  //to keep track of number of transactions for master 
  int apb_master_tx_count = 0;

  //Variable : slave_tx_count
  //to keep track of number of transactions for slave 
  int spi_slave_tx_count = 0;

  //Variable byte_data_cmp_verified_master_pwdata_slave_mosi_count
  //to keep track of number of byte wise compared verified master_tx_data
  int byte_data_cmp_verified_master_pwdata_slave_mosi_count = 0;

  //Variable byte_data_cmp_failed_master_pwdata_slave_mosi_count
  //to keep track of number of byte wise compared failed master_tx_data
  int byte_data_cmp_failed_master_pwdata_slave_mosi_count = 0;

  //-------------------------------------------------------
  // Externally defined Tasks and Functions
  //-------------------------------------------------------
  extern function new(string name = "pulpino_spi_master_ip_scoreboard", uvm_component parent = null);
  extern virtual function void build_phase(uvm_phase phase);
  extern virtual task run_phase(uvm_phase phase);
  extern virtual function void check_phase (uvm_phase phase);
  extern virtual function void report_phase(uvm_phase phase);

endclass : pulpino_spi_master_ip_scoreboard

//--------------------------------------------------------------------------------------------
// Construct: new
// Initialization of new memory
//
// Parameters:
//  name - pulpino_spi_master_ip_scoreboard
//  parent - parent under which this component is created
//--------------------------------------------------------------------------------------------
function pulpino_spi_master_ip_scoreboard::new(string name = "pulpino_spi_master_ip_scoreboard",uvm_component parent = null);
super.new(name, parent);
  apb_master_analysis_fifo = new("apb_master_analysis_fifo",this);
  spi_slave_analysis_fifo = new("spi_slave_analysis_fifo",this);
endfunction : new

//--------------------------------------------------------------------------------------------
// Function: build_phase
// Builds its parent components
//
// Parameters:
//  phase - uvm phase
//--------------------------------------------------------------------------------------------
function void pulpino_spi_master_ip_scoreboard::build_phase(uvm_phase phase);
  super.build_phase(phase);
endfunction : build_phase

//--------------------------------------------------------------------------------------------
// Task: run_phase
// Used to give delays and check the wdata and rdata are similar or not
//
// Parameters:
//  phase - uvm phase
//--------------------------------------------------------------------------------------------
task pulpino_spi_master_ip_scoreboard::run_phase(uvm_phase phase);

  super.run_phase(phase);
 
  forever begin

  `uvm_info(get_type_name(),$sformatf("before calling master's analysis fifo get method"),UVM_HIGH)
  apb_master_analysis_fifo.get(apb_master_tx_h);
  apb_master_tx_count++;


  `uvm_info(get_type_name(),$sformatf("after calling master's analysis fifo get method"),UVM_HIGH) 
  `uvm_info(get_type_name(),$sformatf("printing apb_master_tx_h, \n %s",apb_master_tx_h.sprint()),UVM_HIGH)
  `uvm_info(get_type_name(),$sformatf("before calling slave's analysis_fifo"),UVM_HIGH)

  spi_slave_analysis_fifo.get(spi_slave_tx_h);
  spi_slave_tx_count++;

  `uvm_info(get_type_name(),$sformatf("after calling slave's analysis fifo get method"),UVM_HIGH) 
  `uvm_info(get_type_name(),$sformatf("printing spi_slave_tx_h, \n %s",spi_slave_tx_h.sprint()),UVM_HIGH)

   //-------------------------------------------------------
  //Data comparision for master
  //-------------------------------------------------------

  `uvm_info(get_type_name(),$sformatf("--\n-----------------------------------------------SCOREBOARDCOMPARISIONS--------------------------------------------------"),UVM_HIGH)

   //Verifying pwdata in master and slave 
   foreach(spi_slave_tx_h.master_out_slave_in[i])
   if(apb_master_tx_h.pwdata[i] == spi_slave_tx_h.master_out_slave_in[i]) begin
     `uvm_info(get_type_name(),$sformatf("apb_pwdata from apb_master and master_out_slave_in from spi_slave is equal"),UVM_HIGH);
     //`uvm_info("SB_PWDATA_MATCHED WITH MOSI0", $sformatf("Master PWDATA = 'h%0x and Slave
     //           master_out_slave_in['h%0x] = 'h%0x",apb_master_tx_h.pwdata,i,spi_slave_tx_h.master_out_slave_in[i]), UVM_HIGH); 

     byte_data_cmp_verified_master_pwdata_slave_mosi_count++;
   end

    else begin
    `uvm_info(get_type_name(),$sformatf("apb_pwdata from apb_master and master_out_slave_in from slave is not equal"),UVM_HIGH);
    //`uvm_info("SB_PWDATA_MISMATCHED WITH MOSI0", $sformatf("Master PWDATA = 'h%0x and Slave
    //            master_out_slave_in['h%0x] = 'h%0x",apb_master_tx_h.pwdata,i,spi_slave_tx_h.master_out_slave_in[i]), UVM_HIGH); 
    byte_data_cmp_failed_master_pwdata_slave_mosi_count++;
  end
end

endtask : run_phase


//--------------------------------------------------------------------------------------------
// Function: check_phase
// Display the result of simulation
//
// Parameters:
// phase - uvm phase
//--------------------------------------------------------------------------------------------
function void pulpino_spi_master_ip_scoreboard::check_phase(uvm_phase phase);
  super.check_phase(phase);
  `uvm_info(get_type_name(),$sformatf("--\n----------------------------------------------END OF SCOREBOARD CHECK PHASE---------------------------------------"),UVM_HIGH) 
endfunction : check_phase
  

//--------------------------------------------------------------------------------------------
// Function: report_phase
// Display the result of simulation
//
// Parameters:
// phase - uvm phase
//--------------------------------------------------------------------------------------------
function void pulpino_spi_master_ip_scoreboard::report_phase(uvm_phase phase);
  super.report_phase(phase);
  `uvm_info("scoreboard",$sformatf("--\n--------------------------------------------------Scoreboard Report-----------------------------------------------"),UVM_HIGH);
  

  `uvm_info("scoreboard",$sformatf("--\n--------------------------------------------------End of Scoreboard Report-----------------------------------------------"),UVM_HIGH);
endfunction : report_phase



`endif

