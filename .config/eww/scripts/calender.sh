#!/bin/bash
# Returns JSON for the given month (YYYY-MM), default to current month
MONTH=${1:-$(date +%Y-%m)}
YEAR=${MONTH%-*}
MON=${MONTH#*-}

# Get first day of month (1 = Monday, 7 = Sunday) and total days
FIRST_DAY=$(date -d "$YEAR-$MON-01" +%u) # 1..7
TOTAL_DAYS=$(cal $MON $YEAR | awk 'NF {DAYS = $NF}; END {print DAYS}')

# Build weeks array
WEEKS=()
CURRENT_WEEK=()
# Add empty cells for days before month start
for ((i = 1; i < FIRST_DAY; i++)); do
	CURRENT_WEEK+=("")
done

for ((d = 1; d <= TOTAL_DAYS; d++)); do
	CURRENT_WEEK+=($d)
	if ((${#CURRENT_WEEK[@]} == 7)); then
		WEEKS+=("$(printf '%s\n' "${CURRENT_WEEK[@]}" | jq -R . | jq -s .)")
		CURRENT_WEEK=()
	fi
done

# Add remaining empty cells
if ((${#CURRENT_WEEK[@]} > 0)); then
	while ((${#CURRENT_WEEK[@]} < 7)); do
		CURRENT_WEEK+=("")
	done
	WEEKS+=("$(printf '%s\n' "${CURRENT_WEEK[@]}" | jq -R . | jq -s .)")
fi

# Build JSON
WEEKS_JSON=$(printf '%s\n' "${WEEKS[@]}" | jq -s .)
MONTH_NAME=$(date -d "$YEAR-$MON-01" +%B)
echo "{\"month\": \"$MONTH_NAME\", \"year\": $YEAR, \"weeks\": $WEEKS_JSON}"
