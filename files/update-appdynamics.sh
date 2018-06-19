echo "Initiated AppD update" >> appdynamics.log
echo "Fetching start-appdynamics.sh script" >> appdynamics.log 
wget https://raw.githubusercontent.com/jarocht/WCloud/master/files/start-appdynamics.sh -P /opt/appdynamics/
echo "fetch complete, starting script" >> appdynamics.log 
bash /opt/appdynamics/start-appdynamics.sh &
echo "start-appdynamics.sh script has been started, exiting update-script.sh" >> appdynamics.log 
