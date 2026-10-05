local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BasePartUtil = require(ReplicatedStorage.Modules.Shared.Utils.BasePartUtil)
local EmoteVfxScale = require(ReplicatedStorage.Modules.Client.Emotes.EmoteVfxScale)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local FlareWaveEmote = {}
FlareWaveEmote.__index = FlareWaveEmote

function FlareWaveEmote.new()
	return (setmetatable({
		_janitor = Janitor.new()
	}, FlareWaveEmote))
end

local function setVfxEnabled(folder, enabled: boolean)
	for _, descendant in folder:GetDescendants() do
		if descendant:IsA("ParticleEmitter") or descendant:IsA("PointLight") then
			descendant.Enabled = enabled
		end
	end
end

function FlareWaveEmote:start(parent, p2, p3)
	local humanoid = parent:FindFirstChildOfClass("Humanoid")

	if humanoid then
		humanoid:UnequipTools()
	end

	local clone = ReplicatedStorage.Emotes.Flare:Clone()
	clone.Parent = parent
	EmoteVfxScale.scaleToCharacterWorldScale(clone, parent)
	local rightHand = parent:WaitForChild("RightHand")
	local handle = clone:WaitForChild("Handle")
	clone:PivotTo(rightHand.RightGripAttachment.WorldCFrame)
	self._janitor:Add(BasePartUtil.weld(handle, rightHand, clone, "WeldConstraint"))
	self._janitor:Add(clone)

	if p3 ~= nil then
		setVfxEnabled(clone, p3.isEnabled())
		self._janitor:Add(p3.onEnabledChanged:Connect(function(enabled: boolean)
			setVfxEnabled(clone, enabled)
		end))
	end

	self._janitor:Add(p2.Stopped:Connect(function()
		self._janitor:Cleanup()
	end))
end

return FlareWaveEmote