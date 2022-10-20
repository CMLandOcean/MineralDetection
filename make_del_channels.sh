DEL_RANGES=${1:-0-400, 1300-1500, 1800-2000}
# Create deleted channels file

# example input
# del_ranges = 0-400, 1300-1500, 1800-2000

echo DEL_RANGES | sed 's/,/\n/g' | sed 's/[^0-9]/ /g' | awk '{print $1, $2}' > del_ranges.txt

# For each row of del_ranges, with del1 and del2
xargs < del_ranges.txt -n 2 sh make_del_range.sh | tr '\n' ' '| sed '$s/ $/ # gao_2022a \n/' > delete_gao2022p.txt
