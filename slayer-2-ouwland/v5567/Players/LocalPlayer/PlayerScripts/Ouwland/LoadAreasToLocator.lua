local areaLocator = game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Subsets"):WaitForChild("Areas"):WaitForChild("AreaLocator")
local module = require(areaLocator)
local Locator = require(areaLocator:WaitForChild("Locator"))
local Regions = require(game.ReplicatedStorage:WaitForChild("Regions"))

for _, region in pairs(Regions.Regions) do
	if region.Area then
		module.CurrentAreas[region.Name] = region.Area
	end
end

for k, biome in Regions.Biomes do
	Locator.Biomes[k] = biome
end