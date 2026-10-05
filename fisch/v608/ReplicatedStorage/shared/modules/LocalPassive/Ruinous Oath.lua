local RuinousOath = {}
game:GetService("ContentProvider")
game:GetService("RunService")
game:GetService("ReplicatedStorage")
local module = require("./PassiveHandler")

function RuinousOath.Morph(p, data, object)
	object:Preload(script:GetChildren())
	task.spawn(function()
		object:WaitUntilReady()

		if object:GetRandom(5):NextInteger(1, 100) <= 15 then
			object:TweenModifier("progress", "add", 0, 60, TweenInfo.new(0.5))
			local _ = data.progress.bar.BackgroundColor3
			p.current.logicTweens:CreateAndPlay(
				data.progress.bar,
				TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, true),
				{
					BackgroundColor3 = Color3.fromRGB(255, 0, 0)
				}
			)
		end

		local now = nil
		local backgroundColor3 = data.playerbar.BackgroundColor3
		tick()
		local barSize = object.barSize
		object:AddModifier("minBarSize", "add", 0.15)
		local modifier = object:CreateModifier("progressefficiency", "force_add")
		local modifier2 = object:CreateModifier("barSize", "add")
		local modifier3 = object:CreateModifier("resilience", "multiply")
		local total = 0
		data.progressspeed.Visible = true
		local onLogicStepConnection = nil
		onLogicStepConnection = object.OnLogicStep:Connect(function(p2)
			if not data.Parent then
				onLogicStepConnection:Disconnect()
				return
			end

			total += p2
			modifier3.Value = math.clamp(total / 30 + 1, 1, 1.5)

			if object.perfect then
				modifier.Value += p2 / 20

				if object.barSize > 0.15 then
					modifier2.Value -= p2 / 10
				end

				data.playerbar.BackgroundColor3 = backgroundColor3:Lerp(
					Color3.fromRGB(255, 0, 0),
					(barSize - object.barSize) / (barSize - 0.15)
				)
			elseif not now then
				now = tick()
				local tweenInfo = TweenInfo.new(0.33)
				object.logicTweens:CreateAndPlay(data.playerbar, tweenInfo, {
					BackgroundColor3 = backgroundColor3
				})
				object.logicTweens:CreateAndPlay(modifier, tweenInfo, {
					Value = 0
				})
				object.logicTweens:CreateAndPlay(modifier2, tweenInfo, {
					Value = 0
				})
				object.logicTweens:CreateAndPlay(modifier3, tweenInfo, {
					Value = 1
				})
			end
		end)
	end)
end

setmetatable(RuinousOath, module)
return RuinousOath