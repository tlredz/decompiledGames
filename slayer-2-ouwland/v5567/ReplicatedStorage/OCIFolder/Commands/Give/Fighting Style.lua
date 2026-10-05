return function(p, p2)
	if p then
		local child = game.ReplicatedStorage.Player_Service.Data:FindFirstChild(p.Name)

		if child == nil then
			return
		end

		local child2 = child.slots:FindFirstChild("Slot" .. child.slotEquipped.Value)

		if child2 == nil then
			return
		end

		local powers = child2:FindFirstChild("Powers")

		if powers == nil then
			return
		end

		local fightingStyle = powers:FindFirstChild("FightingStyle")

		if fightingStyle == nil then
			return
		else
			fightingStyle.Value = p2
		end
	end
end