local createVector = vector.create
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local assets = ReplicatedStorage.Assets
local itemDropEffect = assets.ItemDropEffect
local specialItemDropEffect = assets.SpecialItemDropEffect
local shared = ReplicatedStorage.Shared
local FastUtils = require(shared.FastUtils)
return function(position: Vector3, duration: number?, flag: boolean?)
	local clone

	if flag then
		clone = specialItemDropEffect:Clone()
	else
		clone = itemDropEffect:Clone()
	end

	clone.AuraStuff.Position = position + createVector(0, 200, 0)
	clone.Land.Position = position
	clone.Parent = workspace
	FastUtils.fastTween(clone.AuraStuff, TweenInfo.new(duration, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
		Position = position
	})
	task.wait(duration)

	for _, descendant in clone.AuraStuff:GetDescendants() do
		if not (descendant:IsA("ParticleEmitter") or descendant:IsA("Beam") or descendant:IsA("Highlight")) then
			continue
		end

		descendant.Enabled = false
	end

	for _, child in clone.Land.Attachment:GetChildren() do
		child:Emit(child:GetAttribute("EmitCount"))
	end

	Debris:AddItem(clone, 3)
end