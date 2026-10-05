local Button = {}
Button.__index = Button
local imageButton = script.ImageButton
local v = false

function Button.new(data)
	local guiButton = data.guiButton

	if guiButton == nil then
		guiButton = imageButton:Clone()
	end

	local selected = guiButton:FindFirstChild("Selected")
	local icon = guiButton:FindFirstChild("Icon")
	local more = guiButton:FindFirstChild("More")
	local propVIP = guiButton:FindFirstChild("PropVIP")
	local propTheme = guiButton:FindFirstChild("PropTheme")
	guiButton.Name = data.Name or guiButton.Name

	if icon and propVIP then
		guiButton.Icon.Image = data.Icon or guiButton.Icon.Image
	end

	local object = setmetatable({
		guiButton = guiButton,
		selectedFrame = selected,
		AssetId = data.AssetId,
		PropVIPPic = propVIP,
		PropThemePic = propTheme
	}, Button)

	local function inputBegan(p)
		if (p.UserInputType == Enum.UserInputType.MouseMovement or p.UserInputType == Enum.UserInputType.Touch) and more and data.DetailsCallback then
			more.Visible = true
		end
	end

	local function inputEnded(p)
		if (p.UserInputType == Enum.UserInputType.MouseMovement or p.UserInputType == Enum.UserInputType.Touch) and more and data.DetailsCallback then
			more.Visible = false
		end
	end

	local function activated(p)
		if v == false then
			v = true

			if data.ActivatedCallback then
				data.ActivatedCallback(p)
			end

			wait(0.3)
			v = false
		end
	end

	if more and data.DetailsCallback then
		local function touchLongPress(_, p)
			if p == Enum.UserInputState.Begin then
				data.DetailsCallback()
			end
		end

		guiButton.TouchLongPress:Connect(touchLongPress)
		more.Activated:Connect(data.DetailsCallback)
	end

	guiButton.InputBegan:Connect(inputBegan)
	guiButton.InputEnded:Connect(inputEnded)
	guiButton.Activated:Connect(activated)
	return object
end

function Button.Parent(p, parent)
	p.guiButton.Parent = parent
end

function Button.SetSelected(p, visible)
	if p.selectedFrame then
		p.selectedFrame.Visible = visible
	end
end

function Button.SetPeeImage(p, visible)
	if p.PropVIPPic then
		p.PropVIPPic.Visible = visible
	end
end

function Button.SetThemeImage(p, image)
	if p.PropThemePic then
		p.PropThemePic.Visible = true
		p.PropThemePic.Image = image
	end
end

function Button:Destroy()
	self.PropVIPPic = nil
	self.PropThemePic = nil
	self.selectedFrame = nil
	self.guiButton:Destroy()
	self.guiButton = nil
	setmetatable(self, nil)
end

return Button