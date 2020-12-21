#include<iostream>
#include<limits>
using namespace std;
int main(){
	constexpr unsigned int BUFFER_SIZE = 128;
	char buffer[BUFFER_SIZE];
	cin.ignore(numeric_limits<streamsize>::max(), '@');
	while(!cin.eof()){
		cin.unget();
		cin.getline(buffer, BUFFER_SIZE);
		cout<<buffer<<endl;
		cin.ignore(numeric_limits<streamsize>::max(), '@');
	}
	return 0;
}
