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

# The EName contract on Polygon
1. The contract address： 0xBAA5c79d9a4C9E60a19D1C7884E2b400A6D8211A
2. The contract page: [https://polygonscan.com/address/0xBAA5c79d9a4C9E60a19D1C7884E2b400A6D8211A#code](https://polygonscan.com/address/0xBAA5c79d9a4C9E60a19D1C7884E2b400A6D8211A#code)
3. We can check that eaddress("ename.e") = 0xeccad5a26B2604b9878F3420B23b97f77a169043, and ename(0xeccad5a26B2604b9878F3420B23b97f77a169043) = "ename.e".
   
   
