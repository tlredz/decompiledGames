local TweenService = game:GetService("TweenService")
local PolyLib = require(game.ReplicatedStorage.Assets.Modules.PolyLib)
return function()
	PolyLib:ParticleHandler(script.Parent)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function animateBeam(p)
		local _1 = p["1"]
		local _2 = p["2"]
		_1.Width0 = 25
		_1.Width1 = 12
		_2.Width0 = 10
		_2.Width1 = 4
		_1.Enabled = true
		_2.Enabled = true
		task.spawn(function()
			task.wait(0.25)
			TweenService:Create(_1, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {
				Width0 = 0,
				Width1 = 0
			}):Play()
			TweenService:Create(_2, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {
				Width0 = 0,
				Width1 = 0
			}):Play()
		end)
	end

	animateBeam(script.Parent.Part1["1"]) -- equivalent call inferred; original call site unknown
	animateBeam(script.Parent.Part1["2"]) -- equivalent call inferred; original call site unknown
	animateBeam(script.Parent.Part2["1"]) -- equivalent call inferred; original call site unknown
	animateBeam(script.Parent.Part2["2"]) -- equivalent call inferred; original call site unknown
end