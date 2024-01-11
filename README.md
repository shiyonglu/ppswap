To install foundry: 

1. download foundryup:
    curl -L https://foundry.paradigm.xyz | bash
2.  install foundry:
    foundryup
3. Now you have four commands to use: forge, cast, anvil and chisel.

Let's learn how to use the command forge

1. create and init a project:
   forge init myproj
   or
   in the project home directory: forge init --force
2. To compile: forge build
3. To test all tests: forge test
4. To test a particular test method: forge test --match-test testmethod -vv
5. To test a whole test file and fork a blokchain: forge test --fork-url theURL --match-path test/mytest.t.sol -vvvv
6. To deply a contract on a real blockchain: forge script script/Token.s.sol: TokenScript --rpt-url $ETH_RPC_URL --broadcast --verify -vvvv
   
