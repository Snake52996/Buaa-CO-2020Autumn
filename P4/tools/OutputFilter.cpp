#include<iostream>
#include<limits>
using namespace std;
int main(){
	constexpr unsigned int BUFFER_SIZE = 128;
	bool start_sign = false;
	char buffer[BUFFER_SIZE];
	while(!cin.eof()){
		if(start_sign || cin.peek() == '@'){
			start_sign = true;
			cin.getline(buffer, BUFFER_SIZE);
			cout<<buffer<<endl;
		}else cin.ignore(numeric_limits<streamsize>::max(), '\n');
	}
	return 0;
}
