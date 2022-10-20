DEL1=${1}
DEL2=${2}
# Create deleted channels range t thing

# For each row of del_ranges, with del1 and del2

DEL1ID=`awk ' {print $1*1000}' waves.txt | awk -v del1="$DEL1" -v del2="$DEL2" '$1 > del1 && $1 < del2 { print NR}' | sort -n | head -1`
DEL2ID=`awk ' {print $1*1000}' waves.txt | awk -v del1="$DEL1" -v del2="$DEL2" '$1 > del1 && $1 < del2 { print NR}' | sort -n | tail -1`

echo ${DEL1ID}t${DEL2ID}
