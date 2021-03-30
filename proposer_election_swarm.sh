#! /bin/bash
session1="leader_reputation_swarm"
session2="rotating_proposer_swarm"
tmux kill-session -t $session1
tmux kill-session -t $session2

cd ~/diem

tmux new-session -d -s $session1 -n node0 'cargo run -p diem-node --release -- -f ~/dev_tests/leader_reputation_swarm/0/node.yaml'
tmux new-window -t $session1 -n node1 'cargo run -p diem-node --release -- -f ~/dev_tests/leader_reputation_swarm/1/node.yaml'
tmux new-window -t $session1 -n node2 'cargo run -p diem-node --release -- -f ~/dev_tests/leader_reputation_swarm/2/node.yaml'
tmux new-window -t $session1 -n node3 'cargo run -p diem-node --release -- -f ~/dev_tests/leader_reputation_swarm/3/node.yaml'

echo "Waiting 10s"
sleep 10s

cargo run -p cluster-test --release -- --mint-file ~/dev_tests/leader_reputation_swarm/mint.key --swarm --peers "localhost:42375,localhost:44241,localhost:44323,localhost:44415" --emit-tx > ~/dev_tests/leader_reputation_swarm/output.txt
echo "leader_reputation_swarm Test Finished"
tmux kill-session -t $session1

tmux new-session -d -s $session2 -n node0 'cargo run -p diem-node --release -- -f ~/dev_tests/rotating_proposer_swarm/0/node.yaml'
tmux new-window -t $session2 -n node1 'cargo run -p diem-node --release -- -f ~/dev_tests/rotating_proposer_swarm/1/node.yaml'
tmux new-window -t $session2 -n node2 'cargo run -p diem-node --release -- -f ~/dev_tests/rotating_proposer_swarm/2/node.yaml'
tmux new-window -t $session2 -n node3 'cargo run -p diem-node --release -- -f ~/dev_tests/rotating_proposer_swarm/3/node.yaml'

echo "Waiting 10s"
sleep 10s

cargo run -p cluster-test --release -- --mint-file ~/dev_tests/rotating_proposer_swarm/mint.key --swarm --peers "localhost:44723,localhost:38881,localhost:38439,localhost:44223" --emit-tx > ~/dev_tests/rotating_proposer_swarm/output.txt
echo "rotating_proposer_swarm Test Finished"
tmux kill-session -t $session2

echo "leader_reputation_swarm:"
cat ~/dev_tests/leader_reputation_swarm/output.txt
echo "rotating_proposer_swarm:"
cat ~/dev_tests/rotating_proposer_swarm/output.txt
