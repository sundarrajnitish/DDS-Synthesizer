
library IEEE;

use IEEE.std_logic_1164.all;

package CONV_PACK_dds_synthesizer_ftw_width32 is

-- define attributes
attribute ENUM_ENCODING : STRING;

end CONV_PACK_dds_synthesizer_ftw_width32;

library IEEE;

use IEEE.std_logic_1164.all;

use work.CONV_PACK_dds_synthesizer_ftw_width32.all;

entity dds_synthesizer_ftw_width32_DW01_add_1 is

   port( A, B : in std_logic_vector (31 downto 0);  CI : in std_logic;  SUM : 
         out std_logic_vector (31 downto 0);  CO : out std_logic);

end dds_synthesizer_ftw_width32_DW01_add_1;

architecture SYN_rpl of dds_synthesizer_ftw_width32_DW01_add_1 is

   component IVI
      port( A : in std_logic;  Z : out std_logic);
   end component;
   
   component EO1
      port( A, B, C, D : in std_logic;  Z : out std_logic);
   end component;
   
   component AO5
      port( A, B, C : in std_logic;  Z : out std_logic);
   end component;
   
   component AO2
      port( A, B, C, D : in std_logic;  Z : out std_logic);
   end component;
   
   component AO4
      port( A, B, C, D : in std_logic;  Z : out std_logic);
   end component;
   
   component OR2
      port( A, B : in std_logic;  Z : out std_logic);
   end component;
   
   component EOI
      port( A, B : in std_logic;  Z : out std_logic);
   end component;
   
   component ND2I
      port( A, B : in std_logic;  Z : out std_logic);
   end component;
   
   component AN2I
      port( A, B : in std_logic;  Z : out std_logic);
   end component;
   
   component NR2I
      port( A, B : in std_logic;  Z : out std_logic);
   end component;
   
   component ENI
      port( A, B : in std_logic;  Z : out std_logic);
   end component;
   
   signal n153, n154, n155, n156, n157, n158, n159, n160, n161, n162, n163, 
      n164, n165, n166, n167, n168, n169, n170, n171, n172, n173, n174, n175, 
      n176, n177, n178, n179, n180, n181, n182, n183, n184, n185, n186, n187, 
      n188, n189, n190, n191, n192, n193, n194, n195, n196, n197, n198, n199, 
      n200, n201, n202, n203, n204, n205, n206, n207, n208, n209, n210, n211, 
      n212, n213, n214, n215, n216, n217, n218, n219, n220, n221, n222, n223, 
      n224, n225, n226, n227, n228, n229, n230, n231, n232, n233, n234, n235, 
      n236, n237, n238, n239, n240, n241, n242, n243, n244, n245, n246, n247, 
      n248, n249, n250, n251, n252, n253, n254, n255, n256, n257, n258, n259, 
      n260, n261, n262, n263, n264, n265, n266, n267, n268, n269, n270, n122, 
      n123, n124, n125, n126, n127, n128, n129, n130, n131, n132, n133, n134, 
      n135, n136, n137, n138, n139, n140, n141, n142, n143, n144, n145, n146, 
      n147, n148, n149, n150, n151, n152 : std_logic;

begin
   
   U1 : EOI port map( A => n153, B => n154, Z => SUM(9));
   U2 : EOI port map( A => n130, B => B(9), Z => n153);
   U3 : EOI port map( A => n155, B => n156, Z => SUM(8));
   U4 : ENI port map( A => A(8), B => B(8), Z => n156);
   U5 : EOI port map( A => n157, B => n158, Z => SUM(7));
   U6 : ENI port map( A => A(7), B => B(7), Z => n158);
   U9 : NR2I port map( A => n128, B => n160, Z => n161);
   U10 : EOI port map( A => n162, B => n163, Z => SUM(6));
   U11 : EOI port map( A => n129, B => B(6), Z => n163);
   U12 : EOI port map( A => n160, B => n164, Z => SUM(5));
   U13 : EOI port map( A => n128, B => B(5), Z => n164);
   U16 : NR2I port map( A => n126, B => n166, Z => n167);
   U17 : EOI port map( A => n168, B => n169, Z => SUM(4));
   U18 : EOI port map( A => n127, B => B(4), Z => n169);
   U19 : EOI port map( A => n166, B => n170, Z => SUM(3));
   U20 : EOI port map( A => n126, B => B(3), Z => n170);
   U23 : EOI port map( A => n174, B => n175, Z => SUM(31));
   U24 : ENI port map( A => B(31), B => A(31), Z => n175);
   U27 : NR2I port map( A => n150, B => n177, Z => n178);
   U28 : EOI port map( A => n179, B => n180, Z => SUM(30));
   U29 : ENI port map( A => A(30), B => B(30), Z => n180);
   U32 : AN2I port map( A => n149, B => n182, Z => n183);
   U33 : ENI port map( A => n184, B => n185, Z => SUM(2));
   U34 : ENI port map( A => A(2), B => B(2), Z => n185);
   U35 : EOI port map( A => n177, B => n186, Z => SUM(29));
   U36 : EOI port map( A => n150, B => B(29), Z => n186);
   U39 : NR2I port map( A => n148, B => n188, Z => n189);
   U40 : EOI port map( A => n182, B => n190, Z => SUM(28));
   U41 : EOI port map( A => n149, B => B(28), Z => n190);
   U44 : NR2I port map( A => n147, B => n192, Z => n193);
   U45 : EOI port map( A => n188, B => n194, Z => SUM(27));
   U46 : EOI port map( A => n148, B => B(27), Z => n194);
   U49 : NR2I port map( A => n146, B => n196, Z => n197);
   U50 : EOI port map( A => n192, B => n198, Z => SUM(26));
   U51 : EOI port map( A => n147, B => B(26), Z => n198);
   U54 : NR2I port map( A => n145, B => n200, Z => n201);
   U55 : EOI port map( A => n196, B => n202, Z => SUM(25));
   U56 : EOI port map( A => n146, B => B(25), Z => n202);
   U59 : NR2I port map( A => n144, B => n204, Z => n205);
   U60 : EOI port map( A => n200, B => n206, Z => SUM(24));
   U61 : EOI port map( A => n145, B => B(24), Z => n206);
   U64 : NR2I port map( A => n143, B => n208, Z => n209);
   U65 : EOI port map( A => n204, B => n210, Z => SUM(23));
   U66 : EOI port map( A => n144, B => B(23), Z => n210);
   U69 : NR2I port map( A => n142, B => n212, Z => n213);
   U70 : EOI port map( A => n208, B => n214, Z => SUM(22));
   U71 : EOI port map( A => n143, B => B(22), Z => n214);
   U74 : NR2I port map( A => n141, B => n216, Z => n217);
   U75 : EOI port map( A => n212, B => n218, Z => SUM(21));
   U76 : EOI port map( A => n142, B => B(21), Z => n218);
   U79 : NR2I port map( A => n140, B => n220, Z => n221);
   U80 : EOI port map( A => n216, B => n222, Z => SUM(20));
   U81 : EOI port map( A => n141, B => B(20), Z => n222);
   U84 : NR2I port map( A => n139, B => n224, Z => n225);
   U85 : ENI port map( A => n173, B => n226, Z => SUM(1));
   U86 : EOI port map( A => B(1), B => A(1), Z => n226);
   U87 : EOI port map( A => n220, B => n227, Z => SUM(19));
   U88 : EOI port map( A => n140, B => B(19), Z => n227);
   U91 : NR2I port map( A => n138, B => n229, Z => n230);
   U92 : EOI port map( A => n224, B => n231, Z => SUM(18));
   U93 : EOI port map( A => n139, B => B(18), Z => n231);
   U96 : NR2I port map( A => n137, B => n233, Z => n234);
   U97 : EOI port map( A => n229, B => n235, Z => SUM(17));
   U98 : EOI port map( A => n138, B => B(17), Z => n235);
   U101 : NR2I port map( A => n136, B => n237, Z => n238);
   U102 : EOI port map( A => n233, B => n239, Z => SUM(16));
   U103 : EOI port map( A => n137, B => B(16), Z => n239);
   U106 : NR2I port map( A => n135, B => n241, Z => n242);
   U107 : EOI port map( A => n237, B => n243, Z => SUM(15));
   U108 : EOI port map( A => n136, B => B(15), Z => n243);
   U111 : NR2I port map( A => n134, B => n245, Z => n246);
   U112 : EOI port map( A => n241, B => n247, Z => SUM(14));
   U113 : EOI port map( A => n135, B => B(14), Z => n247);
   U116 : NR2I port map( A => n133, B => n249, Z => n250);
   U117 : EOI port map( A => n245, B => n251, Z => SUM(13));
   U118 : EOI port map( A => n134, B => B(13), Z => n251);
   U121 : NR2I port map( A => n132, B => n253, Z => n254);
   U122 : EOI port map( A => n249, B => n255, Z => SUM(12));
   U123 : EOI port map( A => n133, B => B(12), Z => n255);
   U126 : NR2I port map( A => n131, B => n257, Z => n258);
   U127 : EOI port map( A => n253, B => n259, Z => SUM(11));
   U128 : EOI port map( A => n132, B => B(11), Z => n259);
   U131 : ND2I port map( A => A(9), B => n122, Z => n261);
   U132 : EOI port map( A => n257, B => n262, Z => SUM(10));
   U133 : EOI port map( A => n131, B => B(10), Z => n262);
   U135 : NR2I port map( A => n154, B => n130, Z => n263);
   U139 : NR2I port map( A => n129, B => n162, Z => n266);
   U142 : NR2I port map( A => n127, B => n168, Z => n268);
   U145 : AN2I port map( A => A(2), B => n184, Z => n270);
   U147 : ND2I port map( A => B(0), B => A(0), Z => n173);
   U148 : EOI port map( A => B(0), B => A(0), Z => SUM(0));
   U180 : ND2I port map( A => n125, B => n173, Z => n172);
   U181 : ND2I port map( A => n123, B => A(8), Z => n264);
   U7 : AO5 port map( A => n125, B => n173, C => n152, Z => n184);
   U8 : AO2 port map( A => n123, B => A(8), C => n264, D => B(8), Z => n154);
   U14 : AO4 port map( A => A(9), B => n122, C => B(9), D => n263, Z => n257);
   U15 : AO5 port map( A => A(3), B => n124, C => B(3), Z => n168);
   U21 : AO4 port map( A => n270, B => B(2), C => n184, D => A(2), Z => n269);
   U22 : AO5 port map( A => A(5), B => n267, C => B(5), Z => n162);
   U25 : EO1 port map( A => n168, B => n127, C => n268, D => B(4), Z => n267);
   U26 : AO5 port map( A => A(10), B => n260, C => B(10), Z => n253);
   U30 : AO2 port map( A => n261, B => n151, C => n154, D => n130, Z => n260);
   U31 : AO5 port map( A => A(12), B => n252, C => B(12), Z => n245);
   U37 : EO1 port map( A => n253, B => n132, C => n254, D => B(11), Z => n252);
   U38 : AO5 port map( A => A(11), B => n256, C => B(11), Z => n249);
   U42 : EO1 port map( A => n257, B => n131, C => n258, D => B(10), Z => n256);
   U43 : AO5 port map( A => A(14), B => n244, C => B(14), Z => n237);
   U47 : EO1 port map( A => n245, B => n134, C => n246, D => B(13), Z => n244);
   U48 : AO5 port map( A => A(13), B => n248, C => B(13), Z => n241);
   U52 : EO1 port map( A => n249, B => n133, C => n250, D => B(12), Z => n248);
   U53 : AO5 port map( A => A(16), B => n236, C => B(16), Z => n229);
   U57 : EO1 port map( A => n237, B => n136, C => n238, D => B(15), Z => n236);
   U58 : AO5 port map( A => A(15), B => n240, C => B(15), Z => n233);
   U62 : EO1 port map( A => n241, B => n135, C => n242, D => B(14), Z => n240);
   U63 : AO5 port map( A => A(18), B => n228, C => B(18), Z => n220);
   U67 : EO1 port map( A => n229, B => n138, C => n230, D => B(17), Z => n228);
   U68 : AO5 port map( A => A(17), B => n232, C => B(17), Z => n224);
   U72 : EO1 port map( A => n233, B => n137, C => n234, D => B(16), Z => n232);
   U73 : AO5 port map( A => A(20), B => n219, C => B(20), Z => n212);
   U77 : EO1 port map( A => n220, B => n140, C => n221, D => B(19), Z => n219);
   U78 : AO5 port map( A => A(19), B => n223, C => B(19), Z => n216);
   U82 : EO1 port map( A => n224, B => n139, C => n225, D => B(18), Z => n223);
   U83 : AO5 port map( A => A(22), B => n211, C => B(22), Z => n204);
   U89 : EO1 port map( A => n212, B => n142, C => n213, D => B(21), Z => n211);
   U90 : AO5 port map( A => A(21), B => n215, C => B(21), Z => n208);
   U94 : EO1 port map( A => n216, B => n141, C => n217, D => B(20), Z => n215);
   U95 : AO5 port map( A => A(24), B => n203, C => B(24), Z => n196);
   U99 : EO1 port map( A => n204, B => n144, C => n205, D => B(23), Z => n203);
   U100 : AO5 port map( A => A(23), B => n207, C => B(23), Z => n200);
   U104 : EO1 port map( A => n208, B => n143, C => n209, D => B(22), Z => n207)
                           ;
   U105 : AO5 port map( A => A(26), B => n195, C => B(26), Z => n188);
   U109 : EO1 port map( A => n196, B => n146, C => n197, D => B(25), Z => n195)
                           ;
   U110 : AO5 port map( A => A(25), B => n199, C => B(25), Z => n192);
   U114 : EO1 port map( A => n200, B => n145, C => n201, D => B(24), Z => n199)
                           ;
   U115 : AO5 port map( A => A(2), B => n171, C => B(2), Z => n166);
   U119 : AO2 port map( A => n172, B => n152, C => n173, D => n125, Z => n171);
   U120 : AO5 port map( A => A(28), B => n187, C => B(28), Z => n177);
   U124 : EO1 port map( A => n188, B => n148, C => n189, D => B(27), Z => n187)
                           ;
   U125 : AO5 port map( A => A(27), B => n191, C => B(27), Z => n182);
   U129 : EO1 port map( A => n192, B => n147, C => n193, D => B(26), Z => n191)
                           ;
   U130 : AO5 port map( A => A(4), B => n165, C => B(4), Z => n160);
   U134 : EO1 port map( A => n166, B => n126, C => n167, D => B(3), Z => n165);
   U136 : AO5 port map( A => A(7), B => n265, C => B(7), Z => n155);
   U137 : EO1 port map( A => n162, B => n129, C => n266, D => B(6), Z => n265);
   U138 : AO5 port map( A => A(30), B => n176, C => B(30), Z => n174);
   U140 : EO1 port map( A => n177, B => n150, C => n178, D => B(29), Z => n176)
                           ;
   U141 : AO5 port map( A => A(29), B => n181, C => B(29), Z => n179);
   U143 : EO1 port map( A => n182, B => n149, C => n183, D => B(28), Z => n181)
                           ;
   U144 : AO5 port map( A => A(6), B => n159, C => B(6), Z => n157);
   U146 : EO1 port map( A => n160, B => n128, C => n161, D => B(5), Z => n159);
   U149 : IVI port map( A => n154, Z => n122);
   U150 : IVI port map( A => n155, Z => n123);
   U151 : IVI port map( A => n269, Z => n124);
   U152 : IVI port map( A => A(1), Z => n125);
   U153 : IVI port map( A => A(3), Z => n126);
   U154 : IVI port map( A => A(4), Z => n127);
   U155 : IVI port map( A => A(5), Z => n128);
   U156 : IVI port map( A => A(6), Z => n129);
   U157 : IVI port map( A => A(9), Z => n130);
   U158 : IVI port map( A => A(10), Z => n131);
   U159 : IVI port map( A => A(11), Z => n132);
   U160 : IVI port map( A => A(12), Z => n133);
   U161 : IVI port map( A => A(13), Z => n134);
   U162 : IVI port map( A => A(14), Z => n135);
   U163 : IVI port map( A => A(15), Z => n136);
   U164 : IVI port map( A => A(16), Z => n137);
   U165 : IVI port map( A => A(17), Z => n138);
   U166 : IVI port map( A => A(18), Z => n139);
   U167 : IVI port map( A => A(19), Z => n140);
   U168 : IVI port map( A => A(20), Z => n141);
   U169 : IVI port map( A => A(21), Z => n142);
   U170 : IVI port map( A => A(22), Z => n143);
   U171 : IVI port map( A => A(23), Z => n144);
   U172 : IVI port map( A => A(24), Z => n145);
   U173 : IVI port map( A => A(25), Z => n146);
   U174 : IVI port map( A => A(26), Z => n147);
   U175 : IVI port map( A => A(27), Z => n148);
   U176 : IVI port map( A => A(28), Z => n149);
   U177 : IVI port map( A => A(29), Z => n150);
   U178 : IVI port map( A => B(9), Z => n151);
   U179 : IVI port map( A => B(1), Z => n152);

