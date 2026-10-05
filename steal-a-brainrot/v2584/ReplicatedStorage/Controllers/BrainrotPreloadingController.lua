local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContentProvider = game:GetService("ContentProvider")
local Animals = require(ReplicatedStorage.Datas.Animals)
local BrainrotAssets = require(ReplicatedStorage.Shared.BrainrotAssets)
return {
	Start = function(_)
		for childName, animal in Animals do
			local v = animal.IsEnabled and not animal.IsEnabled() and true or false

			if not (animal.ShouldPreload and animal.ShouldPreload() or v) then
				continue
			end

			local v2 = {}
			local v3 = ReplicatedStorage.Models.Animals:FindFirstChild(childName) and BrainrotAssets.getModel(childName)

			if v3 then
				table.insert(v2, v3)
			end

			local child = ReplicatedStorage.Animations.Animals:FindFirstChild(childName)

			if child then
				table.insert(v2, child)
			end

			local child2 = animal.SpawnVFX and ReplicatedStorage.Controllers.SpawnEffectsController:FindFirstChild(animal.SpawnVFX)

			if child2 then
				table.insert(v2, child2)
			end

			if #v2 > 0 then
				task.spawn(pcall, ContentProvider.PreloadAsync, ContentProvider, v2)
			end
		end
	end
}