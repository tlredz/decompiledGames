local Global = require(game.ReplicatedStorage.Global)
Global.__REACT_MICROPROFILER_LEVEL = 10
Global.IsUnitTest = true
local React = require(game.ReplicatedStorage.Packages.React)
local ReactRoblox = require(game.ReplicatedStorage.Packages.ReactRoblox)
local Map = require(game.ReplicatedStorage.Definitions.Map)
local FakeIsland = require(script.Parent.FakeIsland)
local Star = require(script.Parent.Star)
local usePeriod = require(game.ReplicatedStorage.React.Hooks.Animation.usePeriod)
local createElement = React.createElement

local function component(_)
	local state, _ = React.useState(workspace.CurrentCamera.CFrame * CFrame.new(0, 0, 30))
	local v = usePeriod(true, 6) * 6.283185307179586
	local v2 = usePeriod(true, 25) * 6.283185307179586
	local children = {}

	for k, island in Map.getCurrentMap().Islands do
		local key = island.Index.Key
		local v3 = (v2 + math.rad(360 * (k / #Map.getCurrentMap().Islands))) % 6.283185307179586
		local cFrame = state * CFrame.Angles(0, v3, 0) + Vector3.new(math.cos(v3), math.sin(v3), 0) * 90
		children[`Island{k}`] = createElement(FakeIsland, {
			Island = key,
			CFrame = cFrame,
			Scale = 0.015
		})

		for i = 1, 7 do
			local v5 = (v + math.rad(i / 5 * 360)) % 6.283185307179586
			children[`Star{k}-{i}`] = createElement(Star, {
				CFrame = cFrame + Vector3.new(0, math.sin(v5), (math.cos(v5))) * 20,
				Scale = 3
			})
		end
	end

	return (createElement(React.Fragment, {}, children))
end

return function()
	local folder = Instance.new("Folder")
	folder.Name = "MapVictorySequence"
	folder.Parent = workspace
	local root = ReactRoblox.createRoot(folder)
	task.spawn(function()
		root:render((ReactRoblox.createPortal(createElement(component, {}), folder)))
	end)
	return function()
		root:unmount()
		folder:Destroy()
	end
end