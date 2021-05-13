#! /bin/bash

# tmux会话
session1="diem-swarm-LR"
session2="diem-swarm-RP"

# 终止可能存在的测试会话
tmux kill-session -t $session1
tmux kill-session -t $session2

# 读入设定Loss
Loss=$1
echo "当前Loss：$Loss"

# 删除测试结果文件
rm /home/hmj/temp/temp_test_result_LR
rm /home/hmj/temp/temp_test_result_RP

cd /home/hmj/diem

for i in {1..10}; 
do 
    echo "Test $i LR part:"
    echo "尝试启动本地集群，启动信息写入临时文件：/home/hmj/temp/temp_swarm_info"
    tmux new-session -d -s $session1 -n swarm 'target/release/diem-swarm-lr --diem-node target/release/diem-node -n 4 > /home/hmj/temp/temp_swarm_info'
    sleep 20s
    swarm_path=`cat /home/hmj/temp/temp_swarm_info | grep -P '\--mint-file.*mint.key' -o | uniq | sed 's/\-\-mint\-file \"\(.*\)mint.key/\1/g'`
    cluster_test=`cat /home/hmj/temp/temp_swarm_info | grep -P '\-\-mint\-file.*\-\-emit\-tx' -o`
    echo "集群目录：$swarm_path"
    echo "集群测试命令参数：$cluster_test"
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
    tmux new-window -t $session1 -n sr0 'cat /home/hmj/temp/temp_node_0_safety_rules_config_path | xargs /home/hmj/diem/target/release/safety-rules'
    tmux new-window -t $session1 -n sr1 'cat /home/hmj/temp/temp_node_1_safety_rules_config_path | xargs /home/hmj/diem/target/release/safety-rules'
    tmux new-window -t $session1 -n sr2 'cat /home/hmj/temp/temp_node_2_safety_rules_config_path | xargs /home/hmj/diem/target/release/safety-rules'
    tmux new-window -t $session1 -n sr3 'cat /home/hmj/temp/temp_node_3_safety_rules_config_path | xargs /home/hmj/diem/target/release/safety-rules'
    # 设置影响端口
    effect_port=`cat $node_0_safety_rules_config_path | grep -P "/ip4/.*/tcp/[0-9]+" -o | sed 's/\/ip4\/0\.0\.0\.0\/tcp\/\([0-9]*\)/\1/g' | tail -n 1`
    echo "$effect_port" | xargs iptables -A INPUT -p tcp -m statistic --mode random --probability $Loss -j DROP --dport
    echo "影响端口：$effect_port"
    # 当前干扰规则
    iptables -L INPUT -n
    # 启动集群测试
    echo "$cluster_test" | xargs target/release/cluster-test >> /home/hmj/temp/temp_test_result_LR
    # 删除干扰规则
    echo "$effect_port" | xargs iptables -D INPUT -p tcp -m statistic --mode random --probability $Loss -j DROP --dport
    # 终止测试会话
    tmux kill-session -t $session1
    # 删除测试目录
    rm -rf "$swarm_path"

    echo "Test $i RP part:"
    echo "尝试启动本地集群，启动信息写入临时文件：/home/hmj/temp/temp_swarm_info"
    tmux new-session -d -s $session2 -n swarm 'target/release/diem-swarm-rp --diem-node target/release/diem-node -n 4 > /home/hmj/temp/temp_swarm_info'
    sleep 20s
    swarm_path=`cat /home/hmj/temp/temp_swarm_info | grep -P '\--mint-file.*mint.key' -o | uniq | sed 's/\-\-mint\-file \"\(.*\)mint.key/\1/g'`
    cluster_test=`cat /home/hmj/temp/temp_swarm_info | grep -P '\-\-mint\-file.*\-\-emit\-tx' -o`
    echo "集群目录：$swarm_path"
    echo "集群测试命令参数：$cluster_test"
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
    tmux new-window -t $session2 -n sr0 'cat /home/hmj/temp/temp_node_0_safety_rules_config_path | xargs /home/hmj/diem/target/release/safety-rules'
    tmux new-window -t $session2 -n sr1 'cat /home/hmj/temp/temp_node_1_safety_rules_config_path | xargs /home/hmj/diem/target/release/safety-rules'
    tmux new-window -t $session2 -n sr2 'cat /home/hmj/temp/temp_node_2_safety_rules_config_path | xargs /home/hmj/diem/target/release/safety-rules'
    tmux new-window -t $session2 -n sr3 'cat /home/hmj/temp/temp_node_3_safety_rules_config_path | xargs /home/hmj/diem/target/release/safety-rules'
    # 设置影响端口
    effect_port=`cat $node_0_safety_rules_config_path | grep -P "/ip4/.*/tcp/[0-9]+" -o | sed 's/\/ip4\/0\.0\.0\.0\/tcp\/\([0-9]*\)/\1/g' | tail -n 1`
    echo "$effect_port" | xargs iptables -A INPUT -p tcp -m statistic --mode random --probability $Loss -j DROP --dport
    echo "影响端口：$effect_port"
    # 当前干扰规则
    iptables -L INPUT -n
    # 启动集群测试
    echo "$cluster_test" | xargs target/release/cluster-test >> /home/hmj/temp/temp_test_result_RP
    # 删除干扰规则
    echo "$effect_port" | xargs iptables -D INPUT -p tcp -m statistic --mode random --probability $Loss -j DROP --dport
    # 终止测试会话 
    tmux kill-session -t $session2
    # 删除测试目录
    rm -rf "$swarm_path"
done
# 设置修改权限
chmod a+w /home/hmj/temp/temp_test_result_LR
chmod a+w /home/hmj/temp/temp_test_result_RP

# 汇总计算
rm /home/hmj/temp/temp_data_file_LR
echo "submitted committed expired latency p99latency" > /home/hmj/temp/temp_data_file_LR
cat /home/hmj/temp/temp_test_result_LR | grep -P "Average.*" -o | sed 's/Average rate: submitted: \([0-9]*\) txn\/s, committed: \([0-9]*\) txn\/s, expired: \([0-9]*\) txn\/s, latency: \([0-9]*\) ms, p99 latency: \([0-9]*\) ms/\1 \2 \3 \4 \5/g' >> /home/hmj/temp/temp_data_file_LR
output_lr=`cat /home/hmj/temp/temp_data_file_LR | datamash --whitespace --header-in --round 2 --output-delimiter=, mean 1,2,3,4,5 median 1,2,3,4,5 pstdev 1,2,3,4,5`
echo "$Loss,LR,$output_lr" >> /home/hmj/temp/report
rm /home/hmj/temp/temp_data_file_RP
echo "submitted committed expired latency p99latency" > /home/hmj/temp/temp_data_file_RP
cat /home/hmj/temp/temp_test_result_RP | grep -P "Average.*" -o | sed 's/Average rate: submitted: \([0-9]*\) txn\/s, committed: \([0-9]*\) txn\/s, expired: \([0-9]*\) txn\/s, latency: \([0-9]*\) ms, p99 latency: \([0-9]*\) ms/\1 \2 \3 \4 \5/g' >> /home/hmj/temp/temp_data_file_RP
output_rp=`cat /home/hmj/temp/temp_data_file_RP | datamash --whitespace --header-in --round 2 --output-delimiter=, mean 1,2,3,4,5 median 1,2,3,4,5 pstdev 1,2,3,4,5`
echo "$Loss,RP,$output_rp" >> /home/hmj/temp/report


