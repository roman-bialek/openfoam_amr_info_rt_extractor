# make the headers of the csv
log_file_name=$1; #log.solver # <---- change this

echo "simulation_time" > tmp_simtime
echo "total_cells" > tmp_total_cells

# Using `>>` to append at end of file
grep -oP '(?<=^Time = )[+\-]?(\d+\.\d*|\d*\.\d+|\d+)([eE][+\-]?\d+)?' $log_file_name >> tmp_simtime

# grep -oP '^Refined from \d+ to (\d+) cells\.' $log_file_name > tmp_total_cells
## update:
grep -oP '^Refined from \d+ to \K\d+(?= cells\.)|^Selected 0 cells for refinement out of \K\d+' $log_file_name >> tmp_total_cells


# get exec and clock times
echo "execution_time" > tmp0
echo "clock_time" > tmp1
grep -oP '(?<=ExecutionTime = )[+\-]?(\d+\.\d*|\d*\.\d+|\d+)([eE][+\-]?\d+)?' $log_file_name >> tmp0
grep -oP '(?<=ClockTime = )[0-9.]+' $log_file_name >> tmp1

# merge files together by columns
paste -d "," tmp_simtime tmp_total_cells tmp0 tmp1 > data.csv

# optional
# rm tmp_simtime tmp_total_cells tmp0 tmp1
