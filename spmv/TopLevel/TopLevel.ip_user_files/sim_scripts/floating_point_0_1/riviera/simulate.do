onbreak {quit -force}
onerror {quit -force}

asim -t 1ps +access +r +m+floating_point_0 -L xil_defaultlib -L unisims_ver -L unimacro_ver -L secureip -O5 xil_defaultlib.floating_point_0 xil_defaultlib.glbl

do {wave.do}

view wave
view structure

do {floating_point_0.udo}

run -all

endsim

quit -force
