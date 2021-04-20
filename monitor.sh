#! /bin/bash
# tmux 会话
session1="monitor_swarm"
# 终止可能存在的监控会话
tmux kill-session -t $session1
echo "尝试启动本地集群，启动信息写入临时文件：/home/hmj/temp/temp_swarm_info"
tmux new-session -d -s $session1 -n swarm '/home/hmj/diem/target/release/diem-swarm_leader_reputation --diem-node /home/hmj/diem/target/release/diem-node -n 4 > /home/hmj/temp/temp_swarm_info'
echo "等待10s"
sleep 10s
# 获得集群目录
swarm_path=`cat /home/hmj/temp/temp_swarm_info | grep -P '\--mint-file.*mint.key' -o | uniq | sed 's/\-\-mint\-file \"\(.*\)mint.key/\1/g'`
# 获得集群测试命令参数
cluster_test=`cat /home/hmj/temp/temp_swarm_info | grep -P '\-\-mint\-file.*\-\-emit\-tx' -o`
echo "集群目录：$swarm_path"
echo "集群测试命令参数：$cluster_test"
# 集群各节点配置文件
node_0_config_path=$swarm_path"0/node.yaml"
node_1_config_path=$swarm_path"1/node.yaml"
node_2_config_path=$swarm_path"2/node.yaml"
node_3_config_path=$swarm_path"3/node.yaml"
# 获得集群各节点metrics server port
node_0_metrics_server_port=`cat $node_0_config_path | grep -P '  metrics\_server\_port\: [0-9]+' -o | sed 's/  metrics_server_port: \(.*\)/\1/g'`
node_1_metrics_server_port=`cat $node_1_config_path | grep -P '  metrics\_server\_port\: [0-9]+' -o | sed 's/  metrics_server_port: \(.*\)/\1/g'`
node_2_metrics_server_port=`cat $node_2_config_path | grep -P '  metrics\_server\_port\: [0-9]+' -o | sed 's/  metrics_server_port: \(.*\)/\1/g'`
node_3_metrics_server_port=`cat $node_3_config_path | grep -P '  metrics\_server\_port\: [0-9]+' -o | sed 's/  metrics_server_port: \(.*\)/\1/g'`
# 构造prometheus监控目标
targets="- targets: ['localhost:"$node_0_metrics_server_port"','localhost:"$node_1_metrics_server_port"','localhost:"$node_2_metrics_server_port"','localhost:"$node_3_metrics_server_port"']"
echo "prometheus监控目标：$targets"
# 构造prometheus配置文件
cp /home/hmj/temp/prometheus.yml /home/hmj/temp/temp_prometheus.yml
echo "    "$targets >> /home/hmj/temp/temp_prometheus.yml
# 启动node_exporter
tmux new-window -t $session1 -n node '/home/hmj/node_exporter-1.1.2.linux-amd64/node_exporter'
# 启动pushgateway
tmux new-window -t $session1 -n pushgateway '/home/hmj/pushgateway-1.4.0.linux-amd64/pushgateway'
echo "使用临时配置文件启动prometheus"
tmux new-window -t $session1 -n prometheus '/home/hmj/prometheus-2.26.0.linux-amd64/prometheus --config.file=/home/hmj/temp/temp_prometheus.yml'
# 集群各节点sr配置文件
node_0_safety_rules_config_path=$swarm_path"0/safety_rules.yaml"
node_1_safety_rules_config_path=$swarm_path"1/safety_rules.yaml"
node_2_safety_rules_config_path=$swarm_path"2/safety_rules.yaml"
node_3_safety_rules_config_path=$swarm_path"3/safety_rules.yaml"
# 将集群各节点sr配置文件写入临时文件
echo "$node_0_safety_rules_config_path"> /home/hmj/temp/temp_node_0_safety_rules_config_path
echo "$node_1_safety_rules_config_path"> /home/hmj/temp/temp_node_1_safety_rules_config_path
echo "$node_2_safety_rules_config_path"> /home/hmj/temp/temp_node_2_safety_rules_config_path
echo "$node_3_safety_rules_config_path"> /home/hmj/temp/temp_node_3_safety_rules_config_path
# 启动集群各节点的sr服务
tmux new-window -t $session1 -n sr0 'export PUSH_METRICS_ENDPOINT=http://localhost:9091/metrics/job/sr0;cat /home/hmj/temp/temp_node_0_safety_rules_config_path | xargs -I {} /home/hmj/diem/target/release/safety-rules {} > /home/hmj/temp/temp_sr_log0 2>&1'
tmux new-window -t $session1 -n sr1 'export PUSH_METRICS_ENDPOINT=http://localhost:9091/metrics/job/sr1;cat /home/hmj/temp/temp_node_1_safety_rules_config_path | xargs -I {} /home/hmj/diem/target/release/safety-rules {} > /home/hmj/temp/temp_sr_log1 2>&1'
tmux new-window -t $session1 -n sr2 'export PUSH_METRICS_ENDPOINT=http://localhost:9091/metrics/job/sr2;cat /home/hmj/temp/temp_node_2_safety_rules_config_path | xargs -I {} /home/hmj/diem/target/release/safety-rules {} > /home/hmj/temp/temp_sr_log2 2>&1'
tmux new-window -t $session1 -n sr3 'export PUSH_METRICS_ENDPOINT=http://localhost:9091/metrics/job/sr3;cat /home/hmj/temp/temp_node_3_safety_rules_config_path | xargs -I {} /home/hmj/diem/target/release/safety-rules {} > /home/hmj/temp/temp_sr_log3 2>&1'
# 重启grafana-server服务
systemctl restart grafana-server
echo "tmux 会话运行情况："
tmux ls
