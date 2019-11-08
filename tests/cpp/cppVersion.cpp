#include <algorithm>
#include <iostream>
#include <iterator>
#include <map>
#include <memory>
#include <utility>
#include <vector>

using std::cout;
using std::endl;

int main(){

	cout<< "__cplusplus = " << __cplusplus << endl;
	//cout<< "__STDC_VERSION__ = " << __STDC_VERSION__ << endl;

	#if __cplusplus == 201103L
	cout<<"C++11"<<endl;
	#elif __cplusplus == 201402L
	cout<<"C++14"<<endl;
	#elif __cplusplus == 201703L
	cout<<"C++17"<<endl;
	#endif

	//auto myPointer = std::make_unique<int>(1);

	return 0;
}
