local Global = require(game.ReplicatedStorage.Global)
Global.__REACT_MICROPROFILER_LEVEL = 10
Global.IsUnitTest = true
local React = require(game.ReplicatedStorage.Packages.React)
local ReactRoblox = require(game.ReplicatedStorage.Packages.ReactRoblox)
local UILabs = require(game.ReplicatedStorage.DevPackages.UILabs)
local IdMap = require(game.ReplicatedStorage.IdMap)
local ItemConfig = require(game.ReplicatedStorage.ItemConfig)
local parentModule = require(script.Parent)
local v = {}
local moneyPrices = {}

for k, _ in IdMap.Moveset do
	local unwrapped = ItemConfig.match(k, "Fruit"):unwrap()

	if unwrapped.Index.StorageKey ~= k or ItemConfig.match("Permanent " .. k, "Redeemable"):isErr() then
		continue
	end

	table.insert(v, k)
	moneyPrices[k] = unwrapped.Quality.MoneyPrice or 1e999
end

table.sort(v, function(a: string, b: string)
	return (moneyPrices[a] or 1e999) < (moneyPrices[b] or 1e999)
end)
local createElement = React.createElement
return UILabs.CreateReactStory({
	react = React,
	reactRoblox = ReactRoblox,
	controls = {
		FruitStorageKey = UILabs.Choose(v, 1),
		IsSelected = false,
		IsFocused = false,
		IsEquipped = false,
		HasEgg = false
	}
}, function(p)
	return createElement(parentModule, {
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		SizeConstraint = Enum.SizeConstraint.RelativeYY,
		Size = UDim2.fromOffset(128, 128),
		IsFocused = p.controls.IsFocused,
		IsSelected = p.controls.IsSelected,
		IsEquipped = p.controls.IsEquipped,
		OnEggSelect = p.controls.HasEgg and function() end or nil,
		FruitStorageKey = p.controls.FruitStorageKey
	})
end)