onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib fpacc_opt

do {wave.do}

view wave
view structure
view signals

do {fpacc.udo}

run -all

quit -force
