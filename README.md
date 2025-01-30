# To install Ubuntu under Windows 10/11
   1. https://learn.microsoft.com/en-us/windows/wsl/install

# download the ppswap project
  1. install git: https://git-scm.com/book/en/v2/Getting-Started-Installing-Git 
  2. git clone https://github.com/shiyonglu/ppswap.git

# To install foundry: 

1. download foundryup:
    curl -L https://foundry.paradigm.xyz | bash
2.  install foundry:
    foundryup
3. Now you have four commands to use:``forge``, ``cast``, ``anvil`` and ``chisel``.

# To install OpenZeppelin, forge-std and the ds-test and some other libraries
1. cd ppswap
2. mkdir lib
3. cd lib
4. git clone https://github.com/OpenZeppelin/openzeppelin-contracts.git
5. git clone https://github.com/foundry-rs/forge-std.git
6. git clone https://github.com/dapphub/ds-test.git
7. git clone https://github.com/Uniswap/v2-core.git
8. git clone https://github.com/Uniswap/v2-periphery.git

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

# How to create a Web3 website Using Amazon AWS EC2
1. Create an Amazon EC2 ubuntu instance at https://aws.amazon.com/
2. Connect to the intance and open a terminal
3. Install Apache Tomcat at /opt/tomcat according to : https://www.digitalocean.com/community/tutorials/how-to-install-the-apache-web-server-on-ubuntu-20-04
4. Accee http://a.b.c.d, make sure use the public ip not private ip. Check wheter to use port 80 or port 8080. (one of the column in the instance attribute list)
5. Find out the security group for the EC2 instance (one of the column), and then under ``Network and Security``, you will need to configure your security group for the instance to allow port 80 or other port access.
6.  Now you should be able to access the index webpage of http://a.b.c.d
7. Replace the default index page ``/var/www/html/index.html`` by the frontend index.html, everything should work from there.
8. Use chatgpt 3.5 to generate a defaut page as a start, which you can improve manually with help from chatgpt.
9. If you like to support ssl, go to: https://www.zerossl.com/ and start with a FREE SSL certificate for days. Make sure: 1) the certificates are in the a diretory and should be readable ONLY by the web serer (tomcat); 2) the right port 8443/443 is used and opened in AWS security group; 3) shutdown and restart the the web server; 4) It might take a while to take effect. Try https://letsencrypt.org/

   
