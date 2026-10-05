local RunService = game:GetService("RunService")
local Maid = require(game.ReplicatedStorage.Util.Maid)
local FountainWater = {}
FountainWater.LoadForLocations = { "Fountain City" }
FountainWater.Maid = Maid.new()

function FountainWater.RegionEntered(p)
	local maid = p.Maid
	maid:GiveTask(task.spawn(function()
		local fountain = workspace:WaitForChild("Map"):WaitForChild("Fountain", 30)

		if not fountain then
			return
		end

		local meshesfountainisland_Cylinder047 = fountain:WaitForChild("Meshes/fountainisland_Cylinder.047", 30)

		if not meshesfountainisland_Cylinder047 then
			return
		end

		local texture = meshesfountainisland_Cylinder047:WaitForChild("Texture", 30)

		if texture and texture:IsA("Texture") then
			RunService:BindToRenderStep(
				"IslandController.FountainCity.FountainWater",
				Enum.RenderPriority.Camera.Value + 1,
				function(p2)
					texture.OffsetStudsU = (texture.OffsetStudsU + 6 * p2) % texture.StudsPerTileU
					texture.OffsetStudsV = (texture.OffsetStudsV + 3 * p2) % texture.StudsPerTileV
				end
			)
			maid:GiveTask(function()
				RunService:UnbindFromRenderStep("IslandController.FountainCity.FountainWater")
			end)
		end
	end))
end

function FountainWater.RegionLeaving(_) end

return FountainWater