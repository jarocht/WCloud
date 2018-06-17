#!bin/bash
echo "Start up initiated" >> appdynamics.log 
echo "Found APPDYNAMICS_START_AGENT set to:${APPDYNAMICS_START_AGENT}" >> appdynamics.log
if [ "$APPDYNAMICS_START_AGENT" = 'true' ]; then

    pid=
    while [ -z "$pid" ]
    do
    pid="$(pgrep java)"
    sleep 30
    done

    echo "Found PID:${pid}:" >> appdynamics.log

    # Determine tier name from hostname
    a=m2meventlistenerstg-v2-65785c574d-tlns7
    #a=$HOSTNAME
    b=stg
    #b=$spring_profile

    echo "Found HOSTNAME:${a}:" >> appdynamics.log
    echo "Found spring_profile:${b}:" >> appdynamics.log

    strindex() { 
    x="${1%%$2*}"
    [[ "$x" = "$1" ]] && index=-1 || index="${#x}"
    }
    strindex "$a" "$b"
    if [ $index = "-1" ]; then
        appd_tier_name=$HOSTNAME
        echo "ERROR: Failed to parse the hostname for a service name, using hostname instead." >> appdynamics.log
    else
        appd_tier_name=${a:0:$index}
    fi
    echo "Set appd_tier_name to:${appd_tier_name}:" >> appdynamics.log

    echo "Hooking AppD agent into pid:${pid}, with tier name:${appd_tier_name}, and node name:${HOSTNAME}" >> appdynamics.log
    java -Xbootclasspath/a:/usr/lib/jvm/java-1.8.0-openjdk-amd64/lib/tools.jar -jar /opt/appdynamics/agent/javaagent.jar ${pid} appdynamics.agent.tierName=${appd_tier_name},appdynamics.agent.nodeName=${HOSTNAME} >> appdynamics.log
else 
    echo "APPDYNAMICS_START_AGENT is 'false', exiting without hooking agent" >> appdynamics.log
fi
