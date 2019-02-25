#define DEBUG_DATA_READ 0
#define DEBUG_DMA 0
#define DEBUG_CHECK_RESULTS 0

// ## removes the preceding comma when there are 0 arguments in __VA_ARGS__
#define debug_printf(fmt, debug_cond, ...) do { if (debug_cond) xil_printf(fmt, ## __VA_ARGS__); } while (0)
#define debug_data_read_printf(fmt, ...) debug_printf(fmt, DEBUG_DATA_READ, ## __VA_ARGS__)
#define debug_dma_printf(fmt, ...) debug_printf(fmt, DEBUG_DMA, ## __VA_ARGS__)
#define debug_check_results_printf(fmt, ...) debug_printf(fmt, DEBUG_CHECK_RESULTS, ## __VA_ARGS__)

#include <stdio.h>
#include <stdlib.h>
#include "xil_printf.h"
#include "xstatus.h"
#include "xfully_pipelined_spmv.h"
#include "xil_exception.h"
#include "xtmrctr.h"
#include "xaxidma.h"
#include "ff.h"
#include "inttypes.h"
#include "fpgamshr.h"

u32 nnz[NUM_SPMV];
u32 rows[NUM_SPMV];
u32 cols;

float* val_mem[NUM_SPMV] = {NULL};
unsigned* col_mem[NUM_SPMV] = {NULL};
u32* rowptr_mem[NUM_SPMV] = {NULL};
float* vect_mem = (float*)MEM_BASE_ADDR;
float* ref_output_mem[NUM_SPMV] = {NULL};
float* output_mem[NUM_SPMV];

#define NUM_BENCHMARKS EDIT_ME

char* benchmarks[NUM_BENCHMARKS] = {EDIT ME};

//#define NUM_BENCHMARKS 14
//char* benchmarks[NUM_BENCHMARKS] = {"pds-80", "amazon-2", "cnr-2000", "dblp-201", "enron", "eu-2005", "flickr",
//		"in-2004", "internet","ljournal", "rail4284", "webbase-", "youtube", "bcspwr01"};

XAxiDma row_dma[NUM_SPMV];
XAxiDma_Config *row_dma_cfg[NUM_SPMV];
XAxiDma val_dma[NUM_SPMV];
XAxiDma_Config *val_dma_cfg[NUM_SPMV];
XAxiDma col_dma[NUM_SPMV];
XAxiDma_Config *col_dma_cfg[NUM_SPMV];

#define NUM_DMAS 3

u32 spmv_base_addrs[] = {
		XPAR_FULLYPIPELINEDSPMVRTL_0_BASEADDR,
		XPAR_FULLYPIPELINEDSPMVRTL_1_BASEADDR,
		XPAR_FULLYPIPELINEDSPMVRTL_2_BASEADDR,
		XPAR_FULLYPIPELINEDSPMVRTL_3_BASEADDR
};

u32 row_dma_device_id[] = {
		XPAR_AXI_DMA_0_DEVICE_ID,
		XPAR_AXI_DMA_3_DEVICE_ID,
		XPAR_AXI_DMA_6_DEVICE_ID,
		XPAR_AXI_DMA_9_DEVICE_ID
};

u32 col_dma_device_id[] = {
		XPAR_AXI_DMA_1_DEVICE_ID,
		XPAR_AXI_DMA_4_DEVICE_ID,
		XPAR_AXI_DMA_7_DEVICE_ID,
		XPAR_AXI_DMA_10_DEVICE_ID
};


u32 val_dma_device_id[] = {
		XPAR_AXI_DMA_2_DEVICE_ID,
		XPAR_AXI_DMA_5_DEVICE_ID,
		XPAR_AXI_DMA_8_DEVICE_ID,
		XPAR_AXI_DMA_11_DEVICE_ID
};



XTmrCtr spmv_axis_timer;

volatile int timer_val;
volatile int irq_flag = 0;

