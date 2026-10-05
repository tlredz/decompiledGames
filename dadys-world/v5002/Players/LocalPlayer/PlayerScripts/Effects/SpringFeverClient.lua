local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local localPlayer = Players.LocalPlayer
local info = workspace:WaitForChild("Info")
local SpringFeverArt = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Zones"):WaitForChild("SpringFeverArt"))
local flag = false
local renderSteppedConnection = nil
local v = nil

local function updateSpeedBlur()
	local character = localPlayer.Character

	if not character then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return
	end

	local position = humanoidRootPart.Position

	if not v then
		v = position
		return
	end

	local v2 = (position - v).Magnitude / 0.033
	v = position
	SpringFeverArt.UpdateSpeedBlur(v2, character, humanoidRootPart)
end

local function updateVisuals()
	local character = localPlayer.Character

	if not character then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return
	end

	local position = humanoidRootPart.Position

	if not v then
		v = position
		return
	end

	local v2 = (position - v).Magnitude / 0.033
	v = position
	SpringFeverArt.UpdateSpeedBlur(v2, character, humanoidRootPart)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function activate()
	if flag then
		return
	end

	flag = true
	local character = localPlayer.Character

	if character then
		SpringFeverArt.Activate(character)
	end

	v = nil
	renderSteppedConnection = RunService.RenderStepped:Connect(updateVisuals)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function deactivate()
	if not flag then
		return
	end

	flag = false
	SpringFeverArt.Deactivate()

	if renderSteppedConnection then
		renderSteppedConnection:Disconnect()
		renderSteppedConnection = nil
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function checkState()
	if info:GetAttribute("SpringFeverActive") then
		activate() -- equivalent call inferred; original call site unknown
	else
		deactivate() -- equivalent call inferred; original call site unknown
	end
end

info:GetAttributeChangedSignal("SpringFeverActive"):Connect(checkState)
checkState() -- equivalent call inferred; original call site unknown
localPlayer.CharacterAdded:Connect(function(character)
	if not flag then
		return
	end

	task.wait(1)

	if not flag then
		return
	end

	SpringFeverArt.OnRespawn(character)
end)