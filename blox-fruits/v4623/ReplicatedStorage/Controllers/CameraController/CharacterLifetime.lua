return {
	bind = function(instance, player)
		local character = player.Character

		if not character then
			return
		end

		instance._maid:GiveTask(player.CharacterRemoving:Connect(function(character2)
			if character2 == character then
				instance:Destroy()
			end
		end))
		local humanoid = character:FindFirstChildOfClass("Humanoid")

		if humanoid then
			instance._maid:GiveTask(humanoid.Died:Connect(function()
				instance:Destroy()
			end))

			if humanoid.Health <= 0 then
				instance:Destroy()
			end
		end
	end
}