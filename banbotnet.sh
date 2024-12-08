#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <path to lists>

Usage example: 

$0 /data/lists"
    exit 1
fi

folder_path="$1"

ipset_name_v4="botnet_ips_v4"
ipset_name_v6="botnet_ips_v6"

if ! ipset -L | grep -q "$ipset_name_v4"; then
    ipset create $ipset_name_v4 hash:ip
fi

if ! ipset -L | grep -q "$ipset_name_v6"; then
    ipset create $ipset_name_v6 hash:ip family inet6
fi

cd "$folder_path" || exit

total_lines=$(grep -hcv '^#' * | wc -l)
current_line=0

for file in *; do
    [[ ! -f $file || $file == *"."* ]] || continue

    while IFS= read -r line; do
        ((current_line++))
        ip=$(echo "$line" | awk '{print $folder_path}')
        if [[ ! -z $ip ]]; then
            if [[ $ip =~ .*:.* ]]; then
                if ! ipset test $ipset_name_v6 $ip &>/dev/null; then
                    ipset add $ipset_name_v6 $ip &>/dev/null
                fi
            else
                if ! ipset test $ipset_name_v4 $ip &>/dev/null; then
                    ipset add $ipset_name_v4 $ip &>/dev/null
                fi
            fi
        fi
    done < "$file"
done

iptables -I INPUT -m set --match-set $ipset_name_v4 src -j DROP
iptables -I OUTPUT -m set --match-set $ipset_name_v4 dst -j DROP

ip6tables -I INPUT -m set --match-set $ipset_name_v6 src -j DROP
ip6tables -I OUTPUT -m set --match-set $ipset_name_v6 dst -j DROP

netfilter-persistent save
netfilter-persistent reload

service iptables restart
