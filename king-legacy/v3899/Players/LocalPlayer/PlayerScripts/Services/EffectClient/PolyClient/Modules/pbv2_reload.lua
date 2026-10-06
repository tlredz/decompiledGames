local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("TweenService")
return function(p)
	local arms_cf = p.arms_cf
	local _ = game.Players.LocalPlayer
	local count = 0

	for _, child in pairs(workspace.Effects:GetChildren()) do
		if child.Name == "bullet_fx" then
			count += 1
		end
	end

	if count > 24 then
		return
	end

	for _, v in pairs(arms_cf) do
		local cFrame = v
		task.spawn(function()
			for i = 1, 2 do
				local clone = ReplicatedStorage.Chest.SwordEffect.PhoenixBlade.V2.bullet_fx:Clone()
				_G.PU:Dust(clone, 2)
				clone.CFrame = cFrame
				clone.Parent = workspace.Effects
				wait()
			end
		end)
	end
end