#include<string>
#include<stdexcept>
#include<cstdio>
#include<map>
using namespace std;
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
inline static char __toHexadecimalFormat(unsigned int value){
    constexpr unsigned int speed_up_result = 'a' - 10;
    value &= 0xf;
    if(value < 10) return '0' + value;
    return speed_up_result + value;
}
inline static string toHexadecimalFormat(unsigned int value){
    string result;
    result.push_back(__toHexadecimalFormat(value >> 28));
    result.push_back(__toHexadecimalFormat(value >> 24));
    result.push_back(__toHexadecimalFormat(value >> 20));
    result.push_back(__toHexadecimalFormat(value >> 16));
    result.push_back(__toHexadecimalFormat(value >> 12));
    result.push_back(__toHexadecimalFormat(value >> 8));
    result.push_back(__toHexadecimalFormat(value >> 4));
    result.push_back(__toHexadecimalFormat(value));
    return result;
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
inline static void shiftWordEndian(unsigned char* origin){
    unsigned char temp;
    temp = origin[0];
    origin[0] = origin[3];
    origin[3] = temp;
    temp = origin[1];
    origin[1] = origin[2];
    origin[2] = temp;
}
enum class SupportedInstructions{
    ADD,
    ADDI,
    ADDIU,
    ADDU,
    AND,
    ANDI,
    BEQ,
    BEQL,
    BGEZ,
    BGEZAL,
    BGEZALL,
    BGEZL,
    BGTZ,
    BGTZL,
    BLEZ,
    BLEZL,
    BLTZ,
    BLTZAL,
    BLTZALL,
    BLTZL,
    BNE,
    BNEL,
    BREAK,
    DIV,
    DIVU,
    ERET,
    J,
    JAL,
    JALR,
    JR,
    LB,
    LBU,
    LH,
    LHU,
    LUI,
    LW,
    MFC0,
    MFHI,
    MFLO,
    MTC0,
    MTHI,
    MTLO,
    MULT,
    MULTU,
    NOP,
    NOR,
    OR,
    ORI,
    SB,
    SH,
    SLL,
    SLLV,
    SLT,
    SLTI,
    SLTIU,
    SLTU,
    SRA,
    SRAV,
    SRL,
    SRLV,
    SUB,
    SUBU,
    SW,
    SYSCALL,
    TEQ,
    TEQI,
    TGE,
    TGEI,
    TGEIU,
    TGEU,
    TLT,
    TLTI,
    TLTIU,
    TLTU,
    TNE,
    TNEI,
    XOR,
    XORI
};
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
    if(opcode == 0x00) result = special_function_map.at(instruction & 0x3f);
    else if(opcode == 0x01) result = regimm_rt_map.at((instruction >> 16) & 0x1f);
    else if(opcode == 0x10){
        if(instruction == 0x42000018) result = SupportedInstructions::ERET;
        else result = COP0_rs_map.at((instruction >> 21) & 0x1f);
    }else result = opcode_map.at(opcode);
    if(result == SupportedInstructions::SLL && instruction == 0x0) result = SupportedInstructions::NOP;
    return result;
}
int main(){
    unsigned char buffer[1024];
    FILE* input_f = fopen("2", "r");
    unsigned int count = fread(buffer, 4, 256, input_f);
    fclose(input_f);
    unsigned int word_offset;
    for(unsigned int word_bytes = 0; word_bytes < count; ++word_bytes){
        word_offset = word_bytes << 2;
        shiftWordEndian(buffer + word_offset);
        printf("%s\n", toHexadecimalFormat(fromBinaryFormat(buffer + word_offset)).c_str());
    }
    return 0;
}