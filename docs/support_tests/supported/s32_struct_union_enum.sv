// EXPECT: output enum RUN next=DONE num=3
module t; typedef enum logic [1:0] {IDLE, RUN, DONE} st_e; typedef struct packed { logic [3:0] a; logic [3:0] b; } ps_t;
typedef union packed { logic [7:0] w; ps_t s; } pu_t; typedef struct { int x; string n; } us_t;
st_e s; ps_t p; pu_t u; us_t v; initial begin s = RUN; p = '{a:4'h1, b:4'h2}; u.w = 8'hA5; v = '{x:3, n:"hi"};
$display("enum %s next=%s num=%0d p=%h u.s.a=%h v=%p", s.name(), s.next().name(), s.num(), p, u.s.a, v); $finish; end endmodule
