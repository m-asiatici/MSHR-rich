/*
 * fpgamshr.h
 *
 *  Created on: Jul 5, 2018
 *      Author: asiatici
 */

#ifndef FPGAMSHR_H_
#define FPGAMSHR_H_

#include <limits.h>
#include "math.h"
#include "params.h"

#define NUM_SPMV 4
#define NUM_INPUTS 4

#define MEMORY_SPAN (1 << ADDR_BITS)
#define CACHE_SIZE_REDUCTION_VALUES (1 << CACHE_SIZE_REDUCTION_WIDTH)

#if FPGAMSHR_EXISTS
#define FPGAMSHR_BASEADDR XPAR_FPGAMSHR_0_BASEADDR
#define FPGAMSHR_BASE_ADDR ((volatile u64*)(XPAR_FPGAMSHR_0_BASEADDR))
#define CACHE_RECV_REQS_OFFSET (0)
#define CACHE_HITS_OFFSET (1)
#define CACHE_CYCLES_OUT_MISSES_STALL_OFFSET (2)
#define CACHE_CYCLES_OUT_DATA_STALL_OFFSET (3)
#define MSHR_CURRENTLY_USED_OFFSET (REGS_PER_REQ_HANDLER_MODULE)
#define MSHR_MAX_USED_OFFSET (REGS_PER_REQ_HANDLER_MODULE + 1)
#define MSHR_COLLISION_TRIGGER_COUNT_OFFSET (REGS_PER_REQ_HANDLER_MODULE + 2)
#define TRAD_MSHR_CYCLES_MSHR_FULL (REGS_PER_REQ_HANDLER_MODULE + 2)
#define MSHR_CYCLES_IN_COLLISION_OFFSET (REGS_PER_REQ_HANDLER_MODULE + 3)
#define TRAD_MSHR_CYCLES_SE_BUF_FULL (REGS_PER_REQ_HANDLER_MODULE + 3)
#define MSHR_STALL_TRIGGER_COUNT_OFFSET (REGS_PER_REQ_HANDLER_MODULE + 4)
#define MSHR_CYCLES_IN_STALL_OFFSET (REGS_PER_REQ_HANDLER_MODULE + 5)
#define MSHR_ACCEPTED_ALLOCS_OFFSET (REGS_PER_REQ_HANDLER_MODULE + 6)
#define MSHR_ACCEPTED_DEALLOCS_OFFSET (REGS_PER_REQ_HANDLER_MODULE + 7)
#define MSHR_CYCLES_ALLOCS_STALLED_OFFSET (REGS_PER_REQ_HANDLER_MODULE + 8)
#define MSHR_CYCLES_DEALLOCS_STALLED_OFFSET (REGS_PER_REQ_HANDLER_MODULE + 9)
#define MSHR_ENQUEUED_MEM_REQS_OFFSET (REGS_PER_REQ_HANDLER_MODULE + 10)
#define MSHR_CYCLES_OUT_SE_BUF_NOT_READY_OFFSET (REGS_PER_REQ_HANDLER_MODULE + 11)
#define MSHR_ACCUM_USED_MSHR_OFFSET (REGS_PER_REQ_HANDLER_MODULE + 12)
#define SE_BUF_MAX_USED_OFFSET (2*REGS_PER_REQ_HANDLER_MODULE + 1)
#define SE_BUF_MAX_USED_ROWS_OFFSET (2*REGS_PER_REQ_HANDLER_MODULE + 3)
#define SE_BUF_MAX_ROWS_WITH_NEXT_PTR_OFFSET (2*REGS_PER_REQ_HANDLER_MODULE + 5)
#define SE_BUF_CYCLES_IN_FW_STALL_OFFSET (2*REGS_PER_REQ_HANDLER_MODULE + 6)
#define SE_BUF_CYCLES_RESP_GEN_STALL_OFFSET (2*REGS_PER_REQ_HANDLER_MODULE + 7)
#define SE_BUF_CYCLES_WRITE_PIPELINE_STALL_OFFSET (2*REGS_PER_REQ_HANDLER_MODULE + 8)
#define SE_BUF_CYCLES_VALID_NEXT_PTR_STALL_OFFSET (2*REGS_PER_REQ_HANDLER_MODULE + 9)
#define SE_BUF_ACCUM_USED_ENTRIES_OFFSET (2*REGS_PER_REQ_HANDLER_MODULE + 10)
#define SE_BUF_ACCUM_USED_ROWS_OFFSET (2*REGS_PER_REQ_HANDLER_MODULE + 11)
#define RESP_GEN_ACCEPTED_INPUTS_OFFSET (3*REGS_PER_REQ_HANDLER_MODULE)
#define RESP_GEN_RESP_SENT_OUT_OFFSET (3*REGS_PER_REQ_HANDLER_MODULE + 1)
#define RESP_GEN_CYCLES_OUT_NOT_READY_OFFSET (3*REGS_PER_REQ_HANDLER_MODULE + 2)
#define ROB_RECEIVED_REQS (0)
#define ROB_RECEIVED_RESP (1)
#define ROB_CURR_USED_ENTRIES (2)
#define ROB_MAX_USED_ENTRIES (3)
#define ROB_SENT_RESP (4)
#define ROB_CYCLES_FULL_STALLED (5)
#define ROB_CYCLES_REQS_IN_STALLED (6)
#define ROB_CYCLES_REQS_OUT_STALLED (7)
#define ROB_CYCLES_RESP_OUT_STALLED (8)
#define GET_REG_ADDR(x) (FPGAMSHR_BASE_ADDR + x)
#endif

