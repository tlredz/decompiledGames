local Global = require(game.ReplicatedStorage.Global)
Global.__REACT_MICROPROFILER_LEVEL = 10
Global.IsUnitTest = true
local React = require(game.ReplicatedStorage.Packages.React)
local ReactRoblox = require(game.ReplicatedStorage.Packages.ReactRoblox)
local parentModule = require(script.Parent)
require(script.Parent.Types)
local createElement = React.createElement
local server = {
	{
		UserId = 156,
		Username = "builderman",
		Context = "In your server",
		Online = true,
		IsFriend = false
	},
	{
		UserId = 1,
		Username = "Roblox",
		Context = "In your server",
		Online = false,
		IsFriend = false
	}
}
local global = {
	{
		UserId = 1361839327,
		Username = "BloxFruits",
		Context = "Playing Blox Fruits.",
		Online = true,
		IsFriend = true
	},
	{
		UserId = 64950,
		Username = "Balling",
		Context = "Is your friend.",
		Online = false,
		IsFriend = true
	}
}
local recent = {
	{
		UserId = 42223924,
		Username = "CJ_Oyer",
		Context = "Forced to support console.",
		Online = false,
		IsFriend = true
	},
	{
		UserId = 52187831,
		Username = "xonae",
		Context = "Hallucinated.",
		Online = false,
		IsFriend = false
	},
	{
		UserId = 8166616593,
		Username = "mrheffner_gg",
		Context = "Made a spreadsheet.",
		Online = true,
		IsFriend = false
	},
	{
		UserId = 9829205164,
		Username = "undercover_admin23",
		Context = "Who is this guy, anyway?",
		Online = true,
		IsFriend = true
	}
}

local function component(_)
	local defaultCategory = #recent >= 10 and "Recent" or "Server"
	local state, setState = React.useState(true)
	return parentModule({
		Open = state,
		SetOpen = setState,
		DefaultCategory = defaultCategory,
		Server = server,
		Global = global,
		Recent = recent
	})
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