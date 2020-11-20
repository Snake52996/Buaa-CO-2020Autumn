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

if [ ! -d Tests ]; then
	mkdir Tests
fi
if [ ! -f ac -o ac -ot AnsCompare.cpp ]; then
	echo "Compiling AnsCompare"
	g++ -s -O3 -static -std=c++17 -o ac AnsCompare.cpp
fi
if [ ! -f of -o of -ot OutputFilter.cpp ]; then
	echo "Compiling OutputFilter"
	g++ -s -O3 -static -o of OutputFilter.cpp
fi
mkdir -p Environment
cd Environment
mkdir -p Runable
cd Runable
export PLATFORM=lin64
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$PATH:"$XILINX/lib/$PLATFORM"
export PATH=$PATH:"$XILINX/bin/$PLATFORM"
while getopts ":rm" opt
do
	if [ $opt = "r" ]; then
		REBUILD=1
	elif [ $opt = "m" ]; then
		MT=1
	fi
done
if [ "$REBUILD" = "1" -o ! -f ./mips ]; then
	echo "Compiling MIPS"
	$XILINX/bin/$PLATFORM/fuse -nodebug -intstyle ise -incremental -o mips -prj $PROJECT_FILE $TOP_DESIGN > /dev/null
fi
cd ..
if [ ! $MT ]; then
	cp -rf Runable/* .
fi
set +o errexit
TOTAL=0
PASSED=0
if [ "$MT" = "1" ]; then
	echo -n "" > passed
fi
for file in ../Tests/*
do
	if [ ! -f $file ]; then
			continue
	fi
	TOTAL=`expr $TOTAL + 1`
	if [ "$MT" = "1" ]; then
		../judge_thread.sh $file &
	else
		../judge_thread.sh $file
		if [ $? -eq 0 ]; then PASSED=`expr $PASSED + 1`
		fi
	fi
done
wait
if [ "$MT" = "1" ]; then
	while read LINE
	do
		PASSED=$(expr $PASSED + 1)
	done < passed
fi
echo "You passed \e[1m"$PASSED"\e[0m out of \e[1m"$TOTAL"\e[0m test cases."