int Init_dma(){
	int i;
	for(i = 0; i < NUM_SPMV; i++) {
		row_dma_cfg[i] = XAxiDma_LookupConfig(row_dma_device_id[i]);
		if (row_dma_cfg[i]) {
			int status = XAxiDma_CfgInitialize(&row_dma[i], row_dma_cfg[i]);
			if (status != XST_SUCCESS) {
				printf("Error initializing AxiDMA core %d\n\r", i);
				return -1;
			}
		}
		val_dma_cfg[i] = XAxiDma_LookupConfig(val_dma_device_id[i]);
		if (val_dma_cfg[i]) {
			int status = XAxiDma_CfgInitialize(&val_dma[i], val_dma_cfg[i]);
			if (status != XST_SUCCESS) {
				printf("Error initializing AxiDMA core %d\n\r", i);
				return -2;
			}
		}
		col_dma_cfg[i] = XAxiDma_LookupConfig(col_dma_device_id[i]);
		if (col_dma_cfg[i]) {
			int status = XAxiDma_CfgInitialize(&col_dma[i], col_dma_cfg[i]);
			if (status != XST_SUCCESS) {
				printf("Error initializing AxiDMA core %d\n\r", i);
				return -2;
			}
		}
	}
	return 0;
}

#define MAX_TRANSFER_SIZE_BYTES (8*1024*1024 - 8)

