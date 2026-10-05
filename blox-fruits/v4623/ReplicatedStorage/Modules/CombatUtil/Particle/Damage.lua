local effectContainer = game.ReplicatedStorage:FindFirstChild("EffectContainer")

if effectContainer and effectContainer:FindFirstChild("Container") and effectContainer.Container:FindFirstChild("Misc") and effectContainer.Container.Misc:FindFirstChild("Damage") then
	return require(effectContainer.Container.Misc.Damage)
end

return {}