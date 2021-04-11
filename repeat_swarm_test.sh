#! /bin/bash
session1="diem-swarm-LeaderReputation"
session2="diem-swarm-RotatingProposer"

tmux kill-session -t $session1
tmux kill-session -t $session2
rm /home/hmj/temp/LeaderReputation.txt /home/hmj/temp/RotatingProposer.txt
cd /home/hmj/diem
for i in {1..10}; 
do 
    echo "Test $i LeaderReputation part:"
    tmux new-session -d -s $session1 -n swarm 'target/release/diem-swarm_leader_reputation --diem-node target/release/diem-node -n 4 > /home/hmj/temp/temp_swarm_info'
    tmux ls
    sleep 20s
    tmp_path=`cat /home/hmj/temp/temp_swarm_info | grep -P '\--mint-file.*mint.key' -o | uniq | sed 's/\-\-mint\-file \"\(.*\)mint.key/\1/g'`
    cluster_test=`cat /home/hmj/temp/temp_swarm_info | grep -P '\-\-mint\-file.*\-\-emit\-tx' -o`
    echo "临时集群目录：$tmp_path"
    echo "集群测试命令参数：$cluster_test"

    node_0_safety_rules_config_path=$tmp_path"0/safety_rules.yaml"
    node_1_safety_rules_config_path=$tmp_path"1/safety_rules.yaml"
    node_2_safety_rules_config_path=$tmp_path"2/safety_rules.yaml"
    node_3_safety_rules_config_path=$tmp_path"3/safety_rules.yaml"
    echo "$node_0_safety_rules_config_path"> /home/hmj/temp/temp_node_0_safety_rules_config_path
    echo "$node_1_safety_rules_config_path"> /home/hmj/temp/temp_node_1_safety_rules_config_path
    echo "$node_2_safety_rules_config_path"> /home/hmj/temp/temp_node_2_safety_rules_config_path
    echo "$node_3_safety_rules_config_path"> /home/hmj/temp/temp_node_3_safety_rules_config_path
    tmux new-window -t $session1 -n sr0 'cat /home/hmj/temp/temp_node_0_safety_rules_config_path | xargs /home/hmj/diem/target/release/safety-rules'
    tmux new-window -t $session1 -n sr1 'cat /home/hmj/temp/temp_node_1_safety_rules_config_path | xargs /home/hmj/diem/target/release/safety-rules'
    tmux new-window -t $session1 -n sr2 'cat /home/hmj/temp/temp_node_2_safety_rules_config_path | xargs /home/hmj/diem/target/release/safety-rules'
    tmux new-window -t $session1 -n sr3 'cat /home/hmj/temp/temp_node_3_safety_rules_config_path | xargs /home/hmj/diem/target/release/safety-rules'
    
    effect_port=`cat $node_0_safety_rules_config_path | grep -P "/ip4/.*/tcp/[0-9]+" -o | sed 's/\/ip4\/0\.0\.0\.0\/tcp\/\([0-9]*\)/\1/g' | tail -n 1`
    echo "$effect_port" | xargs iptables -A INPUT -p tcp -m statistic --mode random --probability 0.50 -j DROP --dport
    echo "影响端口：$effect_port"
    iptables -L INPUT -n
    echo "$cluster_test" | xargs target/release/cluster-test >> /home/hmj/temp/LeaderReputation.txt
    echo "$effect_port" | xargs iptables -D INPUT -p tcp -m statistic --mode random --probability 0.50 -j DROP --dport
    tmux kill-session -t $session1

    echo "Test $i RotatingProposer part:"
    tmux new-session -d -s $session2 -n swarm 'target/release/diem-swarm_rotating_proposer --diem-node target/release/diem-node -n 4 > /home/hmj/temp/temp_swarm_info'
    tmux ls
    sleep 20s
    tmp_path=`cat /home/hmj/temp/temp_swarm_info | grep -P '\--mint-file.*mint.key' -o | uniq | sed 's/\-\-mint\-file \"\(.*\)mint.key/\1/g'`
    cluster_test=`cat /home/hmj/temp/temp_swarm_info | grep -P '\-\-mint\-file.*\-\-emit\-tx' -o`
    echo "临时集群目录：$tmp_path"
    echo "集群测试命令参数：$cluster_test"

    node_0_safety_rules_config_path=$tmp_path"0/safety_rules.yaml"
    node_1_safety_rules_config_path=$tmp_path"1/safety_rules.yaml"
    node_2_safety_rules_config_path=$tmp_path"2/safety_rules.yaml"
    node_3_safety_rules_config_path=$tmp_path"3/safety_rules.yaml"
    echo "$node_0_safety_rules_config_path"> /home/hmj/temp/temp_node_0_safety_rules_config_path
    echo "$node_1_safety_rules_config_path"> /home/hmj/temp/temp_node_1_safety_rules_config_path
    echo "$node_2_safety_rules_config_path"> /home/hmj/temp/temp_node_2_safety_rules_config_path
    echo "$node_3_safety_rules_config_path"> /home/hmj/temp/temp_node_3_safety_rules_config_path
    tmux new-window -t $session2 -n sr0 'cat /home/hmj/temp/temp_node_0_safety_rules_config_path | xargs /home/hmj/diem/target/release/safety-rules'
    tmux new-window -t $session2 -n sr1 'cat /home/hmj/temp/temp_node_1_safety_rules_config_path | xargs /home/hmj/diem/target/release/safety-rules'
    tmux new-window -t $session2 -n sr2 'cat /home/hmj/temp/temp_node_2_safety_rules_config_path | xargs /home/hmj/diem/target/release/safety-rules'
    tmux new-window -t $session2 -n sr3 'cat /home/hmj/temp/temp_node_3_safety_rules_config_path | xargs /home/hmj/diem/target/release/safety-rules'
    
    effect_port=`cat $node_0_safety_rules_config_path | grep -P "/ip4/.*/tcp/[0-9]+" -o | sed 's/\/ip4\/0\.0\.0\.0\/tcp\/\([0-9]*\)/\1/g' | tail -n 1`
    echo "$effect_port" | xargs iptables -A INPUT -p tcp -m statistic --mode random --probability 0.50 -j DROP --dport
    echo "影响端口：$effect_port"
    iptables -L INPUT -n
    echo "$cluster_test" | xargs target/release/cluster-test >> /home/hmj/temp/RotatingProposer.txt
    echo "$effect_port" | xargs iptables -D INPUT -p tcp -m statistic --mode random --probability 0.50 -j DROP --dport
    tmux kill-session -t $session2
done
chmod a+w /home/hmj/temp/LeaderReputation.txt
chmod a+w /home/hmj/temp/RotatingProposer.txt

echo "LeaderReputation:"
cat /home/hmj/temp/LeaderReputation.txt | grep -P "Total.*" -o  | sed 's/.*, committed: \([0-9]*\), expired: 0/\1/g' | awk '{sum+=$1} END {print  "Average rate committed: " sum/NR/60 " txn/s"}'
echo "RotatingProposer:"
cat /home/hmj/temp/RotatingProposer.txt | grep -P "Total.*" -o  | sed 's/.*, committed: \([0-9]*\), expired: 0/\1/g' | awk '{sum+=$1} END {print  "Average rate committed: " sum/NR/60 " txn/s"}'