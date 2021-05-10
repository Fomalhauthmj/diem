num=$(awk 'BEGIN{for(i=0;i<=1;i+=0.01)print i}')
rm /home/hmj/temp/report.txt
for i in $num
do 
     echo "Loss:$i"
     sudo /home/hmj/diem/repeat_swarm_test.sh $i
done
# 生成原始数据
# cat temp/report.txt | rg "Average rate committed: " | sed 's/Average rate committed: \(.*\) txn\/s/\1/g'> temp/execl_data