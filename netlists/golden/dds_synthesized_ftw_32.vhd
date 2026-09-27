
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

   component EO
      port( A, B : in std_logic;  Z : out std_logic);
   end component;
   
   component EN
      port( A, B : in std_logic;  Z : out std_logic);
   end component;
   
   component AN2
      port( A, B : in std_logic;  Z : out std_logic);
   end component;
   
   component OR2
      port( A, B : in std_logic;  Z : out std_logic);
   end component;
   
   component AO2
      port( A, B, C, D : in std_logic;  Z : out std_logic);
   end component;
   
   component AO4
      port( A, B, C, D : in std_logic;  Z : out std_logic);
   end component;
   
   component IVI
      port( A : in std_logic;  Z : out std_logic);
   end component;
   
   signal n1, n2, n3, n4, n5, n6, n7, n8, n9, n10, n11, n12, n13, n14, n15, n16
      , n17, n18, n19, n20, n21, n22, n23, n24, n25, n26, n27, n28, n29, n30, 
      n31, n32, n33, n34, n35, n36, n37, n38, n39, n40, n41, n42, n43, n44, n45
      , n46, n47, n48, n49, n50, n51, n52, n53, n54, n55, n56, n57, n58, n59, 
      n60, n61, n62, n63, n64, n65, n66, n67, n68, n69, n70, n71, n72, n73, n74
      , n75, n76, n77, n78, n79, n80, n81, n82, n83, n84, n85, n86, n87, n88, 
      n89, n90, n91, n92, n93, n94, n95, n96, n97, n98, n99, n100, n101, n102, 
      n103, n104, n105, n106, n107, n108, n109, n110, n111, n112, n113, n114, 
      n115, n116, n117, n118, n119, n120, n121 : std_logic;

begin
   
   U1 : IVI port map( A => n47, Z => n1);
   U2 : IVI port map( A => n50, Z => n2);
   U3 : IVI port map( A => n55, Z => n3);
   U4 : IVI port map( A => n58, Z => n4);
   U5 : IVI port map( A => n61, Z => n5);
   U6 : IVI port map( A => n64, Z => n6);
   U7 : IVI port map( A => n67, Z => n7);
   U8 : IVI port map( A => n70, Z => n8);
   U9 : IVI port map( A => n73, Z => n9);
   U10 : IVI port map( A => n76, Z => n10);
   U11 : IVI port map( A => n79, Z => n11);
   U12 : IVI port map( A => n82, Z => n12);
   U13 : IVI port map( A => n87, Z => n13);
   U14 : IVI port map( A => n90, Z => n14);
   U15 : IVI port map( A => n93, Z => n15);
   U16 : IVI port map( A => n96, Z => n16);
   U17 : IVI port map( A => n99, Z => n17);
   U18 : IVI port map( A => n102, Z => n18);
   U19 : IVI port map( A => n105, Z => n19);
   U20 : IVI port map( A => n108, Z => n20);
   U21 : IVI port map( A => n111, Z => n21);
   U22 : IVI port map( A => B(8), Z => n22);
   U23 : IVI port map( A => n35, Z => n23);
   U24 : IVI port map( A => n37, Z => n24);
   U25 : IVI port map( A => n39, Z => n25);
   U26 : IVI port map( A => n41, Z => n26);
   U27 : IVI port map( A => n43, Z => n27);
   U28 : IVI port map( A => n52, Z => n28);
   U29 : IVI port map( A => A(8), Z => n29);
   U30 : EN port map( A => n30, B => n31, Z => SUM(9));
   U31 : EN port map( A => A(9), B => B(9), Z => n30);
   U32 : EO port map( A => n32, B => n33, Z => SUM(8));
   U33 : EO port map( A => n29, B => B(8), Z => n32);
   U34 : EO port map( A => n34, B => n35, Z => SUM(7));
   U35 : EN port map( A => A(7), B => B(7), Z => n34);
   U36 : EO port map( A => n36, B => n37, Z => SUM(6));
   U37 : EN port map( A => A(6), B => B(6), Z => n36);
   U38 : EO port map( A => n38, B => n39, Z => SUM(5));
   U39 : EN port map( A => A(5), B => B(5), Z => n38);
   U40 : EO port map( A => n40, B => n41, Z => SUM(4));
   U41 : EN port map( A => A(4), B => B(4), Z => n40);
   U42 : EO port map( A => n42, B => n43, Z => SUM(3));
   U43 : EN port map( A => A(3), B => B(3), Z => n42);
   U44 : EO port map( A => n44, B => n45, Z => SUM(31));
   U45 : AO2 port map( A => B(30), B => n46, C => A(30), D => n1, Z => n45);
   U46 : OR2 port map( A => n1, B => A(30), Z => n46);
   U47 : EN port map( A => B(31), B => A(31), Z => n44);
   U48 : EO port map( A => n48, B => n47, Z => SUM(30));
   U49 : AO2 port map( A => n2, B => A(29), C => n49, D => B(29), Z => n47);
   U50 : OR2 port map( A => A(29), B => n2, Z => n49);
   U51 : EN port map( A => A(30), B => B(30), Z => n48);
   U52 : EO port map( A => n51, B => n52, Z => SUM(2));
   U53 : EN port map( A => A(2), B => B(2), Z => n51);
   U54 : EO port map( A => n53, B => n50, Z => SUM(29));
   U55 : AO2 port map( A => n3, B => A(28), C => n54, D => B(28), Z => n50);
   U56 : OR2 port map( A => A(28), B => n3, Z => n54);
   U57 : EN port map( A => A(29), B => B(29), Z => n53);
   U58 : EO port map( A => n56, B => n55, Z => SUM(28));
   U59 : AO2 port map( A => n4, B => A(27), C => n57, D => B(27), Z => n55);
   U60 : OR2 port map( A => A(27), B => n4, Z => n57);
   U61 : EN port map( A => A(28), B => B(28), Z => n56);
   U62 : EO port map( A => n59, B => n58, Z => SUM(27));
   U63 : AO2 port map( A => n5, B => A(26), C => n60, D => B(26), Z => n58);
   U64 : OR2 port map( A => A(26), B => n5, Z => n60);
   U65 : EN port map( A => A(27), B => B(27), Z => n59);
   U66 : EO port map( A => n62, B => n61, Z => SUM(26));
   U67 : AO2 port map( A => n6, B => A(25), C => n63, D => B(25), Z => n61);
   U68 : OR2 port map( A => A(25), B => n6, Z => n63);
   U69 : EN port map( A => A(26), B => B(26), Z => n62);
   U70 : EO port map( A => n65, B => n64, Z => SUM(25));
   U71 : AO2 port map( A => n7, B => A(24), C => n66, D => B(24), Z => n64);
   U72 : OR2 port map( A => A(24), B => n7, Z => n66);
   U73 : EN port map( A => A(25), B => B(25), Z => n65);
   U74 : EO port map( A => n68, B => n67, Z => SUM(24));
   U75 : AO2 port map( A => n8, B => A(23), C => n69, D => B(23), Z => n67);
   U76 : OR2 port map( A => A(23), B => n8, Z => n69);
   U77 : EN port map( A => A(24), B => B(24), Z => n68);
   U78 : EO port map( A => n71, B => n70, Z => SUM(23));
   U79 : AO2 port map( A => n9, B => A(22), C => n72, D => B(22), Z => n70);
   U80 : OR2 port map( A => A(22), B => n9, Z => n72);
   U81 : EN port map( A => A(23), B => B(23), Z => n71);
   U82 : EO port map( A => n74, B => n73, Z => SUM(22));
   U83 : AO2 port map( A => n10, B => A(21), C => n75, D => B(21), Z => n73);
   U84 : OR2 port map( A => A(21), B => n10, Z => n75);
   U85 : EN port map( A => A(22), B => B(22), Z => n74);
   U86 : EO port map( A => n77, B => n76, Z => SUM(21));
   U87 : AO2 port map( A => n11, B => A(20), C => n78, D => B(20), Z => n76);
   U88 : OR2 port map( A => A(20), B => n11, Z => n78);
   U89 : EN port map( A => A(21), B => B(21), Z => n77);
   U90 : EO port map( A => n80, B => n79, Z => SUM(20));
   U91 : AO2 port map( A => n12, B => A(19), C => n81, D => B(19), Z => n79);
   U92 : OR2 port map( A => A(19), B => n12, Z => n81);
   U93 : EN port map( A => A(20), B => B(20), Z => n80);
   U94 : EO port map( A => n83, B => n84, Z => SUM(1));
   U95 : EO port map( A => B(1), B => A(1), Z => n84);
   U96 : EO port map( A => n85, B => n82, Z => SUM(19));
   U97 : AO2 port map( A => n13, B => A(18), C => n86, D => B(18), Z => n82);
   U98 : OR2 port map( A => A(18), B => n13, Z => n86);
   U99 : EN port map( A => A(19), B => B(19), Z => n85);
   U100 : EO port map( A => n88, B => n87, Z => SUM(18));
   U101 : AO2 port map( A => n14, B => A(17), C => n89, D => B(17), Z => n87);
   U102 : OR2 port map( A => A(17), B => n14, Z => n89);
   U103 : EN port map( A => A(18), B => B(18), Z => n88);
   U104 : EO port map( A => n91, B => n90, Z => SUM(17));
   U105 : AO2 port map( A => n15, B => A(16), C => n92, D => B(16), Z => n90);
   U106 : OR2 port map( A => A(16), B => n15, Z => n92);
   U107 : EN port map( A => A(17), B => B(17), Z => n91);
   U108 : EO port map( A => n94, B => n93, Z => SUM(16));
   U109 : AO2 port map( A => n16, B => A(15), C => n95, D => B(15), Z => n93);
   U110 : OR2 port map( A => A(15), B => n16, Z => n95);
   U111 : EN port map( A => A(16), B => B(16), Z => n94);
   U112 : EO port map( A => n97, B => n96, Z => SUM(15));
   U113 : AO2 port map( A => n17, B => A(14), C => n98, D => B(14), Z => n96);
   U114 : OR2 port map( A => A(14), B => n17, Z => n98);
   U115 : EN port map( A => A(15), B => B(15), Z => n97);
   U116 : EO port map( A => n100, B => n99, Z => SUM(14));
   U117 : AO2 port map( A => n18, B => A(13), C => n101, D => B(13), Z => n99);
   U118 : OR2 port map( A => A(13), B => n18, Z => n101);
   U119 : EN port map( A => A(14), B => B(14), Z => n100);
   U120 : EO port map( A => n103, B => n102, Z => SUM(13));
   U121 : AO2 port map( A => n19, B => A(12), C => n104, D => B(12), Z => n102)
                           ;
   U122 : OR2 port map( A => A(12), B => n19, Z => n104);
   U123 : EN port map( A => A(13), B => B(13), Z => n103);
   U124 : EO port map( A => n106, B => n105, Z => SUM(12));
   U125 : AO2 port map( A => n20, B => A(11), C => n107, D => B(11), Z => n105)
                           ;
   U126 : OR2 port map( A => A(11), B => n20, Z => n107);
   U127 : EN port map( A => A(12), B => B(12), Z => n106);
   U128 : EO port map( A => n109, B => n108, Z => SUM(11));
   U129 : AO2 port map( A => n21, B => A(10), C => n110, D => B(10), Z => n108)
                           ;
   U130 : OR2 port map( A => A(10), B => n21, Z => n110);
   U131 : EN port map( A => A(11), B => B(11), Z => n109);
   U132 : EO port map( A => n112, B => n111, Z => SUM(10));
   U133 : AO2 port map( A => n31, B => A(9), C => n113, D => B(9), Z => n111);
   U134 : OR2 port map( A => A(9), B => n31, Z => n113);
   U135 : AO4 port map( A => n33, B => n29, C => n114, D => n22, Z => n31);
   U136 : AN2 port map( A => n29, B => n33, Z => n114);
   U137 : AO2 port map( A => n23, B => A(7), C => n115, D => B(7), Z => n33);
   U138 : OR2 port map( A => A(7), B => n23, Z => n115);
   U139 : AO2 port map( A => n24, B => A(6), C => n116, D => B(6), Z => n35);
   U140 : OR2 port map( A => A(6), B => n24, Z => n116);
   U141 : AO2 port map( A => n25, B => A(5), C => n117, D => B(5), Z => n37);
   U142 : OR2 port map( A => A(5), B => n25, Z => n117);
   U143 : AO2 port map( A => n26, B => A(4), C => n118, D => B(4), Z => n39);
   U144 : OR2 port map( A => A(4), B => n26, Z => n118);
   U145 : AO2 port map( A => n27, B => A(3), C => n119, D => B(3), Z => n41);
   U146 : OR2 port map( A => A(3), B => n27, Z => n119);
   U147 : AO2 port map( A => n28, B => A(2), C => n120, D => B(2), Z => n43);
   U148 : OR2 port map( A => A(2), B => n28, Z => n120);
   U149 : AO2 port map( A => n83, B => A(1), C => n121, D => B(1), Z => n52);
   U150 : OR2 port map( A => n83, B => A(1), Z => n121);
   U151 : AN2 port map( A => B(0), B => A(0), Z => n83);
   U152 : EN port map( A => A(10), B => B(10), Z => n112);
   U153 : EO port map( A => B(0), B => A(0), Z => SUM(0));

