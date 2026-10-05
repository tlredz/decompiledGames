local createVector = vector.create
local HandDebugGUI = {
	Enabled = false,
	TextSize = 12,
	MaxDistance = 100,
	RefreshRate = 0.2,
	BackgroundColor = Color3.fromRGB(0, 0, 0),
	BackgroundTransparency = 0.5,
	TextColors = {
		Default = Color3.fromRGB(255, 255, 255),
		Idle = Color3.fromRGB(0, 255, 0),
		Emerging = Color3.fromRGB(0, 200, 255),
		Attacking = Color3.fromRGB(255, 0, 0),
		Cooldown = Color3.fromRGB(255, 200, 0),
		Returning = Color3.fromRGB(150, 150, 150)
	},
	ActiveGUIs = {}
}

function HandDebugGUI.Create(parent, handData)
	if not (HandDebugGUI.Enabled and (parent and parent.Parent)) then
		return
	end

	if HandDebugGUI.ActiveGUIs[parent] then
		return HandDebugGUI.ActiveGUIs[parent]
	end

	local billboardGui = Instance.new("BillboardGui")
	billboardGui.Name = "DebugGUI"
	billboardGui.AlwaysOnTop = true
	billboardGui.Size = UDim2.new(0, 200, 0, 100)
	billboardGui.StudsOffset = createVector(0, 2, 0)
	billboardGui.MaxDistance = HandDebugGUI.MaxDistance
	billboardGui.Adornee = parent.PrimaryPart or parent:FindFirstChildOfClass("BasePart")
	local frame = Instance.new("Frame")
	frame.BackgroundColor3 = HandDebugGUI.BackgroundColor
	frame.BackgroundTransparency = HandDebugGUI.BackgroundTransparency
	frame.Size = UDim2.new(1, 0, 1, 0)
	frame.BorderSizePixel = 0
	frame.Parent = billboardGui
	local uIListLayout = Instance.new("UIListLayout")
	uIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	uIListLayout.VerticalAlignment = Enum.VerticalAlignment.Top
	uIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	uIListLayout.Padding = UDim.new(0, 2)
	uIListLayout.Parent = frame
	local textLabel = Instance.new("TextLabel")
	textLabel.BackgroundTransparency = 1
	textLabel.Size = UDim2.new(1, 0, 0, 20)
	textLabel.Font = Enum.Font.SourceSansBold
	textLabel.TextSize = HandDebugGUI.TextSize + 2
	textLabel.TextColor3 = HandDebugGUI.TextColors.Default
	textLabel.Text = "BLOT HAND DEBUG"
	textLabel.LayoutOrder = 0
	textLabel.Parent = frame
	local textLabel2 = Instance.new("TextLabel")
	textLabel2.BackgroundTransparency = 1
	textLabel2.Size = UDim2.new(1, 0, 0, 18)
	textLabel2.Font = Enum.Font.SourceSans
	textLabel2.TextSize = HandDebugGUI.TextSize
	textLabel2.TextColor3 = HandDebugGUI.TextColors.Default
	textLabel2.Text = "State: Unknown"
	textLabel2.LayoutOrder = 1
	textLabel2.Parent = frame
	local textLabel3 = Instance.new("TextLabel")
	textLabel3.BackgroundTransparency = 1
	textLabel3.Size = UDim2.new(1, 0, 0, 18)
	textLabel3.Font = Enum.Font.SourceSans
	textLabel3.TextSize = HandDebugGUI.TextSize
	textLabel3.TextColor3 = HandDebugGUI.TextColors.Default
	textLabel3.Text = "Target: None"
	textLabel3.LayoutOrder = 2
	textLabel3.Parent = frame
	local textLabel4 = Instance.new("TextLabel")
	textLabel4.BackgroundTransparency = 1
	textLabel4.Size = UDim2.new(1, 0, 0, 18)
	textLabel4.Font = Enum.Font.SourceSans
	textLabel4.TextSize = HandDebugGUI.TextSize
	textLabel4.TextColor3 = HandDebugGUI.TextColors.Default
	textLabel4.Text = "Players: 0"
	textLabel4.LayoutOrder = 3
	textLabel4.Parent = frame
	billboardGui.Parent = parent
	local v = {
		Billboard = billboardGui,
		StateLabel = textLabel2,
		TargetLabel = textLabel3,
		PlayersLabel = textLabel4,
		HandData = handData
	}
	HandDebugGUI.ActiveGUIs[parent] = v
	task.spawn(function()
		while task.wait(HandDebugGUI.RefreshRate) do
			if not HandDebugGUI.Enabled then
				HandDebugGUI.Remove(parent)
				break
			end

			if parent and parent.Parent then
				HandDebugGUI.Update(parent)
			else
				HandDebugGUI.Remove(parent)
				break
			end
		end
	end)
	return v
