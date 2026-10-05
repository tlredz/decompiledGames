local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
require3(script.Parent._Types)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local v = require3(ReplicatedStorage2.Shared.ThreadSafeTargetingHelper)
local v2 = require3(ReplicatedStorage2.Misc.LightningBolt)
local v3 = require3(ReplicatedStorage2.Misc.LightningBolt.LightningSparks)
local v4 = require3(ReplicatedStorage2.Shared.ShockwaveEffect)
local Swap = {}
Swap.cooldown = 25
Swap.cooldownReductionPerUpgrade = 6
Swap.iconId = "rbxassetid://14919629746"

function Swap.validateArguments(state, p)
	assert(state ~= nil, "Bad arguments")
	assert(typeof(state.target) == "Instance", "Bad target")
	assert(state.target.Parent == workspace.Alive, "Bad target parent")
	assert(state.target:IsA("Model"), "Invalid target")
	assert(state.user == p.character, "Invalid user")
	assert(state.user ~= state.target, "Invalid selection")
	state.userPivot = state.user:GetPivot()
	state.targetPivot = state.target:GetPivot()
end

function Swap.canBeUsed(p)
	return v.GetCharacterTargetCharacter(p.character) ~= nil
end

function Swap.localOwnerActivation(p)
	local characterTargetCharacter = v.GetCharacterTargetCharacter(p.character)

	if RunService:IsClient() then
		TweenService:Create(
			workspace.CurrentCamera,
			TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In, 0, true),
			{
				FieldOfView = 75.60000000000001
			}
		):Play()
	end

	return {
		target = characterTargetCharacter,
		user = p.character,
		targetPivot = characterTargetCharacter:GetPivot(),
		userPivot = p.character:GetPivot()
	}
end

function Swap.serverActivationAsync(_, _, data)
	task.delay(0.5, function()
		if data.user:GetAttribute("IsBot") then
			data.user:PivotTo(data.targetPivot)
		end

		if data.target:GetAttribute("IsBot") then
			data.target:PivotTo(data.userPivot)
		end
	end)
end

function Swap.anyClientActivationAsync(p, _, data)
	if data.user == localPlayer.Character then
		task.delay(0.5, function()
			data.user:PivotTo(data.user:GetPivot().Rotation + data.targetPivot.Position)
		end)
	end

	if data.target == localPlayer.Character then
		task.delay(0.5, function()
			data.target:PivotTo(data.target:GetPivot().Rotation + data.userPivot.Position)
		end)
	end

	for _, parent in { data.user, data.target } do
		local humanoid = parent:FindFirstChildWhichIsA("Humanoid")

		if not humanoid then
			continue
		end

		local rootPart = humanoid.RootPart

		if not rootPart then
			continue
		end

		local clone

		if p.upgradeLevel <= 2 then
			clone = ReplicatedStorage2.Misc.swappart:Clone()
		else
			clone = ReplicatedStorage2.Misc.maxSwap:Clone()
		end

		clone.Parent = parent
		Debris:AddItem(clone, 2)
		local part = rootPart
		task.spawn(function()
			local v9 = {
				cframe = clone.CFrame,
				diameter = 15,
				color = 0,
				orientation = "Vertical"
			}
			local color

			if p.upgradeLevel >= 2 then
				color = Color3.fromRGB(0, 255, 119)
			else
				color = Color3.fromRGB(74, 143, 255)
			end

			v9.color = color
			v4(v9)
			clone.CFrame = part.CFrame
			clone.WeldConstraint.Part1 = part
			clone.charg:Play()
			clone.Attachment.Osu:Emit(1)
			clone.Attachment.zapper:Emit(3)
			task.wait(0.5)
			local v12 = {
				cframe = clone.CFrame,
				diameter = 25,
				color = 0,
				orientation = "Vertical"
			}
			local color2

			if p.upgradeLevel >= 2 then
				color2 = Color3.fromRGB(0, 255, 119)
			else
				color2 = Color3.fromRGB(74, 143, 255)
			end

			v12.color = color2
			v4(v12)
			clone.blas:Play()
			clone.Attachment.Specs2:Emit(10)
			clone.Attachment.chb:Emit(3)
			clone.Attachment.colorme:Emit(5)
		end)
	end

	local v6, v7 = unpack({})

	if v6 and v7 then
		local v8 = v2.new(v6.Attachment, v7.Attachment, 15)
		v8.AnimationSpeed = 6
		v8.CurveSize0 = 3
		v8.CurveSize1 = 3
		local color

		if p.upgradeLevel >= 2 then
			color = Color3.fromRGB(0, 255, 119)
		else
			color = Color3.fromRGB(74, 143, 255)
		end

		v8.Color = color
		v8.Thickness = 0.3
		v8.PulseSpeed = 10
		v8.PulseLength = 5
		v8.FadeLength = 1
		v8.MaxRadius = 5
		v8.ContractFrom = 0.2
		v8.MinThicknessMultiplier = 0.75
		v8.MaxThicknessMultiplier = 1.5
		local new = v3.new(v8)
		new.MaxSparkCount = 3
		task.delay(0.63, function()
			v8:Destroy()
		end)
	end
end

return Swap