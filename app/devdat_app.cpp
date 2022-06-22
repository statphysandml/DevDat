#include "devdat/devdat.hpp"
#include <iostream>

int main(){
  int result = devdat::add_one(1);
  std::cout << "1 + 1 = " << result << std::endl;
}