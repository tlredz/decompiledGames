local WeldSpawner = {}
local v = {}

function WeldSpawner.createWeld(p, part, value: string?, duration: number?)
	local weldConstraint = Instance.new("WeldConstraint")
	weldConstraint.Part0 = p
	weldConstraint.Part1 = part
	weldConstraint.Name = value or "VFXWeld"
	weldConstraint.Parent = p
	table.insert(v, weldConstraint)

	if duration and duration > 0 then
		task.delay(duration, function()
			WeldSpawner.destroyWeld(weldConstraint)
		end)
	end

	return weldConstraint
end

function WeldSpawner.createAdvancedWeld(p, part, cframe: CFrame?, value: string?, duration: number?)
	if cframe then
		part.CFrame = p.CFrame * cframe
	end

	local weldConstraint = Instance.new("WeldConstraint")
	weldConstraint.Part0 = p
	weldConstraint.Part1 = part
	weldConstraint.Name = value or "AdvancedVFXWeld"
	weldConstraint.Parent = p
	table.insert(v, weldConstraint)

	if duration and duration > 0 then
		task.delay(duration, function()
			WeldSpawner.destroyWeld(weldConstraint)
		end)
	end

	return weldConstraint
end

function WeldSpawner.destroyWeld(weldConstraint)
	if weldConstraint and weldConstraint:IsA("WeldConstraint") and weldConstraint.Parent then
		local index = table.find(v, weldConstraint)

		if index then
			table.remove(v, index)
		end

		weldConstraint:Destroy()
	end
end

function WeldSpawner.destroyAllVFXWelds()
	for i = #v, 1, -1 do
		local weldConstraint = v[i]

		if weldConstraint and weldConstraint:IsA("WeldConstraint") and weldConstraint.Parent then
			WeldSpawner.destroyWeld(weldConstraint)
		end
	end

	table.clear(v)
end

return WeldSpawner