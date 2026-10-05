local Net = require(game.ReplicatedStorage.Modules.Net)
return {
	OnStart = function()
		local remoteFunction = Net:RemoteFunction("SynchronizedTeleport")

		remoteFunction.OnClientInvoke = function(instance, cFrame, flag: boolean?)
			if flag then
				local currentCamera = workspace.CurrentCamera
				local parent = instance.Parent

				if game.Players:GetPlayerFromCharacter(parent) then
					local objectSpace = instance.CFrame:ToObjectSpace(currentCamera.CFrame)
					instance.CFrame = cFrame
					currentCamera.CFrame = instance.CFrame:ToWorldSpace(objectSpace)
				else
					instance.CFrame = cFrame
				end
			else
				instance.CFrame = cFrame
			end

			return true
		end
	end
}