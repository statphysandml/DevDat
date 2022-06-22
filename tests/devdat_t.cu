#include <devdat/devdat.hpp>

#include "catch2/catch.hpp"

TEST_CASE( "cuda_version", "[cuda]") {
    int driver_version , runtime_version;
    cudaDriverGetVersion( &driver_version );
    cudaRuntimeGetVersion ( &runtime_version );
    std::cout << driver_version << "\t" << runtime_version << std::endl;
}

TEST_CASE( "dev_dat", "[devdat]"){
    std::vector< std::vector<cudaT> > data{std::vector<cudaT> {0, 1, 2}, std::vector<cudaT> {2, 3, 4}};
}

// ToDo
/* TEST_CASE( "add_one", "[adder]" ){
  REQUIRE(add_one(0) == 1);
  REQUIRE(add_one(123) == 124);
  REQUIRE(add_one(-1) == 0);
} */