int Test_spmv_mult_axis(int num_spmv){

	typedef struct {
		u32 next_start_addr;
		u32 bytes_left;
	} dma_state_t;

	typedef struct {
		dma_state_t val;
		dma_state_t col;
		dma_state_t rowptr;
		dma_state_t output;
	} spmv_dma_state_t;

	spmv_dma_state_t dma_state[num_spmv];

	int i;

	for(i = 0; i < num_spmv; i++) {
		dma_state[i].val.next_start_addr = (u32)val_mem[i];
		dma_state[i].val.bytes_left = nnz[i] * sizeof(float);
		dma_state[i].col.next_start_addr = (u32)col_mem[i];
		dma_state[i].col.bytes_left = nnz[i] * sizeof(unsigned);

		dma_state[i].rowptr.next_start_addr = (u32)rowptr_mem[i];
		dma_state[i].rowptr.bytes_left = (rows[i] + 1)*sizeof(int);

		dma_state[i].output.next_start_addr = (u32)output_mem[i];
		dma_state[i].output.bytes_left = rows[i] * sizeof(float);

		Xil_DCacheFlushRange((u32)val_mem[i], nnz[i] * sizeof(float));
		Xil_DCacheFlushRange((u32)col_mem[i], nnz[i] * sizeof(unsigned));
		Xil_DCacheFlushRange((u32)rowptr_mem[i], (rows[i] + 1) * sizeof(u32));
		Xil_DCacheInvalidateRange((u32)output_mem[i], rows[i] * sizeof(float));
		XSpmv_mult_axis_Set_val_size(i, (u32)nnz[i]);
		XSpmv_mult_axis_Set_output_size(i, (u32)rows[i]);
		XSpmv_mult_axis_Set_vect_mem(i, (u32)vect_mem);

		debug_dma_printf("i=%d, curr_nnz=%d, curr_row_num=%d\n\r", i, nnz[i], rows[i]);
	}

	int ret_val;
	for(i = 0; i < num_spmv; i++)
	{
		int bytes_to_send = dma_state[i].val.bytes_left > MAX_TRANSFER_SIZE_BYTES ? MAX_TRANSFER_SIZE_BYTES : dma_state[i].val.bytes_left;
		debug_dma_printf("Sending %d bytes from addr 0x%08X on val[%d]\n\r", bytes_to_send, dma_state[i].val.next_start_addr, i);
		if((ret_val = XAxiDma_SimpleTransfer(&val_dma[i], dma_state[i].val.next_start_addr, bytes_to_send, XAXIDMA_DMA_TO_DEVICE)) != XST_SUCCESS) {
			xil_printf("Error starting val_dma[%d] (code %d)\n\r", i, ret_val);
			return XST_FAILURE;
		}
		dma_state[i].val.next_start_addr += bytes_to_send;
		dma_state[i].val.bytes_left -= bytes_to_send;

		bytes_to_send = dma_state[i].col.bytes_left > MAX_TRANSFER_SIZE_BYTES ? MAX_TRANSFER_SIZE_BYTES : dma_state[i].col.bytes_left;
		debug_dma_printf("Sending %d bytes from addr 0x%08X on col[%d]\n\r", bytes_to_send, dma_state[i].col.next_start_addr, i);
		if((ret_val = XAxiDma_SimpleTransfer(&col_dma[i], dma_state[i].col.next_start_addr, bytes_to_send, XAXIDMA_DMA_TO_DEVICE)) != XST_SUCCESS) {
			xil_printf("Error starting col_dma[%d] (code %d)\n\r", i, ret_val);
			return XST_FAILURE;
		}
		dma_state[i].col.next_start_addr += bytes_to_send;
		dma_state[i].col.bytes_left -= bytes_to_send;

		bytes_to_send = dma_state[i].rowptr.bytes_left > MAX_TRANSFER_SIZE_BYTES ? MAX_TRANSFER_SIZE_BYTES : dma_state[i].rowptr.bytes_left;
		debug_dma_printf("Sending %d bytes from addr 0x%08X on rowptr[%d]\n\r", bytes_to_send, dma_state[i].rowptr.next_start_addr, i);
		if((ret_val = XAxiDma_SimpleTransfer(&row_dma[i], dma_state[i].rowptr.next_start_addr, bytes_to_send, XAXIDMA_DMA_TO_DEVICE)) != XST_SUCCESS) {
			xil_printf("Error starting row_dma[%d] (code %d)\n\r", i, ret_val);
			return XST_FAILURE;
		}
		dma_state[i].rowptr.next_start_addr += bytes_to_send;
		dma_state[i].rowptr.bytes_left -= bytes_to_send;

		bytes_to_send = dma_state[i].output.bytes_left > MAX_TRANSFER_SIZE_BYTES ? MAX_TRANSFER_SIZE_BYTES : dma_state[i].output.bytes_left;
		debug_dma_printf("Sending %d bytes to addr 0x%08X from output[%d]\n\r", bytes_to_send, dma_state[i].output.next_start_addr, i);
		if((ret_val = XAxiDma_SimpleTransfer(&row_dma[i], dma_state[i].output.next_start_addr, bytes_to_send, XAXIDMA_DEVICE_TO_DMA)) != XST_SUCCESS) {
			xil_printf("Error starting output_dma[%d] (code %d)\n\r", i, ret_val);
			return XST_FAILURE;
		}
		dma_state[i].output.next_start_addr += bytes_to_send;
		dma_state[i].output.bytes_left -= bytes_to_send;
	}

    XTmrCtr_SetResetValue(&spmv_axis_timer, 0, 0);
    XTmrCtr_Start(&spmv_axis_timer, 0);
    for(i = 0; i < num_spmv; i++)
    {
		XSpmv_mult_axis_Start(i);
	}

    int any_transfers_pending = 1;
    while(any_transfers_pending) {
    	any_transfers_pending = 0;
		for(i = 0; i < num_spmv; i++)
		{
			if(dma_state[i].val.bytes_left > 0) {
				any_transfers_pending = 1;
				if(!XAxiDma_Busy(&val_dma[i], XAXIDMA_DMA_TO_DEVICE)) {
					int bytes_to_send = dma_state[i].val.bytes_left > MAX_TRANSFER_SIZE_BYTES ? MAX_TRANSFER_SIZE_BYTES : dma_state[i].val.bytes_left;
					debug_dma_printf("Sending %d bytes from addr 0x%08X on val[%d]\n\r", bytes_to_send, dma_state[i].val.next_start_addr, i);
					if((ret_val = XAxiDma_SimpleTransfer(&val_dma[i], dma_state[i].val.next_start_addr, bytes_to_send, XAXIDMA_DMA_TO_DEVICE)) != XST_SUCCESS) {
						xil_printf("Error starting val_dma[%d] (code %d)\n\r", i, ret_val);
						return XST_FAILURE;
					}
					dma_state[i].val.next_start_addr += bytes_to_send;
					dma_state[i].val.bytes_left -= bytes_to_send;
				}
			}
			if(dma_state[i].col.bytes_left > 0) {
				any_transfers_pending = 1;
				if(!XAxiDma_Busy(&col_dma[i], XAXIDMA_DMA_TO_DEVICE)) {
					int bytes_to_send = dma_state[i].col.bytes_left > MAX_TRANSFER_SIZE_BYTES ? MAX_TRANSFER_SIZE_BYTES : dma_state[i].col.bytes_left;
					debug_dma_printf("Sending %d bytes from addr 0x%08X on col[%d]\n\r", bytes_to_send, dma_state[i].col.next_start_addr, i);
					if((ret_val = XAxiDma_SimpleTransfer(&col_dma[i], dma_state[i].col.next_start_addr, bytes_to_send, XAXIDMA_DMA_TO_DEVICE)) != XST_SUCCESS) {
						xil_printf("Error starting col_dma[%d] (code %d)\n\r", i, ret_val);
						return XST_FAILURE;
					}
					dma_state[i].col.next_start_addr += bytes_to_send;
					dma_state[i].col.bytes_left -= bytes_to_send;
				}
			}
			if(dma_state[i].rowptr.bytes_left > 0) {
				any_transfers_pending = 1;
				if(!XAxiDma_Busy(&row_dma[i], XAXIDMA_DMA_TO_DEVICE)) {
					int bytes_to_send = dma_state[i].rowptr.bytes_left > MAX_TRANSFER_SIZE_BYTES ? MAX_TRANSFER_SIZE_BYTES : dma_state[i].rowptr.bytes_left;
					debug_dma_printf("Sending %d bytes from addr 0x%08X on rowptr[%d]\n\r", bytes_to_send, dma_state[i].rowptr.next_start_addr, i);
					if((ret_val = XAxiDma_SimpleTransfer(&row_dma[i], dma_state[i].rowptr.next_start_addr, bytes_to_send, XAXIDMA_DMA_TO_DEVICE)) != XST_SUCCESS) {
						xil_printf("Error starting row_dma[%d] (code %d)\n\r", i, ret_val);
						return XST_FAILURE;
					}
					dma_state[i].rowptr.next_start_addr += bytes_to_send;
					dma_state[i].rowptr.bytes_left -= bytes_to_send;
				}
			}
			if(dma_state[i].output.bytes_left > 0) {
				any_transfers_pending = 1;
				if(!XAxiDma_Busy(&row_dma[i], XAXIDMA_DEVICE_TO_DMA)) {
					int bytes_to_send = dma_state[i].output.bytes_left > MAX_TRANSFER_SIZE_BYTES ? MAX_TRANSFER_SIZE_BYTES : dma_state[i].output.bytes_left;
					debug_dma_printf("Sending %d bytes to addr 0x%08X from output[%d]\n\r", bytes_to_send, dma_state[i].output.next_start_addr, i);
					if((ret_val = XAxiDma_SimpleTransfer(&row_dma[i], dma_state[i].output.next_start_addr, bytes_to_send, XAXIDMA_DEVICE_TO_DMA)) != XST_SUCCESS) {
						xil_printf("Error starting output_dma[%d] (code %d)\n\r", i, ret_val);
						return XST_FAILURE;
					}
					dma_state[i].output.next_start_addr += bytes_to_send;
					dma_state[i].output.bytes_left -= bytes_to_send;
				}
			}
		}
    }

	int all_idle = 0;
	while(!all_idle)
	{
		all_idle = 1;
		for(i = 0; i < num_spmv; i++)
		{
			all_idle &= XSpmv_mult_axis_IsIdle(i);
		}
	}
    irq_flag = 0;
    XTmrCtr_Stop(&spmv_axis_timer, 0);

    all_idle = 0;
    while(!all_idle)
    {
    	all_idle = 1;
		for(i = 0; i < num_spmv; i++)
		{
			all_idle &= !XAxiDma_Busy(&row_dma[i], XAXIDMA_DEVICE_TO_DMA);
		}
    }

    xil_printf("%u ", XTmrCtr_GetValue(&spmv_axis_timer, 0));

    for(i = 0; i < num_spmv; i++)
    	Xil_DCacheInvalidateRange((u32)output_mem[i], rows[i] * sizeof(float));
    return XST_SUCCESS;
}

