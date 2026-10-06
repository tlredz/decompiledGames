local createVector = vector.create
game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local IdentityLayer = {}
IdentityLayer.__index = IdentityLayer
local v = {}

function IdentityLayer.new(ctx)
	local object = setmetatable({}, IdentityLayer)
	object._ctx = ctx
	object.rootFolder = ctx.rootFolder
	object.markers = {}
	object.currentMatchPlayers = nil
	object.localParticipantSlotId = nil
	object.identityMarkersVisible = false
	object.isLocalParticipant = false
	object.participantTableState = "Idle"
	return object
end

function IdentityLayer.rebuildMarker(p, p2: string, p3)
	local billboardGui = Instance.new("BillboardGui")
	billboardGui.Name = "IdentityBillboard"
	billboardGui.Adornee = p3
	billboardGui.AlwaysOnTop = true
	billboardGui.LightInfluence = 0
	billboardGui.Size = UDim2.fromScale(4.6, 2.9)
	billboardGui.StudsOffset = createVector(0, 3.5, 0)
	billboardGui.Enabled = false
	billboardGui.Parent = p3
	local frame = Instance.new("Frame")
	frame.Name = "IdentityFrame"
	frame.BackgroundTransparency = 1
	frame.Size = UDim2.fromScale(1, 1)
	frame.Parent = billboardGui
	local uIListLayout = Instance.new("UIListLayout")
	uIListLayout.FillDirection = Enum.FillDirection.Vertical
	uIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	uIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	uIListLayout.Padding = UDim.new(0.02, 0)
	uIListLayout.Parent = frame
	local imageLabel = Instance.new("ImageLabel")
	imageLabel.Name = "AvatarImage"
	imageLabel.BackgroundTransparency = 1
	imageLabel.Size = UDim2.fromScale(0.56, 0.56)
	imageLabel.ScaleType = Enum.ScaleType.Crop
	imageLabel.Visible = false
	imageLabel.Parent = frame
	local uICorner = Instance.new("UICorner")
	uICorner.CornerRadius = UDim.new(1, 0)
	uICorner.Parent = imageLabel
	local uIStroke = Instance.new("UIStroke")
	uIStroke.Color = Color3.fromRGB(240, 244, 255)
	uIStroke.Thickness = 1.4
	uIStroke.Transparency = 0.15
	uIStroke.Parent = imageLabel
	local textLabel = Instance.new("TextLabel")
	textLabel.Name = "IdentityText"
	textLabel.BackgroundTransparency = 1
	textLabel.Size = UDim2.fromScale(0.9, 0.46)
	textLabel.Font = Enum.Font.GothamBlack
	textLabel.TextScaled = true
	textLabel.TextWrapped = true
	textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	textLabel.TextStrokeTransparency = 0.25
	textLabel.TextStrokeColor3 = Color3.fromRGB(10, 12, 18)
	textLabel.Visible = false
	textLabel.Parent = frame
	local textLabel2 = Instance.new("TextLabel")
	textLabel2.Name = "ArrowText"
	textLabel2.BackgroundTransparency = 1
	textLabel2.Size = UDim2.fromScale(0.46, 0.22)
	textLabel2.Font = Enum.Font.GothamBlack
	textLabel2.TextScaled = true
	textLabel2.TextColor3 = Color3.fromRGB(255, 240, 190)
	textLabel2.TextStrokeTransparency = 0.2
	textLabel2.TextStrokeColor3 = Color3.fromRGB(10, 12, 18)
	textLabel2.Text = "▼"
	textLabel2.Parent = frame
	local v2 = {
		billboard = billboardGui,
		imageLabel = imageLabel,
		textLabel = textLabel,
		arrowLabel = textLabel2,
		requestId = 0
	}
	p.markers[p2] = v2
	return v2
end

function IdentityLayer:_hideIdentityMarkers()
	for _, marker in self.markers do
		marker.billboard.Enabled = false
		marker.imageLabel.Visible = false
		marker.textLabel.Visible = false
		marker.requestId += 1
	end
end

function IdentityLayer:_resolveIdentityName(p2: string)
	local v2 = self.currentMatchPlayers and self.currentMatchPlayers[p2]

	if v2 then
		return v2.username or v2.name or p2
	end

	return p2
end

function IdentityLayer:_showSpectatorIdentityMarker(p: string, p2)
	local marker = self.markers[p]

	if not marker then
		return
	end

	marker.requestId += 1
	marker.billboard.Enabled = true
	marker.imageLabel.Visible = false
	marker.textLabel.Visible = true
	marker.textLabel.Size = UDim2.fromScale(0.92, 0.42)
	marker.textLabel.Font = Enum.Font.GothamBold
	marker.textLabel.TextColor3 = Color3.fromRGB(240, 244, 255)
	marker.textLabel.Text = self:_resolveIdentityName(p)
	marker.arrowLabel.TextColor3 = Color3.fromRGB(255, 240, 190)
	marker.arrowLabel.Visible = true
	local userId = p2 and p2.userId

	if typeof(userId) ~= "number" then
		return
	end

	local image = v[userId]

	if image then
		marker.imageLabel.Image = image
		marker.imageLabel.Visible = true
		marker.textLabel.Visible = false
	else
		local requestId = marker.requestId
		task.spawn(function()
			local success, result = pcall(function()
				return Players:GetUserThumbnailAsync(
					userId,
					Enum.ThumbnailType.HeadShot,
					Enum.ThumbnailSize.Size100x100
				)
			end)

			if not success or self.rootFolder == nil or marker.requestId ~= requestId then
				return
			end

			v[userId] = result
			marker.imageLabel.Image = result
			marker.imageLabel.Visible = true
			marker.textLabel.Visible = false
		end)
	end
end

function IdentityLayer:_refreshIdentityMarkers()
	self:_hideIdentityMarkers()

	if self.isLocalParticipant or not (self.identityMarkersVisible and self.currentMatchPlayers) then
		return
	end

	for k, currentMatchPlayer in self.currentMatchPlayers do
		self:_showSpectatorIdentityMarker(k, currentMatchPlayer)
	end
end

function IdentityLayer:setParticipantView(isLocalParticipant: boolean, participantTableState: string)
	self.isLocalParticipant = isLocalParticipant
	self.participantTableState = participantTableState
	self:_refreshIdentityMarkers()
end

function IdentityLayer:setLocalParticipantSlot(localParticipantSlotId: string?)
	if self.localParticipantSlotId == localParticipantSlotId then
		return
	end

	self.localParticipantSlotId = localParticipantSlotId
	self:_refreshIdentityMarkers()
end

function IdentityLayer:setMatchPlayers(currentMatchPlayers)
	if self.currentMatchPlayers == currentMatchPlayers then
		return
	end

	self.currentMatchPlayers = currentMatchPlayers
	self:_refreshIdentityMarkers()
end

function IdentityLayer:setIdentityMarkersVisible(identityMarkersVisible: boolean)
	if self.identityMarkersVisible == identityMarkersVisible then
		return
	end

	self.identityMarkersVisible = identityMarkersVisible
	self:_refreshIdentityMarkers()
end

function IdentityLayer:reset()
	self:setIdentityMarkersVisible(false)
end

function IdentityLayer:destroy()
	self.rootFolder = nil
end

return IdentityLayer