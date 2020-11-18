/*
	(Compile: g++ -s -o3 -std=c++17 -o ac AnsCompare.cpp)
	Tested on Ubuntu 20.04.1 LTS with g++ (GCC) 9.2.0
*/
#include<cstdio>
#include<iostream>
#include<fstream>
#include<cstdlib>
#include<string>
#include<filesystem>
#include<regex>
using namespace std;
enum EXIT_STATUS{
	OK = 0,
	UNKNOWN_EXCEPTION,
	FILE_NOT_FOUND,
	WRONG_ANSWER,
	ILLEGAL_ARGUMENT
};
const regex REGISTER_LINE("^\\s*@(0x)?([0-9a-fA-F]{8})\\s*:\\s*\\$\\s*([0-9]+)\\s*<=\\s*(0x)?([0-9a-fA-F]{8})\\s*$");
const regex MEMORY_LINE("^\\s*@(0x)?([0-9a-fA-F]{8})\\s*:\\s*\\*\\s*(0x)?([0-9a-fA-F]{8})\\s*<=\\s*(0x)?([0-9a-fA-F]{8})\\s*$");
inline const string& getCommandName(char* command){
	static string command_name;
	if(!command_name.size()) command_name = filesystem::path(command).stem().string();
	return command_name;
}
void safeForNow(){
	printf("\e[32;1mAC\e[0m  You have passed this test case.\n");
	printf("Come on, that doesn't mean you're totally correct,\n");
	printf("but the more test cases you've passed, it would be more possible for you to be.\n");
	printf("\e[1mCONFIDENCE!\e[0m\n");
	exit(EXIT_STATUS::OK);
}
void throwIllegalArgument(char* command){
	printf("\e[36;1;4mUsage\e[0m: %s output answer\n", getCommandName(command).c_str());
	printf("\toutput\t-- The file which contains output from your CPU\n");
	printf("\tanswer\t-- The file which contains standard output\n");
	printf("\e[36;1;4mNOTE\e[0m\n");
	printf("\tAny assignment to register 0 will be ignored.\n");
	printf("\tAny blank character between or after any element(i.e. @, PC value,\n");
	printf("\t  $ or *, address of register or memory, <= and assigned value) in\n");
	printf("\t  a single line will be ignored.\n");
	printf("\tAny empty line will be ignored.\n");
	printf("\t\"0x\" at the beginning of any hex value will be ignored.\n");
	printf("\t\'0\' as Prefix in register address will also be ignored.\n");
	printf("\e[36;1;4mSTATUS CODE\e[0m\n");
	printf("\t%2d -- \e[32;1m%s\e[0m\n", EXIT_STATUS::OK, "Accepted");
	printf("\t%2d -- \e[34;1m%s\e[0m\n", EXIT_STATUS::UNKNOWN_EXCEPTION, "Unknown Exception");
	printf("\t%2d -- \e[33;1m%s\e[0m\n", EXIT_STATUS::FILE_NOT_FOUND, "File Not Found");
	printf("\t%2d -- \e[31;1m%s\e[0m\n", EXIT_STATUS::WRONG_ANSWER, "Wrong Answer");
	printf("\t%2d -- \e[35;1m%s\e[0m\n", EXIT_STATUS::ILLEGAL_ARGUMENT, "Illegal Argument");
	exit(EXIT_STATUS::ILLEGAL_ARGUMENT);
}
void throwFileNotFound(const char* path){
	printf("\e[33;1mError: Failed to open %s: file doesn't exist or permission denied.\e[0m\n", path);
	printf("Maybe you want to check and try again.\n");
	exit(EXIT_STATUS::FILE_NOT_FOUND);
}
void throwWrongAnswer(const char* comment){
	constexpr const char* const sentences[] = {
		"Such moment always exists. DON'T GIVE UP!",
		"Whoops, kind of hard, right?",
		"Don't be disappointed my friend. Keep going.",
		"Too hard for now? Maybe you just need a \"farther look\"! How about go for a walk?",
		"Don't worry, I believe you can fix it next time!",
		"Well...see you soon.",
		"\e[1mDETERMINATION\e[0m"
	};
	constexpr int sentences_count = 7;
	printf("\e[31;1mWA\e[0m  %s\n", comment);
	printf("%s\n", sentences[rand() % sentences_count]);
	exit(EXIT_STATUS::WRONG_ANSWER);
}
void throwUnknownException(const char* comment){
	printf("\e[34;1mUKE\e[0m  %s\n", comment);
	printf("That's really a bad news. Maybe this judger received a WA?\n");
	exit(EXIT_STATUS::UNKNOWN_EXCEPTION);
}
string getNextLine(istream& log){
	static string temp;
	static smatch m;
	while(!log.eof()){
		getline(log, temp);
		if(!temp.size()) continue;
		if(regex_match(temp, m, REGISTER_LINE)){
			if(stoi(m[3]) == 0) continue;
			temp = "@" + m.str(2) + ": $" + to_string(stoi(m.str(3))) + " <= " + m.str(5);
			break;
		}else if(regex_match(temp, m, MEMORY_LINE)){
			temp = "@" + m.str(2) + ": *" + m.str(4) + " <= " + m.str(6);
			break;
		}else{
			temp = "";
			break;
		}
	}
	for(char& c: temp) if(c >= 'a' && c <= 'f') c = c - 'a' + 'A';
	return temp;
}
void removeNops(istream& log){
	auto fall_back_pos = log.tellg();
	string temp;
	smatch tmap;
	while(!log.eof()){
		temp = getNextLine(log);
		if(temp.size()) if(!regex_match(temp, tmap, REGISTER_LINE) || stoi(tmap.str(3)) != 0){
			log.seekg(fall_back_pos);
			break;
		}
	}
}
void compare(istream& out, istream& ans){
	string out_line, ans_line;
	while(!out.eof() && !ans.eof()){
		out_line = getNextLine(out);
		ans_line = getNextLine(ans);
		if(out_line == ans_line) continue;
		if(!out_line.size()){
			if(out.eof()) break;
			throwWrongAnswer("Illegal output encountered.");
		}
		if(!ans_line.size()){
			if(ans.eof()) break;
			throwUnknownException("Failed to parse standard output. What's up!?");
		}
		throwWrongAnswer(("We got \'" + out_line + "\' when we excepted \'" + ans_line + "\'.").c_str());
		
	}
	if(!out.eof()) throwWrongAnswer("Your output is more than standard output.");
	if(!ans.eof()) throwWrongAnswer("Your output is fewer than standard output.");
}
int main(int argc, char** argv){
	srand(time(NULL));
	constexpr const char* const sentences[] = {
		"You will get an AC this time, I can tell.",
		"How's everything?",
		"My pleasure to see you."
	};
	constexpr int sentences_count = 3;
	if(argc != 3) throwIllegalArgument(argv[0]);
	ifstream output(argv[1]);
	ifstream answer(argv[2]);
	if(!output.is_open()) throwFileNotFound(argv[1]);
	if(!answer.is_open()) throwFileNotFound(argv[2]);
	printf("%s\n", sentences[rand() % sentences_count]);
	compare(output, answer);
	safeForNow();
}
