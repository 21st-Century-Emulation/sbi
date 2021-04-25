docker build -q -t sbi .
docker run --rm --name sbi -d -p 8080:8080 sbi

RESULT=`curl -s --header "Content-Type: application/json" \
  --request POST \
  --data '{"id":"abcd", "opcode":222,"state":{"a":0,"b":1,"c":0,"d":5,"e":15,"h":10,"l":20,"flags":{"sign":false,"zero":false,"auxCarry":false,"parity":false,"carry":true},"programCounter":1,"stackPointer":2,"cycles":0,"interruptsEnabled":true}}' \
  http://localhost:8080/api/v1/execute?operand1=1`
EXPECTED='{"id":"abcd", "opcode":222,"state":{"a":254,"b":1,"c":0,"d":5,"e":15,"h":10,"l":20,"flags":{"sign":true,"zero":false,"auxCarry":false,"parity":false,"carry":true},"programCounter":1,"stackPointer":2,"cycles":7,"interruptsEnabled":true}}'

docker kill sbi

DIFF=`diff <(jq -S . <<< "$RESULT") <(jq -S . <<< "$EXPECTED")`

if [ $? -eq 0 ]; then
    echo -e "\e[32mSBI Test Pass \e[0m"
    exit 0
else
    echo -e "\e[31mSBI Test Fail  \e[0m"
    echo "$RESULT"
    echo "$DIFF"
    exit -1
fi