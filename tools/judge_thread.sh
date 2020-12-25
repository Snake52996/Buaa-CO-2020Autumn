if [ $# -ne 1 -o ! -f $1 ]; then exit
fi
func() {
local FIRST_LINE="`head -n 1 $1`"
local TEMP_NAME=`echo $1 | md5sum`
local TEMP_NAME=`expr substr "$TEMP_NAME" 1 10`
local SIMULATION_TIME
mkdir -p $TEMP_NAME
cp -r Runable/* $TEMP_NAME/
cd $TEMP_NAME
if [ `expr "$FIRST_LINE" : "#!"` -eq 0 -o `expr "$FIRST_LINE" : ".*simulation_duration="` -eq 0 ]; then
	SIMULATION_TIME="50us"
else
	SIMULATION_TIME=${FIRST_LINE##*simulation_duration=}
fi
echo "run "$SIMULATION_TIME";\nexit;" > mips.tcl
cp ../$1 as.asm
../../Mars.jar a nc db mc CompactDataAtZero dump 0x4180-0x5000 HexText code_handler.txt as.asm
../../Mars.jar nc db mc CompactDataAtZero dump .text HexText code.txt as.asm > ans
echo "0000000c" >> code.txt
./mips -tclbatch mips.tcl | ../../of > out
../../ac out ans ../$1
local RES=$?
if [ $RES -eq 4 ]; then
	echo "extending simulation duration..."
	echo "run 20000us;\nexit;" > mips.tcl
	./mips -tclbatch mips.tcl | ../../of > out
	../../ac out ans ../$1
	RES=$?
fi
if [ $RES -ne 0 ]; then
	echo "\e[33;1mYou can view your and standard output in Environment/"$TEMP_NAME"\e[0m\n"
	return 1
else
	echo ""
	echo "1" >> ../passed
	cd ..
	rm -rfd $TEMP_NAME
	return 0
fi
}
func $1
