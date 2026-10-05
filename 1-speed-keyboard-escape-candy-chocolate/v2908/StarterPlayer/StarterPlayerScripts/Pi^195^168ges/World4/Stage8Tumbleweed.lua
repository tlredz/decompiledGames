local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local localPlayer = Players.LocalPlayer
local v = {}
local v2 = {}

local function waitForDescendant(instance, childName: string)
	local child = instance:FindFirstChild(childName, true)

	while not child and instance.Parent do
		task.wait(0.1)
		child = instance:FindFirstChild(childName, true)
	end

	return child
end

local function findTimerLabel(instance)
	local v3 = waitForDescendant(instance, "TimerPart")

	if not v3 then
		warn("[Stage8Tumbleweed][Client] TimerPart introuvable dans", instance:GetFullName())
		return nil
	end

	local timer = v3:FindFirstChild("Timer", true)

	if timer and timer:IsA("TextLabel") then
		return timer
	end

	local textLabel = v3:FindFirstChildWhichIsA("TextLabel", true)

	if not textLabel then
		warn("[Stage8Tumbleweed][Client] TextLabel du timer introuvable dans", v3:GetFullName())
	end

	return textLabel
end

local function setupTumbleweed(instance)
	if v[instance] or v2[instance] then
		return
	end

	v2[instance] = true
	local part = waitForDescendant(instance, "Tumbleweed")

	if part and part:IsA("BasePart") then
		local part2 = waitForDescendant(instance, "KillPart")
		local part3 = waitForDescendant(instance, "TumbleweedDropSpawn")
		local part4 = waitForDescendant(instance, "TumbleweedStart")
		local part5 = waitForDescendant(instance, "TumbleweedEnd")

		if part2 and part2:IsA("BasePart") then
			part.Anchored = true
			part2.Anchored = true
			part2.CanCollide = false

			if part3 and part3:IsA("BasePart") and part4 and part4:IsA("BasePart") and part5 and part5:IsA("BasePart") then
				local fallTime = instance:GetAttribute("FallTime")
				local speed = instance:GetAttribute("Speed")
				local bounceTime = instance:GetAttribute("BounceTime")
				local bounceHeight = instance:GetAttribute("BounceHeight")
				local fallTime2 = (typeof(fallTime) ~= "number" or not (fallTime > 0)) and 1 or fallTime
				local v4 = (typeof(speed) ~= "number" or not (speed > 0)) and 70 or speed
				local bounceTime2 = (typeof(bounceTime) ~= "number" or not (bounceTime >= 0)) and 0.2 or bounceTime
				local bounceHeight2 = (typeof(bounceHeight) ~= "number" or not (bounceHeight >= 0)) and 3 or bounceHeight
				local travelTime = (part5.Position - part4.Position).Magnitude / v4

				if travelTime <= 0 then
					v2[instance] = nil
					warn("[World4Tumbleweed] TumbleweedStart et TumbleweedEnd ne doivent pas être superposés")
				else
					v[instance] = {
						visual = part,
						killPart = part2,
						killPartPositionOffset = part2.Position - part.Position,
						killPartRotation = part2.CFrame.Rotation,
						timerLabel = findTimerLabel(instance),
						dropCFrame = part3.CFrame,
						startCFrame = part4.CFrame,
						endCFrame = part5.CFrame,
						fallTime = fallTime2,
						travelTime = travelTime,
						bounceTime = bounceTime2,
						bounceHeight = bounceHeight2,
						cycleStart = workspace:GetServerTimeNow(),
						lastKillCheck = 0
					}
					v2[instance] = nil
				end
			else
				v2[instance] = nil
				warn("[World4Tumbleweed] Un ou plusieurs repères sont introuvables dans", instance:GetFullName())
			end
		else
			v2[instance] = nil
			warn("[World4Tumbleweed] BasePart 'KillPart' introuvable dans", instance:GetFullName())
		end
	else
		v2[instance] = nil

		if instance.Parent then
			warn("[World4Tumbleweed] MeshPart 'Tumbleweed' introuvable dans", instance:GetFullName())
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function removeTumbleweed(p)
	v[p] = nil
	v2[p] = nil
end

RunService.PreRender:Connect(function()
	local serverTimeNow = workspace:GetServerTimeNow()

	for k, v3 in v do
		if k.Parent then
			if v3.visual:IsDescendantOf(k) and v3.killPart:IsDescendantOf(k) then
				local cycleStart = v3.cycleStart
				local fallTime = v3.fallTime
				local travelTime = v3.travelTime
				local bounceTime = v3.bounceTime
				local bounceHeight = v3.bounceHeight
				local v4 = fallTime + bounceTime + travelTime
				local v5 = serverTimeNow - cycleStart

				if not (v5 < 0) then
					local v6 = v5 % v4
					local v7 = v4 - v6
					local cFrame

					if v6 < fallTime then
						local v9 = math.clamp(v6 / fallTime, 0, 1)
						cFrame = v3.dropCFrame:Lerp(v3.startCFrame, v9)
					elseif v6 < fallTime + bounceTime and bounceTime > 0 then
						local v9 = math.clamp((v6 - fallTime) / bounceTime, 0, 1)
						local v10 = bounceHeight * 4 * v9 * (1 - v9)
						cFrame = v3.startCFrame + Vector3.new(0, v10, 0)
					else
						local v9 = v6 - fallTime - bounceTime
						local v10 = math.clamp(v9 / travelTime, 0, 1)
						local rollSpeed = k:GetAttribute("RollSpeed")
						local v11 = math.rad((typeof(rollSpeed) ~= "number" and -360 or rollSpeed) * v9)
						cFrame = v3.startCFrame:Lerp(v3.endCFrame, v10) * CFrame.Angles(v11, 0, 0)
					end

					local v9 = cFrame.Position + v3.killPartPositionOffset
					local cFrame2 = CFrame.new(v9) * v3.killPartRotation
					v3.visual.CFrame = cFrame
					v3.killPart.CFrame = cFrame2

					if serverTimeNow - v3.lastKillCheck >= 0.1 then
						v3.lastKillCheck = serverTimeNow
						local character = localPlayer.Character

						if character then
							for _, v12 in workspace:GetPartBoundsInBox(cFrame2, v3.killPart.Size) do
								if not v12:IsDescendantOf(character) then
									continue
								end

								local humanoid = character:FindFirstChildOfClass("Humanoid")

								if humanoid and humanoid.Health > 0 then
									humanoid.Health = 0
								end

								break
							end
						end
					end

					if v3.timerLabel then
						v3.timerLabel.Text = string.format("%.1f", (math.max(0, v7)))
					end
				end
			else
				removeTumbleweed(k) -- equivalent call inferred; original call site unknown
				task.spawn(setupTumbleweed, k)
			end
		else
			v[k] = nil
		end
	end
end)
local tagged = CollectionService:GetTagged("World4Stage8TumbleweedModel")

for _, model in tagged do
	if model:IsA("Model") then
		task.spawn(setupTumbleweed, model)
	end
end

CollectionService:GetInstanceAddedSignal("World4Stage8TumbleweedModel"):Connect(function(model)
	if model:IsA("Model") then
		task.spawn(setupTumbleweed, model)
	else
		warn("[Stage8Tumbleweed][Client] Instance taguée non-Model :", model:GetFullName(), model.ClassName)
	end
end)
CollectionService:GetInstanceRemovedSignal("World4Stage8TumbleweedModel"):Connect(function(model)
	if model:IsA("Model") then
		removeTumbleweed(model) -- equivalent call inferred; original call site unknown
	end
end)