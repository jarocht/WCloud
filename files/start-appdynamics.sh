#!bin/bash
export APPDYNAMICS_START_AGENT=true #set to false to disable agent hooking

echo "Start-appdynamics.sh initiated" >> appdynamics.log
echo "Found APPDYNAMICS_START_AGENT set to:${APPDYNAMICS_START_AGENT}" >> appdynamics.log
if [ "$APPDYNAMICS_START_AGENT" = "true" ]; then

    echo "Found APPDYNAMICS_START_DELAY set to:${APPDYNAMICS_START_DELAY}: waiting that long to hook JVM" >> appdynamics.log

    pid=
    while [ -z "$pid" ]
    do
    pid="$(pgrep java)"
    sleep ${APPDYNAMICS_START_DELAY}
    done

    echo "Found PID:${pid}:" >> appdynamics.log

    # Determine tier name from hostname
    #a=m2meventlistenerstg-v2-65785c574d-tlns7
    a=$HOSTNAME
    #b=stg
    b=$spring_profile

    echo "Found HOSTNAME:${a}:" >> appdynamics.log
    echo "Found spring_profile:${b}:" >> appdynamics.log

    strindex() { 
    x="${1%%$2*}"
    [[ "$x" = "$1" ]] && index=-1 || index="${#x}"
    }
    strindex "$a" "$b"
    if [ $index = "-1" ]; then
        echo "WARN: Failed to parse the hostname for a service name, checking for qa." >> appdynamics.log
        strindex "$a" "qa"
        if [ $index = "-1" ]; then
            appd_tier_name=$HOSTNAME
            echo "ERROR: Failed to parse the hostname for a service name, using hostname instead." >> appdynamics.log
        else
            appd_tier_name=${a:0:$index}
        fi
    else
        appd_tier_name=${a:0:$index}
    fi
    echo "Set appd_tier_name to:${appd_tier_name}:" >> appdynamics.log

    export UNIQUE_HOST_ID=$(sed -rn '1s#.*/##; 1s/(.{12}).*/\1/p' /proc/self/cgroup)
    echo "Unique Host ID is:${UNIQUE_HOST_ID}:" >> appdynamics.log

    echo "Hooking AppD agent into pid:${pid}, with app name:WCloud-residential-$spring_profile, tier name:${appd_tier_name}, and node name prefix:${appd_tier_name}, node name reuse is set to 'true'" >> appdynamics.log
    java -Xbootclasspath/a:/usr/lib/jvm/java-1.8.0-openjdk-amd64/lib/tools.jar -jar /opt/appdynamics/agent/javaagent.jar ${pid} appdynamics.agent.applicationName=WCloud-residential-$spring_profile,appdynamics.agent.tierName=${appd_tier_name},appdynamics.agent.reuse.nodeName.prefix=${appd_tier_name},appdynamics.agent.reuse.nodeName=true,appdynamics.agent.uniqueHostId=${UNIQUE_HOST_ID},appdynamics.analytics.agent.url=http://169.60.159.85:9090/v2/sinks/bt &
    echo "AppD agent has been hooked!" >> appdynamics.log
else 
    echo "APPDYNAMICS_START_AGENT is 'false', exiting without hooking agent" >> appdynamics.log
fi
echo "Done Logging" >> appdynamics.log
