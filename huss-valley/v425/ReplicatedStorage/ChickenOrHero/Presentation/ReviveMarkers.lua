local createVector = vector.create
local ValleyPanels = require(script.Parent.ValleyPanels)
local ReviveMarkers = {}
ReviveMarkers.__index = ReviveMarkers

function ReviveMarkers.new(p)
	local object = setmetatable({
		folder = ValleyPanels.make("ScreenGui", p, "ReviveMarkers", {
			ResetOnSpawn = false,
			IgnoreGuiInset = true,
			ScreenInsets = Enum.ScreenInsets.None,
			ClipToDeviceSafeArea = false,
			DisplayOrder = 22
		}),
		records = {}
	}, ReviveMarkers)
	local RunService = game:GetService("RunService")
	object.render = RunService.RenderStepped:Connect(function()
		local currentCamera = workspace.CurrentCamera

		if not currentCamera then
			return
		end

		for _, record in object.records do
			if record.root and record.root.Parent then
				local worldToViewportPoint, v = currentCamera:WorldToViewportPoint(record.root.Position + createVector(
					0,
					3.4,
					0
				))
				record.gui.Visible = v and worldToViewportPoint.Z > 0
				record.gui.Position = UDim2.fromOffset(worldToViewportPoint.X, worldToViewportPoint.Y)
			else
				record.gui.Visible = false
			end
		end
	end)
	return object
end

function ReviveMarkers:create(p2, root)
	local gui = ValleyPanels.make("Frame", self.folder, "Revive", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		Size = UDim2.fromOffset(72, 68),
		ClipsDescendants = false,
		Visible = false,
		Active = false
	})
	local disc = ValleyPanels.make("Frame", gui, "Circle", {
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.fromScale(0.5, 0),
		Size = UDim2.fromOffset(35, 35),
		BackgroundColor3 = Color3.fromRGB(14, 39, 36),
		BackgroundTransparency = 0.36,
		BorderSizePixel = 0
	})
	ValleyPanels.corner(disc, 100)
	local ring = ValleyPanels.make("UIStroke", disc, "Ring", {
		Color = Color3.fromRGB(132, 238, 201),
		Thickness = 1.8,
		Transparency = 0.22
	})
	local bars = {}

	for _, v5 in { Vector2.new(17, 5), Vector2.new(5, 17) } do
		local v6 = ValleyPanels.make("Frame", disc, "Cross", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(v5.X, v5.Y),
			BackgroundColor3 = ring.Color,
			BackgroundTransparency = 0.1,
			BorderSizePixel = 0
		})
		ValleyPanels.corner(v6, 2)
		table.insert(bars, v6)
	end

	local text = ValleyPanels.text(gui, "Label", "REVIVE", 0, 39, 72, 17, 10, ring.Color)
	text.TextXAlignment = Enum.TextXAlignment.Center
	text.Font = Enum.Font.GothamBold
	text.TextStrokeTransparency = 0.45
	local v5 = {
		root = root,
		gui = gui,
		disc = disc,
		ring = ring,
		label = text,
		bars = bars
	}
	self.records[p2] = v5
	return v5
end

function ReviveMarkers:update(items, player, p)
	local v = {}
	local currentCamera = workspace.CurrentCamera

	if p and currentCamera then
		for _, item in items do
			local character = item.Character
			local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

			if not (character ~= player.Character and character and character.Parent and humanoidRootPart) then
				continue
			end

			if not (character:GetAttribute("RescueAvailable") == true and character:GetAttribute("Ragdolled") == true) then
				continue
			end

			local magnitude = (currentCamera.CFrame.Position - humanoidRootPart.Position).Magnitude

			if not (magnitude < 150) then
				continue
			end

			v[character] = true
			local v2 = self.records[character] or self:create(character, humanoidRootPart)
			v2.root = humanoidRootPart
			local rescueHelperId = character:GetAttribute("RescueHelperId")
			local color = rescueHelperId and Color3.fromRGB(239, 206, 137) or Color3.fromRGB(132, 238, 201)
			local v3 = math.clamp((magnitude - 80) / 70, 0, 1)
			v2.ring.Color = color
			v2.ring.Transparency = v3 * 0.65 + 0.22
			v2.disc.BackgroundTransparency = v3 * 0.5 + 0.36

			for _, bar in v2.bars do
				bar.BackgroundColor3 = color
				bar.BackgroundTransparency = v3 * 0.75 + 0.1
			end

			v2.label.Text = not rescueHelperId and "REVIVE" or rescueHelperId == player.UserId and "REVIVING" or "HELPING"
			v2.label.TextColor3 = color
			v2.label.TextTransparency = v3 * 0.85
			v2.label.TextStrokeTransparency = v3 * 0.5 + 0.45
		end
	end

	for k, record in self.records do
		if v[k] then
			continue
		end

		record.gui:Destroy()
		self.records[k] = nil
	end
end

function ReviveMarkers.destroy(data)
	data.render:Disconnect()
	data.folder:Destroy()
	table.clear(data.records)
end

return ReviveMarkers