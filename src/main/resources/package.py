#!/usr/bin/python

import json
import argparse
from subprocess import Popen, STDOUT, PIPE
import axi4
import os

script = '''
create_project -force "{0}" /tmp
ipx::infer_core -name "{0}" -vendor "{1}" -library "{2}" -version "{3}" "{4}"
set_property supported_families {{virtex7 Production qvirtex7 Production kintex7 Production kintex7l Production qkintex7 Production qkintex7l Production artix7 Production artix7l Production aartix7 Production qartix7 Production zynq Production qzynq Production azynq Production}} [ipx::current_core]
set_property core_revision 1 [ipx::current_core]
set_property display_name "{0}" [ipx::current_core]
set_property description "{0}" [ipx::current_core]
set_property taxonomy "{2}" [ipx::current_core]
ipx::add_bus_parameter POLARITY [ipx::get_bus_interfaces reset -of_objects [ipx::current_core]]
set_property value ACTIVE_HIGH [ipx::get_bus_parameters POLARITY -of_objects [ipx::get_bus_interfaces reset -of_objects [ipx::current_core]]]
ipx::update_checksums [ipx::current_core]
ipx::save_core [ipx::current_core]
close_project -delete
'''

script_with_hex = '''
create_project -force "{0}" /tmp
add_files -norecurse "{4}"
add_files -norecurse [glob "{4}/*.hex"]
update_compile_order -fileset sources_1
update_compile_order -fileset sources_1
set_property file_type {{Memory Initialization Files}} [get_files -of_objects [get_filesets sources_1] [glob "{4}/*.hex"]]
ipx::package_project -root_dir "{4}" -vendor "{1}" -library "{2}"
set_property supported_families {{virtex7 Production qvirtex7 Production kintex7 Production kintex7l Production qkintex7 Production qkintex7l Production artix7 Production artix7l Production aartix7 Production qartix7 Production zynq Production qzynq Production azynq Production}} [ipx::current_core]
set_property core_revision 1 [ipx::current_core]
set_property display_name "{0}" [ipx::current_core]
set_property name "{0}" [ipx::current_core]
set_property description "{0}" [ipx::current_core]
set_property taxonomy "{2}" [ipx::current_core]
ipx::add_bus_parameter POLARITY [ipx::get_bus_interfaces reset -of_objects [ipx::current_core]]
set_property value ACTIVE_HIGH [ipx::get_bus_parameters POLARITY -of_objects [ipx::get_bus_interfaces reset -of_objects [ipx::current_core]]]
ipx::update_checksums [ipx::current_core]
ipx::save_core [ipx::current_core]
close_project -delete
'''

__interface_script = '''
set name    "{0}"
set vendor  "{1}"
set library "{2}"
set version "{3}"
set root    "{4}"
set mainmod "{5}"

cd $root

create_project -in_memory $root
update_ip_catalog
ipx::create_core $vendor $library $name $version

set core [ipx::current_core]

set families [list]
foreach p [get_parts] {{ lappend families [get_property ARCHITECTURE $p] }}
set families [lsort -unique $families]
foreach f $families {{ lappend fams $f "Production" }}
set_property supported_families $fams $core

#set_property core_revision 1 $core
set_property display_name $name $core
set_property description $name $core
set_property taxonomy $library $core

set fg [ipx::add_file_group -type synthesis "sources" $core]
set_property -dict [list model_name $name language Verilog] $fg
ipx::import_top_level_hdl -top_level_hdl_file $mainmod -verbose $core
ipx::add_file $mainmod $fg

set clk [ipx::add_bus_interface clock $core]
set_property type_name std_logic [ipx::add_port "clock" $core]
set_property -dict [list \
  abstraction_type_vlnv {{xilinx.com:signal:clock_rtl:1.0}} \
  bus_type_vlnv {{xilinx.com:signal:clock:1.0}}] $clk
set_property physical_name "clock" [ipx::add_port_map "CLK" $clk]

set rst [ipx::add_bus_interface reset $core]
set_property type_name std_logic [ipx::add_port "reset" $core]
set_property -dict [list \
  abstraction_type_vlnv {{xilinx.com:signal:reset_rtl:1.0}} \
  bus_type_vlnv {{xilinx.com:signal:reset:1.0}}] $rst
set_property value ACTIVE_HIGH [ipx::add_bus_parameter POLARITY $rst]
set_property physical_name "reset" [ipx::add_port_map "RST" $rst]

{6}

ipx::create_default_gui_files $core
ipx::update_checksums $core
ipx::save_core $core
ipx::archive_core "$root/$name.zip" $core
#close_project -delete
'''

__axi4Tcl = '''
set if [ipx::add_bus_interface "{0}" $core]
set_property -dict [list \
  abstraction_type_vlnv xilinx.com:interface:aximm_rtl:1.0 \
  bus_type_vlnv xilinx.com:interface:aximm:1.0 \
  interface_mode {1}] $if
ipx::associate_bus_interfaces -busif "{0}" -clock clock -reset reset $core
foreach {{bport port}} {2} {{
  puts "$bport $port"
  set_property physical_name "$port" [ipx::add_port_map $bport $if]
}}
'''

def map_interface(name, kind):
	if kind == 'axi4master':
		script = __axi4Tcl.format(name, 'master', make_tcl_port_list(axi4.get_port_dict(name)))
		return script
	elif kind == 'axi4slave':
		script = __axi4Tcl.format(name, 'slave', make_tcl_port_list(axi4.get_port_dict(name)))
		return script
	else:
		print 'unknown interface: ' + kind
		return ''

def make_tcl_port_list(d, f=lambda x: x):
        return "[list " + ' '.join([k + ' ' + f(d[k]) for k in sorted(d.keys())]) + "]"

def read_json(jsonfile):
	with open(jsonfile, 'r') as jf:
		contents = jf.read()
		return json.loads(contents)

def make_vivado_script(jsonfile):
	cd = read_json(jsonfile)
	if ('interfaces' not in cd) or (len(cd['interfaces']) is 0):
		#print 'found no interfaces, or empty interface list, using auto-inference'
		return script_with_hex.format(cd['name'], cd['vendor'], cd['library'], cd['version'], cd['root'])
	else:
		#print 'found interfaces: ', cd['interfaces']
		ifs = '\n'.join([map_interface(i['name'], i['kind']) for i in cd['interfaces']])
		return __interface_script.format(cd['name'], cd['vendor'], cd['library'], cd['version'], cd['root'], cd['root'] + '/' + cd['name'] + '.v', ifs)

def run_vivado(jsonfile, script):
	p = Popen(['vivado', '-mode', 'tcl', '-nolog', '-nojournal'], stdin=PIPE, stdout=PIPE, stderr=STDOUT)
        with open(os.path.join(os.path.dirname(jsonfile), 'package.tcl'), 'w') as tclf:
            tclf.write(script)
	output = p.communicate(input = script)[0]
	print output.decode()

def parse_args():
	parser = argparse.ArgumentParser(description = 'Package a hardware module specified by JSON as IP-XACT.')
	parser.add_argument('json', help = 'path to JSON file')
	return parser.parse_args()

args = parse_args()
run_vivado(args.json, make_vivado_script(args.json))
#print make_vivado_script(args.json)