void Compare_result(int num_spmv){

	debug_check_results_printf("Result verification: \n\r");

	unsigned i, acc;
	for(acc = 0; acc < num_spmv; acc++)
	{
		for(i = 0; i < rows[acc]; i++){
			//printf("%d: %lf %lf\n\r", i, output_mem[i], ref_output_mem[i]);
			if((ref_output_mem[acc][i] > 1e-5) && (((((int32_t*)ref_output_mem[acc])[i] - ((int32_t*)output_mem[acc])[i]) > 167772) || (((int32_t*)output_mem[acc])[i] - ((int32_t*)ref_output_mem[acc])[i]) > 167772))
			{
				printf("%d %d: %lf %lf\n\r", acc, i, output_mem[acc][i], ref_output_mem[acc][i]);
				break;
			}
		}
		if(i == rows[acc])
		{
			debug_check_results_printf("Pass\n\r");
		}
		else
			xil_printf("Fail\n\r");
	}
}

void mem_test()
{
	int* arr = (int*)MEM_BASE_ADDR;
	for(int i = 0; i < 1024; i++) {
		arr[i] = i;
	}
	for(int i = 0; i < 1024; i++) {
		if(arr[i] != i)
			xil_printf("Error at loc %d: found %d\n", i, arr[i]);
	}
}

