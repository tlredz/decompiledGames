local TweenService = game:GetService("TweenService")
return function(folder, p, p2)
	for _, effect in pairs(folder:GetDescendants()) do
		if effect:IsA("ParticleEmitter") then
			local attributes = effect:GetAttributes()
			local emitDelay = attributes.EmitDelay
			local emitDuration = attributes.EmitDuration or 0
			local v2 = effect
			task.delay(emitDelay, function()
				if emitDuration > 0 then
					task.defer(function()
						v2.Enabled = true
						task.wait(emitDuration)
						v2.Enabled = false
					end)
				else
					v2:Emit(attributes.EmitCount)
				end
			end)
		end

		if not effect:IsA("Beam") then
			continue
		end

		local attributes = effect:GetAttributes()
		local duration = attributes.Duration
		local v = not (p2 and p2.TweenTime) and 0.5 or p2.TweenTime
		local v2 = effect

		local function Shut_OFF()
			TweenService:Create(v2, TweenInfo.new(v, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
				Width1 = 0,
				Width0 = 0
			}):Play()
		end

		local v3 = effect

		local function Turn_ON()
			TweenService:Create(v3, TweenInfo.new(v, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
				Width1 = attributes.Width1,
				Width0 = attributes.Width0
			}):Play()
		end

		Turn_ON()

		if not duration then
			continue
		end

		local Shut_OFF2 = Shut_OFF
		task.delay(duration, function()
			Shut_OFF2()
		end)
	end

	if p then
		game.Debris:AddItem(folder, p)
	end
end