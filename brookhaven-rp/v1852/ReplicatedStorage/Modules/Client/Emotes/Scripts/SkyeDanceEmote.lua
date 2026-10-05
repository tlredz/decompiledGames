local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = { "LeftHand", "RightHand" }
local SkyeDanceEmote = {}
SkyeDanceEmote.__index = SkyeDanceEmote

function SkyeDanceEmote.new()
	local self = setmetatable({}, SkyeDanceEmote)
	self._janitor = Janitor.new()
	self._activeAssets = nil
	self._looseClones = {}
	self._emittersByFolder = {}
	return self
end

local function collectEmitters(p, name: string, emitter)
	local emitters = p._emittersByFolder[name]

	if emitters == nil then
		emitters = {}
		p._emittersByFolder[name] = emitters
	end

	if emitter:IsA("ParticleEmitter") then
		table.insert(emitters, emitter)
	end

	for _, emitter2 in emitter:GetDescendants() do
		if emitter2:IsA("ParticleEmitter") then
			table.insert(emitters, emitter2)
		end
	end
end

local function setToggleableEmittersEnabled(state, enabled: boolean)
	for _, v2 in v do
		local v3 = state._emittersByFolder[v2]

		if v3 == nil then
			continue
		end

		for _, v4 in v3 do
			v4.Enabled = enabled
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setAllEmittersEnabled(state, enabled: boolean)
	for _, v2 in state._emittersByFolder do
		for _, v3 in v2 do
			v3.Enabled = enabled
		end
	end
end

local function attachPartToBodyPart(part, part2, folder)
	local clone = part:Clone()
	clone.Anchored = false
	clone.CanCollide = false
	clone.CanTouch = false
	clone.Massless = true
	clone.CFrame = part2.CFrame
	clone.Parent = folder
	local HRP = clone:FindFirstChild("HRP", true)

	if HRP and HRP:IsA("Motor6D") then
		HRP.Part0 = part2
		HRP.Part1 = clone
		HRP.Parent = part2
		return clone
	else
		local weldConstraint = Instance.new("WeldConstraint")
		weldConstraint.Part0 = part2
		weldConstraint.Part1 = clone
		weldConstraint.Parent = clone
		return clone
	end
end

local function mountTemplate(state, parent, skyesSummerSong)
	local folder = Instance.new("Folder")
	folder.Name = "SkyeDanceAssets"
	folder.Parent = parent

	for _, folder2 in skyesSummerSong:GetChildren() do
		local part = parent:FindFirstChild(folder2.Name)

		if not (part and part:IsA("BasePart") and folder2:IsA("Folder")) then
			continue
		end

		for _, part2 in folder2:GetChildren() do
			if part2:IsA("BasePart") then
				local v2 = attachPartToBodyPart(part2, part, folder)
				collectEmitters(state, folder2.Name, v2)
			else
				local clone = part2:Clone()
				clone.Parent = part
				collectEmitters(state, folder2.Name, clone)
				table.insert(state._looseClones, clone)
			end
		end
	end

	return folder
end

function SkyeDanceEmote:start(parent, object, p2)
	local v2 = p2 ~= nil
	local v3 = not v2 or p2.isEnabled()
	local emotes = ReplicatedStorage:FindFirstChild("Emotes")

	if not emotes then
		return
	end

	local skyesSummerSong = emotes:FindFirstChild("Skye's Summer Song")

	if not skyesSummerSong then
		return
	end

	self._activeAssets = mountTemplate(self, parent, skyesSummerSong)

	if v3 == false then
		setToggleableEmittersEnabled(self, false)
	end

	self._janitor:Add(object:GetMarkerReachedSignal("Heart"):Connect(function()
		if v3 == false then
			return
		end

		local upperTorso = self._emittersByFolder.UpperTorso

		if upperTorso == nil then
			return
		end

		for _, v4 in upperTorso do
			v4:Emit(3)
		end
	end))

	if v2 then
		self._janitor:Add(p2.onEnabledChanged:Connect(function(enabled: boolean)
			v3 = enabled
			setToggleableEmittersEnabled(self, enabled)
		end))
	end

	self._janitor:Add(function()
		setAllEmittersEnabled(self, false) -- equivalent call inferred; original call site unknown

		if self._activeAssets ~= nil then
			Debris:AddItem(self._activeAssets, 2)
			self._activeAssets = nil
		end

		for _, _looseClone in self._looseClones do
			Debris:AddItem(_looseClone, 2)
		end

		table.clear(self._looseClones)
		table.clear(self._emittersByFolder)
	end)
	local flag = false
	self._janitor:Add(object.Stopped:Connect(function()
		if flag then
			return
		end

		flag = true
		self._janitor:Destroy()
	end))
end

return SkyeDanceEmote