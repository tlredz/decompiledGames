return {
	Steps = {
		{
			Time = 1.37,
			Run = function(object)
				object:Sound("Charge")
			end
		},
		{
			Marker = "Cast",
			Run = function(instance)
				instance:Sound("Slash")
				local clone = instance:Clone("Effect")

				if clone then
					clone:PivotTo(instance.GoalCFrame)
					instance:Cache(clone)
					instance:Emit(clone)
					instance:Debris(clone, 3)
				end

				instance:Shake({
					Position = instance.GoalCFrame.Position,
					Amplitude = 2,
					Frequency = 0.1,
					FadeOutTime = 0.5
				})
				instance:Impact({
					Position = instance.GoalCFrame.Position,
					Duration = 0.25,
					TintColor = Color3.fromRGB(255, 0, 0)
				})
				instance:Blur({
					Position = instance.GoalCFrame.Position,
					Size = 30
				})
			end
		}
	}
}