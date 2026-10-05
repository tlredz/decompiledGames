local Debris = {
	Removing = {}
}

function Debris.AddItem(_, instance, duration: number)
	Debris.Removing[instance] = true
	task.delay(duration, function()
		if not (instance:IsDescendantOf(game) and Debris.Removing[instance]) then
			return
		end

		Debris.Removing[instance] = nil
		instance:Destroy()
	end)
end

function Debris.RemoveItem(_, p)
	if not Debris.Removing[p] then
		return
	end

	Debris.Removing[p] = nil
end

return Debris