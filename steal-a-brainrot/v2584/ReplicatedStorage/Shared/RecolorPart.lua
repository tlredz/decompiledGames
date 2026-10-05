local function RecolorOne(instance, color: Color3)
	if instance:GetAttribute("__RECOLOR") ~= false then
		if instance:IsA("BasePart") then
			instance.Color = color
		elseif instance:IsA("SurfaceAppearance") then
			instance.Color = color
		elseif instance:IsA("Highlight") then
			instance.FillColor = color
			instance.OutlineColor = color
		elseif instance:IsA("ParticleEmitter") then
			instance.Color = ColorSequence.new(color)
		end
	end
end

local RecolorPart

RecolorPart = function(instance, color: Color3)
	RecolorOne(instance, color)

	for _, child in ipairs(instance:GetChildren()) do
		RecolorPart(child, color)
	end
end

return (setmetatable({
	track = function(folder)
		local v = {}
		local v2 = {}
		local v3 = {}
		local v4 = {}
		local v5 = {}

		local function add(instance)
			if instance:GetAttribute("__RECOLOR") == false then
				return
			end

			local instances = nil

			if instance:IsA("BasePart") then
				instances = v
			elseif instance:IsA("SurfaceAppearance") then
				instances = v2
			elseif instance:IsA("Highlight") then
				instances = v3
			elseif instance:IsA("ParticleEmitter") then
				instances = v4
			end

			if instances then
				v5[instance] = instances
				table.insert(instances, instance)
			end
		end

		local function remove(p)
			local v6 = v5[p]

			if not v6 then
				return
			end

			v5[p] = nil
			local index = table.find(v6, p)

			if index then
				table.remove(v6, index)
			end
		end

		add(folder)

		for _, descendant in folder:GetDescendants() do
			add(descendant)
		end

		local descendantAddedConnection = folder.DescendantAdded:Connect(add)
		local descendantRemovingConnection = folder.DescendantRemoving:Connect(remove)
		return {
			Recolor = function(_, color: Color3)
				for _, v6 in v do
					v6.Color = color
				end

				for _, v6 in v2 do
					v6.Color = color
				end

				for _, v6 in v3 do
					v6.FillColor = color
					v6.OutlineColor = color
				end

				if #v4 > 0 then
					local colorSequence = ColorSequence.new(color)

					for _, v6 in v4 do
						v6.Color = colorSequence
					end
				end
			end,
			Destroy = function(_)
				descendantAddedConnection:Disconnect()
				descendantRemovingConnection:Disconnect()
				table.clear(v5)
				table.clear(v)
				table.clear(v2)
				table.clear(v3)
				table.clear(v4)
			end
		}
	end
}, {
	__call = function(_, p, color: Color3)
		RecolorPart(p, color)
	end
}))