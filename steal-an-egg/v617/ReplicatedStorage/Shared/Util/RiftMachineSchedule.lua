local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Environment = require(ReplicatedStorage.Shared.Modules.Environment)
local RiftFlags = require(ReplicatedStorage.Shared.Flags.RiftFlags)
local v = {
	TestDelayAttribute = "RiftMachineTestDelaySeconds",
	TestSwapAtAttribute = "RiftMachineTestSwapAtUnix",
	ActiveSwapAtAttribute = "RiftMachineActiveSwapAt",
	EmergencyLabAttribute = "RiftMachineEmergencyLab"
}

function v.GetSwapAt()
	if not RunService:IsStudio() then
		return RiftFlags.SwapAtUnix:Get()
	end

	local attribute = Workspace:GetAttribute(v.TestDelayAttribute)
	local attribute2 = Workspace:GetAttribute(v.ActiveSwapAtAttribute)
	local attribute3 = Workspace:GetAttribute(v.TestSwapAtAttribute)

	if (type(attribute) == "number" and attribute > 0 or type(attribute3) == "number") and type(attribute2) == "number" then
		return attribute2
	end

	return RiftFlags.SwapAtUnix:Get()
end

function v.IsLaboratoryTime()
	if Workspace:GetAttribute(v.EmergencyLabAttribute) == true then
		return true
	end

	if RunService:IsStudio() then
		local attribute = Workspace:GetAttribute(v.TestDelayAttribute)
		local attribute2 = Workspace:GetAttribute(v.TestSwapAtAttribute)

		if (type(attribute) ~= "number" or attribute <= 0) and type(attribute2) ~= "number" then
			return true
		end
	elseif Environment.GetEnvironmentName() == "test" or Environment.GetEnvironmentName() == "dev" then
		return true
	end

	return Workspace:GetServerTimeNow() >= v.GetSwapAt()
end

return table.freeze(v)