end SYN_rpl;

library IEEE;

use IEEE.std_logic_1164.all;

use work.CONV_PACK_dds_synthesizer_ftw_width32.all;

entity dds_synthesizer_ftw_width32_DW01_add_0 is

   port( A, B : in std_logic_vector (9 downto 0);  CI : in std_logic;  SUM : 
         out std_logic_vector (9 downto 0);  CO : out std_logic);

end dds_synthesizer_ftw_width32_DW01_add_0;

architecture SYN_rpl of dds_synthesizer_ftw_width32_DW01_add_0 is

   component IVI
      port( A : in std_logic;  Z : out std_logic);
   end component;
   
   component EO1
      port( A, B, C, D : in std_logic;  Z : out std_logic);
   end component;
   
   component AO5
      port( A, B, C : in std_logic;  Z : out std_logic);
   end component;
   
   component AO4
      port( A, B, C, D : in std_logic;  Z : out std_logic);
   end component;
   
   component AO2
      port( A, B, C, D : in std_logic;  Z : out std_logic);
   end component;
   
   component OR2
      port( A, B : in std_logic;  Z : out std_logic);
   end component;
   
   component ENI
      port( A, B : in std_logic;  Z : out std_logic);
   end component;
   
   component NR2I
      port( A, B : in std_logic;  Z : out std_logic);
   end component;
   
   component EOI
      port( A, B : in std_logic;  Z : out std_logic);
   end component;
   
   component AN2I
      port( A, B : in std_logic;  Z : out std_logic);
   end component;
   
   signal n43, n44, n45, n46, n47, n48, n49, n50, n51, n52, n53, n54, n55, n56,
      n57, n58, n59, n60, n61, n62, n63, n64, n65, n66, n67, n68, n69, n70, n71
      , n72, n73, n74, n34, n35, n36, n37, n38, n39, n40, n41, n42 : std_logic;