end SYN_rpl;

library IEEE;

use IEEE.std_logic_1164.all;

use work.CONV_PACK_dds_synthesizer_ftw_width32.all;

entity dds_synthesizer_ftw_width32_DW01_add_0 is

   port( A, B : in std_logic_vector (9 downto 0);  CI : in std_logic;  SUM : 
         out std_logic_vector (9 downto 0);  CO : out std_logic);

end dds_synthesizer_ftw_width32_DW01_add_0;

architecture SYN_rpl of dds_synthesizer_ftw_width32_DW01_add_0 is

   component EO
      port( A, B : in std_logic;  Z : out std_logic);
   end component;
   
   component AN2
      port( A, B : in std_logic;  Z : out std_logic);
   end component;
   
   component EN
      port( A, B : in std_logic;  Z : out std_logic);
   end component;
   
   component OR2
      port( A, B : in std_logic;  Z : out std_logic);
   end component;
   
   component AO2
      port( A, B, C, D : in std_logic;  Z : out std_logic);
   end component;
   
   component IVI
      port( A : in std_logic;  Z : out std_logic);
   end component;
   
   signal n1, n2, n3, n4, n5, n6, n7, n8, n9, n10, n11, n12, n13, n14, n15, n16
      , n17, n18, n19, n20, n21, n22, n23, n24, n25, n26, n27, n28, n29, n30, 
      n31, n32, n33 : std_logic;

