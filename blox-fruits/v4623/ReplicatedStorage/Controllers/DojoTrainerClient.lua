local Net = require(game.ReplicatedStorage.Modules.Net)
return {
	OnStart = function(_)
		Net:RemoteEvent("DragonDojoEmber").OnClientEvent:Connect(function(data)
			local character = game.Players.LocalPlayer.Character
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")

			if not (character and humanoid) then
				return
			end

			if data.Context == "SpawnEmber" then
				for i = 1, #data.Embers do
					local ember = data.Embers[i]
					local Effect = require(game.ReplicatedStorage.Effect)
					Effect.new("Ember"):play({
						Stamina = 1,
						Expires = data.Expires,
						CurrentRunAwaySpeed = 0.9,
						MinRunAwaySpeed = 0.2,
						MaxRunAwaySpeed = 0.9,
						IdleDistance = 250,
						ChaseDistance = 500,
						Region = "DragonDojo",
						Context = "BlazeEmber",
						Character = character,
						Humanoid = humanoid,
						CFrame = ember,
						Touched = function(instance)
							instance:Destroy()
							Net:RemoteEvent("DragonDojoEmber"):FireServer()
						end,
						Color = Color3.new(1, 0.333333, 0)
					})
				end
			end
		end)
	end
}