begin
   
   U1 : EOI port map( A => n43, B => n44, Z => SUM(9));
   U2 : ENI port map( A => B(9), B => A(9), Z => n44);
   U5 : NR2I port map( A => n40, B => n46, Z => n47);
   U6 : EOI port map( A => n48, B => n49, Z => SUM(8));
   U7 : ENI port map( A => A(8), B => B(8), Z => n49);
   U10 : NR2I port map( A => n39, B => n51, Z => n52);
   U11 : EOI port map( A => n46, B => n53, Z => SUM(7));
   U12 : ENI port map( A => A(7), B => B(7), Z => n53);
   U15 : NR2I port map( A => n38, B => n55, Z => n56);
   U16 : EOI port map( A => n51, B => n57, Z => SUM(6));
   U17 : ENI port map( A => A(6), B => B(6), Z => n57);
   U20 : NR2I port map( A => n37, B => n59, Z => n60);
   U21 : EOI port map( A => n55, B => n61, Z => SUM(5));
   U22 : ENI port map( A => A(5), B => B(5), Z => n61);
   U25 : AN2I port map( A => A(3), B => n64, Z => n63);
   U26 : EOI port map( A => n59, B => n65, Z => SUM(4));
   U27 : ENI port map( A => A(4), B => B(4), Z => n65);
   U30 : ENI port map( A => n64, B => n69, Z => SUM(3));
   U31 : ENI port map( A => A(3), B => B(3), Z => n69);
   U34 : NR2I port map( A => A(1), B => n72, Z => n71);
   U35 : EOI port map( A => n68, B => n73, Z => SUM(2));
   U36 : ENI port map( A => A(2), B => B(2), Z => n73);
   U38 : EOI port map( A => n72, B => n74, Z => SUM(1));
   U39 : EOI port map( A => B(1), B => A(1), Z => n74);
   U40 : NR2I port map( A => n35, B => n42, Z => n72);
   U41 : ENI port map( A => n42, B => A(0), Z => SUM(0));
   U51 : OR2 port map( A => n36, B => n68, Z => n67);
   U3 : AO5 port map( A => n36, B => n70, C => n41, Z => n64);
   U4 : AO4 port map( A => n71, B => B(1), C => n72, D => A(1), Z => n70);
   U8 : AO5 port map( A => A(1), B => n72, C => B(1), Z => n68);
   U9 : AO5 port map( A => A(3), B => n66, C => B(3), Z => n59);
   U13 : AO2 port map( A => n67, B => n41, C => n68, D => n36, Z => n66);
   U14 : AO5 port map( A => A(4), B => n34, C => B(4), Z => n55);
   U18 : AO4 port map( A => n63, B => B(3), C => n64, D => A(3), Z => n62);
   U19 : AO5 port map( A => A(5), B => n58, C => B(5), Z => n51);
   U23 : EO1 port map( A => n59, B => n37, C => n60, D => B(4), Z => n58);
   U24 : AO5 port map( A => A(6), B => n54, C => B(6), Z => n46);
   U28 : EO1 port map( A => n55, B => n38, C => n56, D => B(5), Z => n54);
   U29 : AO5 port map( A => A(7), B => n50, C => B(7), Z => n48);
   U32 : EO1 port map( A => n51, B => n39, C => n52, D => B(6), Z => n50);
   U33 : AO5 port map( A => A(8), B => n45, C => B(8), Z => n43);
   U37 : EO1 port map( A => n46, B => n40, C => n47, D => B(7), Z => n45);
   U42 : IVI port map( A => n62, Z => n34);
   U43 : IVI port map( A => A(0), Z => n35);
   U44 : IVI port map( A => A(2), Z => n36);
   U45 : IVI port map( A => A(4), Z => n37);
   U46 : IVI port map( A => A(5), Z => n38);
   U47 : IVI port map( A => A(6), Z => n39);
   U48 : IVI port map( A => A(7), Z => n40);
   U49 : IVI port map( A => B(2), Z => n41);
   U50 : IVI port map( A => B(0), Z => n42);

end SYN_rpl;

library IEEE;

use IEEE.std_logic_1164.all;

use work.CONV_PACK_dds_synthesizer_ftw_width32.all;

entity dds_synthesizer_ftw_width32 is

   port( clk_i, rst_i : in std_logic;  ftw_i : in std_logic_vector (31 downto 
         0);  phase_i : in std_logic_vector (9 downto 0);  phase_o, ampl_o : 
         out std_logic_vector (9 downto 0));

end dds_synthesizer_ftw_width32;

architecture SYN_dds_synthesizer_arch of dds_synthesizer_ftw_width32 is

   component ND2
      port( A, B : in std_logic;  Z : out std_logic);
   end component;
   
   component NR2
      port( A, B : in std_logic;  Z : out std_logic);
   end component;
   
   component MUX21L
      port( A, B, S : in std_logic;  Z : out std_logic);
   end component;
   
   component IV
      port( A : in std_logic;  Z : out std_logic);
   end component;
   
   component AO4
      port( A, B, C, D : in std_logic;  Z : out std_logic);
   end component;
   
   component AO6
      port( A, B, C : in std_logic;  Z : out std_logic);
   end component;
   
   component NR3
      port( A, B, C : in std_logic;  Z : out std_logic);
   end component;
   
   component AO2
      port( A, B, C, D : in std_logic;  Z : out std_logic);
   end component;
   
   component AO3
      port( A, B, C, D : in std_logic;  Z : out std_logic);
   end component;
   
   component EN
      port( A, B : in std_logic;  Z : out std_logic);
   end component;
   
   component AO1
      port( A, B, C, D : in std_logic;  Z : out std_logic);
   end component;
   
   component NR4
      port( A, B, C, D : in std_logic;  Z : out std_logic);
   end component;
   
   component EO
      port( A, B : in std_logic;  Z : out std_logic);
   end component;
   
   component AO7
      port( A, B, C : in std_logic;  Z : out std_logic);
   end component;
   
   component ND4
      port( A, B, C, D : in std_logic;  Z : out std_logic);
   end component;
   
   component ND3
      port( A, B, C : in std_logic;  Z : out std_logic);
   end component;
   
   component EO1
      port( A, B, C, D : in std_logic;  Z : out std_logic);
   end component;
   
   component OR2
      port( A, B : in std_logic;  Z : out std_logic);
   end component;
   
   component EON1
      port( A, B, C, D : in std_logic;  Z : out std_logic);
   end component;
   
   component OR3
      port( A, B, C : in std_logic;  Z : out std_logic);
   end component;
   
   component MUX21H
      port( A, B, S : in std_logic;  Z : out std_logic);
   end component;
   
   component AN3
      port( A, B, C : in std_logic;  Z : out std_logic);
   end component;
   
   component AN2
      port( A, B : in std_logic;  Z : out std_logic);
   end component;
   
   component dds_synthesizer_ftw_width32_DW01_add_1
      port( A, B : in std_logic_vector (31 downto 0);  CI : in std_logic;  SUM 
            : out std_logic_vector (31 downto 0);  CO : out std_logic);
   end component;
   
   component dds_synthesizer_ftw_width32_DW01_add_0
      port( A, B : in std_logic_vector (9 downto 0);  CI : in std_logic;  SUM :
            out std_logic_vector (9 downto 0);  CO : out std_logic);
   end component;
   
   component FD2
      port( D, CP, CD : in std_logic;  Q, QN : out std_logic);
   end component;
   
   signal phase_o_9_port, phase_o_8_port, phase_o_7_port, phase_o_6_port, 
      phase_o_5_port, phase_o_4_port, phase_o_3_port, phase_o_2_port, 
      phase_o_1_port, N290, ftw_accu_31_port, ftw_accu_30_port, 
      ftw_accu_29_port, ftw_accu_28_port, ftw_accu_27_port, ftw_accu_26_port, 
      ftw_accu_25_port, ftw_accu_24_port, ftw_accu_23_port, ftw_accu_22_port, 
      ftw_accu_21_port, ftw_accu_20_port, ftw_accu_19_port, ftw_accu_18_port, 
      ftw_accu_17_port, ftw_accu_16_port, ftw_accu_15_port, ftw_accu_14_port, 
      ftw_accu_13_port, ftw_accu_12_port, ftw_accu_11_port, ftw_accu_10_port, 
      ftw_accu_9_port, ftw_accu_8_port, ftw_accu_7_port, ftw_accu_6_port, 
      ftw_accu_5_port, ftw_accu_4_port, ftw_accu_3_port, ftw_accu_2_port, 
      ftw_accu_1_port, ftw_accu_0_port, lut_out_8_port, lut_out_7_port, 
      lut_out_6_port, lut_out_5_port, lut_out_4_port, lut_out_3_port, 
      lut_out_2_port, lut_out_1_port, quadrant_3_or_4_delay, N299, N300, N301, 
      N302, N303, N304, N305, N306, N307, N308, N309, N310, N311, N312, N313, 
      N314, N315, N316, N317, N318, N319, N320, N321, N322, N323, N324, N325, 
      N326, N327, N328, N329, N330, N331, N332, N333, N334, N335, N336, N337, 
      N338, N339, N340, N360, N361, N362, N363, N364, N365, N366, N367, N368, 
      N370, N371, N372, N373, N374, N375, N376, N377, N378, N379, n651, n652, 
      n653, n654, n655, n656, n657, n658, n659, n660, n661, n662, n663, n664, 
      n665, n666, n667, n668, n669, n670, n671, n672, n673, n674, n675, n676, 
      n678, n679, n1033, n1034, n1035, n1036, n1037, n1038, n1039, n1040, n1041
      , n1042, n1043, n1044, n1045, n1046, n1047, n1048, n1049, n1050, n1051, 
      n1052, n1053, n1054, n1055, n1056, n1057, n1058, n1059, n1060, n1061, 
      n1062, n1063, n1064, n1065, n1066, n1067, n1068, n1069, n1070, n1071, 
      n1072, n1073, n1074, n1075, n1076, n1077, n1078, n1079, n1080, n1081, 
      n1082, n1083, n1084, n1085, n1086, n1087, n1088, n1089, n1090, n1091, 
      n1092, n1093, n1094, n1095, n1096, n1097, n1098, n1099, n1100, n1101, 
      n1102, n1103, n1104, n1105, n1106, n1107, n1108, n1109, n1110, n1111, 
      n1112, n1113, n1114, n1115, n1116, n1117, n1118, n1119, n1120, n1121, 
      n1122, n1123, n1124, n1125, n1126, n1127, n1128, n1129, n1130, n1131, 
      n1132, n1133, n1134, n1135, n1136, n1137, n1138, n1139, n1140, n1141, 
      n1142, n1143, n1144, n1145, n1146, n1147, n1148, n1149, n1150, n1151, 
      n1152, n1153, n1154, n1155, n1156, n1157, n1158, n1159, n1160, n1161, 
      n1162, n1163, n1164, n1165, n1166, n1167, n1168, n1169, n1170, n1171, 
      n1172, n1173, n1174, n1175, n1176, n1177, n1178, n1179, n1180, n1181, 
      n1182, n1183, n1184, n1185, n1186, n1187, n1188, n1189, n1190, n1191, 
      n1192, n1193, n1194, n1195, n1196, n1197, n1198, n1199, n1200, n1201, 
      n1202, n1203, n1204, n1205, n1206, n1207, n1208, n1209, n1210, n1211, 
      n1212, n1213, n1214, n1215, n1216, n1217, n1218, n1219, n1220, n1221, 
      n1222, n1223, n1224, n1225, n1226, n1227, n1228, n1229, n1230, n1231, 
      n1232, n1233, n1234, n1235, n1236, n1237, n1238, n1239, n1240, n1241, 
      n1242, n1243, n1244, n1245, n1246, n1247, n1248, n1249, n1250, n1251, 
      n1252, n1253, n1254, n1255, n1256, n1257, n1258, n1259, n1260, n1261, 
      n1262, n1263, n1264, n1265, n1266, n1267, n1268, n1269, n1270, n1271, 
      n1272, n1273, n1274, n1275, n1276, n1277, n1278, n1279, n1280, n1281, 
      n1282, n1283, n1284, n1285, n1286, n1287, n1288, n1289, n1290, n1291, 
      n1292, n1293, n1294, n1295, n1296, n1297, n1298, n1299, n1300, n1301, 
      n1302, n1303, n1304, n1305, n1306, n1307, n1308, n1309, n1310, n1311, 
      n1312, n1313, n1314, n1315, n1316, n1317, n1318, n1319, n1320, n1321, 
      n1322, n1323, n1324, n1325, n1326, n1327, n1328, n1329, n1330, n1331, 
      n1332, n1333, n1334, n1335, n1336, n1337, n1338, n1339, n1340, n1341, 
      n1342, n1343, n1344, n1345, n1346, n1347, n1348, n1349, n1350, n1351, 
      n1352, n1353, n1354, n1355, n1356, n1357, n1358, n1359, n1360, n_1004, 
      n_1005, n_1006, n_1007, n_1008, n_1009, n_1010, n_1011, n_1012, n_1013, 
      n_1014, n_1015, n_1016, n_1017, n_1018, n_1019, n_1020, n_1021, n_1022, 
      n_1023, n_1024, n_1025, n_1026, n_1027, n_1028, n_1029, n_1030, n_1031, 
      n_1032, n_1033, n_1034, n_1035, n_1036, n_1037, n_1038, n_1039, n_1040, 
      n_1041, n_1042, n_1043, n_1044, n_1045, n_1046, n_1047, n_1048, n_1049, 
      n_1050, n_1051, n_1052, n_1053, n_1054, n_1055, n_1056, n_1057, n_1058, 
      n_1059, n_1060, n_1061, n_1062 : std_logic;

