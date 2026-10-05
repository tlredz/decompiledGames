local Global = require(game.ReplicatedStorage.Global)
Global.__REACT_MICROPROFILER_LEVEL = 10
Global.IsUnitTest = true
local React = require(game.ReplicatedStorage.Packages.React)
local ReactRoblox = require(game.ReplicatedStorage.Packages.ReactRoblox)
local UILabs = require(game.ReplicatedStorage.DevPackages.UILabs)
local NoteBubbles = require(script.Parent.NoteBubbles)
local createElement = React.createElement
local notes = {
	"Melee",
	"Sword",
	"Fruit",
	"Gun",
	"Gun",
	"Fruit",
	"Sword",
	"Melee"
}
return UILabs.CreateReactStory({
	react = React,
	reactRoblox = ReactRoblox,
	controls = {
		Beat = 2,
		Landed = 0,
		Missed = false
	}
}, function(p)
	local beat = tonumber(p.controls.Beat) or 2
	local v2 = math.clamp(tonumber(p.controls.Landed) or 0, 0, #notes)
	local state, setState = React.useState(nil)
	React.useEffect(function()
		setState({
			Notes = notes,
			Start = workspace:GetServerTimeNow() + beat * 2,
			Beat = beat,
			Perfect = 0.3,
			Good = 0.7,
			Token = 1
		})
	end, { beat })
	local marks = {}

	for i = 1, v2 do
		marks[i] = {
			Verdict = i % 2 == 0 and "Good" or "Perfect",
			At = workspace:GetServerTimeNow()
		}
	end

	if p.controls.Missed == true then
		marks[v2 + 1] = {
			Verdict = "Miss",
			At = workspace:GetServerTimeNow()
		}
	end

	return createElement(NoteBubbles.Bubbles, {
		Round = state,
		Marks = marks,
		Phase = p.controls.Missed == true and "Fail" or "Listen",
		EarlyAt = nil
	})
end)