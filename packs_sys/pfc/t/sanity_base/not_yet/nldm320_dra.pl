

% swipl  % 396,814,768 inferences, 62.415 CPU in 62.434 seconds (100% CPU, 6357653 Lips)
% XSB 5 seconds
% dra-intrerp 

:- use_module(library(dra)).
:- dra_table(tc/2).

tc(X,Y):- adj(X,Y).
tc(X,Z):- tc(X,Y), tc(Y,Z).

adj(1,2).
adj(2,3).
adj(3,4).
adj(4,5).
adj(5,6).
adj(6,7).
adj(7,8).
adj(8,9).
adj(9,10).
adj(10,11).
adj(11,12).
adj(12,13).
adj(13,14).
adj(14,15).
adj(15,16).
adj(16,17).
adj(17,18).
adj(18,19).
adj(19,20).
adj(20,21).
adj(21,22).
adj(22,23).
adj(23,24).
adj(24,25).
adj(25,26).
adj(26,27).
adj(27,28).
adj(28,29).
adj(29,30).
adj(30,31).
adj(31,32).
adj(32,33).
adj(33,34).
adj(34,35).
adj(35,36).
adj(36,37).
adj(37,38).
adj(38,39).
adj(39,40).
adj(40,41).
adj(41,42).
adj(42,43).
adj(43,44).
adj(44,45).
adj(45,46).
adj(46,47).
adj(47,48).
adj(48,49).
adj(49,50).
adj(50,51).
adj(51,52).
adj(52,53).
adj(53,54).
adj(54,55).
adj(55,56).
adj(56,57).
adj(57,58).
adj(58,59).
adj(59,60).
adj(60,61).
adj(61,62).
adj(62,63).
adj(63,64).
adj(64,65).
adj(65,66).
adj(66,67).
adj(67,68).
adj(68,69).
adj(69,70).
adj(70,71).
adj(71,72).
adj(72,73).
adj(73,74).
adj(74,75).
adj(75,76).
adj(76,77).
adj(77,78).
adj(78,79).
adj(79,80).
adj(80,81).
adj(81,82).
adj(82,83).
adj(83,84).
adj(84,85).
adj(85,86).
adj(86,87).
adj(87,88).
adj(88,89).
adj(89,90).
adj(90,91).
adj(91,92).
adj(92,93).
adj(93,94).
adj(94,95).
adj(95,96).
adj(96,97).
adj(97,98).
adj(98,99).
adj(99,100).
adj(100,101).
adj(101,102).
adj(102,103).
adj(103,104).
adj(104,105).
adj(105,106).
adj(106,107).
adj(107,108).
adj(108,109).
adj(109,110).
adj(110,111).
adj(111,112).
adj(112,113).
adj(113,114).
adj(114,115).
adj(115,116).
adj(116,117).
adj(117,118).
adj(118,119).
adj(119,120).
adj(120,121).
adj(121,122).
adj(122,123).
adj(123,124).
adj(124,125).
adj(125,126).
adj(126,127).
adj(127,128).
adj(128,129).
adj(129,130).
adj(130,131).
adj(131,132).
adj(132,133).
adj(133,134).
adj(134,135).
adj(135,136).
adj(136,137).
adj(137,138).
adj(138,139).
adj(139,140).
adj(140,141).
adj(141,142).
adj(142,143).
adj(143,144).
adj(144,145).
adj(145,146).
adj(146,147).
adj(147,148).
adj(148,149).
adj(149,150).
adj(150,151).
adj(151,152).
adj(152,153).
adj(153,154).
adj(154,155).
adj(155,156).
adj(156,157).
adj(157,158).
adj(158,159).
adj(159,160).
adj(160,161).
adj(161,162).
adj(162,163).
adj(163,164).
adj(164,165).
adj(165,166).
adj(166,167).
adj(167,168).
adj(168,169).
adj(169,170).
adj(170,171).
adj(171,172).
adj(172,173).
adj(173,174).
adj(174,175).
adj(175,176).
adj(176,177).
adj(177,178).
adj(178,179).
adj(179,180).
adj(180,181).
adj(181,182).
adj(182,183).
adj(183,184).
adj(184,185).
adj(185,186).
adj(186,187).
adj(187,188).
adj(188,189).
adj(189,190).
adj(190,191).
adj(191,192).
adj(192,193).
adj(193,194).
adj(194,195).
adj(195,196).
adj(196,197).
adj(197,198).
adj(198,199).
adj(199,200).
adj(200,201).
adj(201,202).
adj(202,203).
adj(203,204).
adj(204,205).
adj(205,206).
adj(206,207).
adj(207,208).
adj(208,209).
adj(209,210).
adj(210,211).
adj(211,212).
adj(212,213).
adj(213,214).
adj(214,215).
adj(215,216).
adj(216,217).
adj(217,218).
adj(218,219).
adj(219,220).
adj(220,221).
adj(221,222).
adj(222,223).
adj(223,224).
adj(224,225).
adj(225,226).
adj(226,227).
adj(227,228).
adj(228,229).
adj(229,230).
adj(230,231).
adj(231,232).
adj(232,233).
adj(233,234).
adj(234,235).
adj(235,236).
adj(236,237).
adj(237,238).
adj(238,239).
adj(239,240).
adj(240,241).
adj(241,242).
adj(242,243).
adj(243,244).
adj(244,245).
adj(245,246).
adj(246,247).
adj(247,248).
adj(248,249).
adj(249,250).
adj(250,251).
adj(251,252).
adj(252,253).
adj(253,254).
adj(254,255).
adj(255,256).
adj(256,257).
adj(257,258).
adj(258,259).
adj(259,260).
adj(260,261).
adj(261,262).
adj(262,263).
adj(263,264).
adj(264,265).
adj(265,266).
adj(266,267).
adj(267,268).
adj(268,269).
adj(269,270).
adj(270,271).
adj(271,272).
adj(272,273).
adj(273,274).
adj(274,275).
adj(275,276).
adj(276,277).
adj(277,278).
adj(278,279).
adj(279,280).
adj(280,281).
adj(281,282).
adj(282,283).
adj(283,284).
adj(284,285).
adj(285,286).
adj(286,287).
adj(287,288).
adj(288,289).
adj(289,290).
adj(290,291).
adj(291,292).
adj(292,293).
adj(293,294).
adj(294,295).
adj(295,296).
adj(296,297).
adj(297,298).
adj(298,299).
adj(299,300).
adj(300,301).
adj(301,302).
adj(302,303).
adj(303,304).
adj(304,305).
adj(305,306).
adj(306,307).
adj(307,308).
adj(308,309).
adj(309,310).
adj(310,311).
adj(311,312).
adj(312,313).
adj(313,314).
adj(314,315).
adj(315,316).
adj(316,317).
adj(317,318).
adj(318,319).
adj(319,320).
adj(320,1).

:- use_module(library(statistics)).
:- statistics(cputime,X),assert(load_time(X)).
:- time(findall(_,tc(_X,_Y),_)).
:- statistics(cputime,X),retract(load_time(LT)), Time is X-LT,write(time_was(Time)).


% ISSUE: https://github.com/logicmoo/logicmoo_workspace/issues/85 
% EDIT: https://github.com/logicmoo/logicmoo_workspace/edit/master/packs_sys/pfc/t/sanity_base/nldm320_dra.pl 
% JENKINS: https://jenkins.logicmoo.org/job/logicmoo_workspace/lastBuild/testReport/logicmoo.pfc.test.sanity_base/NLDM320_DRA/logicmoo_pfc_test_sanity_base_NLDM320_DRA_JUnit/ 
% ISSUE_SEARCH: https://github.com/logicmoo/logicmoo_workspace/issues?q=is%3Aissue+label%3ANLDM320_DRA 

