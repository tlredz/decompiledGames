local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
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

local function isLocalCharacterPart(instance)
	local character = localPlayer.Character
	return character ~= nil and instance:IsDescendantOf(character)
end

local function computeLavaAlpha(p: number, p2: number, p3: number, p4: number)
	if p < p2 then
		return p / p2, true
	end

	if p < p2 + p3 then
		return 1, false
	end

	if p < p2 + p3 + p4 then
		return 1 - (p - (p2 + p3)) / p4, true
	end

	return 0, false
end

-- equivalent calls inferred from this helper; original call sites unknown
local function applyLavaAlpha(data, p: number)
	local v3 = data.MinHeight + (data.MaxHeight - data.MinHeight) * p
	data.Lava.Size = Vector3.new(data.BaseSize.X, v3, data.BaseSize.Z)
	data.Lava.CFrame = data.BaseCF * CFrame.new(0, v3 / 2, 0)
end

local function setupTrap(instance)
	if v[instance] or v2[instance] then
		return
	end

	v2[instance] = true
	local part = waitForDescendant(instance, "LavaPart")
	local part2 = waitForDescendant(instance, "LavaBottom")
	local part3 = waitForDescendant(instance, "LavaTop")

	if part and part:IsA("BasePart") and part2 and part2:IsA("BasePart") and part3 and part3:IsA("BasePart") then
		part2.Transparency = 1
		part2.CanCollide = false
		part3.Transparency = 1
		part3.CanCollide = false
		local sound = part:FindFirstChildOfClass("Sound")

		if sound then
			sound:Play()
		end

		local manual = instance:GetAttribute("Manual") == true
		local minHeight = instance:GetAttribute("MinHeight") or part.Size.Y
		local dot = (part3.Position - part2.Position):Dot(part2.CFrame.UpVector)

		if dot <= 0 then
			v2[instance] = nil
			warn("[Stage12LavaTower] LavaTop doit être au-dessus de LavaBottom dans", instance:GetFullName())
		else
			local maxHeight = math.max(dot, minHeight)
			local v4 = {
				Lava = part,
				Bottom = part2,
				Top = part3,
				Sound = sound,
				Manual = manual,
				Active = false,
				TriggerTime = 0,
				BaseCF = part2.CFrame,
				BaseSize = part.Size,
				MinHeight = minHeight,
				MaxHeight = maxHeight,
				StartTime = workspace:GetServerTimeNow()
			}
			applyLavaAlpha(v4, 0) -- equivalent call inferred; original call site unknown
			part.Touched:Connect(function(otherPart)
				if v4.Manual and not v4.Active then
					return
				end

				local character = localPlayer.Character
				local v5

				if character == nil then
					v5 = false
				else
					v5 = otherPart:IsDescendantOf(character)
				end

				if not v5 then
					return
				end

				local character2 = localPlayer.Character
				local humanoid = character2 and character2:FindFirstChildOfClass("Humanoid")

				if humanoid and humanoid.Health > 0 then
					humanoid.Health = 0
				end
			end)

			if manual then
				if sound then
					sound.Volume = 0
				end

				local part4 = waitForDescendant(instance, "ManualZone")

				if part4 and part4:IsA("BasePart") then
					part4.Touched:Connect(function(otherPart)
						if v4.Active then
							return
						end

						local character = localPlayer.Character
						local v5

						if character == nil then
							v5 = false
						else
							v5 = otherPart:IsDescendantOf(character)
						end

						if not v5 then
							return
						end

						v4.Active = true
						v4.TriggerTime = workspace:GetServerTimeNow()
					end)
				else
					warn("[LavaTower] Manual activé mais 'ManualZone' introuvable dans", instance:GetFullName())
				end
			end

			v[instance] = v4
			v2[instance] = nil
		end
	else
		v2[instance] = nil

		if instance.Parent then
			warn("[Stage12LavaTower] LavaPart, LavaBottom ou LavaTop invalide dans", instance:GetFullName())
		end
	end
end

RunService.PreRender:Connect(function()
	local serverTimeNow = workspace:GetServerTimeNow()

	for k, v3 in v do
		if not k:IsDescendantOf(workspace) then
			continue
		end

		local riseTime = k:GetAttribute("RiseTime") or 5
		local topWait = k:GetAttribute("TopWait") or 1
		local fallTime = k:GetAttribute("FallTime") or 2

		if v3.Manual then
			if v3.Active then
				local v4 = serverTimeNow - v3.TriggerTime
				local v5, v6

				if v4 < riseTime then
					v5 = v4 / riseTime
					v6 = true
				elseif v4 < riseTime + topWait then
					v5 = 1
					v6 = false
				elseif v4 < riseTime + topWait + fallTime then
					v5 = 1 - (v4 - (riseTime + topWait)) / fallTime
					v6 = true
				else
					v5 = 0
					v6 = false
				end

				applyLavaAlpha(v3, v5) -- equivalent call inferred; original call site unknown

				if v3.Sound then
					v3.Sound.Volume = v6 and 1 or 0
				end

				if riseTime + topWait + fallTime <= v4 then
					v3.Active = false
				end
			else
				applyLavaAlpha(v3, 0) -- equivalent call inferred; original call site unknown

				if v3.Sound then
					v3.Sound.Volume = 0
				end
			end
		else
			local startTime = v3.StartTime
			local bottomWait = k:GetAttribute("BottomWait") or 2
			local v4 = riseTime + topWait + fallTime + bottomWait
			local v5 = (serverTimeNow - startTime) % v4
			local v6, v7

			if v5 < riseTime then
				v6 = v5 / riseTime
				v7 = true
			elseif v5 < riseTime + topWait then
				v6 = 1
				v7 = false
			elseif v5 < riseTime + topWait + fallTime then
				v6 = 1 - (v5 - (riseTime + topWait)) / fallTime
				v7 = true
			else
				v6 = 0
				v7 = false
			end

			applyLavaAlpha(v3, v6) -- equivalent call inferred; original call site unknown

			if v3.Sound then
				v3.Sound.Volume = v7 and 1 or 0
			end
		end
	end
end)
CollectionService:GetInstanceAddedSignal("W4LavaTrap"):Connect(function(model)
	if model:IsA("Model") then
		task.spawn(setupTrap, model)
	end
end)
CollectionService:GetInstanceRemovedSignal("W4LavaTrap"):Connect(function(p)
	v[p] = nil
	v2[p] = nil
end)

for _, model in ipairs(CollectionService:GetTagged("W4LavaTrap")) do
	if model:IsA("Model") then
		task.spawn(setupTrap, model)
	end
end