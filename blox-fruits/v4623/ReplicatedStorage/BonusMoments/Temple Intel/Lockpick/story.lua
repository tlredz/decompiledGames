local Global = require(game.ReplicatedStorage.Global)
Global.__REACT_MICROPROFILER_LEVEL = 10
Global.IsUnitTest = true
local React = require(game.ReplicatedStorage.Packages.React)
local ReactRoblox = require(game.ReplicatedStorage.Packages.ReactRoblox)
local UILabs = require(game.ReplicatedStorage.DevPackages.UILabs)
local Lockpick = require(script.Parent.Lockpick)
local createElement = React.createElement
return UILabs.CreateReactStory({
	react = React,
	reactRoblox = ReactRoblox,
	controls = {
		Picks = 3,
		Pin = 0,
		Reveal = false
	}
}, function(p)
	local pin = tonumber(p.controls.Pin) or 0
	local lockpick = Lockpick.Lockpick
	local v2 = {
		Picks = tonumber(p.controls.Picks) or 3,
		Pin = 0,
		Reveal = 0,
		OnFinish = 0
	}

	if pin == 0 then
		pin = nil
	end

	v2.Pin = pin
	v2.Reveal = p.controls.Reveal == true

	function v2.OnFinish(flag: boolean)
		print((`[Lockpick story] OnFinish(picked = {flag}) — true = the padlock came open (in-game this asks the server to unlock the chest)`))
	end

	return createElement(lockpick, v2)
end)