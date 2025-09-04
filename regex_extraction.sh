

# make the headers of the csv
log_file=$1; #log.solver # <---- change this

echo "simulation_time" > tmp_simtime
echo "total_cells" > tmp_total_cells

# echo "-1" >> tmp_total_cells # offset with dummy value - manually change this to value of choice

# Using `>>` to append at end of file
grep -oP '(?<=^Time = )[+\-]?(\d+\.\d*|\d*\.\d+|\d+)([eE][+\-]?\d+)?' $log_file >> tmp_simtime

    # grep -oP '^Refined from \d+ to (\d+) cells\.' $log_file > tmp_total_cells
    ## update:
    # grep -oP '^Refined from \d+ to \K\d+(?= cells\.)|^Selected 0 cells for refinement out of \K\d+' $log_file >> tmp_total_cells
#grep -oP '^Refined from \d+ to \K\d+(?= cells\.)|^Unrefined from \d+ to \K\d+(?= cells\.)|Selected 0 cells for refinement out of \K\d+' \
#         $log_file >> tmp_total_cells

python cell_regex.py ${log_file} -o edge_case_out.log --verbose

# Fix tmp_total_cells
 python duplicate_columns.py edge_case_out.log 10
#tmp_total_cell_fixed

mv tmp_total_cells tmp_total_cells0
rm tmp_total_cells
mv tmp_total_cell_fixed tmp_total_cells


# get exec and clock times
echo "execution_time" > tmp0
echo "clock_time" > tmp1
grep -oP '(?<=ExecutionTime = )[+\-]?(\d+\.\d*|\d*\.\d+|\d+)([eE][+\-]?\d+)?' $log_file >> tmp0
grep -oP '(?<=ClockTime = )[0-9.]+' $log_file >> tmp1

# merge files together by columns
paste -d "," tmp_simtime tmp_total_cells tmp0 tmp1 > data.csv

# optional (clean up)
# rm tmp_simtime tmp_total_cells tmp0 tmp1
