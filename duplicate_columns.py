import sys # for positional arugments

if __name__ == "__main__":
    filename = sys.argv[1]
    refine_interval = int(sys.argv[2])

    if sys.argv[1] is None:
        filename = "tmp_total_cells"
    if sys.argv[2] is None:
        refine_interval = 10

    print(f"Filename = {filename}")
    print(f"Refinement interval given = {refine_interval}")
    # refine_interval = 2
    # filename = "tmp_total_cells"
    output_filename = "tmp_total_cell_fixed"

    f = open(filename, 'r')
    b_reading_file = True

    new_file = open(output_filename, "w")

    while b_reading_file:
        current_line = f.readline()
        if (current_line == ""):
            # end of file
            b_reading_file = False
            break
        
        for i in range(refine_interval):
            new_file.write(current_line)


    new_file.close()
    f.close()
    print("(Total cell files fixed and closed)")