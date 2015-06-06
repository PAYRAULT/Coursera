./trace.sh >trace.txt 2>&1
./trace_orig.sh >trace_orig.txt 2>&1
sed 's/..\/fix\/code\//.\//' <trace.txt >new
sed 's/..\/origin\//.\//' <trace_orig.txt >new_orig
