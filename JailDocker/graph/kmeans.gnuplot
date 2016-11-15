call "common.gnuplot"

set zeroaxis
set yrange [0:]
set xlabel "cores" font "arial,20"
set ylabel "Throughput(MB/sec)" font "arial,20"
set ytics format " %.0s%c" font "arial,20"
set xtics  font "arial,20"
set title font "arial,20"
set term eps
set output 'kmeans.eps'
set key at graph 1,0.55
#set linetype 1 lw 12 lc rgb '#ff0000'
set font  "arial,20"


plot \
"./data/kmeans_default.data" every :::0::0 with lp title "k-means count PS GC",\
"./data/kmeans_default_g1.data" every :::0::0 with lp title "k-means count G1 GC"

