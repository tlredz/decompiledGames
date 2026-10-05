local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")

local function PrepareHumanoidRigs(folder)
	for _, humanoid in folder:GetDescendants() do
		if not humanoid:IsA("Humanoid") then
			continue
		end

		local parent = humanoid.Parent

		if not (parent and parent:IsA("Model")) then
			continue
		end

		local humanoidRootPart = parent:FindFirstChild("HumanoidRootPart")

		if not (humanoidRootPart and humanoidRootPart:IsA("BasePart")) then
			continue
		end

		for _, part in parent:GetDescendants() do
			if part:IsA("BasePart") then
				part.Anchored = part == humanoidRootPart
			end
		end
	end
end

local ConcertFunctions = {}

function ConcertFunctions.InitStageAsset(instance)
	local parent = CollectionService:GetTagged("Scene")[1]

	if not parent then
		return
	end

	if (RunService:IsClient() or plugin ~= nil) and instance and parent then
		local clone = instance:Clone()
		clone.Name = "StageDecoration"

		for _, instance2 in (clone:FindFirstChild("Decoration") or clone):QueryDescendants("BasePart, Fire, Sparkles, Smoke, ParticleEmitter, Decal, Texture, TextLabel, Beam") do
			if instance2:IsA("TextLabel") then
				instance2.TextTransparency = 1
			elseif instance2:IsA("Beam") then
				instance2.Brightness = 0
			else
				instance2.LocalTransparencyModifier = 1
			end
		end

		PrepareHumanoidRigs(clone)
		clone.Parent = parent
	end
end

function ConcertFunctions.CleanupStageAsset()
	local v = CollectionService:GetTagged("Scene")[1]

	if not v then
		return
	end

	if RunService:IsClient() or plugin ~= nil then
		local stageDecoration = v:FindFirstChild("StageDecoration")

		if stageDecoration ~= nil then
			stageDecoration:Destroy()
		end
	end
end

return ConcertFunctions