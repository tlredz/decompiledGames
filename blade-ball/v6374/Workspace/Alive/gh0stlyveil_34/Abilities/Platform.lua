local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local localPlayer = game.Players.LocalPlayer
local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local UserInputService = require(ReplicatedStorage2:WaitForChild("UserInputService"))
local ReplicatedStorage3 = game:GetService("ReplicatedStorage")
local humanoid = character:WaitForChild("Humanoid")
game:GetService("Debris")
local RunService = game:GetService("RunService")
local SettingsController = require(ReplicatedStorage3:WaitForChild("Controllers"):WaitForChild("SettingsController"))
local Abilities = require(ReplicatedStorage.Shared.Abilities)
local SpeedModifiers = require(ReplicatedStorage3.Shared.SpeedModifiers)
local Utils = require(ReplicatedStorage.Common.Utils)
local platform = script:WaitForChild("Platform")
local track = humanoid:FindFirstChildOfClass("Animator"):LoadAnimation(platform)
local flag = false
local thread = nil
local mouseButton2 = Enum.UserInputType.MouseButton2
local vector2 = localPlayer:WaitForChild("PlayerGui"):WaitForChild("Hotbar"):WaitForChild("Ability"):WaitForChild("Vector")
local module = require(game.ReplicatedStorage.Shared.Abilities[script.Name])
vector2.Image = module and module.iconId or ""

local function ability()
	if flag or (localPlayer.Character.Parent ~= workspace.Alive or localPlayer.PlayerGui.Hotbar.Ability.Red.Visible) or humanoid.FloorMaterial == Enum.Material.Air then
		return
	end

	flag = true
	local abilityCooldown = Abilities.getAbilityCooldown(localPlayer, script.Name)
	local v = SpeedModifiers:SetModifierFor(
		character,
		"Initial Platform Debuff",
		SpeedModifiers.Utils.MinDebuff(character, 0),
		SpeedModifiers.Priority.DEBUFF
	)
	ReplicatedStorage3.Remotes.VisualBindableCD:Fire(false, true, abilityCooldown)
	track:Play(0.05, 1, 0.75)
	task.spawn(function()
		task.wait(0.2)
		ReplicatedStorage3.Remotes.Platform:FireServer()
		task.wait(0.1)
		v()
	end)
	thread = task.delay(abilityCooldown, function()
		flag = false
		thread = nil
	end)
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then
		return
	end

	if SettingsController:UseBind(input, "Ability") then
		ability()
	end
end)
ReplicatedStorage3.Remotes.AbilityButtonPress.Event:Connect(function()
	ability()
end)
ReplicatedStorage3.Remotes.EndCD.OnClientEvent:Connect(function()
	flag = false

	if thread then
		Utils.Thread.SafeCancel(thread)
		thread = nil
	end
end)
ReplicatedStorage3.Remotes.KeybindM2.OnClientEvent:Connect(function(p)
	if p then
		mouseButton2 = nil
	else
		mouseButton2 = Enum.UserInputType.MouseButton2
	end
end)
local preSimulationConnection = nil
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Include
raycastParams.FilterDescendantsInstances = { workspace.Runtime }
local overlapParams = OverlapParams.new()
overlapParams.FilterType = Enum.RaycastFilterType.Include
overlapParams.FilterDescendantsInstances = { workspace.Runtime }
local cFrame = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function startPlatformUpdate()
	if preSimulationConnection then
		preSimulationConnection:Disconnect()
	end

	cFrame = nil
	preSimulationConnection = RunService.PreSimulation:Connect(function(_: number)
		local primaryPart = character.PrimaryPart

		if primaryPart then
			local cFrame2 = primaryPart.CFrame
			local v = nil
			local raycastResult = workspace:Raycast(
				cFrame2.Position + createVector(0, 15, 0),
				createVector(-0, -35, -0),
				raycastParams
			)
			local instance = raycastResult and raycastResult.Instance

			if not raycastResult then
				for _, v2 in workspace:GetPartBoundsInBox(cFrame2, createVector(1, 1, 1), overlapParams) do
					if v2:HasTag("Platform") then
						instance = v2
					end
				end
			end

			if instance and instance:HasTag("Platform") then
				local ownerCharacter = instance:FindFirstChild("OwnerCharacter")

				if ownerCharacter and ownerCharacter.Value == character then
					v = instance
				end
			end

			if not v then
				cFrame = nil
				return
			end

			if not cFrame then
				cFrame = v.CFrame
			end

			local cFrame3 = v.CFrame
			local v2 = cFrame3 * cFrame:Inverse()
			cFrame = cFrame3
			primaryPart.CFrame = v2 * cFrame2
		else
			cFrame = nil

			if preSimulationConnection then
				preSimulationConnection:Disconnect()
				preSimulationConnection = nil
			end
		end
	end)
end

character.AncestryChanged:Connect(function(_, parent)
	if parent == workspace.Alive then
		startPlatformUpdate() -- equivalent call inferred; original call site unknown
	elseif preSimulationConnection then
		preSimulationConnection:Disconnect()
		preSimulationConnection = nil
	end
end)

if character:IsDescendantOf(workspace.Alive) then
	if preSimulationConnection then
		preSimulationConnection:Disconnect()
	end

	cFrame = nil
	preSimulationConnection = RunService.PreSimulation:Connect(function(_: number)
		local primaryPart = character.PrimaryPart

		if primaryPart then
			local cFrame2 = primaryPart.CFrame
			local v = nil
			local raycastResult = workspace:Raycast(
				cFrame2.Position + createVector(0, 15, 0),
				createVector(-0, -35, -0),
				raycastParams
			)
			local instance = raycastResult and raycastResult.Instance

			if not raycastResult then
				for _, v2 in workspace:GetPartBoundsInBox(cFrame2, createVector(1, 1, 1), overlapParams) do
					if v2:HasTag("Platform") then
						instance = v2
					end
				end
			end

			if instance and instance:HasTag("Platform") then
				local ownerCharacter = instance:FindFirstChild("OwnerCharacter")

				if ownerCharacter and ownerCharacter.Value == character then
					v = instance
				end
			end

			if not v then
				cFrame = nil
				return
			end

			if not cFrame then
				cFrame = v.CFrame
			end

			local cFrame3 = v.CFrame
			local v2 = cFrame3 * cFrame:Inverse()
			cFrame = cFrame3
			primaryPart.CFrame = v2 * cFrame2
		else
			cFrame = nil

			if preSimulationConnection then
				preSimulationConnection:Disconnect()
				preSimulationConnection = nil
			end
		end
	end)
end