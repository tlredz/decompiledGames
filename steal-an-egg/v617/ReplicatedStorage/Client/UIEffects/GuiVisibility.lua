local Players = game:GetService("Players")
local v = {}
local v2 = {}

function v.IsVisible(parent, ancestor, p)
	if not parent:IsDescendantOf(ancestor) or p ~= nil and p.Disabled then
		return false
	end

	while parent ~= nil and parent ~= ancestor do
		if parent:IsA("GuiObject") and not parent.Visible then
			return false
		end

		if parent:IsA("LayerCollector") and not parent.Enabled then
			return false
		else
			parent = parent.Parent
		end
	end

	return parent == ancestor
end

function v.Watch(instance, callback, instance2, p)
	local v3 = p or Players.LocalPlayer:WaitForChild("PlayerGui")

	if instance2 ~= nil and v2[instance2] ~= nil then
		v2[instance2].Destroy()
	end

	local bindableEvent = Instance.new("BindableEvent")
	local connections = {}
	local connections2 = {}
	local flag = true
	local v4 = false
	local v5 = nil

	-- equivalent calls inferred from this helper; original call sites unknown
	local function publish(isVisible: boolean)
		if v4 == isVisible then
			return
		end

		v4 = isVisible
		bindableEvent:Fire()

		if callback ~= nil then
			callback(v4)
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function evaluate()
		if flag then
			publish(v.IsVisible(instance, v3, instance2)) -- equivalent call inferred; original call site unknown
		end
	end

	local function rebuild()
		for _, connection in connections do
			connection:Disconnect()
		end

		table.clear(connections)
		local parent = instance

		while parent ~= nil and parent ~= v3 do
			if parent:IsA("GuiObject") then
				table.insert(connections, parent:GetPropertyChangedSignal("Visible"):Connect(evaluate))
			elseif parent:IsA("LayerCollector") then
				table.insert(connections, parent:GetPropertyChangedSignal("Enabled"):Connect(evaluate))
			end

			parent = parent.Parent
		end

		evaluate() -- equivalent call inferred; original call site unknown
	end

	v5 = {
		IsVisible = function()
			return flag and v4
		end,
		WaitUntilVisible = function()
			while flag and not v4 do
				bindableEvent.Event:Wait()
			end

			return flag
		end,
		Destroy = function()
			if not flag then
				return
			end

			flag = false

			for _, connection in connections do
				connection:Disconnect()
			end

			for _, connection in connections2 do
				connection:Disconnect()
			end

			table.clear(connections)
			table.clear(connections2)

			if instance2 ~= nil and v2[instance2] == v5 then
				v2[instance2] = nil
			end

			publish(false) -- equivalent call inferred; original call site unknown
			bindableEvent:Fire()
			task.defer(function()
				bindableEvent:Destroy()
			end)
		end
	}

	if instance2 ~= nil then
		v2[instance2] = v5
		table.insert(connections2, instance2:GetPropertyChangedSignal("Enabled"):Connect(evaluate))
		table.insert(connections2, instance2.Destroying:Connect(v5.Destroy))
	end

	table.insert(connections2, instance.AncestryChanged:Connect(rebuild))
	table.insert(connections2, instance.Destroying:Connect(v5.Destroy))
	rebuild()
	return v5
end

return table.freeze(v)