game:GetService("RunService")
local HighlightGroup = {}
HighlightGroup.__index = HighlightGroup
local v = {}

function HighlightGroup.new(script, _WorldOrigin, name)
	if not script then
		warn("HighlightGroup: Highlight instance does not exist.")
		return
	end

	if script:IsA("Script") then
		local parent = script.Parent
		script.Parent = workspace
		script.Disabled = true
		script.Disabled = false
		local value = script.SpawnedHighlight.Value
		_ = script:Destroy()
		value:SetAttribute("proxyhighlight", true)
		value.Parent = parent
		script = value
	end

	script.Enabled = false
	local clone = script:Clone()
	local model = Instance.new("Model")
	clone.Parent = model

	if name then
		if v[name] then
			return v[name]
		end

		model.Name = name
		_WorldOrigin = workspace._WorldOrigin
	end

	model.Parent = _WorldOrigin
	local object = setmetatable({
		ID = name,
		HighlightObject = clone,
		Model = model,
		SuperParent = _WorldOrigin
	}, HighlightGroup)
	local childRemovedConnection = nil
	clone.Destroying:Once(function()
		model.Name = "DESTROYING"

		if childRemovedConnection then
			childRemovedConnection:Disconnect()
		end

		object:Destroy()
	end)

	if name then
		v[name] = object
		childRemovedConnection = model.ChildRemoved:Connect(function()
			if #model:GetChildren() == 1 then
				task.delay(2, function()
					if #model:GetChildren() == 1 then
						model.Name = "DESTROYING"
						childRemovedConnection:Disconnect()
						object:Destroy()
					end
				end)
			end
		end)
	end

	return object
end

function HighlightGroup.Insert(p, instance, duration, instance2)
	local model = p.Model

	if not model then
		warn("HighlightGroup: Model no longer exists")
		return
	end

	instance.Parent = model
	local v2 = false

	if instance2 then
		instance2.Destroying:Once(function()
			v2 = true
			instance:Destroy()
		end)
	end

	if duration then
		task.delay(duration, function()
			if not v2 and instance:IsDescendantOf(workspace) then
				instance.Parent = instance2 or p.SuperParent
			end
		end)
	end
end

function HighlightGroup.Remove(p, instance)
	local model = p.Model

	if not model then
		warn("HighlightGroup: Model no longer exists")
	elseif instance:IsDescendantOf(model) then
		instance.Parent = p.SuperParent
	end
end

function HighlightGroup:Destroy()
	if v[self.ID] then
		v[self.ID] = nil
	end

	if self.Model:IsDescendantOf(workspace) then
		self.Model:Destroy()
	end

	if self.HighlightObject:IsDescendantOf(workspace) then
		self.HighlightObject:Destroy()
	end

	self.SuperParent = nil
end

return HighlightGroup