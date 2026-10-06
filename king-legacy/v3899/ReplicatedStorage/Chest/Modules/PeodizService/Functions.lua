local TweenService = game:GetService("TweenService")
local Functions = {}

function Functions:CustomForLoop(_)
	if self.CurrentWaitTime >= self.WaitTime then
		self.CurrentWaitTime -= self.WaitTime

		if self.Function then
			local v = math.floor(self.CurrentTime * self.End / self.Step) * self.Step
			local v2 = tonumber((string.format("%.3f", v)))
			task.spawn(function()
				local currentTime = self.CurrentTime

				if self.Tween then
					local easingStyle = self.Tween.EasingStyle or Enum.EasingStyle.Linear
					local easingDirection = self.Tween.EasingDirection or Enum.EasingDirection.Out
					currentTime = TweenService:GetValue(currentTime, easingStyle, easingDirection)
				end

				if self.Function and self.Function(currentTime, v2) and not self.Finished then
					self:Destroy()
				end
			end)
		end
	end
end

function Functions:CustomForceForLoop(_)
	if self.CurrentWaitTime >= self.WaitTime then
		self.CurrentWaitTime -= self.WaitTime
		local v = math.floor(self.CurrentTime * self.End / self.Step) * self.Step
		local v2 = tonumber((string.format("%.3f", v)))

		if self.Step < v2 then
			for i = self.Start, v2, self.Step do
				local v3 = tonumber((string.format("%.3f", i)))

				if v3 == v2 or (i < self.Step or v3 <= 0 or self.StepData[v3]) then
					continue
				end

				self.StepData[v3] = true
				local v4 = i / self.End

				if not self.Function then
					continue
				end

				local v5 = v4
				local v6 = v3
				task.spawn(function()
					local value = v5

					if self.Tween then
						local easingStyle = self.Tween.EasingStyle or Enum.EasingStyle.Linear
						local easingDirection = self.Tween.EasingDirection or Enum.EasingDirection.Out
						value = TweenService:GetValue(value, easingStyle, easingDirection)
					end

					if self.Function and self.Function(value, v6) and not self.Finished then
						self:Destroy()
					end
				end)
			end
		end

		if self.StepData then
			if self.StepData[v2] then
				return
			else
				self.StepData[v2] = true
			end
		end

		if self.Function then
			task.spawn(function()
				local currentTime = self.CurrentTime

				if self.Tween then
					local easingStyle = self.Tween.EasingStyle or Enum.EasingStyle.Linear
					local easingDirection = self.Tween.EasingDirection or Enum.EasingDirection.Out
					currentTime = TweenService:GetValue(currentTime, easingStyle, easingDirection)
				end

				if self.Function and self.Function(currentTime, v2) and not self.Finished then
					self:Destroy()
				end
			end)
		end
	end
end

function Functions:ForLoop()
	if self.CurrentWaitTime >= self.WaitTime then
		self.CurrentWaitTime -= self.WaitTime

		if self.Function then
			task.spawn(function()
				local currentTime = self.CurrentTime

				if self.Tween then
					local easingStyle = self.Tween.EasingStyle or Enum.EasingStyle.Linear
					local easingDirection = self.Tween.EasingDirection or Enum.EasingDirection.Out
					currentTime = TweenService:GetValue(currentTime, easingStyle, easingDirection)
				end

				if self.Function and self.Function(currentTime) and not self.Finished then
					self:Destroy()
				end
			end)
		end
	end
end

function Functions:ForceForLoop(p)
	if self.CurrentWaitTime >= self.WaitTime then
		self.CurrentWaitTime -= self.WaitTime
		local v = math.floor(self.CurrentTime * self.Step)

		if v - 1 > 0 and self.StepData then
			for i = 1, v - 1 do
				if self.StepData[i] then
					continue
				end

				self.StepData[i] = true
				local v2 = i / self.Step + p / self.Step

				if not self.Function then
					continue
				end

				local v3 = v2
				task.spawn(function()
					local value = v3

					if self.Tween then
						local easingStyle = self.Tween.EasingStyle or Enum.EasingStyle.Linear
						local easingDirection = self.Tween.EasingDirection or Enum.EasingDirection.Out
						value = TweenService:GetValue(value, easingStyle, easingDirection)
					end

					if self.Function and self.Function(value) and not self.Finished then
						self:Destroy()
					end
				end)
			end
		end

		if self.StepData then
			self.StepData[v] = true
		end

		if self.Function then
			task.spawn(function()
				local currentTime = self.CurrentTime

				if self.Tween then
					local easingStyle = self.Tween.EasingStyle or Enum.EasingStyle.Linear
					local easingDirection = self.Tween.EasingDirection or Enum.EasingDirection.Out
					currentTime = TweenService:GetValue(currentTime, easingStyle, easingDirection)
				end

				if self.Function and self.Function(currentTime) and not self.Finished then
					self:Destroy()
				end
			end)
		end
	end
end

function Functions.Heartbeat(instance, p)
	if instance.Function then
		task.spawn(function()
			local currentTime = instance.CurrentTime

			if instance.Tween then
				local easingStyle = instance.Tween.EasingStyle or Enum.EasingStyle.Linear
				local easingDirection = instance.Tween.EasingDirection or Enum.EasingDirection.Out
				currentTime = TweenService:GetValue(currentTime, easingStyle, easingDirection)
			end

			if instance.Function and instance.Function(currentTime, p) and not instance.Finished then
				instance:Destroy()
			end
		end)
	end
end

function Functions:HeartbeatWait(p)
	if self.CurrentWaitTime >= self.WaitTime then
		self.CurrentWaitTime -= self.WaitTime

		if self.Function then
			task.spawn(function()
				local currentTime = self.CurrentTime

				if self.Tween then
					local easingStyle = self.Tween.EasingStyle or Enum.EasingStyle.Linear
					local easingDirection = self.Tween.EasingDirection or Enum.EasingDirection.Out
					currentTime = TweenService:GetValue(currentTime, easingStyle, easingDirection)
				end

				if self.Function and self.Function(currentTime, p) and not self.Finished then
					self:Destroy()
				end
			end)
		end
	end
end

return Functions