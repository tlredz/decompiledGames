local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local BasePartUtil = require(ReplicatedStorage.Modules.Shared.Utils.BasePartUtil)
local ModelUtil = require(ReplicatedStorage.Modules.Shared.Utils.ModelUtil)
local ZipLineConstants = require(ReplicatedStorage.Modules.Shared.World.ZipLineConstants)
local v = Component.new({
	Tag = ZipLineConstants.HANDLE_TAG
})

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	local instance = self.Instance

	if self.Instance:IsA("Player") then
		instance = self.Instance.Character

		if instance == nil then
			return
		end
	end

	local humanoidRootPart = instance:WaitForChild("HumanoidRootPart")
	local clone = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Misc"):WaitForChild("ZipLineHandle"):Clone()
	local v2 = humanoidRootPart.CFrame - humanoidRootPart.Position
	local humanoid = instance:WaitForChild("Humanoid")
	local hipHeight = humanoid and humanoid.HipHeight or 2
	clone:PivotTo(CFrame.new(
		humanoidRootPart.Position.X,
		humanoidRootPart.Position.Y + hipHeight + 0.3,
		humanoidRootPart.Position.Z
	) * v2)
	clone.Parent = humanoidRootPart
	ModelUtil.unanchor(clone)
	ModelUtil.weld(clone)
	local primaryPart = clone.PrimaryPart

	if primaryPart ~= nil then
		BasePartUtil.weld(primaryPart, humanoidRootPart, clone, "WeldConstraint")
	end

	clone:WaitForChild("Handle"):WaitForChild("Sound"):Play()
	self._Janitor:Add(clone)
	self._Janitor:Add(task.delay(90, function()
		clone:Destroy()
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v