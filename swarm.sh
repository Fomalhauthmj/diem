#! /bin/bash
session1="swarm0"
tmux kill-session -t $session1

cd /home/hmj/diem

#echo "删除可能存在的丢包模拟"
#sudo tc qdisc del dev lo root

#echo "添加丢包模拟"
#sudo tc qdisc add dev lo root netem loss 20% 100%

tmux new-session -d -s $session1 -n node0 'cargo run -p diem-node --release -- -f /home/hmj/test_swarm/0/node.yaml'
tmux new-window -t $session1 -n node1 'cargo run -p diem-node --release -- -f /home/hmj/test_swarm/1/node.yaml'
tmux new-window -t $session1 -n node2 'cargo run -p diem-node --release -- -f /home/hmj/test_swarm/2/node.yaml'
tmux new-window -t $session1 -n node3 'cargo run -p diem-node --release -- -f /home/hmj/test_swarm/3/node.yaml'

tmux ls
echo "Waiting 10s"
sleep 10s

cargo run -p cluster-test --release -- --mint-file /home/hmj/test_swarm/mint.key --swarm --peers "localhost:43337,localhost:41821,localhost:41295,localhost:41111" --emit-tx >~/tmpout0
echo "swarm0 Test Finished"
tmux kill-session -t $session1


#echo "删除丢包模拟"
#sudo tc qdisc del dev lo root

