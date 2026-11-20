// EXPECT: output read: line 7
module t; int fd; string l; initial begin fd = $fopen("tmp_io.txt", "w"); $fwrite(fd, "line %0d\n", 7); $fclose(fd);
fd = $fopen("tmp_io.txt", "r"); void'($fgets(l, fd)); $fclose(fd); $display("read: %s%s", l, $sformatf("t=%0t", $time)); $finish; end endmodule
