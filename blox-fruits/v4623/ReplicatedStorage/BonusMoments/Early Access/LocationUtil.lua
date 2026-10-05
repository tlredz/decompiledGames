local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(script.Parent.Config)
local LocationUtil = {
	getWorldOrigin = function()
		return workspace:FindFirstChild("_WorldOrigin")
	end
}

function LocationUtil.getCutsceneAssets()
	local worldOrigin = LocationUtil.getWorldOrigin()
	local model

	if worldOrigin then
		model = worldOrigin:FindFirstChild(Config.CUTSCENE_ASSET_NAME)
	end

	if model and model:IsA("Model") then
		return model
	end

	return nil
end

function LocationUtil.getNPC(childName: string)
	local nPCs = workspace:FindFirstChild("NPCs")
	local child

	if nPCs then
		child = nPCs:FindFirstChild(childName)
	end

	if child then
		return child
	end

	local nPCs2 = ReplicatedStorage:FindFirstChild("NPCs")

	if nPCs2 then
		return (nPCs2:FindFirstChild(childName))
	end

	return nil
end

function LocationUtil.getTown()
	local map = workspace:FindFirstChild("Map")

	if map then
		return (map:FindFirstChild(Config.MAP_MODEL_NAME))
	end

	return nil
end

function LocationUtil.getLocations()
	local town = LocationUtil.getTown()

	if not town then
		return nil
	end

	for _, descendant in town:GetDescendants() do
		if descendant.Name ~= Config.LOCATIONS_FOLDER_NAME then
			continue
		end

		local child = descendant:FindFirstChild(Config.MOMENT_FOLDER_NAME)

		if child then
			return child
		end
	end

	return nil
end

function LocationUtil.getMarker(childName: string)
	local v = Config.NPC_INSTANCE_MARKERS[childName]

	if v then
		return LocationUtil.getNPC(v)
	end

	if Config.CUTSCENE_INSTANCE_MARKERS[childName] then
		local cutsceneAssets = LocationUtil.getCutsceneAssets()

		if cutsceneAssets then
			return (cutsceneAssets:FindFirstChild(childName, true))
		end

		return nil
	elseif Config.TOWN_INSTANCE_MARKERS[childName] then
		local town = LocationUtil.getTown()

		if town then
			return (town:FindFirstChild(childName, true))
		end

		return nil
	else
		local locations = LocationUtil.getLocations()

		if locations then
			return (locations:FindFirstChild(childName, true))
		end

		return nil
	end
end

function LocationUtil.getInstanceCFrame(instance)
	if instance:IsA("Attachment") then
		return instance.WorldCFrame
	end

	if instance:IsA("BasePart") then
		return instance.CFrame
	end

	if instance:IsA("Model") then
		return instance:GetPivot()
	end

	return nil
end

function LocationUtil.resolve(p: string, flag: boolean?)
	local marker = LocationUtil.getMarker(p)
	local selected

	if marker then
		selected = LocationUtil.getInstanceCFrame(marker)
	end

	if selected then
		return marker, selected
	end

	if flag and RunService:IsStudio() then
		return nil, Config.FALLBACK_CFRAMES[p]
	end

	return nil, nil
end

return LocationUtil