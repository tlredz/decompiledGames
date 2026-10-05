game:GetService("RunService")
game:GetService("ContentProvider")
game:GetService("ReplicatedStorage")
local module = require("./PassiveHandler")
local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Circular, Enum.EasingDirection.Out)
local EidolonRod = {
	Morph = function(p, p2, object)
		object:Preload({ script })
		task.spawn(function()
			object:WaitUntilReady()
			local playerbar = p2.playerbar
			local v = false
			p.reelTrove:Add(object.OnLogicStep:Connect(function()
				if object.progress >= p.config.ProgressThreshold and not v then
					v = true
					script.sound:Play()
					local clone = script.CompleteGradient:Clone()
					clone.Parent = playerbar
					local uIGradient = clone.UIGradient
					uIGradient.Offset = Vector2.new(0, 1)
					object.renderTweens:Create(uIGradient, TweenInfo.new(1), {
						Offset = Vector2.new(0, -1)
					}):Play()
					object:TweenModifier(
						"progress",
						"add",
						object.progressefficiency,
						p.config.ProgressBoost,
						tweenInfo
					)
					object:TweenModifier("barSize", "force", object.barSize, p.config.BarSize, tweenInfo)
				end
			end))
		end)
	end
}
setmetatable(EidolonRod, module)
return EidolonRod