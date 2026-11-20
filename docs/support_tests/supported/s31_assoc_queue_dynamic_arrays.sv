// EXPECT: output aa.num=2 exists=1
// EXPECT: output q='{'h1, 'h3} size=2 sum=4
// EXPECT: output d='{'h0, 'h0, 'h9}
// EXPECT: output found='{'h3}
module t;
  int aa[string]; int q[$]; int d[]; int found[$];
  initial begin
    aa["x"] = 1; aa["y"] = 2;
    q.push_back(3); q.push_front(1);
    d = new[3]; d[2] = 9;
    $display("aa.num=%0d exists=%0d", aa.num(), aa.exists("x"));
    foreach (aa[k]) $display("aa[%s]=%0d", k, aa[k]);
    $display("q=%p size=%0d sum=%0d", q, q.size(), q.sum());
    $display("d=%p", d);
    found = q.find(x) with (x > 1);
    $display("found=%p", found);
    $finish;
  end
endmodule
