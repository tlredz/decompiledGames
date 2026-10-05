local UI_EmitterModule = require(game.ReplicatedStorage.UI_EmitterModule)

for _, emitter in pairs(game.Players.LocalPlayer.PlayerGui:GetDescendants()) do
	if emitter:IsA("ParticleEmitter") then
		UI_EmitterModule:AddEmitter(emitter, 1)
	end
end

game.Players.LocalPlayer.PlayerGui.DescendantAdded:Connect(function(emitter)
	if emitter:IsA("ParticleEmitter") then
		UI_EmitterModule:AddEmitter(emitter, 1)
	end
end)
game.Players.LocalPlayer.PlayerGui.DescendantRemoving:Connect(function(emitter)
	if emitter:IsA("ParticleEmitter") then
		UI_EmitterModule:RemoveEmitter(emitter)
	end
end)