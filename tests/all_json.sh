#! /bin/sh
#script qui lance tous les jsons

TESTREP=$1
echo "******************"
echo "/tests/core/batch/19.json"
python $TESTREP/check_test.py --prefix ../build/ --test $TESTREP/tests/core/batch/19.json

echo "/tests/core/batch/20.json"
python $TESTREP/check_test.py --prefix ../build/ --test $TESTREP/tests/core/batch/20.json

echo "/tests/core/doesitwork/10.json"
python $TESTREP/check_test.py --prefix ../build/ --test $TESTREP/tests/core/doesitwork/10.json

echo "/tests/core/doesitwork/7.json"
python $TESTREP/check_test.py --prefix ../build/ --test $TESTREP/tests/core/doesitwork/7.json

echo "/tests/core/doesitwork/8.json"
python $TESTREP/check_test.py --prefix ../build/ --test $TESTREP/tests/core/doesitwork/8.json

echo "/tests/core/doesitwork/9.json"
python $TESTREP/check_test.py --prefix ../build/ --test $TESTREP/tests/core/doesitwork/9.json

echo "/tests/core/edge/badargs/11.json"
python $TESTREP/check_test.py --prefix ../build/ --test $TESTREP/tests/core/edge/badargs/11.json

echo "/tests/core/edge/badargs/12.json"
python $TESTREP/check_test.py --prefix ../build/ --test $TESTREP/tests/core/edge/badargs/12.json

echo "/tests/core/edge/badstate/13.json"
python $TESTREP/check_test.py --prefix ../build/ --test $TESTREP/tests/core/edge/badstate/13.json

echo "/tests/core/edge/badstate/14.json"
python $TESTREP/check_test.py --prefix ../build/ --test $TESTREP/tests/core/edge/badstate/14.json

echo "/tests/core/features/rooms/17.json"
python $TESTREP/check_test.py --prefix ../build/ --test $TESTREP/tests/core/features/rooms/17.json

echo "/tests/core/features/rooms/18.json"
python $TESTREP/check_test.py --prefix ../build/ --test $TESTREP/tests/core/features/rooms/18.json

echo "/tests/core/features/summary/15.json"
python $TESTREP/check_test.py --prefix ../build/ --test $TESTREP/tests/core/features/summary/15.json

echo "/tests/core/features/summary/16.json"
python $TESTREP/check_test.py --prefix ../build/ --test $TESTREP/tests/core/features/summary/16.json

echo "/tests/optional/roomhistory/21.json"
python $TESTREP/check_test.py --prefix ../build/ --test $TESTREP/tests/optional/roomhistory/21.json

echo "/tests/optional/roomhistory/22.json"
python $TESTREP/check_test.py --prefix ../build/ --test $TESTREP/tests/optional/roomhistory/22.json

echo "/tests/optional/roomhistory/29.json"
python $TESTREP/check_test.py --prefix ../build/ --test $TESTREP/tests/optional/roomhistory/29.json

echo "/tests/optional/roomhistory/30.json"
python $TESTREP/check_test.py --prefix ../build/ --test $TESTREP/tests/optional/roomhistory/30.json

echo "/tests/optional/roomhistory/31.json"
python $TESTREP/check_test.py --prefix ../build/ --test $TESTREP/tests/optional/roomhistory/31.json

echo "/tests/optional/time/23.json"
python $TESTREP/check_test.py --prefix ../build/ --test $TESTREP/tests/optional/time/23.json

echo "/tests/optional/time/24.json"
python $TESTREP/check_test.py --prefix ../build/ --test $TESTREP/tests/optional/time/24.json

echo "/tests/optional/time/32.json"
python $TESTREP/check_test.py --prefix ../build/ --test $TESTREP/tests/optional/time/32.json

echo "/tests/optional/time/33.json"
python $TESTREP/check_test.py --prefix ../build/ --test $TESTREP/tests/optional/time/33.json

echo "/tests/optional/time/34.json"
python $TESTREP/check_test.py --prefix ../build/ --test $TESTREP/tests/optional/time/34.json

echo "/tests/perf/size/1.json"
python $TESTREP/check_test.py --prefix ../build/ --test $TESTREP/tests/perf/size/1.json

echo "/tests/perf/size/2.json"
python $TESTREP/check_test.py --prefix ../build/ --test $TESTREP/tests/perf/size/2.json

echo "/tests/perf/size/25.json"
python $TESTREP/check_test.py --prefix ../build/ --test $TESTREP/tests/perf/size/25.json

echo "/tests/perf/size/26.json"
python $TESTREP/check_test.py --prefix ../build/ --test $TESTREP/tests/perf/size/26.json

echo "/tests/perf/size/3.json"
python $TESTREP/check_test.py --prefix ../build/ --test $TESTREP/tests/perf/size/3.json

echo "/tests/perf/speed/27.json"
python $TESTREP/check_test.py --prefix ../build/ --test $TESTREP/tests/perf/speed/27.json

echo "/tests/perf/speed/28.json"
python $TESTREP/check_test.py --prefix ../build/ --test $TESTREP/tests/perf/speed/28.json

echo "/tests/perf/speed/4.json"
python $TESTREP/check_test.py --prefix ../build/ --test $TESTREP/tests/perf/speed/4.json

echo "/tests/perf/speed/5.json"
python $TESTREP/check_test.py --prefix ../build/ --test $TESTREP/tests/perf/speed/5.json

echo "/tests/perf/speed/6.json"
python $TESTREP/check_test.py --prefix ../build/ --test $TESTREP/tests/perf/speed/6.json
