cd ~/diem
cargo check 
cargo fmt
cargo build -p safety-rules --release 
cargo build -p consensus --release
cargo build -p diem-node --release
cargo build -p diem-swarm --release
cargo build -p cluster-test --release
# cargo run -p diem-swarm --release -- --diem-node target/release/diem-node -n 4
# cargo run -p cluster-test --release -- 