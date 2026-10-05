local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Config = require(script.Parent.Config)

local function getPlayerHumanoid(instance)
	local model = instance:FindFirstAncestorOfClass("Model")
	local playerFromCharacter

	if model then
		playerFromCharacter = Players:GetPlayerFromCharacter(model)
	end

	local humanoid

	if playerFromCharacter then
		humanoid = model:FindFirstChildOfClass("Humanoid")
	end

	if humanoid and humanoid.Health > 0 then
		return humanoid
	end

	return nil
end

local Catch = {}

function Catch.buildOverlapParams()
	local overlapParams = OverlapParams.new()
	overlapParams.FilterType = Enum.RaycastFilterType.Include
	overlapParams.MaxParts = Config.catchMaxPartsPerQuery
	return overlapParams
end

function Catch.killOverlappingPlayers(instance, p)
	for _, childName in Config.catchPartNames do
		local part = instance:FindFirstChild(childName)

		if not (part and part:IsA("BasePart")) then
			continue
		end

		for _, v in Workspace:GetPartsInPart(part, p) do
			local model = v:FindFirstAncestorOfClass("Model")
			local playerFromCharacter

			if model then
				playerFromCharacter = Players:GetPlayerFromCharacter(model)
			end

			local humanoid

			if playerFromCharacter then
				humanoid = model:FindFirstChildOfClass("Humanoid")
			end

			if not (humanoid and humanoid.Health > 0) then
				humanoid = nil
			end

			if humanoid then
				humanoid.Health = 0
			end
		end
	end
end

return Catch