begin
   
   U1 : IVI port map( A => n11, Z => n1);
   U2 : IVI port map( A => n14, Z => n2);
   U3 : IVI port map( A => n17, Z => n3);
   U4 : IVI port map( A => n20, Z => n4);
   U5 : IVI port map( A => n23, Z => n5);
   U6 : IVI port map( A => n26, Z => n6);
   U7 : IVI port map( A => n29, Z => n7);
   U8 : EO port map( A => n8, B => n9, Z => SUM(9));
   U9 : AO2 port map( A => B(8), B => n10, C => A(8), D => n1, Z => n9);
   U10 : OR2 port map( A => n1, B => A(8), Z => n10);
   U11 : EN port map( A => B(9), B => A(9), Z => n8);
   U12 : EO port map( A => n12, B => n11, Z => SUM(8));
   U13 : AO2 port map( A => n2, B => A(7), C => n13, D => B(7), Z => n11);
   U14 : OR2 port map( A => A(7), B => n2, Z => n13);
   U15 : EN port map( A => A(8), B => B(8), Z => n12);
   U16 : EO port map( A => n15, B => n14, Z => SUM(7));
   U17 : AO2 port map( A => n3, B => A(6), C => n16, D => B(6), Z => n14);
   U18 : OR2 port map( A => A(6), B => n3, Z => n16);
   U19 : EN port map( A => A(7), B => B(7), Z => n15);
   U20 : EO port map( A => n18, B => n17, Z => SUM(6));
   U21 : AO2 port map( A => n4, B => A(5), C => n19, D => B(5), Z => n17);
   U22 : OR2 port map( A => A(5), B => n4, Z => n19);
   U23 : EN port map( A => A(6), B => B(6), Z => n18);
   U24 : EO port map( A => n21, B => n20, Z => SUM(5));
   U25 : AO2 port map( A => n5, B => A(4), C => n22, D => B(4), Z => n20);
   U26 : OR2 port map( A => A(4), B => n5, Z => n22);
   U27 : EN port map( A => A(5), B => B(5), Z => n21);
   U28 : EO port map( A => n24, B => n23, Z => SUM(4));
   U29 : AO2 port map( A => n6, B => A(3), C => n25, D => B(3), Z => n23);
   U30 : OR2 port map( A => A(3), B => n6, Z => n25);
   U31 : EN port map( A => A(4), B => B(4), Z => n24);
   U32 : EO port map( A => n27, B => n26, Z => SUM(3));
   U33 : AO2 port map( A => n7, B => A(2), C => n28, D => B(2), Z => n26);
   U34 : OR2 port map( A => A(2), B => n7, Z => n28);
   U35 : EN port map( A => A(3), B => B(3), Z => n27);
   U36 : EO port map( A => n30, B => n29, Z => SUM(2));
   U37 : AO2 port map( A => n31, B => A(1), C => n32, D => B(1), Z => n29);
   U38 : OR2 port map( A => n31, B => A(1), Z => n32);
   U39 : EN port map( A => A(2), B => B(2), Z => n30);
   U40 : EO port map( A => n31, B => n33, Z => SUM(1));
   U41 : EO port map( A => B(1), B => A(1), Z => n33);
   U42 : AN2 port map( A => B(0), B => A(0), Z => n31);
   U43 : EO port map( A => B(0), B => A(0), Z => SUM(0));

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
   
   component ND3
      port( A, B, C : in std_logic;  Z : out std_logic);
   end component;
   
   component AO6
      port( A, B, C : in std_logic;  Z : out std_logic);
   end component;
   
   component NR4
      port( A, B, C, D : in std_logic;  Z : out std_logic);
   end component;
   
   component EO
      port( A, B : in std_logic;  Z : out std_logic);
   end component;
   
   component AO1
      port( A, B, C, D : in std_logic;  Z : out std_logic);
   end component;
   
   component AN3
      port( A, B, C : in std_logic;  Z : out std_logic);
   end component;
   
   component AO7
      port( A, B, C : in std_logic;  Z : out std_logic);
   end component;
   
   component AO2
      port( A, B, C, D : in std_logic;  Z : out std_logic);
   end component;
   
   component NR3
      port( A, B, C : in std_logic;  Z : out std_logic);
   end component;
   
   component OR3
      port( A, B, C : in std_logic;  Z : out std_logic);
   end component;
   
   component AO3
      port( A, B, C, D : in std_logic;  Z : out std_logic);
   end component;
   
   component AO4
      port( A, B, C, D : in std_logic;  Z : out std_logic);
   end component;
   
   component EO1
      port( A, B, C, D : in std_logic;  Z : out std_logic);
   end component;
   
   component AN2
      port( A, B : in std_logic;  Z : out std_logic);
   end component;
   
   component MUX31L
      port( D0, D1, D2, A, B : in std_logic;  Z : out std_logic);
   end component;
   
   component MUX21H
      port( A, B, S : in std_logic;  Z : out std_logic);
   end component;
   
   component ND4
      port( A, B, C, D : in std_logic;  Z : out std_logic);
   end component;
   
   component OR2
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
      phase_o_1_port, N290, quadrant_3_or_4_2delay, ftw_accu_31_port, 
      ftw_accu_30_port, ftw_accu_29_port, ftw_accu_28_port, ftw_accu_27_port, 
      ftw_accu_26_port, ftw_accu_25_port, ftw_accu_24_port, ftw_accu_23_port, 
      ftw_accu_22_port, ftw_accu_21_port, ftw_accu_20_port, ftw_accu_19_port, 
      ftw_accu_18_port, ftw_accu_17_port, ftw_accu_16_port, ftw_accu_15_port, 
      ftw_accu_14_port, ftw_accu_13_port, ftw_accu_12_port, ftw_accu_11_port, 
      ftw_accu_10_port, ftw_accu_9_port, ftw_accu_8_port, ftw_accu_7_port, 
      ftw_accu_6_port, ftw_accu_5_port, ftw_accu_4_port, ftw_accu_3_port, 
      ftw_accu_2_port, ftw_accu_1_port, ftw_accu_0_port, lut_out_8_port, 
      lut_out_7_port, lut_out_6_port, lut_out_5_port, lut_out_4_port, 
      lut_out_3_port, lut_out_2_port, lut_out_1_port, quadrant_3_or_4_delay, 
      N299, N300, N301, N302, N303, N304, N305, N306, N307, N308, N309, N310, 
      N311, N312, N313, N314, N315, N316, N317, N318, N319, N320, N321, N322, 
      N323, N324, N325, N326, N327, N328, N329, N330, N331, N332, N333, N334, 
      N335, N336, N337, N338, N339, N340, N360, N361, N362, N363, N364, N365, 
      N366, N367, N368, N370, N371, N372, N373, N374, N375, N376, N377, N378, 
      N379, n3, n4, n321_port, n322_port, n323_port, n324_port, n325_port, 
      n326_port, n327_port, n328_port, n329_port, n330_port, n331_port, 
      n332_port, n333_port, n334_port, n335_port, n336_port, n337_port, 
      n338_port, n339_port, n340_port, n341, n342, n343, n344, n345, n346, n347
      , n348, n349, n350, n351, n352, n353, n354, n355, n356, n357, n358, n359,
      n360_port, n361_port, n362_port, n363_port, n364_port, n365_port, 
      n366_port, n367_port, n368_port, n369, n370_port, n371_port, n372_port, 
      n373_port, n374_port, n375_port, n376_port, n377_port, n378_port, 
      n379_port, n380, n381, n382, n383, n384, n385, n386, n387, n388, n389, 
      n390, n391, n392, n393, n394, n395, n396, n397, n398, n399, n400, n401, 
      n402, n403, n404, n405, n406, n407, n408, n409, n410, n411, n412, n413, 
      n414, n415, n416, n417, n418, n419, n420, n421, n422, n423, n424, n425, 
      n426, n427, n428, n429, n430, n431, n432, n433, n434, n435, n436, n437, 
      n438, n439, n440, n441, n442, n443, n444, n445, n446, n447, n448, n449, 
      n450, n451, n452, n453, n454, n455, n456, n457, n458, n459, n460, n461, 
      n462, n463, n464, n465, n466, n467, n468, n469, n470, n471, n472, n473, 
      n474, n475, n476, n477, n478, n479, n480, n481, n482, n483, n484, n485, 
      n486, n487, n488, n489, n490, n491, n492, n493, n494, n495, n496, n497, 
      n498, n499, n500, n501, n502, n503, n504, n505, n506, n507, n508, n509, 
      n510, n511, n512, n513, n514, n515, n516, n517, n518, n519, n520, n521, 
      n522, n523, n524, n525, n526, n527, n528, n529, n530, n531, n532, n533, 
      n534, n535, n536, n537, n538, n539, n540, n541, n542, n543, n544, n545, 
      n546, n547, n548, n549, n550, n551, n552, n553, n554, n555, n556, n557, 
      n558, n559, n560, n561, n562, n563, n564, n565, n566, n567, n568, n569, 
      n570, n571, n572, n573, n574, n575, n576, n577, n578, n579, n580, n581, 
      n582, n583, n584, n585, n586, n587, n588, n589, n590, n591, n592, n593, 
      n594, n595, n596, n597, n598, n599, n600, n601, n602, n603, n604, n605, 
      n606, n607, n608, n609, n610, n611, n612, n613, n614, n615, n616, n617, 
      n618, n619, n620, n621, n622, n623, n624, n625, n626, n627, n628, n629, 
      n630, n631, n632, n633, n634, n635, n636, n637, n638, n639, n640, n641, 
      n642, n643, n644, n645, n646, n647, n648, n649, n650, n651, n652, n653, 
      n654, n655, n656, n657, n658, n659, n660, n661, n662, n663, n664, n665, 
      n666, n667, n668, n669, n670, n671, n672, n673, n674, n675, n676, n677, 
      n_1004, n_1005, n_1006, n_1007, n_1008, n_1009, n_1010, n_1011, n_1012, 
      n_1013, n_1014, n_1015, n_1016, n_1017, n_1018, n_1019, n_1020, n_1021, 
      n_1022, n_1023, n_1024, n_1025, n_1026, n_1027, n_1028, n_1029, n_1030, 
      n_1031, n_1032, n_1033, n_1034, n_1035, n_1036, n_1037, n_1038, n_1039, 
      n_1040, n_1041, n_1042, n_1043, n_1044, n_1045, n_1046, n_1047, n_1048, 
      n_1049, n_1050, n_1051, n_1052, n_1053, n_1054, n_1055, n_1056, n_1057, 
      n_1058, n_1059, n_1060, n_1061, n_1062, n_1063, n_1064 : std_logic;

