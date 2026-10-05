local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = {
	{
		name = "StarLines",
		particleNames = { "TrailStarVFX" }
	}
}
local StarDanceEmote = {}
StarDanceEmote.__index = StarDanceEmote

function StarDanceEmote.new()
	local self = setmetatable({}, StarDanceEmote)
	self._janitor = Janitor.new()
	self._particlesByName = {}
	self._soundProgress = nil
	self._soundDone = nil
	return self
end

local function addParticlesFromRoot(p, effect)
	if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
		local effects = p._particlesByName[effect.Name]

		if effects == nil then
			effects = {}
			p._particlesByName[effect.Name] = effects
		end

		table.insert(effects, effect)
	end

	for _, effect2 in effect:GetDescendants() do
		if not (effect2:IsA("ParticleEmitter") or effect2:IsA("Trail")) then
			continue
		end

		local effects = p._particlesByName[effect2.Name]

		if effects == nil then
			effects = {}
			p._particlesByName[effect2.Name] = effects
		end

		table.insert(effects, effect2)
	end
end

local function addCloneToParent(p, instance, parent)
	local v2 = p._janitor:Add(instance:Clone())
	v2.Parent = parent
	addParticlesFromRoot(p, v2)
	return v2
end

local function attachPartToBodyPart(p, part, part2, parent)
	local v2 = p._janitor:Add(part:Clone())
	v2.Anchored = false
	v2.CanCollide = false
	v2.CanTouch = false
	v2.Massless = true
	v2.CFrame = part2.CFrame
	v2.Parent = parent
	local HRP = v2:FindFirstChild("HRP", true)

	if HRP and HRP:IsA("Motor6D") then
		HRP.Part0 = part2
		HRP.Part1 = v2
		HRP.Parent = part2
	else
		local v3 = p._janitor:Add(Instance.new("WeldConstraint"))
		v3.Part0 = part2
		v3.Part1 = v2
		v3.Parent = v2
	end

	addParticlesFromRoot(p, v2)
	return v2
end

local function mountTemplate(state, parent, starDance)
	local parent2 = state._janitor:Add(Instance.new("Folder"))
	parent2.Name = "StarDanceAssets"
	parent2.Parent = parent
	local humanoidRootPart = nil
	local v3 = nil

	for _, folder in starDance:GetChildren() do
		if folder.Name == "Sounds" and folder:IsA("Folder") then
			v3 = folder
		else
			local part = parent:FindFirstChild(folder.Name)

			if part and part:IsA("BasePart") and folder:IsA("Folder") then
				for _, part2 in folder:GetChildren() do
					if part2:IsA("BasePart") then
						local v4 = attachPartToBodyPart(state, part2, part, parent2)

						if humanoidRootPart == nil or part.Name == "HumanoidRootPart" then
							humanoidRootPart = v4
						end
					else
						local v4 = state._janitor:Add(part2:Clone())
						v4.Parent = part
						addParticlesFromRoot(state, v4)
					end
				end
			else
				local v4 = state._janitor:Add(folder:Clone())
				v4.Parent = parent2
				addParticlesFromRoot(state, v4)
			end
		end
	end

	if not v3 then
		return parent2
	end

	if humanoidRootPart == nil then
		humanoidRootPart = parent:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart then
			if not humanoidRootPart:IsA("BasePart") then
				humanoidRootPart = parent2
			end
		else
			humanoidRootPart = parent2
		end
	end

	for _, child in v3:GetChildren() do
		local v4 = state._janitor:Add(child:Clone())
		v4.Parent = humanoidRootPart
		addParticlesFromRoot(state, v4)
	end

	return parent2
end

local function setParticlesEnabled(state, particleNames, enabled: boolean)
	for _, item in particleNames do
		local v2 = state._particlesByName[item]

		if v2 == nil then
			continue
		end

		for _, v3 in v2 do
			v3.Enabled = enabled
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setAllParticlesEnabled(state, enabled: boolean)
	for _, v2 in state._particlesByName do
		for _, v3 in v2 do
			v3.Enabled = enabled
		end
	end
end

function StarDanceEmote:start(parent, object, p2)
	local v2 = p2 ~= nil
	local v3 = not v2 or p2.isEnabled()
	local emotes = ReplicatedStorage:FindFirstChild("Emotes")

	if not emotes then
		return
	end

	local starDance = emotes:FindFirstChild("Star Dance")

	if not starDance then
		return
	end

	local v4 = mountTemplate(self, parent, starDance)
	local soundProgress = v4:FindFirstChild("SoundProgress", true)

	if soundProgress and soundProgress:IsA("Sound") then
		self._soundProgress = soundProgress
	end

	local soundDone = v4:FindFirstChild("SoundDone", true)

	if soundDone and soundDone:IsA("Sound") then
		self._soundDone = soundDone
	end

	if v3 == false then
		setAllParticlesEnabled(self, false) -- equivalent call inferred; original call site unknown
	end

	for _, v5 in v do
		local v6 = v5
		self._janitor:Add(object:GetMarkerReachedSignal(v5.name):Connect(function(p3: string)
			if v3 == false then
				return
			end

			if p3 == "start" then
				setParticlesEnabled(self, v6.particleNames, true)
			elseif p3 == "stop" then
				setParticlesEnabled(self, v6.particleNames, false)
			end
		end))
	end

	self._janitor:Add(object:GetMarkerReachedSignal("StarSound"):Connect(function(p3: string)
		if v3 == false then
			return
		end

		if p3 == "hit" then
			if self._soundProgress then
				self._soundProgress:Play()
			end
		elseif p3 == "done" and self._soundDone then
			self._soundDone:Play()
		end
	end))

	if v2 then
		self._janitor:Add(p2.onEnabledChanged:Connect(function(flag: boolean)
			v3 = flag

			if flag == false then
				setAllParticlesEnabled(self, false) -- equivalent call inferred; original call site unknown

				if self._soundProgress ~= nil then
					self._soundProgress:Stop()
				end

				if self._soundDone ~= nil then
					self._soundDone:Stop()
				end
			end
		end))
	end

	self._janitor:Add(object.Stopped:Connect(function()
		self._janitor:Destroy()
	end))
end

return StarDanceEmote