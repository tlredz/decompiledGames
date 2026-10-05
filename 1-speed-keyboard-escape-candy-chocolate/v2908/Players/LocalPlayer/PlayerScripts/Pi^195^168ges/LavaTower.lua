local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
local localPlayer = Players.LocalPlayer
local v = {}

local function isLocalCharacterPart(instance)
	local character = localPlayer.Character
	return character ~= nil and instance:IsDescendantOf(character)
end

local function computeLavaCF(p, p2: number, riseTime: number, topWait: number, fallTime: number)
	if p2 < riseTime then
		return p.Bottom.CFrame:Lerp(p.Top.CFrame, p2 / riseTime), true
	end

	if p2 < riseTime + topWait then
		return p.Top.CFrame, false
	end

	if p2 < riseTime + topWait + fallTime then
		local v2 = (p2 - (riseTime + topWait)) / fallTime
		return p.Top.CFrame:Lerp(p.Bottom.CFrame, v2), true
	else
		return p.Bottom.CFrame, false
	end
end

local function setupTrap(instance)
	if v[instance] then
		return
	end

	local lavaPart = instance:WaitForChild("LavaPart", 10)
	local lavaBottom = instance:WaitForChild("LavaBottom", 10)
	local lavaTop = instance:WaitForChild("LavaTop", 10)

	if not (lavaPart and lavaBottom and lavaTop) then
		return
	end

	lavaBottom.Transparency = 1
	lavaBottom.CanCollide = false
	lavaTop.Transparency = 1
	lavaTop.CanCollide = false
	local sound = lavaPart:FindFirstChildOfClass("Sound")

	if sound then
		sound:Play()
	end

	local manual = instance:GetAttribute("Manual") == true
	local v2 = {
		Lava = lavaPart,
		Bottom = lavaBottom,
		Top = lavaTop,
		Sound = sound,
		Manual = manual,
		Active = false,
		TriggerTime = 0
	}

	if manual then
		lavaPart.CFrame = lavaBottom.CFrame

		if sound then
			sound.Volume = 0
		end

		local manualZone = instance:FindFirstChild("ManualZone")

		if manualZone and manualZone:IsA("BasePart") then
			manualZone.Touched:Connect(function(otherPart)
				if v2.Active then
					return
				end

				local character = localPlayer.Character
				local v3

				if character == nil then
					v3 = false
				else
					v3 = otherPart:IsDescendantOf(character)
				end

				if not v3 then
					return
				end

				v2.Active = true
				v2.TriggerTime = workspace:GetServerTimeNow()
			end)
		else
			warn("[LavaTower] Manual activé mais 'ManualZone' introuvable dans", instance:GetFullName())
		end

		lavaPart.Touched:Connect(function(otherPart)
			if not v2.Active then
				return
			end

			local character = localPlayer.Character
			local v3

			if character == nil then
				v3 = false
			else
				v3 = otherPart:IsDescendantOf(character)
			end

			if not v3 then
				return
			end

			local character2 = localPlayer.Character
			local humanoid = character2 and character2:FindFirstChildOfClass("Humanoid")

			if humanoid and humanoid.Health > 0 then
				humanoid.Health = 0
			end
		end)
	end

	v[instance] = v2
end

RunService.PreRender:Connect(function()
	local serverTimeNow = workspace:GetServerTimeNow()

	for k, v2 in v do
		if not k:IsDescendantOf(workspace) then
			continue
		end

		local riseTime = k:GetAttribute("RiseTime") or 5
		local topWait = k:GetAttribute("TopWait") or 1
		local fallTime = k:GetAttribute("FallTime") or 2

		if v2.Manual then
			if v2.Active then
				local v3 = serverTimeNow - v2.TriggerTime
				local cFrame, v5 = computeLavaCF(v2, v3, riseTime, topWait, fallTime)
				v2.Lava.CFrame = cFrame

				if v2.Sound then
					v2.Sound.Volume = v5 and 1 or 0
				end

				if riseTime + topWait + fallTime <= v3 then
					v2.Active = false
				end
			else
				v2.Lava.CFrame = v2.Bottom.CFrame

				if v2.Sound then
					v2.Sound.Volume = 0
				end
			end
		else
			local cycleStartTime = k:GetAttribute("CycleStartTime") or 0

			if cycleStartTime ~= 0 then
				local bottomWait = k:GetAttribute("BottomWait") or 2
				local v3 = riseTime + topWait + fallTime + bottomWait
				local cFrame, v6 = computeLavaCF(v2, (serverTimeNow - cycleStartTime) % v3, riseTime, topWait, fallTime)
				v2.Lava.CFrame = cFrame

				if v2.Sound then
					v2.Sound.Volume = v6 and 1 or 0
				end
			end
		end
	end
end)
CollectionService:GetInstanceAddedSignal("LavaTrap"):Connect(setupTrap)
CollectionService:GetInstanceRemovedSignal("LavaTrap"):Connect(function(p)
	v[p] = nil
end)

for _, v2 in ipairs(CollectionService:GetTagged("LavaTrap")) do
	setupTrap(v2)
end