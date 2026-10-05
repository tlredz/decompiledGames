local RunService = game:GetService("RunService")
local Effect = require(game.ReplicatedStorage.Effect)
local opeOpeSlash = Effect.new("Ope-Ope.Slash")
local Sound = require(game.ReplicatedStorage.Util.Sound)
return function(list)
	local v, v2, v3, v4, v5 = unpack(list)
	local v6 = Sound:Play("Ope.Levitate.Travel", v:Lerp(v2, 0.5), 3 * v3)
	spawn(function()
		wait(v4 * 0.75)
		Sound:FadeOut(v6, v4 * 0.25)
	end)
	local magnitude = (v2 - v).Magnitude
	local v7 = math.ceil(magnitude / (v3 / 2))

	for i = 1, v7 do
		local v8 = i / v7
		opeOpeSlash:replicate({
			CFrame.new(v, v2) * CFrame.new(0, 0, -magnitude * v8) * CFrame.Angles(3.141592653589793, 0, 0),
			v3 * (i / v7),
			v4,
			v5
		})
		RunService.RenderStepped:Wait()
	end
end