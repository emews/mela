#!/usr/bin/env tclsh

# CREATE XYZ

set fdx [ open "x.dat" "w" ]
set fdy [ open "y.dat" "w" ]
set fdz [ open "z.dat" "w" ]

while { [ gets stdin line ] >= 0 } {
  if { [ string first "TASK:" $line ] == 0 } {
    lassign $line _ x y _ z
    puts $fdx $x
    puts $fdy $y
    puts $fdz $z
  }
}

close $fdx
close $fdy
close $fdz
