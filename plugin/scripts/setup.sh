#!/usr/bin/env bash
#
# claude-cobrain Setup Hook
# Runs after /plugin install - reminds user to run the install skill
#

set -euo pipefail

# Colors
if [[ -t 2 ]]; then
  BOLD='\033[1m'
  GREEN='\033[0;32m'
  YELLOW='\033[1;33m'
  CYAN='\033[0;36m'
  NC='\033[0m'
else
  BOLD='' GREEN='' YELLOW='' CYAN='' NC=''
fi

echo "" >&2
echo -e "${GREEN}========================================${NC}" >&2
echo -e "${GREEN}  claude-cobrain installed successfully  ${NC}" >&2
echo -e "${GREEN}========================================${NC}" >&2
echo "" >&2
echo -e "${YELLOW}${BOLD}>>> Run this command to set up the daemon:${NC}" >&2
echo "" >&2
echo -e "    ${CYAN}/claude-cobrain:install${NC}" >&2
echo "" >&2
echo -e "  This will check prerequisites, deploy the" >&2
echo -e "  daemon script, and start the background service." >&2
echo "" >&2

exit 0
