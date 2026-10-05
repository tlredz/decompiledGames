local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Gamepasses = require(ReplicatedStorage.Modules.Shared.PlayerData.Gamepasses)
local WheelDecalsConfig = {
	remoteConfigDirectory = "Vehicles/WheelDecals",
	isPublic = true,
	isLoaded = false,
	cache = nil,
	middlewares = {
		setupData = function(p)
			local result = {}

			for _, decal in p.Decals do
				local gamepass = decal.Gamepass
				local gamepass2

				if not (gamepass == nil or gamepass == "") then
					gamepass2 = Gamepasses[gamepass]
				end

				table.insert(result, {
					Image = decal.Image,
					Gamepass = gamepass2
				})
			end

			return result
		end
	}
}

function WheelDecalsConfig.GetConfig()
	while not WheelDecalsConfig.isLoaded do
		task.wait()
	end

	return WheelDecalsConfig.cache
end

return WheelDecalsConfig