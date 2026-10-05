local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "OrientPartToVelocity"
})

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	local instance = self.Instance
	self._Janitor:Add(RunService.RenderStepped:Connect(function(_)
		local assemblyLinearVelocity = instance.AssemblyLinearVelocity

		if assemblyLinearVelocity.Magnitude > 0 then
			instance.CFrame = CFrame.lookAt(instance.Position, instance.Position + assemblyLinearVelocity)
		end
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v