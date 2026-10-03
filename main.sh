#!/bin/bash

echo "Welcome to BashGrade Labs"

# Validation Functions

numeric_ok() {
    local val="$1"
    if [[ "$val" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
        return 0
    else
        echo "Value must be a number (for example 90 or 87.5)"
        return 1
    fi
}

require_file() {
    local file="$1"
    if [[ -z "$file" ]]; then
        echo "You must enter a file name"
        return 1
    fi

    if [[ ! -f "$file" ]]; then
        echo "File '$file' does not exist"
        return 1
    fi
    return 0
}

while true; do
    echo "==========================="
    echo "       BashGrade Labs      "
    echo "==========================="
    echo "1. Create course file"
    echo "2. Add assignment"
    echo "3. Add category"
    echo "4. View grade summary (Unweighted)"
    echo "5. AWK summary report"
    echo "6. Python statistics"
    echo "7. Perl HTML export"
    echo "8. Sync to SQLite"
    echo "9. Exit"
    echo

    read -p "Choose: " choice

    case "$choice" in
        1)
	    clear
            read -p "Course file name: " file

            if [[ -z "$file" ]]; then
                echo "File name cannot be empty"
                continue
            fi

            if [[ -e "$file" ]]; then
                echo "File '$file' already exists"
                continue
            fi

            touch "$file" || { echo "Could not create file"; continue; }
            chmod 600 "$file"

            echo "COURSE_FILE=$file" >> "$file"
            echo "Course file created"
            ;;

        2)
	    clear
            read -p "Course file: " file
            require_file "$file" || continue

            echo "Existing categories:"
            grep '^CATEGORY:' "$file" | cut -d: -f2
            echo

            read -p "Category: " cat

            if [[ -z "$cat" ]]; then
                echo "Category cannot be empty"
                continue
            fi

            if ! grep -q "^CATEGORY:$cat:" "$file"; then
                echo "Category '$cat' does not exist"
                continue
            fi

            read -p "Assignment: " name

            if [[ -z "$name" ]]; then
                echo "Please enter an assignment name"
                continue
            fi

	    echo "Enter the score as a percentage (Ex: 93)."
            read -p "Score: " score
            numeric_ok "$score" || continue

            echo "$cat:$name:$score" >> "$file"
            echo "Assignment added"
            ;;

        3)
	    clear
            read -p "Course file: " file
            require_file "$file" || continue

            read -p "Category name: " cat

            if [[ -z "$cat" ]]; then
                echo "Category name cannot be empty"
                continue
            fi

            if grep -q "^CATEGORY:$cat:" "$file"; then
                echo "Category '$cat' already exists"
                continue
            fi

	    echo "Note: If your course doesn't use weighted grading categories, enter 0"
            read -p "Weight (0.0 to 1.0): " weight

            numeric_ok "$weight" || continue


            awk -v w="$weight" 'BEGIN { exit !(w >= 0 && w <= 1) }'
            if [[ $? -ne 0 ]]; then
                echo "Weight must be between 0 and 1"
                continue
            fi

            echo "CATEGORY:$cat:$weight" >> "$file"
            echo "Category added"
            ;;

        4)
	    clear
            read -p "Course file: " file
            require_file "$file" || continue

            awk -F: '
                NF == 3 && $3 ~ /^[0-9]+(\.[0-9]+)?$/ {
                    sum[$1] += $3
                    count[$1]++
                }
                END {
                    if (length(sum) == 0) {
                        print "No assignment scores found"
                        exit
                    }
                    for (c in sum)
                        printf "%s avg = %.2f\n", c, sum[c] / count[c]
                }
            ' "$file"
            ;;

        5)
	    clear
            read -p "Course file: " file
            require_file "$file" || continue
            awk -f report.awk "$file"
            ;;

        6)
	    clear
            read -p "Course file: " file
            require_file "$file" || continue
            python3 ./stats.py "$file"
            ;;

        7)
	    clear
            read -p "Course file: " file
            require_file "$file" || continue

	    base=$(basename "$file")
	    out="${base%.*}.html"

            ./export.pl "$file" > "$out"
	    echo "HTML report has been created as $out"
            ;;

        8)
	    clear
            read -p "Course file: " file
            require_file "$file" || continue

            sqlite3 grades.db \
                "create TABLE IF NOT EXISTS grades (cat TEXT, name TEXT, score REAL);"

            awk -F: '
                NF == 3 && $3 ~ /^[0-9]+(\.[0-9]+)?$/ {
                    printf "INSERT INTO grades VALUES(\"%s\",\"%s\",%s);\n", $1, $2, $3
                }
            ' "$file" | sqlite3 grades.db

            echo "Synced scores into grades.db"
	    echo "You can view the table with the following command: sqlite3 grades.db 'SELECT * FROM grades;'"
            ;;

        9)
	    clear
            echo "Thank you for using BashGrade Labs!"
            exit 0
            ;;

        *)
	    clear
            echo "Invalid choice. Please enter a valid number."
            ;;
    esac

    echo
done
