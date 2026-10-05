local Global = require(game.ReplicatedStorage.Global)
Global.__REACT_MICROPROFILER_LEVEL = 10
Global.IsUnitTest = true
local React = require(game.ReplicatedStorage.Packages.React)
local ReactRoblox = require(game.ReplicatedStorage.Packages.ReactRoblox)
local DungeonQueue = require(script.Parent.Parent.DungeonQueue)
local createElement = React.createElement

local function component(_)
	warn("a")
	local v = {
		SelectedDungeon = {
			DungeonId = "Dungeon_01",
			DungeonName = "Simulation Dungeon",
			IsLocked = false
		},
		Party = {
			GUID = "TEST",
			SelectedDungeon = {
				DungeonId = "Dungeon_01",
				DungeonName = "Simulation Dungeon",
				IsLocked = false
			},
			Players = {
				{
					PlayerInstance = game.Players.LocalPlayer,
					IsReady = true,
					Issue = "ok",
					IsLeader = true
				}
			}
		},
		IncomingInvites = {},
		NearbyInvitableAllies = {}
	}
	local v2 = {
		OnExit = function(instance)
			print(instance:GetFullName())
			instance.Parent.Parent.Parent.Parent = workspace
		end,
		Position = UDim2.new(0.5, 0, 0.5, 0),
		AnchorPoint = Vector2.new(0.5, 0.5)
	}

	for k, v3 in pairs(v) do
		v2[k] = v3
	end

	return (createElement(React.Fragment, {}, {
		DungeonQueue = createElement(DungeonQueue, v2)
	}))
end

return function(p)
	local root = ReactRoblox.createRoot(p)
	task.spawn(function()
		root:render((ReactRoblox.createPortal(createElement(component, {}), p)))
	end)
	return function()
		root:unmount()
	end
end