int Read_single_vector(const char* full_file_name, u32* vec_size, size_t vec_elem_size, void** vec) {
	static FIL fp;	  // File instance
	unsigned int bytes_read;
	FRESULT result;

	result = f_open(&fp, full_file_name, FA_READ);
	if (result!= 0) {
		xil_printf("f_open of %s returned %d\n\r", full_file_name, result);
		return XST_FAILURE;
	}

	result = f_read(&fp, (void*)vec_size, sizeof(u32), &bytes_read);
	if (result!= 0) {
		xil_printf("First f_read on .dat file returned %d\n\r", result);
		return XST_FAILURE;
	}
	debug_data_read_printf("vec size from %s=%d\n\r", full_file_name, *vec_size);

	if(*vec == NULL)
		*vec = malloc((*vec_size)*vec_elem_size);
	if (*vec == NULL) {
		xil_printf("Unable to allocate vector from %s\n\r", full_file_name);
		return XST_FAILURE;
	}
	result = f_read(&fp, (void*)(*vec), (*vec_size)*vec_elem_size, &bytes_read);
	if (result!=0) {
		xil_printf("Bulk f_read of %s returned %d\n\r", full_file_name, result);
		return XST_FAILURE;
	}

	result = f_close(&fp);
	if (result!=0) {
		xil_printf("f_close of %s returned %d\n\r", full_file_name, result);
		return XST_FAILURE;
	}

	return XST_SUCCESS;
}

int Read_data(const char* folder_name, const int num_spmv) {

	char full_file_name[50];

	FATFS fs; // File System instance

	FRESULT result;
	if(strlen(folder_name) > 8) {
		xil_printf("Folder name is limited to 8 characters\n\r");
		return XST_FAILURE;
	}

	result = f_mount(&fs, "0:/", 1);
	if (result != 0) {
		xil_printf("f_mount returned %d\n\r", result);
		return XST_FAILURE;
	}

	int i;

	sprintf(full_file_name, "%s/%d/%s.vec", folder_name, num_spmv, folder_name);
	if(Read_single_vector(full_file_name, &cols, sizeof(float), (void**)&vect_mem) != XST_SUCCESS)
		return XST_FAILURE;
	if(((u32)vect_mem + cols*sizeof(float)) > MEMORY_SPAN + MEM_BASE_ADDR) {
		xil_printf("Vector does not fit in the memory region accessible by the FPGAMSHR (max addr=0x%08X), aborting", (u32)vect_mem + cols*sizeof(float));
		return XST_FAILURE;
	}

	for(i = 0; i < num_spmv; i++) {
		sprintf(full_file_name, "%s/%d/%d.val", folder_name, num_spmv, i);
		if(Read_single_vector(full_file_name, &nnz[i], sizeof(float), (void**)&(val_mem[i])) != XST_SUCCESS)
			return XST_FAILURE;
		sprintf(full_file_name, "%s/%d/%d.col", folder_name, num_spmv, i);
		if(Read_single_vector(full_file_name, &nnz[i], sizeof(unsigned), (void**)&(col_mem[i])) != XST_SUCCESS)
			return XST_FAILURE;

		sprintf(full_file_name, "%s/%d/%d.row", folder_name, num_spmv, i);
		if(Read_single_vector(full_file_name, &rows[i], sizeof(u32), (void**)&(rowptr_mem[i])) != XST_SUCCESS)
			return XST_FAILURE;
		rows[i]--; // rowptr size is rows + 1

		sprintf(full_file_name, "%s/%d/%d.exp", folder_name, num_spmv, i);
		if(Read_single_vector(full_file_name, &rows[i], sizeof(float), (void**)&(ref_output_mem[i])) != XST_SUCCESS)
			return XST_FAILURE;
		output_mem[i] = (float*)malloc(rows[i]*sizeof(float));
	}
	return XST_SUCCESS;
}

