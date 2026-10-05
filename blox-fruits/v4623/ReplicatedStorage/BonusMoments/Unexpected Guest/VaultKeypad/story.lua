local Global = require(game.ReplicatedStorage.Global)
Global.__REACT_MICROPROFILER_LEVEL = 10
Global.IsUnitTest = true
local React = require(game.ReplicatedStorage.Packages.React)
local ReactRoblox = require(game.ReplicatedStorage.Packages.ReactRoblox)
local UILabs = require(game.ReplicatedStorage.DevPackages.UILabs)
local VaultKeypad = require(script.Parent.VaultKeypad)
local createElement = React.createElement
return UILabs.CreateReactStory({
	react = React,
	reactRoblox = ReactRoblox,
	controls = {
		Code = "1234"
	}
}, function(p)
	return createElement(VaultKeypad.Keypad, {
		Code = tostring(p.controls.Code),
		OnFinish = function(flag: boolean)
			print((`[VaultKeypad story] OnFinish(accepted = {flag}) - true means the entered code matched the Code control`))
		end
	})
end)