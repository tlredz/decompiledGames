local RunService = game:GetService("RunService")
local localPlayer = game.Players.LocalPlayer
local presentation = game.ReplicatedStorage:WaitForChild("ChickenOrHero"):WaitForChild("Presentation")
local ThreatIndicatorConfig = require(presentation:WaitForChild("ThreatIndicatorConfig"))
local ThreatIndicatorModel = require(presentation:WaitForChild("ThreatIndicatorModel"))
local ParticipantDirectory = require(presentation:WaitForChild("ParticipantDirectory"))
local session = presentation.Parent.Game.Session
local ring = script.Parent:WaitForChild("Ring")
local frames = {}
local v = {}
local v2 = {}
local updateInterval = 0

for _, frame in ring:GetChildren() do
	if not (frame:IsA("Frame") and frame:GetAttribute("Angle")) then
		continue
	end

	table.insert(frames, frame)
	v[frame] = 0
	v2[frame] = 0
end

local function eligible()
	local character = localPlayer.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local phase = session:GetAttribute("Phase")
	local enabled = ThreatIndicatorConfig.Enabled

	if not enabled then
		return enabled
	end

	if localPlayer:GetAttribute("InMatch") == true and localPlayer:GetAttribute("GameRole") == "Runner" and localPlayer:GetAttribute("RunState") == "Active" then
		if character then
			if humanoid then
				if humanoid.Health > 0 then
					enabled = not (character:GetAttribute("MovementLocked") or localPlayer:GetAttribute("ChoiceSpotlightActive")) and not (localPlayer:GetAttribute("ScreenPresentationActive") or localPlayer:GetAttribute("TutorialModalActive")) and (phase == "HeroRun" or phase == "GroupRun" or phase == "FinalRun")
				else
					enabled = false
				end
			else
				enabled = humanoid
			end
		else
			enabled = character
		end
	else
		enabled = false
	end

	return enabled
end

-- equivalent calls inferred from this helper; original call sites unknown
local function publishThreat(catcherThreatIntensity)
	localPlayer:SetAttribute("CatcherThreatIntensity", catcherThreatIntensity)
	localPlayer:SetAttribute("CatcherThreatUpdatedAt", workspace:GetServerTimeNow())
end

local function sample()
	publishThreat(0) -- equivalent call inferred; original call site unknown

	for _, v3 in frames do
		v2[v3] = 0
	end

	local character = localPlayer.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
	local currentCamera = workspace.CurrentCamera

	if not (humanoidRootPart and currentCamera) then
		return
	end

	local list = ParticipantDirectory.list()
	local characters = {}

	for _, v3 in list do
		if v3.Character then
			table.insert(characters, v3.Character)
		end
	end

	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = characters
	raycastParams.RespectCanCollide = true
	local samples = {}

	for _, v3 in list do
		if not (v3.UserId ~= localPlayer.UserId and v3:GetAttribute("GameRole") == "Catcher" and v3:GetAttribute("RunState") == "Active") then
			continue
		end

		local character2 = v3.Character
		local humanoidRootPart2 = character2 and character2:FindFirstChild("HumanoidRootPart")
		local humanoid = character2 and character2:FindFirstChildOfClass("Humanoid")

		if not humanoidRootPart2 or not humanoid or not (humanoid.Health > 0) or character2:GetAttribute("MovementLocked") then
			continue
		end

		local sample2 = ThreatIndicatorModel.sample(
			humanoidRootPart.Position,
			humanoidRootPart.AssemblyLinearVelocity,
			currentCamera.CFrame.LookVector,
			humanoidRootPart2.Position,
			humanoidRootPart2.AssemblyLinearVelocity,
			ThreatIndicatorConfig
		)

		if not sample2 or workspace:Raycast(
			humanoidRootPart.Position,
			humanoidRootPart2.Position - humanoidRootPart.Position,
			raycastParams
		) then
			continue
		end

		table.insert(samples, sample2)
	end

	table.sort(samples, function(a, b)
		return a.strength > b.strength
	end)

	while #samples > ThreatIndicatorConfig.MaxThreats do
		table.remove(samples)
	end

	publishThreat(not samples[1] and 0 or samples[1].strength or 0) -- equivalent call inferred; original call site unknown

	for _, v4 in frames do
		v2[v4] = ThreatIndicatorModel.sector(v4:GetAttribute("Angle"), samples, ThreatIndicatorConfig.ArcWidth)
	end
end

local renderSteppedConnection = RunService.RenderStepped:Connect(function(dt)
	if eligible() then
		updateInterval += dt

		if updateInterval >= ThreatIndicatorConfig.UpdateInterval then
			updateInterval = 0
			sample()
		end

		local visible = false

		for _, v4 in frames do
			local v5 = v[v4]
			local v6 = v2[v4]
			local fadeInTime = v5 < v6 and ThreatIndicatorConfig.FadeInTime or ThreatIndicatorConfig.FadeOutTime
			local v7 = v5 + (v6 - v5) * (1 - math.exp(-dt / fadeInTime))
			v[v4] = v7
			v4.BackgroundTransparency = 1 - v7 * ThreatIndicatorConfig.MaxOpacity

			if v7 > 0.015 then
				visible = true
			end
		end

		ring.Visible = visible
	else
		publishThreat(0) -- equivalent call inferred; original call site unknown
		ring.Visible = false
		updateInterval = ThreatIndicatorConfig.UpdateInterval

		for _, v3 in frames do
			v[v3] = 0
			v2[v3] = 0
			v3.BackgroundTransparency = 1
		end
	end
end)
script.Destroying:Connect(function()
	renderSteppedConnection:Disconnect()
	ring.Visible = false
	publishThreat(0) -- equivalent call inferred; original call site unknown
end)