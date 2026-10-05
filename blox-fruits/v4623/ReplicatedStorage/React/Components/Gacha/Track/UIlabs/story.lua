local Global = require(game.ReplicatedStorage.Global)
Global.__REACT_MICROPROFILER_LEVEL = 10
Global.IsUnitTest = true
local React = require(game.ReplicatedStorage.Packages.React)
local ReactRoblox = require(game.ReplicatedStorage.Packages.ReactRoblox)
local UILabs = require(game.ReplicatedStorage.DevPackages.UILabs)
require(game.ReplicatedStorage.Economy.ItemId)
local parentModule = require(script.Parent)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local v = {
	{
		Name = "Scrap Metal",
		IdType = "Material",
		Quantity = 5,
		Goal = 1
	},
	{
		Name = "Angel Wings",
		IdType = "Material",
		Quantity = 10,
		Goal = 3
	},
	{
		Name = "Fire Feather",
		IdType = "Material",
		Quantity = 20,
		Goal = 5
	},
	{
		Name = "Leviathan Heart",
		IdType = "Material",
		Quantity = 30,
		Goal = 7
	},
	{
		Name = "Ectoplasm",
		IdType = "Material",
		Quantity = 40,
		Goal = 10
	}
}
local v2 = {
	{
		Name = "Free Spin",
		Quantity = 1,
		Goal = 5
	},
	{
		Name = "Rocket-Rocket",
		IdType = "PhysicalMoveset",
		Quantity = 1,
		Goal = 10
	},
	{
		Name = "Free Spin",
		Quantity = 1,
		Goal = 15
	},
	{
		Name = "Empyrean (Kitsune)-Empyrean (Kitsune)",
		IdType = "Redeemable",
		Quantity = 1,
		Goal = 20
	}
}
local goal = v[#v].Goal
local createElement = React.createElement

local function getRewardForGoal(goal2: number)
	for _, v3 in v do
		if v3.Goal == goal2 then
			return v3
		end
	end

	if goal2 <= goal then
		return nil
	end

	local total = 0
	local total2 = 0
	local v3 = {}

	for _, v4 in pairs(v2) do
		total += v4.Goal
		table.insert(v3, v4.Goal + total2)
		total2 = v4.Goal + total2
	end

	local v4 = goal2 - goal
	local v5 = math.floor((v4 - 1) / total) * total

	for k, v6 in v3 do
		if v4 ~= v5 + v6 then
			continue
		end

		local clone = table.clone(v2[k])
		clone.Goal = goal2
		return clone
	end

	return nil
end

local function getVisibleRewards(progress: number)
	local v3 = progress
	local result = {}
	local count = 0
	local count2 = 0

	while #result < 3 and v3 >= 1 do
		local rewardForGoal = getRewardForGoal(v3)

		if rewardForGoal then
			table.insert(result, 1, rewardForGoal)
		end

		v3 -= 1
		count += 1
	end

	local v4 = progress + 1

	while #result < 10 do
		local rewardForGoal = getRewardForGoal(v4)

		if rewardForGoal then
			table.insert(result, rewardForGoal)
		end

		v4 += 1
		count2 += 1
	end

	print((`iterations1={count}, iterations2={count2}, total={count2 + count}`))
	return result
end

return UILabs.CreateReactStory({
	react = React,
	reactRoblox = ReactRoblox,
	controls = {
		Progress = UILabs.Number(5, 0, 1000000, 1)
	}
}, function(p)
	local items = React.useMemo(function()
		return (getVisibleRewards(p.controls.Progress))
	end, { p.controls.Progress })
	return createElement("Frame", {
		Size = UDim2.fromScale(0.5, 0.2),
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE
	}, {
		Track = createElement(parentModule, {
			Size = UDim2.fromScale(1, 1),
			Progress = p.controls.Progress,
			Items = items
		})
	})
end)