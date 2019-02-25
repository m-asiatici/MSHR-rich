/*
 * xfully_pipelined_spmv.h
 *
 *  Created on: Jul 3, 2018
 *      Author: asiatici
 */

#ifndef SRC_XFULLY_PIPELINED_SPMV_H_
#define SRC_XFULLY_PIPELINED_SPMV_H_
#include "xil_io.h"

#define SPLIT_INPUT_VECTORS

#define XSPMV_MULT_AXIS_AXILITES_ADDR_AP_CTRL          0x00
#define XSPMV_MULT_AXIS_AXILITES_ADDR_GIE              0x04
#define XSPMV_MULT_AXIS_AXILITES_ADDR_IER              0x08
#define XSPMV_MULT_AXIS_AXILITES_ADDR_ISR              0x0c
#define XSPMV_MULT_AXIS_AXILITES_BITS_VAL_SIZE_DATA    32
#define XSPMV_MULT_AXIS_AXILITES_BITS_OUTPUT_SIZE_DATA 32
#define XSPMV_MULT_AXIS_AXILITES_BITS_VECT_MEM_DATA    32
#ifdef SPLIT_INPUT_VECTORS
#define XSPMV_MULT_AXIS_AXILITES_ADDR_VAL_SIZE_DATA    0x4
#define XSPMV_MULT_AXIS_AXILITES_ADDR_OUTPUT_SIZE_DATA 0x8
#define XSPMV_MULT_AXIS_AXILITES_ADDR_VECT_MEM_DATA    0xC
#else
#define XSPMV_MULT_AXIS_AXILITES_ADDR_VAL_SIZE_DATA    0x10
#define XSPMV_MULT_AXIS_AXILITES_ADDR_OUTPUT_SIZE_DATA 0x18
#define XSPMV_MULT_AXIS_AXILITES_ADDR_VECT_MEM_DATA    0x20
#endif

extern u32 spmv_base_addrs[];

#define XSpmv_mult_axis_ReadReg(BaseAddress, RegOffset) \
    Xil_In32((BaseAddress) + (RegOffset))

#define XSpmv_mult_axis_WriteReg(BaseAddress, RegOffset, Data) \
    Xil_Out32((BaseAddress) + (RegOffset), (u32)(Data))

u32 XSpmv_mult_axis_IsIdle(int instance_index) {
    u32 Data;

    Data = XSpmv_mult_axis_ReadReg(spmv_base_addrs[instance_index], XSPMV_MULT_AXIS_AXILITES_ADDR_AP_CTRL);
#ifdef SPLIT_INPUT_VECTORS
    return Data & 0x1;
#else
    return (Data >> 2) & 0x1;
#endif
}

void XSpmv_mult_axis_Set_val_size(int instance_index, u32 Data) {
    XSpmv_mult_axis_WriteReg(spmv_base_addrs[instance_index], XSPMV_MULT_AXIS_AXILITES_ADDR_VAL_SIZE_DATA, Data);
}

void XSpmv_mult_axis_Set_output_size(int instance_index, u32 Data) {
    XSpmv_mult_axis_WriteReg(spmv_base_addrs[instance_index], XSPMV_MULT_AXIS_AXILITES_ADDR_OUTPUT_SIZE_DATA, Data);
}

void XSpmv_mult_axis_Set_vect_mem(int instance_index, u32 Data) {
    XSpmv_mult_axis_WriteReg(spmv_base_addrs[instance_index], XSPMV_MULT_AXIS_AXILITES_ADDR_VECT_MEM_DATA, Data);
}

void XSpmv_mult_axis_Start(int instance_index) {
    u32 Data;

    Data = XSpmv_mult_axis_ReadReg(spmv_base_addrs[instance_index], XSPMV_MULT_AXIS_AXILITES_ADDR_AP_CTRL) & 0x80;
    XSpmv_mult_axis_WriteReg(spmv_base_addrs[instance_index], XSPMV_MULT_AXIS_AXILITES_ADDR_AP_CTRL, Data | 0x01);
}

#endif /* SRC_XFULLY_PIPELINED_SPMV_H_ */
