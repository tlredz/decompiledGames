local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
local v = {}
local v2 = {}
local setupTrap

setupTrap = function(instance)
	local wallL = instance:WaitForChild("WallL", 5)
	local wallR = instance:WaitForChild("WallR", 5)
	local targetL = instance:WaitForChild("TargetL", 5)
	local targetR = instance:WaitForChild("TargetR", 5)
	local crushCenter = instance:WaitForChild("CrushCenter", 5)

	if not (wallL and wallR and targetL and targetR and crushCenter) then
		return
	end

	local cycleStartTime = instance:GetAttribute("CycleStartTime")

	if cycleStartTime then
		local closeTime = instance:GetAttribute("CloseTime") or 2
		local waitTime = instance:GetAttribute("WaitTime") or 1
		local openTime = instance:GetAttribute("OpenTime") or 1
		v[instance] = {
			L = wallL,
			R = wallR,
			startL = wallL.CFrame,
			startR = wallR.CFrame,
			endL = targetL.CFrame,
			endR = targetR.CFrame,
			closeT = closeTime,
			waitT = waitTime,
			openT = openTime,
			total = closeTime + waitTime + openTime,
			startTime = cycleStartTime,
			SoundL = wallL:FindFirstChild("MoveSoundL"),
			SoundR = wallR:FindFirstChild("MoveSoundR"),
			ImpactS = crushCenter:FindFirstChild("ImpactSound"),
			LastState = "Idle"
		}
		targetL.CanCollide = false
		targetR.CanCollide = false
	else
		if v2[instance] then
			return
		end

		local cycleStartTimeChangedConnection = nil
		cycleStartTimeChangedConnection = instance:GetAttributeChangedSignal("CycleStartTime"):Connect(function()
			v2[instance] = nil

			if cycleStartTimeChangedConnection then
				cycleStartTimeChangedConnection:Disconnect()
			end

			setupTrap(instance)
		end)
		v2[instance] = cycleStartTimeChangedConnection
	end
end

RunService.PreRender:Connect(function()
	local serverTimeNow = workspace:GetServerTimeNow()

	for k, v3 in v do
		if not k:IsDescendantOf(workspace) then
			continue
		end

		local v4 = (serverTimeNow - v3.startTime) % v3.total

		if v4 < v3.closeT then
			local v5 = v4 / v3.closeT
			v3.L.CFrame = v3.startL:Lerp(v3.endL, v5)
			v3.R.CFrame = v3.startR:Lerp(v3.endR, v5)
		elseif v4 < v3.closeT + v3.waitT then
			v3.L.CFrame = v3.endL
			v3.R.CFrame = v3.endR
		else
			local v5 = (v4 - v3.closeT - v3.waitT) / v3.openT
			v3.L.CFrame = v3.endL:Lerp(v3.startL, v5)
			v3.R.CFrame = v3.endR:Lerp(v3.startR, v5)
		end

		if v4 < v3.closeT then
			if v3.SoundL and not v3.SoundL.IsPlaying then
				v3.SoundL:Play()
			end

			if v3.SoundR and not v3.SoundR.IsPlaying then
				v3.SoundR:Play()
			end

			v3.LastState = "Closing"
		elseif v4 < v3.closeT + v3.waitT then
			if v3.LastState == "Closing" then
				if v3.SoundL then
					v3.SoundL:Stop()
				end

				if v3.SoundR then
					v3.SoundR:Stop()
				end

				if v3.ImpactS then
					v3.ImpactS:Play()
				end

				v3.LastState = "Wait"
			end
		else
			if v3.SoundL and not v3.SoundL.IsPlaying then
				v3.SoundL:Play()
			end

			if v3.SoundR and not v3.SoundR.IsPlaying then
				v3.SoundR:Play()
			end

			v3.LastState = "Opening"
		end
	end
end)
CollectionService:GetInstanceRemovedSignal("CrushTrap"):Connect(function(p)
	v[p] = nil
	local connection = v2[p]

	if connection then
		connection:Disconnect()
		v2[p] = nil
	end
end)

for _, v3 in ipairs(CollectionService:GetTagged("CrushTrap")) do
	setupTrap(v3)
end

CollectionService:GetInstanceAddedSignal("CrushTrap"):Connect(function(model)
	if model:IsA("Model") then
		setupTrap(model)
	end
end)