void FPGAMSHR_Clear_stats() {
#if FPGAMSHR_EXISTS
	*(volatile u32*)FPGAMSHR_BASEADDR = 1;
#endif
}

void FPGAMSHR_Profiling_snapshot() {
#if FPGAMSHR_EXISTS
	*(volatile u32*)FPGAMSHR_BASEADDR = 2;
#endif
}

void FPGAMSHR_Get_stats_pretty() {
#if FPGAMSHR_EXISTS
	// get snapshot
	FPGAMSHR_Profiling_snapshot();
	int i;
	for(i = 0; i < NUM_REQ_HANDLERS; i++) {
		printf("Bank %d\n\r", i);
		volatile u64 recv_reqs = *((volatile u64*)(FPGAMSHR_BASEADDR) + i*REGS_PER_REQ_HANDLER);
		volatile u64 hits = *((volatile u64*)(FPGAMSHR_BASEADDR) + i*REGS_PER_REQ_HANDLER + 1);
		printf("Cache: received requests: %"PRIu64"\n\r", recv_reqs);
		printf("Cache: hits: %"PRIu64" (hit rate=%f)\n\r", hits, (float)hits/recv_reqs);
		printf("Cache: cyclesOutMissesStall: %"PRIu64"\n\r", *((volatile u64*)(FPGAMSHR_BASEADDR) + i*REGS_PER_REQ_HANDLER + 2));
		printf("Cache: cyclesOutDataStall: %"PRIu64"\n\r", *((volatile u64*)(FPGAMSHR_BASEADDR) + i*REGS_PER_REQ_HANDLER + 3));
#if MSHR_PER_HASH_TABLE > 0
		printf("MSHR: currentlyUsedMSHR: %"PRIu64"\n\r", *((volatile u64*)(FPGAMSHR_BASEADDR) + i*REGS_PER_REQ_HANDLER + REGS_PER_REQ_HANDLER_MODULE));
		printf("MSHR: maxUsedMSHR: %"PRIu64"\n\r", *((volatile u64*)(FPGAMSHR_BASEADDR) + i*REGS_PER_REQ_HANDLER + REGS_PER_REQ_HANDLER_MODULE + 1));
#if MSHR_HASH_TABLES > 0
		printf("MSHR: collisonTriggerCount: %"PRIu64"\n\r", *((volatile u64*)(FPGAMSHR_BASEADDR) + i*REGS_PER_REQ_HANDLER + REGS_PER_REQ_HANDLER_MODULE + 2));
		printf("MSHR: cyclesSpentHandlingCollisons: %"PRIu64"\n\r", *((volatile u64*)(FPGAMSHR_BASEADDR) + i*REGS_PER_REQ_HANDLER + REGS_PER_REQ_HANDLER_MODULE + 3));
#else // MSHR_HASH_TABLES > 0
		printf("MSHR: cyclesMSHRFull: %"PRIu64"\n\r", *((volatile u64*)(FPGAMSHR_BASEADDR) + i*REGS_PER_REQ_HANDLER + REGS_PER_REQ_HANDLER_MODULE + 2));
		printf("MSHR: cyclesLdBufFull: %"PRIu64"\n\r", *((volatile u64*)(FPGAMSHR_BASEADDR) + i*REGS_PER_REQ_HANDLER + REGS_PER_REQ_HANDLER_MODULE + 3));
#endif // MSHR_HASH_TABLES > 0
		printf("MSHR: stallTriggerCount: %"PRIu64"\n\r", *((volatile u64*)(FPGAMSHR_BASEADDR) + i*REGS_PER_REQ_HANDLER + REGS_PER_REQ_HANDLER_MODULE + 4));
		printf("MSHR: cyclesSpentStalling: %"PRIu64"\n\r", *((volatile u64*)(FPGAMSHR_BASEADDR) + i*REGS_PER_REQ_HANDLER + REGS_PER_REQ_HANDLER_MODULE + 5));
		printf("MSHR: acceptedAllocsCount: %"PRIu64"\n\r", *((volatile u64*)(FPGAMSHR_BASEADDR) + i*REGS_PER_REQ_HANDLER + REGS_PER_REQ_HANDLER_MODULE + 6));
		printf("MSHR: acceptedDeallocsCount: %"PRIu64"\n\r", *((volatile u64*)(FPGAMSHR_BASEADDR) + i*REGS_PER_REQ_HANDLER + REGS_PER_REQ_HANDLER_MODULE + 7));
		printf("MSHR: cyclesAllocsStalled: %"PRIu64"\n\r", *((volatile u64*)(FPGAMSHR_BASEADDR) + i*REGS_PER_REQ_HANDLER + REGS_PER_REQ_HANDLER_MODULE + 8));
		printf("MSHR: cyclesDeallocsStalled: %"PRIu64"\n\r", *((volatile u64*)(FPGAMSHR_BASEADDR) + i*REGS_PER_REQ_HANDLER + REGS_PER_REQ_HANDLER_MODULE + 9));
		printf("MSHR: enqueuedMemReqsCount: %"PRIu64"\n\r", *((volatile u64*)(FPGAMSHR_BASEADDR) + i*REGS_PER_REQ_HANDLER + REGS_PER_REQ_HANDLER_MODULE + 10));
		printf("MSHR: cyclesOutLdBufNotReady: %"PRIu64"\n\r", *((volatile u64*)(FPGAMSHR_BASEADDR) + i*REGS_PER_REQ_HANDLER + REGS_PER_REQ_HANDLER_MODULE + 11));
		printf("MSHR: accumUsedMSHR: %"PRIu64"\n\r", *((volatile u64*)(FPGAMSHR_BASEADDR) + i*REGS_PER_REQ_HANDLER + REGS_PER_REQ_HANDLER_MODULE + 12));
		printf("Subentry buffer: snapshotUsedEntries: %"PRIu64"\n\r", *((volatile u64*)(FPGAMSHR_BASEADDR) + i*REGS_PER_REQ_HANDLER + 2*REGS_PER_REQ_HANDLER_MODULE));
		printf("Subentry buffer: maxUsedEntries: %"PRIu64"\n\r", *((volatile u64*)(FPGAMSHR_BASEADDR) + i*REGS_PER_REQ_HANDLER + 2*REGS_PER_REQ_HANDLER_MODULE + 1));
		printf("Subentry buffer: currentlyUsedRows: %"PRIu64"\n\r", *((volatile u64*)(FPGAMSHR_BASEADDR) + i*REGS_PER_REQ_HANDLER + 2*REGS_PER_REQ_HANDLER_MODULE + 2));
		printf("Subentry buffer: maxUsedRows: %"PRIu64"\n\r", *((volatile u64*)(FPGAMSHR_BASEADDR) + i*REGS_PER_REQ_HANDLER + 2*REGS_PER_REQ_HANDLER_MODULE + 3));
		printf("Subentry buffer: snapshotRowsWithNextRowPtrValid: %"PRIu64"\n\r", *((volatile u64*)(FPGAMSHR_BASEADDR) + i*REGS_PER_REQ_HANDLER + 2*REGS_PER_REQ_HANDLER_MODULE + 4));
		printf("Subentry buffer: maxRowsWithNextRowPtrValid: %"PRIu64"\n\r", *((volatile u64*)(FPGAMSHR_BASEADDR) + i*REGS_PER_REQ_HANDLER + 2*REGS_PER_REQ_HANDLER_MODULE + 5));
		printf("Subentry buffer: cyclesRespGenStall: %"PRIu64"\n\r", *((volatile u64*)(FPGAMSHR_BASEADDR) + i*REGS_PER_REQ_HANDLER + 2*REGS_PER_REQ_HANDLER_MODULE + 6));
		printf("Subentry buffer: cyclesWritePipelineStall: %"PRIu64"\n\r", *((volatile u64*)(FPGAMSHR_BASEADDR) + i*REGS_PER_REQ_HANDLER + 2*REGS_PER_REQ_HANDLER_MODULE + 7));
		printf("Subentry buffer: cyclesValidNextPtrInputStall: %"PRIu64"\n\r", *((volatile u64*)(FPGAMSHR_BASEADDR) + i*REGS_PER_REQ_HANDLER + 2*REGS_PER_REQ_HANDLER_MODULE + 8));
		printf("Subentry buffer: nextPtrCacheHits: %"PRIu64"\n\r", *((volatile u64*)(FPGAMSHR_BASEADDR) + i*REGS_PER_REQ_HANDLER + 2*REGS_PER_REQ_HANDLER_MODULE + 9));
		printf("Subentry buffer: accumUsedEntries: %"PRIu64"\n\r", *((volatile u64*)(FPGAMSHR_BASEADDR) + i*REGS_PER_REQ_HANDLER + 2*REGS_PER_REQ_HANDLER_MODULE + 10));
		printf("Subentry buffer: accumUsedRows: %"PRIu64"\n\r", *((volatile u64*)(FPGAMSHR_BASEADDR) + i*REGS_PER_REQ_HANDLER + 2*REGS_PER_REQ_HANDLER_MODULE + 11));
		printf("RespGen: acceptedInputsCount: %"PRIu64"\n\r", *((volatile u64*)(FPGAMSHR_BASEADDR) + i*REGS_PER_REQ_HANDLER + 3*REGS_PER_REQ_HANDLER_MODULE));
		printf("RespGen: responsesSentOutCount: %"PRIu64"\n\r", *((volatile u64*)(FPGAMSHR_BASEADDR) + i*REGS_PER_REQ_HANDLER + 3*REGS_PER_REQ_HANDLER_MODULE + 1));
		printf("RespGen: cyclesOutNotReady: %"PRIu64"\n\r", *((volatile u64*)(FPGAMSHR_BASEADDR) + i*REGS_PER_REQ_HANDLER + 3*REGS_PER_REQ_HANDLER_MODULE + 2));
#endif // MSHR_PER_HASH_TABLE > 0
	}
	for(i = 0; i < NUM_INPUTS; i++) {
		printf("Input %d\n\r", i);
		printf("ROB: receivedRequests: %"PRIu64"\n\r", *((volatile u64*)(FPGAMSHR_BASEADDR) + (NUM_REQ_HANDLERS + i)*REGS_PER_REQ_HANDLER));
		printf("ROB: receivedResponses: %"PRIu64"\n\r", *((volatile u64*)(FPGAMSHR_BASEADDR) + (NUM_REQ_HANDLERS + i)*REGS_PER_REQ_HANDLER + 1));
		printf("ROB: currentlyUsedEntries: %"PRIu64"\n\r", *((volatile u64*)(FPGAMSHR_BASEADDR) + (NUM_REQ_HANDLERS + i)*REGS_PER_REQ_HANDLER + 2));
		printf("ROB: maxUsedEntries: %"PRIu64"\n\r", *((volatile u64*)(FPGAMSHR_BASEADDR) + (NUM_REQ_HANDLERS + i)*REGS_PER_REQ_HANDLER + 3));
		printf("ROB: sentResponses: %"PRIu64"\n\r", *((volatile u64*)(FPGAMSHR_BASEADDR) + (NUM_REQ_HANDLERS + i)*REGS_PER_REQ_HANDLER + 4));
		printf("ROB: cyclesFullStalled: %"PRIu64"\n\r", *((volatile u64*)(FPGAMSHR_BASEADDR) + (NUM_REQ_HANDLERS + i)*REGS_PER_REQ_HANDLER + 5));
		printf("ROB: cyclesReqsInStalled: %"PRIu64"\n\r", *((volatile u64*)(FPGAMSHR_BASEADDR) + (NUM_REQ_HANDLERS + i)*REGS_PER_REQ_HANDLER + 6));
		printf("ROB: cyclesReqsOutStalled: %"PRIu64"\n\r", *((volatile u64*)(FPGAMSHR_BASEADDR) + (NUM_REQ_HANDLERS + i)*REGS_PER_REQ_HANDLER + 7));
		printf("ROB: cyclesRespOutStalled: %"PRIu64"\n\r", *((volatile u64*)(FPGAMSHR_BASEADDR) + (NUM_REQ_HANDLERS + i)*REGS_PER_REQ_HANDLER + 8));
	}
	volatile u64 cycles = *((volatile u64*)(FPGAMSHR_BASEADDR) + (NUM_INPUTS + NUM_REQ_HANDLERS)*REGS_PER_REQ_HANDLER);
	printf("Total cycles: %"PRIu64"\n\r", cycles);
	printf("extMem not ready: %"PRIu64"\n\r", *((volatile u64*)(FPGAMSHR_BASEADDR) + (NUM_INPUTS + NUM_REQ_HANDLERS)*REGS_PER_REQ_HANDLER + 1));
#endif
}


