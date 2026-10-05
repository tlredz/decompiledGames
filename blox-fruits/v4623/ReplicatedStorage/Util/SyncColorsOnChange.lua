local ColorShiftObjectDescendants = require(game.ReplicatedStorage.Util.ColorShiftObjectDescendants)
local v = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function disconnectAll(list)
	for _, connection in list do
		connection:Disconnect()
	end

	table.clear(list)
end

local function isRemoved(p)
	return p.Parent == nil
end

local function syncColorsOnChange(instance, sourcePlayer, childName: string)
	if typeof(sourcePlayer) ~= "Instance" then
		if type(sourcePlayer) == "table" then
			sourcePlayer = sourcePlayer.SourcePlayer or sourcePlayer.Character
		else
			sourcePlayer = nil
		end
	end

	if typeof(sourcePlayer) ~= "Instance" or sourcePlayer.Parent == nil or v[instance] then
		return nil
	end

	local connections = {}
	local connections2 = {}
	local flag = true
	local flag2 = false
	local v2 = {}

	-- equivalent calls inferred from this helper; original call sites unknown
	local function disconnect()
		if not flag then
			return
		end

		flag = false
		disconnectAll(connections) -- equivalent call inferred; original call site unknown
		disconnectAll(connections2) -- equivalent call inferred; original call site unknown
		v[instance] = nil
	end

	local function checkAncestry()
		if instance.Parent == nil or sourcePlayer.Parent == nil then
			disconnect() -- equivalent call inferred; original call site unknown
		end
	end

	local function scheduleRecolor()
		if flag and not flag2 then
			flag2 = true
			task.delay(0.1, function()
				flag2 = false

				if (instance.Parent == nil or sourcePlayer.Parent == nil) and flag then
					flag = false
					disconnectAll(connections) -- equivalent call inferred; original call site unknown
					disconnectAll(connections2) -- equivalent call inferred; original call site unknown
					v[instance] = nil
				end

				if not flag then
					return
				end

				local child = sourcePlayer:FindFirstChild(childName)

				if child and child:FindFirstChild("Default") and child:FindFirstChild("Shifted") then
					ColorShiftObjectDescendants(instance, sourcePlayer, childName, v2)
				end
			end)
		end
	end

	local bindPalette

	bindPalette = function()
		disconnectAll(connections2) -- equivalent call inferred; original call site unknown

		if not flag then
			return
		end

		local child = sourcePlayer:FindFirstChild(childName)

		if not child then
			return
		end

		local function onPaletteChildChanged(p)
			if p.Name == "Default" or p.Name == "Shifted" then
				bindPalette()
			end
		end

		table.insert(connections2, child.ChildAdded:Connect(onPaletteChildChanged))
		table.insert(connections2, child.ChildRemoved:Connect(onPaletteChildChanged))
		table.insert(connections2, child:GetAttributeChangedSignal("PaletteVersion"):Connect(scheduleRecolor))

		for _, childName2 in { "Default", "Shifted" } do
			local child2 = child:FindFirstChild(childName2)

			if child2 then
				table.insert(connections2, child2.AttributeChanged:Connect(scheduleRecolor))
			end
		end

		if flag then
			if flag2 then
				return
			end

			flag2 = true
			task.delay(0.1, function()
				flag2 = false

				if (instance.Parent == nil or sourcePlayer.Parent == nil) and flag then
					flag = false
					disconnectAll(connections) -- equivalent call inferred; original call site unknown
					disconnectAll(connections2) -- equivalent call inferred; original call site unknown
					v[instance] = nil
				end

				if not flag then
					return
				end

				local child2 = sourcePlayer:FindFirstChild(childName)

				if child2 and child2:FindFirstChild("Default") and child2:FindFirstChild("Shifted") then
					ColorShiftObjectDescendants(instance, sourcePlayer, childName, v2)
				end
			end)
		end
	end

	local function onOwnerChildChanged(p)
		if p.Name == childName then
			bindPalette()
		end
	end

	local function invalidateDescendants()
		v2.targets = nil
	end

	v[instance] = true
	table.insert(connections, sourcePlayer.ChildAdded:Connect(onOwnerChildChanged))
	table.insert(connections, sourcePlayer.ChildRemoved:Connect(onOwnerChildChanged))
	table.insert(connections, sourcePlayer.AncestryChanged:Connect(checkAncestry))
	table.insert(connections, instance.AncestryChanged:Connect(checkAncestry))
	table.insert(connections, instance.Destroying:Connect(disconnect))
	table.insert(connections, instance.DescendantAdded:Connect(invalidateDescendants))
	table.insert(connections, instance.DescendantRemoving:Connect(invalidateDescendants))
	bindPalette()
	return {
		Disconnect = function(self)
			if not flag then
				return
			end

			flag = false
			disconnectAll(connections) -- equivalent call inferred; original call site unknown
			disconnectAll(connections2) -- equivalent call inferred; original call site unknown
			v[instance] = nil
		end
	}
end

return syncColorsOnChange