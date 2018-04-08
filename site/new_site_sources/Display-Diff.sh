#!/bin/bash
diff -u -r site-good site |
    grep -v '^ ' |
    grep -v "Last Modified" |
    grep -vP '^(---|\+\+\+|diff|@@)' |
    grep -vP '(pubDate|lastBuildDate)' |
    grep -vF "שונה לאחרונה בתאריך"
