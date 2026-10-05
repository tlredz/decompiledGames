local opeOpe = game.ReplicatedStorage.EffectContainer:FindFirstChild("Ope-Ope")

if opeOpe then
	local room = opeOpe:FindFirstChild("Room")
	local create = room and room:FindFirstChild("Create")

	if create then
		require(create)
	end
end

require(game.ReplicatedStorage["Ope-Ope"].Modules.Session)