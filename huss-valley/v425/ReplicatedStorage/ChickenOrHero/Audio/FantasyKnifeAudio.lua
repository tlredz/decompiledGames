local v = {
	EmberCommon = {
		105793298027133,
		134671877618939,
		9119747138,
		"FantasyCommon"
	},
	EmberRare = {
		9119742466,
		125914564702009,
		9119747163,
		"FantasyRare"
	},
	EmberEpic = {
		9114446802,
		9114446852,
		110870147282698,
		"MoltenFang"
	},
	EmberLegendary = {
		104896783166331,
		9125646252,
		140491618332570,
		"VoidSovereign"
	},
	CelestialCommon = {
		9119744718,
		138283030240531,
		138293953015099,
		"FantasyCommon"
	},
	CelestialRare = {
		9125647212,
		9125648149,
		107001835875685,
		"FantasyRare"
	},
	CelestialEpic = {
		9116394545,
		9125647528,
		93592528031453,
		"StormTalon"
	},
	CelestialLegendary = {
		9116395089,
		9125646242,
		104220464553864,
		"CelestialDragon"
	}
}
local clones = {
	FantasyCommon = {
		9116190478,
		9113824230,
		5789211405,
		9116194425,
		9125619589,
		9116194421,
		9116194421,
		0,
		1,
		0
	},
	FantasyRare = {
		9119742466,
		9119748082,
		9119749145,
		9126014020,
		9113449585,
		9119747260,
		9126013811,
		0,
		1.1,
		0
	},
	MoltenFang = {
		7518441422,
		9117878426,
		101467914599270,
		9126014020,
		88644431848133,
		9116194421,
		9126013811,
		100970228713833,
		0.82,
		0.13
	},
	SpectralReaper = {
		9125647212,
		9125647922,
		9125648149,
		9125646252,
		9125646917,
		9125646918,
		9125648137,
		110631293617327,
		0.86,
		0.12
	},
	SolarPhoenix = {
		110631293617327,
		9117878426,
		137373404763792,
		81857580097150,
		9113449585,
		9119747260,
		9126013811,
		9126073001,
		1.16,
		0.16
	},
	VoidSovereign = {
		1216343787,
		9125647922,
		129561737395908,
		75787837073401,
		101387462540484,
		9125646918,
		9125648137,
		9120709480,
		0.72,
		0.15
	},
	StormTalon = {
		9119744718,
		132839917432435,
		122312400582724,
		136080815136211,
		98609496290942,
		9125616884,
		9113133597,
		88644431848133,
		1.28,
		0.11
	},
	Moonfang = {
		9125994570,
		9119748082,
		9126013477,
		9126013644,
		9125362690,
		9125994543,
		9126013811,
		5621616510,
		0.94,
		0.13
	},
	GlacialCrown = {
		9119742466,
		9114861389,
		9119749145,
		9126014020,
		116374735080767,
		9114860944,
		9113041458,
		93748663519982,
		1.35,
		0.15
	},
	CelestialDragon = {
		5614963261,
		9117878426,
		132839917432435,
		9120972444,
		88644431848133,
		9119747260,
		9113133597,
		1216343787,
		0.91,
		0.17
	}
}
local v2 = {
	"Equip",
	"Windup",
	"Swing",
	"Dive",
	"Hit",
	"Sheath",
	"Cancel"
}
local FantasyKnifeAudio = {}

for k, v3 in v do
	local clone = table.clone(clones[v3[4]])
	local v4 = v3[1]
	local v5 = v3[2]
	local v6 = v3[3]
	clone[1] = v4
	clone[3] = v5
	clone[5] = v6
	clone[8] = 0
	clone[9] = 1
	clone[10] = 0
	clones[k] = clone
end

local v3 = {
	Equip = 0.24,
	Windup = 0.1,
	Swing = 0.24,
	Dive = 0.28,
	Hit = 0.34,
	Sheath = 0.14,
	Cancel = 0.1
}
local v4 = {
	Equip = 1,
	Windup = 0.94,
	Swing = 1.1,
	Dive = 0.98,
	Hit = 1,
	Sheath = 1.08,
	Cancel = 0.9
}

local function sound(parent, name, p, volume, playbackSpeed)
	local v5 = parent:FindFirstChild(name)

	if not v5 then
		v5 = Instance.new("Sound")
		v5.Name = name
		v5.Parent = parent
	end

	v5.SoundId = "rbxassetid://" .. p
	v5.Volume = volume
	v5.PlaybackSpeed = playbackSpeed
	v5.Looped = false
	v5.PlayOnRemove = false
	v5.RollOffMaxDistance = 100
	v5.RollOffMinDistance = 7
	v5:SetAttribute("Enabled", true)
	v5:SetAttribute("PitchVariation", 0.018)
	v5:SetAttribute("KnifeMaxSeconds", (name == "Equip" or name == "Hit" or string.find(name, "Signature")) and 3 or 2)
	return v5
end

function FantasyKnifeAudio.install(p)
	local parent = p.library:FindFirstChild("08_Knives")

	if not parent then
		parent = Instance.new("Folder")
		parent.Name = "08_Knives"
		parent.Parent = p.library
	end

	for _, childName in { "BaseDagger", "SpoonDagger" } do
		local child = parent:FindFirstChild(childName)
		local sheath = child and child:FindFirstChild("Sheath")

		if not child or not sheath or child:FindFirstChild("Cancel") then
			continue
		end

		local clone = sheath:Clone()
		clone.Name = "Cancel"
		clone.Volume *= 0.7
		clone.Parent = child
	end

	for childName, v6 in clones do
		local v7 = parent:FindFirstChild(childName)

		if not v7 then
			v7 = Instance.new("Folder")
			v7.Name = childName
			v7.Parent = parent
		end

		for k, v8 in v2 do
			sound(
				v7,
				v8,
				v6[k],
				v[childName] and (v8 == "Equip" or v8 == "Swing" or v8 == "Hit") and 0.35 or v3[v8],
				v4[v8] * v6[9]
			)
			local v9 = "Knife_" .. childName .. "_" .. v8
			p.catalog[v9] = {
				Path = "08_Knives/" .. childName .. "/" .. v8,
				MinInterval = v8 == "Windup" and 0.9 or 0.09
			}

			if not (v6[8] ~= 0 and (v8 == "Equip" or v8 == "Dive" or v8 == "Hit")) then
				continue
			end

			local name = v8 .. "Signature"
			sound(v7, name, v6[8], v6[10] * (v8 == "Hit" and 1 or 0.65), v6[9] * (v8 == "Hit" and 0.92 or 1.12))
			p.catalog[v9 .. "Signature"] = {
				Path = "08_Knives/" .. childName .. "/" .. name,
				MinInterval = 0.12
			}
		end
	end
end

function FantasyKnifeAudio.layer(object, p, p2, p3)
	if object.catalog[p .. "Signature"] then
		object:one(p .. "Signature", p2, p3)
	end
end

return FantasyKnifeAudio