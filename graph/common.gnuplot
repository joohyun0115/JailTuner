# Based on
# https://github.com/aclements/thesis
TARGET="`echo $TARGET`"

set macros

if ("$0" eq "" || "$0"[0:1] eq "$$"[0:1]) {
  # Sized for one column of a two column, 7.5" wide body
  # SIZE="3.05in,1.8in"

  # Sized for one column 6" wide body
  SIZE="3in,2.2in"
} else {
  if ("$0" eq "2col") {
    # Sized for 6" wide body
    #SIZE="2.95in,2.2in"
    # 5.5" wide body
    SIZE="2.7in,2.2in"
  } else {
    if ("$0" eq "3col") {
      SIZE="2.25in,1.6in"
    } else {
      if ("$0" eq "2x2") {
        # Sized for a 2x2 multiplot on a 6" wide body
        #SIZE="6in,4in"
        # 5.5" wide body
        SIZE="5.5in,3.7in"
      } else {
        SIZE="$0"
      }
    }
  }
}

if (!exists("SLIDES_SIZE")) {
  SLIDES_SIZE="720,500"
}

# Note: If you change the default font size, change \gpcode
TIKZ_FONT=exists("TIKZ_FONT") ? TIKZ_FONT : "'\\figureversion{tab},10'"
if (TARGET eq "paper-tikz") {
  set term tikz size @SIZE font @TIKZ_FONT
  set output
  set pointsize 1.5
  set key spacing 1.35
} else {
  if (TARGET eq "pdf") {
    set term pdfcairo size @SIZE linewidth 2 rounded font ',10'
    set output
  } else {
    if (TARGET eq "slides") {
      set term svg size @SLIDES_SIZE font "Open Sans,20" dashed linewidth 2 enhanced
#      set output
      set output "|sed 's/<svg/& style=\"font-weight:300\"/'"
    } else {
      if (!(TARGET eq "")) {
        print sprintf("Unknown target %s!", TARGET)
      }
    }
  }
}

set ytics nomirror
set xtics nomirror
set grid back lt 0 lt rgb 'grey'
set border 3 back

xaxis_tom = 'set xrange [1:48]; \
          set xtics 6 add (1); \
          set xlabel "\\# cores"'
xaxis_ben = 'set xrange [1:120]; \
          set xtics 15 add (1); \
          set xlabel "\\# cores"'

fmtbinary(x) = x < 2**10 ? sprintf("%d", x) \
             : x < 2**20 ? sprintf("%d~KB", x/2**10) \
             : x < 2**30 ? sprintf("%d~MB", x/2**20) \
             : x < 2**40 ? sprintf("%d~GB", x/2**30) \
             : x < 2**50 ? sprintf("%d~TB", x/2**40) \
             : "too big"

set linetype 1 lw 4 lc rgb '#00dd00'
set linetype 2 lw 4 lc rgb '#0000ff'
set linetype 3 lw 4 lc rgb '#ff0000'
set linetype 4 lw 4
set linetype 5 lw 4

# Since most of our graphs are scalability graphs, put key in top left
#set key at graph 0,1 left top Left reverse
# Bottom right for per-core scalability graphs
set key at graph 0.62,0.85

#
# RadixVM stuff
#

radix='with lp lt 1'
linux='with lp lt 2'
bonsai='with lp lt 3'

vmusing="using 'iv.cores':(column(2)/column('iv.cores'))"

#
# Multiplot stuff
#

mp_startx=0.125                 # Left edge of col 0 plot area
mp_starty=0.075                 # Top of row 0 plot area
mp_width=0.825                  # Total width of plot area
mp_height=0.825                 # Total height of plot area
mp_colgap=0.1                   # Gap between columns
mp_rowgap=0.15                  # Gap between rows
# The screen coordinate of the left edge of column col
mp_left(col)=mp_startx + col*((mp_width+mp_colgap)/real(mp_ncols))
# The screen coordinate of the top edge of row row
mp_top(row)=1 - (mp_starty + row*((mp_height+mp_rowgap)/real(mp_nrows)))

# Set up a multiplot with w columns and h rows
mpSetup(w,h) = sprintf('\
    mp_nplot=-1; \
    mp_ncols=%d; \
    mp_nrows=%d; \
    set multiplot', w, h)
# Start the next graph in the multiplot
mpNext = '\
    mp_nplot=mp_nplot+1; \
    set lmargin at screen mp_left(mp_nplot%mp_ncols); \
    set rmargin at screen mp_left(mp_nplot%mp_ncols+1)-mp_colgap; \
    set tmargin at screen mp_top(mp_nplot/mp_ncols); \
    set bmargin at screen mp_top(mp_nplot/mp_ncols+1)+mp_rowgap; \
    unset label 1'
# Set Y axis row label such that it aligns regardless of tic width
mpRowLabel(lbl) = \
    sprintf('set label 1 "%s" at graph -0.25,0.5 center rotate',lbl)

mpNextSharing = '\
    eval mpNext; \
    if (mp_nplot>0) {unset key}; \
    if (mp_nplot%2==0) {@xaxis_ben} else {@xaxis_tom}; \
    if (mp_nplot==0) {set title "80-core Intel"}; \
    if (mp_nplot==1) {set title "48-core AMD"}; \
    if (mp_nplot>1) {unset title}'

#
# Slides stuff
#

if (TARGET eq "slides") {
  set style line 1 lt 1 lc rgb "#8ae234" lw 3
  set style line 2 lt 1 lc rgb "#000000" lw 3

  # Line style for axes
  set style line 120 lt 1
  set style line 120 lt rgb "#808080"

  # Line style for grid
  set style line 121 lt 3  # Dotted
  set style line 121 lt rgb "#808080" lw 0.5

  set grid back linestyle 81
  set border 3 back linestyle 120
}
