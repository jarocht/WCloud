#!bin/bash
mkdir -p /started

pid=
while [ -z "$pid" ]
do
  pid="$(pgrep java)"
  sleep 30
done

mkdir -p /pid-${pid}

# Determine tier name from hostname
a=m2meventlistenerstg-v2-65785c574d-tlns7
#a=$HOSTNAME
b=stg
#b=$spring_profile

strindex() { 
  x="${1%%$2*}"
  [[ "$x" = "$1" ]] && index=-1 || index="${#x}"
}
strindex "$a" "$b"
if [ $index = "-1" ]; then
    #hostname parsing failed
    appd_tier_name=$HOSTNAME
else
    appd_tier_name=${a:0:$index}
fi
echo $appd_tier_name
mkdir -p /tier_name-$appd_tier_name
mkdir -p /node-name-$HOSTNAME


java -Xbootclasspath/a:/usr/lib/jvm/java-1.8.0-openjdk-amd64/lib/tools.jar -jar /opt/appdynamics/agent/javaagent.jar ${pid} appdynamics.agent.tierName=${appd_tier_name},appdynamics.agent.nodeName=${HOSTNAME}