int main()
{
  XTmrCtr_Initialize(&spmv_axis_timer, XPAR_AXI_TIMER_0_DEVICE_ID);
	XTmrCtr_SetOptions(&spmv_axis_timer, 0, XTC_CAPTURE_MODE_OPTION);

  if(Init_dma() != 0)
    return -1;

  int num_spmv, cache_divider, benchmark_idx, mshr_count_idx;
#if FPGAMSHR_EXISTS
  xil_printf("benchmark numAcc robDepth mshrHashTables mshrPerHashTable ldBufPerRow ldBufRows cacheWays cacheSize totalCycles ");
#else
  xil_printf("benchmark numAcc cacheSize totalCycles ");
#endif
  FPGAMSHR_Get_stats_header();

  for(benchmark_idx = 0; benchmark_idx < NUM_BENCHMARKS; benchmark_idx++) { // for each benchmark
	   for(num_spmv = 1; num_spmv <= 4; num_spmv++) { // for all numbers of accelerators (num_spmv always 4 in the paper)
       // we statically partition the matrix rows across accelerators in the
       // input data, so we need to read the right set of sparse vector
       // depending on num_spmv
		     debug_data_read_printf("Reading data...\r\n");
			   if(Read_data(benchmarks[benchmark_idx], num_spmv) != XST_SUCCESS)
				     return XST_FAILURE;
			   debug_data_read_printf("...done\r\n");
#if FPGAMSHR_EXISTS
      // we iterate over all possible cache size values
      // effective_cache_size = total_cache_size / (2 ^ cache_divider)
			for(cache_divider = 0; cache_divider <= CACHE_SIZE_REDUCTION_VALUES; cache_divider++) {
					FPGAMSHR_Clear_stats();
					FPGAMSHR_Invalidate_cache();
					if(cache_divider == CACHE_SIZE_REDUCTION_VALUES)
						FPGAMSHR_Disable_cache();
					else
					{
						FPGAMSHR_Enable_cache();
						FPGAMSHR_SetCacheDivider(cache_divider);
					}
#else
				  cache_divider = CACHE_SIZE_REDUCTION_VALUES + 1;
#endif
#if FPGAMSHR_EXISTS
          // run parameters
					xil_printf("\r\n%s %d %d %d %d %d %d %d %d ", benchmarks[benchmark_idx], num_spmv,
            ROB_DEPTH, MSHR_HASH_TABLES, MSHR_PER_HASH_TABLE, SE_BUF_ENTRIES_PER_ROW, SE_BUF_ROWS, CACHE_WAYS,
            cache_divider == CACHE_SIZE_REDUCTION_VALUES ? 0 : CACHE_SIZE >> cache_divider);
#else
					xil_printf("\r\n%s %d 0 ", benchmarks[benchmark_idx], num_spmv);
#endif
					if(Test_spmv_mult_axis(num_spmv) != XST_SUCCESS)
						return XST_FAILURE;
					Compare_result(num_spmv);

          // Uncomment to get a full dump of the internal performance registers
					// FPGAMSHR_Get_stats_pretty();
#if FPGAMSHR_EXISTS
					FPGAMSHR_Get_stats_row();
					}
#endif
				int i;
				for(i = 0; i < num_spmv; i++) {
					free(val_mem[i]);
					val_mem[i] = NULL;
					free(col_mem[i]);
					col_mem[i] = NULL;

					free(rowptr_mem[i]);
					rowptr_mem[i] = NULL;
					free(ref_output_mem[i]);
					ref_output_mem[i] = NULL;
					free(output_mem[i]);
					output_mem[i] = NULL;
				}
			}
    }
    return 0;
}
