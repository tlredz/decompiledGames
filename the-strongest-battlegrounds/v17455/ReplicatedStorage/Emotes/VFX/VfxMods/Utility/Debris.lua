local Debris = {
	Removing = {}
}

function Debris.AddItem(_, instance, duration: number)
	Debris.Removing[instance] = true
	task.delay(duration, function()
		if not (instance.Parent and Debris.Removing[instance]) then
			return
		end

		Debris.Removing[instance] = nil
		instance:Destroy()
	end)
end

return Debris