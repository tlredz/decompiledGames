local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local UserInputService = require(ReplicatedStorage2:WaitForChild("UserInputService"))
local Workspace = game:GetService("Workspace")
local controllers = ReplicatedStorage.Controllers
local packages = ReplicatedStorage.Packages
local misc = ReplicatedStorage.Misc
local name = script.Name
local Net = require(packages.Net)
local Replion = require(packages.Replion)
local SettingsController = require(controllers.SettingsController)
local Utils = require(ReplicatedStorage.Common.Utils)
local localPlayer = Players.LocalPlayer
local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
local v = false
local flag = false
local thread = nil
local remoteFunction = Net:RemoteFunction("NewAbilities/ActivePrimarySlot")
local ability = localPlayer.PlayerGui:WaitForChild("Hotbar"):WaitForChild("Ability")
local counts = ability:WaitForChild("ready"):WaitForChild("counts")
local v2 = Replion.Client:WaitReplion("Data")

local function updateIcon()
	local child = misc.DataAbilities:FindFirstChild(name)

	if not child then
		return
	end

	local attributes = child:GetAttributes()
	local v3 = v2:Get({ "AbilityUpgrades", name })
	local icon = attributes.Icon

	for i = 1, v3 or 0 do
		icon = attributes["Icon" .. i] or attributes.Icon
	end

	ability.Vector.Image = icon or ""
end

task.spawn(updateIcon)
v2:OnChange({ "AbilityUpgrades", name }, updateIcon)

-- equivalent calls inferred from this helper; original call sites unknown
local function cancelUpdateThread()
	if thread then
		Utils.Thread.SafeCancel(thread)
		thread = nil
	end
end

local update

update = function()
	flag = false
	local necromancersLeft = character:GetAttribute("NecromancersLeft") or 0
	local necromancersCooldown = character:GetAttribute("NecromancersCooldown")
	local necromancersActive = character:GetAttribute("NecromancersActive") or 0
	local serverTimeNow = Workspace:GetServerTimeNow()

	if counts then
		counts.Text = tostring(necromancersLeft)
	end

	if necromancersLeft <= 0 or necromancersActive > 0 then
		v = false
		ReplicatedStorage.Remotes.VisualBindableCD:Fire(false, true, 0, true)
	elseif necromancersCooldown and serverTimeNow < necromancersCooldown then
		if not v then
			cancelUpdateThread() -- equivalent call inferred; original call site unknown
			ReplicatedStorage.Remotes.VisualBindableCD:Fire(false, true, necromancersCooldown - serverTimeNow)
			v = true
			thread = task.spawn(function()
				repeat
					task.wait(0.1)
					local serverTimeNow2 = Workspace:GetServerTimeNow()
					local necromancersCooldown2 = character:GetAttribute("NecromancersCooldown")
				until not necromancersCooldown2 or necromancersCooldown2 <= serverTimeNow2

				update()
			end)
		end
	else
		cancelUpdateThread() -- equivalent call inferred; original call site unknown
		v = false
		ReplicatedStorage.Remotes.VisualBindableCD:Fire(false, true, 1, true)
		flag = true
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function ability2()
	if flag then
		remoteFunction:InvokeServer(name)
	else
		misc.error:Play()
	end
end

local v3 = true
script.Destroying:Connect(function()
	v3 = false
	cancelUpdateThread() -- equivalent call inferred; original call site unknown
end)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then
		return
	end

	if SettingsController:UseBind(input, "Ability") then
		ability2() -- equivalent call inferred; original call site unknown
	end
end)
character:GetAttributeChangedSignal("NecromancersLeft"):Connect(update)
character:GetAttributeChangedSignal("NecromancersCooldown"):Connect(update)
character:GetAttributeChangedSignal("NecromancersActive"):Connect(update)
Workspace.Alive.ChildAdded:Connect(update)
Workspace.Alive.ChildRemoved:Connect(update)
ReplicatedStorage.Remotes.AbilityButtonPress.Event:Connect(ability2)
ReplicatedStorage.Remotes.EndCD.OnClientEvent:Connect(update)
task.spawn(update)