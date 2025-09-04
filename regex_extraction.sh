
fp_src=$(dirname "$0") # cheap relative-pathing fix


log_file=$1; #log.solver # <---- change this
refinement_interval=$2 # 10

callas_example=">  bash ${0} logfile refinement_interval_value"
if [ -z ${log_file} ]; then
    echo "${0} Error:"
    echo ">  log file not provided in 1st position"
    echo ">  Please see example below:"
    echo ">  (call as:)"
    echo ${callas_example}
    exit 1
fi

if [ -z ${refinement_interval} ]; then
    echo "${0} Error:"
    echo ">  Refinement interval not provided in 2nd position"
    echo ">  Please provide a value, e.g., 1, 2, ..., 10"
    echo "> (call as:)"
    echo ${callas_example}
    exit 1
fi

echo "simulation_time" > tmp_simtime
echo "total_cells" > tmp_total_cells


# (Using `>>` to append at end of file)
echo "(Grep 1: sim time)"
grep -oP '(?<=^Time = )[+\-]?(\d+\.\d*|\d*\.\d+|\d+)([eE][+\-]?\d+)?' $log_file >> tmp_simtime


echo ""
echo "(python 1: warning is slower than grep's)"

python ${fp_src}/cell_regex.py ${log_file} \
        -o edge_case_out.log \
        --verbose

echo ""


# Fix tmp_total_cells
echo "(python 2: duplicate columns)"
python ${fp_src}/duplicate_columns.py edge_case_out.log ${refinement_interval} # returns file `tmp_total_cell_fixed`

echo "total_cell" > tmp_add_header
cat tmp_add_header tmp_total_cell_fixed > tmp_total_cells


# get exec and clock times
echo "execution_time" > tmp0
echo "clock_time" > tmp1
echo "(grep 2: exec times)"
grep -oP '(?<=ExecutionTime = )[+\-]?(\d+\.\d*|\d*\.\d+|\d+)([eE][+\-]?\d+)?' $log_file >> tmp0
echo "(grep 3: clock times)"
grep -oP '(?<=ClockTime = )[0-9.]+' $log_file >> tmp1


# merge files together by columns
paste -d "," tmp_simtime tmp_total_cells tmp0 tmp1 > data.csv


# optional (clean up; un/comment)
rm tmp_simtime \
    tmp_total_cells \
    tmp0 \
    tmp1 \
    tmp_add_header \
    tmp_total_cell_fixed \
    edge_case_out.log

echo ""
echo "(Exit 0, End of Script)"