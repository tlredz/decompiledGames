local React = require(game.ReplicatedStorage.Packages.React)
local Noise = require(game.ReplicatedStorage.Packages.Noise)
require(game.ReplicatedStorage.React.RobloxTypes)
local useTime = require(game.ReplicatedStorage.React.Hooks.Animation.useTime)
local v = Noise.new(12345)
local createElement = React.createElement
return function(p)
	local v2 = useTime(p.IsActive == nil or p.IsActive)
	return createElement("UIGradient", {
		Rotation = 0,
		Color = React.useMemo(function()
			local v4 = v2 / 1.5
			local v5 = {}
			local colorSequenceKeypoints = {}

			for i = 0, 19 do
				v5[i] = math.clamp(0.2 + 0.8 * (1 - v:Perlin(i * 6 / 19, v4)), 0, 1)
			end

			for i = 0, 19 do
				local perlin = v:Perlin(i * 5 / 19, v4, 2)
				local v7 = v5[i]
				table.insert(
					colorSequenceKeypoints,
					ColorSequenceKeypoint.new(
						i == 19 and 1 or i == 0 and 0 or i / 20 + perlin / 20,
						Color3.new(v7, v7, v7)
					)
				)
			end

			return ColorSequence.new(colorSequenceKeypoints)
		end, { v2 })
	})
end