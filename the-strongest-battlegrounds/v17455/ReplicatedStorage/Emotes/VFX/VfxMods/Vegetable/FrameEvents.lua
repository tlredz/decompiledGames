local createVector = vector.create
local part_Icles = script.Parent:WaitForChild("Misc"):WaitForChild("Part_Icles")
local FrameEvents = {
	frame_events = {},
	preload_assets = {},
	length_frames = 725,
	camera_part_keyframes = {
		[0] = {
			object = "camera_rig",
			part = "CamPart"
		}
	},
	property_keyframes = {
		{
			name = "4.FieldOfView",
			target = {
				root = "camera"
			},
			property = "FieldOfView",
			value_type = "number",
			values = {
				[0] = 70,
				[33] = 30,
				[57] = 35,
				[69] = 29,
				[73] = 22.714285714285715,
				[79] = 17.076923076923077,
				[86] = 14.923076923076923,
				[92] = 14.923076923076923,
				[147] = 13,
				[148] = 65,
				[160] = 74,
				[174] = 19,
				[186] = 21.666666666666664,
				[192] = 22.266666666666666,
				[198] = 21.4,
				[201] = 20.6,
				[207] = 19.65,
				[213] = 20,
				[237] = 24,
				[310] = 24,
				[316] = 25.6,
				[322] = 30.4,
				[325] = 33.599999999999994,
				[331] = 38.107317073170734,
				[334] = 38.46829268292683,
				[340] = 40.394177812745866,
				[365] = 53.43509047993706,
				[371] = 52.93333333333334,
				[413] = 24,
				[414] = 5,
				[493] = 90,
				[495] = 90,
				[496] = 7,
				[525] = 30,
				[531] = 56.666666666666664,
				[533] = 65.55555555555556,
				[539] = 100,
				[543] = 100,
				[546] = 99.42602040816327,
				[552] = 96.55612244897961,
				[555] = 94.26020408163266,
				[561] = 85.9375,
				[567] = 77.0408163265306,
				[592] = 65
			},
			eases = {
				[92] = {
					Type = "Sine",
					Direction = "Out"
				},
				[148] = {
					Type = "Circ",
					Direction = "Out"
				},
				[567] = {
					Type = "Sine",
					Direction = "Out"
				}
			}
		},
		{
			name = "5.Transparency",
			target = {
				root = "workspace",
				path = { "Baseplate" }
			},
			property = "Transparency",
			value_type = "number",
			values = {
				[0] = 0,
				[73] = 0,
				[77] = 1,
				[348] = 1,
				[349] = 0
			}
		},
		{
			name = "6.Transparency",
			target = {
				root = "workspace",
				path = { "Baseplate", "Texture" }
			},
			property = "Transparency",
			value_type = "number",
			values = {
				[0] = 0.800000011920929,
				[72] = 0.800000011920929,
				[73] = 0.800000011920929,
				[77] = 1,
				[348] = 1,
				[349] = 0.7999999999999999
			}
		},
		{
			name = "7.Color3",
			target = {
				root = "vfx",
				path = { "backgroundloop", "Base" }
			},
			property = "Color3",
			value_type = "Color3",
			values = {
				[0] = Color3.new(0.8901961445808411, 0.37254902720451355, 0),
				[73] = Color3.new(0.8901961445808411, 0.37254902720451355, 0),
				[74] = Color3.new(1, 0.29411765933036804, 0.13725490868091583),
				[147] = Color3.new(1, 0.29411765933036804, 0.13725490868091583),
				[150] = Color3.new(0.8901960849761963, 0.7237188816070557, 0.33164164423942566),
				[202] = Color3.new(0.8901960849761963, 0.7237188816070557, 0.33164164423942566),
				[273] = Color3.new(0.8901961445808411, 0.37254902720451355, 0),
				[385] = Color3.new(1.784313678741455, 13.945097923278809, 0.4901960790157318)
			}
		},
		{
			name = "8.CFrame",
			target = {
				root = "vfx",
				path = { "lmloop" },
				relative_to_origin = true
			},
			property = "CFrame",
			value_type = "CFrame",
			values = {
				[0] = CFrame.new(79.93080139160156, -53.39942169189453, -150.55111694335938, 1, 0, 0, 0, 1, 0, 0, 0, 1),
				[344] = CFrame.new(
					79.93080139160156,
					-53.39942169189453,
					-150.55111694335938,
					1,
					0,
					0,
					0,
					1,
					0,
					0,
					0,
					1
				),
				[345] = CFrame.new(
					79.93080139160156,
					-53.39942169189453,
					-150.55111694335938,
					1,
					0,
					0,
					0,
					1,
					0,
					0,
					0,
					1
				),
				[346] = CFrame.new(0, 2.3284339904785156, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
				[497] = CFrame.new(0, 2.3284339904785156, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
				[498] = CFrame.new(0, -190.7336883544922, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
			}
		},
		{
			name = "9.Scale",
			target = {
				root = "vfx",
				path = { "lmloop", "Mesh" }
			},
			property = "Scale",
			value_type = "Vector3",
			values = {
				[0] = createVector(0.0004999174, 0.00049991737, 0.0004999174),
				[344] = createVector(0.0004999174, 0.00049991737, 0.0004999174),
				[345] = createVector(0.0004999174, 0.00049991737, 0.0004999174),
				[346] = createVector(13, 13, 13),
				[446] = createVector(13, 13, 13),
				[495] = createVector(20, 20, 20),
				[496] = createVector(0, 0, 0)
			}
		},
		{
			name = "10.CFrame",
			target = {
				root = "vfx",
				path = { "Explosionloop" },
				relative_to_origin = true
			},
			property = "CFrame",
			value_type = "CFrame",
			values = {
				[0] = CFrame.new(59.31980514526367, -55.709781646728516, -166.57818603515625, 1, 0, 0, 0, 1, 0, 0, 0, 1),
				[495] = CFrame.new(
					59.31980514526367,
					-55.709781646728516,
					-166.57818603515625,
					1,
					0,
					0,
					0,
					1,
					0,
					0,
					0,
					1
				),
				[496] = CFrame.new(
					59.31980514526367,
					-55.709781646728516,
					-166.57818603515625,
					1,
					0,
					0,
					0,
					1,
					0,
					0,
					0,
					1
				),
				[497] = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
			}
		},
		{
			name = "11.Scale",
			target = {
				root = "vfx",
				path = { "Explosionloop", "Mesh" }
			},
			property = "Scale",
			value_type = "Vector3",
			values = {
				[0] = createVector(0.00050002337, 0.00050002337, 0.00050002337),
				[495] = createVector(0.00050002337, 0.00050002337, 0.00050002337),
				[496] = createVector(0.00050002337, 0.00050002337, 0.00050002337),
				[497] = createVector(30, 30, 30),
				[531] = createVector(35, 35, 35),
				[595] = createVector(43, 43, 43)
			}
		},
		{
			name = "12.Color3",
			target = {
				root = "vfx",
				path = { "Explosionloop", "Overlay" }
			},
			property = "Color3",
			value_type = "Color3",
			values = {
				[0] = Color3.new(11.764705657958984, 4.705882549285889, 0.7843137383460999),
				[534] = Color3.new(11.764705657958984, 4.705882549285889, 0.7843137383460999),
				[535] = Color3.new(11.764705657958984, 4.705882549285889, 0.7843137383460999),
				[608] = Color3.new(17.86274528503418, 6.098039150238037, 2.1764705181121826)
			}
		},
		{
			name = "12.Transparency",
			target = {
				root = "vfx",
				path = { "Explosionloop", "Overlay" }
			},
			property = "Transparency",
			value_type = "number",
			values = {
				[0] = 0,
				[586] = 0,
				[587] = 0,
				[607] = 1
			}
		},
		{
			name = "13.Color",
			target = {
				root = "vfx",
				path = { "backgroundloop", "Attachment", "PointLight" }
			},
			property = "Color",
			value_type = "Color3",
			values = {
				[0] = Color3.new(1, 0.4862745404243469, 0.14509804546833038),
				[274] = Color3.new(1, 0.4862745404243469, 0.14509804546833038),
				[275] = Color3.new(1, 0.4862745404243469, 0.14509804546833038),
				[318] = Color3.new(1, 0.3035883903503418, 0.07058823108673096)
			}
		},
		{
			name = "13.Brightness",
			target = {
				root = "vfx",
				path = { "backgroundloop", "Attachment", "PointLight" }
			},
			property = "Brightness",
			value_type = "number",
			values = {
				[0] = 0,
				[71] = 0,
				[72] = 0,
				[78] = 5,
				[186] = 5,
				[262] = 9,
				[301] = 9,
				[337] = 10,
				[493] = 9,
				[507] = 0
			}
		},
		{
			name = "14.Scale",
			target = {
				root = "vfx",
				path = { "backgroundloop", "Mesh" }
			},
			property = "Scale",
			value_type = "Vector3",
			values = {
				[0] = createVector(0, 0, 0),
				[75] = createVector(2.1425421, 2.1425421, 2.1425421),
				[77] = createVector(7, 7, 7),
				[147] = createVector(8.089075, 8.089075, 8.089075),
				[148] = createVector(12.741, 12.741, 12.741),
				[446] = createVector(12.740983, 12.740983, 12.740983),
				[496] = createVector(18, 18, 18),
				[497] = createVector(0, 0, 0)
			}
		},
		{
			name = "15.TintColor",
			target = {
				root = "lighting",
				path = { "ColorSkill" }
			},
			property = "TintColor",
			value_type = "Color3",
			values = {
				[0] = Color3.new(1, 1, 1),
				[3] = Color3.new(1, 1, 1),
				[6] = Color3.new(1, 1, 1),
				[26] = Color3.new(1, 1, 1),
				[31] = Color3.new(1, 1, 1),
				[75] = Color3.new(1, 1, 1),
				[79] = Color3.new(1, 1, 1),
				[343] = Color3.new(1, 1, 1),
				[348] = Color3.new(1, 1, 1),
				[568] = Color3.new(1, 1, 1),
				[595] = Color3.new(1, 1, 1)
			}
		},
		{
			name = "15.Brightness",
			target = {
				root = "lighting",
				path = { "ColorSkill" }
			},
			property = "Brightness",
			value_type = "number",
			values = {
				[0] = 0,
				[3] = 0,
				[6] = -0.049999999999999996,
				[26] = -0.049999999999999996,
				[31] = 0.25,
				[34] = 0,
				[75] = 0,
				[79] = -0.049999999999999996,
				[343] = -0.05000000074505806,
				[348] = -0.20000000298023224,
				[568] = -0.20000000298023224,
				[595] = 1
			}
		},
		{
			name = "15.Saturation",
			target = {
				root = "lighting",
				path = { "ColorSkill" }
			},
			property = "Saturation",
			value_type = "number",
			values = {
				[0] = 0,
				[3] = 0,
				[6] = -0.75,
				[26] = -0.75,
				[31] = 0.44999999999999996,
				[75] = 0.44999998807907104,
				[79] = 0.25,
				[343] = 0.25,
				[348] = 0.25,
				[568] = 0.25,
				[595] = 0
			}
		},
		{
			name = "15.Contrast",
			target = {
				root = "lighting",
				path = { "ColorSkill" }
			},
			property = "Contrast",
			value_type = "number",
			values = {
				[0] = 0,
				[3] = 0,
				[6] = 0.39999999999999997,
				[26] = 0.39999999999999997,
				[31] = 0.35,
				[42] = 0.7,
				[75] = 0.3499999940395355,
				[79] = 0.15,
				[343] = 0.15000000596046448,
				[348] = 0.5,
				[568] = 0.5,
				[595] = 0
			}
		},
		{
			name = "16.Color",
			target = {
				root = "vfx",
				path = { "Box" }
			},
			property = "Color",
			value_type = "Color3",
			values = {
				[0] = Color3.new(0, 0, 0),
				[28] = Color3.new(0, 0, 0),
				[29] = Color3.new(0, 0, 0),
				[44] = Color3.new(1, 0.46115022897720337, 0.047058820724487305),
				[58] = Color3.new(0.800000011920929, 0.3686274588108063, 0.03529411926865578),
				[73] = Color3.new(0.772549033164978, 0.4630737006664276, 0.19086503982543945)
			}
		},
		{
			name = "16.Transparency",
			target = {
				root = "vfx",
				path = { "Box" }
			},
			property = "Transparency",
			value_type = "number",
			values = {
				[0] = 1,
				[6] = 1,
				[7] = 1,
				[10] = 0.7,
				[43] = 0.550000011920929,
				[77] = 0.550000011920929,
				[78] = 1
			}
		},
		{
			name = "17.CFrame",
			target = {
				root = "vfx",
				path = { "Explosionloop1" },
				relative_to_origin = true
			},
			property = "CFrame",
			value_type = "CFrame",
			values = {
				[0] = CFrame.new(59.31980514526367, -55.70928192138672, -166.57818603515625, 1, 0, 0, 0, 1, 0, 0, 0, 1),
				[495] = CFrame.new(
					59.31980514526367,
					-55.70928192138672,
					-166.57818603515625,
					1,
					0,
					0,
					0,
					1,
					0,
					0,
					0,
					1
				),
				[496] = CFrame.new(
					59.31980514526367,
					-55.70928192138672,
					-166.57818603515625,
					1,
					0,
					0,
					0,
					1,
					0,
					0,
					0,
					1
				),
				[497] = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
			}
		},
		{
			name = "18.Scale",
			target = {
				root = "vfx",
				path = { "Explosionloop1", "Mesh" }
			},
			property = "Scale",
			value_type = "Vector3",
			values = {
				[0] = createVector(0.00050002337, 0.00050002337, 0.00050002337),
				[494] = createVector(0.00050002337, 0.00050002337, 0.00050002337),
				[495] = createVector(0.00050002337, 0.00050002337, 0.00050002337),
				[497] = createVector(29, 29, 29),
				[543] = createVector(35, 35, 35)
			}
		},
		{
			name = "19.Transparency",
			target = {
				root = "vfx",
				path = { "Explosionloop1", "Overlay" }
			},
			property = "Transparency",
			value_type = "number",
			values = {
				[0] = 0,
				[586] = 0,
				[587] = 0,
				[599] = 1
			}
		},
		{
			name = "20.Range",
			target = {
				root = "vfx",
				path = { "Explosionloop", "Attachment", "PointLight" }
			},
			property = "Range",
			value_type = "number",
			values = {
				[0] = 54,
				[539] = 54,
				[540] = 54,
				[580] = 84
			}
		},
		{
			name = "20.Brightness",
			target = {
				root = "vfx",
				path = { "Explosionloop", "Attachment", "PointLight" }
			},
			property = "Brightness",
			value_type = "number",
			values = {
				[0] = 0,
				[496] = 0,
				[497] = 0,
				[498] = 15,
				[605] = 55,
				[606] = 15,
				[624] = 0
			}
		},
		{
			name = "21.ClockTime",
			target = {
				root = "lighting"
			},
			property = "ClockTime",
			value_type = "number",
			values = {
				[0] = 14.5,
				[344] = 14.5,
				[351] = 14.5,
				[385] = 14.5,
				[496] = 14.5,
				[499] = 18,
				[581] = 18,
				[590] = 18,
				[595] = 14.5,
				[597] = 18,
				[612] = 14.5
			}
		},
		{
			name = "21.ColorShift_Bottom",
			target = {
				root = "lighting"
			},
			property = "ColorShift_Bottom",
			value_type = "Color3",
			values = {
				[0] = Color3.new(0, 0, 0),
				[344] = Color3.new(0, 0, 0),
				[351] = Color3.new(1, 0.5411764979362488, 0.3137255012989044),
				[385] = Color3.new(1, 0.5411764979362488, 0.3137255012989044),
				[496] = Color3.new(1, 0.5411764979362488, 0.3137255012989044),
				[499] = Color3.new(1, 0.3686274588108063, 0.2549019753932953),
				[581] = Color3.new(1, 0.3686274588108063, 0.2549019753932953),
				[597] = Color3.new(1, 0.3686274588108063, 0.2549019753932953),
				[612] = Color3.new(0, 0, 0)
			}
		},
		{
			name = "21.EnvironmentDiffuseScale",
			target = {
				root = "lighting"
			},
			property = "EnvironmentDiffuseScale",
			value_type = "number",
			values = {
				[0] = 1,
				[344] = 1,
				[351] = 0.5,
				[385] = 0.5,
				[496] = 0.5,
				[499] = 0.4970000088214874,
				[581] = 0.4970000088214874,
				[597] = 0.4970000088214874,
				[612] = 1
			}
		},
		{
			name = "21.EnvironmentSpecularScale",
			target = {
				root = "lighting"
			},
			property = "EnvironmentSpecularScale",
			value_type = "number",
			values = {
				[0] = 1,
				[344] = 1,
				[351] = 0.30000001192092896,
				[385] = 0.30000001192092896,
				[496] = 0.30000001192092896,
				[499] = 0.5820000171661377,
				[581] = 0.5820000171661377,
				[597] = 0.5820000171661377,
				[612] = 1
			}
		},
		{
			name = "21.Ambient",
			target = {
				root = "lighting"
			},
			property = "Ambient",
			value_type = "Color3",
			values = {
				[0] = Color3.new(0.27450981736183167, 0.27450981736183167, 0.27450981736183167),
				[344] = Color3.new(0.27450981736183167, 0.27450981736183167, 0.27450981736183167),
				[351] = Color3.new(0.5960784554481506, 0.5490196347236633, 0.32156863808631897),
				[385] = Color3.new(0.5960784554481506, 0.5490196347236633, 0.32156863808631897),
				[496] = Color3.new(0.5960784554481506, 0.5490196347236633, 0.32156863808631897),
				[499] = Color3.new(0.6901960968971252, 0.29019609093666077, 0.09019608050584793),
				[581] = Color3.new(0.6901960968971252, 0.29019609093666077, 0.09019608050584793),
				[597] = Color3.new(0.6901960968971252, 0.29019609093666077, 0.09019608050584793),
				[612] = Color3.new(0.27450981736183167, 0.27450981736183167, 0.27450981736183167)
			}
		},
		{
			name = "21.OutdoorAmbient",
			target = {
				root = "lighting"
			},
			property = "OutdoorAmbient",
			value_type = "Color3",
			values = {
				[0] = Color3.new(0.27450981736183167, 0.27450981736183167, 0.27450981736183167),
				[344] = Color3.new(0.27450981736183167, 0.27450981736183167, 0.27450981736183167),
				[351] = Color3.new(0.27450981736183167, 0.27450981736183167, 0.27450981736183167),
				[385] = Color3.new(0.27450981736183167, 0.27450981736183167, 0.27450981736183167),
				[496] = Color3.new(0.27450981736183167, 0.27450981736183167, 0.27450981736183167),
				[499] = Color3.new(0, 0, 0),
				[581] = Color3.new(0, 0, 0),
				[597] = Color3.new(0, 0, 0),
				[612] = Color3.new(0.27450981736183167, 0.27450981736183167, 0.27450981736183167)
			}
		},
		{
			name = "21.Brightness",
			target = {
				root = "lighting"
			},
			property = "Brightness",
			value_type = "number",
			values = {
				[0] = 3,
				[344] = 3,
				[351] = 3,
				[385] = 3,
				[496] = 3,
				[499] = 15,
				[581] = 15,
				[597] = 15,
				[612] = 3
			}
		},
		{
			name = "21.ColorShift_Top",
			target = {
				root = "lighting"
			},
			property = "ColorShift_Top",
			value_type = "Color3",
			values = {
				[0] = Color3.new(0, 0, 0),
				[344] = Color3.new(0, 0, 0),
				[351] = Color3.new(0.5176470875740051, 0.4274510145187378, 0.20000001788139343),
				[385] = Color3.new(0.5176470875740051, 0.4274510145187378, 0.20000001788139343),
				[496] = Color3.new(0.5176470875740051, 0.4274510145187378, 0.20000001788139343),
				[499] = Color3.new(1, 0.8196079134941101, 0.2705882489681244),
				[581] = Color3.new(1, 0.8196079134941101, 0.2705882489681244),
				[597] = Color3.new(1, 0.8196079134941101, 0.2705882489681244),
				[612] = Color3.new(0, 0, 0)
			}
		},
		{
			name = "21.ExposureCompensation",
			target = {
				root = "lighting"
			},
			property = "ExposureCompensation",
			value_type = "number",
			values = {
				[0] = 0,
				[343] = 0,
				[344] = 0,
				[351] = 0,
				[385] = 0,
				[496] = 0,
				[503] = 0,
				[533] = 0,
				[542] = -1,
				[580] = -1,
				[605] = 0
			}
		},
		{
			name = "22.Threshold",
			target = {
				root = "lighting",
				path = { "Bloom" }
			},
			property = "Threshold",
			value_type = "number",
			values = {
				[0] = 2,
				[519] = 2,
				[520] = 2,
				[543] = 1,
				[613] = 1,
				[632] = 2
			}
		},
		{
			name = "22.Intensity",
			target = {
				root = "lighting",
				path = { "Bloom" }
			},
			property = "Intensity",
			value_type = "number",
			values = {
				[0] = 1,
				[519] = 1,
				[520] = 1,
				[543] = 1,
				[613] = 1,
				[632] = 1
			}
		},
		{
			name = "22.Size",
			target = {
				root = "lighting",
				path = { "Bloom" }
			},
			property = "Size",
			value_type = "number",
			values = {
				[0] = 24,
				[519] = 24,
				[520] = 24,
				[543] = 32,
				[613] = 32,
				[632] = 24
			}
		},
		{
			name = "23.InFocusRadius",
			target = {
				root = "lighting",
				path = { "DepthOfField" }
			},
			property = "InFocusRadius",
			value_type = "number",
			values = {
				[0] = 30.604999542236328,
				[7] = 30.604999542236328,
				[33] = 30.604999542236328,
				[82] = 0,
				[147] = 0,
				[351] = 0,
				[367] = 0,
				[441] = 0,
				[493] = 0
			}
		},
		{
			name = "23.FarIntensity",
			target = {
				root = "lighting",
				path = { "DepthOfField" }
			},
			property = "FarIntensity",
			value_type = "number",
			values = {
				[0] = 1,
				[7] = 1,
				[33] = 1,
				[82] = 0,
				[147] = 0,
				[351] = 0,
				[367] = 1,
				[441] = 1,
				[493] = 0
			}
		},
		{
			name = "23.FocusDistance",
			target = {
				root = "lighting",
				path = { "DepthOfField" }
			},
			property = "FocusDistance",
			value_type = "number",
			values = {
				[0] = 47.279998779296875,
				[7] = 47.279998779296875,
				[33] = 35.15999984741211,
				[82] = 0,
				[147] = 0,
				[351] = 0,
				[367] = 42.41999816894531,
				[441] = 42.41999816894531,
				[493] = 0
			}
		},
		{
			name = "23.NearIntensity",
			target = {
				root = "lighting",
				path = { "DepthOfField" }
			},
			property = "NearIntensity",
			value_type = "number",
			values = {
				[0] = 1,
				[7] = 1,
				[33] = 1,
				[82] = 0,
				[147] = 0,
				[351] = 0,
				[367] = 1,
				[441] = 1,
				[493] = 0
			}
		},
		{
			name = "24.Color",
			target = {
				root = "camera_rig",
				path = {
					"CamPart",
					"Beams",
					"M3",
					"A",
					"Beams"
				}
			},
			property = "Color",
			value_type = "Color3",
			property_type = "ColorSequence",
			values = {
				[0] = Color3.new(0, 0, 0),
				[529] = Color3.new(0, 0, 0),
				[530] = Color3.new(0, 0, 0),
				[541] = Color3.new(1, 0.42352941632270813, 0.09019608050584793),
				[547] = Color3.new(0.2823529541492462, 0.11992097645998001, 0.025467127561569214),
				[553] = Color3.new(0.37254902720451355, 0.1582290679216385, 0.033602457493543625),
				[555] = Color3.new(0.9333333373069763, 0.396405428647995, 0.08418300002813339),
				[559] = Color3.new(0.125490203499794, 0.053298212587833405, 0.011318723671138287),
				[566] = Color3.new(0.125490203499794, 0.053298212587833405, 0.011318723671138287),
				[582] = Color3.new(0.6823529601097107, 0.2898090183734894, 0.06154555827379227)
			}
		},
		{
			name = "25.Color",
			target = {
				root = "camera_rig",
				path = {
					"CamPart",
					"Beams",
					"M3",
					"A1",
					"Beams"
				}
			},
			property = "Color",
			value_type = "Color3",
			property_type = "ColorSequence",
			values = {
				[0] = Color3.new(0, 0, 0),
				[529] = Color3.new(0, 0, 0),
				[530] = Color3.new(0, 0, 0),
				[541] = Color3.new(0.0784313753247261, 0.0333113819360733, 0.007074201945215464),
				[547] = Color3.new(0.10196078568696976, 0.043304797261953354, 0.009196462109684944),
				[553] = Color3.new(0.03921568766236305, 0.01665569096803665, 0.003537100972607732),
				[555] = Color3.new(0.10980392247438431, 0.046635933220386505, 0.009903882630169392),
				[559] = Color3.new(0.125490203499794, 0.053298212587833405, 0.011318723671138287),
				[566] = Color3.new(0.125490203499794, 0.053298212587833405, 0.011318723671138287),
				[582] = Color3.new(0.06666667014360428, 0.028314676135778427, 0.00601307163015008)
			}
		}
	}
}

-- equivalent calls inferred from this helper; original call sites unknown
local function active(p)
	local run_context = p and p.run_context
	return not run_context or run_context.running == true
end

local function delay_if_active(data, p, callback)
	local thread = nil
	thread = task.delay(tonumber(p) or 0, function()
		local cleanup_tasks = data and (data.cleanup_tasks or data.cleanupTasks)
		local index = cleanup_tasks and table.find(cleanup_tasks, thread)

		if index then
			table.remove(cleanup_tasks, index)
		end

		if active(data) then
			callback()
		end
	end)
	local cleanup_tasks = data and (data.cleanup_tasks or data.cleanupTasks)

	if cleanup_tasks then
		table.insert(cleanup_tasks, thread)
	end

	local cleanup_main = data and (data.cleanup_main or data.cleanupMain)

	if cleanup_main then
		table.insert(cleanup_main, thread)
	end

	return thread
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

local function attr_number(instance, attributeName, p)
	local attribute = instance and instance:GetAttribute(attributeName)

	if typeof(attribute) == "number" then
		return attribute
	end

	return p
end

local function for_each_effect(effect, fn)
	if not effect then
		return
	end

	if effect:IsA("ParticleEmitter") or effect:IsA("Beam") or effect:IsA("Trail") then
		fn(effect)
	end

	for _, effect2 in ipairs(effect:GetDescendants()) do
		if not (effect2:IsA("ParticleEmitter") or effect2:IsA("Beam") or effect2:IsA("Trail")) then
			continue
		end

		fn(effect2)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function set_enabled(p, enabled)
	for_each_effect(p, function(p2)
		p2.Enabled = enabled
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function emit_scoped(p, p2)
	for_each_effect(p2, function(effect)
		if effect:IsA("ParticleEmitter") then
			local emitDelay = effect and effect:GetAttribute("EmitDelay")
			delay_if_active(p, typeof(emitDelay) ~= "number" and 0 or emitDelay, function()
				if effect.Parent then
					local emitCount = effect and effect:GetAttribute("EmitCount")
					effect:Emit((math.max(1, typeof(emitCount) ~= "number" and 1 or emitCount)))
				end
			end)
			local emitDuration = effect:GetAttribute("EmitDuration")

			if emitDuration then
				effect.Enabled = true
				task.delay(emitDuration, function()
					effect.Enabled = false
				end)
			end
		elseif effect:IsA("Beam") or effect:IsA("Trail") then
			local emitDelay = effect and effect:GetAttribute("EmitDelay")
			delay_if_active(p, typeof(emitDelay) ~= "number" and 0 or emitDelay, function()
				if effect.Parent then
					effect.Enabled = true
					local emitDuration = effect and effect:GetAttribute("EmitDuration")
					delay_if_active(p, typeof(emitDuration) ~= "number" and 0.2 or emitDuration, function()
						if effect.Parent then
							effect.Enabled = false
						end
					end)
				end
			end)
		end
	end)
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

FrameEvents.frame_events = {
	[0] = function(p)
		set_enabled(get_child(p.vfx, "AuraFx"), false) -- equivalent call inferred; original call site unknown
		set_enabled(get_child(p.vfx, "StarFx"), false) -- equivalent call inferred; original call site unknown
		set_enabled(get_child(p.vfx, "BGFX"), false) -- equivalent call inferred; original call site unknown
		set_enabled(get_child(p.vfx, "MiniBombFx"), false) -- equivalent call inferred; original call site unknown
		set_enabled(get_child(p.vfx, "DustFx"), false) -- equivalent call inferred; original call site unknown
		set_enabled(get_child(p.vfx, "BombFx"), false) -- equivalent call inferred; original call site unknown
	end,
	[26] = function(p)
		set_enabled(get_child(p.vfx, "AuraFx"), true) -- equivalent call inferred; original call site unknown
	end,
	[73] = function(p)
		set_enabled(get_child(p.vfx, "AuraFx"), false) -- equivalent call inferred; original call site unknown
		set_enabled(get_child(p.vfx, "StarFx"), true) -- equivalent call inferred; original call site unknown
	end,
	[144] = function(p)
		set_enabled(get_child(p.vfx, "StarFx"), false) -- equivalent call inferred; original call site unknown
	end,
	[184] = function(p)
		set_enabled(get_child(p.vfx, "BGFX"), true) -- equivalent call inferred; original call site unknown
	end,
	[320] = function(p)
		emit_scoped(p, get_child(p.vfx, "TransitionFx1")) -- equivalent call inferred; original call site unknown
	end,
	[321] = function(_) end,
	[340] = function()
		local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
		colorCorrectionEffect.Parent = game.Lighting
		game.Debris:AddItem(colorCorrectionEffect, 5)
		local TweenService = game:GetService("TweenService")
		TweenService:Create(colorCorrectionEffect, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
			Brightness = 2,
			TintColor = Color3.fromRGB(255, 229, 164)
		}):Play()
		task.wait(0.2)
		local TweenService2 = game:GetService("TweenService")
		TweenService2:Create(colorCorrectionEffect, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
			Brightness = 0,
			TintColor = Color3.fromRGB(255, 255, 255)
		}):Play()
	end,
	[346] = function(p)
		emit_part_icles(p, get_child(p.vfx, "Mesh", "Explosion"))
		set_enabled(get_child(p.vfx, "MiniBombFx"), true) -- equivalent call inferred; original call site unknown
		set_enabled(get_child(p.vfx, "BGFX"), false) -- equivalent call inferred; original call site unknown
	end,
	[488] = function(p)
		emit_scoped(p, get_child(p.camera_rig, "CamPart", "Fx", "Emit1")) -- equivalent call inferred; original call site unknown
	end,
	[499] = function(p)
		set_enabled(get_child(p.vfx, "DustFx"), true) -- equivalent call inferred; original call site unknown
		set_enabled(get_child(p.vfx, "MiniBombFx"), false) -- equivalent call inferred; original call site unknown
	end,
	[521] = function(p)
		emit_part_icles(p, get_child(p.vfx, "Mesh", "BigExplosion"))
		set_enabled(get_child(p.camera_rig, "ScreenLines"), true) -- equivalent call inferred; original call site unknown
		set_enabled(get_child(p.vfx, "BombFx"), true) -- equivalent call inferred; original call site unknown
	end,
	[533] = function(p)
		local v = get_child(p.vfx, "DustFx")
		set_enabled(v, false) -- equivalent call inferred; original call site unknown
		emit_scoped(p, v) -- equivalent call inferred; original call site unknown
	end,
	[574] = function(p)
		emit_scoped(p, get_child(p.vfx, "Transition")) -- equivalent call inferred; original call site unknown
	end,
	[586] = function(p)
		set_enabled(get_child(p.vfx, "BombFx"), false) -- equivalent call inferred; original call site unknown
		set_enabled(get_child(p.camera_rig, "ScreenLines"), false) -- equivalent call inferred; original call site unknown
	end
}
return FrameEvents