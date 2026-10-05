local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shake = require(ReplicatedStorage.Packages.Shake)
local Net = require(ReplicatedStorage.Packages.Net)
local ShakePresets = require(ReplicatedStorage.Shared.ShakePresets)
Net:RemoteEvent("CameraShakeService/Shake").OnClientEvent:Connect(function(items)
	local v = Shake.new()

	for k, item in pairs(items) do
		v[k] = item
	end

	ShakePresets.BindShakeToCamera(v, workspace.CurrentCamera)
	v:Start()
end)