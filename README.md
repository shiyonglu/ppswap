# To install Ubuntu under Windows 10/11
   https://canonical-ubuntu-wsl.readthedocs-hosted.com/en/latest/

# To install foundry: 

1. download foundryup:
    curl -L https://foundry.paradigm.xyz | bash
2.  install foundry:
    foundryup
3. Now you have four commands to use:``forge``, ``cast``, ``anvil`` and ``chisel``.

# To install OpenZeppelin, forge-std and the ds-test libraries
1. cd ppswap
2. mkdir lib
3. cd lib
4. git clone https://github.com/OpenZeppelin/openzeppelin-contracts.git
5. git clone https://github.com/foundry-rs/forge-std.git
6. git clone https://github.com/dapphub/ds-test.git 

## Let's learn how to use the command ``forge``

1. create and init a project:
   forge init myproj
   or
   in the project home directory: forge init --force
2. To compile: forge build
3. To test all tests: forge test
4. To test a particular test method: forge test --match-test testmethod -vv
5. To test a whole test file and fork a blokchain: forge test --fork-url theURL --match-path test/mytest.t.sol -vvvv
6. To deply a contract on a real blockchain: forge script script/Token.s.sol: TokenScript --rpt-url $ETH_RPC_URL --broadcast --verify -vvvv
   
