require(script.Parent.Auras.Types)
local assets = script.Parent.Auras.Assets

local function auraAttachment(childName: string)
	return assets:WaitForChild(childName):FindFirstChildWhichIsA("Attachment")
end

local AURAS = {}

for k, v2 in {
	GlowAura = {
		name = "GlowAura",
		multiplier = 1.2,
		price = 1000000,
		gamepass = 1841065578,
		full_body = true,
		instance = assets:WaitForChild("GlowAura"):FindFirstChildWhichIsA("Attachment"),
		icon = "rbxassetid://96628369089363",
		color = Color3.fromRGB(183, 233, 255)
	},
	WindAura = {
		name = "WindAura",
		multiplier = 1.5,
		price = 5000000,
		gamepass = 1841089568,
		instance = assets:WaitForChild("WindAura"):FindFirstChildWhichIsA("Attachment"),
		icon = "rbxassetid://100794940939749",
		color = Color3.fromRGB(104, 111, 149)
	},
	WaterAura = {
		name = "WaterAura",
		multiplier = 2,
		price = 10000000,
		gamepass = 1840979522,
		full_body = true,
		instance = assets:WaitForChild("WaterAura"):FindFirstChildWhichIsA("Attachment"),
		icon = "rbxassetid://93367062665094",
		color = Color3.fromRGB(52, 167, 255)
	},
	MedalAura = {
		name = "MedalAura",
		multiplier = 2,
		full_body = true,
		instance = assets:WaitForChild("MedalAura"):FindFirstChildWhichIsA("Attachment"),
		icon = "rbxassetid://102463236218636",
		color = Color3.fromRGB(143, 255, 52)
	},
	FireAura = {
		name = "FireAura",
		multiplier = 3,
		price = 25000000,
		gamepass = 1860376482,
		full_body = true,
		instance = assets:WaitForChild("FireAura"):FindFirstChildWhichIsA("Attachment"),
		icon = "rbxassetid://79901429526247",
		color = Color3.fromRGB(168, 42, 0)
	},
	ElectricAura = {
		name = "ElectricAura",
		multiplier = 4,
		price = 50000000,
		gamepass = 1883044917,
		full_body = true,
		instance = assets:WaitForChild("ElectricAura"):FindFirstChildWhichIsA("Attachment"),
		icon = "rbxassetid://88995860425004",
		color = Color3.fromRGB(255, 222, 34)
	},
	CandyAura = {
		name = "CandyAura",
		multiplier = 5,
		price = 100000000,
		gamepass = 1906711050,
		full_body = true,
		instance = assets:WaitForChild("CandyAura"):FindFirstChildWhichIsA("Attachment"),
		icon = "rbxassetid://132935336874400",
		color = Color3.fromRGB(255, 67, 199)
	},
	ChocolateAura = {
		name = "ChocolateAura",
		multiplier = 6,
		price = 250000000,
		gamepass = 1907952999,
		full_body = true,
		instance = assets:WaitForChild("ChocolateAura"):FindFirstChildWhichIsA("Attachment"),
		icon = "rbxassetid://108501379128287",
		color = Color3.fromRGB(139, 90, 43)
	},
	StormAura = {
		name = "StormAura",
		multiplier = 7,
		price = 500000000,
		gamepass = 1907497088,
		full_body = true,
		instance = assets:WaitForChild("StormAura"):FindFirstChildWhichIsA("Attachment"),
		icon = "rbxassetid://103592451250334",
		color = Color3.fromRGB(135, 143, 255)
	},
	AlphabetAura = {
		name = "AlphabetAura",
		multiplier = 8.5,
		price = 1000000000,
		gamepass = 1950956476,
		full_body = true,
		instance = assets:WaitForChild("AlphabetAura"):FindFirstChildWhichIsA("Attachment"),
		icon = "rbxassetid://128490666760894",
		color = Color3.fromRGB(182, 111, 223)
	},
	DarknessAura = {
		name = "DarknessAura",
		multiplier = 10,
		price = 0,
		gamepass = 1949510491,
		full_body = true,
		instance = assets:WaitForChild("DarknessAura"):FindFirstChildWhichIsA("Attachment"),
		icon = "rbxassetid://81572547324801",
		color = Color3.fromRGB(37, 10, 65)
	},
	GhostAura = {
		name = "GhostAura",
		multiplier = 100,
		price = 1000000000000,
		gamepass = 1998236650,
		full_body = true,
		instance = assets:WaitForChild("GhostAura"):FindFirstChildWhichIsA("Attachment"),
		icon = "rbxassetid://113253935027580",
		color = Color3.fromRGB(219, 101, 22)
	},
	DollarsAura = {
		name = "DollarsAura",
		multiplier = 1.2,
		price = 1000000,
		DevProduct = 3611546605,
		full_body = true,
		instance = assets:WaitForChild("DollarsAura"):FindFirstChildWhichIsA("Attachment"),
		icon = "rbxassetid://125251720917096",
		color = Color3.fromRGB(80, 200, 90),
		EventKey = "Bbno2026"
	},
	BurgerAura = {
		name = "BurgerAura",
		multiplier = 1.5,
		price = 5000000,
		DevProduct = 3611546635,
		full_body = true,
		instance = assets:WaitForChild("BurgerAura"):FindFirstChildWhichIsA("Attachment"),
		icon = "rbxassetid://78421654997594",
		color = Color3.fromRGB(255, 140, 40),
		EventKey = "Bbno2026"
	},
	CruzAura = {
		name = "CruzAura",
		multiplier = 2.5,
		full_body = true,
		instance = assets:WaitForChild("CruzAura"):FindFirstChildWhichIsA("Attachment"),
		icon = "rbxassetid://107397570377750",
		color = Color3.fromRGB(255, 255, 255),
		EventKey = "CruzVsSplinkAdminAbuse",
		RoundedIcon = true
	},
	SplinkAura = {
		name = "SplinkAura",
		multiplier = 2.5,
		full_body = true,
		instance = assets:WaitForChild("SplinkAura"):FindFirstChildWhichIsA("Attachment"),
		icon = "rbxassetid://121303819405043",
		color = Color3.fromRGB(173, 216, 230),
		EventKey = "CruzVsSplinkAdminAbuse",
		RoundedIcon = true
	}
} do
	if v2.available ~= false then
		AURAS[k] = v2
	end
end

return {
	AURAS = AURAS
}