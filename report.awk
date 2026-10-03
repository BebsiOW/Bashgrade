BEGIN {
    FS=":"
    print "=== AWK Grade Report ==="
    print "Category        Assignment        Score"
    print "---------------------------------------"
}

/^CATEGORY:/ {
    next
}

NF == 3 {
    printf "%-15s %-15s %6.2f\n", $1, $2, $3
    sum[$1] += $3
    count[$1]++
}

END {
    print ""
    print "Category Averages"
    print "-----------------"
    for (c in sum)
        printf "%-15s %.2f\n", c, sum[c] / count[c]
}
