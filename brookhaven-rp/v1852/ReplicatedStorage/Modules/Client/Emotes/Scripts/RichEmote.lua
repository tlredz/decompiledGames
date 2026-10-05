local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BasePartUtil = require(ReplicatedStorage.Modules.Shared.Utils.BasePartUtil)
local EmoteVfxScale = require(ReplicatedStorage.Modules.Client.Emotes.EmoteVfxScale)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local RichEmote = {}
RichEmote.__index = RichEmote

function RichEmote.new()
	return (setmetatable({
		_janitor = Janitor.new()
	}, RichEmote))
end

function RichEmote:start(parent, object)
	local clone = ReplicatedStorage:FindFirstChild("Emotes"):FindFirstChild("Rich"):Clone()
	clone.Parent = parent
	EmoteVfxScale.scaleToCharacterWorldScale(clone, parent)
	local rightHand = parent:WaitForChild("RightHand")
	local v = BasePartUtil.MoveModelAndWeld(clone, clone:WaitForChild("Handle"), rightHand)
	self._janitor:Add(v)
	self._janitor:Add(clone)
	self._janitor:Add(object:GetMarkerReachedSignal("MoneyTransparency0"):Connect(function(_)
		for _, descendant in clone:GetDescendants() do
			if not ((descendant:IsA("BasePart") or descendant:IsA("Decal")) and descendant.Name ~= "Handle") then
				continue
			end

			descendant.Transparency = 0
		end
	end))
	self._janitor:Add(object:GetMarkerReachedSignal("MoneyTransparency1"):Connect(function(_)
		self._janitor:Cleanup()
	end))
	self._janitor:Add(object.Stopped:Connect(function()
		self._janitor:Cleanup()
	end))
end

return RichEmote