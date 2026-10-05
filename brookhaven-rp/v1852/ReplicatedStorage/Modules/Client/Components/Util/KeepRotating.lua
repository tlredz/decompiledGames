local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "KeepRotating"
})

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	self.rotationSpeed = self.Instance:GetAttribute("RotationSpeed")
end

function v.RenderSteppedUpdate(p, _)
	if not p.rotationSpeed then
		return
	end

	local v2 = p.Instance:GetPrimaryPartCFrame() * p.rotationSpeed
	p.Instance:SetPrimaryPartCFrame(v2)
end

function v:Stop()
	self._Janitor:Destroy()
end

return v