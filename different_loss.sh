num=$(awk 'BEGIN{for(i=0;i<=1;i+=0.25)print i}')
rm /home/hmj/temp/report.txt
for i in $num
do 
     echo "Loss:$i"
     sudo /home/hmj/diem/repeat_swarm_test.sh $i
done