#include<stdexcept>
#include<cstdio>
#include<map>
#include<string>
#include<filesystem>
#include<cstdlib>
#include<charconv>
#include<cstring>
using namespace std;
inline bool isLittleEndian(){
    unsigned int checker = 1;
    return (*reinterpret_cast<unsigned char*>(&checker) != 0);
}
const bool IS_LITTLE_ENDIAN = isLittleEndian();
inline static const char* toGeneralRegisterMnemonic(unsigned int address){
    static char general_register_mnemonic[32][5] = {
        "zero", "at", "v0", "v1", "a0", "a1", "a2", "a3",
        "t0", "t1", "t2", "t3", "t4", "t5", "t6", "t7",
        "s0", "s1", "s2", "s3", "s4", "s5", "s6", "s7",
        "t8", "t9", "k0", "k1", "gp", "sp", "fp", "ra"
    };
    if(address >= 32) throw out_of_range("General Register Address out of range.");
    return general_register_mnemonic[address];
}
inline static unsigned char __toHexadecimalFormat(unsigned int value){
    constexpr unsigned int speed_up_result = 'a' - 10;
    value &= 0xf;
    if(value < 10) return '0' + value;
    return speed_up_result + value;
}
inline static void __normalizeHexadecimalDigital(unsigned char& digital){
    constexpr unsigned int speed_up_result = 'a' - 'A';
    if((digital >= '0' && digital <= '9') || (digital >= 'a' && digital <= 'f')) return;
    if(digital >= 'A' && digital <= 'F') digital += speed_up_result;
    else throw invalid_argument("Not a valid hexadecimal digital.");
}
inline static unsigned int __fromHexadecimalFormat(unsigned char origin){
    constexpr unsigned int speed_up_result = 10 - 'a';
    if(origin >= '0' && origin <= '9') return origin - '0';
    return speed_up_result + origin;
}
inline static unsigned int fromHexadecimalFormat(unsigned char* origin){
    for(unsigned int i = 0; i < 8; ++i) __normalizeHexadecimalDigital(origin[i]);
    unsigned int result = 0;
    result |= (__fromHexadecimalFormat(origin[0]) << 28);
    result |= (__fromHexadecimalFormat(origin[1]) << 24);
    result |= (__fromHexadecimalFormat(origin[2]) << 20);
    result |= (__fromHexadecimalFormat(origin[3]) << 16);
    result |= (__fromHexadecimalFormat(origin[4]) << 12);
    result |= (__fromHexadecimalFormat(origin[5]) << 8);
    result |= (__fromHexadecimalFormat(origin[6]) << 4);
    result |= (__fromHexadecimalFormat(origin[7]));
    return result;
}
inline static unsigned int fromBinaryFormat(unsigned char* origin){
    unsigned int result = 0;
    result |= ((unsigned int)(origin[0]) << 24);
    result |= ((unsigned int)(origin[1]) << 16);
    result |= ((unsigned int)(origin[2]) << 8);
    result |= ((unsigned int)(origin[3]));
    return result;
}
inline static void shiftEndian(unsigned char* begin, unsigned char* end){
    while(begin < --end){
        (*begin) ^= (*end) ^= (*begin) ^= (*end);
        ++begin;
    }
}
enum class SupportedInstructions: unsigned long long{
    ADD     = 0x0061646400000000,
    ADDI    = 0x0361646469000000,
    ADDIU   = 0x0361646469750000,
    ADDU    = 0x0061646475000000,
    AND     = 0x00616e6400000000,
    ANDI    = 0x03616e6469000000,
    BEQ     = 0x0562657100000000,
    BEQL    = 0x056265716c000000,
    BGEZ    = 0x0a6267657a000000,
    BGEZAL  = 0x0a6267657a616c00,
    BGEZALL = 0x0a6267657a616c6c,
    BGEZL   = 0x0a6267657a6c0000,
    BGTZ    = 0x0a6267747a000000,
    BGTZL   = 0x0a6267747a6c0000,
    BLEZ    = 0x0a626c657a000000,
    BLEZL   = 0x0a626c657a6c0000,
    BLTZ    = 0x0a626c747a000000,
    BLTZAL  = 0x0a626c747a616c00,
    BLTZALL = 0x0a626c747a616c6c,
    BLTZL   = 0x0a626c747a6c0000,
    BNE     = 0x05626e6500000000,
    BNEL    = 0x05626e656c000000,
    BREAK   = 0x0e627265616b0000,
    DIV     = 0x0f64697600000000,
    DIVU    = 0x0f64697675000000,
    ERET    = 0x0e65726574000000,
    J       = 0x0b6a000000000000,
    JAL     = 0x0b6a616c00000000,
    JALR    = 0x066a616c72000000,
    JR      = 0x0c6a720000000000,
    LB      = 0x046c620000000000,
    LBU     = 0x046c627500000000,
    LH      = 0x046c680000000000,
    LHU     = 0x046c687500000000,
    LUI     = 0x096c756900000000,
    LW      = 0x046c770000000000,
    MFC0    = 0x076d666330000000,
    MFHI    = 0x0d6d666869000000,
    MFLO    = 0x0d6d666c6f000000,
    MTC0    = 0x076d746330000000,
    MTHI    = 0x0c6d746869000000,
    MTLO    = 0x0c6d746c6f000000,
    MULT    = 0x0f6d756c74000000,
    MULTU   = 0x0f6d756c74750000,
    NOP     = 0x0e6e6f7000000000,
    NOR     = 0x006e6f7200000000,
    OR      = 0x006f720000000000,
    ORI     = 0x036f726900000000,
    SB      = 0x0473620000000000,
    SH      = 0x0473680000000000,
    SLL     = 0x02736c6c00000000,
    SLLV    = 0x01736c6c76000000,
    SLT     = 0x00736c7400000000,
    SLTI    = 0x03736c7469000000,
    SLTIU   = 0x03736c7469750000,
    SLTU    = 0x00736c7475000000,
    SRA     = 0x0273726100000000,
    SRAV    = 0x0173726176000000,
    SRL     = 0x0273726c00000000,
    SRLV    = 0x0173726c76000000,
    SUB     = 0x0073756200000000,
    SUBU    = 0x0073756275000000,
    SW      = 0x0473770000000000,
    SYSCALL = 0x0e73797363616c6c,
    TEQ     = 0x0f74657100000000,
    TEQI    = 0x0874657169000000,
    TGE     = 0x0f74676500000000,
    TGEI    = 0x0874676569000000,
    TGEIU   = 0x0874676569750000,
    TGEU    = 0x0f74676575000000,
    TLT     = 0x0f746c7400000000,
    TLTI    = 0x08746c7469000000,
    TLTIU   = 0x08746c7469750000,
    TLTU    = 0x0f746c7475000000,
    TNE     = 0x0f746e6500000000,
    TNEI    = 0x08746e6569000000,
    XOR     = 0x00786f7200000000,
    XORI    = 0x03786f7269000000,
    UNKNOWN_INSTRUCTION
};
inline constexpr unsigned long long getInstructionFormat(SupportedInstructions instruction){
    
    constexpr unsigned long long formats[] = {
        0x0000003a92a94a81,
        0x0000002a93a94a81,
        0x0000000593a94a81,
        0x0000000692a93a81,
        0x000000c2ab693a81,
        0x0000000793a92a81,
        0x0000000002a94a81,
        0x0000000004a93a81,
        0x0000000000692a81,
        0x0000000000693a81,
        0x0000000000792a81,
        0x0000000000000781,
        0x0000000000002a81,
        0x0000000000004a81,
        0x0000000000000001,
        0x0000000003a92a81
    };
    return formats[((unsigned long long)instruction) >> 56];
}
inline static map<unsigned int, SupportedInstructions> initializeOpcodeMap(){
    map<unsigned int, SupportedInstructions> opcode_map;
    opcode_map[0x02] = SupportedInstructions::J;
    opcode_map[0x03] = SupportedInstructions::JAL;
    opcode_map[0x04] = SupportedInstructions::BEQ;
    opcode_map[0x05] = SupportedInstructions::BNE;
    opcode_map[0x06] = SupportedInstructions::BLEZ;
    opcode_map[0x07] = SupportedInstructions::BGTZ;
    opcode_map[0x08] = SupportedInstructions::ADDI;
    opcode_map[0x09] = SupportedInstructions::ADDIU;
    opcode_map[0x0a] = SupportedInstructions::SLTI;
    opcode_map[0x0b] = SupportedInstructions::SLTIU;
    opcode_map[0x0c] = SupportedInstructions::ANDI;
    opcode_map[0x0d] = SupportedInstructions::ORI;
    opcode_map[0x0e] = SupportedInstructions::XORI;
    opcode_map[0x0f] = SupportedInstructions::LUI;
    opcode_map[0x14] = SupportedInstructions::BEQL;
    opcode_map[0x15] = SupportedInstructions::BNEL;
    opcode_map[0x16] = SupportedInstructions::BLEZL;
    opcode_map[0x17] = SupportedInstructions::BGTZL;
    opcode_map[0x20] = SupportedInstructions::LB;
    opcode_map[0x21] = SupportedInstructions::LH;
    opcode_map[0x23] = SupportedInstructions::LW;
    opcode_map[0x24] = SupportedInstructions::LBU;
    opcode_map[0x25] = SupportedInstructions::LHU;
    opcode_map[0x28] = SupportedInstructions::SB;
    opcode_map[0x29] = SupportedInstructions::SH;
    opcode_map[0x2b] = SupportedInstructions::SW;
    return opcode_map;
}
inline static map<unsigned int, SupportedInstructions> initializeSpecialFunctionMap(){
    map<unsigned int, SupportedInstructions> special_function_map;
    special_function_map[0x00] = SupportedInstructions::SLL;
    special_function_map[0x02] = SupportedInstructions::SRL;
    special_function_map[0x03] = SupportedInstructions::SRA;
    special_function_map[0x04] = SupportedInstructions::SLLV;
    special_function_map[0x06] = SupportedInstructions::SRLV;
    special_function_map[0x07] = SupportedInstructions::SRAV;
    special_function_map[0x08] = SupportedInstructions::JR;
    special_function_map[0x09] = SupportedInstructions::JALR;
    special_function_map[0x0c] = SupportedInstructions::SYSCALL;
    special_function_map[0x0d] = SupportedInstructions::BREAK;
    special_function_map[0x10] = SupportedInstructions::MFHI;
    special_function_map[0x11] = SupportedInstructions::MTHI;
    special_function_map[0x12] = SupportedInstructions::MFLO;
    special_function_map[0x13] = SupportedInstructions::MTLO;
    special_function_map[0x18] = SupportedInstructions::MULT;
    special_function_map[0x19] = SupportedInstructions::MULTU;
    special_function_map[0x1a] = SupportedInstructions::DIV;
    special_function_map[0x1b] = SupportedInstructions::DIVU;
    special_function_map[0x20] = SupportedInstructions::ADD;
    special_function_map[0x21] = SupportedInstructions::ADDU;
    special_function_map[0x22] = SupportedInstructions::SUB;
    special_function_map[0x23] = SupportedInstructions::SUBU;
    special_function_map[0x24] = SupportedInstructions::AND;
    special_function_map[0x25] = SupportedInstructions::OR;
    special_function_map[0x26] = SupportedInstructions::XOR;
    special_function_map[0x27] = SupportedInstructions::NOR;
    special_function_map[0x2a] = SupportedInstructions::SLT;
    special_function_map[0x2b] = SupportedInstructions::SLTU;
    special_function_map[0x30] = SupportedInstructions::TGE;
    special_function_map[0x31] = SupportedInstructions::TGEU;
    special_function_map[0x32] = SupportedInstructions::TLT;
    special_function_map[0x33] = SupportedInstructions::TLTU;
    special_function_map[0x34] = SupportedInstructions::TEQ;
    special_function_map[0x36] = SupportedInstructions::TNE;
    return special_function_map;
}
inline static map<unsigned int, SupportedInstructions> initializeRegimmRtMap(){
    map<unsigned int, SupportedInstructions> regimm_rt_map;
    regimm_rt_map[0x00] = SupportedInstructions::BLTZ;
    regimm_rt_map[0x01] = SupportedInstructions::BGEZ;
    regimm_rt_map[0x02] = SupportedInstructions::BLTZL;
    regimm_rt_map[0x03] = SupportedInstructions::BGEZL;
    regimm_rt_map[0x08] = SupportedInstructions::TGEI;
    regimm_rt_map[0x09] = SupportedInstructions::TGEIU;
    regimm_rt_map[0x0a] = SupportedInstructions::TLTI;
    regimm_rt_map[0x0b] = SupportedInstructions::TLTIU;
    regimm_rt_map[0x0c] = SupportedInstructions::TEQI;
    regimm_rt_map[0x0e] = SupportedInstructions::TNEI;
    regimm_rt_map[0x10] = SupportedInstructions::BLTZAL;
    regimm_rt_map[0x11] = SupportedInstructions::BGEZAL;
    regimm_rt_map[0x12] = SupportedInstructions::BLTZALL;
    regimm_rt_map[0x13] = SupportedInstructions::BGEZALL;
    return regimm_rt_map;
}
inline static map<unsigned int, SupportedInstructions> initializeCOP0RsMap(){
    map<unsigned int, SupportedInstructions> COP0_rs_map;
    COP0_rs_map[0x00] = SupportedInstructions::MFC0;
    COP0_rs_map[0x04] = SupportedInstructions::MTC0;
    return COP0_rs_map;
}
inline static SupportedInstructions identifyInstruction(unsigned int instruction){
    static map<unsigned int, SupportedInstructions> opcode_map = initializeOpcodeMap();
    static map<unsigned int, SupportedInstructions> special_function_map = initializeSpecialFunctionMap();
    static map<unsigned int, SupportedInstructions> regimm_rt_map = initializeRegimmRtMap();
    static map<unsigned int, SupportedInstructions> COP0_rs_map = initializeCOP0RsMap();
    unsigned int opcode = instruction >> 26;
    SupportedInstructions result;
    try{
        if(opcode == 0x00) result = special_function_map.at(instruction & 0x3f);
        else if(opcode == 0x01) result = regimm_rt_map.at((instruction >> 16) & 0x1f);
        else if(opcode == 0x10){
            if(instruction == 0x42000018) result = SupportedInstructions::ERET;
            else result = COP0_rs_map.at((instruction >> 21) & 0x1f);
        }else result = opcode_map.at(opcode);
    }catch(const out_of_range& exception){
        result = SupportedInstructions::UNKNOWN_INSTRUCTION;
    }
    if(result == SupportedInstructions::SLL && instruction == 0x0) result = SupportedInstructions::NOP;
    return result;
}
inline static void printStringToString(unsigned char* target, const unsigned char* source, unsigned int& offset){
    while(*source){
        *(target++) = *(source++);
        ++offset;
    }
}
inline static void printHexadecimalMarkerToString(unsigned char* target, unsigned int& offset){
    *target = '0';
    *(target + 1) = 'x';
    offset += 2;
}
inline static void printWordToString(unsigned char* target, unsigned int source, unsigned int& offset){
    *target = __toHexadecimalFormat(source >> 28);
    *(target + 1) = __toHexadecimalFormat(source >> 24);
    *(target + 2) = __toHexadecimalFormat(source >> 20);
    *(target + 3) = __toHexadecimalFormat(source >> 16);
    *(target + 4) = __toHexadecimalFormat(source >> 12);
    *(target + 5) = __toHexadecimalFormat(source >> 8);
    *(target + 6) = __toHexadecimalFormat(source >> 4);
    *(target + 7) = __toHexadecimalFormat(source);
    offset += 8;
}
inline static void printHalfToString(unsigned char* target, unsigned int source, unsigned int& offset){
    *target = __toHexadecimalFormat(source >> 12);
    *(target + 1) = __toHexadecimalFormat(source >> 8);
    *(target + 2) = __toHexadecimalFormat(source >> 4);
    *(target + 3) = __toHexadecimalFormat(source);
    offset += 4;
}
inline static const unsigned char* getStringOfInteger(unsigned int integer){
    static const unsigned char strs[][3] = {
        "0", "1", "2", "3", "4", "5", "6", "7", "8", "9",
        "10", "11", "12", "13", "14", "15", "16", "17", "18", "19",
        "20", "21", "22", "23", "24", "25", "26", "27", "28", "29",
        "30", "31"
    };
    return strs[integer];
}
inline static const string getFileName(char* path){
	return filesystem::path(path).stem().string();
}
inline static void throwIllegalArgument(char* command){
	printf("\e[36;1;4mUsage\e[0m: %s <dumped code> [<starting_address>]\n", getFileName(command).c_str());
	printf("\t     <dumped code> -- The file which contains dumped code in binary format.\n");
	printf("\t<starting_address> -- The address of first instruction in hexadecimal format without 0x prefix.\n");
	printf("\e[36;1;4mNOTE\e[0m\n");
	printf("\tOnly binary format is supported. A helper will be distributed along with\n");
    printf("\t  this disassembler to convert hexadecimal format to binary one.\n");
	printf("\tStarting address will be configured to 0x3000 if not specificied.\n");
	printf("\tLabels in branch and jump instructions will be shown as address to which\n");
    printf("\t  the instruction will branch to. Such representation may stop you from\n");
    printf("\t  assembling generated code.\n");
	exit(1);
}
inline static void throwFileNotFound(const char* path){
	printf("\e[33;1mError: Failed to open %s: file doesn't exist or permission denied.\e[0m\n", path);
	printf("Maybe you want to check and try again.\n");
	exit(1);
}
int main(int argc, char** argv){
    if(argc < 2) throwIllegalArgument(argv[0]);
    FILE* input_f = fopen(argv[1], "rb");
    if(input_f == NULL) throwFileNotFound(argv[1]);
    unsigned int current_address = 0x3000;
    if(argc >= 3){
        unsigned int temp_length = strlen(argv[2]);
        from_chars(argv[2], argv[2] + temp_length, current_address, 16);
    }
    unsigned char buffer[1024];
    unsigned char out_buffer[100];
    unsigned int count = 0;
    unsigned int word_offset;
    unsigned int instruction;
    unsigned int rs;
    unsigned int rt;
    unsigned int rd;
    unsigned int sa;
    unsigned int address;
    unsigned int immediate;
    int signed_immediate;
    unsigned long long mnemonic;
    unsigned long long format;
    unsigned int output_buffer_pointer;
    constexpr const unsigned char space[] = " ";
    constexpr const unsigned char dollar[] = "$";
    constexpr const unsigned char left[] = "(";
    constexpr const unsigned char right[] = ")";
    constexpr const unsigned char comma[] = ",";
    constexpr const unsigned char unknown_instruction_info[] = "Unknown instruction encountered: ";
    constexpr const unsigned char tab[] = "\t";
    constexpr const unsigned char comment[] = "# ";
    SupportedInstructions decoded_instruction;
    while(true){
        count = fread(buffer, 4, 256, input_f);
        if(!count) break;
        for(unsigned int word_bytes = 0; word_bytes < count; ++word_bytes){
            output_buffer_pointer = 0;
            word_offset = word_bytes << 2;
            shiftEndian(buffer + word_offset, buffer + word_offset + 4);
            instruction = fromBinaryFormat(buffer + word_offset);
            decoded_instruction = identifyInstruction(instruction);
            if(decoded_instruction == SupportedInstructions::UNKNOWN_INSTRUCTION){
                printStringToString(
                    out_buffer + output_buffer_pointer,
                    comment,
                    output_buffer_pointer
                );
                printStringToString(
                    out_buffer + output_buffer_pointer,
                    unknown_instruction_info,
                    output_buffer_pointer
                );
                printWordToString(
                    out_buffer + output_buffer_pointer,
                    instruction,
                    output_buffer_pointer
                );
            }else{
                rs = (instruction >> 21) & 0x1f;
                rt = (instruction >> 16) & 0x1f;
                rd = (instruction >> 11) & 0x1f;
                sa = (instruction >> 6) & 0x1f;
                immediate = instruction & 0xffff;
                signed_immediate = immediate | ((immediate & 0x8000) ? 0xffff0000 : 0);
                if(
                    decoded_instruction == SupportedInstructions::J ||
                    decoded_instruction == SupportedInstructions::JAL
                ){
                    address = ((current_address + 4) & 0xf0000000) | ((instruction & 0x03ffffff) << 2);
                }else{
                    address = current_address + 4 + (signed_immediate * 4);
                }
                mnemonic = ((unsigned long long)decoded_instruction) << 8;
                if(IS_LITTLE_ENDIAN) shiftEndian(
                    reinterpret_cast<unsigned char*>(&mnemonic),
                    reinterpret_cast<unsigned char*>(&mnemonic) + sizeof(mnemonic)
                );
                format = getInstructionFormat(decoded_instruction);
                while(format){
                    switch(format & 0xf){
                        case 0:
                            out_buffer[output_buffer_pointer++] = '\0';
                            break;
                        case 1:
                            printStringToString(
                                out_buffer + output_buffer_pointer,
                                reinterpret_cast<unsigned char*>(&mnemonic),
                                output_buffer_pointer
                            );
                            break;
                        case 2:
                            printStringToString(
                                out_buffer + output_buffer_pointer,
                                getStringOfInteger(rs),
                                output_buffer_pointer
                            );
                            break;
                        case 3:
                            printStringToString(
                                out_buffer + output_buffer_pointer,
                                getStringOfInteger(rt),
                                output_buffer_pointer
                            );
                            break;
                        case 4:
                            printStringToString(
                                out_buffer + output_buffer_pointer,
                                getStringOfInteger(rd),
                                output_buffer_pointer
                            );
                            break;
                        case 5:
                            printStringToString(
                                out_buffer + output_buffer_pointer,
                                getStringOfInteger(sa),
                                output_buffer_pointer
                            );
                            break;
                        case 6:
                            printHexadecimalMarkerToString(
                                out_buffer + output_buffer_pointer, output_buffer_pointer
                            );
                            printHalfToString(
                                out_buffer + output_buffer_pointer,
                                immediate,
                                output_buffer_pointer
                            );
                            break;
                        case 7:
                            printHexadecimalMarkerToString(
                                out_buffer + output_buffer_pointer, output_buffer_pointer
                            );
                            printWordToString(
                                out_buffer + output_buffer_pointer,
                                address,
                                output_buffer_pointer
                            );
                            break;
                        case 8:
                            printStringToString(
                                out_buffer + output_buffer_pointer,
                                space,
                                output_buffer_pointer
                            );
                            break;
                        case 9:
                            printStringToString(
                                out_buffer + output_buffer_pointer,
                                comma,
                                output_buffer_pointer
                            );
                            break;
                        case 10:
                            printStringToString(
                                out_buffer + output_buffer_pointer,
                                dollar,
                                output_buffer_pointer
                            );
                            break;
                        case 11:
                            printStringToString(
                                out_buffer + output_buffer_pointer,
                                left,
                                output_buffer_pointer
                            );
                            break;
                        case 12:
                            printStringToString(
                                out_buffer + output_buffer_pointer,
                                right,
                                output_buffer_pointer
                            );
                            break;
                        default: break;
                    }
                    format >>= 4;
                }
            }
            printStringToString(
                out_buffer + output_buffer_pointer,
                tab,
                output_buffer_pointer
            );
            printStringToString(
                out_buffer + output_buffer_pointer,
                comment,
                output_buffer_pointer
            );
            printHexadecimalMarkerToString(
                out_buffer + output_buffer_pointer, output_buffer_pointer
            );
            printWordToString(
                out_buffer + output_buffer_pointer,
                current_address,
                output_buffer_pointer
            );
            out_buffer[output_buffer_pointer] = '\0';
            printf("%s\n", out_buffer);
            current_address += 4;
        }
    }
    fclose(input_f);
    return 0;
}