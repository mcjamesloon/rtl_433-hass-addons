#!/usr/bin/env bashio

conf_directory="/config/rtl_433"

if bashio::services.available "mqtt"; then
    host=$(bashio::services "mqtt" "host")
    password=$(bashio::services "mqtt" "password")
    port=$(bashio::services "mqtt" "port")
    username=$(bashio::services "mqtt" "username")
    retain=$(bashio::config "retain")
else
    bashio::log.info "The mqtt addon is not available."
    bashio::log.info "Manually update the output line in the configuration file with mqtt connection settings, and restart the addon."
fi


rtl_433 -f 344975000 -F json -M utc | while read line
do
  sensor_id=`echo $line |  jq -c ".id"`
  sensor_data=`echo "$line"`
  
  bashio::log.info $sensor_id
  bashio::log.info $sensor_data
  #send sensor data to unique MQTT topic by sensor ID. MQTT debug on '-d'
  echo $sensor_data | mosquitto_pub -h $host -p 1883 -i RTL_433 -l -t honeywell/sensor/$sensor_id -u $username -P $password -d

done

#rtl_433_pids=()
#for template in $conf_directory/*.conf.template
#do
    # Remove '.template' from the file name.
#    live=$(basename $template .template)

    # By sourcing the template, we can substitute any environment variable in
    # the template. In fact, enterprising users could write _any_ valid bash
    # to create the final configuration file. To simplify template creation,
    # we wrap the needed redirections into a temparary file.
#    echo "cat <<EOD > $live" > /tmp/rtl_433_heredoc
#    cat $template >> /tmp/rtl_433_heredoc
#    echo EOD >> /tmp/rtl_433_heredoc

#    source /tmp/rtl_433_heredoc

#    echo "Starting rtl_433 with $live..."
#    tag=$(basename $live .conf)
#    rtl_433 -c "$live" > >(sed "s/^/[$tag] /") 2> >(>&2 sed "s/^/[$tag] /")&
#    rtl_433_pids+=($!)
#done

#wait -n ${rtl_433_pids[*]}
