local createVector = vector.create
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local UserInputService = require(ReplicatedStorage2:WaitForChild("UserInputService"))
local _ = ReplicatedStorage.Assets
local controllers = ReplicatedStorage.Controllers
local packages = ReplicatedStorage.Packages
local shared = ReplicatedStorage.Shared
local name = script.Name
require(shared.Abilities)
local Net = require(packages.Net)
local Replion = require(packages.Replion)
local SettingsController = require(controllers.SettingsController)
local Utils = require(ReplicatedStorage.Common.Utils)
local localPlayer = Players.LocalPlayer
local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local v = false
local v2 = false
local mouseButton2 = Enum.UserInputType.MouseButton2
local thread = nil
local remoteFunction = Net:RemoteFunction("NewAbilities/ActivePrimarySlot")
local remoteEvent = Net:RemoteEvent("QuantumArenaDash")
local ability = localPlayer.PlayerGui:WaitForChild("Hotbar"):WaitForChild("Ability")
local v3 = Replion.Client:WaitReplion("Data")

local function updateIcon()
	local child = ReplicatedStorage.Misc.DataAbilities:FindFirstChild(name)

	if not child then
		return
	end

	local attributes = child:GetAttributes()
	local v4 = v3:Get({ "AbilityUpgrades", name })
	local icon = attributes.Icon

	for i = 1, v4 or 0 do
		icon = attributes["Icon" .. i] or attributes.Icon
	end

	ability.Vector.Image = icon or ""
end

task.spawn(updateIcon)
v3:OnChange({ "AbilityUpgrades", name }, updateIcon)

-- equivalent calls inferred from this helper; original call sites unknown
local function getMoveDirection()
	if not humanoid.RootPart then
		return createVector(0, 0, 0)
	end

	local moveDirection = createVector(0, 0, 0)

	if humanoid.MoveDirection == moveDirection then
		if humanoid.WalkToPoint ~= moveDirection then
			moveDirection = humanoid.WalkToPoint - humanoid.RootPart.Position
		end
	else
		moveDirection = humanoid.MoveDirection
	end

	return moveDirection * createVector(1, 0, 1)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getKillsProgress()
	return (math.clamp(
		((character:GetAttribute("QuantumArenaCharge") or 0) - 1 * (character:GetAttribute("QuantumArenaUses") or 0)) / 1,
		0,
		1
	))
end

local function updateKillProgress()
	if workspace:GetAttribute("QuantumArenaActive") == localPlayer.UserId and character:IsDescendantOf(workspace.Alive) then
		return
	end

	local killsProgress = getKillsProgress() -- equivalent call inferred; original call site unknown

	if killsProgress == 0 and character:IsDescendantOf(workspace.Dead) then
		v2 = false
		ReplicatedStorage.Remotes.VisualBindableCD:Fire(false, true, 1, true)
	else
		local quantumArenaFreeCharge = workspace:GetAttribute("QuantumArenaFreeCharge")

		if killsProgress <= 0 and (character:GetAttribute("QuantumArenaCharge") or 0) == 0 and quantumArenaFreeCharge and workspace:GetServerTimeNow() < quantumArenaFreeCharge then
			if not v2 then
				v2 = true
				ReplicatedStorage.Remotes.VisualBindableCD:Fire(
					false,
					true,
					quantumArenaFreeCharge - workspace:GetServerTimeNow()
				)
			end
		else
			v2 = false
			ReplicatedStorage.Remotes.VisualBindableCD:Fire(false, true, math.min(killsProgress, 1), true)
		end
	end
end

local function ability2()
	if v or not character:IsDescendantOf(workspace.Alive) or (character.Parent ~= workspace.Alive or ability.Red.Visible ~= false) then
		return
	end

	local quantumArenaActive = workspace:GetAttribute("QuantumArenaActive")
	local v4 = quantumArenaActive == localPlayer.UserId

	if quantumArenaActive and not v4 then
		ReplicatedStorage.Misc.error:Play()
		return
	end

	local killsProgress = getKillsProgress() -- equivalent call inferred; original call site unknown

	if not v4 and killsProgress < 1 then
		return
	end

	if quantumArenaActive then
		local moveDirection = getMoveDirection() -- equivalent call inferred; original call site unknown

		if moveDirection == createVector(0, 0, 0) then
			ReplicatedStorage.Misc.error:Play()
			return
		end

		local raycastParams = RaycastParams.new()
		raycastParams.FilterType = Enum.RaycastFilterType.Exclude
		raycastParams.FilterDescendantsInstances = {
			workspace.Runtime,
			workspace.Alive,
			workspace.Dead,
			workspace.Balls,
			workspace.TrainingBalls
		}
		local pivot = character:GetPivot()
		local raycastResult = workspace:Raycast(pivot.Position, moveDirection * 35, raycastParams)

		if raycastResult then
			character:PivotTo(character:GetPivot().Rotation + raycastResult.Position)
		else
			character:PivotTo(character:GetPivot() + moveDirection * 35)
		end

		v = true
		ReplicatedStorage.Remotes.VisualBindableCD:Fire(false, true, 1)
		remoteEvent:FireServer(pivot, character:GetPivot())
		thread = task.delay(1, function()
			v = false
			thread = nil

			if workspace:GetAttribute("QuantumArenaActive") ~= localPlayer.UserId and math.clamp(
				((character:GetAttribute("QuantumArenaCharge") or 0) - 1 * (character:GetAttribute("QuantumArenaUses") or 0)) / 1,
				0,
				1
			) < 1 then
				updateKillProgress()
			end
		end)
	else
		if not remoteFunction:InvokeServer(name) then
			return
		end

		ReplicatedStorage.Remotes.VisualBindableCD:Fire(false, true, 4)
		v = true
		thread = task.delay(4, function()
			v = false
			thread = nil
			updateKillProgress()
		end)
	end
end

task.spawn(updateKillProgress)
workspace:GetAttributeChangedSignal("QuantumArenaActive"):Connect(updateKillProgress)
workspace:GetAttributeChangedSignal("QuantumArenaFreeCharge"):Connect(updateKillProgress)
character:GetAttributeChangedSignal("QuantumArenaCharge"):Connect(updateKillProgress)
character:GetAttributeChangedSignal("QuantumArenaUses"):Connect(updateKillProgress)
local v4 = true
script.Destroying:Connect(function()
	v4 = false

	if thread then
		Utils.Thread.SafeCancel(thread)
	end
end)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then
		return
	end

	if SettingsController:UseBind(input, "Ability") then
		ability2()
	end
end)
ReplicatedStorage.Remotes.AbilityButtonPress.Event:Connect(ability2)
ReplicatedStorage.Remotes.EndCD.OnClientEvent:Connect(function()
	v = false

	if thread then
		Utils.Thread.SafeCancel(thread)
		thread = nil
	end

	updateKillProgress()
end)
ReplicatedStorage.Remotes.KeybindM2.OnClientEvent:Connect(function(p)
	if p then
		mouseButton2 = nil
	else
		mouseButton2 = Enum.UserInputType.MouseButton2
	end
end)
character.AncestryChanged:Connect(function(_, parent)
	if parent == workspace.Alive then
		updateKillProgress()
	end
end)