begin
   phase_o <= ( phase_o_9_port, phase_o_8_port, phase_o_7_port, phase_o_6_port,
      phase_o_5_port, phase_o_4_port, phase_o_3_port, phase_o_2_port, 
      phase_o_1_port, N290 );
   
   n3 <= '0';
   n4 <= '0';
   ftw_accu_reg_0_inst : FD2 port map( D => N299, CP => clk_i, CD => n677, Q =>
                           ftw_accu_0_port, QN => n_1004);
   ftw_accu_reg_1_inst : FD2 port map( D => N300, CP => clk_i, CD => n677, Q =>
                           ftw_accu_1_port, QN => n_1005);
   ftw_accu_reg_2_inst : FD2 port map( D => N301, CP => clk_i, CD => n677, Q =>
                           ftw_accu_2_port, QN => n_1006);
   ftw_accu_reg_3_inst : FD2 port map( D => N302, CP => clk_i, CD => n677, Q =>
                           ftw_accu_3_port, QN => n_1007);
   ftw_accu_reg_4_inst : FD2 port map( D => N303, CP => clk_i, CD => n677, Q =>
                           ftw_accu_4_port, QN => n_1008);
   ftw_accu_reg_5_inst : FD2 port map( D => N304, CP => clk_i, CD => n677, Q =>
                           ftw_accu_5_port, QN => n_1009);
   ftw_accu_reg_6_inst : FD2 port map( D => N305, CP => clk_i, CD => n677, Q =>
                           ftw_accu_6_port, QN => n_1010);
   ftw_accu_reg_7_inst : FD2 port map( D => N306, CP => clk_i, CD => n677, Q =>
                           ftw_accu_7_port, QN => n_1011);
   ftw_accu_reg_8_inst : FD2 port map( D => N307, CP => clk_i, CD => n677, Q =>
                           ftw_accu_8_port, QN => n_1012);
   ftw_accu_reg_9_inst : FD2 port map( D => N308, CP => clk_i, CD => n677, Q =>
                           ftw_accu_9_port, QN => n_1013);
   ftw_accu_reg_10_inst : FD2 port map( D => N309, CP => clk_i, CD => n677, Q 
                           => ftw_accu_10_port, QN => n_1014);
   ftw_accu_reg_11_inst : FD2 port map( D => N310, CP => clk_i, CD => n677, Q 
                           => ftw_accu_11_port, QN => n_1015);
   ftw_accu_reg_12_inst : FD2 port map( D => N311, CP => clk_i, CD => n677, Q 
                           => ftw_accu_12_port, QN => n_1016);
   ftw_accu_reg_13_inst : FD2 port map( D => N312, CP => clk_i, CD => n677, Q 
                           => ftw_accu_13_port, QN => n_1017);
   ftw_accu_reg_14_inst : FD2 port map( D => N313, CP => clk_i, CD => n677, Q 
                           => ftw_accu_14_port, QN => n_1018);
   ftw_accu_reg_15_inst : FD2 port map( D => N314, CP => clk_i, CD => n677, Q 
                           => ftw_accu_15_port, QN => n_1019);
   ftw_accu_reg_16_inst : FD2 port map( D => N315, CP => clk_i, CD => n677, Q 
                           => ftw_accu_16_port, QN => n_1020);
   ftw_accu_reg_17_inst : FD2 port map( D => N316, CP => clk_i, CD => n677, Q 
                           => ftw_accu_17_port, QN => n_1021);
   ftw_accu_reg_18_inst : FD2 port map( D => N317, CP => clk_i, CD => n677, Q 
                           => ftw_accu_18_port, QN => n_1022);
   ftw_accu_reg_19_inst : FD2 port map( D => N318, CP => clk_i, CD => n677, Q 
                           => ftw_accu_19_port, QN => n_1023);
   ftw_accu_reg_20_inst : FD2 port map( D => N319, CP => clk_i, CD => n677, Q 
                           => ftw_accu_20_port, QN => n_1024);
   ftw_accu_reg_21_inst : FD2 port map( D => N320, CP => clk_i, CD => n677, Q 
                           => ftw_accu_21_port, QN => n_1025);
   ftw_accu_reg_22_inst : FD2 port map( D => N321, CP => clk_i, CD => n677, Q 
                           => ftw_accu_22_port, QN => n_1026);
   ftw_accu_reg_23_inst : FD2 port map( D => N322, CP => clk_i, CD => n677, Q 
                           => ftw_accu_23_port, QN => n_1027);
   ftw_accu_reg_24_inst : FD2 port map( D => N323, CP => clk_i, CD => n677, Q 
                           => ftw_accu_24_port, QN => n_1028);
   ftw_accu_reg_25_inst : FD2 port map( D => N324, CP => clk_i, CD => n677, Q 
                           => ftw_accu_25_port, QN => n_1029);
   ftw_accu_reg_26_inst : FD2 port map( D => N325, CP => clk_i, CD => n677, Q 
                           => ftw_accu_26_port, QN => n_1030);
   ftw_accu_reg_27_inst : FD2 port map( D => N326, CP => clk_i, CD => n677, Q 
                           => ftw_accu_27_port, QN => n_1031);
   ftw_accu_reg_28_inst : FD2 port map( D => N327, CP => clk_i, CD => n677, Q 
                           => ftw_accu_28_port, QN => n_1032);
   ftw_accu_reg_29_inst : FD2 port map( D => N328, CP => clk_i, CD => n677, Q 
                           => ftw_accu_29_port, QN => n_1033);
   ftw_accu_reg_30_inst : FD2 port map( D => N329, CP => clk_i, CD => n677, Q 
                           => ftw_accu_30_port, QN => n_1034);
   ftw_accu_reg_31_inst : FD2 port map( D => N330, CP => clk_i, CD => n677, Q 
                           => ftw_accu_31_port, QN => n_1035);
   phase_reg_9_inst : FD2 port map( D => N340, CP => clk_i, CD => n677, Q => 
                           phase_o_9_port, QN => n_1036);
   phase_reg_8_inst : FD2 port map( D => N339, CP => clk_i, CD => n677, Q => 
                           phase_o_8_port, QN => n321_port);
   phase_reg_7_inst : FD2 port map( D => N338, CP => clk_i, CD => n677, Q => 
                           phase_o_7_port, QN => n325_port);
   phase_reg_6_inst : FD2 port map( D => N337, CP => clk_i, CD => n677, Q => 
                           phase_o_6_port, QN => n_1037);
   phase_reg_5_inst : FD2 port map( D => N336, CP => clk_i, CD => n677, Q => 
                           phase_o_5_port, QN => n322_port);
   phase_reg_4_inst : FD2 port map( D => N335, CP => clk_i, CD => n677, Q => 
                           phase_o_4_port, QN => n_1038);
   phase_reg_3_inst : FD2 port map( D => N334, CP => clk_i, CD => n677, Q => 
                           phase_o_3_port, QN => n323_port);
   phase_reg_2_inst : FD2 port map( D => N333, CP => clk_i, CD => n677, Q => 
                           phase_o_2_port, QN => n_1039);
   phase_reg_1_inst : FD2 port map( D => N332, CP => clk_i, CD => n677, Q => 
                           phase_o_1_port, QN => n324_port);
   phase_reg_0_inst : FD2 port map( D => N331, CP => clk_i, CD => n677, Q => 
                           N290, QN => n676);
   lut_out_reg_8_inst : FD2 port map( D => N368, CP => clk_i, CD => n677, Q => 
                           lut_out_8_port, QN => n670);
   lut_out_reg_7_inst : FD2 port map( D => N367, CP => clk_i, CD => n677, Q => 
                           lut_out_7_port, QN => n671);
   lut_out_reg_6_inst : FD2 port map( D => N366, CP => clk_i, CD => n677, Q => 
                           lut_out_6_port, QN => n_1040);
   lut_out_reg_5_inst : FD2 port map( D => N365, CP => clk_i, CD => n677, Q => 
                           lut_out_5_port, QN => n672);
   lut_out_reg_4_inst : FD2 port map( D => N364, CP => clk_i, CD => n677, Q => 
                           lut_out_4_port, QN => n_1041);
   lut_out_reg_3_inst : FD2 port map( D => N363, CP => clk_i, CD => n677, Q => 
                           lut_out_3_port, QN => n673);
   lut_out_reg_2_inst : FD2 port map( D => N362, CP => clk_i, CD => n677, Q => 
                           lut_out_2_port, QN => n_1042);
   lut_out_reg_1_inst : FD2 port map( D => N361, CP => clk_i, CD => n677, Q => 
                           lut_out_1_port, QN => n675);
   lut_out_reg_0_inst : FD2 port map( D => N360, CP => clk_i, CD => n677, Q => 
                           N370, QN => n674);
   lut_out_delay_reg_8_inst : FD2 port map( D => lut_out_8_port, CP => clk_i, 
                           CD => n677, Q => n_1043, QN => n652);
   lut_out_delay_reg_7_inst : FD2 port map( D => lut_out_7_port, CP => clk_i, 
                           CD => n677, Q => n_1044, QN => n654);
   lut_out_delay_reg_6_inst : FD2 port map( D => lut_out_6_port, CP => clk_i, 
                           CD => n677, Q => n_1045, QN => n656);
   lut_out_delay_reg_5_inst : FD2 port map( D => lut_out_5_port, CP => clk_i, 
                           CD => n677, Q => n_1046, QN => n658);
   lut_out_delay_reg_4_inst : FD2 port map( D => lut_out_4_port, CP => clk_i, 
                           CD => n677, Q => n_1047, QN => n660);
   lut_out_delay_reg_3_inst : FD2 port map( D => lut_out_3_port, CP => clk_i, 
                           CD => n677, Q => n_1048, QN => n662);
   lut_out_delay_reg_2_inst : FD2 port map( D => lut_out_2_port, CP => clk_i, 
                           CD => n677, Q => n_1049, QN => n664);
   lut_out_delay_reg_1_inst : FD2 port map( D => lut_out_1_port, CP => clk_i, 
                           CD => n677, Q => n_1050, QN => n666);
   lut_out_delay_reg_0_inst : FD2 port map( D => N370, CP => clk_i, CD => n677,
                           Q => n_1051, QN => n668);
   lut_out_inv_delay_reg_9_inst : FD2 port map( D => N379, CP => clk_i, CD => 
                           n677, Q => n_1052, QN => n669);
   lut_out_inv_delay_reg_8_inst : FD2 port map( D => N378, CP => clk_i, CD => 
                           n677, Q => n_1053, QN => n651);
   lut_out_inv_delay_reg_7_inst : FD2 port map( D => N377, CP => clk_i, CD => 
                           n677, Q => n_1054, QN => n653);
   lut_out_inv_delay_reg_6_inst : FD2 port map( D => N376, CP => clk_i, CD => 
                           n677, Q => n_1055, QN => n655);
   lut_out_inv_delay_reg_5_inst : FD2 port map( D => N375, CP => clk_i, CD => 
                           n677, Q => n_1056, QN => n657);
   lut_out_inv_delay_reg_4_inst : FD2 port map( D => N374, CP => clk_i, CD => 
                           n677, Q => n_1057, QN => n659);
   lut_out_inv_delay_reg_3_inst : FD2 port map( D => N373, CP => clk_i, CD => 
                           n677, Q => n_1058, QN => n661);
   lut_out_inv_delay_reg_2_inst : FD2 port map( D => N372, CP => clk_i, CD => 
                           n677, Q => n_1059, QN => n663);
   lut_out_inv_delay_reg_1_inst : FD2 port map( D => N371, CP => clk_i, CD => 
                           n677, Q => n_1060, QN => n665);
   lut_out_inv_delay_reg_0_inst : FD2 port map( D => N370, CP => clk_i, CD => 
                           n677, Q => n_1061, QN => n667);
   quadrant_3_or_4_delay_reg : FD2 port map( D => phase_o_9_port, CP => clk_i, 
                           CD => n677, Q => quadrant_3_or_4_delay, QN => n_1062
                           );
   quadrant_3_or_4_2delay_reg : FD2 port map( D => quadrant_3_or_4_delay, CP =>
                           clk_i, CD => n677, Q => quadrant_3_or_4_2delay, QN 
                           => n326_port);
   add_99 : dds_synthesizer_ftw_width32_DW01_add_0 port map( A(9) => 
                           ftw_accu_31_port, A(8) => ftw_accu_30_port, A(7) => 
                           ftw_accu_29_port, A(6) => ftw_accu_28_port, A(5) => 
                           ftw_accu_27_port, A(4) => ftw_accu_26_port, A(3) => 
                           ftw_accu_25_port, A(2) => ftw_accu_24_port, A(1) => 
                           ftw_accu_23_port, A(0) => ftw_accu_22_port, B(9) => 
                           phase_i(9), B(8) => phase_i(8), B(7) => phase_i(7), 
                           B(6) => phase_i(6), B(5) => phase_i(5), B(4) => 
                           phase_i(4), B(3) => phase_i(3), B(2) => phase_i(2), 
                           B(1) => phase_i(1), B(0) => phase_i(0), CI => n3, 
                           SUM(9) => N340, SUM(8) => N339, SUM(7) => N338, 
                           SUM(6) => N337, SUM(5) => N336, SUM(4) => N335, 
                           SUM(3) => N334, SUM(2) => N333, SUM(1) => N332, 
                           SUM(0) => N331, CO => n_1063);
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
                           , B(1) => ftw_i(1), B(0) => ftw_i(0), CI => n4, 
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
                           SUM(1) => N300, SUM(0) => N299, CO => n_1064);
   U339 : IV port map( A => rst_i, Z => n677);
   U340 : NR2 port map( A => n669, B => n326_port, Z => ampl_o(9));
   U341 : MUX21L port map( A => n652, B => n651, S => quadrant_3_or_4_2delay, Z
                           => ampl_o(8));
   U342 : MUX21L port map( A => n654, B => n653, S => quadrant_3_or_4_2delay, Z
                           => ampl_o(7));
   U343 : MUX21L port map( A => n656, B => n655, S => quadrant_3_or_4_2delay, Z
                           => ampl_o(6));
   U344 : MUX21L port map( A => n658, B => n657, S => quadrant_3_or_4_2delay, Z
                           => ampl_o(5));
   U345 : MUX21L port map( A => n660, B => n659, S => quadrant_3_or_4_2delay, Z
                           => ampl_o(4));
   U346 : MUX21L port map( A => n662, B => n661, S => quadrant_3_or_4_2delay, Z
                           => ampl_o(3));
   U347 : MUX21L port map( A => n664, B => n663, S => quadrant_3_or_4_2delay, Z
                           => ampl_o(2));
   U348 : MUX21L port map( A => n666, B => n665, S => quadrant_3_or_4_2delay, Z
                           => ampl_o(1));
   U349 : MUX21L port map( A => n668, B => n667, S => quadrant_3_or_4_2delay, Z
                           => ampl_o(0));
   U350 : ND2 port map( A => n670, B => n327_port, Z => N379);
   U351 : EO port map( A => n670, B => n327_port, Z => N378);
   U352 : AN2 port map( A => n671, B => n328_port, Z => n327_port);
   U353 : EO port map( A => n671, B => n328_port, Z => N377);
   U354 : NR2 port map( A => lut_out_6_port, B => n329_port, Z => n328_port);
   U355 : EO port map( A => lut_out_6_port, B => n329_port, Z => N376);
   U356 : ND2 port map( A => n672, B => n330_port, Z => n329_port);
   U357 : EO port map( A => n672, B => n330_port, Z => N375);
   U358 : NR2 port map( A => lut_out_4_port, B => n331_port, Z => n330_port);
   U359 : EO port map( A => lut_out_4_port, B => n331_port, Z => N374);
   U360 : ND2 port map( A => n673, B => n332_port, Z => n331_port);
   U361 : EO port map( A => n673, B => n332_port, Z => N373);
   U362 : NR2 port map( A => lut_out_2_port, B => n333_port, Z => n332_port);
   U363 : EO port map( A => lut_out_2_port, B => n333_port, Z => N372);
   U364 : ND2 port map( A => n674, B => n675, Z => n333_port);
   U365 : EO port map( A => n674, B => n675, Z => N371);
   U366 : AO3 port map( A => n334_port, B => n335_port, C => n336_port, D => 
                           n337_port, Z => N368);
   U367 : IV port map( A => n338_port, Z => n334_port);
   U368 : AO7 port map( A => n339_port, B => n340_port, C => n341, Z => 
                           n338_port);
   U369 : ND4 port map( A => n342, B => n343, C => n336_port, D => n344, Z => 
                           N367);
   U370 : ND2 port map( A => n345, B => n346, Z => n343);
   U371 : MUX21L port map( A => n347, B => n348, S => n349, Z => n342);
   U372 : NR2 port map( A => n350, B => n351, Z => n348);
   U373 : AO7 port map( A => n352, B => n353, C => n354, Z => n347);
   U374 : ND2 port map( A => n355, B => n336_port, Z => N366);
   U375 : MUX21L port map( A => n356, B => n357, S => n345, Z => n355);
   U376 : ND4 port map( A => n358, B => n346, C => n335_port, D => n354, Z => 
                           n357);
   U377 : ND2 port map( A => n359, B => n360_port, Z => n346);
   U378 : OR3 port map( A => n353, B => n339_port, C => n361_port, Z => n358);
   U379 : AO3 port map( A => n362_port, B => n363_port, C => n344, D => 
                           n364_port, Z => n356);
   U380 : MUX21L port map( A => n365_port, B => n366_port, S => n349, Z => 
                           n364_port);
   U381 : AO3 port map( A => n350, B => n367_port, C => n368_port, D => n354, Z
                           => n366_port);
   U382 : ND2 port map( A => n369, B => n370_port, Z => n368_port);
   U383 : AO3 port map( A => n340_port, B => n371_port, C => n372_port, D => 
                           n373_port, Z => n365_port);
   U384 : AO2 port map( A => n374_port, B => n375_port, C => n376_port, D => 
                           n361_port, Z => n373_port);
   U385 : ND2 port map( A => n359, B => n349, Z => n344);
   U386 : IV port map( A => n377_port, Z => n359);
   U387 : AO3 port map( A => n378_port, B => n337_port, C => n336_port, D => 
                           n379_port, Z => N365);
   U388 : AO2 port map( A => n380, B => n381, C => n382, D => n383, Z => 
                           n379_port);
   U389 : AO3 port map( A => n350, B => n384, C => n385, D => n386, Z => n383);
   U390 : EO1 port map( A => n387, B => n376_port, C => n388, D => n352, Z => 
                           n386);
   U391 : AO6 port map( A => n389, B => n390, C => n387, Z => n352);
   U392 : AO7 port map( A => n391, B => n392, C => n369, Z => n385);
   U393 : MUX21L port map( A => n375_port, B => n370_port, S => n390, Z => n392
                           );
   U394 : AO3 port map( A => n393, B => n367_port, C => n394, D => n395, Z => 
                           n381);
   U395 : IV port map( A => n396, Z => n395);
   U396 : AO3 port map( A => n360_port, B => n377_port, C => n397, D => 
                           n372_port, Z => n396);
   U397 : MUX21L port map( A => n398, B => n399, S => n370_port, Z => n394);
   U398 : NR2 port map( A => n390, B => n400, Z => n399);
   U399 : IV port map( A => n363_port, Z => n398);
   U400 : AO1 port map( A => n401, B => n391, C => n387, D => n402, Z => n393);
   U401 : NR4 port map( A => n403, B => n404, C => n405, D => n406, Z => 
                           n378_port);
   U402 : MUX21L port map( A => n335_port, B => n407, S => n408, Z => n406);
   U403 : NR2 port map( A => n370_port, B => n335_port, Z => n407);
   U404 : MUX21L port map( A => n409, B => n410, S => n390, Z => n405);
   U405 : ND2 port map( A => n339_port, B => n340_port, Z => n410);
   U406 : OR2 port map( A => n360_port, B => n340_port, Z => n409);
   U407 : AO7 port map( A => n411, B => n412, C => n413, Z => n360_port);
   U408 : IV port map( A => n372_port, Z => n404);
   U409 : ND2 port map( A => n408, B => n390, Z => n372_port);
   U410 : IV port map( A => n414, Z => n403);
   U411 : AO3 port map( A => n415, B => n416, C => n336_port, D => n417, Z => 
                           N364);
   U412 : AO2 port map( A => n382, B => n418, C => n345, D => n419, Z => n417);
   U413 : ND2 port map( A => n420, B => n421, Z => n419);
   U414 : MUX21L port map( A => n422, B => n423, S => n349, Z => n421);
   U415 : AO7 port map( A => n370_port, B => n388, C => n341, Z => n423);
   U416 : AO3 port map( A => n351, B => n424, C => n425, D => n426, Z => n422);
   U417 : EO1 port map( A => n408, B => n411, C => n427, D => n353, Z => n426);
   U418 : AO6 port map( A => n428, B => n389, C => n429, Z => n425);
   U419 : IV port map( A => n430, Z => n429);
   U420 : AO2 port map( A => n431, B => n390, C => n387, D => n376_port, Z => 
                           n420);
   U421 : AO3 port map( A => n367_port, B => n432, C => n433, D => n434, Z => 
                           n418);
   U422 : AO1 port map( A => n435, B => n375_port, C => n436, D => n428, Z => 
                           n434);
   U423 : NR2 port map( A => n388, B => n371_port, Z => n436);
   U424 : AO3 port map( A => n340_port, B => n437, C => n438, D => n439, Z => 
                           n435);
   U425 : MUX21L port map( A => n440, B => n441, S => n390, Z => n433);
   U426 : NR2 port map( A => n412, B => n442, Z => n441);
   U427 : NR3 port map( A => n443, B => n444, C => n445, Z => n415);
   U428 : AO4 port map( A => n442, B => n427, C => n446, D => n384, Z => n445);
   U429 : MUX21L port map( A => n447, B => n448, S => n411, Z => n444);
   U430 : ND2 port map( A => n376_port, B => n424, Z => n448);
   U431 : AO6 port map( A => n389, B => n449, C => n450, Z => n447);
   U432 : AO3 port map( A => n451, B => n388, C => n452, D => n397, Z => n443);
   U433 : ND2 port map( A => n431, B => n453, Z => n397);
   U434 : IV port map( A => n454, Z => n431);
   U435 : OR3 port map( A => n449, B => n361_port, C => n362_port, Z => n452);
   U436 : AN2 port map( A => n371_port, B => n455, Z => n451);
   U437 : AO3 port map( A => n456, B => n457, C => n458, D => n459, Z => N363);
   U438 : AO2 port map( A => n380, B => n460, C => n382, D => n461, Z => n459);
   U439 : AO3 port map( A => n388, B => n432, C => n462, D => n463, Z => n461);
   U440 : AO1 port map( A => n450, B => n464, C => n465, D => n466, Z => n463);
   U441 : NR3 port map( A => n467, B => n401, C => n400, Z => n466);
   U442 : AN3 port map( A => n369, B => n424, C => n387, Z => n465);
   U443 : AO7 port map( A => n446, B => n455, C => n468, Z => n464);
   U444 : AO2 port map( A => n469, B => n361_port, C => n453, D => n470, Z => 
                           n462);
   U445 : AO3 port map( A => n401, B => n400, C => n471, D => n472, Z => n470);
   U446 : MUX21L port map( A => n408, B => n450, S => n389, Z => n472);
   U447 : ND2 port map( A => n369, B => n412, Z => n471);
   U448 : AO7 port map( A => n424, B => n473, C => n474, Z => n469);
   U449 : EO1 port map( A => n408, B => n475, C => n442, D => n476, Z => n474);
   U450 : AO3 port map( A => n390, B => n477, C => n478, D => n479, Z => n460);
   U451 : MUX21L port map( A => n480, B => n481, S => n413, Z => n479);
   U452 : NR2 port map( A => n412, B => n455, Z => n481);
   U453 : AO4 port map( A => n375_port, B => n482, C => n361_port, D => 
                           n362_port, Z => n480);
   U454 : ND2 port map( A => n428, B => n375_port, Z => n478);
   U455 : NR2 port map( A => n482, B => n353, Z => n428);
   U456 : AO1 port map( A => n483, B => n376_port, C => n484, D => n485, Z => 
                           n477);
   U457 : MUX21L port map( A => n486, B => n487, S => n411, Z => n485);
   U458 : AO2 port map( A => n369, B => n446, C => n488, D => n376_port, Z => 
                           n487);
   U459 : AO3 port map( A => n489, B => n388, C => n414, D => n490, Z => n484);
   U460 : ND2 port map( A => n450, B => n475, Z => n490);
   U461 : ND2 port map( A => n491, B => n424, Z => n414);
   U462 : AO6 port map( A => n492, B => n493, C => n494, Z => n458);
   U463 : ND4 port map( A => n495, B => n496, C => n367_port, D => n432, Z => 
                           n493);
   U464 : ND2 port map( A => n390, B => n413, Z => n496);
   U465 : MUX21H port map( A => n442, B => n351, S => n362_port, Z => n495);
   U466 : ND2 port map( A => n353, B => n361_port, Z => n351);
   U467 : AO1 port map( A => n374_port, B => n446, C => n497, D => n498, Z => 
                           n456);
   U468 : AO4 port map( A => n454, B => n455, C => n377_port, D => n362_port, Z
                           => n498);
   U469 : ND2 port map( A => n361_port, B => n340_port, Z => n377_port);
   U470 : AO3 port map( A => n499, B => n482, C => n427, D => n500, Z => n497);
   U471 : AO7 port map( A => n370_port, B => n387, C => n450, Z => n500);
   U472 : ND2 port map( A => n402, B => n424, Z => n427);
   U473 : NR2 port map( A => n501, B => n408, Z => n499);
   U474 : IV port map( A => n439, Z => n374_port);
   U475 : AO3 port map( A => n502, B => n503, C => n336_port, D => n504, Z => 
                           N362);
   U476 : MUX31L port map( D0 => n505, D1 => n506, D2 => n507, A => n345, B => 
                           n349, Z => n504);
   U477 : AO6 port map( A => n508, B => n509, C => n337_port, Z => n507);
   U478 : AO1 port map( A => n450, B => n411, C => n510, D => n511, Z => n509);
   U479 : IV port map( A => n354, Z => n511);
   U480 : ND2 port map( A => n390, B => n449, Z => n354);
   U481 : NR2 port map( A => n437, B => n512, Z => n510);
   U482 : NR2 port map( A => n513, B => n514, Z => n508);
   U483 : MUX21L port map( A => n515, B => n339_port, S => n449, Z => n514);
   U484 : AO6 port map( A => n402, B => n412, C => n516, Z => n515);
   U485 : MUX21L port map( A => n517, B => n432, S => n413, Z => n513);
   U486 : ND2 port map( A => n387, B => n446, Z => n432);
   U487 : AN2 port map( A => n482, B => n489, Z => n517);
   U488 : MUX21L port map( A => n412, B => n401, S => n411, Z => n489);
   U489 : AO3 port map( A => n400, B => n371_port, C => n518, D => n519, Z => 
                           n506);
   U490 : AO7 port map( A => n520, B => n521, C => n390, Z => n519);
   U491 : AO4 port map( A => n401, B => n473, C => n413, D => n362_port, Z => 
                           n521);
   U492 : MUX21L port map( A => n522, B => n454, S => n411, Z => n520);
   U493 : ND2 port map( A => n369, B => n375_port, Z => n454);
   U494 : AO1 port map( A => n401, B => n413, C => n501, D => n523, Z => n522);
   U495 : NR2 port map( A => n375_port, B => n388, Z => n523);
   U496 : IV port map( A => n486, Z => n501);
   U497 : AO7 port map( A => n341, B => n402, C => n524, Z => n518);
   U498 : IV port map( A => n467, Z => n402);
   U499 : NR2 port map( A => n390, B => n376_port, Z => n341);
   U500 : ND2 port map( A => n391, B => n446, Z => n371_port);
   U501 : AO3 port map( A => n525, B => n467, C => n526, D => n527, Z => n505);
   U502 : AO6 port map( A => n391, B => n528, C => n529, Z => n527);
   U503 : AO4 port map( A => N290, B => n340_port, C => n524, D => n388, Z => 
                           n528);
   U504 : MUX21L port map( A => n453, B => n387, S => n488, Z => n526);
   U505 : NR4 port map( A => n530, B => n531, C => n532, D => n533, Z => n525);
   U506 : NR2 port map( A => n340_port, B => n534, Z => n533);
   U507 : IV port map( A => n494, Z => n336_port);
   U508 : AO1 port map( A => n535, B => n361_port, C => n536, D => n537, Z => 
                           n502);
   U509 : AO6 port map( A => n538, B => n539, C => n482, Z => n537);
   U510 : IV port map( A => n540, Z => n539);
   U511 : AO2 port map( A => n488, B => n369, C => n450, D => n375_port, Z => 
                           n538);
   U512 : AO4 port map( A => n339_port, B => n363_port, C => n541, D => n455, Z
                           => n536);
   U513 : AO6 port map( A => n542, B => n353, C => n532, Z => n541);
   U514 : AO3 port map( A => n473, B => n542, C => n543, D => n544, Z => n535);
   U515 : AO1 port map( A => n483, B => n491, C => n545, D => n546, Z => n544);
   U516 : NR2 port map( A => n442, B => n547, Z => n545);
   U517 : IV port map( A => n438, Z => n491);
   U518 : MUX21L port map( A => n540, B => n548, S => n411, Z => n543);
   U519 : NR2 port map( A => n488, B => n367_port, Z => n548);
   U520 : AO4 port map( A => n488, B => n388, C => n483, D => n400, Z => n540);
   U521 : AO3 port map( A => n549, B => n550, C => n551, D => n552, Z => N361);
   U522 : AO2 port map( A => n553, B => n554, C => n382, D => n555, Z => n552);
   U523 : ND3 port map( A => n556, B => n557, C => n558, Z => n555);
   U524 : AO1 port map( A => n559, B => n542, C => n529, D => n560, Z => n558);
   U525 : NR2 port map( A => n561, B => n455, Z => n560);
   U526 : AO6 port map( A => n534, B => n340_port, C => n531, Z => n561);
   U527 : NR3 port map( A => n483, B => n442, C => n437, Z => n529);
   U528 : AO4 port map( A => n353, B => n467, C => n400, D => n482, Z => n559);
   U529 : MUX21L port map( A => n562, B => n563, S => n390, Z => n557);
   U530 : NR2 port map( A => n564, B => n367_port, Z => n563);
   U531 : NR2 port map( A => n473, B => n512, Z => n562);
   U532 : AO2 port map( A => n483, B => n565, C => n516, D => n408, Z => n556);
   U533 : IV port map( A => n468, Z => n516);
   U534 : ND2 port map( A => n391, B => n375_port, Z => n468);
   U535 : AO3 port map( A => n390, B => n388, C => n430, D => n439, Z => n565);
   U536 : IV port map( A => n503, Z => n382);
   U537 : AO3 port map( A => n467, B => n566, C => n567, D => n568, Z => n554);
   U538 : AO1 port map( A => n387, B => n569, C => n570, D => n571, Z => n568);
   U539 : NR3 port map( A => n473, B => n483, C => n361_port, Z => n571);
   U540 : IV port map( A => n534, Z => n483);
   U541 : NR3 port map( A => n437, B => n524, C => n400, Z => n570);
   U542 : AO7 port map( A => n442, B => n534, C => n572, Z => n569);
   U543 : AO2 port map( A => n453, B => n573, C => n676, D => n574, Z => n567);
   U544 : AO3 port map( A => n340_port, B => n467, C => n575, D => n430, Z => 
                           n574);
   U545 : ND2 port map( A => n391, B => n353, Z => n430);
   U546 : ND2 port map( A => n369, B => n361_port, Z => n575);
   U547 : AO7 port map( A => n676, B => n388, C => n576, Z => n573);
   U548 : AO2 port map( A => n369, B => n542, C => n376_port, D => n512, Z => 
                           n576);
   U549 : IV port map( A => n457, Z => n553);
   U550 : AO6 port map( A => n577, B => n380, C => n494, Z => n551);
   U551 : IV port map( A => n416, Z => n380);
   U552 : MUX21L port map( A => n578, B => n542, S => n390, Z => n577);
   U553 : AO1 port map( A => n369, B => n475, C => n579, D => n580, Z => n578);
   U554 : AO4 port map( A => n400, B => n581, C => n582, D => n388, Z => n580);
   U555 : AO6 port map( A => n524, B => n583, C => n350, Z => n582);
   U556 : AO3 port map( A => n583, B => n584, C => n486, D => n585, Z => n579);
   U557 : ND2 port map( A => n449, B => n375_port, Z => n584);
   U558 : AO7 port map( A => n411, B => n375_port, C => n547, Z => n475);
   U559 : NR3 port map( A => n586, B => n587, C => n588, Z => n549);
   U560 : AO4 port map( A => n339_port, B => n367_port, C => n401, D => n439, Z
                           => n588);
   U561 : ND2 port map( A => n453, B => n340_port, Z => n439);
   U562 : MUX21L port map( A => n589, B => n486, S => n411, Z => n587);
   U563 : ND2 port map( A => n412, B => n376_port, Z => n589);
   U564 : AO3 port map( A => n590, B => n455, C => n363_port, D => n591, Z => 
                           n586);
   U565 : EO1 port map( A => n524, B => n592, C => n467, D => n572, Z => n591);
   U566 : AO6 port map( A => n450, B => n524, C => n530, Z => n572);
   U567 : IV port map( A => n566, Z => n530);
   U568 : ND2 port map( A => n376_port, B => n390, Z => n363_port);
   U569 : NR2 port map( A => n449, B => n401, Z => n590);
   U570 : AO3 port map( A => n593, B => n503, C => n594, D => n595, Z => N360);
   U571 : AO6 port map( A => n492, B => n596, C => n494, Z => n595);
   U572 : AN3 port map( A => n597, B => n325_port, C => phase_o_8_port, Z => 
                           n494);
   U573 : AO3 port map( A => n598, B => n361_port, C => n599, D => n600, Z => 
                           n596);
   U574 : AO1 port map( A => n413, B => n601, C => n602, D => n603, Z => n600);
   U575 : NR3 port map( A => n534, B => n388, C => n467, Z => n603);
   U576 : ND2 port map( A => N290, B => n375_port, Z => n534);
   U577 : NR2 port map( A => n384, B => n604, Z => n602);
   U578 : ND2 port map( A => n450, B => n361_port, Z => n384);
   U579 : AO4 port map( A => n437, B => n446, C => n467, D => n512, Z => n601);
   U580 : ND2 port map( A => n583, B => n361_port, Z => n467);
   U581 : AO2 port map( A => n531, B => n391, C => n676, D => n592, Z => n599);
   U582 : AO4 port map( A => n449, B => n437, C => n390, D => n442, Z => n592);
   U583 : IV port map( A => n437, Z => n391);
   U584 : ND2 port map( A => n411, B => n361_port, Z => n437);
   U585 : NR2 port map( A => n400, B => n676, Z => n531);
   U586 : AO1 port map( A => n408, B => n350, C => n605, D => n440, Z => n598);
   U587 : MUX21L port map( A => n606, B => n449, S => n401, Z => n605);
   U588 : AO7 port map( A => n449, B => n542, C => n583, Z => n606);
   U589 : IV port map( A => n550, Z => n492);
   U590 : ND2 port map( A => n349, B => n345, Z => n550);
   U591 : MUX21L port map( A => n607, B => n608, S => n390, Z => n594);
   U592 : AO4 port map( A => n676, B => n416, C => n609, D => n457, Z => n608);
   U593 : ND2 port map( A => n345, B => n335_port, Z => n457);
   U594 : AO1 port map( A => n450, B => n350, C => n610, D => n611, Z => n609);
   U595 : AO4 port map( A => n476, B => n388, C => n353, D => n547, Z => n611);
   U596 : MUX21L port map( A => n375_port, B => n446, S => n411, Z => n476);
   U597 : AO3 port map( A => n375_port, B => n438, C => n612, D => n585, Z => 
                           n610);
   U598 : OR3 port map( A => n411, B => n400, C => n542, Z => n612);
   U599 : ND2 port map( A => n369, B => n583, Z => n438);
   U600 : IV port map( A => n339_port, Z => n350);
   U601 : ND2 port map( A => n337_port, B => n335_port, Z => n416);
   U602 : IV port map( A => n349, Z => n335_port);
   U603 : NR2 port map( A => n349, B => n613, Z => n607);
   U604 : AO6 port map( A => n564, B => n369, C => n614, Z => n613);
   U605 : MUX21L port map( A => n615, B => n616, S => n345, Z => n614);
   U606 : IV port map( A => n337_port, Z => n345);
   U607 : NR3 port map( A => n617, B => n370_port, C => n618, Z => n616);
   U608 : IV port map( A => n362_port, Z => n370_port);
   U609 : MUX21L port map( A => n619, B => n339_port, S => n413, Z => n617);
   U610 : ND2 port map( A => n401, B => n583, Z => n619);
   U611 : IV port map( A => n446, Z => n401);
   U612 : AO2 port map( A => n376_port, B => n620, C => n604, D => n353, Z => 
                           n615);
   U613 : AO7 port map( A => n411, B => N290, C => n547, Z => n620);
   U614 : ND2 port map( A => n411, B => n542, Z => n547);
   U615 : IV port map( A => n442, Z => n369);
   U616 : IV port map( A => n604, Z => n564);
   U617 : AO7 port map( A => n676, B => n411, C => n581, Z => n604);
   U618 : ND2 port map( A => n337_port, B => n349, Z => n503);
   U619 : NR2 port map( A => n621, B => n597, Z => n349);
   U620 : MUX21L port map( A => n622, B => phase_o_6_port, S => n321_port, Z =>
                           n621);
   U621 : ND2 port map( A => n623, B => phase_o_6_port, Z => n622);
   U622 : EO port map( A => n325_port, B => n624, Z => n337_port);
   U623 : NR2 port map( A => n597, B => n321_port, Z => n624);
   U624 : NR2 port map( A => n623, B => phase_o_6_port, Z => n597);
   U625 : AO1 port map( A => n453, B => n625, C => n626, D => n627, Z => n593);
   U626 : AN3 port map( A => n387, B => n340_port, C => n524, Z => n627);
   U627 : IV port map( A => n455, Z => n387);
   U628 : ND2 port map( A => n390, B => n411, Z => n455);
   U629 : MUX21L port map( A => n628, B => n629, S => n390, Z => n626);
   U630 : AO1 port map( A => n440, B => n446, C => n532, D => n630, Z => n629);
   U631 : NR2 port map( A => n362_port, B => n367_port, Z => n630);
   U632 : ND2 port map( A => n412, B => n411, Z => n362_port);
   U633 : IV port map( A => n424, Z => n412);
   U634 : NR2 port map( A => n542, B => n442, Z => n532);
   U635 : IV port map( A => n473, Z => n440);
   U636 : ND2 port map( A => n631, B => n449, Z => n473);
   U637 : EO port map( A => n353, B => n411, Z => n631);
   U638 : NR4 port map( A => n546, B => n632, C => n633, D => n634, Z => n628);
   U639 : MUX21L port map( A => n635, B => n636, S => n411, Z => n634);
   U640 : ND2 port map( A => n524, B => n618, Z => n636);
   U641 : ND2 port map( A => n367_port, B => n442, Z => n618);
   U642 : ND2 port map( A => n413, B => n340_port, Z => n442);
   U643 : IV port map( A => n542, Z => n524);
   U644 : ND2 port map( A => n413, B => N290, Z => n635);
   U645 : AO6 port map( A => n446, B => n339_port, C => n400, Z => n633);
   U646 : ND2 port map( A => n411, B => n389, Z => n339_port);
   U647 : ND2 port map( A => n585, B => n566, Z => n632);
   U648 : ND3 port map( A => n542, B => n583, C => n450, Z => n585);
   U649 : IV port map( A => n367_port, Z => n450);
   U650 : ND2 port map( A => n449, B => n353, Z => n367_port);
   U651 : ND2 port map( A => n446, B => n424, Z => n542);
   U652 : ND2 port map( A => n389, B => N290, Z => n424);
   U653 : ND2 port map( A => n676, B => n375_port, Z => n446);
   U654 : NR2 port map( A => n581, B => n388, Z => n546);
   U655 : ND2 port map( A => n411, B => n676, Z => n581);
   U656 : ND2 port map( A => n486, B => n566, Z => n625);
   U657 : ND2 port map( A => n488, B => n408, Z => n566);
   U658 : IV port map( A => n388, Z => n408);
   U659 : ND2 port map( A => n340_port, B => n353, Z => n388);
   U660 : IV port map( A => n449, Z => n340_port);
   U661 : IV port map( A => n512, Z => n488);
   U662 : ND2 port map( A => n389, B => n676, Z => n512);
   U663 : IV port map( A => n375_port, Z => n389);
   U664 : ND2 port map( A => n376_port, B => n375_port, Z => n486);
   U665 : ND2 port map( A => n637, B => n638, Z => n375_port);
   U666 : MUX21L port map( A => n324_port, B => n639, S => phase_o_8_port, Z =>
                           n637);
   U667 : NR2 port map( A => n676, B => n324_port, Z => n639);
   U668 : IV port map( A => n400, Z => n376_port);
   U669 : ND2 port map( A => n449, B => n413, Z => n400);
   U670 : IV port map( A => n353, Z => n413);
   U671 : ND2 port map( A => n640, B => n641, Z => n353);
   U672 : MUX21L port map( A => n323_port, B => n642, S => phase_o_8_port, Z =>
                           n640);
   U673 : NR2 port map( A => n643, B => n323_port, Z => n642);
   U674 : NR2 port map( A => n644, B => n645, Z => n449);
   U675 : MUX21L port map( A => n646, B => phase_o_4_port, S => n321_port, Z =>
                           n644);
   U676 : ND2 port map( A => n641, B => phase_o_4_port, Z => n646);
   U677 : IV port map( A => n482, Z => n453);
   U678 : ND2 port map( A => n390, B => n583, Z => n482);
   U679 : IV port map( A => n411, Z => n583);
   U680 : NR2 port map( A => n647, B => n643, Z => n411);
   U681 : MUX21L port map( A => n648, B => phase_o_2_port, S => n321_port, Z =>
                           n647);
   U682 : ND2 port map( A => n638, B => phase_o_2_port, Z => n648);
   U683 : IV port map( A => n361_port, Z => n390);
   U684 : ND2 port map( A => n649, B => n623, Z => n361_port);
   U685 : ND2 port map( A => n645, B => n322_port, Z => n623);
   U686 : MUX21L port map( A => n322_port, B => n650, S => phase_o_8_port, Z =>
                           n649);
   U687 : NR2 port map( A => n645, B => n322_port, Z => n650);
   U688 : NR2 port map( A => n641, B => phase_o_4_port, Z => n645);
   U689 : ND2 port map( A => n643, B => n323_port, Z => n641);
   U690 : NR2 port map( A => n638, B => phase_o_2_port, Z => n643);
   U691 : ND2 port map( A => n676, B => n324_port, Z => n638);

end SYN_dds_synthesizer_arch;
