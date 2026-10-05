local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ProximityPromptService = game:GetService("ProximityPromptService")
local localPlayer = Players.LocalPlayer
local MenuManager = require(ReplicatedStorage.SharedUtils.MenuManager)
local SettingsController = require(ReplicatedStorage:WaitForChild("SharedUI"):WaitForChild("SettingsController"))
task.spawn(SettingsController.init)

-- equivalent calls inferred from this helper; original call sites unknown
local function getRoot()
	local character = localPlayer.Character
	return character and character:FindFirstChild("HumanoidRootPart")
end

local count = 0

-- equivalent calls inferred from this helper; original call sites unknown
local function startAutoCloseMonitor(parent)
	count += 1
	local v = count
	task.spawn(function()
		while v == count and MenuManager:IsOpen("SettingsController") do
			local root = getRoot() -- equivalent call inferred; original call site unknown

			if root and (root.Position - parent.Position).Magnitude > 15 then
				MenuManager:Close("SettingsController")
				break
			else
				task.wait(0.2)
			end
		end
	end)
end

ProximityPromptService.PromptTriggered:Connect(function(player, p)
	if p ~= localPlayer then
		return
	end

	local parent = player.Parent
	local parent2 = parent and parent.Parent

	if not parent2 or parent2.Name ~= "SettingsOpener" then
		return
	end

	if MenuManager:IsOpen("SettingsController") then
		MenuManager:Close("SettingsController")
		return
	end

	MenuManager:Open("SettingsController")

	if parent2:IsA("BasePart") then
		startAutoCloseMonitor(parent2) -- equivalent call inferred; original call site unknown
	end
end)