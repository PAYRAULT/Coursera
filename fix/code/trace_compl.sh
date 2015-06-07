rm -f new*
echo "new processing"
./trace.sh >trace.txt 2>&1
echo "original processing"
./trace_orig.sh >trace_origin.txt 2>&1
echo "oracle processing"
./trace_oracle.sh >trace_oracle.txt 2>&1
echo "post processing"
sed 's/..\/fix\/code\//.\//' <trace.txt >new
sed 's/..\/oracle\//.\//' <trace_oracle.txt >new_oracle
sed 's/..\/origin\//.\//' <trace_origin.txt >new_origin
