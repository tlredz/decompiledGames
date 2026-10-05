local descendants = script.Parent.Attachment:GetDescendants()
local TweenService = game:GetService("TweenService")
local tweenInfo = TweenInfo.new(1.5, Enum.EasingStyle.Cubic, Enum.EasingDirection.In, 0, true, 0)
return {
	StartEffect = function()
		for _, instance in descendants do
			if instance:IsA("ParticleEmitter") then
				if instance:GetAttribute("EmitDelay") then
					local v = instance
					task.delay(instance:GetAttribute("EmitDelay"), function()
						v:Emit(v:GetAttribute("EmitCount"))
					end)
				else
					instance:Emit(instance:GetAttribute("EmitCount"))
				end

				if instance:GetAttribute("EmitDuration") then
					local v = instance
					task.spawn(function()
						v.Enabled = true
						task.wait(v:GetAttribute("EmitDuration"))
						v.Enabled = false
					end)
				end
			elseif instance:IsA("PointLight") then
				instance.Enabled = true
				local tween = TweenService:Create(instance, tweenInfo, {
					Color = Color3.fromRGB(101, 255, 163),
					Brightness = 6,
					Range = 4
				})
				tween:Play()
				local v = instance
				tween.Completed:Connect(function()
					v.Enabled = false
				end)
			end
		end
	end
}