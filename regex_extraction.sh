

# make the headers of the csv
log_file=$1; #log.solver # <---- change this
refinement_interval=$2 # 10


echo "simulation_time" > tmp_simtime
echo "total_cells" > tmp_total_cells

# echo "-1" >> tmp_total_cells # offset with dummy value - manually change this to value of choice

# (Using `>>` to append at end of file)
echo "(Grep 1: sim time)"
grep -oP '(?<=^Time = )[+\-]?(\d+\.\d*|\d*\.\d+|\d+)([eE][+\-]?\d+)?' $log_file >> tmp_simtime

    # grep -oP '^Refined from \d+ to (\d+) cells\.' $log_file > tmp_total_cells
    ## update:
    # grep -oP '^Refined from \d+ to \K\d+(?= cells\.)|^Selected 0 cells for refinement out of \K\d+' $log_file >> tmp_total_cells
#grep -oP '^Refined from \d+ to \K\d+(?= cells\.)|^Unrefined from \d+ to \K\d+(?= cells\.)|Selected 0 cells for refinement out of \K\d+' \
#         $log_file >> tmp_total_cells


echo ""
echo "(python 1: warning is slower than grep's)"

python cell_regex.py ${log_file} \
        -o edge_case_out.log \
        --verbose

echo ""


# Fix tmp_total_cells
echo "(python 2: duplicate columns)"
python duplicate_columns.py edge_case_out.log ${refinement_interval} # returns file `tmp_total_cell_fixed`

echo "total_cell" > tmp_add_header
cat tmp_add_header tmp_total_cell_fixed > tmp_total_cells

# mv tmp_total_cells tmp_total_cells0
# rm tmp_total_cells
# mv tmp_total_cell_fixed_w_header tmp_total_cells


# get exec and clock times
echo "execution_time" > tmp0
echo "clock_time" > tmp1
echo "(grep 2: exec times)"
grep -oP '(?<=ExecutionTime = )[+\-]?(\d+\.\d*|\d*\.\d+|\d+)([eE][+\-]?\d+)?' $log_file >> tmp0
echo "(grep 3: clock times)"
grep -oP '(?<=ClockTime = )[0-9.]+' $log_file >> tmp1

# merge files together by columns
paste -d "," tmp_simtime tmp_total_cells tmp0 tmp1 > data.csv

# optional (clean up)
# rm tmp_simtime tmp_total_cells tmp0 tmp1

echo ""
echo "(Exit 0, End of Script)"