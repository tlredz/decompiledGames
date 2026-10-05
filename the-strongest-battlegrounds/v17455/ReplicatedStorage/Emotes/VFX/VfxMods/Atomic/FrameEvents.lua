local RunService = game:GetService("RunService")

local function asset_ids(list)
	local result = table.create(#list)

	for i, v in ipairs(list) do
		result[i] = "rbxassetid://" .. tostring(v)
	end

	return result
end

local v = {
	103047555457598,
	96383636824429,
	77154417364449,
	133137576766442,
	115318972904606,
	137255364874840,
	132472016893093,
	99729851054227,
	96717741781345,
	110693788205976,
	93843483677541,
	127407922526291,
	129076977690639,
	92067785586199,
	119743349944939,
	136972809799069,
	91478903475190,
	136133984243170,
	72219640454898,
	88163481619715,
	94423331326642,
	117808038842761,
	95419784206252,
	114444333531335,
	120540136534309,
	94585248946723,
	95567875281911,
	90619039074767,
	117869206659466,
	119670663200915,
	87096459538150,
	130854059267265,
	75228717668228,
	92103682167129,
	130546540410960,
	98185997045696,
	138476886648889,
	74909781813809,
	126807255979917,
	98628873444459,
	116584945169227,
	83530610844882
}
local ids2 = table.create(#v)
local v3 = {
	target = "main",
	ids = 0,
	start_frame = 554,
	duration = 1.65,
	z_index = 2,
	scale_type = 0,
	image_color3 = 0
}
local v4 = {}

for i, v5 in ipairs(v) do
	ids2[i] = "rbxassetid://" .. tostring(v5)
end

v3.ids = ids2
v3.scale_type = Enum.ScaleType.Crop
v3.image_color3 = Color3.new(1, 1, 1)
local v5 = {
	112935479431445,
	109057892990795,
	80726326993602,
	95083496696831,
	106045215236859,
	72910716127515,
	128815416024421,
	110294769222556,
	72921199799538,
	99193415742123,
	123777366622874,
	99543022782379,
	123416291429460,
	96946451555973,
	106183222583762,
	133533006660600,
	133527147823594,
	129390033312584,
	136324469364756,
	135209310289053,
	85493274636136,
	97220968970686,
	75649894688030,
	74948873957450,
	129741735417695,
	75423009674842,
	132019872203441,
	79232739913482,
	125685905853346,
	72568535254127,
	93480281793377,
	113606005628857,
	78698946227147,
	114641769777520,
	101145477574325,
	83115291430091,
	108404275737897,
	99510811488568,
	109173473585804,
	89894805895626,
	118400402616215,
	117442957516300,
	91401933430707,
	98875771872423,
	135276894380550,
	100641936925699,
	139767415298468,
	88353469755732,
	129831965954149,
	85196987606319,
	122843149902415,
	106596604200513,
	88970899370211,
	126028519637442,
	119069001591182,
	111910432655186,
	114929774933935,
	91676958326954,
	106039012935007,
	136993658860159,
	140712521168633,
	130312605035524,
	126328211226133,
	124267309471147,
	135484398513460,
	115504991410931,
	130812830344978,
	77645752640301,
	102109169848082,
	95624955160362,
	120632571988890,
	78869819770526,
	112024989660677,
	90264923764455,
	71459138053541,
	123785970392757,
	76238458813551,
	102334801760740,
	120378638290222,
	121870493097160,
	104661541562507,
	136364407574573,
	120228400341944,
	108893026128680,
	103072952765465,
	96770990272485,
	119185884999922,
	71817231585674,
	107512974259402,
	86343768085819,
	94877623784783,
	93684661229297,
	121583562209098,
	98278707047265,
	125183294346296,
	132197544347139,
	106896480748251,
	116023514604477,
	125391113932346,
	79505231926933,
	101215936550061,
	100395028559922,
	124975425602392,
	124857321076040,
	133896950541521,
	126347865364388,
	123080916162831,
	120764618473307,
	79003798762756,
	75891252311319,
	73662139605552,
	125194891971847,
	126756917999610,
	72354844613627,
	107890413827350,
	138397478274389,
	89993597393376,
	109550334771256,
	123975030043039,
	101997762931144,
	107625080073466,
	71215303570729,
	113812740535467,
	80051110272072,
	116560141754234,
	136738962929514,
	97110883119333,
	115822830368847,
	72653064433446,
	93573850531655,
	139044780026230,
	130285879532856,
	116785715949691,
	95998482401559,
	88087180420696,
	98720636527903,
	77256957092336,
	75045104571646,
	134678040850990,
	89596617175959,
	89951409630975,
	137650791208715,
	94419022560557,
	100738919125117,
	117743502243665,
	84174991989599,
	112888435155766,
	110211539569844,
	71760604279595,
	128983987630696,
	73272051065006,
	119909858440198,
	109546700477931,
	111039029408686,
	86576894891327,
	91749502211810,
	122000021115910,
	129640085935721,
	103226107788343,
	70732253395890,
	123306860979875,
	82339075595489,
	72320610478619,
	121232101517515,
	85067506945227,
	125595717730970,
	138249178857832,
	105174119000428,
	76155764122140,
	93418635292993,
	140650201318564,
	77732726167318,
	130033461472955,
	120819719275059,
	123558797616669,
	71565309949035,
	94055179432438,
	140596082911032,
	78474800150399,
	118532284528456,
	110567949080762,
	133261250162658,
	124866405439344,
	71416717246610,
	132658582232309,
	106309760404639,
	73497430260508,
	105829101242951,
	102461852763084,
	123094725332977,
	129546817481585,
	131989521340752,
	132903339128932,
	134538792168152,
	74179161538050,
	78604559489608,
	83622243584550,
	74613475245856,
	74616227310577,
	110034995706513,
	126829686095823,
	76293272205966,
	71333983800138,
	105250955386914,
	118881709763798,
	136235666168018,
	90495718264405,
	91202588119729,
	72983542996634,
	117807855231928,
	127342595955806,
	129926615903202,
	128497872227390,
	103423796207741,
	129128302877792,
	123102719717931,
	92197022678481,
	134015379929461
}
local ids3 = table.create(#v5)
local v7 = {
	target = "main",
	ids = 0,
	start_frame = 633,
	duration = 6.6,
	z_index = 2,
	scale_type = 0,
	image_color3 = 0
}

for i, v8 in ipairs(v5) do
	ids3[i] = "rbxassetid://" .. tostring(v8)
end

v7.ids = ids3
v7.scale_type = Enum.ScaleType.Crop
v7.image_color3 = Color3.new(1, 1, 1)
local v8 = {
	84107340390206,
	103921258771546,
	80904490788451,
	126519495604534,
	134194831707856,
	120822127673061,
	74110713294389,
	115168868752710,
	113777708939146,
	139318248467613,
	86989570513210,
	139558334853383,
	71990925454521,
	73722656857987,
	136316349869421,
	88602316276600,
	122132265155342,
	96003895986874,
	108930200457623,
	105935920897578
}
local ids4 = table.create(#v8)
local v10 = {
	target = "impact",
	ids = 0,
	start_frame = 1030,
	duration = 0.85,
	z_index = 15,
	scale_type = 0,
	image_color3 = 0
}

for i, v11 in ipairs(v8) do
	ids4[i] = "rbxassetid://" .. tostring(v11)
end

v10.ids = ids4
v10.scale_type = Enum.ScaleType.Crop
v10.image_color3 = Color3.new(0, 0, 0)
v4[1], v4[2], v4[3] = v3, v7, v10
local v11 = {
	106813751880872,
	82189465621073,
	112578709531548,
	74121234747178,
	89461472662226,
	85453514547211,
	120271502062756,
	136296950757997,
	77593375661797,
	107478314590891,
	114855552540899,
	110695709153013,
	112628322685955,
	74751472235235,
	100572364600299,
	79188209227345,
	119378504291000,
	108617202324518,
	92095749014021,
	129320324451802,
	79370086700194,
	129401750390356,
	124843171126659,
	117621337427933
}
local assetids = table.create(#v11)
local assets = {}
local v14 = {
	assets = 0,
	loops = 0
}

for i, v15 in ipairs(v11) do
	assetids[i] = "rbxassetid://" .. tostring(v15)
end

assets.assetids1 = assetids
local v15 = {
	132116169898954,
	74340613478069,
	123596432170532,
	128289947742381,
	139393201713791,
	120415723058067,
	114764461921205,
	79607838103641,
	93577246948532,
	121251176648758,
	138014516845652,
	93455996108260,
	70951886834878,
	122695876026937,
	83024271728045,
	86821784707153,
	91650154541648,
	88764848502424,
	100840343749074,
	86052582465782,
	96229516091769,
	93595891156113,
	85776782921713,
	121766889517779,
	113384947078207,
	103877181369181,
	101813319674031,
	134396514967520,
	105105298336556,
	110226855342839,
	101844059497356,
	118510359748448,
	99559136086020,
	128479562678335,
	77540612657770,
	121895148742828,
	127704329042881,
	122084713657789,
	96474897959195,
	135497192263580,
	114747252293142,
	71148484766025,
	84632087399105,
	98083356291547,
	86117192104594,
	86350743823511,
	120220760670806,
	133497920657798,
	138907318131817,
	128838343818968,
	113467931555756,
	75925363257239,
	77220009742015,
	117965030785876,
	82456220024534,
	80786907097362,
	127165993392493,
	92260601978728,
	76906915517479,
	131652213581219,
	131647700662791,
	133662531572567,
	75749289193152,
	75200239510292,
	122143588829697,
	91648864068745,
	119963452585947,
	129994197905307,
	114674390937674,
	77601037408781,
	85190530765607,
	119351900219509,
	84114122343609,
	119540987191252,
	129987826972483,
	135045643181809,
	139133188739652,
	107238281869738,
	102858346574553,
	140042260855340,
	72251035588830,
	101283411894079,
	105420045398610,
	108480342603156,
	87535497845777,
	139891091529065,
	73106326402087,
	122572039873808,
	126847730352073,
	110758952410293,
	89000912738846,
	80463682505143,
	137213011743248,
	105495432666390,
	134069446127433,
	75992237473823,
	124014579847049,
	115416557532205,
	101159582285502,
	75546308552164
}
local linesassetids = table.create(#v15)

for i, v17 in ipairs(v15) do
	linesassetids[i] = "rbxassetid://" .. tostring(v17)
end

assets.linesassetids = linesassetids
local v17 = {
	84953323457789,
	112632531138201,
	136711237178374,
	116986463231440,
	74072539123371,
	73765513496962,
	82864485098244,
	131385159488889,
	87652804799816,
	116688883990899,
	117384003912484,
	139587187277507,
	109696181449236,
	129009438323401,
	139860883456103,
	127643618308992,
	97023629456021,
	138850017174036,
	134557366317952,
	77676971521208,
	71170816976789,
	140036620543106,
	89420929491589,
	73075172602612,
	127571239586665,
	112892222298663,
	123729537664950,
	126892259535247,
	118397579788713,
	94106961436936,
	122910673866157,
	120712627770965,
	87062605911882,
	87978019398021,
	138184526662491,
	119049813074345,
	78444516545777,
	135407132510535,
	109517047176533,
	111928154015348,
	119295697081092,
	121652757234586,
	129028209464936,
	100334079969519,
	95596487585787,
	130404225063406,
	113507615867572,
	114199698082272,
	88202133237485,
	134331870956094,
	114290915804638,
	118384021114780,
	100236020607230,
	107859936395739,
	105559739940225,
	73419515283572,
	76031212272582,
	79694917666786,
	133455551220681,
	124445177288274,
	100678652585256,
	88023351824366,
	123510658128173,
	76557343274821,
	102540976497663,
	111483215880611,
	120178867116503,
	113763456474319,
	109853902573814,
	80219809013737,
	76673025160756,
	114187749257280,
	123288839249583,
	94293136400001,
	129090027990800,
	72775633912444,
	89618462513761,
	136605979146295,
	72447087341247,
	75275036150958,
	88595367955564,
	103682663063903,
	102601868015623,
	128423924688152,
	116598678677170,
	113832803444790,
	115022307778538,
	81980344045484,
	89054597919994,
	91116561627114,
	110913834681471,
	87280344269771,
	126571576317306,
	72708081397549,
	88469412166440,
	83761652504213
}
local shockwaveassetids = table.create(#v17)

for i, v19 in ipairs(v17) do
	shockwaveassetids[i] = "rbxassetid://" .. tostring(v19)
end

assets.shockwaveassetids = shockwaveassetids
v14.assets = assets
v14.loops = {
	{
		path = {
			"Mesh",
			"Main",
			"Waveloop0",
			"Decal"
		},
		assets = "assetids1",
		duration = 1
	},
	{
		path = {
			"Mesh",
			"Main",
			"Waveloop1",
			"Overlay"
		},
		assets = "assetids1",
		duration = 1
	},
	{
		path = {
			"Mesh",
			"Main",
			"Waveloop2",
			"Overlay"
		},
		assets = "assetids1",
		duration = 1
	},
	{
		path = {
			"Mesh",
			"Main",
			"Waveloop3",
			"Overlay"
		},
		assets = "assetids1",
		duration = 1
	},
	{
		path = {
			"Mesh",
			"Main",
			"Waveloop4",
			"Overlay"
		},
		assets = "assetids1",
		duration = 1
	},
	{
		path = {
			"Mesh",
			"Char",
			"SwordMesh",
			"Decal1"
		},
		assets = "assetids1",
		duration = 1
	},
	{
		path = {
			"Mesh",
			"Char",
			"HeadF",
			"Wave"
		},
		assets = "assetids1",
		duration = 1
	},
	{
		path = {
			"Mesh",
			"Char",
			"Left ArmF",
			"Wave1"
		},
		assets = "assetids1",
		duration = 1
	},
	{
		path = {
			"Mesh",
			"Char",
			"Left ArmF",
			"Wave2"
		},
		assets = "assetids1",
		duration = 1
	},
	{
		path = {
			"Mesh",
			"Char",
			"Left ArmF",
			"Wave3"
		},
		assets = "assetids1",
		duration = 1
	},
	{
		path = {
			"Mesh",
			"Char",
			"Left ArmF",
			"Wave4"
		},
		assets = "assetids1",
		duration = 1
	},
	{
		path = {
			"Mesh",
			"Char",
			"Left LegF",
			"Wave1"
		},
		assets = "assetids1",
		duration = 1
	},
	{
		path = {
			"Mesh",
			"Char",
			"Left LegF",
			"Wave2"
		},
		assets = "assetids1",
		duration = 1
	},
	{
		path = {
			"Mesh",
			"Char",
			"Left LegF",
			"Wave3"
		},
		assets = "assetids1",
		duration = 1
	},
	{
		path = {
			"Mesh",
			"Char",
			"Left LegF",
			"Wave4"
		},
		assets = "assetids1",
		duration = 1
	},
	{
		path = {
			"Mesh",
			"Char",
			"Right ArmF",
			"Wave1"
		},
		assets = "assetids1",
		duration = 1
	},
	{
		path = {
			"Mesh",
			"Char",
			"Right ArmF",
			"Wave2"
		},
		assets = "assetids1",
		duration = 1
	},
	{
		path = {
			"Mesh",
			"Char",
			"Right ArmF",
			"Wave3"
		},
		assets = "assetids1",
		duration = 1
	},
	{
		path = {
			"Mesh",
			"Char",
			"Right ArmF",
			"Wave4"
		},
		assets = "assetids1",
		duration = 1
	},
	{
		path = {
			"Mesh",
			"Char",
			"Right LegF",
			"Wave1"
		},
		assets = "assetids1",
		duration = 1
	},
	{
		path = {
			"Mesh",
			"Char",
			"Right LegF",
			"Wave2"
		},
		assets = "assetids1",
		duration = 1
	},
	{
		path = {
			"Mesh",
			"Char",
			"Right LegF",
			"Wave3"
		},
		assets = "assetids1",
		duration = 1
	},
	{
		path = {
			"Mesh",
			"Char",
			"Right LegF",
			"Wave4"
		},
		assets = "assetids1",
		duration = 1
	},
	{
		path = {
			"Mesh",
			"Char",
			"TorsoF",
			"Wave1"
		},
		assets = "assetids1",
		duration = 1
	},
	{
		path = {
			"Mesh",
			"Char",
			"TorsoF",
			"Wave2"
		},
		assets = "assetids1",
		duration = 1
	},
	{
		path = {
			"Mesh",
			"Char",
			"TorsoF",
			"Wave3"
		},
		assets = "assetids1",
		duration = 1
	},
	{
		path = {
			"Mesh",
			"Char",
			"TorsoF",
			"Wave4"
		},
		assets = "assetids1",
		duration = 1
	},
	{
		path = {
			"Mesh",
			"Pilar",
			"Wind",
			"Decal1"
		},
		assets = "shockwaveassetids",
		duration = 1
	},
	{
		path = {
			"Mesh",
			"Pilar",
			"Wind1",
			"Decal1"
		},
		assets = "shockwaveassetids",
		duration = 1
	},
	{
		path = {
			"Mesh",
			"Pilar",
			"Wind2",
			"Decal1"
		},
		assets = "shockwaveassetids",
		duration = 1
	},
	{
		path = {
			"Mesh",
			"Pilar",
			"WindD",
			"Decal1"
		},
		assets = "shockwaveassetids",
		duration = 1
	},
	{
		path = {
			"Mesh",
			"Pilar",
			"WindL",
			"Decal1"
		},
		assets = "linesassetids",
		duration = 1
	},
	{
		path = {
			"Mesh",
			"Pilar",
			"WindL1",
			"Decal1"
		},
		assets = "linesassetids",
		duration = 1
	}
}
local FrameEvents = {
	frame_events = {},
	preload_assets = {},
	length_frames = 2019,
	camera_part_keyframes = {
		[0] = {
			object = "camera_rig",
			part = "CamPart"
		},
		[296] = {
			object = "camera_rig1",
			part = "CamPart"
		},
		[660] = {
			object = "camera_rig",
			part = "CamPart"
		},
		[1420] = false,
		[1719] = {
			object = "camera_rig",
			part = "CamPart"
		}
	},
	property_keyframes = {
		{
			name = "game.Workspace.rockrig.Transparency",
			target = {
				root = "vfx",
				path = { "rockrig" },
				relative_to_origin = true
			},
			property = "Transparency",
			value_type = "number",
			values = {
				[0] = 1
			}
		},
		{
			name = "game.Workspace.CurrentCamera.FieldOfView",
			target = {
				root = "camera",
				path = {}
			},
			property = "FieldOfView",
			value_type = "number",
			eases = {
				["1325"] = {
					Direction = "Out",
					Type = "Expo"
				},
				["1719"] = {
					Direction = "InOut",
					Type = "Expo"
				},
				["296"] = {
					Direction = "Out",
					Type = "Sine"
				},
				["370"] = {
					Direction = "Out",
					Type = "Sine"
				},
				["371"] = {
					Direction = "Out",
					Type = "Back"
				}
			},
			values = {
				[0] = 45,
				[53] = 30,
				[74] = 36,
				[85] = 44,
				[88] = 30,
				[97] = 19,
				[270] = 19,
				[291] = 24,
				[295] = 24,
				[296] = 32,
				[370] = 20,
				[371] = 20,
				[424] = 23.205,
				[1027] = 23.20547866821289,
				[1056] = 19,
				[1075] = 14.681818181818182,
				[1081] = 14.219178063528878,
				[1102] = 18,
				[1189] = 10,
				[1204] = 23.20547866821289,
				[1205] = 4,
				[1220] = 23,
				[1258] = 37,
				[1265] = 33,
				[1305] = 33,
				[1307] = 3,
				[1325] = 60,
				[1356] = 80,
				[1718] = 80,
				[1719] = 15,
				[1901] = 13
			}
		},
		{
			name = "game.Lighting.ClockTime",
			target = {
				root = "lighting",
				path = {}
			},
			property = "ClockTime",
			value_type = "number",
			values = {
				[0] = 3,
				[1417] = 4.5,
				[1458] = 4.5
			}
		},
		{
			name = "game.Workspace.Fx.Mesh.Main.Waveloop0.Decal.Transparency",
			target = {
				root = "vfx",
				path = {
					"Mesh",
					"Main",
					"Waveloop0",
					"Decal"
				},
				relative_to_origin = true
			},
			property = "Transparency",
			value_type = "number",
			values = {
				[0] = 1,
				[91] = 1,
				[104] = 0,
				[1263] = 0,
				[1265] = 1
			}
		},
		{
			name = "game.Workspace.Fx.Mesh.Main.Waveloop1.Overlay.Transparency",
			target = {
				root = "vfx",
				path = {
					"Mesh",
					"Main",
					"Waveloop1",
					"Overlay"
				},
				relative_to_origin = true
			},
			property = "Transparency",
			value_type = "number",
			values = {
				[0] = 1,
				[91] = 1,
				[104] = 0,
				[1263] = 0,
				[1265] = 1
			}
		},
		{
			name = "game.Workspace.Fx.Mesh.Main.Waveloop2.Overlay.Transparency",
			target = {
				root = "vfx",
				path = {
					"Mesh",
					"Main",
					"Waveloop2",
					"Overlay"
				},
				relative_to_origin = true
			},
			property = "Transparency",
			value_type = "number",
			values = {
				[0] = 1,
				[91] = 1,
				[104] = 0,
				[1263] = 0,
				[1265] = 1
			}
		},
		{
			name = "game.Workspace.Fx.Mesh.Main.Waveloop3.Overlay.Transparency",
			target = {
				root = "vfx",
				path = {
					"Mesh",
					"Main",
					"Waveloop3",
					"Overlay"
				},
				relative_to_origin = true
			},
			property = "Transparency",
			value_type = "number",
			values = {
				[0] = 1,
				[91] = 1,
				[104] = 0,
				[1263] = 0,
				[1265] = 1
			}
		},
		{
			name = "game.Workspace.Fx.Mesh.Main.Waveloop4.Overlay.Transparency",
			target = {
				root = "vfx",
				path = {
					"Mesh",
					"Main",
					"Waveloop4",
					"Overlay"
				},
				relative_to_origin = true
			},
			property = "Transparency",
			value_type = "number",
			values = {
				[0] = 1,
				[91] = 1,
				[104] = 0,
				[1263] = 0,
				[1265] = 1
			}
		},
		{
			name = "game.Workspace.Fx.Mesh.Char.HeadF.Wave.Transparency",
			target = {
				root = "vfx",
				path = {
					"Mesh",
					"Char",
					"HeadF",
					"Wave"
				},
				relative_to_origin = true
			},
			property = "Transparency",
			value_type = "number",
			values = {
				[0] = 1,
				[94] = 1,
				[101] = 0,
				[1264] = 0,
				[1267] = 1
			}
		},
		{
			name = "game.Workspace.Fx.Mesh.Char.Left ArmF.Wave1.Transparency",
			target = {
				root = "vfx",
				path = {
					"Mesh",
					"Char",
					"Left ArmF",
					"Wave1"
				},
				relative_to_origin = true
			},
			property = "Transparency",
			value_type = "number",
			values = {
				[0] = 1,
				[94] = 1,
				[101] = 0,
				[1264] = 0,
				[1267] = 1
			}
		},
		{
			name = "game.Workspace.Fx.Mesh.Char.Left ArmF.Wave2.Transparency",
			target = {
				root = "vfx",
				path = {
					"Mesh",
					"Char",
					"Left ArmF",
					"Wave2"
				},
				relative_to_origin = true
			},
			property = "Transparency",
			value_type = "number",
			values = {
				[0] = 1,
				[94] = 1,
				[101] = 0,
				[1264] = 0,
				[1267] = 1
			}
		},
		{
			name = "game.Workspace.Fx.Mesh.Char.Left ArmF.Wave3.Transparency",
			target = {
				root = "vfx",
				path = {
					"Mesh",
					"Char",
					"Left ArmF",
					"Wave3"
				},
				relative_to_origin = true
			},
			property = "Transparency",
			value_type = "number",
			values = {
				[0] = 1,
				[94] = 1,
				[101] = 0,
				[1264] = 0,
				[1267] = 1
			}
		},
		{
			name = "game.Workspace.Fx.Mesh.Char.Left ArmF.Wave4.Transparency",
			target = {
				root = "vfx",
				path = {
					"Mesh",
					"Char",
					"Left ArmF",
					"Wave4"
				},
				relative_to_origin = true
			},
			property = "Transparency",
			value_type = "number",
			values = {
				[0] = 1,
				[94] = 1,
				[101] = 0,
				[1264] = 0,
				[1267] = 1
			}
		},
		{
			name = "game.Workspace.Fx.Mesh.Char.Left LegF.Wave1.Transparency",
			target = {
				root = "vfx",
				path = {
					"Mesh",
					"Char",
					"Left LegF",
					"Wave1"
				},
				relative_to_origin = true
			},
			property = "Transparency",
			value_type = "number",
			values = {
				[0] = 1,
				[94] = 1,
				[101] = 0,
				[1264] = 0,
				[1267] = 1
			}
		},
		{
			name = "game.Workspace.Fx.Mesh.Char.Left LegF.Wave2.Transparency",
			target = {
				root = "vfx",
				path = {
					"Mesh",
					"Char",
					"Left LegF",
					"Wave2"
				},
				relative_to_origin = true
			},
			property = "Transparency",
			value_type = "number",
			values = {
				[0] = 1,
				[94] = 1,
				[101] = 0,
				[1264] = 0,
				[1267] = 1
			}
		},
		{
			name = "game.Workspace.Fx.Mesh.Char.Left LegF.Wave3.Transparency",
			target = {
				root = "vfx",
				path = {
					"Mesh",
					"Char",
					"Left LegF",
					"Wave3"
				},
				relative_to_origin = true
			},
			property = "Transparency",
			value_type = "number",
			values = {
				[0] = 1,
				[94] = 1,
				[101] = 0,
				[1264] = 0,
				[1267] = 1
			}
		},
		{
			name = "game.Workspace.Fx.Mesh.Char.Left LegF.Wave4.Transparency",
			target = {
				root = "vfx",
				path = {
					"Mesh",
					"Char",
					"Left LegF",
					"Wave4"
				},
				relative_to_origin = true
			},
			property = "Transparency",
			value_type = "number",
			values = {
				[0] = 1,
				[94] = 1,
				[101] = 0,
				[1264] = 0,
				[1267] = 1
			}
		},
		{
			name = "game.Workspace.Fx.Mesh.Char.Right ArmF.Wave1.Transparency",
			target = {
				root = "vfx",
				path = {
					"Mesh",
					"Char",
					"Right ArmF",
					"Wave1"
				},
				relative_to_origin = true
			},
			property = "Transparency",
			value_type = "number",
			values = {
				[0] = 1,
				[94] = 1,
				[101] = 0,
				[1264] = 0,
				[1267] = 1
			}
		},
		{
			name = "game.Workspace.Fx.Mesh.Char.Right ArmF.Wave2.Transparency",
			target = {
				root = "vfx",
				path = {
					"Mesh",
					"Char",
					"Right ArmF",
					"Wave2"
				},
				relative_to_origin = true
			},
			property = "Transparency",
			value_type = "number",
			values = {
				[0] = 1,
				[94] = 1,
				[101] = 0,
				[1264] = 0,
				[1267] = 1
			}
		},
		{
			name = "game.Workspace.Fx.Mesh.Char.Right ArmF.Wave3.Transparency",
			target = {
				root = "vfx",
				path = {
					"Mesh",
					"Char",
					"Right ArmF",
					"Wave3"
				},
				relative_to_origin = true
			},
			property = "Transparency",
			value_type = "number",
			values = {
				[0] = 1,
				[94] = 1,
				[101] = 0,
				[1264] = 0,
				[1267] = 1
			}
		},
		{
			name = "game.Workspace.Fx.Mesh.Char.Right ArmF.Wave4.Transparency",
			target = {
				root = "vfx",
				path = {
					"Mesh",
					"Char",
					"Right ArmF",
					"Wave4"
				},
				relative_to_origin = true
			},
			property = "Transparency",
			value_type = "number",
			values = {
				[0] = 1,
				[94] = 1,
				[101] = 0,
				[1264] = 0,
				[1267] = 1
			}
		},
		{
			name = "game.Workspace.Fx.Mesh.Char.Right LegF.Wave1.Transparency",
			target = {
				root = "vfx",
				path = {
					"Mesh",
					"Char",
					"Right LegF",
					"Wave1"
				},
				relative_to_origin = true
			},
			property = "Transparency",
			value_type = "number",
			values = {
				[0] = 1,
				[94] = 1,
				[101] = 0,
				[1264] = 0,
				[1267] = 1
			}
		},
		{
			name = "game.Workspace.Fx.Mesh.Char.Right LegF.Wave2.Transparency",
			target = {
				root = "vfx",
				path = {
					"Mesh",
					"Char",
					"Right LegF",
					"Wave2"
				},
				relative_to_origin = true
			},
			property = "Transparency",
			value_type = "number",
			values = {
				[0] = 1,
				[94] = 1,
				[101] = 0,
				[1264] = 0,
				[1267] = 1
			}
		},
		{
			name = "game.Workspace.Fx.Mesh.Char.Right LegF.Wave3.Transparency",
			target = {
				root = "vfx",
				path = {
					"Mesh",
					"Char",
					"Right LegF",
					"Wave3"
				},
				relative_to_origin = true
			},
			property = "Transparency",
			value_type = "number",
			values = {
				[0] = 1,
				[94] = 1,
				[101] = 0,
				[1264] = 0,
				[1267] = 1
			}
		},
		{
			name = "game.Workspace.Fx.Mesh.Char.Right LegF.Wave4.Transparency",
			target = {
				root = "vfx",
				path = {
					"Mesh",
					"Char",
					"Right LegF",
					"Wave4"
				},
				relative_to_origin = true
			},
			property = "Transparency",
			value_type = "number",
			values = {
				[0] = 1,
				[94] = 1,
				[101] = 0,
				[1264] = 0,
				[1267] = 1
			}
		},
		{
			name = "game.Workspace.Fx.Mesh.Char.TorsoF.Wave1.Transparency",
			target = {
				root = "vfx",
				path = {
					"Mesh",
					"Char",
					"TorsoF",
					"Wave1"
				},
				relative_to_origin = true
			},
			property = "Transparency",
			value_type = "number",
			values = {
				[0] = 1,
				[94] = 1,
				[101] = 0,
				[1264] = 0,
				[1267] = 1
			}
		},
		{
			name = "game.Workspace.Fx.Mesh.Char.TorsoF.Wave2.Transparency",
			target = {
				root = "vfx",
				path = {
					"Mesh",
					"Char",
					"TorsoF",
					"Wave2"
				},
				relative_to_origin = true
			},
			property = "Transparency",
			value_type = "number",
			values = {
				[0] = 1,
				[94] = 1,
				[101] = 0,
				[1264] = 0,
				[1267] = 1
			}
		},
		{
			name = "game.Workspace.Fx.Mesh.Char.TorsoF.Wave3.Transparency",
			target = {
				root = "vfx",
				path = {
					"Mesh",
					"Char",
					"TorsoF",
					"Wave3"
				},
				relative_to_origin = true
			},
			property = "Transparency",
			value_type = "number",
			values = {
				[0] = 1,
				[94] = 1,
				[101] = 0,
				[1264] = 0,
				[1267] = 1
			}
		},
		{
			name = "game.Workspace.Fx.Mesh.Char.TorsoF.Wave4.Transparency",
			target = {
				root = "vfx",
				path = {
					"Mesh",
					"Char",
					"TorsoF",
					"Wave4"
				},
				relative_to_origin = true
			},
			property = "Transparency",
			value_type = "number",
			values = {
				[0] = 1,
				[94] = 1,
				[101] = 0,
				[1264] = 0,
				[1267] = 1
			}
		},
		{
			name = "game.Lighting.DepthOfField.FarIntensity",
			target = {
				root = "lighting",
				path = { "DepthOfField" }
			},
			property = "FarIntensity",
			value_type = "number",
			values = {
				[0] = 0,
				[11] = 1,
				[44] = 1,
				[89] = 1,
				[101] = 1,
				[119] = 1,
				[126] = 1,
				[150] = 1,
				[162] = 1,
				[166] = 1,
				[173] = 1,
				[177] = 1,
				[187] = 1,
				[194] = 1,
				[278] = 1,
				[303] = 1,
				[347] = 1,
				[734] = 1,
				[864] = 1,
				[1016] = 1,
				[1034] = 1,
				[1180] = 1,
				[1237] = 1,
				[1299] = 1
			}
		},
		{
			name = "game.Lighting.DepthOfField.FocusDistance",
			target = {
				root = "lighting",
				path = { "DepthOfField" }
			},
			property = "FocusDistance",
			value_type = "number",
			values = {
				[0] = 0,
				[11] = 0,
				[44] = 4.840000152587891,
				[89] = 4.840000152587891,
				[101] = 4.840000152587891,
				[119] = 0,
				[126] = 9.699999809265137,
				[150] = 12.119999885559082,
				[162] = 12.119999885559082,
				[166] = 0,
				[173] = 0,
				[177] = 5,
				[187] = 0.6000000238418579,
				[194] = 5,
				[278] = 5,
				[303] = 16.959999084472656,
				[347] = 5,
				[734] = 5,
				[864] = 8.5,
				[1016] = 8.5,
				[1034] = 2.5,
				[1180] = 2.5,
				[1237] = 31.520000457763672,
				[1299] = 10.899999618530273
			}
		},
		{
			name = "game.Lighting.DepthOfField.InFocusRadius",
			target = {
				root = "lighting",
				path = { "DepthOfField" }
			},
			property = "InFocusRadius",
			value_type = "number",
			values = {
				[0] = 0,
				[11] = 0,
				[44] = 0,
				[89] = 0,
				[101] = 0,
				[119] = 6,
				[126] = 6,
				[150] = 6,
				[162] = 6,
				[166] = 0,
				[173] = 0,
				[177] = 0,
				[187] = 0,
				[194] = 0,
				[278] = 0,
				[303] = 0,
				[347] = 0,
				[734] = 0,
				[864] = 0,
				[1016] = 0,
				[1034] = 0,
				[1180] = 0,
				[1237] = 0,
				[1299] = 17.274999618530273
			}
		},
		{
			name = "game.Lighting.DepthOfField.NearIntensity",
			target = {
				root = "lighting",
				path = { "DepthOfField" }
			},
			property = "NearIntensity",
			value_type = "number",
			values = {
				[0] = 0,
				[11] = 1,
				[44] = 1,
				[89] = 1,
				[101] = 1,
				[119] = 1,
				[126] = 1,
				[150] = 1,
				[162] = 1,
				[166] = 1,
				[173] = 1,
				[177] = 1,
				[187] = 1,
				[194] = 1,
				[278] = 1,
				[303] = 1,
				[347] = 1,
				[734] = 1,
				[864] = 1,
				[1016] = 1,
				[1034] = 1,
				[1180] = 1,
				[1237] = 1,
				[1299] = 1
			}
		},
		{
			name = "game.Workspace.Fx.Mesh.Char.SwordMesh.Decal1.Transparency",
			target = {
				root = "vfx",
				path = {
					"Mesh",
					"Char",
					"SwordMesh",
					"Decal1"
				},
				relative_to_origin = true
			},
			property = "Transparency",
			value_type = "number",
			values = {
				[0] = 1,
				[565] = 1,
				[625] = 0,
				[1231] = 0,
				[1271] = 1
			}
		},
		{
			name = "game.Workspace.Fx.Mesh.Main.Waveloop0.Transparency",
			target = {
				root = "vfx",
				path = { "Mesh", "Main", "Waveloop0" },
				relative_to_origin = true
			},
			property = "Transparency",
			value_type = "number",
			values = {
				[0] = 1,
				[79] = 1,
				[114] = 0.550000011920929,
				[1231] = 0.550000011920929,
				[1296] = 1
			}
		},
		{
			name = "game.Workspace.Fx.Mesh.Main.Waveloop3.Transparency",
			target = {
				root = "vfx",
				path = { "Mesh", "Main", "Waveloop3" },
				relative_to_origin = true
			},
			property = "Transparency",
			value_type = "number",
			values = {
				[0] = 1,
				[79] = 1,
				[114] = 0.550000011920929,
				[1231] = 0.550000011920929,
				[1296] = 1
			}
		},
		{
			name = "game.Workspace.Fx.AuraChargeFx.ChargeFx.P.PointLight.Brightness",
			target = {
				root = "vfx",
				path = {
					"AuraChargeFx",
					"ChargeFx",
					"P",
					"PointLight"
				},
				relative_to_origin = true
			},
			property = "Brightness",
			value_type = "number",
			values = {
				[0] = 0,
				[87] = 0,
				[95] = 15,
				[113] = 3,
				[294] = 3,
				[296] = 0,
				[659] = 0,
				[661] = 3,
				[1255] = 3
			}
		},
		{
			name = "game.Workspace.Fx.AuraChargeFx.ChargeFx.P.PointLight.Range",
			target = {
				root = "vfx",
				path = {
					"AuraChargeFx",
					"ChargeFx",
					"P",
					"PointLight"
				},
				relative_to_origin = true
			},
			property = "Range",
			value_type = "number",
			eases = {
				["1255"] = {
					Direction = "Out",
					Type = "Expo"
				}
			},
			values = {
				[0] = 72,
				[1255] = 72,
				[1285] = 0
			}
		},
		{
			name = "game.Workspace.CameraRig1.CFrame",
			target = {
				root = "camera_rig1",
				path = {},
				relative_to_origin = true
			},
			property = "CFrame",
			value_type = "CFrame",
			relative_to_origin = true,
			values = {
				[0] = CFrame.new(0, 3, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
				[296] = CFrame.new(0, -50, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
				[307] = CFrame.new(0, -50, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
			}
		},
		{
			name = "game.Workspace.Fx.bomb.CFrame",
			target = {
				root = "vfx",
				path = { "bomb" },
				relative_to_origin = true
			},
			property = "CFrame",
			value_type = "CFrame",
			relative_to_origin = true,
			values = {
				[0] = CFrame.new(
					0,
					-35.23577117919922,
					-17.019174575805664,
					1,
					0,
					0,
					0,
					0.8930652141571045,
					0.4499269723892212,
					0,
					-0.4499269723892212,
					0.8930652141571045
				),
				[296] = CFrame.new(
					0,
					-35.23577117919922,
					-17.019174575805664,
					1,
					0,
					0,
					0,
					0.893065333366394,
					0.4499269723892212,
					0,
					-0.4499269723892212,
					0.893065333366394
				),
				[370] = CFrame.new(
					0,
					-35.23577117919922,
					-17.019174575805664,
					-0.9987570643424988,
					1.5080811976986297e-7,
					0.04984339699149132,
					-0.022425753995776176,
					0.893065333366394,
					-0.4493677020072937,
					-0.04451347514986992,
					-0.4499269425868988,
					-0.8919553160667419
				),
				[371] = CFrame.new(
					0,
					-48.66279983520508,
					-1.6672559976577759,
					0.9987570643424988,
					0,
					0.04984339699149132,
					-0.02242589183151722,
					0.893065333366394,
					0.44936779141426086,
					-0.044513408094644547,
					-0.44992703199386597,
					0.8919553160667419
				),
				[493] = CFrame.new(
					0,
					-48.66279983520508,
					-1.6672561168670654,
					-0.8556556105613708,
					0,
					0.5175455808639526,
					-0.23285777866840363,
					0.893065333366394,
					-0.38498249650001526,
					-0.4622020721435547,
					-0.4499269723892212,
					-0.7641562223434448
				),
				[494] = CFrame.new(
					0,
					-89.92562103271484,
					-1.6672561168670654,
					1,
					0,
					0,
					0,
					0.8930652141571045,
					0.4499269723892212,
					0,
					-0.4499269723892212,
					0.8930652141571045
				)
			}
		},
		{
			name = "game.Workspace.Fx.bomb.Size",
			target = {
				root = "vfx",
				path = { "bomb" },
				relative_to_origin = true
			},
			property = "Size",
			value_type = "Vector3",
			values = {
				[0] = vector.create(0.42331308, 0.90359914, 0.42331308)
			}
		},
		{
			name = "game.Lighting.ColorSkills.Brightness",
			target = {
				root = "lighting",
				path = { "ColorSkills" }
			},
			property = "Brightness",
			value_type = "number",
			eases = {
				["1406"] = {
					Direction = "Out",
					Type = "Sine"
				}
			},
			values = {
				[0] = 0,
				[284] = 0,
				[291] = -1,
				[292] = -1,
				[298] = -0.8,
				[307] = -0.19999999999999996,
				[313] = -0.10000000149011612,
				[336] = 0,
				[349] = 0,
				[370] = 0,
				[371] = -0.04999999701976776,
				[493] = -0.04999999701976776,
				[494] = 0,
				[498] = 0,
				[513] = 0,
				[528] = 0.15,
				[552] = 0.7,
				[580] = 15,
				[660] = 5,
				[662] = 0,
				[1061] = 0,
				[1062] = -15,
				[1074] = 0,
				[1270] = 0,
				[1279] = 0.15,
				[1298] = 0.10000000149011612,
				[1308] = 0.10000000149011612,
				[1312] = 0.20000000298023224,
				[1342] = 0.20000000298023224,
				[1406] = 0.20000000298023224,
				[1420] = 1.25,
				[1710] = 1.25,
				[1749] = 0
			}
		},
		{
			name = "game.Lighting.ColorSkills.Contrast",
			target = {
				root = "lighting",
				path = { "ColorSkills" }
			},
			property = "Contrast",
			value_type = "number",
			values = {
				[0] = 0,
				[284] = 0,
				[313] = 0,
				[333] = 0.25,
				[349] = 0.05000000074505806,
				[370] = 0.05000000074505806,
				[371] = 0.5,
				[493] = 0.5,
				[494] = 0,
				[498] = 0,
				[513] = 0,
				[528] = -0.19999999999999998,
				[552] = -0.3,
				[580] = -55,
				[660] = -55,
				[662] = 0,
				[1061] = 0,
				[1062] = -66,
				[1074] = 0,
				[1270] = 0,
				[1279] = 0.20000000298023224,
				[1298] = 0.30000001192092896,
				[1308] = 0.30000001192092896,
				[1312] = 0.6000000238418579,
				[1342] = 0.85,
				[1398] = 0.85,
				[1427] = 0.6000000238418579,
				[1441] = 0
			}
		},
		{
			name = "game.Lighting.ColorSkills.Saturation",
			target = {
				root = "lighting",
				path = { "ColorSkills" }
			},
			property = "Saturation",
			value_type = "number",
			values = {
				[0] = 0,
				[284] = 0,
				[313] = 0,
				[349] = 0.20000000298023224,
				[370] = 0.20000000298023224,
				[371] = 0.20000000298023224,
				[493] = 0.20000000298023224,
				[494] = 0,
				[498] = 0,
				[513] = 0,
				[580] = -1,
				[660] = -1,
				[662] = 0,
				[1061] = 0,
				[1062] = -1,
				[1071] = -1,
				[1077] = -0.7999999999999999,
				[1085] = -0.5,
				[1115] = 0,
				[1270] = 0,
				[1279] = 0.30000001192092896,
				[1298] = -0.6000000238418579,
				[1308] = -0.6000000238418579,
				[1312] = 0,
				[1342] = 0.30000001192092896,
				[1427] = 0.30000001192092896,
				[1441] = 0
			}
		},
		{
			name = "game.Lighting.ColorSkills.TintColor",
			target = {
				root = "lighting",
				path = { "ColorSkills" }
			},
			property = "TintColor",
			value_type = "Color3",
			values = {
				[0] = Color3.new(1, 1, 1),
				[284] = Color3.new(1, 1, 1),
				[313] = Color3.new(1, 1, 1),
				[349] = Color3.new(1, 1, 1),
				[370] = Color3.new(1, 1, 1),
				[371] = Color3.new(1, 1, 1),
				[493] = Color3.new(1, 1, 1),
				[494] = Color3.new(1, 1, 1),
				[498] = Color3.new(1, 1, 1),
				[513] = Color3.new(1, 1, 1),
				[528] = Color3.new(1, 0.8581243753433228, 0.7333333492279053),
				[580] = Color3.new(1, 1, 1),
				[660] = Color3.new(1, 1, 1),
				[662] = Color3.new(1, 1, 1),
				[1061] = Color3.new(1, 1, 1),
				[1062] = Color3.new(1, 1, 1),
				[1074] = Color3.new(1, 1, 1),
				[1270] = Color3.new(1, 1, 1),
				[1279] = Color3.new(1, 1, 1),
				[1288] = Color3.new(1, 1, 1),
				[1298] = Color3.new(0.7960785031318665, 0.615686297416687, 1),
				[1308] = Color3.new(0.7960785031318665, 0.615686297416687, 1),
				[1312] = Color3.new(0.988235354423523, 0.6823529601097107, 1),
				[1342] = Color3.new(1, 1, 1),
				[1427] = Color3.new(1, 1, 1),
				[1441] = Color3.new(1, 1, 1)
			}
		},
		{
			name = "game.Workspace.Fx.NuclearFx.Fx2.Part.Transparency",
			target = {
				root = "vfx",
				path = { "NuclearFx", "Fx2", "Part" },
				relative_to_origin = true
			},
			property = "Transparency",
			value_type = "number",
			values = {
				[0] = 1,
				[369] = 1,
				[371] = 0
			}
		},
		{
			name = "game.Workspace.Fx.NuclearFx.Fx2.PointLight.Brightness",
			target = {
				root = "vfx",
				path = { "NuclearFx", "Fx2", "PointLight" },
				relative_to_origin = true
			},
			property = "Brightness",
			value_type = "number",
			eases = {
				["584"] = {
					Direction = "Out",
					Type = "Expo"
				}
			},
			values = {
				[0] = 0,
				[493] = 0,
				[494] = 2,
				[498] = 2,
				[553] = 5,
				[584] = 125,
				[660] = 0
			}
		},
		{
			name = "game.Workspace.CameraRig1.CamPart.Beams.M3.A.Beams.Color",
			target = {
				root = "camera_rig1",
				path = {
					"CamPart",
					"Beams",
					"M3",
					"A",
					"Beams"
				},
				relative_to_origin = true
			},
			property = "Color",
			value_type = "Color3",
			property_type = "ColorSequence",
			values = {
				[0] = Color3.new(0, 0, 0),
				[493] = Color3.new(0, 0, 0),
				[494] = Color3.new(1, 0.5921568870544434, 0.25882354378700256),
				[500] = Color3.new(0.3019607961177826, 0.1791478991508484, 0.078154556453228),
				[509] = Color3.new(1, 0.5932819843292236, 0.2588235139846802),
				[519] = Color3.new(0, 0, 0),
				[526] = Color3.new(1, 0.5932819843292236, 0.2588235139846802),
				[534] = Color3.new(0, 0, 0),
				[537] = Color3.new(1, 0.5932819843292236, 0.2588235139846802),
				[542] = Color3.new(0, 0, 0)
			}
		},
		{
			name = "game.Workspace.CameraRig1.CamPart.Beams.M3.A.Beams.TextureLength",
			target = {
				root = "camera_rig1",
				path = {
					"CamPart",
					"Beams",
					"M3",
					"A",
					"Beams"
				},
				relative_to_origin = true
			},
			property = "TextureLength",
			value_type = "number",
			eases = {
				["494"] = {
					Direction = "Out",
					Type = "Sine"
				}
			},
			values = {
				[0] = 1.375,
				[494] = 1.375,
				[558] = 0.5
			}
		},
		{
			name = "game.Workspace.Fx.bomb.Highlight.FillTransparency",
			target = {
				root = "vfx",
				path = { "bomb", "Highlight" },
				relative_to_origin = true
			},
			property = "FillTransparency",
			value_type = "number",
			values = {
				[0] = 1,
				[296] = 1,
				[298] = 0,
				[473] = 0,
				[475] = 1
			}
		},
		{
			name = "game.Workspace.Fx.Mesh.Pilar.PilarBeam.Cylinder.Transparency",
			target = {
				root = "vfx",
				path = {
					"Mesh",
					"Pilar",
					"PilarBeam",
					"Cylinder"
				},
				relative_to_origin = true
			},
			property = "Transparency",
			value_type = "number",
			values = {
				[0] = 1,
				[1311] = 1,
				[1320] = 0,
				[1416] = 0,
				[1424] = 1
			}
		},
		{
			name = "game.Lighting.Bloom.Intensity",
			target = {
				root = "lighting",
				path = { "Bloom" }
			},
			property = "Intensity",
			value_type = "number",
			values = {
				[0] = 1,
				[1258] = 1,
				[1266] = 2,
				[1330] = 2,
				[1352] = 1
			}
		},
		{
			name = "game.Lighting.Bloom.Size",
			target = {
				root = "lighting",
				path = { "Bloom" }
			},
			property = "Size",
			value_type = "number",
			values = {
				[0] = 24,
				[1258] = 24,
				[1266] = 56,
				[1330] = 56,
				[1352] = 24
			}
		},
		{
			name = "game.Lighting.Bloom.Threshold",
			target = {
				root = "lighting",
				path = { "Bloom" }
			},
			property = "Threshold",
			value_type = "number",
			values = {
				[0] = 2,
				[1258] = 2,
				[1266] = 1.25,
				[1330] = 1.25,
				[1352] = 2
			}
		},
		{
			name = "game.Workspace.Fx.Mesh.Pilar.Wind.Decal1.Transparency",
			target = {
				root = "vfx",
				path = {
					"Mesh",
					"Pilar",
					"Wind",
					"Decal1"
				},
				relative_to_origin = true
			},
			property = "Transparency",
			value_type = "number",
			values = {
				[0] = 1,
				[1309] = 1,
				[1320] = 0.5499999999999999,
				[1414] = 0.550000011920929,
				[1437] = 1
			}
		},
		{
			name = "game.Workspace.Fx.Mesh.Pilar.Wind1.Decal1.Transparency",
			target = {
				root = "vfx",
				path = {
					"Mesh",
					"Pilar",
					"Wind1",
					"Decal1"
				},
				relative_to_origin = true
			},
			property = "Transparency",
			value_type = "number",
			values = {
				[0] = 1,
				[1309] = 1,
				[1320] = 0.7,
				[1414] = 0.699999988079071,
				[1437] = 1
			}
		},
		{
			name = "game.Workspace.Fx.Mesh.Pilar.Wind2.Decal1.Transparency",
			target = {
				root = "vfx",
				path = {
					"Mesh",
					"Pilar",
					"Wind2",
					"Decal1"
				},
				relative_to_origin = true
			},
			property = "Transparency",
			value_type = "number",
			values = {
				[0] = 1,
				[1309] = 1,
				[1320] = 0.8999999999999999,
				[1414] = 0.8999999761581421,
				[1437] = 1
			}
		},
		{
			name = "game.Workspace.Fx.Mesh.Pilar.WindD.Decal1.Transparency",
			target = {
				root = "vfx",
				path = {
					"Mesh",
					"Pilar",
					"WindD",
					"Decal1"
				},
				relative_to_origin = true
			},
			property = "Transparency",
			value_type = "number",
			values = {
				[0] = 1,
				[1269] = 1,
				[1286] = 0.7,
				[1414] = 0.7,
				[1437] = 1
			}
		},
		{
			name = "game.Workspace.Fx.Mesh.Pilar.WindL.Decal1.Transparency",
			target = {
				root = "vfx",
				path = {
					"Mesh",
					"Pilar",
					"WindL",
					"Decal1"
				},
				relative_to_origin = true
			},
			property = "Transparency",
			value_type = "number",
			values = {
				[0] = 1,
				[1279] = 1,
				[1309] = 0,
				[1414] = 0,
				[1437] = 1
			}
		},
		{
			name = "game.Workspace.Fx.Mesh.Pilar.WindL1.Decal1.Transparency",
			target = {
				root = "vfx",
				path = {
					"Mesh",
					"Pilar",
					"WindL1",
					"Decal1"
				},
				relative_to_origin = true
			},
			property = "Transparency",
			value_type = "number",
			values = {
				[0] = 1,
				[1279] = 1,
				[1325] = 0,
				[1414] = 0,
				[1437] = 1
			}
		},
		{
			name = "game.Workspace.Fx.PilarFx.P.PointLight.Brightness",
			target = {
				root = "vfx",
				path = { "PilarFx", "P", "PointLight" },
				relative_to_origin = true
			},
			property = "Brightness",
			value_type = "number",
			values = {
				[0] = 0,
				[1304] = 0,
				[1336] = 0.5,
				[1414] = 0.5,
				[1436] = 0
			}
		},
		{
			name = "game.Workspace.Fx.PilarFx.P.Attachment.PointLight.Brightness",
			target = {
				root = "vfx",
				path = {
					"PilarFx",
					"P",
					"Attachment",
					"PointLight"
				},
				relative_to_origin = true
			},
			property = "Brightness",
			value_type = "number",
			values = {
				[0] = 0,
				[1268] = 0,
				[1300] = 5,
				[1414] = 5,
				[1436] = 0
			}
		},
		{
			name = "game.Workspace.Fx.Mesh.Pilar.FB.Wind1.CFrame",
			target = {
				root = "vfx",
				path = {
					"Mesh",
					"Pilar",
					"FB",
					"Wind1"
				},
				relative_to_origin = true
			},
			property = "CFrame",
			value_type = "CFrame",
			relative_to_origin = true,
			values = {
				[0] = CFrame.new(4.631617546081543, 39.263671875, 0.7688655853271484, 0, 1, 0, 1, 0, 0, 0, 0, -1),
				[1301] = CFrame.new(4.631617546081543, 39.263671875, 0.7688655853271484, 0, 1, 0, 1, 0, 0, 0, 0, -1),
				[1332] = CFrame.new(
					4.631617546081543,
					39.263671875,
					0.7688655853271484,
					0,
					-0.027877099812030792,
					-0.9996113777160645,
					1,
					0,
					0,
					0,
					-0.9996113777160645,
					0.027877099812030792
				),
				[1371] = CFrame.new(
					4.631617546081543,
					39.263671875,
					0.7688655853271484,
					0,
					-0.9520231485366821,
					0.3060262203216553,
					1,
					0,
					0,
					0,
					0.3060262203216553,
					0.9520231485366821
				),
				[1407] = CFrame.new(
					4.631617546081543,
					39.263671875,
					0.7688655853271484,
					0,
					0.07152275741100311,
					0.9974390268325806,
					1,
					0,
					0,
					0,
					0.9974390268325806,
					-0.07152275741100311
				),
				[1438] = CFrame.new(
					4.631617546081543,
					39.263671875,
					0.7688655853271484,
					0,
					0.9999970197677612,
					0.002469487488269806,
					1,
					0,
					0,
					0,
					0.002469487488269806,
					-0.9999970197677612
				)
			}
		},
		{
			name = "game.Workspace.Fx.Mesh.Pilar.FB.Wind2.CFrame",
			target = {
				root = "vfx",
				path = {
					"Mesh",
					"Pilar",
					"FB",
					"Wind2"
				},
				relative_to_origin = true
			},
			property = "CFrame",
			value_type = "CFrame",
			relative_to_origin = true,
			values = {
				[0] = CFrame.new(0, 24.55573272705078, 0.7688654661178589, 0, 1, 0, 1, 0, 0, 0, 0, -1),
				[1301] = CFrame.new(0, 24.55573272705078, 0.7688654661178589, 0, 1, 0, 1, 0, 0, 0, 0, -1),
				[1332] = CFrame.new(
					0,
					24.55573272705078,
					0.7688654661178589,
					0,
					-0.027877099812030792,
					-0.9996113777160645,
					1,
					0,
					0,
					0,
					-0.9996113777160645,
					0.027877099812030792
				),
				[1371] = CFrame.new(
					0,
					24.55573272705078,
					0.7688654661178589,
					0,
					-0.9520231485366821,
					0.3060262203216553,
					1,
					0,
					0,
					0,
					0.3060262203216553,
					0.9520231485366821
				),
				[1407] = CFrame.new(
					0,
					24.55573272705078,
					0.7688654661178589,
					0,
					0.07152275741100311,
					0.9974390268325806,
					1,
					0,
					0,
					0,
					0.9974390268325806,
					-0.07152275741100311
				),
				[1438] = CFrame.new(
					0,
					24.55573272705078,
					0.7688654661178589,
					0,
					0.9999970197677612,
					0.002469487488269806,
					1,
					0,
					0,
					0,
					0.002469487488269806,
					-0.9999970197677612
				)
			}
		},
		{
			name = "game.Workspace.RockBig.Transparency",
			target = {
				root = "vfx",
				path = { "RockBig" },
				relative_to_origin = true
			},
			property = "Transparency",
			value_type = "number",
			values = {
				[0] = 1,
				[1304] = 1,
				[1314] = 0
			}
		},
		{
			name = "game.CoreGui.MoonAnimatorEffects.Vignette.ImageTransparency",
			target = {
				root = "background_image",
				path = {}
			},
			property = "ImageTransparency",
			value_type = "number",
			values = {
				[0] = 1,
				[1297] = 1,
				[1315] = 0,
				[1335] = 0,
				[1420] = 1
			}
		},
		{
			name = "game.Workspace.Fx.Trails.CFrame",
			target = {
				root = "vfx",
				path = { "Trails" },
				relative_to_origin = true
			},
			property = "CFrame",
			value_type = "CFrame",
			relative_to_origin = true,
			values = {
				[0] = CFrame.new(0, 8.430742263793945, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
				[671] = CFrame.new(0, 8.430742263793945, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
				[690] = CFrame.new(
					0,
					8.430742263793945,
					0,
					-0.8588518500328064,
					0,
					0.512224018573761,
					0,
					1,
					0,
					-0.512224018573761,
					0,
					-0.8588518500328064
				),
				[709] = CFrame.new(
					0,
					8.430742263793945,
					0,
					0.6223731637001038,
					0,
					-0.7827205061912537,
					0,
					0.9999999403953552,
					0,
					0.7827205061912537,
					0,
					0.6223731637001038
				),
				[726] = CFrame.new(
					0,
					8.430742263793945,
					0,
					-0.19746308028697968,
					0,
					0.980310320854187,
					0,
					0.9999999403953552,
					0,
					-0.980310320854187,
					0,
					-0.19746308028697968
				),
				[742] = CFrame.new(
					0,
					8.430742263793945,
					0,
					-0.37232762575149536,
					0,
					-0.9281013011932373,
					0,
					1,
					0,
					0.9281013011932373,
					0,
					-0.37232762575149536
				),
				[758] = CFrame.new(0, 8.430742263793945, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
				[774] = CFrame.new(0, 8.430742263793945, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
				[793] = CFrame.new(
					0,
					8.430742263793945,
					0,
					-0.8588518500328064,
					0,
					0.512224018573761,
					0,
					1,
					0,
					-0.512224018573761,
					0,
					-0.8588518500328064
				),
				[812] = CFrame.new(
					0,
					8.430742263793945,
					0,
					0.6223731637001038,
					0,
					-0.7827205061912537,
					0,
					0.9999999403953552,
					0,
					0.7827205061912537,
					0,
					0.6223731637001038
				),
				[829] = CFrame.new(
					0,
					8.430742263793945,
					0,
					-0.19746308028697968,
					0,
					0.980310320854187,
					0,
					0.9999999403953552,
					0,
					-0.980310320854187,
					0,
					-0.19746308028697968
				),
				[845] = CFrame.new(
					0,
					8.430742263793945,
					0,
					-0.37232762575149536,
					0,
					-0.9281013011932373,
					0,
					1,
					0,
					0.9281013011932373,
					0,
					-0.37232762575149536
				),
				[861] = CFrame.new(0, 8.430742263793945, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
				[876] = CFrame.new(0, 8.430742263793945, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
				[895] = CFrame.new(
					0,
					8.430742263793945,
					0,
					-0.8588518500328064,
					0,
					0.512224018573761,
					0,
					1,
					0,
					-0.512224018573761,
					0,
					-0.8588518500328064
				),
				[914] = CFrame.new(
					0,
					8.430742263793945,
					0,
					0.6223731637001038,
					0,
					-0.7827205061912537,
					0,
					0.9999999403953552,
					0,
					0.7827205061912537,
					0,
					0.6223731637001038
				),
				[931] = CFrame.new(
					0,
					8.430742263793945,
					0,
					-0.19746308028697968,
					0,
					0.980310320854187,
					0,
					0.9999999403953552,
					0,
					-0.980310320854187,
					0,
					-0.19746308028697968
				),
				[947] = CFrame.new(
					0,
					8.430742263793945,
					0,
					-0.37232762575149536,
					0,
					-0.9281013011932373,
					0,
					1,
					0,
					0.9281013011932373,
					0,
					-0.37232762575149536
				),
				[963] = CFrame.new(0, 8.430742263793945, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
				[978] = CFrame.new(0, 8.430742263793945, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
				[997] = CFrame.new(
					0,
					8.430742263793945,
					0,
					-0.8588518500328064,
					0,
					0.512224018573761,
					0,
					1,
					0,
					-0.512224018573761,
					0,
					-0.8588518500328064
				),
				[1016] = CFrame.new(
					0,
					8.430742263793945,
					0,
					0.6223731637001038,
					0,
					-0.7827205061912537,
					0,
					0.9999999403953552,
					0,
					0.7827205061912537,
					0,
					0.6223731637001038
				),
				[1033] = CFrame.new(
					0,
					8.430742263793945,
					0,
					-0.19746308028697968,
					0,
					0.980310320854187,
					0,
					0.9999999403953552,
					0,
					-0.980310320854187,
					0,
					-0.19746308028697968
				),
				[1049] = CFrame.new(
					0,
					8.430742263793945,
					0,
					-0.37232762575149536,
					0,
					-0.9281013011932373,
					0,
					1,
					0,
					0.9281013011932373,
					0,
					-0.37232762575149536
				),
				[1065] = CFrame.new(0, 8.430742263793945, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
				[1081] = CFrame.new(0, 8.430742263793945, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
				[1100] = CFrame.new(
					0,
					8.430742263793945,
					0,
					-0.8588518500328064,
					0,
					0.512224018573761,
					0,
					1,
					0,
					-0.512224018573761,
					0,
					-0.8588518500328064
				),
				[1119] = CFrame.new(
					0,
					8.430742263793945,
					0,
					0.6223731637001038,
					0,
					-0.7827205061912537,
					0,
					0.9999999403953552,
					0,
					0.7827205061912537,
					0,
					0.6223731637001038
				),
				[1136] = CFrame.new(
					0,
					8.430742263793945,
					0,
					-0.19746308028697968,
					0,
					0.980310320854187,
					0,
					0.9999999403953552,
					0,
					-0.980310320854187,
					0,
					-0.19746308028697968
				),
				[1152] = CFrame.new(
					0,
					8.430742263793945,
					0,
					-0.37232762575149536,
					0,
					-0.9281013011932373,
					0,
					1,
					0,
					0.9281013011932373,
					0,
					-0.37232762575149536
				),
				[1168] = CFrame.new(0, 8.430742263793945, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
				[1182] = CFrame.new(0, 8.430742263793945, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
				[1201] = CFrame.new(
					0,
					8.430742263793945,
					0,
					-0.8588518500328064,
					0,
					0.512224018573761,
					0,
					1,
					0,
					-0.512224018573761,
					0,
					-0.8588518500328064
				),
				[1220] = CFrame.new(
					0,
					8.430742263793945,
					0,
					0.6223731637001038,
					0,
					-0.7827205061912537,
					0,
					0.9999999403953552,
					0,
					0.7827205061912537,
					0,
					0.6223731637001038
				),
				[1237] = CFrame.new(
					0,
					8.430742263793945,
					0,
					-0.19746308028697968,
					0,
					0.980310320854187,
					0,
					0.9999999403953552,
					0,
					-0.980310320854187,
					0,
					-0.19746308028697968
				),
				[1253] = CFrame.new(
					0,
					8.430742263793945,
					0,
					-0.37232762575149536,
					0,
					-0.9281013011932373,
					0,
					1,
					0,
					0.9281013011932373,
					0,
					-0.37232762575149536
				),
				[1269] = CFrame.new(0, 8.430742263793945, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
				[1318] = CFrame.new(
					0,
					8.430742263793945,
					0,
					0.9285980463027954,
					0,
					0.3710872530937195,
					0,
					0.9999999403953552,
					0,
					-0.3710872530937195,
					0,
					0.9285980463027954
				)
			}
		}
	}
}

for _, v19 in ipairs(v4) do
	for _, id in ipairs(v19.ids) do
		table.insert(FrameEvents.preload_assets, id)
	end
end

for _, list in pairs(v14.assets) do
	for _, v19 in ipairs(list) do
		table.insert(FrameEvents.preload_assets, v19)
	end
end

local misc = script.Parent:WaitForChild("Misc")
local part_Icles = misc:WaitForChild("Part_Icles")
local vfxmodule = misc:FindFirstChild("Vfxmodule")

-- equivalent calls inferred from this helper; original call sites unknown
local function active(p)
	local run_context = p and p.run_context
	return not run_context or run_context.running == true
end

-- equivalent calls inferred from this helper; original call sites unknown
local function delay_if_active(p, value: number?, fn)
	task.delay(value or 0, function()
		if active(p) then
			fn()
		end
	end)
end

local function get_child(child, ...)
	for _, childName in ipairs({ ... }) do
		if not child then
			return nil
		end

		child = child:FindFirstChild(childName)
	end

	return child
end

local function get_path(child, path)
	for _, childName in ipairs(path) do
		if not child then
			return nil
		end

		child = child:FindFirstChild(childName)
	end

	return child
end

local function find_deep(instance, childName: string)
	if not instance then
		return nil
	end

	local child = instance:FindFirstChild(childName)

	if child then
		return child
	end

	return instance:FindFirstChild(childName, true)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function camera_rig1(data)
	return data.camera_rig1 or data.cameraRig1 or data.misc_models and (data.misc_models.camera_rig1 or data.misc_models.cameraRig1 or data.misc_models.camera_rig_1)
end

local function collect_enabled_targets(effect, effects)
	if not effect then
		return
	end

	if effect:IsA("ParticleEmitter") or effect:IsA("Beam") or effect:IsA("Trail") then
		table.insert(effects, effect)
	end

	for _, effect2 in ipairs(effect:GetDescendants()) do
		if not (effect2:IsA("ParticleEmitter") or effect2:IsA("Beam") or effect2:IsA("Trail")) then
			continue
		end

		table.insert(effects, effect2)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function set_enabled(p, enabled: boolean)
	local v19 = {}
	collect_enabled_targets(p, v19)

	for _, v20 in ipairs(v19) do
		v20.Enabled = enabled
	end
end

local function attr_number(instance, attributeName: string, p: number)
	local attribute = instance:GetAttribute(attributeName)

	if typeof(attribute) == "number" then
		return attribute
	end

	return p
end

local function emit_scoped(p, folder)
	if not folder then
		return
	end

	for _, effect in ipairs(folder:GetDescendants()) do
		if effect:IsA("ParticleEmitter") then
			local emitDelay = effect:GetAttribute("EmitDelay")
			local v20 = effect

			local function fn()
				if v20.Parent then
					local emitCount = v20:GetAttribute("EmitCount")
					v20:Emit(typeof(emitCount) ~= "number" and 1 or emitCount)
				end
			end

			delay_if_active(p, typeof(emitDelay) ~= "number" and 0 or emitDelay, fn) -- equivalent call inferred; original call site unknown
		elseif effect:IsA("Beam") or effect:IsA("Trail") then
			local emitDelay = effect:GetAttribute("EmitDelay")
			local v20 = effect
			local v21 = effect

			local function fn()
				if v20.Parent then
					v20.Enabled = true
					local emitDuration = v20:GetAttribute("EmitDuration")

					local function fn2()
						if v20.Parent then
							v20.Enabled = false
						end
					end

					delay_if_active(p, typeof(emitDuration) ~= "number" and 0.2 or emitDuration, fn2) -- equivalent call inferred; original call site unknown
				end
			end

			delay_if_active(p, typeof(emitDelay) ~= "number" and 0 or emitDelay, fn) -- equivalent call inferred; original call site unknown
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function emit_vfx(p, p2)
	if not p2 then
		return
	end

	local vfx = shared.vfx

	if vfx and type(vfx.emit) == "function" then
		pcall(vfx.emit, p2)
	else
		emit_scoped(p, p2)
	end
end

local function emit_part_icles(p, p2)
	if p2 and active(p) then
		local success, result = pcall(require, part_Icles)

		if success and result and result.AbsoluteEmit then
			pcall(function()
				result:AbsoluteEmit(p2)
			end)
		end
	end
end

local function clone_eyes_fx(p)
	local character = p.character

	if not character then
		return
	end

	local head = character:FindFirstChild("Head")

	if not head or head:FindFirstChild("EyesFx") then
		return
	end

	local eyesFx = misc:FindFirstChild("EyesFx")

	if eyesFx then
		local clone = eyesFx:Clone()
		clone.Name = "EyesFx"
		clone.Parent = head
		table.insert(p.cleanup_objects, clone)
	end
end

CFrame.new(
	-0.00388050079,
	-1.00360608,
	-2.28502369,
	1,
	0,
	0,
	0,
	-0.0124384966,
	0.999922633,
	0,
	-0.999922633,
	-0.0124384966
)
CFrame.new(
	-0.00411248207,
	0.228573799,
	-0.00808262825,
	1,
	0,
	0,
	0,
	0.999922633,
	-0.0124384966,
	0,
	0.0124384966,
	0.999922633
)
CFrame.new(0, 0.0247864723, 0)
local v19 = {
	{
		f_part = "HeadF",
		limb_names = { "Head" }
	},
	{
		f_part = "TorsoF",
		limb_names = { "Torso", "UpperTorso" }
	},
	{
		f_part = "Left ArmF",
		limb_names = { "Left Arm", "LeftUpperArm" }
	},
	{
		f_part = "Right ArmF",
		limb_names = { "Right Arm", "RightUpperArm" }
	},
	{
		f_part = "Left LegF",
		limb_names = { "Left Leg", "LeftUpperLeg" }
	},
	{
		f_part = "Right LegF",
		limb_names = { "Right Leg", "RightUpperLeg" }
	}
}

-- equivalent calls inferred from this helper; original call sites unknown
local function prepare_overlay_part(part)
	part.Anchored = false
	part.CanCollide = false
	part.CanQuery = false
	part.Massless = true
end

local function wire_character_overlays(state)
	if state.overlays_wired then
		return
	end

	state.overlays_wired = true
	local character = state.character
	local v20 = get_child(state.vfx, "Mesh", "Char")

	if not (character and v20) then
		return
	end

	for _, v21 in ipairs(v19) do
		local part = v20:FindFirstChild(v21.f_part)
		local part2 = nil

		for _, childName in ipairs(v21.limb_names) do
			part2 = character:FindFirstChild(childName)

			if part2 then
				break
			end
		end

		if not (part and part:IsA("BasePart") and part2 and part2:IsA("BasePart")) then
			continue
		end

		prepare_overlay_part(part) -- equivalent call inferred; original call site unknown
		part.CFrame = part2.CFrame
		local motor6D = Instance.new("Motor6D")
		motor6D.Name = v21.f_part
		motor6D.Part0 = part2
		motor6D.Part1 = part
		motor6D.Parent = part2
		table.insert(state.cleanup_objects, motor6D)
	end
end

local function clone_shadow_sword(_) end

local function shadow_sword(p)
	return p.shadow_sword or nil
end

local v20 = {
	Shirt = true,
	Pants = true,
	ShirtGraphic = true,
	BodyColors = true,
	CharacterMesh = true
}

local function weld_cloned_accessory(user1, clone)
	local handle = clone:FindFirstChild("Handle")

	if not (handle and handle:IsA("BasePart")) then
		clone:Destroy()
		return
	end

	for _, child in ipairs(handle:GetChildren()) do
		if not (child:IsA("Weld") or child:IsA("Motor6D") or child:IsA("WeldConstraint")) then
			continue
		end

		child:Destroy()
	end

	handle.Anchored = false
	handle.CanCollide = false
	handle.Massless = true
	local attachment = handle:FindFirstChildOfClass("Attachment")
	local head = nil
	local v21 = nil

	if attachment then
		for _, part in ipairs(user1:GetChildren()) do
			if not part:IsA("BasePart") then
				continue
			end

			local attachment2 = part:FindFirstChild(attachment.Name)

			if not (attachment2 and attachment2:IsA("Attachment")) then
				continue
			end

			v21 = attachment2
			head = part
			break
		end
	end

	if not head then
		head = user1:FindFirstChild("Head")

		if not (head and head:IsA("BasePart")) then
			head = nil
		end
	end

	if not head then
		clone:Destroy()
		return
	end

	local weld = Instance.new("Weld")
	weld.Name = "AccessoryWeld"
	weld.Part0 = handle
	weld.Part1 = head

	if attachment and v21 then
		weld.C0 = attachment.CFrame
		weld.C1 = v21.CFrame
	end

	weld.Parent = handle
	clone.Parent = user1
end

local function apply_victim_appearance(data)
	local user1 = data.user1 or data.User1
	local victim = data.victim or data.Victim

	if not (user1 and user1:IsA("Model") and victim and victim:IsA("Model")) then
		return
	end

	if user1:GetAttribute("VictimAppearanceApplied") then
		return
	end

	user1:SetAttribute("VictimAppearanceApplied", true)

	for _, child in ipairs(user1:GetChildren()) do
		if not (child:IsA("Accessory") or child:IsA("Hat") or v20[child.ClassName]) then
			continue
		end

		child:Destroy()
	end

	for _, child in ipairs(victim:GetChildren()) do
		if not v20[child.ClassName] then
			continue
		end

		local clone = child:Clone()
		clone.Parent = user1
	end

	for _, part in ipairs(victim:GetChildren()) do
		if not (part:IsA("BasePart") and part.Name ~= "HumanoidRootPart") then
			continue
		end

		local part2 = user1:FindFirstChild(part.Name)

		if not (part2 and part2:IsA("BasePart")) then
			continue
		end

		part2.Color = part.Color
		part2.Material = part.Material
		part2.Reflectance = part.Reflectance
		part2.Transparency = part.Transparency
		local specialMesh = part:FindFirstChildOfClass("SpecialMesh")

		if specialMesh then
			local specialMesh2 = part2:FindFirstChildOfClass("SpecialMesh")

			if specialMesh2 then
				specialMesh2:Destroy()
			end

			local clone_2 = specialMesh:Clone()
			clone_2.Parent = part2
		end

		for _, decal in ipairs(part2:GetChildren()) do
			if decal:IsA("Decal") then
				decal:Destroy()
			end
		end

		for _, decal in ipairs(part:GetChildren()) do
			if not decal:IsA("Decal") then
				continue
			end

			local clone_3 = decal:Clone()
			clone_3.Parent = part2
		end
	end

	for _, child in ipairs(victim:GetChildren()) do
		if child:IsA("Accessory") or child:IsA("Hat") then
			weld_cloned_accessory(user1, child:Clone())
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setup_actor_vfx(data)
	clone_eyes_fx(data)
	wire_character_overlays(data)
	set_enabled(nil, false) -- equivalent call inferred; original call site unknown
end

local function start_texture_loops(state)
	if state.texture_loops_started then
		return
	end

	state.texture_loops_started = true

	if not vfxmodule then
		return
	end

	local success, result = pcall(require, vfxmodule)

	if not success or type(result) ~= "table" or type(result.textureflipbookLoop) ~= "function" then
		return
	end

	local texture_loop_controllers = {}
	state.texture_loop_controllers = texture_loop_controllers

	for _, v22 in ipairs(v14.loops or {}) do
		local v23 = get_path(state.vfx, v22.path)
		local v24 = v14.assets and v14.assets[v22.assets]

		if not (v23 and v24) then
			continue
		end

		local success2, result2 = pcall(result.textureflipbookLoop, v23, v24, v22.duration or 1)

		if not (success2 and type(result2) == "table" and type(result2.Stop) == "function") then
			continue
		end

		table.insert(texture_loop_controllers, result2)
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function stop_controllers()
		for _, v22 in ipairs(texture_loop_controllers) do
			v22:Stop()
		end
	end

	if state.cleanup_callbacks then
		table.insert(state.cleanup_callbacks, stop_controllers)
	end

	local heartbeatConnection = nil
	heartbeatConnection = RunService.Heartbeat:Connect(function()
		if active(state) then
			return
		end

		stop_controllers() -- equivalent call inferred; original call site unknown

		if heartbeatConnection then
			heartbeatConnection:Disconnect()
		end
	end)
	state.cleanup_connections.texture_loops = heartbeatConnection
end

local function sequence_parent(data, data2)
	local target = data2.target

	if target == "impact" or target == "overlay" then
		return data.impact_image or data.impactImage or data.impact_ui or data.impactUI or data.overlay_ui or data.overlayUI or data.background_ui or data.backgroundUI
	end

	return data.screen_image or data.screenImage or data.screen_ui or data.screenUI or data.background_ui or data.backgroundUI or data.background_image or data.backgroundImage
end

-- equivalent calls inferred from this helper; original call sites unknown
local function warm_sequence_label(p)
	if p and p.Parent then
		p.ImageTransparency = 0.997
		p.Size = UDim2.fromScale(1, 1)
	end
end

local function prepare_image_sequence(state, data)
	local parent = sequence_parent(state, data)
	local ids = data.ids or {}

	if not parent or #ids == 0 then
		return nil
	end

	state.image_sequence_labels = state.image_sequence_labels or {}
	local image_sequence_label = state.image_sequence_labels[data]

	if image_sequence_label then
		return image_sequence_label
	end

	local result = {}

	for i, id in ipairs(ids) do
		local imageLabel = Instance.new("ImageLabel")
		imageLabel.Name = "SequenceFrame_" .. i
		imageLabel.BackgroundTransparency = 1
		imageLabel.BorderSizePixel = 0
		imageLabel.Position = UDim2.fromScale(0.5, 0.5)
		imageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
		imageLabel.Size = UDim2.fromOffset(1, 1)
		imageLabel.Image = id
		imageLabel.ScaleType = data.scale_type or Enum.ScaleType.Crop
		imageLabel.ZIndex = data.z_index or 2
		imageLabel.ImageColor3 = data.image_color3 or Color3.fromRGB(255, 255, 255)
		imageLabel.Parent = parent
		result[i] = imageLabel
		table.insert(state.cleanup_objects, imageLabel)
	end

	warm_sequence_label(result[1]) -- equivalent call inferred; original call site unknown
	state.image_sequence_labels[data] = result
	return result
end

local function play_image_sequence(p, p2)
	local v21 = prepare_image_sequence(p, p2)

	if not v21 or #v21 == 0 then
		return
	end

	local count = #v21
	local duration = tonumber(p2.duration) or 0
	local v22 = not (duration > 0) and 0 or duration / count

	if v22 > 0 then
		v22 = math.ceil(v22 * 60 - 0.0001) / 60
	end

	task.spawn(function()
		local now = os.clock()

		if p.timeline_start and p2.start_frame then
			now = p.timeline_start + p2.start_frame / 60
		end

		local v23 = 0

		while true do
			local run_context = p and p.run_context

			if run_context and run_context.running ~= true then
				break
			end

			local v25

			if v22 > 0 then
				v25 = math.min(count, math.floor((os.clock() - now) / v22) + 1)
			else
				v25 = count
			end

			if v23 < v25 then
				for i = math.max(v23, 1), v25 - 1 do
					local v26 = v21[i]

					if v26 and v26.Parent then
						v26:Destroy()
					end
				end

				local v26 = v21[v25]

				if not (v26 and v26.Parent) then
					return
				end

				v26.Size = UDim2.fromScale(1, 1)
				v26.ImageTransparency = 0
				warm_sequence_label(v21[v25 + 1]) -- equivalent call inferred; original call site unknown
				v23 = v25
			end

			if count <= v23 then
				break
			else
				task.wait((math.max(0, now + v23 * v22 - os.clock())))
			end
		end

		if not active(p) then
			return
		end

		local v25 = now + v22 * count - os.clock()

		if v25 > 0 then
			task.wait(v25)
		end

		local v26 = v21[count]

		if v26 and v26.Parent then
			v26:Destroy()
		end
	end)
end

FrameEvents.frame_events = {
	[0] = function(data)
		setup_actor_vfx(data) -- equivalent call inferred; original call site unknown
		apply_victim_appearance(data)
		start_texture_loops(data)
		prepare_image_sequence(data, v4[1])
		prepare_image_sequence(data, v4[2])
		prepare_image_sequence(data, v4[3])
		set_enabled(get_child(data.camera_rig, "CamPart", "Beams", "M1"), false) -- equivalent call inferred; original call site unknown
		set_enabled(get_child(camera_rig1(data), "CamPart", "Beams", "M3"), false) -- equivalent call inferred; original call site unknown
		set_enabled(get_child(data.vfx, "NuclearFx", "Fx1"), false) -- equivalent call inferred; original call site unknown
		set_enabled(get_child(data.vfx, "NuclearFx", "Fx2"), false) -- equivalent call inferred; original call site unknown
		set_enabled(get_child(data.vfx, "AuraChargeFx"), false) -- equivalent call inferred; original call site unknown
		set_enabled(get_child(data.vfx, "Mesh", "Pilar"), false) -- equivalent call inferred; original call site unknown
		set_enabled(get_child(data.vfx, "PilarFx"), false) -- equivalent call inferred; original call site unknown
	end,
	[95] = function(p)
		set_enabled(get_child(p.camera_rig, "CamPart", "Beams", "M1"), true) -- equivalent call inferred; original call site unknown
	end,
	[295] = function(p)
		set_enabled(get_child(p.camera_rig, "CamPart", "Beams", "M1"), false) -- equivalent call inferred; original call site unknown
		set_enabled(get_child(p.vfx, "NuclearFx", "Fx1"), true) -- equivalent call inferred; original call site unknown
	end,
	[366] = function(p)
		set_enabled(get_child(p.vfx, "NuclearFx", "Fx2"), true) -- equivalent call inferred; original call site unknown
	end,
	[371] = function(p)
		set_enabled(get_child(p.vfx, "NuclearFx", "Fx1"), false) -- equivalent call inferred; original call site unknown
	end,
	[475] = function(data)
		emit_scoped(data, get_child(camera_rig1(data), "CamPart", "Fx", "Emit1"))
	end,
	[493] = function(data)
		set_enabled(get_child(data.vfx, "NuclearFx", "Fx2"), false) -- equivalent call inferred; original call site unknown
		set_enabled(get_child(camera_rig1(data), "CamPart", "Beams", "M3"), true) -- equivalent call inferred; original call site unknown
	end,
	[548] = function(data)
		local shadow_sword2 = data.shadow_sword or nil
		set_enabled(shadow_sword2, true) -- equivalent call inferred; original call site unknown
		set_enabled(get_child(camera_rig1(data), "CamPart", "Beams", "M3"), false) -- equivalent call inferred; original call site unknown
	end,
	[554] = function(p)
		play_image_sequence(p, v4[1])
	end,
	[621] = function(p)
		set_enabled(get_child(p.vfx, "AuraChargeFx"), true) -- equivalent call inferred; original call site unknown
	end,
	[633] = function(p)
		play_image_sequence(p, v4[2])
	end,
	[660] = function(p)
		set_enabled(get_child(p.camera_rig, "CamPart", "Beams", "M1"), true) -- equivalent call inferred; original call site unknown
		emit_vfx(p, get_child(p.vfx, "Trails", "SharedEndBezier")) -- equivalent call inferred; original call site unknown
	end,
	[1030] = function(p)
		play_image_sequence(p, v4[3])
	end,
	[1045] = function(p)
		local shadow_sword2 = p.shadow_sword or nil
		set_enabled(shadow_sword2, false) -- equivalent call inferred; original call site unknown
	end,
	[1079] = function(p)
		emit_vfx(p, get_child(p.character, "Head", "EyesFx")) -- equivalent call inferred; original call site unknown
	end,
	[1204] = function(p)
		set_enabled(get_child(p.vfx, "AuraChargeFx"), false) -- equivalent call inferred; original call site unknown
	end,
	[1249] = function(p)
		emit_scoped(p, get_child(p.camera_rig, "CamPart", "Fx", "Emit"))
	end,
	[1301] = function(p)
		set_enabled(get_child(p.vfx, "Mesh", "Pilar"), true) -- equivalent call inferred; original call site unknown
		set_enabled(get_child(p.vfx, "PilarFx"), true) -- equivalent call inferred; original call site unknown
		set_enabled(get_child(p.camera_rig, "CamPart", "Beams", "M1"), false) -- equivalent call inferred; original call site unknown
		emit_vfx(p, get_child(p.vfx, "Mesh", "Pilar", "N")) -- equivalent call inferred; original call site unknown
		emit_part_icles(p, get_child(p.vfx, "Mesh", "Pilar", "FB"))
	end,
	[1421] = function(p)
		set_enabled(get_child(p.vfx, "Mesh", "Pilar"), false) -- equivalent call inferred; original call site unknown
		set_enabled(get_child(p.vfx, "PilarFx"), false) -- equivalent call inferred; original call site unknown
	end
}
return FrameEvents