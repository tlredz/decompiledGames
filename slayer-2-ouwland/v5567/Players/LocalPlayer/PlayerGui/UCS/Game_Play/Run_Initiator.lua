local v = false
local Run_Handler = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Client"):WaitForChild("Modules"):WaitForChild("GamePlay"):WaitForChild("Run_Handler"))
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local InputHandler = require(ReplicatedStorage.CAM.Client.Components.Client.InputHandler)
local DataValue = require(ReplicatedStorage.CAM.Client.Modules.DataValue)
local SettingsKeys = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.SettingsKeys)
local cleanit = require(ReplicatedStorage.Packages.cleanit)
local localPlayer = game.Players.LocalPlayer

if Run_Handler.LifeCleaner ~= nil then
	Run_Handler.LifeCleaner:Clean()
end

local maid = cleanit.new()
Run_Handler.LifeCleaner = maid
Run_Handler.Toggled = false
task.spawn(function()
	local humanoid = (localPlayer.Character or localPlayer.CharacterAdded:Wait()):WaitForChild("Humanoid", 10)

	if humanoid == nil then
		return
	end

	humanoid.Died:Connect(function()
		Run_Handler.Toggled = false
	end)
end)
local v2 = maid:Add(DataValue.new(SettingsKeys.RunToggle.Path, SettingsKeys.RunToggle.Default, SettingsKeys.Scope))

local function toggles()
	return v2:Get() == true
end

local v3 = maid:Add(DataValue.new(
	SettingsKeys.StrictShiftLock.Path,
	SettingsKeys.StrictShiftLock.Default,
	SettingsKeys.Scope
))

-- equivalent calls inferred from this helper; original call sites unknown
local function publishMode()
	Run_Handler.RunToggles = v3:Get() == true
end

publishMode() -- equivalent call inferred; original call site unknown
v2.Changed:Connect(function()
	v = false
	Run_Handler.Toggled = false
end)
v3.Changed:Connect(publishMode)
maid:Add(InputHandler.ListenTo("Run", function(p, p2)
	if p == "Down" then
		if p2 then
			return
		end

		if v2:Get() == true then
			Run_Handler.Toggled = not Run_Handler.Toggled
		else
			v = true
		end
	elseif p == "Up" then
		if v2:Get() == true then
			return
		else
			v = false
		end
	end
end))

if v2:Get() ~= true and InputHandler.IsDown("Run") then
	v = true
end

require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Subsets"):WaitForChild("Gameplay"):WaitForChild("StatsFetch"))
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local getvaluesfolder = Utility.getvaluesfolder(localPlayer)

while true do
	local is_Running = false

	if getvaluesfolder:FindFirstChild("CombatStun") == nil and getvaluesfolder:FindFirstChild("Strict_Stun") == nil and getvaluesfolder:FindFirstChild("Ragdoll") == nil and getvaluesfolder:FindFirstChild("RagDoll") == nil and (v == true or Run_Handler.Toggled == true) then
		is_Running = Run_Handler.check_can_run() == true or false
	end

	if Run_Handler.Is_Running ~= is_Running then
		Run_Handler.Is_Running = is_Running
		Run_Handler.RunningChanged:Fire(is_Running)
	end

	task.wait(0.1)
end