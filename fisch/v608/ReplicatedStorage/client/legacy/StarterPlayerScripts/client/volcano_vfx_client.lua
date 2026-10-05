local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("CollectionService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local Shake = require(ReplicatedStorage:WaitForChild("packages").Shake)
local Observers = require(ReplicatedStorage.packages.Observers)
local legacyLocalPlayerData = require(ReplicatedStorage.client.modules.legacyLocalPlayerData)
local currentCamera = Workspace.CurrentCamera
local spawns = Workspace:WaitForChild("world"):WaitForChild("spawns", 1e999)
local fishing = Workspace:WaitForChild("zones"):WaitForChild("fishing", 1e999)
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")
local theme = script.theme
local disableCamShake = nil
local volcanicShake = false
local uIGradients = {}
local v = Shake.new()
v.FadeInTime = 0.65
v.FadeOutTime = 0.5
v.Frequency = 0.85
v.Amplitude = 0.2
v.SustainTime = 0.5
v.Sustain = true
v.RotationInfluence = vector.create(0.05, 0.05, 0.05)

-- equivalent calls inferred from this helper; original call sites unknown
local function getPlayerDistanceToEvent()
	local spawn = spawns:FindFirstChild("Roslit") and spawns.Roslit:FindFirstChild("spawn")

	if not spawn then
		return nil
	end

	local character = localPlayer.Character

	if character and character.PrimaryPart then
		return (spawn.Position - localPlayer.Character.PrimaryPart.Position).Magnitude
	end

	return nil
end

local function updateShake()
	volcanicShake = Workspace:GetAttribute("volcanicShake")
	local v2 = not (disableCamShake and disableCamShake.Value)
	local playerDistanceToEvent = getPlayerDistanceToEvent() -- equivalent call inferred; original call site unknown

	if volcanicShake and v2 and playerDistanceToEvent and playerDistanceToEvent <= 2500 then
		if not v:IsShaking() then
			v.Sustain = true
			v:Start()
			v:BindToRenderStep(Shake.NextRenderName(), Enum.RenderPriority.Last.Value, function(position, data, _)
				currentCamera.CFrame *= CFrame.new(position) * CFrame.Angles(data.X, data.Y, data.Z)
			end)
		end
	elseif v:IsShaking() then
		v.Sustain = false
	end
end

Observers.observeTag("AshfallPoolUIGradient", function(uIGradient)
	if not uIGradient:IsA("UIGradient") then
		return function() end
	end

	table.insert(uIGradients, uIGradient)
	return function()
		local index = table.find(uIGradients, uIGradient)

		if index then
			table.remove(uIGradients, index)
		end
	end
end)
Observers.observeChildren(fishing, function(p)
	if p.Name ~= "Ashfall Pool" then
		return function() end
	end

	updateShake()
	return updateShake
end)
Workspace:GetAttributeChangedSignal("volcanicShake"):Connect(updateShake)
task.defer(updateShake)
task.defer(function()
	disableCamShake = legacyLocalPlayerData.fetch():WaitForChild("Settings"):WaitForChild("disableCamShake")
	updateShake()
end)
local flag = true
RunService.Heartbeat:Connect(function(_: number)
	if flag then
		flag = false
		return
	end

	flag = true
	local playerDistanceToEvent = getPlayerDistanceToEvent() -- equivalent call inferred; original call site unknown

	if playerDistanceToEvent and playerDistanceToEvent <= 750 then
		if not theme.IsPlaying and volcanicShake then
			theme:Play()

			for _, sound in playerGui:GetChildren() do
				if not sound:IsA("Sound") then
					continue
				end

				sound:SetAttribute("defaultVolume", 0.5)
				sound.Volume = 0.5
			end
		end

		if #uIGradients > 0 then
			local v2 = os.clock() % 25 / 25
			local colorSequenceKeypoints = table.create(9)

			for i = 1, 9 do
				local v3 = v2 - (i - 1) / 8

				if v3 < 0 then
					v3 += 1
				end

				colorSequenceKeypoints[i] = ColorSequenceKeypoint.new((i - 1) / 8, Color3.fromHSV(v3, 1, 1))
			end

			local colorSequence = ColorSequence.new(colorSequenceKeypoints)

			for _, v3 in uIGradients do
				v3.Color = colorSequence
			end
		end
	elseif theme.IsPlaying then
		theme:Stop()

		for _, sound in playerGui:GetChildren() do
			if sound:IsA("Sound") then
				sound.Volume = sound:GetAttribute("defaultVolume") or 0.5
			end
		end
	end
end)