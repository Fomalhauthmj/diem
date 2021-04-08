#! /bin/bash
cd ~
touch enable.txt
touch disable.txt

session1="enable_swarm"
session2="disable_swarm"

tmux kill-session -t $session1
tmux kill-session -t $session2

cd ~/diem
for i in {1..20}; 
do 
    echo "Test $i enable part:"
    tmux new-session -d -s $session1 -n swarm 'target/release/diem-swarm-enable-cachedverifiedQCs --diem-node target/release/diem-node -n 4 > ~/info.txt'
    tmux ls
    sleep 10s
    cat ~/info.txt | grep -P '\-\-mint\-file.*\-\-emit\-tx' -o | xargs cargo run -p cluster-test --release -- >> ~/enable.txt
    tmux kill-session -t $session1

    echo "Test $i disable part:"
    tmux new-session -d -s $session2 -n swarm 'target/release/diem-swarm-disable-cachedverifiedQCs --diem-node target/release/diem-node -n 4 > ~/info.txt'
    tmux ls
    sleep 10s
    cat ~/info.txt | grep -P '\-\-mint\-file.*\-\-emit\-tx' -o | xargs cargo run -p cluster-test --release -- >> ~/disable.txt
    tmux kill-session -t $session2
done