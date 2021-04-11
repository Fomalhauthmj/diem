#! /bin/bash
session1="monitor_swarm"
tmux kill-session -t $session1
echo "尝试启动本地集群"
tmux new-session -d -s $session1 -n swarm '~/diem/target/release/diem-swarm --diem-node ~/diem/target/release/diem-node -n 4 > ~/temp/temp_swarm_info'
tmux ls
echo "等待10s"
sleep 10s
tmp_path=`cat ~/temp/temp_swarm_info | grep -P '\--mint-file.*mint.key' -o | uniq | sed 's/\-\-mint\-file \"\(.*\)mint.key/\1/g'`
cluster_test=`cat ~/temp/temp_swarm_info | grep -P '\-\-mint\-file.*\-\-emit\-tx' -o`
echo "集群测试命令参数：$cluster_test"
echo "临时集群目录：$tmp_path"
node_0_config_path=$tmp_path"0/node.yaml"
node_1_config_path=$tmp_path"1/node.yaml"
node_2_config_path=$tmp_path"2/node.yaml"
node_3_config_path=$tmp_path"3/node.yaml"
node_0_safety_rules_config_path=$tmp_path"0/safety_rules.yaml"
node_1_safety_rules_config_path=$tmp_path"1/safety_rules.yaml"
node_2_safety_rules_config_path=$tmp_path"2/safety_rules.yaml"
node_3_safety_rules_config_path=$tmp_path"3/safety_rules.yaml"
echo "$node_0_safety_rules_config_path"> ~/temp/temp_node_0_safety_rules_config_path
echo "$node_1_safety_rules_config_path"> ~/temp/temp_node_1_safety_rules_config_path
echo "$node_2_safety_rules_config_path"> ~/temp/temp_node_2_safety_rules_config_path
echo "$node_3_safety_rules_config_path"> ~/temp/temp_node_3_safety_rules_config_path
tmux new-window -t $session1 -n sr0 'cat ~/temp/temp_node_0_safety_rules_config_path | xargs ~/diem/target/release/safety-rules'
tmux new-window -t $session1 -n sr1 'cat ~/temp/temp_node_1_safety_rules_config_path | xargs ~/diem/target/release/safety-rules'
tmux new-window -t $session1 -n sr2 'cat ~/temp/temp_node_2_safety_rules_config_path | xargs ~/diem/target/release/safety-rules'
tmux new-window -t $session1 -n sr3 'cat ~/temp/temp_node_3_safety_rules_config_path | xargs ~/diem/target/release/safety-rules'


node_0_metrics_server_port=`cat $node_0_config_path | grep -P '  metrics\_server\_port\: [0-9]+' -o | sed 's/  metrics_server_port: \(.*\)/\1/g'`
node_1_metrics_server_port=`cat $node_1_config_path | grep -P '  metrics\_server\_port\: [0-9]+' -o | sed 's/  metrics_server_port: \(.*\)/\1/g'`
node_2_metrics_server_port=`cat $node_2_config_path | grep -P '  metrics\_server\_port\: [0-9]+' -o | sed 's/  metrics_server_port: \(.*\)/\1/g'`
node_3_metrics_server_port=`cat $node_3_config_path | grep -P '  metrics\_server\_port\: [0-9]+' -o | sed 's/  metrics_server_port: \(.*\)/\1/g'`

targets="- targets: ['localhost:"$node_0_metrics_server_port"','localhost:"$node_1_metrics_server_port"','localhost:"$node_2_metrics_server_port"','localhost:"$node_3_metrics_server_port"']"

cp ~/temp/prometheus.yml ~/temp/temp_prometheus.yml
echo "    "$targets >> ~/temp/temp_prometheus.yml
echo "Prometheus配置文件写入完成"
tmux new-window -t $session1 -n node '~/node_exporter-1.1.2.linux-amd64/node_exporter'
echo "使用此配置启动Prometheus"
tmux new-window -t $session1 -n prometheus '~/prometheus-2.26.0.linux-amd64/prometheus --config.file=/home/hmj/temp/temp_prometheus.yml'
tmux ls
