local localPlayer = game.Players.LocalPlayer
local humanoidRootPart = (localPlayer.Character or localPlayer.CharacterAdded:Wait()):WaitForChild("HumanoidRootPart")
local anno_localthought = game.ReplicatedStorage:WaitForChild("events"):WaitForChild("anno_localthought")
local goggobiteQuest = workspace:WaitForChild("GoggobiteQuest", 1e999)
local v = {
	A = { "pro", "vis", "ion" },
	B = { "tra", "di", "tion" },
	C = { "u", "ni", "form" },
	D = { "fi", "nan", "cial" },
	E = { "fac", "to", "ry" },
	F = { "ex", "cep", "tion" },
	G = { "wa", "ter", "fall" },
	H = { "se", "cre", "tion" },
	I = { "com", "pu", "ter" },
	J = { "con", "ven", "tion" },
	K = { "trans", "par", "ent" },
	L = { "gen", "er", "ate" },
	M = { "des", "truc", "tion" },
	N = { "de", "pres", "sion" },
	O = { "con", "fi", "dence" },
	P = { "lim", "it", "ed" },
	Q = { "a", "ban", "don" },
	R = { "li", "be", "ral" },
	S = { "in", "fin", "ite" },
	T = { "pre", "val", "ence" },
	U = { "co", "lect", "ion" },
	V = { "in", "fule", "ence" },
	W = { "tri", "vi", "al" },
	X = { "i", "llu", "sion" },
	Y = { "tel", "e", "phone" },
	Z = { "ex", "ten", "sion" },
	["1"] = { "in", "sis", "tence" },
	["2"] = { "ra", "dic", "al" },
	["3"] = { "dif", "fer", "ence" },
	["4"] = { "o", "ver", "all" },
	["5"] = { "go", "ggo", "bite" },
	["6"] = { "ur", "gen", "cy" },
	["7"] = { "an", "a", "lyst" },
	["8"] = { "e", "quin", "ox" },
	["9"] = { "trans", "mis", "sion" },
	["0"] = { "im", "pos", "ter" }
}

local function getCombinedWord(name)
	local upper = name:upper()
	local v2 = upper:sub(1, 1)
	local v3 = upper:sub(math.ceil(#upper / 2), (math.ceil(#upper / 2)))
	local v4 = upper:sub(-1)
	local v5 = v[v2] and v[v2][1] or ""
	local v6 = v[v3] and v[v3][2] or ""
	local v7 = v[v4] and v[v4][3] or ""
	return v5 .. v6 .. v7, v5, v6, v7
end

local combinedWord, section, section2, section3 = getCombinedWord(localPlayer.Name)
local v5 = {
	Section1 = section,
	Section2 = section2,
	Section3 = section3
}
local v6 = {
	GoggobiteDoor1 = { "MerakDoor1Section1", "PolarisDoor1Section2", "BigDipperDoor1Section3" },
	GoggobiteDoor2 = { "LittleDipperDoor2Section1", "BigDipperDoor2Section2", "BigDipperDoor2Section3" },
	GoggobiteDoor3 = { "DubheDoor3Section1", "MerakDoor3Section2", "LittleDipperDoor3Section3" }
}

-- equivalent calls inferred from this helper; original call sites unknown
local function isNear(part)
	if part and part:IsA("BasePart") then
		return (humanoidRootPart.Position - part.Position).Magnitude <= 100
	end

	return false
end

localPlayer.Chatted:Connect(function(value)
	local lower = value:lower()

	for _, child in pairs(goggobiteQuest:GetChildren()) do
		-- equivalent call inferred; original call site unknown
		if not isNear(child) then
			continue
		end

		local v7 = string.match(child.Name, "^(%a+)")

		if not (v7 and lower == v7:lower()) then
			continue
		end

		for k, v8 in pairs(v5) do
			if not child.Name:find(k) then
				continue
			end

			anno_localthought:Fire(v8)
			return
		end
	end

	for childName, _ in pairs(v6) do
		local child = goggobiteQuest:FindFirstChild(childName)

		if not child then
			continue
		end

		local near = isNear(child) -- equivalent call inferred; original call site unknown

		if not (near and lower == combinedWord:lower()) then
			continue
		end

		child.CanCollide = false
		child.Transparency = 0.5
		local v7 = child
		task.delay(5, function()
			if v7 then
				v7.CanCollide = true
				v7.Transparency = 0
			end
		end)
		break
	end
end)