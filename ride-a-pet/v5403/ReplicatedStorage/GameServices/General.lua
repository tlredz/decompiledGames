local General = {}

function General.GiveItem(_, player, instance, value)
	if not instance then
		warn(string.format("General:GiveItem called with no Item for %s", player and player.Name or "?"))
		return nil
	end

	local v = value or 1
	local character = player.Character
	local backpack = player:FindFirstChildOfClass("Backpack")

	if not backpack then
		return nil
	end

	local clone = character and character:FindFirstChild(instance.Name) or backpack:FindFirstChild(instance.Name)

	if v < 0 then
		local data = clone and clone:FindFirstChild("Data")
		local amount = data and data:FindFirstChild("Amount")

		if not amount or amount.Value < -v then
			return nil
		end
	end

	if not clone then
		clone = instance:Clone()

		for _, part in clone:GetDescendants() do
			if not part:IsA("BasePart") then
				continue
			end

			part.CanCollide = false
			part.Anchored = false
			part.Massless = true
		end

		local clone_2 = script:WaitForChild("Data"):Clone()
		clone_2.Parent = clone
		clone.Parent = backpack
	end

	local amount = clone:WaitForChild("Data"):WaitForChild("Amount")
	amount.Value = math.clamp(amount.Value + v, 0, 1e999)
	local value2 = amount.Value

	if value2 <= 0 then
		clone:Destroy()
	end

	return value2
end

function General.GetPlot(_, p)
	local plots = workspace:FindFirstChild("Plots")

	if not plots then
		return nil
	end

	for _, child in plots:GetChildren() do
		local data = child:FindFirstChild("Data")
		local owner = data and data:FindFirstChild("Owner")

		if owner and owner.Value == p then
			return child
		end
	end

	return nil
end

return General