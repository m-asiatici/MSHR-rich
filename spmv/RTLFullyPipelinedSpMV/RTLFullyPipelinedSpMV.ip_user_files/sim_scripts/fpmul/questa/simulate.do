onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib fpmul_opt

do {wave.do}

view wave
view structure
view signals

do {fpmul.udo}

run -all

quit -force
