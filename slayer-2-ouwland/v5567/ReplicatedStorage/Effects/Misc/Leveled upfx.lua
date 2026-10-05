local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LevelUpEffect = require(ReplicatedStorage.CAM.Client.Components.NonePackagedMisc.LevelUpEffect)
local Ouwmit = require(ReplicatedStorage.CAM.Client.Modules.Effects.Ouwmit)
local DebrisModule = require(ReplicatedStorage.CAM.DebrisModule)
local RaycastHelper = require(ReplicatedStorage.CAM.Global.RaycastHelper)
return function(player, p, p2, p3)
	if player == nil then
		return
	end

	local character = player.Character

	if character == nil then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart == nil then
		return
	end

	local cFrame = humanoidRootPart.CFrame
	local clone = script.LevelUpEffect:Clone()
	clone.Center.CFrame = cFrame
	clone.Parent = workspace.Debree
	clone.Center.Sound:Play()
	local raycastResult = workspace:Raycast(cFrame.Position, cFrame.UpVector * -15, RaycastHelper.Crater)
	local color

	if not (raycastResult == nil or raycastResult.Instance == nil) then
		color = raycastResult.Instance.Color
	end

	Ouwmit.Emit(clone, Ouwmit.Owned(character, color ~= nil and ({
		Color = color,
		ColorWhitelist = "DustRaycast"
	} or nil) or nil))
	DebrisModule:AddItem(clone, 4)
	local playerGui = player:FindFirstChild("PlayerGui")

	if playerGui == nil then
		return
	end

	local levelUpEffect = LevelUpEffect(playerGui:FindFirstChild("ComponentsHolder"), p, p2, p3)
	task.delay(3, levelUpEffect)
end