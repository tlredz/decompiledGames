local createVector = vector.create
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = require(ReplicatedStorage:WaitForChild("UserInputService"))
local common = ReplicatedStorage.Common
local controllers = ReplicatedStorage.Controllers
local misc = ReplicatedStorage.Misc
local packages = ReplicatedStorage.Packages
local remotes = ReplicatedStorage.Remotes
local shared = ReplicatedStorage.Shared
local name = script.Name
local localPlayer = Players.LocalPlayer
local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
local v = false
local tsunamiChargesChangedConnection = nil
local tsunamiUsesChangedConnection = nil
require(shared.Abilities)
local Net = require(packages.Net)
local Replion = require(packages.Replion)
local SettingsController = require(controllers.SettingsController)
require(common.Utils)
local remoteFunction = Net:RemoteFunction("NewAbilities/ActivePrimarySlot")
local ability = localPlayer:WaitForChild("PlayerGui"):WaitForChild("Hotbar"):WaitForChild("Ability")
local vector2 = ability:WaitForChild("Vector")
local v2 = Replion.Client:WaitReplion("Data")
local Tsunami = require(shared.Abilities.Tsunami)
local child = localPlayer:WaitForChild("Upgrades"):WaitForChild(name)

-- equivalent calls inferred from this helper; original call sites unknown
local function getUpgradeLevel()
	local v3 = v2:Get({ "AbilityUpgrades", name })
	return (math.max(child.Value, type(v3) ~= "number" and 0 or v3))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getMaxUsesLeft()
	local uses = Tsunami.uses or 1
	return uses + (getUpgradeLevel() >= 1 and 1 or 0)
end

local function getDisplayedUsesLeft(instance)
	if instance then
		local tsunamiUses = instance:GetAttribute("TsunamiUses")

		if type(tsunamiUses) == "number" and not (tsunamiUses <= 0) then
			return (math.max(getMaxUsesLeft() - tsunamiUses, 0))
		end
	end

	return getMaxUsesLeft()
end

local v3 = character
local v4

if v3 then
	local tsunamiUses = v3:GetAttribute("TsunamiUses")

	if type(tsunamiUses) == "number" and not (tsunamiUses <= 0) then
		v4 = math.max(getMaxUsesLeft() - tsunamiUses, 0)
	else
		v4 = getMaxUsesLeft()
	end
else
	v4 = getMaxUsesLeft()
end

-- equivalent calls inferred from this helper; original call sites unknown
local function updateRemainingLabel()
	local ready = ability:FindFirstChild("ready")
	local counts = ready and ready:FindFirstChild("counts")

	if counts and counts:IsA("TextLabel") then
		counts.Text = tostring(v4)
	end
end

local function updateCharacter(character2)
	character = character2
	v = false
	local v5

	if character2 then
		local tsunamiUses = character2:GetAttribute("TsunamiUses")

		if type(tsunamiUses) == "number" and not (tsunamiUses <= 0) then
			v5 = math.max(getMaxUsesLeft() - tsunamiUses, 0)
		else
			v5 = getMaxUsesLeft()
		end
	else
		v5 = getMaxUsesLeft()
	end

	v4 = v5

	if tsunamiChargesChangedConnection then
		tsunamiChargesChangedConnection:Disconnect()
		tsunamiChargesChangedConnection = nil
	end

	if tsunamiUsesChangedConnection then
		tsunamiUsesChangedConnection:Disconnect()
		tsunamiUsesChangedConnection = nil
	end

	local function refreshUsesLeft()
		local v6 = character2
		local v7

		if v6 then
			local tsunamiUses = v6:GetAttribute("TsunamiUses")

			if type(tsunamiUses) == "number" and not (tsunamiUses <= 0) then
				v7 = math.max(getMaxUsesLeft() - tsunamiUses, 0)
			else
				v7 = getMaxUsesLeft()
			end
		else
			v7 = getMaxUsesLeft()
		end

		local v8 = v4 < v7
		v4 = v7
		updateRemainingLabel() -- equivalent call inferred; original call site unknown

		if v8 then
			remotes.VisualBindableCD:Fire(false, true, 0.01)
		end
	end

	tsunamiChargesChangedConnection = character2:GetAttributeChangedSignal("TsunamiCharges"):Connect(refreshUsesLeft)
	tsunamiUsesChangedConnection = character2:GetAttributeChangedSignal("TsunamiUses"):Connect(refreshUsesLeft)
	local ready = ability:FindFirstChild("ready")
	local counts = ready and ready:FindFirstChild("counts")

	if counts then
		if not counts:IsA("TextLabel") then
			return
		end

		counts.Text = tostring(v4)
	end
end

