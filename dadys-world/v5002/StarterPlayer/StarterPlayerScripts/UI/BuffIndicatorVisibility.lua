local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MyDataController = require(ReplicatedStorage.Modules.ClientUI.MyDataController)
local SettingsFlags = require(ReplicatedStorage.SharedUtils.SettingsFlags)
local v = { "Settings", "BuffIndicatorToggle" }
local localPlayer = Players.LocalPlayer
local enabled = false
local childAddedConnection = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function applyTo(instance)
	if not instance then
		return
	end

	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart") or instance.PrimaryPart

	if not humanoidRootPart then
		return
	end

	local debuffWindow = humanoidRootPart:FindFirstChild("DebuffWindow")

	if debuffWindow and debuffWindow:IsA("BillboardGui") then
		debuffWindow.Enabled = enabled
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function apply()
	applyTo(localPlayer.Character) -- equivalent call inferred; original call site unknown
end

local function watchCharacter(character)
	if childAddedConnection then
		childAddedConnection:Disconnect()
		childAddedConnection = nil
	end

	if not character then
		return
	end

	local humanoidRootPart = character:WaitForChild("HumanoidRootPart", 10)

	if not humanoidRootPart then
		return
	end

	childAddedConnection = humanoidRootPart.ChildAdded:Connect(function(child)
		if child.Name == "DebuffWindow" then
			applyTo(character) -- equivalent call inferred; original call site unknown
		end
	end)
	applyTo(character) -- equivalent call inferred; original call site unknown
end

watchCharacter(localPlayer.Character)
localPlayer.CharacterAdded:Connect(watchCharacter)
task.spawn(function()
	local v3 = MyDataController:waitForReplica()

	if not v3 then
		return
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function refresh()
		enabled = SettingsFlags:GetEffective(
			MyDataController:getDataFromPath("Settings.BuffIndicatorToggle"),
			"BuffIndicatorToggle"
		) == true
		apply() -- equivalent call inferred; original call site unknown
	end

	v3:ListenToChange(v, refresh)
	SettingsFlags.Changed:Connect(refresh)
	refresh() -- equivalent call inferred; original call site unknown
end)