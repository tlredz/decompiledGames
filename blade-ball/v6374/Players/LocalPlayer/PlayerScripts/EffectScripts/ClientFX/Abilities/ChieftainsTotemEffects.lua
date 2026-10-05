local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Trove = require(ReplicatedStorage.Packages.Trove)
local Utils = require(ReplicatedStorage.Common.Utils)
local FastUtils = require(ReplicatedStorage.Shared.FastUtils)
local currentCamera = workspace.CurrentCamera
local localPlayer = Players.LocalPlayer
local chieftainsTotem = ReplicatedStorage.Assets.Abilities["Chieftain's Totem"]
local v = 0

local function updateLocalTransparency(p, items, items2)
	local now = os.clock()

	if now - v < 0.1 then
		return
	end

	v = now
	local localTransparencyModifier = math.clamp(
		not p and 12 or (p.Position - currentCamera.CFrame.Position).Magnitude,
		3,
		12
	) * -0.1111111111111111 + 1.3333333333333333

	for _, item in items do
		item.LocalTransparencyModifier = localTransparencyModifier
	end

	for _, item in items2 do
		item.Enabled = localTransparencyModifier <= 0.05 and item:GetAttribute("Enabled")
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getSize(model)
	if model:IsA("Model") then
		return (model:GetExtentsSize())
	end

	return model.Size
end

local function getBaseParts(part)
	local parts = {}

	if part:IsA("BasePart") then
		table.insert(parts, part)
	end

	for _, part2 in part:GetDescendants() do
		if part2:IsA("BasePart") then
			table.insert(parts, part2)
		end
	end

	return parts
end

return function(instance, state)
	local playerFromCharacter = Players:GetPlayerFromCharacter(instance)

	if not playerFromCharacter then
		return
	end

	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return
	end

	local maid = Trove.new()
	local upgraded

	if state.upgrade == 2 then
		upgraded = chieftainsTotem.Upgraded
	else
		upgraded = chieftainsTotem.Normal
	end

	local _ = state.range * 0.5
	local clone = maid:Clone(upgraded.Totem)
	local baseParts = getBaseParts(clone)

	for _, basePart in baseParts do
		basePart.Transparency = 1
	end

	clone.Parent = workspace.Runtime
	local clone2 = maid:Clone(upgraded.TotemRange)
	Utils.Physics.ResizePart(clone2, state.range / clone2.Part.Size.X)
	clone2.Part.Transparency = 1
	clone2.Parent = workspace.Runtime
	local numberValue = Instance.new("NumberValue")
	local size = getSize(clone) -- equivalent call inferred; original call site unknown
	numberValue.Value = -(size.Y * 0.5 + 3)
	local fastTween = FastUtils.fastTween
	local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	local size2 = getSize(clone) -- equivalent call inferred; original call site unknown
	fastTween(numberValue, tweenInfo, {
		Value = size2.Y * 0.5
	})
	maid:Add(
		FastUtils.fastTween(
			clone2.Part,
			TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 0, false, 0.3),
			{
				Transparency = 0
			}
		),
		"Cancel"
	)
	clone:PivotTo(humanoidRootPart:GetPivot() * CFrame.new(0, numberValue.Value, 0))
	state.totem = clone
	local v3 = false

	for _, basePart in baseParts do
		maid:Add(FastUtils.fastTween(basePart, TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
			Transparency = 0
		}), "Cancel")
	end

	local emitters = {}

	for _, emitter in clone:GetDescendants() do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		emitter:SetAttribute("Enabled", true)
		table.insert(emitters, emitter)
	end

	maid:Add(RunService.PostSimulation:Connect(function(dt: number)
		local pivot = humanoidRootPart:GetPivot()
		clone2:PivotTo(CFrame.new(pivot.X, state.floorY + 0.2, pivot.Z))
		clone:PivotTo(CFrame.lookAt(
			clone:GetPivot().Position:Lerp(
				(pivot * CFrame.new(0, 0, 6)).Position + createVector(0, 1, 0) * (numberValue.Value + math.sin(os.clock() * 3)),
				dt * 0.1 * 60
			),
			pivot.Position + createVector(0, 1, 0) * numberValue.Value * 1
		))

		if playerFromCharacter == localPlayer then
			local v5

			if clone:IsA("Model") then
				v5 = clone.PrimaryPart
			else
				v5 = clone
			end

			updateLocalTransparency(v5, baseParts, emitters)
		end
	end))

	for _, descendant in clone2:GetDescendants() do
		if descendant:IsA("Beam") then
			descendant:SetAttribute("TargetWidth0", descendant.Width0)
			descendant:SetAttribute("TargetWidth1", descendant.Width1)
			descendant.Width0 = 0
			descendant.Width1 = 0
			descendant:AddTag("BeamTweenWidth")
		elseif descendant:IsA("ParticleEmitter") then
			descendant.Enabled = true
		elseif descendant:IsA("Decal") then
			maid:Add(
				FastUtils.fastTween(descendant, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
					Transparency = 0
				}),
				"Cancel"
			)
		end
	end

	local maid2 = Trove.new()
	maid2:Add(function()
		v3 = true

		for _, basePart in baseParts do
			maid:Add(
				FastUtils.fastTween(basePart, TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
					Transparency = 1
				}),
				"Cancel"
			)
		end

		maid:Add(
			FastUtils.fastTween(clone2.Part, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
				Transparency = 1
			}),
			"Cancel"
		)

		for _, emitter in clone:GetDescendants() do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			emitter.Enabled = false
			emitter:SetAttribute("Enabled", false)
		end

		for _, descendant in clone2:GetDescendants() do
			if descendant:IsA("Beam") then
				descendant:SetAttribute("TargetWidth0", 0)
				descendant:SetAttribute("TargetWidth1", 0)
				descendant:RemoveTag("BeamTweenWidth")
				descendant:AddTag("BeamTweenWidth")
			elseif descendant:IsA("ParticleEmitter") then
				descendant.Enabled = false
			elseif descendant:IsA("Decal") then
				maid:Add(
					FastUtils.fastTween(
						descendant,
						TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
						{
							Transparency = 1
						}
					),
					"Cancel"
				)
			end
		end

		task.delay(2.5, function()
			maid:Destroy()
		end)
	end)
	maid2:Add(task.delay(state.endTime - workspace:GetServerTimeNow(), function()
		maid2:Destroy()
	end))
	return maid2
end