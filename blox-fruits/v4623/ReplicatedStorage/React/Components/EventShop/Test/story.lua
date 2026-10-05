local Global = require(game.ReplicatedStorage.Global)
Global.__REACT_MICROPROFILER_LEVEL = 10
Global.IsUnitTest = true
local React = require(game.ReplicatedStorage.Packages.React)
local ReactRoblox = require(game.ReplicatedStorage.Packages.ReactRoblox)
local MaterialIconsHD = require(game.ReplicatedStorage.Packages.MaterialIconsHD)
local IdMap = require(game.ReplicatedStorage.IdMap)
local ItemConfig = require(game.ReplicatedStorage.ItemConfig)
local FormatUtil = require(game.ReplicatedStorage.React.FormatUtil)
local parentModule = require(script.Parent)
local createElement = React.createElement

function getItem(p: number)
	local unwrapped = ItemConfig.match(p):unwrap()
	return {
		Type = "Fruit",
		Key = unwrapped.Index.StorageKey,
		Title = unwrapped.Display.Name or unwrapped.Index.StorageKey,
		Icon = unwrapped.Display.Sprite or MaterialIconsHD.broken_image,
		HypeText = "SWITCH FRUIT",
		Price = math.random(10, 125) * 10
	}
end

local function component(_)
	return (createElement(parentModule, {
		Size = UDim2.fromScale(2, 0.7),
		SizeConstraint = Enum.SizeConstraint.RelativeYY,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		EventType = "Easter2026",
		CurrencyAmount = 150,
		OnClick = function(p: string)
			print("Clicked item with key", p)
		end,
		OnExit = function()
			print("Exit button clicked")
		end,
		Items = {
			[1] = {
				Type = "Special",
				Key = "Fragment",
				Title = `${FormatUtil.commaInteger(50000)}`,
				Icon = MaterialIconsHD.broken_image,
				Price = math.random(10, 125) * 10
			},
			[2] = {
				Type = "Special",
				Key = "Fragment",
				Title = `{FormatUtil.FRAGMENT_SYMBOL} {FormatUtil.commaInteger(150)}`,
				Icon = MaterialIconsHD.broken_image,
				Price = math.random(10, 125) * 10
			},
			[3] = getItem(IdMap.Moveset["Yeti-Yeti"]),
			[5] = getItem(IdMap.Moveset["Acidum Rifle"]),
			[6] = getItem(IdMap.Moveset["Blizzard-Blizzard"])
		}
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