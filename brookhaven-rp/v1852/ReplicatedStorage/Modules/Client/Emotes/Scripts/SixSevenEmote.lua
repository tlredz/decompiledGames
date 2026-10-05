local ReplicatedStorage = game:GetService("ReplicatedStorage")
local EmoteVfxScale = require(ReplicatedStorage.Modules.Client.Emotes.EmoteVfxScale)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local SixSevenEmote = {}
SixSevenEmote.__index = SixSevenEmote

function SixSevenEmote.new()
	local self = setmetatable({}, SixSevenEmote)
	self._janitor = Janitor.new()
	return self
end

function SixSevenEmote:start(parent, object)
	local humanoidRootPart = parent:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return
	end

	local _67 = ReplicatedStorage:FindFirstChild("Emotes"):FindFirstChild("67")
	local v = self._janitor:Add(_67:Clone())
	local maid = self._janitor:Add(Janitor.new())
	self._janitor:Add(object:GetMarkerReachedSignal("6VFXAppear"):Connect(function()
		local part = maid:Add(v.Parts["6VFX"]:Clone())
		EmoteVfxScale.scaleToCharacterWorldScale(part, parent)
		local v3 = maid:Add(v.Motors["6VFX"]:Clone())
		v3.Part0 = humanoidRootPart
		v3.Part1 = part
		EmoteVfxScale.scaleMotor6DForWorldScale(v3, parent)
		part.Parent = parent
		v3.Parent = humanoidRootPart
	end))
	self._janitor:Add(object:GetMarkerReachedSignal("7VFXAppear"):Connect(function()
		local part = maid:Add(v.Parts["7VFX"]:Clone())
		EmoteVfxScale.scaleToCharacterWorldScale(part, parent)
		local v3 = maid:Add(v.Motors["7VFX"]:Clone())
		v3.Part0 = humanoidRootPart
		v3.Part1 = part
		EmoteVfxScale.scaleMotor6DForWorldScale(v3, parent)
		part.Parent = parent
		v3.Parent = humanoidRootPart
	end))
	self._janitor:Add(object:GetMarkerReachedSignal("HideVFX"):Connect(function()
		maid:Cleanup()
	end))
	self._janitor:Add(object.Stopped:Connect(function()
		self._janitor:Destroy()
	end))
end

return SixSevenEmote