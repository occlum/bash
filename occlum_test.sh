# Exit when error
set -e

busybox diff <(cat ./siglist.c) <(cat ./siglist.h) || true
# Test command subsitution and pipe
busybox echo $(busybox echo -e "Hello-world-from-bash\n test" | busybox awk '$1=$1' FS="-" OFS=" ")

# Test command substitution
TMP=/usr/local/lib
busybox echo $TMP
TEST=$(busybox echo $(ls -l $TMP))
busybox echo $TEST

# exit 3

# Test unrecognized commands
fake_inst || true

# Test background process (process group/send signal to front process is not supported)
https_server=simplest_web_server_ssl
cd /root/Dev/OCCLUM/occlum-release/demos/https_server/
./$https_server &
pid=$!
echo "pid = $pid"
curl -k https://127.0.0.1:8443
kill $pid
curl -k https://127.0.0.1:8443 || true

# exit 3
cd -

# Test pipe
busybox echo -e "Hello-world-from-bash\n test" | busybox awk '$1=$1' FS="-" OFS=" " > /root/output.txt
busybox cat /root/output.txt
rm /root/output.txt
busybox ls -l /root/output.txt || true

# Test return value and redirection
if /usr/bin/pgrep occlum-run > /dev/null; then
    echo "a occlum process is running"
else
    echo "no occlum process is running"
fi


# Test subshell
SCRIPT_ENV="this is script env"
(
    busybox echo "in subshell:"
    busybox echo $SCRIPT_ENV
    SUBSHELL_ENV="this is subshell env"
    SCRIPT_ENV="this is script env in subshell"
    busybox echo $SUBSHELL_ENV | busybox awk '{print $3}'
    busybox echo $SCRIPT_ENV
)
busybox echo "out subshell:"
busybox echo $SCRIPT_ENV
busybox echo $SUBSHELL_ENV

#TEST exec in subshell
(
while true
do
    echo "1. Disk Stats "
    echo "2. Get Time "
    Input=2
    case "$Input" in
        1) exec df -kh ;;
        2) exec /bin/date  ;;
    esac
done
)

# Test process substitution and redirection
if busybox diff <(cat /root/Dev/BASH/bash-dev/occlum_test.sh) <(cat /root/Dev/BASH/bash/occlum_test.sh) > log; then
    busybox echo "nothing different"
    exit 1
else
    busybox echo "there is some difference"
fi
busybox cat log
busybox rm log


# Test multiple redirection
busybox ls . *.blah > log 2>&1 || true
busybox echo "start log:"
busybox cat log
busybox rm log

# # Test Occlum
cd ~
rm -rf occlum_instance
occlum new occlum_instance
cp demos/hello_c/hello_world occlum_instance/image/bin
cd occlum_instance
SGX_MODE=SIM occlum build
occlum run /bin/hello_world
occlum build
occlum run /bin/hello_world
occlum build --sgx-mode SIM
occlum run /bin/hello_world

export JAVA_HOME=/opt/occlum/toolchains/jvm/java-11-alibaba-dragonwell/jre
/root/Dev/SPARK/spark-3.1.1-bin-hadoop2.7/bin/spark-submit /root/Dev/SPARK/spark-3.1.1-bin-hadoop2.7/examples/src/main/python/pi.py

echo "TESTS successful"

echo "successful"
exit 3
