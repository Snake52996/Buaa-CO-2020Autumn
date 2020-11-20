if [ $# -ne 1 -o ! -f $1 ]; then exit
fi
func() {
local FIRST_LINE="`head -n 1 $1`"
local TEMP_NAME=`echo $1 | md5sum`
local TEMP_NAME=`expr substr "$TEMP_NAME" 1 10`
mkdir -p $TEMP_NAME
cp -r Runable/* $TEMP_NAME/
cd $TEMP_NAME
if [ `expr "$FIRST_LINE" : "#!"` -eq 0 -o `expr "$FIRST_LINE" : ".*simulation_duration="` -eq 0 ]; then
	echo "run 10us;\nexit;" > mips.tcl
else
	echo "run "${FIRST_LINE##*simulation_duration=}";\nexit;" > mips.tcl
fi
../../Mars.jar nc mc CompactDataAtZero dump .text HexText code.txt ../$1 > ans
./mips -tclbatch mips.tcl | ../../of > out
../../ac out ans ../$1
if [ $? -ne 0 ]; then
	echo "\e[33;1mYou can view your and standard output in Environment/"$TEMP_NAME"\e[0m\n"
	return 1
else
	echo ""
	echo "1" >> ../passed
	return 0
fi
}
func $1
