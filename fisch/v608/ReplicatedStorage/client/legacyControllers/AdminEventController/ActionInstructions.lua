local ReplicatedStorage = game:GetService("ReplicatedStorage")
local assets = require(ReplicatedStorage.shared.utils.assets)
require(ReplicatedStorage.shared.modules.library.fish)
local v = {
	ModelRain = 2,
	Water = 2,
	Icon = 2,
	Lighting = 1,
	StartSound = 1,
	Fish = 1,
	Multiplier = 1,
	Mutation = 1,
	Rod = 1,
	Announcement = 1,
	Execute = 1,
	FishingPassives = 1,
	StatusEffect = 1
}
local v2 = {
	ModelRain = true,
	Icon = true,
	StartSound = true
}

local function accumulatePreloadableFromModel(folder)
	local result = {}

	for _, descendant in folder:GetDescendants() do
		if descendant:IsA("Decal") then
			table.insert(result, descendant.Texture)
		elseif descendant:IsA("MeshPart") then
			local meshId = descendant.MeshId
			local textureID = descendant.TextureID

			if meshId and string.len(meshId) ~= 0 then
				table.insert(result, meshId)
			end

			if textureID and string.len(textureID) ~= 0 then
				table.insert(result, textureID)
			end
		end
	end

	task.wait(0)
	return result
end

local ActionInstructions = {}

function ActionInstructions.Handle(data)
	local v3 = 1

	for _, action in data.Actions do
		local v4 = v[action]

		if v4 then
			local v5 = {}

			while v4 > 0 do
				table.insert(v5, data.Arguments[v3])
				v3 += 1
				v4 -= 1
			end

			ActionInstructions._Handle(action, v5, data.TableUpvalue)
		else
			warn("An action could not be preloaded because its client-side argument count was missing.")
		end
	end
end

function ActionInstructions._Handle(p: string, p2, p3)
	if not v2[p] then
		return
	end

	pcall(ActionInstructions[`_{p}`], p2, p3)
end

function ActionInstructions._Fish(list, list2)
	for k, _ in list[1] do
		local async = assets.getAsync("fish", k)

		if async then
			local v3 = accumulatePreloadableFromModel(async)

			for _, v4 in v3 do
				table.insert(list2, v4)
			end
		end

		assets.releaseAsset("fish", k)
	end
end

function ActionInstructions._Icon(list, list2)
	table.insert(list2, (`rbxassetid://{list[1]}`))
end

function ActionInstructions._StartSound(list, list2)
	table.insert(list2, (`rbxassetid://{list[1]}`))
end

function ActionInstructions._ModelRain(list, list2)
	local model = ReplicatedStorage.shared.modules.SharedAdminEvent.ModelRainModels:FindFirstChild(list[1])

	if model and model:IsA("Model") then
		local v3 = accumulatePreloadableFromModel(model)

		for _, v4 in v3 do
			table.insert(list2, v4)
		end
	end
end

return ActionInstructions