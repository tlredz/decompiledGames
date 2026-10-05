local TweenService = game:GetService("TweenService")
local React = require(game.ReplicatedStorage.Packages.React)
local useKeyFrames = require(game.ReplicatedStorage.React.Hooks.Animation.useKeyFrames)
require(game.ReplicatedStorage.React.Components.Map.Types)
return function(p, flag: boolean?)
	local v = React.useMemo(function()
		local v2 = {
			{
				Duration = 0.5,
				Id = "Start"
			}
		}

		if p == "OneStar" or p == "TwoStar" or p == "ThreeStar" or p == "Completed" then
			table.insert(v2, {
				Duration = 1,
				Id = "StarsAscend"
			})
			table.insert(v2, {
				Duration = 1,
				Id = "Stars"
			})
			table.insert(v2, {
				Duration = 1,
				Id = "StarsDescend"
			})
		end

		if p == "Completed" then
			table.insert(v2, {
				Duration = 2,
				Id = "AwakenedAscend"
			})
			table.insert(v2, {
				Duration = 4.25,
				Id = "Awakened"
			})
		end

		table.insert(v2, {
			Duration = 1.5,
			Id = "Finish"
		})
		return v2
	end, { p })
	local v3 = p ~= "Default"

	if type(flag) ~= "boolean" then
		flag = false
	end

	local v4, v5 = useKeyFrames(v, v3, flag)
	local v7

	if p == "Default" then
		v7 = 0
	elseif v4 == "StarsAscend" then
		v7 = v5
	else
		v7 = v4 == "Stars" and 1 or v4 ~= "StarsDescend" and 0 or 1 - v5
	end

	local value = TweenService:GetValue(v7, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
	local v9

	if p == "Completed" then
		if v4 == "AwakenedAscend" then
			v9 = v5
		else
			v9 = v4 == "Awakened" and 1 or v4 ~= "Finish" and 0 or 1 - v5
		end
	else
		v9 = 0
	end

	return v4, v5, value, (TweenService:GetValue(v9, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut))
end