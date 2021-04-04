#! /bin/bash
for i in {1..20}; 
do 
    ./proposer_election_swarm.sh
    echo "Test $i:">> ~/summary.txt
    cat ~/dev_tests/leader_reputation_swarm/output.txt ~/dev_tests/rotating_proposer_swarm/output.txt >> ~/summary.txt 
done