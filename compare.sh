EXPECTED="$1"
RESULT="$2"

# ANSI color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo "Expected: $EXPECTED"
echo "Result: $RESULT"

if [ "$RESULT" = "$EXPECTED" ]; then
    echo -e "${GREEN}Test passed${NC}"
else
    echo -e "${RED}Test failed: variables are not equal"
fi

echo "---"