#!/usr/bin/perl -w

$file = shift;

if (!$file) {
    die "Usage: export.pl COURSE_FILE\n";
}

open $fh, "<", $file or die "Cannot open $file: $!";

print "<html><body><h1>BashGrade Report</h1>\n";
print "<table border='1'>\n";
print "<tr><th>Category</th><th>Assignment</th><th>Score</th></tr>\n";

while (<$fh>) {
    chomp;
    next if /^CATEGORY:/;

    ($cat, $assn, $score) = split /:/;

    print "<tr><td>$cat</td><td>$assn</td><td>$score</td></tr>\n";
}

print "</table></body></html>\n";