updateCharacter(character)
localPlayer.CharacterAdded:Connect(updateCharacter)

local function updateIcon()
	local child2 = misc.DataAbilities:FindFirstChild(name)

	if not child2 then
		return
	end

	local attributes = child2:GetAttributes()
	local v5 = v2:Get({ "AbilityUpgrades", name })
	local icon = attributes.Icon

	for i = 1, v5 or 0 do
		icon = attributes[`Icon{i}`] or attributes.Icon
	end

	vector2.Image = icon or ""
end

updateIcon()
v2:OnChange({ "AbilityUpgrades", name }, function()
	updateIcon()
	local v5 = character
	local v6

	if v5 then
		local tsunamiUses = v5:GetAttribute("TsunamiUses")

		if type(tsunamiUses) == "number" and not (tsunamiUses <= 0) then
			v6 = math.max(getMaxUsesLeft() - tsunamiUses, 0)
		else
			v6 = getMaxUsesLeft()
		end
	else
		v6 = getMaxUsesLeft()
	end

	v4 = v6
	local ready = ability:FindFirstChild("ready")
	local counts = ready and ready:FindFirstChild("counts")

	if counts then
		if not counts:IsA("TextLabel") then
			return
		end

		counts.Text = tostring(v4)
	end
end)
child.Changed:Connect(function()
	local v5 = character
	local v6

	if v5 then
		local tsunamiUses = v5:GetAttribute("TsunamiUses")

		if type(tsunamiUses) == "number" and not (tsunamiUses <= 0) then
			v6 = math.max(getMaxUsesLeft() - tsunamiUses, 0)
		else
			v6 = getMaxUsesLeft()
		end
	else
		v6 = getMaxUsesLeft()
	end

	v4 = v6
	local ready = ability:FindFirstChild("ready")
	local counts = ready and ready:FindFirstChild("counts")

	if counts then
		if not counts:IsA("TextLabel") then
			return
		end

		counts.Text = tostring(v4)
	end
end)

local function getDirectionPayload()
	local currentCamera = workspace.CurrentCamera
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
	local lookVector

	if currentCamera then
		lookVector = currentCamera.CFrame.LookVector
	else
		lookVector = not (humanoidRootPart and humanoidRootPart:IsA("BasePart")) and createVector(0, 0, 1) or humanoidRootPart.CFrame.LookVector
	end

	local vector3 = Vector3.new(lookVector.X, 0, lookVector.Z)

	if vector3.Magnitude < 0.001 then
		vector3 = not (humanoidRootPart and humanoidRootPart:IsA("BasePart")) and createVector(0, 0, 1) or Vector3.new(
			humanoidRootPart.CFrame.LookVector.X,
			0,
			humanoidRootPart.CFrame.LookVector.Z
		)
	end

	local v5 = vector3.Magnitude < 0.001 and createVector(0, 0, 1) or vector3.Unit
	return { v5.X, v5.Z }
end

local function ability2()
	if not character or character.Parent ~= workspace.Alive or (v or ability.Red.Visible ~= false) then
		return
	end

	if v4 <= 0 then
		ReplicatedStorage.Misc.error:Play()
		return
	end

	local directionPayload = getDirectionPayload()
	v = true
	v4 -= 1
	updateRemainingLabel() -- equivalent call inferred; original call site unknown
	remotes.VisualBindableCD:Fire(false, true, 0.5)
	task.delay(0.5, function()
		v = false
	end)

	if not remoteFunction:InvokeServer(name, directionPayload) then
		local v5 = v4 + 1
		v4 = math.clamp(v5, 0, getMaxUsesLeft())
		local ready = ability:FindFirstChild("ready")
		local counts = ready and ready:FindFirstChild("counts")

		if counts then
			if not counts:IsA("TextLabel") then
				return
			end

			counts.Text = tostring(v4)
		end
	end
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then
		return
	end

	if SettingsController:UseBind(input, "Ability") then
		ability2()
	end
end)
remotes.AbilityButtonPress.Event:Connect(ability2)
remotes.EndCD.OnClientEvent:Connect(function()
	v = false
	local v5 = character
	local v6

	if v5 then
		local tsunamiUses = v5:GetAttribute("TsunamiUses")

		if type(tsunamiUses) == "number" and not (tsunamiUses <= 0) then
			v6 = math.max(getMaxUsesLeft() - tsunamiUses, 0)
		else
			v6 = getMaxUsesLeft()
		end
	else
		v6 = getMaxUsesLeft()
	end

	v4 = v6
	local ready = ability:FindFirstChild("ready")
	local counts = ready and ready:FindFirstChild("counts")

	if counts then
		if not counts:IsA("TextLabel") then
			return
		end

		counts.Text = tostring(v4)
	end
end)