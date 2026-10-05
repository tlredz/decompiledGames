require(game.ReplicatedStorage.MovesetTypes)
local RunService = game:GetService("RunService")
local Anims = require(game.ReplicatedStorage.Util.Anims)
Anims:Preload("GuitarZCharge")
Anims:Preload("GuitarZFire")
Anims:Preload("GuitarXCharge")
Anims:Preload("GuitarXFire")
return {
	setup = function(p)
		if not RunService:IsClient() then
			return
		end

		local events = game.ReplicatedStorage:FindFirstChild("Events")
		local shootSoulGuitar = events and events:FindFirstChild("ShootSoulGuitar")

		if shootSoulGuitar and shootSoulGuitar:IsA("BindableFunction") then
			function shootSoulGuitar.OnInvoke(vector: Vector3)
				if typeof(vector) ~= "Vector3" then
					return nil
				end

				p.remotes.event:FireServer(vector)
				return p.remotes.func:InvokeServer("TAP", vector)
			end
		end
	end
}