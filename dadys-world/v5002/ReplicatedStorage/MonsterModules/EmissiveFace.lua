local EmissiveFace = {}
EmissiveFace.__index = EmissiveFace

function EmissiveFace.new(instance, list)
	local config = instance:FindFirstChild("Config")
	local normal = config and config:FindFirstChild("Normal")

	if not (normal and normal:IsA("SurfaceAppearance")) then
		return nil
	end

	local blink = config:FindFirstChild("Blink")
	local attack = config:FindFirstChild("Attack")
	local blink2

	if blink and blink:IsA("SurfaceAppearance") then
		blink2 = blink or normal
	else
		blink2 = normal
	end

	local v = {
		Normal = normal,
		Blink = blink2,
		Attack = 0
	}

	if attack and attack:IsA("SurfaceAppearance") then
		normal = attack or normal
	end

	v.Attack = normal
	local object = setmetatable({}, EmissiveFace)
	object.stash = config
	object.heads = {}

	for i, part in ipairs(list) do
		if not part then
			continue
		end

		for _, surfaceAppearance in part:GetChildren() do
			if surfaceAppearance:IsA("SurfaceAppearance") then
				surfaceAppearance.Parent = config
			end
		end

		local v4 = {
			part = part,
			active = nil
		}

		for _, name in ipairs({ "Normal", "Blink", "Attack" }) do
			local v6 = i == 1 and v[name] or v[name]:Clone()

			if i > 1 then
				v6.Name = name
				v6.Parent = config
			end

			v4[name] = v6
		end

		table.insert(object.heads, v4)
	end

	if #object.heads == 0 then
		return nil
	end

	return object
end

function EmissiveFace:set(p2)
	for _, head in ipairs(self.heads) do
		local active

		if p2 then
			active = head[p2] or nil
		end

		if head.active == active then
			continue
		end

		if active then
			active.Parent = head.part
		end

		if head.active and head.active ~= active then
			head.active.Parent = self.stash
		end

		head.active = active
	end
end

function EmissiveFace:Destroy()
	self:set(nil)
end

return EmissiveFace