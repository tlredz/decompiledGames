local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.client.legacyControllers.StormyLightningController)
local _ = {
	BoltSegments = 6,
	BoltThickness = 0.1,
	BoltOffsetMax = 2,
	BoltColor = Color3.fromRGB(255, 224, 69),
	ArcLifetime = 0.06
}

local function getActiveHeadPositions()
	local positions = {}

	for _, v in CollectionService:GetTagged("ZeusPole") do
		if not v:GetAttribute("Active") then
			continue
		end

		local head = v:FindFirstChild("Head")

		if head and head:IsA("BasePart") then
			table.insert(positions, head.Position)
		end
	end

	return positions
end

local function setPoleParticles(instance, active)
	local head = instance:FindFirstChild("Head")

	if not head then
		return
	end

	for _, emitter in head:GetDescendants() do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = active
		end
	end
end

return {
	Start = function(_)
		for _, v in CollectionService:GetTagged("ZeusPole") do
			setPoleParticles(v, v:GetAttribute("Active") or false)
			local v2 = v
			v:GetAttributeChangedSignal("Active"):Connect(function()
				setPoleParticles(v2, v2:GetAttribute("Active") or false)
			end)
		end
	end
}