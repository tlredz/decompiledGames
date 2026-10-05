local HalloweenPlantClient = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
local modulesByName = {}

function LoadModules()
	local ingredientModules = script:WaitForChild("IngredientModules")

	for _, moduleScript in pairs(ingredientModules:GetChildren()) do
		local module = require(moduleScript)
		modulesByName[moduleScript.Name] = module

		if module.Init then
			module.Init()
		end
	end
end

function HalloweenPlantAdded(instance)
	if not instance:IsDescendantOf(workspace) then
		return
	end

	if modulesByName[instance.Name] then
		modulesByName[instance.Name].Added(instance)
	end
end

function HalloweenPlantClient.Init()
	task.spawn(function()
		LoadModules()
		Client.Utility.ForAllTagged("HalloweenPlant", HalloweenPlantAdded)
	end)
end

return HalloweenPlantClient