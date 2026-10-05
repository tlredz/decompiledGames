local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local Net = require(ReplicatedStorage.packages.Net)
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer.PlayerGui
local _ = script.Parent
local fastTravel = playerGui:WaitForChild("hud"):WaitForChild("safezone"):WaitForChild("FastTravel")
local scroll = fastTravel:WaitForChild("mariana"):WaitForChild("scroll")
local scroll2 = fastTravel:WaitForChild("northern"):WaitForChild("scroll")
local scroll3 = fastTravel:WaitForChild("atlantis"):WaitForChild("scroll")
local scroll4 = fastTravel:WaitForChild("vertigo"):WaitForChild("scroll")
local scroll5 = fastTravel:WaitForChild("jungle"):WaitForChild("scroll")
local scroll6 = fastTravel:WaitForChild("desolate"):WaitForChild("scroll")
local scroll7 = fastTravel:WaitForChild("cultist"):WaitForChild("scroll")
local scroll8 = fastTravel:WaitForChild("tidefall"):WaitForChild("scroll")
local scroll9 = fastTravel:WaitForChild("other"):WaitForChild("scroll")
local switcher = fastTravel:WaitForChild("switcher")
local close = fastTravel:WaitForChild("Close")
local backpack = playerGui:WaitForChild("backpack")
local v = {
	mariana = scroll,
	northern = scroll2,
	atlantis = scroll3,
	vertigo = scroll4,
	jungle = scroll5,
	desolate = scroll6,
	cultist = scroll7,
	tidefall = scroll8,
	other = scroll9
}
local v2 = {
	mariana = {
		"volcanicvents",
		"challengersdeep",
		"abyssalzenith",
		"calmzone",
		"veilofforsaken"
	},
	northern = {
		"base",
		"cryogenic",
		"frigidcavern",
		"glacial",
		"overgrowthcaves",
		"borealpines"
	},
	atlantis = {
		"bellona",
		"apollo",
		"poseidon",
		"zeus",
		"hades",
		"olympian",
		"sunkendepths",
		"etherealabyss",
		"poseidontemple",
		"zeustrial",
		"krakenlair"
	},
	vertigo = {
		"vertigo",
		"thedepths",
		"crystalcove",
		"venue"
	},
	jungle = { "toxicgrove", "livinggarden", "nectarden" },
	desolate = {
		"desolatepocket",
		"brinepool",
		"luminescentcavern",
		"crimsoncavern"
	},
	cultist = {
		"lairentrance",
		"hallofwhispers",
		"passageofoaths",
		"thesanctum"
	},
	tidefall = {
		"sunkenreliquary",
		"coralbastion",
		"collapsedruins",
		"crownedruins"
	},
	other = { "treasureisland", "abovetheclouds" }
}
local v3 = {
	abyssalzenith = "Abyssal Zenith",
	calmzone = "Calm Zone",
	challengersdeep = "Challenger's Deep",
	volcanicvents = "Volcanic Vents",
	veilofforsaken = "Veil of the Forsaken",
	base = nil,
	cryogenic = "Cryogenic Canal",
	frigidcavern = "Frigid Cavern",
	glacial = "Glacial Grotto",
	overgrowthcaves = "Overgrowth Caves",
	borealpines = "Boreal Pines",
	bellona = "Bellona's Frenzy of War",
	apollo = "Apollo's Song of Light",
	poseidon = "Poseidon's Storm of Floods",
	zeus = "Zeus's Thunder of Chaos",
	hades = "Hades' Underworld of Indefinite",
	olympian = "Olympian Fissure",
	sunkendepths = "Sunken Depths",
	etherealabyss = "Ethereal Abyss",
	poseidontemple = "Poseidon Temple",
	zeustrial = "Zeus's Sanctuary",
	krakenlair = "Kraken Lair",
	vertigo = "Vertigo",
	thedepths = "The Depths",
	crystalcove = "Crystal Cove",
	venue = nil,
	toxicgrove = "Toxic Grove",
	livinggarden = "Living Garden",
	nectarden = "Nectar Den",
	crimsoncavern = "Crimson Cavern",
	luminescentcavern = "Luminescent Cavern",
	brinepool = "Brine Pool",
	desolatepocket = "Desolate Deep",
	lairentrance = "Cultist Lair",
	passageofoaths = "Cultist Lair",
	hallofwhispers = "Cultist Lair",
	thesanctum = "Cultist Lair",
	collapsedruins = "Collapsed Ruins",
	coralbastion = "Coral Bastion",
	crownedruins = "Crowned Ruins",
	sunkenreliquary = "Sunken Reliquary",
	treasureisland = nil,
	abovetheclouds = "Above the Clouds"
}