u64 FPGAMSHR_Get_extMemCyclesNotReady() {
#if FPGAMSHR_EXISTS
	return *((volatile u64*)(FPGAMSHR_BASEADDR) + (NUM_REQ_HANDLERS + NUM_INPUTS)*REGS_PER_REQ_HANDLER + 1);
#endif
}

u64 FPGAMSHR_Get_totalCycles() {
#if FPGAMSHR_EXISTS
	return *((volatile u64*)(FPGAMSHR_BASEADDR) + (NUM_REQ_HANDLERS + NUM_INPUTS)*REGS_PER_REQ_HANDLER);
#endif
}

void FPGAMSHR_Get_stats_header() {
	xil_printf("extMemNotReady ");
	xil_printf("receivedRequests ");
	xil_printf("hits ");
	xil_printf("numMemRequests ");
	xil_printf("cyclesOutMissesStall ");
#if MSHR_PER_HASH_TABLE > 0
	xil_printf("maxUsedMSHR ");
#if MSHR_HASH_TABLES > 0
	xil_printf("cyclesInCollision ");
	xil_printf("cyclesInStall ");
#else // MSHR_HASH_TABLES > 0
	xil_printf("cyclesMSHRFull ");
	xil_printf("cyclesLdBufFull ");
#endif // MSHR_HASH_TABLES > 0
	xil_printf("cyclesOutLdBufNotReady ");
	xil_printf("maxUsedLdBufEntries ");
	xil_printf("maxUsedLdBufRows ");
	xil_printf("maxRowsWithNextRowPtrValid ");
	xil_printf("cyclesRespGenStall ");
	xil_printf("cyclesWritePipelineStall ");
	xil_printf("cyclesValidNextPtrInputStall ");
	xil_printf("nextPtrCacheHits ");
	xil_printf("respGenCyclesOutNotReady ");
	xil_printf("robMaxUsedEntries ");
	xil_printf("robCyclesFullStalled ");
	xil_printf("robReqOutStalled ");
	xil_printf("robRespOutStalled ");
	xil_printf("accumUsedMSHR ");
	xil_printf("accumUsedSubentries ");
	xil_printf("accumUsedRows\n\r");
#endif // MSHR_PER_HASH_TABLE > 0
}

