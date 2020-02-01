/***********************************************
 *                                              *
 * Examples for the book Practical UVM          *
 *                                              *
 * Copyright Srivatsa Vasudevan 2010-2020       *
 * All rights reserved                          *
 *                                              *
 * Permission is granted to use this work       * 
 * provided this notice and attached license.txt*
 * are not removed/altered while redistributing *
 * See license.txt for details                  *
 *                                              *
 ************************************************/

/*
 * this class provides the basic transaction required 
 * by the WB Master and WB Slave Agents
 */

`ifndef WB_TRANSACTION__SV
	`define WB_TRANSACTION__SV

	typedef class wb_svtb_config;
	class wb_svtb_transaction ;

		// Different types of read and Write cycles.
		typedef enum {READ, WRITE, BLK_RD, BLK_WR, RMW} kinds_e;
		rand kinds_e kind;

		// This is the status of the transaction
		typedef enum {OK, ACK, RTY, ERR, TIMEOUT ,INFLIGHT , UNKNOWN } status_e;
		rand status_e status;

   
		wb_svtb_config cfg;  // Must be non-NULL to randomize

		typedef enum {CLASSIC, CONSTANT,
			LINEAR, WRAP4, WRAP8, WRAP16,
			EOB} pipelining_e;
		rand pipelining_e next_cycle;

		rand bit [31:0] address;
		rand bit [31:0] data;
		rand bit [ 3:0] sel;
		rand bit [15:0] tgc;
		rand bit [15:0] tga;
		rand bit [15:0] tgd;
		rand bit        lock;
		rand bit [15:0] tag;

		int 		num_wait_states;

		constraint supported {
			next_cycle == CLASSIC;
			kind == READ || kind == WRITE;
		}

		constraint valid_address {
			if (cfg.port_size - cfg.granularity == 1) address[0:0] == 1'b0;
			if (cfg.port_size - cfg.granularity == 2) address[1:0] == 2'b00;
			if (cfg.port_size - cfg.granularity == 3) address[2:0] == 3'b000;
		}

		constraint valid_sel {
			sel inside {8'h01, 8'h03, 8'h07, 8'h0F, 8'h1F, 8'h3F, 8'h7F, 8'hFF};

			//if (cfg.port_size - cfg.granularity == 0) sel[7:1] == 7'h00;
			//if (cfg.port_size - cfg.granularity == 1) sel[7:2] == 6'h00;
			// if (cfg.port_size - cfg.granularity == 2) sel[7:4] == 4'h0;
		}

		constraint wb_svtb_transaction_valid {
			// ToDo: Define constraint to make descriptor valid
			status == OK;
			if (cfg.cycles == wb_svtb_config::CLASSIC ) next_cycle == CLASSIC;

		}

		function new(string name="wb_trans");
			cfg = new;
		endfunction: new


	endclass: wb_svtb_transaction

`endif // WB_TRANSACTION__SV
