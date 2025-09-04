# import sys # for positional arugments
import argparse

import re

if __name__ == "__main__":
    print("[cell_regex.py]: (Program started)")
    parser = argparse.ArgumentParser()
    parser.add_argument("filename", help="input file name", default="log.solver")
    parser.add_argument("--debug", required=False, help="debug outputs", default=False)

    parser.add_argument("-o",
                        "--output",
                        required=False,
                        help="Output file",
                        default="edge_case_out.log")

    parser.add_argument("-v",
                        "--verbose",
                        required=False,
                        help="Verbose output",
                        action="store_true")

    args = parser.parse_args()

    fp = args.filename # "test_log_sean_rfi10.log"
    # fp = 'edge_cases.log'
    # fp = 'debug.log'

    b_debug_simtime = args.debug
    b_debug_print_info = args.verbose

    fp_out = args.output# "edge_case_out.log"
    fp_simtime = "dbg_simtime.log"

    f = open(fp, "r")
    f_out = open(fp_out, "w")

    counter_simtime_total = 0 # total times 'simtime' is found

    counter_simtime_corresponding = 0 # 'simtime' with matching cell count
    counter_cells = 0 # count for matching 'total cells' line

    if (b_debug_simtime):
        f_time = open(fp_simtime, 'w')
        f_line = open("dbg_lines.log", 'w')


    # cell_matcher = (
    #     r'^Refined from \d+ to \K\d+(?= cells\.)|^Unrefined from \d+ '
    #     r'to \K\d+(?= cells\.)|Selected 0 cells for refinement out '
    #     r'of \K\d+'
    # )
    cell_matcher = (
        r'^Refined from \d+ to (\d+) cells\.|'
        r'^Unrefined from \d+ to (\d+) cells\.|'
        r'^Selected 0 cells for refinement out of (\d+)'
    )

    sim_time_matcher = (
        r'(?<=^Time = )[+\-]?(\d+\.\d*|\d*\.\d+|\d+)([eE][+\-]?\d+)?'
    )


    b_reading = True

    flag_found_total_cell = False



    # > Read lines until first simulation time readout is given
    #   - AMR's total cell readout should occur after this.
    b_first_find = True
    count_lines = 1
    while b_first_find:
        line = f.readline()
        count_lines += 1

        match_simtime = re.search(sim_time_matcher, line)
        b_is_simtime = bool(match_simtime)

        if b_is_simtime:
            b_first_find = False

            if (b_debug_simtime):
                f_time.write(match_simtime.group(0) + "\n")

            counter_simtime_total += 1
            counter_simtime_corresponding += 1
            break
        #end if
    #end while

    # > Main matching loop
    latest_cell_count_text = None

    flag_lock_simtime = False

    last_line_read = 0
    while b_reading:
        line = f.readline()
        count_lines += 1
        if line == "":
            break
        #end if

        # - cell match regex encounters error on new line related to \K?
        if line == "\n":
            continue


        match_simtime = re.search(sim_time_matcher, line)
        b_is_simtime = bool(match_simtime)
        if b_is_simtime:
            counter_simtime_total += 1 # added on hack for verbosity

        if b_is_simtime and flag_lock_simtime:
            # >(A) Lock flag: see `>(B)`
            flag_lock_simtime = False
            f_out.write(latest_cell_count_text + "\n")

            last_line_read = count_lines
            counter_cells += 1
            counter_simtime_corresponding += 1

            if (b_debug_simtime):
                f_time.write(match_simtime.group(0) + "\n")
                # counter_simtime_total += 1
                f_line.write(str(count_lines) + "\n")

            #end if
        #end if
        match_cellcount = re.search(cell_matcher, line)
        if match_cellcount:
            # >(B) If time appears on next line, can write value.
            flag_lock_simtime = True
            # latest_cell_count_text = match_cellcount.groups()
            #- will return something like (None, None, 123134)
            latest_cell_count_text = (
                next(group for group in match_cellcount.groups() if group)
            )
            #- next(group for group in match_cellcount.groups() if group)
            #- performs:
            #- for group in match_cellcount.groups():
            #-    if group:
            #-        number = group
            #-        break
    #end while
    # > At end of read, likely will have mismatch:
    #   however, handle early termination:
    # expected_ri = (counter_simtime_total - 1) / (counter_cells)
    if False: # counter_simtime_corresponding == (counter_cells + 1):
        print("(assuming successful finish, correcting last missing cell count...)")
        f_out.write(latest_cell_count_text + "\n")
        ## Issue is with duplication line; refactor the shell script to get it working smoothly
        # Assumes last read was successful

    if (b_debug_print_info):
        print(f"lines read: {count_lines}")
        print(f"Last line read: {last_line_read}")
        print(f"Refinement lines read: {counter_cells}")
        print(f"Time lines read: {counter_simtime_total}")
        expected_ri = (counter_simtime_total-1) / (counter_cells)
        print(f"Expected refinement interval ~ {expected_ri}")
    f.close()
    f_out.close()
    if (b_debug_simtime):
        f_time.close()
    #end if
    print("[cell_regex.py]: (Program ended, exit 0)")
        