void print_profiling_reg(volatile u64* regOffset) {
	double mean = 0;
	for(int i = 0; i < NUM_REQ_HANDLERS; i++) {
		u64 val = *(regOffset + i*REGS_PER_REQ_HANDLER);
		double delta = val - mean;
		mean += delta / (i + 1);
	}
	printf("%"PRIu64" ", (u64)mean);
}

void print_rob_profiling_reg(volatile u64* regOffset) {
	double mean = 0;
	for(int i = 0; i < NUM_INPUTS; i++) {
		u64 val = *(regOffset + (NUM_REQ_HANDLERS+i)*REGS_PER_REQ_HANDLER);
		double delta = val - mean;
		mean += delta / (i + 1);
	}
	printf("%"PRIu64" ", (u64)mean);
}

void FPGAMSHR_Get_stats_row() {
#if FPGAMSHR_EXISTS
	FPGAMSHR_Profiling_snapshot();
	printf("%"PRIu64" ", FPGAMSHR_Get_extMemCyclesNotReady());
	print_profiling_reg(GET_REG_ADDR(CACHE_RECV_REQS_OFFSET));
	print_profiling_reg(GET_REG_ADDR(CACHE_HITS_OFFSET));
	print_profiling_reg(GET_REG_ADDR(MSHR_ACCEPTED_DEALLOCS_OFFSET));
	print_profiling_reg(GET_REG_ADDR(CACHE_CYCLES_OUT_MISSES_STALL_OFFSET));
#if MSHR_PER_HASH_TABLE > 0
	print_profiling_reg(GET_REG_ADDR(MSHR_MAX_USED_OFFSET));
#if MSHR_HASH_TABLES > 0
	print_profiling_reg(GET_REG_ADDR(MSHR_CYCLES_IN_COLLISION_OFFSET));
	print_profiling_reg(GET_REG_ADDR(MSHR_CYCLES_IN_STALL_OFFSET));
#else // MSHR_HASH_TABLES > 0
	print_profiling_reg(GET_REG_ADDR(TRAD_MSHR_CYCLES_MSHR_FULL));
	print_profiling_reg(GET_REG_ADDR(TRAD_MSHR_CYCLES_SE_BUF_FULL));
#endif // MSHR_HASH_TABLES > 0
	print_profiling_reg(GET_REG_ADDR(MSHR_CYCLES_OUT_SE_BUF_NOT_READY_OFFSET));
	print_profiling_reg(GET_REG_ADDR(SE_BUF_MAX_USED_OFFSET));
	print_profiling_reg(GET_REG_ADDR(SE_BUF_MAX_USED_ROWS_OFFSET));
	print_profiling_reg(GET_REG_ADDR(SE_BUF_MAX_ROWS_WITH_NEXT_PTR_OFFSET));
	print_profiling_reg(GET_REG_ADDR(SE_BUF_CYCLES_IN_FW_STALL_OFFSET));
	print_profiling_reg(GET_REG_ADDR(SE_BUF_CYCLES_RESP_GEN_STALL_OFFSET));
	print_profiling_reg(GET_REG_ADDR(SE_BUF_CYCLES_WRITE_PIPELINE_STALL_OFFSET));
	print_profiling_reg(GET_REG_ADDR(SE_BUF_CYCLES_VALID_NEXT_PTR_STALL_OFFSET));
	print_profiling_reg(GET_REG_ADDR(RESP_GEN_CYCLES_OUT_NOT_READY_OFFSET));
	print_rob_profiling_reg(GET_REG_ADDR(ROB_MAX_USED_ENTRIES));
	print_rob_profiling_reg(GET_REG_ADDR(ROB_CYCLES_FULL_STALLED));
	print_rob_profiling_reg(GET_REG_ADDR(ROB_CYCLES_REQS_OUT_STALLED));
	print_rob_profiling_reg(GET_REG_ADDR(ROB_CYCLES_RESP_OUT_STALLED));
	print_profiling_reg(GET_REG_ADDR(MSHR_ACCUM_USED_MSHR_OFFSET));
	print_profiling_reg(GET_REG_ADDR(SE_BUF_ACCUM_USED_ENTRIES_OFFSET));
	print_profiling_reg(GET_REG_ADDR(SE_BUF_ACCUM_USED_ROWS_OFFSET));
#endif // MSHR_PER_HASH_TABLE > 0	
	fflush(stdout);
#endif
}

void FPGAMSHR_Invalidate_cache() {
#if FPGAMSHR_EXISTS
	*(volatile u32*)FPGAMSHR_BASEADDR = 4;
#endif
}

void FPGAMSHR_Disable_cache() {
#if FPGAMSHR_EXISTS
	*(volatile u32*)FPGAMSHR_BASEADDR = 16;
#endif
}

void FPGAMSHR_Enable_cache() {
#if FPGAMSHR_EXISTS
	*(volatile u32*)FPGAMSHR_BASEADDR = 8;
#endif
}

void FPGAMSHR_SetMaxMSHR(u32 mshr) {
#if FPGAMSHR_EXISTS
	*(volatile u32*)(FPGAMSHR_BASEADDR + 16) = mshr;
#endif
}

void FPGAMSHR_SetCacheDivider(u32 div) {
#if FPGAMSHR_EXISTS
	*(volatile u32*)(FPGAMSHR_BASEADDR + 8) = div;
#endif
}

#endif /* FPGAMSHR_H_ */
