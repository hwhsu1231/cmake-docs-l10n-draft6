# get_keys() {
#   jq -r ".[0] | keys[] | select(. != \"VERSION\")" matrix.json | tr -d '\r'
# }
KEYS=$(jq -r ".[0] | keys[] | select(. != \"VERSION\")" matrix.json | tr -d '\r')
declare -A KEY_FILTERS
for KEY in ${KEYS[@]}; do
# for KEY in $(get_keys); do
  # echo "KEY: ${KEY}"
  KEY_FILTERS[${KEY}]=".[] | select(.VERSION == \"git-master\") | .${KEY}"
done
# for KEY in "${!KEYS[@]}"; do
for KEY in ${!KEY_FILTERS[@]}; do
  FILTER="${KEY_FILTERS[${KEY}]}"
  VALUE=$(jq -r "${FILTER}" matrix.json | tr -d '\r')
  # echo "KEY:    ${KEY}"
  # echo "FILTER: ${FILTER}"
  # echo "VALUE:  ${VALUE}"
  if [ "${VALUE}" = "null" ]; then VALUE=""; fi
  # echo "${KEY}=${VALUE}" >> ${GITHUB_OUTPUT}
  echo "${KEY}: ${VALUE}"
done