end

function HandDebugGUI.Update(p)
	local v = HandDebugGUI.ActiveGUIs[p]

	if not (v and v.HandData) then
		return
	end

	local handData = v.HandData
	local state = handData.State or "Unknown"
	v.StateLabel.Text = "State: " .. state
	v.StateLabel.TextColor3 = HandDebugGUI.TextColors[state] or HandDebugGUI.TextColors.Default
	local text = not (handData.TargetPlayer and handData.TargetPlayer.Parent) and "Target: None" or "Target: " .. handData.TargetPlayer.Name
	v.TargetLabel.Text = text
	local count = 0
	local names = {}

	for k, _ in pairs(handData.PlayersInZone or {}) do
		if not (k and k.Parent) then
			continue
		end

		count += 1
		table.insert(names, k.Name)
	end

	local text2 = "Players: " .. count

	if count > 0 then
		text2 ..= " (" .. table.concat(names, ", ") .. ")"
	end

	v.PlayersLabel.Text = text2
end

function HandDebugGUI.Remove(p)
	local v = HandDebugGUI.ActiveGUIs[p]

	if not v then
		return
	end

	if v.Billboard and v.Billboard.Parent then
		v.Billboard:Destroy()
	end

	HandDebugGUI.ActiveGUIs[p] = nil
end

function HandDebugGUI.RemoveAll()
	for k, _ in pairs(HandDebugGUI.ActiveGUIs) do
		HandDebugGUI.Remove(k)
	end
end

function HandDebugGUI.Toggle()
	HandDebugGUI.Enabled = not HandDebugGUI.Enabled

	if not HandDebugGUI.Enabled then
		HandDebugGUI.RemoveAll()
	end

	return HandDebugGUI.Enabled
end

function HandDebugGUI.AddHandDebugGUI(parent)
	if not parent then
		return nil
	end

	print("Adding DebugGUI to: " .. parent:GetFullName())
	local v = parent:FindFirstChild("DebugData")

	if not v then
		v = Instance.new("Folder")
		v.Name = "DebugData"
		v:SetAttribute("State", parent:GetAttribute("HandState") or "Idle")
		v:SetAttribute("LastUpdate", tick())
		v:SetAttribute("PlayersInZone", 0)
		v.Parent = parent
		print("Created DebugData folder for hand")
	end

	local v2 = HandDebugGUI.Create(parent, {
		State = parent:GetAttribute("HandState") or "Idle",
		PlayersInZone = {},
		TargetPlayer = nil
	})
	task.spawn(function()
		while task.wait(HandDebugGUI.RefreshRate) and parent and parent.Parent and HandDebugGUI.Enabled and v and v.Parent do
			local v3 = HandDebugGUI.ActiveGUIs[parent]

			if not v3 then
				continue
			end

			local state = v:GetAttribute("State") or "Unknown"
			v3.StateLabel.Text = "State: " .. state
			v3.StateLabel.TextColor3 = HandDebugGUI.TextColors[state] or HandDebugGUI.TextColors.Default
			local targetPlayer = v:GetAttribute("TargetPlayer") or "None"
			v3.TargetLabel.Text = "Target: " .. targetPlayer
			local playersInZone = v:GetAttribute("PlayersInZone") or 0
			v3.PlayersLabel.Text = "Players in Zone: " .. playersInZone
		end
	end)
	return v2
end

return HandDebugGUI