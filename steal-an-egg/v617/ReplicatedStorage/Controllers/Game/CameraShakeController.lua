local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CameraShaker = require(ReplicatedStorage.Packages.CameraShaker)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local ShakeRequestData = require(ReplicatedStorage.Client.Types.ShakeRequestData)
return {
	Start = function()
		local v = CameraShaker.new()
		v:Start()
		Remotes.SharedFx.JoltOnce.OnClientEvent:Connect(function(data)
			assert(ShakeRequestData.SchemaValidation(data))
			v:ShakeOnce(
				data.Magnitude or 1,
				data.Roughness or 1,
				data.FadeInTime or 0,
				data.FadeOutTime or 0,
				data.PosInfluence,
				data.RotInfluence
			)
		end)
	end
}