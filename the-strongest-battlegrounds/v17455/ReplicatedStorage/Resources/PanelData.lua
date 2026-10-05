local ReplicatedStorage = game:GetService("ReplicatedStorage")
local v = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function warnOnce(p: string, p2: string)
	if v[p] then
		return
	end

	v[p] = true
	warn("[PanelDataDiag] " .. tostring(p2))
end

local function resolveImpactFrames(childName: string)
	local child = script:FindFirstChild(childName)

	if child and child:FindFirstChild("Frames") then
		return child
	end

	local resources = ReplicatedStorage:FindFirstChild("Resources")

	if resources then
		local child2 = resources:FindFirstChild(childName .. "PanelData", true)

		if child2 and child2:FindFirstChild("Frames") then
			return child2
		end

		local child3 = resources:FindFirstChild(childName, true)

		if child3 and child3:FindFirstChild("Frames") then
			return child3
		end
	end

	warnOnce(
		"impact_frames_missing_" .. childName,
		string.format(
			"Missing impact frames template %s; expected script.%s or ReplicatedStorage.Resources.%sPanelData",
			tostring(childName),
			tostring(childName),
			(tostring(childName))
		)
	) -- equivalent call inferred; original call site unknown
	return nil
end

local impactFrames = resolveImpactFrames("Default")
return {
	Default = {
		Start = 17390567756,
		Background = 17391127089,
		StartSound = 6590147536,
		DomainSound = 7438381072,
		ClashWin = 7372887229,
		ImpactFrames = impactFrames
	},
	Random1 = {
		Start = 17390707925,
		Background = 17391198627,
		StartSound = 6667923288,
		DomainSound = 7147847068,
		ClashWin = 7372887229,
		ImpactFrames = impactFrames
	},
	Random2 = {
		Start = 17390723255,
		Background = 17391198273,
		StartSound = 17393311855,
		DomainSound = 6733254192,
		ClashWin = 7372887229,
		ImpactFrames = impactFrames,
		Offset = CFrame.new(-0.3, 0, -1)
	},
	DoughMan = {
		Start = 17413756140,
		Background = 18221518753,
		StartSound = 17413867679,
		DomainSound = 17413867880,
		ClashWin = 17413867780,
		ImpactFrames = impactFrames,
		Volume = 4
	},
	ShadowMonarch = {
		Start = 17559680450,
		Background = 17599975309,
		SecondaryStart = 18542739237,
		StartSound = 18437726610,
		DomainSound = 18437726333,
		ClashWin = 18437744104,
		ImpactFrames = impactFrames,
		Volume = 4,
		SecondaryVolume = 7
	},
	DisgracedOne = {
		Start = 18273120892,
		Background = 18273398317,
		SecondaryStart = 18543079937,
		SecondaryVolume = 2,
		StartSound = 6590147536,
		DomainSound = 18675023501,
		ClashWin = 18662391676,
		ImpactFrames = impactFrames
	},
	MenacingVampire = {
		Start = 18253167327,
		Speed = 0.75,
		Background = 18227439054,
		StartSound = 18227413398,
		SecondaryStart = 18542763267,
		SecondaryVolume = 2,
		DomainSound = 18227413545,
		ClashWin = 18227413545,
		ImpactFrames = impactFrames,
		Volume = 4,
		StandDelay = 0.1,
		Stand = "The World",
		StandAnim = 18253474650,
		StandOffset = CFrame.new(-2.5, -0.5, 0.5),
		StandSpeed = 1.3
	},
	EarthsWarrior = {
		Start = 18385523261,
		Background = 18384268406,
		StartSound = 18438240081,
		SecondaryStart = 18543080262,
		DomainSound = 18438239730,
		ClashWin = 18438239542,
		ImpactFrames = impactFrames,
		Volume = 4,
		SecondaryVolume = 2
	},
	SoulWarrior = {
		Start = 132883912920255,
		Background = 119702633677046,
		SecondaryStart = 123665959119128,
		SecondaryVolume = 0.5,
		StartSound = 138977264854373,
		DomainSound = 132516411711857,
		ClashWin = 75442577623704,
		ImpactFrames = impactFrames
	},
	GhostShinobi = {
		Start = 110706615780628,
		Background = 100912515457928,
		SecondaryStart = 123665959119128,
		SecondaryVolume = 0.5,
		StartSound = 86257343772243,
		Volume = 7,
		DomainSound = 114765959746236,
		ClashWin = 85030585748423,
		ImpactFrames = impactFrames
	},
	FusionDance = {
		NoHands = true,
		Start = 121078431284864,
		Background = 86997629001213,
		StartSound = 106517118281722,
		StartData2 = 131185622103624,
		DomainSound = 6733254192,
		ClashWin = 7372887229,
		ImpactFrames = impactFrames,
		Offset = CFrame.new(-0.3, 0, -1)
	}
}