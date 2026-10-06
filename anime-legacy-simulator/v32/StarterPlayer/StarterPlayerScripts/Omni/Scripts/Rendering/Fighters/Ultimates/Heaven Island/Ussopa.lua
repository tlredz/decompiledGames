local tweenInfo = TweenInfo.new(0.37, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
return {
	Setup = function(instance)
		local leftHand = instance.Model:FindFirstChild("LeftHand")

		if not leftHand then
			return
		end

		instance.LeftHand = leftHand
		local clone = instance:Clone("Slingshot")

		if clone then
			instance:SetPart0(clone, leftHand)
			instance:AttachToModel(clone)
			instance.Slingshot = clone
		end
	end,
	Steps = {
		{
			Marker = "Cast",
			Run = function(instance)
				if not instance.LeftHand then
					return
				end

				instance:Sound("Launch")
				local v = instance.EnemyHRP.Position - Vector3.new(0, instance.Enemy.MediumSize, 0)
				instance.GoalPosition = v
				local clone = instance:Clone("Ball")

				if not clone then
					return
				end

				clone.Anchored = true
				clone.CanCollide = false
				clone.CanTouch = false
				clone.CanQuery = false
				clone.CFrame = CFrame.lookAt(instance.LeftHand.Position, v)
				clone.Parent = workspace.Cache
				instance.Ball = clone
				instance.Omni.Services.TweenService:Create(clone, tweenInfo, {
					Position = v
				}):Play()
			end
		},
		{
			Marker = "Explode",
			Run = function(instance)
				instance:Sound("Explosion")

				if instance.Ball then
					instance:Destroy(instance.Ball)
				end

				if instance.Slingshot then
					instance:Destroy(instance.Slingshot)
				end

				local goalPosition = instance.GoalPosition or instance.Goal
				local clone = instance:Clone("Explosion")

				if clone then
					clone.Anchored = true
					clone.CanCollide = false
					clone.CanTouch = false
					clone.CanQuery = false
					clone:PivotTo(CFrame.new(goalPosition))
					clone.Parent = workspace.Cache
					instance:Emit(clone)
					instance:Debris(clone, 3)
				end

				instance:Shake({
					Position = goalPosition,
					Amplitude = 2,
					Frequency = 0.1,
					FadeOutTime = 0.5
				})
				instance:Impact({
					Position = goalPosition,
					Duration = 0.25,
					TintColor = Color3.fromRGB(255, 140, 60)
				})
				instance:Blur({
					Position = goalPosition,
					Size = 20
				})
				instance:Rock("Explosion", CFrame.new(goalPosition), 8, 0.5, 1.6, false)
			end
		}
	}
}