local function toggleUIEffects(p)
	if p then
		TweenService:Create(
			workspace.CurrentCamera,
			TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
			{
				FieldOfView = 60
			}
		):Play()
		TweenService:Create(
			Lighting:WaitForChild("uiblur"),
			TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
			{
				Size = 10
			}
		):Play()
		TweenService:Create(
			Lighting:WaitForChild("uicc"),
			TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
			{
				Brightness = -0.07,
				TintColor = Color3.fromRGB(184, 184, 184),
				Saturation = -0.3
			}
		):Play()
	else
		TweenService:Create(
			workspace.CurrentCamera,
			TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
			{
				FieldOfView = 70
			}
		):Play()
		TweenService:Create(
			Lighting:WaitForChild("uiblur"),
			TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
			{
				Size = 0
			}
		):Play()
		TweenService:Create(
			Lighting:WaitForChild("uicc"),
			TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
			{
				Brightness = 0,
				TintColor = Color3.fromRGB(255, 255, 255),
				Saturation = 0
			}
		):Play()
	end
end

local function handleFade(p)
	backpack.Enabled = false
	local fadeGui = playerGui:FindFirstChild("FadeGui") or Instance.new("ScreenGui")
	fadeGui.Name = "FadeGui"
	fadeGui.Parent = playerGui
	fadeGui.IgnoreGuiInset = true
	local fadeFrame = fadeGui:FindFirstChild("FadeFrame") or Instance.new("Frame")
	fadeFrame.Name = "FadeFrame"
	fadeFrame.Size = UDim2.new(1, 0, 1, 0)
	fadeFrame.Position = UDim2.new(0, 0, 0, 0)
	fadeFrame.BackgroundColor3 = Color3.new(0, 0, 0)
	fadeFrame.BackgroundTransparency = p and 1 or 0
	fadeFrame.Parent = fadeGui
	TweenService:Create(fadeFrame, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
		BackgroundTransparency = p and 0 or 1
	}):Play()

	if not p then
		task.delay(1, function()
			backpack.Enabled = true

			if fadeGui and fadeGui.Parent then
				fadeGui:Destroy()
			end
		end)
	end
end

Net:RemoteEvent("FastTravel/ToggleUI").OnClientEvent:Connect(function(visible, p)
	fastTravel.Visible = visible

	if visible then
		local v4 = false

		for _, v6 in pairs(v) do
			if not v6.Parent.Visible then
				continue
			end

			v4 = true
			break
		end

		if not v4 then
			scroll.Parent.Visible = true
		end

		for k, list in pairs(v2) do
			local v6 = v[k]

			for _, childName in ipairs(list) do
				local price = v6:WaitForChild("safezone"):WaitForChild(childName):WaitForChild("price")
				local lock = v6:WaitForChild("safezone"):WaitForChild(childName):WaitForChild("lock")
				local buy = v6:WaitForChild("safezone"):WaitForChild(childName):WaitForChild("buy")
				local v7 = p and p[childName]
				local v8 = not v7 or v7.InRegion

				if price then
					if v8 then
						price.Visible = false
					else
						price.Visible = true
						price.ZIndex = 5
						price.Text = v7.LockText or "You can't travel there from here!"
					end
				end

				if not (lock and buy) then
					continue
				end

				local v9 = v3[childName]
				local v10

				if v9 then
					local tracker_bestiaryCompletions = workspace:FindFirstChild("PlayerStats") and workspace.PlayerStats:FindFirstChild(localPlayer.Name) and workspace.PlayerStats[localPlayer.Name]:FindFirstChild("T") and workspace.PlayerStats[localPlayer.Name].T:FindFirstChild(localPlayer.Name) and workspace.PlayerStats[localPlayer.Name].T[localPlayer.Name]:FindFirstChild("Stats") and workspace.PlayerStats[localPlayer.Name].T[localPlayer.Name].Stats:FindFirstChild("tracker_bestiaryCompletions")
					v10 = tracker_bestiaryCompletions and tracker_bestiaryCompletions:FindFirstChild(v9) or false
				else
					v10 = not v9
				end

				if v7 and v7.Locked then
					v10 = false
				end

				local visible2 = v10 and v8 and true or false
				lock.Visible = not visible2
				buy.Visible = visible2
			end
		end

		if UserInputService.PreferredInput == Enum.PreferredInput.Gamepad then
			local GamepadService = game:GetService("GamepadService")
			GamepadService:EnableGamepadCursor(fastTravel)
		end
	end
end)
Net:RemoteEvent("FastTravel/Fade").OnClientEvent:Connect(function(p)
	handleFade(p)
end)
local v4 = {}

for childName, v5 in pairs(v) do
	local v6 = v5
	switcher:WaitForChild(childName).Activated:Connect(function()
		for k, v7 in pairs(v) do
			v7.Parent.Visible = v7 == v6
		end
	end)
end

close.Activated:Connect(function()
	fastTravel.Visible = false
end)

for k, list in pairs(v2) do
	local v5 = v[k]

	for _, childName in ipairs(list) do
		local v6 = childName
		v5:WaitForChild("safezone"):WaitForChild(childName):WaitForChild("buy").Activated:Connect(function()
			if v4[v6] then
				return
			end

			v4[v6] = true
			Net:RemoteEvent("FastTravel/Teleport"):FireServer(v6)
			task.delay(2.5, function()
				v4[v6] = nil
			end)
		end)
	end
end