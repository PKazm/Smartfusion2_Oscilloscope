new_project \
         -name {Spectrum_Analyzer} \
         -location {C:\Users\Phoenix136\Dropbox\FPGA\Microsemi\Oscilloscope\designer\Spectrum_Analyzer\Spectrum_Analyzer_fp} \
         -mode {chain} \
         -connect_programmers {FALSE}
add_actel_device \
         -device {M2S010} \
         -name {M2S010}
enable_device \
         -name {M2S010} \
         -enable {TRUE}
save_project
close_project