begin
   phase_o <= ( phase_o_9_port, phase_o_8_port, phase_o_7_port, phase_o_6_port,
      phase_o_5_port, phase_o_4_port, phase_o_3_port, phase_o_2_port, 
      phase_o_1_port, N290 );
   
   ftw_accu_reg_0_inst : FD2 port map( D => N299, CP => clk_i, CD => n1360, Q 
                           => ftw_accu_0_port, QN => n_1004);
   ftw_accu_reg_1_inst : FD2 port map( D => N300, CP => clk_i, CD => n1360, Q 
                           => ftw_accu_1_port, QN => n_1005);
   ftw_accu_reg_2_inst : FD2 port map( D => N301, CP => clk_i, CD => n1360, Q 
                           => ftw_accu_2_port, QN => n_1006);
   ftw_accu_reg_3_inst : FD2 port map( D => N302, CP => clk_i, CD => n1360, Q 
                           => ftw_accu_3_port, QN => n_1007);
   ftw_accu_reg_4_inst : FD2 port map( D => N303, CP => clk_i, CD => n1360, Q 
                           => ftw_accu_4_port, QN => n_1008);
   ftw_accu_reg_5_inst : FD2 port map( D => N304, CP => clk_i, CD => n1360, Q 
                           => ftw_accu_5_port, QN => n_1009);
   ftw_accu_reg_6_inst : FD2 port map( D => N305, CP => clk_i, CD => n1360, Q 
                           => ftw_accu_6_port, QN => n_1010);
   ftw_accu_reg_7_inst : FD2 port map( D => N306, CP => clk_i, CD => n1360, Q 
                           => ftw_accu_7_port, QN => n_1011);
   ftw_accu_reg_8_inst : FD2 port map( D => N307, CP => clk_i, CD => n1360, Q 
                           => ftw_accu_8_port, QN => n_1012);
   ftw_accu_reg_9_inst : FD2 port map( D => N308, CP => clk_i, CD => n1360, Q 
                           => ftw_accu_9_port, QN => n_1013);
   ftw_accu_reg_10_inst : FD2 port map( D => N309, CP => clk_i, CD => n1360, Q 
                           => ftw_accu_10_port, QN => n_1014);
   ftw_accu_reg_11_inst : FD2 port map( D => N310, CP => clk_i, CD => n1360, Q 
                           => ftw_accu_11_port, QN => n_1015);
   ftw_accu_reg_12_inst : FD2 port map( D => N311, CP => clk_i, CD => n1360, Q 
                           => ftw_accu_12_port, QN => n_1016);
   ftw_accu_reg_13_inst : FD2 port map( D => N312, CP => clk_i, CD => n1360, Q 
                           => ftw_accu_13_port, QN => n_1017);
   ftw_accu_reg_14_inst : FD2 port map( D => N313, CP => clk_i, CD => n1360, Q 
                           => ftw_accu_14_port, QN => n_1018);
   ftw_accu_reg_15_inst : FD2 port map( D => N314, CP => clk_i, CD => n1360, Q 
                           => ftw_accu_15_port, QN => n_1019);
   ftw_accu_reg_16_inst : FD2 port map( D => N315, CP => clk_i, CD => n1360, Q 
                           => ftw_accu_16_port, QN => n_1020);
   ftw_accu_reg_17_inst : FD2 port map( D => N316, CP => clk_i, CD => n1360, Q 
                           => ftw_accu_17_port, QN => n_1021);
   ftw_accu_reg_18_inst : FD2 port map( D => N317, CP => clk_i, CD => n1360, Q 
                           => ftw_accu_18_port, QN => n_1022);
   ftw_accu_reg_19_inst : FD2 port map( D => N318, CP => clk_i, CD => n1360, Q 
                           => ftw_accu_19_port, QN => n_1023);
   ftw_accu_reg_20_inst : FD2 port map( D => N319, CP => clk_i, CD => n1360, Q 
                           => ftw_accu_20_port, QN => n_1024);
   ftw_accu_reg_21_inst : FD2 port map( D => N320, CP => clk_i, CD => n1360, Q 
                           => ftw_accu_21_port, QN => n_1025);
   ftw_accu_reg_22_inst : FD2 port map( D => N321, CP => clk_i, CD => n1360, Q 
                           => ftw_accu_22_port, QN => n_1026);
   ftw_accu_reg_23_inst : FD2 port map( D => N322, CP => clk_i, CD => n1360, Q 
                           => ftw_accu_23_port, QN => n_1027);
   ftw_accu_reg_24_inst : FD2 port map( D => N323, CP => clk_i, CD => n1360, Q 
                           => ftw_accu_24_port, QN => n_1028);
   ftw_accu_reg_25_inst : FD2 port map( D => N324, CP => clk_i, CD => n1360, Q 
                           => ftw_accu_25_port, QN => n_1029);
   ftw_accu_reg_26_inst : FD2 port map( D => N325, CP => clk_i, CD => n1360, Q 
                           => ftw_accu_26_port, QN => n_1030);
   ftw_accu_reg_27_inst : FD2 port map( D => N326, CP => clk_i, CD => n1360, Q 
                           => ftw_accu_27_port, QN => n_1031);
   ftw_accu_reg_28_inst : FD2 port map( D => N327, CP => clk_i, CD => n1360, Q 
                           => ftw_accu_28_port, QN => n_1032);
   ftw_accu_reg_29_inst : FD2 port map( D => N328, CP => clk_i, CD => n1360, Q 
                           => ftw_accu_29_port, QN => n_1033);
   ftw_accu_reg_30_inst : FD2 port map( D => N329, CP => clk_i, CD => n1360, Q 
                           => ftw_accu_30_port, QN => n_1034);
   ftw_accu_reg_31_inst : FD2 port map( D => N330, CP => clk_i, CD => n1360, Q 
                           => ftw_accu_31_port, QN => n_1035);
   phase_reg_9_inst : FD2 port map( D => N340, CP => clk_i, CD => n1360, Q => 
                           phase_o_9_port, QN => n_1036);
   phase_reg_8_inst : FD2 port map( D => N339, CP => clk_i, CD => n1360, Q => 
                           phase_o_8_port, QN => n1036);
   phase_reg_7_inst : FD2 port map( D => N338, CP => clk_i, CD => n1360, Q => 
                           phase_o_7_port, QN => n1041);
   phase_reg_6_inst : FD2 port map( D => N337, CP => clk_i, CD => n1360, Q => 
                           phase_o_6_port, QN => n_1037);
   phase_reg_5_inst : FD2 port map( D => N336, CP => clk_i, CD => n1360, Q => 
                           phase_o_5_port, QN => n1038);
   phase_reg_4_inst : FD2 port map( D => N335, CP => clk_i, CD => n1360, Q => 
                           phase_o_4_port, QN => n_1038);
   phase_reg_3_inst : FD2 port map( D => N334, CP => clk_i, CD => n1360, Q => 
                           phase_o_3_port, QN => n1039);
   phase_reg_2_inst : FD2 port map( D => N333, CP => clk_i, CD => n1360, Q => 
                           phase_o_2_port, QN => n_1039);
   phase_reg_1_inst : FD2 port map( D => N332, CP => clk_i, CD => n1360, Q => 
                           phase_o_1_port, QN => n1040);
   phase_reg_0_inst : FD2 port map( D => N331, CP => clk_i, CD => n1360, Q => 
                           N290, QN => n676);
   lut_out_reg_8_inst : FD2 port map( D => N368, CP => clk_i, CD => n1360, Q =>
                           lut_out_8_port, QN => n670);
   lut_out_reg_7_inst : FD2 port map( D => N367, CP => clk_i, CD => n1360, Q =>
                           lut_out_7_port, QN => n671);
   lut_out_reg_6_inst : FD2 port map( D => N366, CP => clk_i, CD => n1360, Q =>
                           lut_out_6_port, QN => n1033);
   lut_out_reg_5_inst : FD2 port map( D => N365, CP => clk_i, CD => n1360, Q =>
                           lut_out_5_port, QN => n672);
   lut_out_reg_4_inst : FD2 port map( D => N364, CP => clk_i, CD => n1360, Q =>
                           lut_out_4_port, QN => n1034);
   lut_out_reg_3_inst : FD2 port map( D => N363, CP => clk_i, CD => n1360, Q =>
                           lut_out_3_port, QN => n673);
   lut_out_reg_2_inst : FD2 port map( D => N362, CP => clk_i, CD => n1360, Q =>
                           lut_out_2_port, QN => n1035);
   lut_out_reg_1_inst : FD2 port map( D => N361, CP => clk_i, CD => n1360, Q =>
                           lut_out_1_port, QN => n675);
   lut_out_reg_0_inst : FD2 port map( D => N360, CP => clk_i, CD => n1360, Q =>
                           N370, QN => n674);
   lut_out_delay_reg_8_inst : FD2 port map( D => lut_out_8_port, CP => clk_i, 
                           CD => n1360, Q => n_1040, QN => n652);
   lut_out_delay_reg_7_inst : FD2 port map( D => lut_out_7_port, CP => clk_i, 
                           CD => n1360, Q => n_1041, QN => n654);
   lut_out_delay_reg_6_inst : FD2 port map( D => lut_out_6_port, CP => clk_i, 
                           CD => n1360, Q => n_1042, QN => n656);
   lut_out_delay_reg_5_inst : FD2 port map( D => lut_out_5_port, CP => clk_i, 
                           CD => n1360, Q => n_1043, QN => n658);
   lut_out_delay_reg_4_inst : FD2 port map( D => lut_out_4_port, CP => clk_i, 
                           CD => n1360, Q => n_1044, QN => n660);
   lut_out_delay_reg_3_inst : FD2 port map( D => lut_out_3_port, CP => clk_i, 
                           CD => n1360, Q => n_1045, QN => n662);
   lut_out_delay_reg_2_inst : FD2 port map( D => lut_out_2_port, CP => clk_i, 
                           CD => n1360, Q => n_1046, QN => n664);
   lut_out_delay_reg_1_inst : FD2 port map( D => lut_out_1_port, CP => clk_i, 
                           CD => n1360, Q => n_1047, QN => n666);
   lut_out_delay_reg_0_inst : FD2 port map( D => N370, CP => clk_i, CD => n1360
                           , Q => n_1048, QN => n668);
   lut_out_inv_delay_reg_9_inst : FD2 port map( D => N379, CP => clk_i, CD => 
                           n1360, Q => n_1049, QN => n669);
   lut_out_inv_delay_reg_8_inst : FD2 port map( D => N378, CP => clk_i, CD => 
                           n1360, Q => n_1050, QN => n651);
   lut_out_inv_delay_reg_7_inst : FD2 port map( D => N377, CP => clk_i, CD => 
                           n1360, Q => n_1051, QN => n653);
   lut_out_inv_delay_reg_6_inst : FD2 port map( D => N374, CP => clk_i, CD => 
                           n1360, Q => n_1052, QN => n655);
   lut_out_inv_delay_reg_5_inst : FD2 port map( D => n1360, CP => clk_i, CD => 
                           n1360, Q => n_1053, QN => n657);
   lut_out_inv_delay_reg_4_inst : FD2 port map( D => N374, CP => clk_i, CD => 
                           n1360, Q => n_1054, QN => n659);
   lut_out_inv_delay_reg_3_inst : FD2 port map( D => N373, CP => clk_i, CD => 
                           n1360, Q => n_1055, QN => n661);
   lut_out_inv_delay_reg_2_inst : FD2 port map( D => N372, CP => clk_i, CD => 
                           n1360, Q => n_1056, QN => n663);
   lut_out_inv_delay_reg_1_inst : FD2 port map( D => n661, CP => clk_i, CD => 
                           n1360, Q => n_1057, QN => n665);
   lut_out_inv_delay_reg_0_inst : FD2 port map( D => N370, CP => clk_i, CD => 
                           n1360, Q => n_1058, QN => n667);
   quadrant_3_or_4_delay_reg : FD2 port map( D => phase_o_9_port, CP => clk_i, 
                           CD => n1360, Q => quadrant_3_or_4_delay, QN => 
                           n_1059);
   quadrant_3_or_4_2delay_reg : FD2 port map( D => quadrant_3_or_4_delay, CP =>
                           clk_i, CD => n1360, Q => n_1060, QN => n1037);
   n678 <= '0';
   n679 <= '0';
   add_99 : dds_synthesizer_ftw_width32_DW01_add_0 port map( A(9) => 
                           ftw_accu_31_port, A(8) => ftw_accu_30_port, A(7) => 
                           ftw_accu_29_port, A(6) => ftw_accu_28_port, A(5) => 
                           ftw_accu_27_port, A(4) => ftw_accu_26_port, A(3) => 
                           ftw_accu_25_port, A(2) => ftw_accu_24_port, A(1) => 
                           ftw_accu_23_port, A(0) => ftw_accu_22_port, B(9) => 
                           phase_i(9), B(8) => phase_i(8), B(7) => phase_i(7), 
                           B(6) => phase_i(6), B(5) => phase_i(5), B(4) => 
                           phase_i(4), B(3) => phase_i(3), B(2) => phase_i(2), 
                           B(1) => phase_i(1), B(0) => phase_i(0), CI => n678, 
                           SUM(9) => N340, SUM(8) => N339, SUM(7) => N338, 
                           SUM(6) => N337, SUM(5) => N336, SUM(4) => N335, 
                           SUM(3) => N334, SUM(2) => N333, SUM(1) => N332, 
                           SUM(0) => N331, CO => n_1061);
   add_98 : dds_synthesizer_ftw_width32_DW01_add_1 port map( A(31) => 
                           ftw_accu_31_port, A(30) => ftw_accu_30_port, A(29) 
                           => ftw_accu_29_port, A(28) => ftw_accu_28_port, 
                           A(27) => ftw_accu_27_port, A(26) => ftw_accu_26_port
                           , A(25) => ftw_accu_25_port, A(24) => 
                           ftw_accu_24_port, A(23) => ftw_accu_23_port, A(22) 
                           => ftw_accu_22_port, A(21) => ftw_accu_21_port, 
                           A(20) => ftw_accu_20_port, A(19) => ftw_accu_19_port
                           , A(18) => ftw_accu_18_port, A(17) => 
                           ftw_accu_17_port, A(16) => ftw_accu_16_port, A(15) 
                           => ftw_accu_15_port, A(14) => ftw_accu_14_port, 
                           A(13) => ftw_accu_13_port, A(12) => ftw_accu_12_port
                           , A(11) => ftw_accu_11_port, A(10) => 
                           ftw_accu_10_port, A(9) => ftw_accu_9_port, A(8) => 
                           ftw_accu_8_port, A(7) => ftw_accu_7_port, A(6) => 
                           ftw_accu_6_port, A(5) => ftw_accu_5_port, A(4) => 
                           ftw_accu_4_port, A(3) => ftw_accu_3_port, A(2) => 
                           ftw_accu_2_port, A(1) => ftw_accu_1_port, A(0) => 
                           ftw_accu_0_port, B(31) => ftw_i(31), B(30) => 
                           ftw_i(30), B(29) => ftw_i(29), B(28) => ftw_i(28), 
                           B(27) => ftw_i(27), B(26) => ftw_i(26), B(25) => 
                           ftw_i(25), B(24) => ftw_i(24), B(23) => ftw_i(23), 
                           B(22) => ftw_i(22), B(21) => ftw_i(21), B(20) => 
                           ftw_i(20), B(19) => ftw_i(19), B(18) => ftw_i(18), 
                           B(17) => ftw_i(17), B(16) => ftw_i(16), B(15) => 
                           ftw_i(15), B(14) => ftw_i(14), B(13) => ftw_i(13), 
                           B(12) => ftw_i(12), B(11) => ftw_i(11), B(10) => 
                           ftw_i(10), B(9) => ftw_i(9), B(8) => ftw_i(8), B(7) 
                           => ftw_i(7), B(6) => ftw_i(6), B(5) => ftw_i(5), 
                           B(4) => ftw_i(4), B(3) => ftw_i(3), B(2) => ftw_i(2)
                           , B(1) => ftw_i(1), B(0) => ftw_i(0), CI => n679, 
                           SUM(31) => N330, SUM(30) => N329, SUM(29) => N328, 
                           SUM(28) => N327, SUM(27) => N326, SUM(26) => N325, 
                           SUM(25) => N324, SUM(24) => N323, SUM(23) => N322, 
                           SUM(22) => N321, SUM(21) => N320, SUM(20) => N319, 
                           SUM(19) => N318, SUM(18) => N317, SUM(17) => N316, 
                           SUM(16) => N315, SUM(15) => N314, SUM(14) => N313, 
                           SUM(13) => N312, SUM(12) => N311, SUM(11) => N310, 
                           SUM(10) => N309, SUM(9) => N308, SUM(8) => N307, 
                           SUM(7) => N306, SUM(6) => N305, SUM(5) => N304, 
                           SUM(4) => N303, SUM(3) => N302, SUM(2) => N301, 
                           SUM(1) => N300, SUM(0) => N299, CO => n_1062);
   U690 : IV port map( A => rst_i, Z => n1360);
   U691 : NR2 port map( A => n669, B => n1037, Z => ampl_o(9));
   U692 : MUX21L port map( A => n651, B => n652, S => n1037, Z => ampl_o(8));
   U693 : MUX21L port map( A => n653, B => n654, S => n1037, Z => ampl_o(7));
   U694 : MUX21L port map( A => n655, B => n656, S => n1037, Z => ampl_o(6));
   U695 : MUX21L port map( A => n657, B => n658, S => n1037, Z => ampl_o(5));
   U696 : MUX21L port map( A => n659, B => n660, S => n1037, Z => ampl_o(4));
   U697 : MUX21L port map( A => n661, B => n662, S => n1037, Z => ampl_o(3));
   U698 : MUX21L port map( A => n663, B => n664, S => n1037, Z => ampl_o(2));
   U699 : MUX21L port map( A => n665, B => n666, S => n1037, Z => ampl_o(1));
   U700 : MUX21L port map( A => n667, B => n668, S => n1037, Z => ampl_o(0));
   U701 : ND2 port map( A => n670, B => n1042, Z => N379);
   U702 : EO port map( A => n670, B => n1042, Z => N378);
   U703 : NR2 port map( A => lut_out_7_port, B => n1043, Z => n1042);
   U704 : EN port map( A => n671, B => n1043, Z => N377);
   U705 : NR2 port map( A => n1033, B => n1044, Z => n1043);
   U706 : EO port map( A => n1033, B => n1044, Z => N376);
   U707 : NR2 port map( A => n672, B => n1045, Z => n1044);
   U708 : EO port map( A => n672, B => n1045, Z => N375);
   U709 : AN3 port map( A => n1034, B => n1046, C => n673, Z => n1045);
   --
   U710 : EO port map( A => n1034, B => n1047, Z => N374);
   --
   U711 : AN2 port map( A => n673, B => n1046, Z => n1047);
   --
   U712 : EO port map( A => n673, B => n1046, Z => N373);
   --
   U713 : AN3 port map( A => n674, B => n1035, C => n675, Z => n1046);
   --
   U714 : EN port map( A => n1035, B => n1048, Z => N372);
   U715 : ND2 port map( A => n675, B => n674, Z => n1048);
   U716 : EO port map( A => n675, B => n674, Z => N371);
   U717 : AO3 port map( A => n1049, B => n1050, C => n1051, D => n1052, Z => 
                           N368);
   U718 : AO6 port map( A => n1053, B => n1054, C => n1055, Z => n1049);
   U719 : AO3 port map( A => n1056, B => n1052, C => n1051, D => n1057, Z => 
                           N367);
   U720 : MUX21H port map( A => n1058, B => n1059, S => n1060, Z => n1057);
   U721 : AO6 port map( A => n1061, B => n1062, C => n1063, Z => n1059);
   U722 : AO6 port map( A => n1064, B => n1065, C => n1066, Z => n1058);
   U723 : NR2 port map( A => n1067, B => n1068, Z => n1056);
   U724 : AO3 port map( A => n1069, B => n1052, C => n1070, D => n1071, Z => 
                           N366);
   U725 : AO1 port map( A => n1072, B => n1073, C => n1074, D => n1075, Z => 
                           n1071);
   U726 : NR2 port map( A => n1076, B => n1050, Z => n1075);
   U727 : AO1 port map( A => n1077, B => n1061, C => n1078, D => n1079, Z => 
                           n1076);
   U728 : AO7 port map( A => n1080, B => n1081, C => n1068, Z => n1078);
   U729 : MUX21L port map( A => n1082, B => n1066, S => n1083, Z => n1070);
   U730 : OR3 port map( A => n1084, B => n1085, C => n1086, Z => n1082);
   U731 : AO4 port map( A => n1087, B => n1088, C => n1089, D => n1090, Z => 
                           n1086);
   U732 : AO2 port map( A => n1091, B => n1092, C => n1063, D => n1093, Z => 
                           n1069);
   U733 : NR2 port map( A => n1094, B => n1061, Z => n1091);
   U734 : AO3 port map( A => n1095, B => n1052, C => n1096, D => n1097, Z => 
                           N365);
   U735 : AO2 port map( A => n1098, B => n1099, C => n1100, D => n1101, Z => 
                           n1097);
   U736 : ND4 port map( A => n1102, B => n1103, C => n1104, D => n1105, Z => 
                           n1099);
   U737 : AO1 port map( A => n1106, B => n1107, C => n1108, D => n1109, Z => 
                           n1105);
   U738 : NR2 port map( A => n1068, B => n1093, Z => n1109);
   U739 : IV port map( A => n1067, Z => n1093);
   U740 : IV port map( A => n1063, Z => n1068);
   U741 : MUX21L port map( A => n1110, B => n1111, S => n1080, Z => n1108);
   U742 : IV port map( A => n1085, Z => n1110);
   U743 : AO7 port map( A => n1112, B => n1113, C => n1077, Z => n1104);
   U744 : IV port map( A => n1084, Z => n1102);
   U745 : AO6 port map( A => n1114, B => n1115, C => n1074, Z => n1096);
   U746 : AO3 port map( A => n1053, B => n1116, C => n1117, D => n1118, Z => 
                           n1115);
   U747 : AO2 port map( A => n1119, B => n1120, C => n1101, D => n1064, Z => 
                           n1118);
   U748 : AO7 port map( A => n1121, B => n1122, C => n1123, Z => n1064);
   U749 : ND2 port map( A => n1124, B => n1125, Z => n1120);
   U750 : MUX21L port map( A => n1080, B => n1087, S => n1122, Z => n1124);
   U751 : NR4 port map( A => n1084, B => n1126, C => n1127, D => n1128, Z => 
                           n1095);
   U752 : MUX21L port map( A => n1080, B => n1050, S => n1129, Z => n1128);
   U753 : MUX21L port map( A => n1130, B => n1131, S => n1122, Z => n1127);
   U754 : ND2 port map( A => n1067, B => n1054, Z => n1131);
   U755 : AO6 port map( A => n1132, B => n1133, C => n1094, Z => n1067);
   U756 : ND2 port map( A => n1061, B => n1089, Z => n1130);
   U757 : ND2 port map( A => n1134, B => n1135, Z => n1126);
   U758 : ND2 port map( A => n1129, B => n1122, Z => n1084);
   U759 : AO3 port map( A => n1136, B => n1083, C => n1051, D => n1137, Z => 
                           N364);
   U760 : AO2 port map( A => n1114, B => n1138, C => n1079, D => n1139, Z => 
                           n1137);
   U761 : AO3 port map( A => n1122, B => n1140, C => n1117, D => n1141, Z => 
                           n1139);
   U762 : MUX21L port map( A => n1142, B => n1143, S => n1050, Z => n1141);
   U763 : AO3 port map( A => n1133, B => n1129, C => n1144, D => n1145, Z => 
                           n1143);
   U764 : AO6 port map( A => n1146, B => n1065, C => n1147, Z => n1145);
   U765 : MUX21L port map( A => n1062, B => n1148, S => n1132, Z => n1144);
   U766 : AO7 port map( A => n1149, B => n1129, C => n1150, Z => n1142);
   U767 : ND4 port map( A => n1151, B => n1152, C => n1153, D => n1154, Z => 
                           n1138);
   U768 : AO1 port map( A => n1155, B => n1054, C => n1156, D => n1157, Z => 
                           n1154);
   U769 : NR2 port map( A => n1094, B => n1158, Z => n1157);
   U770 : AO4 port map( A => n1087, B => n1088, C => n1134, D => n1140, Z => 
                           n1156);
   U771 : EO1 port map( A => n1159, B => n1092, C => n1103, D => n1160, Z => 
                           n1153);
   U772 : IV port map( A => n1161, Z => n1152);
   U773 : NR4 port map( A => n1162, B => n1163, C => n1164, D => n1165, Z => 
                           n1136);
   U774 : AO4 port map( A => n1054, B => n1166, C => n1129, D => n1123, Z => 
                           n1165);
   U775 : MUX21L port map( A => n1167, B => n1168, S => n1133, Z => n1164);
   U776 : AO6 port map( A => n1087, B => n1054, C => n1077, Z => n1168);
   U777 : ND2 port map( A => n1072, B => n1132, Z => n1167);
   U778 : AO4 port map( A => n1158, B => n1140, C => n1135, D => n1169, Z => 
                           n1163);
   U779 : AO7 port map( A => n1116, B => n1170, C => n1151, Z => n1162);
   U780 : OR2 port map( A => n1090, B => n1129, Z => n1151);
   U781 : AO3 port map( A => n1171, B => n1172, C => n1173, D => n1174, Z => 
                           N363);
   U782 : AO2 port map( A => n1098, B => n1175, C => n1114, D => n1176, Z => 
                           n1174);
   U783 : AO3 port map( A => n1140, B => n1169, C => n1177, D => n1178, Z => 
                           n1176);
   U784 : AO1 port map( A => n1179, B => n1072, C => n1180, D => n1181, Z => 
                           n1178);
   U785 : EON1 port map( A => n1182, B => n1132, C => n1183, D => n1101, Z => 
                           n1180);
   U786 : AO3 port map( A => n1184, B => n1092, C => n1185, D => n1186, Z => 
                           n1183);
   U787 : AO6 port map( A => n1107, B => n1119, C => n1161, Z => n1182);
   U788 : NR2 port map( A => n1160, B => n1187, Z => n1179);
   U789 : AO2 port map( A => n1077, B => n1188, C => n1159, D => n1189, Z => 
                           n1177);
   U790 : AO3 port map( A => n1123, B => n1170, C => n1190, D => n1191, Z => 
                           n1188);
   U791 : ND4 port map( A => n1192, B => n1193, C => n1194, D => n1195, Z => 
                           n1175);
   U792 : AO6 port map( A => n1196, B => n1085, C => n1181, Z => n1195);
   U793 : NR2 port map( A => n1090, B => n1081, Z => n1181);
   U794 : ND2 port map( A => n1197, B => n1170, Z => n1090);
   U795 : NR2 port map( A => n1198, B => n1092, Z => n1085);
   U796 : EO1 port map( A => n1113, B => n1199, C => n1116, D => n1184, Z => 
                           n1194);
   U797 : IV port map( A => n1200, Z => n1116);
   U798 : AO3 port map( A => n1132, B => n1129, C => n1135, D => n1201, Z => 
                           n1199);
   U799 : IV port map( A => n1159, Z => n1135);
   U800 : NR2 port map( A => n1081, B => n1202, Z => n1159);
   U801 : MUX21L port map( A => n1203, B => n1204, S => n1094, Z => n1193);
   U802 : ND2 port map( A => n1166, B => n1190, Z => n1204);
   U803 : IV port map( A => n1146, Z => n1190);
   U804 : AO7 port map( A => n1202, B => n1123, C => n1185, Z => n1203);
   U805 : AO2 port map( A => n1112, B => n1101, C => n1205, D => n1206, Z => 
                           n1192);
   U806 : AO6 port map( A => n1207, B => n1208, C => n1074, Z => n1173);
   U807 : ND4 port map( A => n1209, B => n1210, C => n1186, D => n1211, Z => 
                           n1208);
   U808 : IV port map( A => n1212, Z => n1186);
   U809 : ND2 port map( A => n1092, B => n1065, Z => n1210);
   U810 : MUX21L port map( A => n1119, B => n1062, S => n1080, Z => n1209);
   U811 : NR2 port map( A => n1065, B => n1092, Z => n1062);
   U812 : AO1 port map( A => n1113, B => n1132, C => n1213, D => n1214, Z => 
                           n1171);
   U813 : AO4 port map( A => n1160, B => n1088, C => n1123, D => n1140, Z => 
                           n1214);
   U814 : AO3 port map( A => n1215, B => n1158, C => n1216, D => n1103, Z => 
                           n1213);
   U815 : ND2 port map( A => n1189, B => n1077, Z => n1103);
   U816 : AO7 port map( A => n1063, B => n1077, C => n1149, Z => n1216);
   U817 : NR2 port map( A => n1092, B => n1054, Z => n1063);
   U818 : NR2 port map( A => n1217, B => n1101, Z => n1215);
   U819 : AO3 port map( A => n1218, B => n1219, C => n1220, D => n1221, Z => 
                           N362);
   U820 : AO1 port map( A => n1207, B => n1222, C => n1223, D => n1074, Z => 
                           n1221);
   U821 : AO6 port map( A => n1224, B => n1225, C => n1083, Z => n1223);
   U822 : MUX21L port map( A => n1189, B => n1107, S => n1226, Z => n1225);
   U823 : AO2 port map( A => n1197, B => n1227, C => n1113, D => n1228, Z => 
                           n1224);
   U824 : AO3 port map( A => n1089, B => n1229, C => n1230, D => n1231, Z => 
                           n1228);
   U825 : AO2 port map( A => n1232, B => n1119, C => n1072, D => N290, Z => 
                           n1231);
   U826 : AO7 port map( A => N290, B => n1089, C => n1233, Z => n1227);
   U827 : AO2 port map( A => n1119, B => n1229, C => n1101, D => n1234, Z => 
                           n1233);
   U828 : ND3 port map( A => n1235, B => n1236, C => n1237, Z => n1222);
   U829 : AO1 port map( A => n1077, B => n1134, C => n1238, D => n1066, Z => 
                           n1237);
   U830 : NR2 port map( A => n1122, B => n1089, Z => n1066);
   U831 : NR2 port map( A => n1125, B => n1226, Z => n1238);
   U832 : MUX21L port map( A => n1053, B => n1239, S => n1089, Z => n1236);
   U833 : AO7 port map( A => n1132, B => n1169, C => n1191, Z => n1239);
   U834 : MUX21L port map( A => n1212, B => n1240, S => n1094, Z => n1235);
   U835 : ND2 port map( A => n1241, B => n1158, Z => n1240);
   U836 : MUX21L port map( A => n1160, B => n1202, S => n1133, Z => n1241);
   U837 : NR2 port map( A => n1123, B => n1160, Z => n1212);
   U838 : ND2 port map( A => n1100, B => n1242, Z => n1220);
   U839 : AO3 port map( A => n1123, B => n1140, C => n1243, D => n1244, Z => 
                           n1242);
   U840 : AO1 port map( A => n1205, B => n1170, C => n1245, D => n1246, Z => 
                           n1244);
   U841 : MUX21L port map( A => n1247, B => n1166, S => n1094, Z => n1245);
   U842 : ND2 port map( A => n1160, B => n1107, Z => n1247);
   U843 : AO2 port map( A => n1232, B => n1248, C => n1146, D => n1101, Z => 
                           n1243);
   U844 : NR2 port map( A => n1158, B => n1121, Z => n1146);
   U845 : ND2 port map( A => n1169, B => n1055, Z => n1248);
   U846 : IV port map( A => n1150, Z => n1055);
   U847 : NR2 port map( A => n1092, B => n1072, Z => n1150);
   U848 : IV port map( A => n1106, Z => n1140);
   U849 : NR2 port map( A => n1081, B => n1087, Z => n1106);
   U850 : NR4 port map( A => n1249, B => n1250, C => n1251, D => n1252, Z => 
                           n1218);
   U851 : OR3 port map( A => n1198, B => n1196, C => n1187, Z => n1252);
   U852 : AO4 port map( A => n1061, B => n1111, C => n1206, D => n1253, Z => 
                           n1250);
   U853 : EO1 port map( A => n1197, B => n1077, C => n1129, D => n1187, Z => 
                           n1253);
   U854 : NR2 port map( A => n1113, B => n1107, Z => n1187);
   U855 : AO3 port map( A => n1211, B => n1185, C => n1254, D => n1255, Z => 
                           n1249);
   U856 : MUX21L port map( A => n1161, B => n1256, S => n1234, Z => n1255);
   U857 : NR2 port map( A => n1065, B => n1123, Z => n1256);
   U858 : AO7 port map( A => n1257, B => n1258, C => n1119, Z => n1254);
   U859 : AO4 port map( A => n1158, B => n1226, C => n1169, D => n1229, Z => 
                           n1258);
   U860 : MUX21L port map( A => n1123, B => n1125, S => n1234, Z => n1257);
   U861 : ND2 port map( A => n1107, B => n1121, Z => n1185);
   U862 : AO3 port map( A => n1259, B => n1083, C => n1260, D => n1261, Z => 
                           N361);
   U863 : AO2 port map( A => n1100, B => n1262, C => n1114, D => n1263, Z => 
                           n1261);
   U864 : ND4 port map( A => n1264, B => n1265, C => n1266, D => n1267, Z => 
                           n1263);
   U865 : OR2 port map( A => n1117, B => n676, Z => n1267);
   U866 : ND2 port map( A => n1189, B => n1072, Z => n1117);
   U867 : IV port map( A => n1268, Z => n1266);
   U868 : AO4 port map( A => n1269, B => n1270, C => n1271, D => n1232, Z => 
                           n1268);
   U869 : AO6 port map( A => n1072, B => n1107, C => n1148, Z => n1271);
   U870 : ND2 port map( A => n1092, B => n1077, Z => n1269);
   U871 : MUX21L port map( A => n1272, B => n1273, S => n1229, Z => n1265);
   U872 : IV port map( A => n1196, Z => n1229);
   U873 : AO3 port map( A => n1092, B => n1129, C => n1088, D => n1274, Z => 
                           n1272);
   U874 : IV port map( A => n1147, Z => n1274);
   U875 : AO2 port map( A => n1161, B => n1206, C => n1155, D => n1101, Z => 
                           n1264);
   U876 : NR2 port map( A => n1275, B => n1092, Z => n1161);
   U877 : AO3 port map( A => n1276, B => n1158, C => n1277, D => n1278, Z => 
                           n1262);
   U878 : AO6 port map( A => n1205, B => n1234, C => n1279, Z => n1278);
   U879 : AO4 port map( A => n1169, B => n1230, C => n1280, D => N290, Z => 
                           n1279);
   U880 : AO1 port map( A => n1119, B => n1122, C => n1147, D => n1281, Z => 
                           n1280);
   U881 : NR2 port map( A => n1089, B => n1169, Z => n1281);
   U882 : NR2 port map( A => n1125, B => n1065, Z => n1147);
   U883 : EO1 port map( A => n1282, B => n1283, C => n1123, D => n1284, Z => 
                           n1277);
   U884 : AO6 port map( A => n1119, B => n1196, C => n1285, Z => n1284);
   U885 : IV port map( A => n1275, Z => n1283);
   U886 : NR2 port map( A => n1196, B => n1122, Z => n1282);
   U887 : AO6 port map( A => n1101, B => N290, C => n1286, Z => n1276);
   U888 : AO4 port map( A => n1206, B => n1198, C => n1232, D => n1081, Z => 
                           n1286);
   U889 : AO6 port map( A => n1207, B => n1287, C => n1074, Z => n1260);
   U890 : ND4 port map( A => n1288, B => n1111, C => n1289, D => n1290, Z => 
                           n1287);
   U891 : AO1 port map( A => n1077, B => n1053, C => n1291, D => n1292, Z => 
                           n1290);
   U892 : NR2 port map( A => n1160, B => n1088, Z => n1292);
   U893 : ND2 port map( A => n1107, B => n1089, Z => n1088);
   U894 : MUX21L port map( A => n1201, B => n1293, S => n1133, Z => n1291);
   U895 : ND2 port map( A => n1072, B => n1202, Z => n1293);
   U896 : AO2 port map( A => n1113, B => n1285, C => n1232, D => n1294, Z => 
                           n1289);
   U897 : AO7 port map( A => n1211, B => n1234, C => n1230, Z => n1285);
   U898 : IV port map( A => n1295, Z => n1230);
   U899 : ND2 port map( A => n1072, B => n1092, Z => n1111);
   U900 : AO7 port map( A => n1054, B => n1160, C => n1189, Z => n1288);
   U901 : AO1 port map( A => n1205, B => n676, C => n1296, D => n1297, Z => 
                           n1259);
   U902 : MUX21L port map( A => n1298, B => n1299, S => n1234, Z => n1297);
   U903 : ND2 port map( A => n1113, B => n1077, Z => n1299);
   U904 : AO6 port map( A => n1101, B => n1133, C => n1092, Z => n1298);
   U905 : AO4 port map( A => n1089, B => n1191, C => n1092, D => n1300, Z => 
                           n1296);
   U906 : AO1 port map( A => n1101, B => n1053, C => n1217, D => n1301, Z => 
                           n1300);
   U907 : NR2 port map( A => n1184, B => n1081, Z => n1301);
   U908 : MUX21L port map( A => n1234, B => n1087, S => n1133, Z => n1184);
   U909 : IV port map( A => n1155, Z => n1191);
   U910 : NR2 port map( A => n1125, B => n1087, Z => n1155);
   U911 : AO3 port map( A => n1302, B => n1219, C => n1303, D => n1304, Z => 
                           N360);
   U912 : AO1 port map( A => n1207, B => n1305, C => n1074, D => n1306, Z => 
                           n1304);
   U913 : AO6 port map( A => n1307, B => n1308, C => n1083, Z => n1306);
   U914 : ND2 port map( A => n1205, B => n1234, Z => n1308);
   U915 : MUX21L port map( A => n1309, B => n1092, S => N290, Z => n1307);
   U916 : NR2 port map( A => n1198, B => n1169, Z => n1309);
   U917 : IV port map( A => n1051, Z => n1074);
   U918 : ND3 port map( A => n1310, B => n1041, C => phase_o_8_port, Z => n1051
                           );
   U919 : ND4 port map( A => n1311, B => n1312, C => n1313, D => n1314, Z => 
                           n1305);
   U920 : AO2 port map( A => n1315, B => n1107, C => n1316, D => n1196, Z => 
                           n1314);
   U921 : NR2 port map( A => n1087, B => n676, Z => n1196);
   U922 : NR2 port map( A => n1129, B => n1169, Z => n1316);
   U923 : AO6 port map( A => n1232, B => n1089, C => n1160, Z => n1315);
   U924 : AO2 port map( A => n1206, B => n1148, C => n1200, D => n1270, Z => 
                           n1313);
   U925 : NR2 port map( A => n1211, B => n1092, Z => n1200);
   U926 : IV port map( A => n1077, Z => n1211);
   U927 : MUX21L port map( A => n1294, B => n1205, S => N290, Z => n1312);
   U928 : NR2 port map( A => n1125, B => n1198, Z => n1205);
   U929 : AO4 port map( A => n1054, B => n1125, C => n1092, D => n1081, Z => 
                           n1294);
   U930 : AO2 port map( A => n1092, B => n1317, C => n1112, D => n1065, Z => 
                           n1311);
   U931 : NR2 port map( A => n1170, B => n1125, Z => n1112);
   U932 : AO3 port map( A => n1061, B => n1129, C => n1275, D => n1318, Z => 
                           n1317);
   U933 : ND2 port map( A => n1160, B => n1089, Z => n1318);
   U934 : NR2 port map( A => n1050, B => n1052, Z => n1207);
   U935 : MUX21L port map( A => n1319, B => n1320, S => n1122, Z => n1303);
   U936 : AO7 port map( A => n1321, B => n1172, C => n1322, Z => n1320);
   U937 : MUX21L port map( A => n1323, B => n1324, S => n1270, Z => n1322);
   U938 : EN port map( A => n1134, B => N290, Z => n1270);
   U939 : NR2 port map( A => n1060, B => n1081, Z => n1324);
   U940 : NR2 port map( A => n1065, B => n1083, Z => n1323);
   U941 : IV port map( A => n1098, Z => n1083);
   U942 : NR2 port map( A => n1079, B => n1060, Z => n1098);
   U943 : NR4 port map( A => n1119, B => n1077, C => n1149, D => n1325, Z => 
                           n1321);
   U944 : MUX21L port map( A => n1061, B => n1326, S => n1094, Z => n1325);
   U945 : ND2 port map( A => n1160, B => n1133, Z => n1326);
   U946 : AO6 port map( A => n1327, B => n1328, C => n1172, Z => n1319);
   U947 : IV port map( A => n1100, Z => n1172);
   U948 : NR2 port map( A => n1052, B => n1060, Z => n1100);
   U949 : IV port map( A => n1079, Z => n1052);
   U950 : ND2 port map( A => n1077, B => n1053, Z => n1328);
   U951 : MUX21L port map( A => n1329, B => n1330, S => n1133, Z => n1327);
   U952 : ND2 port map( A => n1331, B => n1332, Z => n1330);
   U953 : MUX21L port map( A => n1072, B => n1077, S => n1234, Z => n1332);
   U954 : MUX21L port map( A => n1119, B => n1101, S => n1121, Z => n1331);
   U955 : AO4 port map( A => n1160, B => n1129, C => n1232, D => n1094, Z => 
                           n1329);
   U956 : IV port map( A => n1114, Z => n1219);
   U957 : NR2 port map( A => n1079, B => n1050, Z => n1114);
   U958 : IV port map( A => n1060, Z => n1050);
   U959 : NR2 port map( A => n1333, B => n1310, Z => n1060);
   U960 : MUX21L port map( A => phase_o_6_port, B => n1334, S => phase_o_8_port
                           , Z => n1333);
   U961 : ND2 port map( A => n1335, B => phase_o_6_port, Z => n1334);
   U962 : EO port map( A => phase_o_7_port, B => n1336, Z => n1079);
   U963 : NR2 port map( A => n1310, B => n1036, Z => n1336);
   U964 : NR2 port map( A => n1335, B => phase_o_6_port, Z => n1310);
   U965 : NR4 port map( A => n1337, B => n1246, C => n1295, D => n1338, Z => 
                           n1302);
   U966 : AO1 port map( A => n1170, B => n1061, C => n1198, D => n1092, Z => 
                           n1338);
   U967 : IV port map( A => n1053, Z => n1061);
   U968 : NR2 port map( A => n1133, B => n1121, Z => n1053);
   U969 : NR2 port map( A => n1226, B => n1129, Z => n1295);
   U970 : IV port map( A => n1206, Z => n1226);
   U971 : NR2 port map( A => n1121, B => N290, Z => n1206);
   U972 : AO4 port map( A => n1158, B => n1201, C => n1275, D => n1339, Z => 
                           n1246);
   U973 : ND2 port map( A => n1092, B => n1170, Z => n1339);
   U974 : IV port map( A => n1160, Z => n1170);
   U975 : ND2 port map( A => n1340, B => n1054, Z => n1275);
   U976 : EN port map( A => n1065, B => n1134, Z => n1340);
   U977 : IV port map( A => n1217, Z => n1201);
   U978 : NR2 port map( A => n1198, B => n1087, Z => n1217);
   U979 : IV port map( A => n1072, Z => n1198);
   U980 : NR2 port map( A => n1089, B => n1094, Z => n1072);
   U981 : IV port map( A => n1107, Z => n1158);
   U982 : NR2 port map( A => n1122, B => n1134, Z => n1107);
   U983 : AO3 port map( A => n1341, B => n1234, C => n1342, D => n1343, Z => 
                           n1337);
   U984 : AO2 port map( A => n1148, B => N290, C => n1077, D => n1344, Z => 
                           n1343);
   U985 : ND2 port map( A => n1345, B => n1166, Z => n1344);
   U986 : IV port map( A => n1073, Z => n1166);
   U987 : NR2 port map( A => n1080, B => n1122, Z => n1073);
   U988 : IV port map( A => n1149, Z => n1080);
   U989 : NR2 port map( A => n1132, B => n1133, Z => n1149);
   U990 : IV port map( A => n1202, Z => n1132);
   U991 : MUX21L port map( A => n1197, B => n1113, S => n1234, Z => n1345);
   U992 : NR2 port map( A => n1089, B => n1065, Z => n1077);
   U993 : IV port map( A => n1054, Z => n1089);
   U994 : NR2 port map( A => n1169, B => n1094, Z => n1148);
   U995 : IV port map( A => n1113, Z => n1169);
   U996 : NR2 port map( A => n1092, B => n1134, Z => n1113);
   U997 : IV port map( A => n1251, Z => n1342);
   U998 : OR3 port map( A => N290, B => n1129, C => n1125, Z => n1251);
   U999 : IV port map( A => n1101, Z => n1129);
   U1000 : NR2 port map( A => n1065, B => n1054, Z => n1101);
   U1001 : IV port map( A => n1094, Z => n1065);
   U1002 : IV port map( A => n1232, Z => n1234);
   U1003 : NR2 port map( A => n1202, B => n1160, Z => n1232);
   U1004 : NR2 port map( A => N290, B => n1087, Z => n1160);
   U1005 : IV port map( A => n1121, Z => n1087);
   U1006 : NR2 port map( A => n1121, B => n676, Z => n1202);
   U1007 : ND2 port map( A => n1346, B => n1347, Z => n1121);
   U1008 : MUX21L port map( A => n1348, B => n1040, S => n1036, Z => n1346);
   U1009 : NR2 port map( A => n676, B => n1040, Z => n1348);
   U1010 : AO6 port map( A => n1119, B => n1092, C => n1273, Z => n1341);
   U1011 : AO4 port map( A => n1081, B => n1125, C => n1054, D => n1123, Z => 
                           n1273);
   U1012 : IV port map( A => n1189, Z => n1123);
   U1013 : NR2 port map( A => n1122, B => n1133, Z => n1189);
   U1014 : IV port map( A => n1197, Z => n1125);
   U1015 : NR2 port map( A => n1133, B => n1092, Z => n1197);
   U1016 : IV port map( A => n1134, Z => n1133);
   U1017 : NR2 port map( A => n1349, B => n1350, Z => n1134);
   U1018 : MUX21L port map( A => phase_o_2_port, B => n1351, S => 
                           phase_o_8_port, Z => n1349);
   U1019 : ND2 port map( A => n1347, B => phase_o_2_port, Z => n1351);
   U1020 : IV port map( A => n1119, Z => n1081);
   U1021 : IV port map( A => n1122, Z => n1092);
   U1022 : ND2 port map( A => n1352, B => n1335, Z => n1122);
   U1023 : ND2 port map( A => n1353, B => n1038, Z => n1335);
   U1024 : MUX21L port map( A => n1354, B => n1038, S => n1036, Z => n1352);
   U1025 : NR2 port map( A => n1353, B => n1038, Z => n1354);
   U1026 : NR2 port map( A => n1094, B => n1054, Z => n1119);
   U1027 : NR2 port map( A => n1355, B => n1353, Z => n1054);
   U1028 : NR2 port map( A => n1356, B => phase_o_4_port, Z => n1353);
   U1029 : MUX21L port map( A => phase_o_4_port, B => n1357, S => 
                           phase_o_8_port, Z => n1355);
   U1030 : ND2 port map( A => n1356, B => phase_o_4_port, Z => n1357);
   U1031 : ND2 port map( A => n1358, B => n1356, Z => n1094);
   U1032 : ND2 port map( A => n1350, B => n1039, Z => n1356);
   U1033 : MUX21L port map( A => n1359, B => n1039, S => n1036, Z => n1358);
   U1034 : NR2 port map( A => n1350, B => n1039, Z => n1359);
   U1035 : NR2 port map( A => n1347, B => phase_o_2_port, Z => n1350);
   U1036 : ND2 port map( A => n676, B => n1040, Z => n1347);

end SYN_dds_synthesizer_arch;
