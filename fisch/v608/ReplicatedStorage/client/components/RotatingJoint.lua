local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local packages = ReplicatedStorage.packages
local Component = require(packages.Component)
local Trove = require(packages.Trove)
local v = Component.new({
	Tag = "RotatingJoint",
	Ancestors = { workspace }
})

function v:Construct()
	self.Trove = Trove.new()
	self.CurrentTransform = CFrame.identity
end

function v.Start(data)
	local jointRotationSpeed = data.Instance:GetAttribute("JointRotationSpeed")
	local X = math.rad(jointRotationSpeed.X)
	local Y = math.rad(jointRotationSpeed.Y)
	local Z = math.rad(jointRotationSpeed.Z)
	data.Trove:Connect(data.Instance:GetAttributeChangedSignal("JointRotationSpeed"), function()
		jointRotationSpeed = data.Instance:GetAttribute("JointRotationSpeed")
		local X2 = math.rad(jointRotationSpeed.X)
		local Y2 = math.rad(jointRotationSpeed.Y)
		local Z2 = math.rad(jointRotationSpeed.Z)
		X = X2
		Y = Y2
		Z = Z2
	end)
	data.Trove:Connect(RunService.RenderStepped, function(p)
		data.CurrentTransform *= CFrame.fromOrientation(X * p, Y * p, Z * p)
		data.Instance.Transform = data.CurrentTransform
	end)
end

function v.Stop(p)
	p.Trove:Clean()
end

return v