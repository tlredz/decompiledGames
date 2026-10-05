local TweenService = game:GetService("TweenService")
local BaseInteractable = require(script.Parent.BaseInteractable)
local tweenInfo = TweenInfo.new(0.75, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
return function(p)
	local v = BaseInteractable.new()
	local v3 = {
		Cold = {
			Motor = p.Sink.ColdBase,
			Offset = CFrame.Angles(
				p:GetAttribute("BathroomSink") == true and 0 or 1.1344640137963142,
				p:GetAttribute("BathroomSink") == true and 1.1344640137963142 or 0,
				0
			)
		},
		Hot = {
			Motor = p.Sink.HotBase,
			Offset = CFrame.Angles(
				p:GetAttribute("BathroomSink") == true and 0 or -1.1344640137963142,
				p:GetAttribute("BathroomSink") == true and -1.1344640137963142 or 0,
				0
			)
		}
	}
	local C1s = {}

	for k, v4 in v3 do
		C1s[k] = v4.Motor.C1
	end

	function v.Run(p2)
		if p2.State then
			for _, v4 in v3 do
				TweenService:Create(v4.Motor, tweenInfo, {
					C1 = v4.Offset
				}):Play()
			end

			p.Sink.WaterRunningSound:Play()
			p.Sink.Faucet.ParticleEmitter.Enabled = true
			task.wait(0.2)
			p.Sink.Splash.ParticleEmitter.Enabled = true
		else
			for k, v4 in v3 do
				TweenService:Create(v4.Motor, tweenInfo, {
					C1 = C1s[k]
				}):Play()
			end

			p.Sink.WaterRunningSound:Stop()
			p.Sink.Faucet.ParticleEmitter.Enabled = false
			task.wait(0.2)
			p.Sink.Splash.ParticleEmitter.Enabled = false
		end
	end

	for _, parent in { p.Cold, p.Hot } do
		local clickDetector = Instance.new("ClickDetector")
		clickDetector.MaxActivationDistance = 12
		clickDetector.Parent = parent
		clickDetector.MouseClick:Connect(function()
			v:ToggleState()
		end)
	end

	return v
end