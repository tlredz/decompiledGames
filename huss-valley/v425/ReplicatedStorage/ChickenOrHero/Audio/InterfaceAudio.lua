local InterfaceAudio = {}
InterfaceAudio.__index = InterfaceAudio

function InterfaceAudio.new(object, folder)
	local object2 = setmetatable({
		buttons = {},
		panels = {},
		connections = {}
	}, InterfaceAudio)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function belongs(guiObject)
		local layerCollector = guiObject:FindFirstAncestorWhichIsA("LayerCollector")
		return layerCollector and (layerCollector.Name == "Notifications" or layerCollector.Name == "HUD" or layerCollector:GetAttribute("UseGameAudio") == true)
	end

	local function add(guiObject)
		if guiObject:IsA("GuiButton") and belongs(guiObject) and not object2.buttons[guiObject] then
			object2.buttons[guiObject] = { guiObject.MouseEnter:Connect(function()
					if guiObject.Visible then
						object:one("Hover")
					end
				end), guiObject.SelectionGained:Connect(function()
					if guiObject.Visible then
						object:one("Hover")
					end
				end), guiObject.Activated:Connect(function()
					object:one("Click")

					if guiObject.Parent and guiObject.Parent.Name == "Options" then
						object:one("ChoiceSubmitted")
					end
				end) }
		elseif guiObject:IsA("Frame") and guiObject.Name == "Choices" and belongs(guiObject) and not object2.panels[guiObject] then
			local visible = guiObject.Visible
			object2.panels[guiObject] = guiObject:GetPropertyChangedSignal("Visible"):Connect(function()
				if guiObject.Visible ~= visible then
					visible = guiObject.Visible
					object:one(visible and "PanelOpen" or "PanelClose")
				end
			end)
		end
	end

	local function remove(p)
		if object2.buttons[p] then
			for _, connection in object2.buttons[p] do
				connection:Disconnect()
			end

			object2.buttons[p] = nil
		end

		if object2.panels[p] then
			object2.panels[p]:Disconnect()
			object2.panels[p] = nil
		end
	end

	object2.remove = remove
	table.insert(object2.connections, folder.DescendantAdded:Connect(add))
	table.insert(object2.connections, folder.DescendantRemoving:Connect(remove))

	for _, descendant in folder:GetDescendants() do
		add(descendant)
	end

	return object2
end

function InterfaceAudio.destroy(data)
	for _, connection in data.connections do
		connection:Disconnect()
	end

	for k in data.buttons do
		data.remove(k)
	end

	for k in data.panels do
		data.remove(k)
	end
end

return InterfaceAudio