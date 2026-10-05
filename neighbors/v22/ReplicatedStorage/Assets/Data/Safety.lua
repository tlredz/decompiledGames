local RunService = game:GetService("RunService")
local _ = game.GameId == 4924789901
local _ = game.GameId == 4253037040
local features = {
	DisableBeds = false,
	DisableBathroom = false,
	DisableBedrooms = false,
	OnlySpawnInPublicArea = true
}
local Safety = {
	IsFurnitureObject = function(_, parent)
		while parent.Name ~= "Furniture" do
			parent = parent.Parent

			if not parent or parent == workspace then
				return false
			end
		end

		return true
	end
}

if RunService:IsServer() then
	print("----------------------")
	print("Safety Overview")

	for k, v2 in next, features, nil do
		print((`>> {k} = {v2}`))
	end

	print("----------------------")
end

Safety.Features = features
return Safety