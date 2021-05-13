num=$(awk 'BEGIN{for(i=0;i<=0.7;i+=0.05)print i}')
rm /home/hmj/temp/report
echo "Loss,Method,mean(submitted),mean(committed),mean(expired),mean(latency),mean(p99latency),median(submitted),median(committed),median(expired),median(latency),median(p99latency),pstdev(submitted),pstdev(committed),pstdev(expired),pstdev(latency),pstdev(p99latency)" > /home/hmj/temp/report
chmod a+x /home/hmj/temp/report
for i in $num
do 
     echo "current Loss:$i"
     sudo /home/hmj/diem/repeat_swarm_test_random.sh $i
done
# 生成原始数据
# cat temp/report.txt | rg "Average rate committed: " | sed 's/Average rate committed: \(.*\) txn\/s/\1/g'> temp/execl_data