set -o errexit

#vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv#

# The project file shall usually be in your project dirctory usually with the name
#   "<test bench name>_beh.prj"
PROJECT_FILE="<PATH TO PROJECT FILE(.prj) OF YOUR TEST BENCH>"

# This is the above-mentioned "<test bench name>" in fact
TOP_DESIGN="<TEST BENCH NAME>"

# Replace with the path to which you installed your ISE
export XILINX=/some/dirctories/14.7/ISE_DS/ISE

#^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^#

if [ ! -f ac -o ac -ot AnsCompare.cpp ]; then
	echo "Compiling AnsCompare"
	g++ -s -O3 -static -std=c++17 -o ac AnsCompare.cpp
fi
if [ ! -f of -o of -ot OutputFilter.cpp ]; then
	echo "Compiling OutputFilter"
	g++ -s -O3 -static -o of OutputFilter.cpp
fi
echo "run 100us;\nexit;" > mips.tcl
mkdir -p Environment
cd Environment
export PLATFORM=lin64
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$PATH:"$XILINX/lib/$PLATFORM"
export PATH=$PATH:"$XILINX/bin/$PLATFORM"
if [ $# -gt 0 -o ! -f mips ]; then
	echo "Compiling MIPS"
	$XILINX/bin/$PLATFORM/fuse -nodebug -intstyle ise -incremental -o mips -prj $PROJECT_FILE $TOP_DESIGN > /dev/null
fi
for file in ../Tests/*
do
	if [ ! -f $file ]; then
		continue
	fi
	../Mars.jar nc mc CompactDataAtZero dump .text HexText code.txt $file > ans
	./mips -tclbatch ../mips.tcl | ../of > out
	../ac out ans $file
done
