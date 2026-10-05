local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local HeartHandsEmote = {}
HeartHandsEmote.__index = HeartHandsEmote

function HeartHandsEmote.new()
	local self = setmetatable({}, HeartHandsEmote)
	self._janitor = Janitor.new()
	self._activeAssets = nil
	return self
end

local function setParticlesEnabled(folder, enabled: boolean)
	for _, effect in folder:GetDescendants() do
		if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
			effect.Enabled = enabled
		end
	end
end

local function attachPartToRoot(_, part, humanoidRootPart, folder)
	local clone = part:Clone()
	clone.Anchored = false
	clone.CanCollide = false
	clone.CanTouch = false
	clone.Massless = true
	clone.CFrame = humanoidRootPart.CFrame
	clone.Parent = folder
	local HRP = clone:FindFirstChild("HRP", true)

	if HRP and HRP:IsA("Motor6D") then
		HRP.Part0 = humanoidRootPart
		HRP.Part1 = clone
		HRP.Parent = humanoidRootPart
	else
		local weldConstraint = Instance.new("WeldConstraint")
		weldConstraint.Part0 = humanoidRootPart
		weldConstraint.Part1 = clone
		weldConstraint.Parent = clone
	end

	setParticlesEnabled(clone, true)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function cloneToParent(_, part, humanoidRootPart)
	local clone = part:Clone()
	clone.Parent = humanoidRootPart
	setParticlesEnabled(clone, true)
end

function HeartHandsEmote:start(parent, p, p2)
	p.Looped = true
	local v = p2 ~= nil

	if v and p2.isEnabled() == false then
		self._janitor:Add(p.Stopped:Connect(function()
			self._janitor:Destroy()
		end))
		return
	end

	local emotes = ReplicatedStorage:FindFirstChild("Emotes")

	if not emotes then
		return
	end

	local heartHands = emotes:FindFirstChild("Heart Hands")

	if not heartHands then
		return
	end

	local humanoidRootPart = parent:FindFirstChild("HumanoidRootPart")

	if not (humanoidRootPart and humanoidRootPart:IsA("BasePart")) then
		return
	end

	local folder = Instance.new("Folder")
	folder.Name = "HeartHandsAssets"
	folder.Parent = parent
	self._activeAssets = folder
	local humanoidRootPart2 = heartHands:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart2 and humanoidRootPart2:IsA("Folder") then
		for _, part in humanoidRootPart2:GetChildren() do
			if part:IsA("BasePart") then
				attachPartToRoot(self, part, humanoidRootPart, folder)
			else
				cloneToParent(nil, part, humanoidRootPart) -- equivalent call inferred; original call site unknown
			end
		end
	else
		for _, part in heartHands:GetChildren() do
			if part:IsA("BasePart") then
				attachPartToRoot(self, part, humanoidRootPart, folder)
			end
		end
	end

	if v then
		self._janitor:Add(p2.onEnabledChanged:Connect(function(flag: boolean)
			if flag == false then
				local _activeAssets = self._activeAssets

				if _activeAssets ~= nil then
					setParticlesEnabled(_activeAssets, false)
				end
			end
		end))
	end

	local flag = false
	self._janitor:Add(p.Stopped:Connect(function()
		if flag then
			return
		end

		flag = true
		local _activeAssets = self._activeAssets

		if _activeAssets then
			setParticlesEnabled(_activeAssets, false)
			Debris:AddItem(_activeAssets, 2)
			self._activeAssets = nil
		end

		self._janitor:Destroy()
	end))
end

return HeartHandsEmote