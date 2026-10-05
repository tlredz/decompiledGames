local MusicNameDiffuserController = {}
MusicNameDiffuserController.__index = MusicNameDiffuserController

function MusicNameDiffuserController.new()
	local self = setmetatable({}, MusicNameDiffuserController)
	self._gui = nil
	self._textLabel = nil
	self._part = nil
	self._currentText = ""
	self._scrollX = 0
	self._scrollSpeed = 150
	return self
end

function MusicNameDiffuserController:scan(parent)
	if not parent then
		return
	end

	if parent.Parent and parent.Parent:IsA("Model") then
		parent = parent.Parent
	end

	local musicNameDiffuser = parent:WaitForChild("MusicNameDiffuser", 5)

	if not musicNameDiffuser then
		warn("[MusicNameDiffuserController] Missing model 'MusicNameDiffuser' in scene.")
		return
	end

	local musicNameDiffuser2 = musicNameDiffuser:WaitForChild("MusicNameDiffuser", 5)

	if not (musicNameDiffuser2 and musicNameDiffuser2:IsA("BasePart")) then
		warn("[MusicNameDiffuserController] Missing part 'MusicNameDiffuser' inside the model.")
		return
	end

	self._part = musicNameDiffuser2
	local surfaceGui = Instance.new("SurfaceGui")
	surfaceGui.Name = "MusicNameDiffuserGui"
	surfaceGui.Face = Enum.NormalId.Front
	surfaceGui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	surfaceGui.PixelsPerStud = 50
	surfaceGui.ClipsDescendants = true
	local textLabel = Instance.new("TextLabel")
	textLabel.Name = "ScrollingText"
	textLabel.BackgroundTransparency = 1
	textLabel.Size = UDim2.new(10, 0, 1, 0)
	textLabel.Position = UDim2.new(0, 0, 0, 0)
	textLabel.Font = Enum.Font.GothamBold
	textLabel.TextScaled = false
	textLabel.TextSize = 100
	textLabel.TextColor3 = Color3.new(1, 1, 1)
	textLabel.TextXAlignment = Enum.TextXAlignment.Left
	textLabel.Text = ""
	textLabel.Parent = surfaceGui
	surfaceGui.Parent = self._part
	self._gui = surfaceGui
	self._textLabel = textLabel
end

function MusicNameDiffuserController:setSongName(p: string)
	if not self._textLabel then
		return
	end

	local v = "NOW PLAYING: " .. p .. "    "

	if self._currentText == v then
		return
	end

	self._currentText = v
	self._textLabel.Text = v

	if self._gui then
		self._scrollX = self._gui.AbsoluteSize.X
	end
end

function MusicNameDiffuserController:update(p: number)
	if not (self._textLabel and self._gui) then
		return
	end

	local Y = self._gui.AbsoluteSize.Y

	if Y > 0 then
		self._textLabel.TextSize = Y * 0.8
	end

	self._scrollX -= self._scrollSpeed * p
	local X = self._textLabel.TextBounds.X

	if X > 0 and self._scrollX < -X then
		self._scrollX = self._gui.AbsoluteSize.X
	end

	self._textLabel.Position = UDim2.new(0, self._scrollX, 0, 0)
end

function MusicNameDiffuserController:destroy()
	if self._gui then
		self._gui:Destroy()
		self._gui = nil
	end
end

return MusicNameDiffuserController