local ReplicatedStorage = game:GetService("ReplicatedStorage")
local NightcrawlerClass = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
local flag = false
local v = nil
local v2 = false

function SetParticlesEnabled(p)
	if p and not v2 then
		if not (localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")) then
			return
		end

		v2 = true

		for _, child in pairs(localPlayer.Character.HumanoidRootPart:GetChildren()) do
			if not (child.Name == "AuraBack" or child.Name == "CloudyMist" or child.Name == "AuraFront" or child.Name == "Mist" or child.Name == "Specs") then
				continue
			end

			child.Enabled = true
		end
	elseif not p and v2 then
		if not (localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")) then
			return
		end

		v2 = false

		for _, child in pairs(localPlayer.Character.HumanoidRootPart:GetChildren()) do
			if not (child.Name == "AuraBack" or child.Name == "CloudyMist" or child.Name == "AuraFront" or child.Name == "Mist" or child.Name == "Specs") then
				continue
			end

			child.Enabled = false
		end
	end
end

function UpdateLight()
	local lightLevel = Client.GetLightLevel.GetLightLevel(localPlayer)

	if lightLevel ~= v then
		v = lightLevel
		print("SET", lightLevel)

		if lightLevel == "Light" then
			Client.WalkspeedController.RemoveSpeedChange("NightcrawlerSpeed")
		elseif lightLevel == "Shadow" then
			Client.WalkspeedController.AddSpeedChange("NightcrawlerSpeed", "Class", 3)
		elseif lightLevel == "Dark" then
			Client.WalkspeedController.AddSpeedChange("NightcrawlerSpeed", "Class", 6)
		end
	end
end

function EnableClass()
	if flag then
		return
	end

	flag = true
	task.spawn(function()
		while true do
			if Client.Utility.IsInDarkness(localPlayer) then
				SetParticlesEnabled(true)
			else
				SetParticlesEnabled(false)
			end

			task.wait(1)
		end
	end)
	task.spawn(function()
		local function addParticles()
			local humanoidRootPart = (localPlayer.Character or localPlayer.CharacterAdded:Wait()):WaitForChild("HumanoidRootPart")

			if humanoidRootPart:FindFirstChild("AuraBack") then
				return
			end

			local nightcrawlerParticles = ReplicatedStorage.Assets.Particles:FindFirstChild("NightcrawlerParticles")

			for _, child in pairs(nightcrawlerParticles:GetChildren()) do
				local clone = child:Clone()
				clone.Parent = humanoidRootPart
			end

			v2 = false
		end

		localPlayer.CharacterAdded:Connect(function()
			addParticles()
		end)

		if localPlayer.Character then
			addParticles()
		end
	end)
end

function NightcrawlerClass.Init()
	-- equivalent calls inferred from this helper; original call sites unknown
	local function check()
		if localPlayer:GetAttribute("Class") == "Nightcrawler" then
			EnableClass()
		end
	end

	localPlayer:GetAttributeChangedSignal("Class"):Connect(check)
	localPlayer:GetAttributeChangedSignal("ClassLevel"):Connect(check)
	localPlayer:GetAttributeChangedSignal("Talent"):Connect(check)
	check() -- equivalent call inferred; original call site unknown
end

return NightcrawlerClass