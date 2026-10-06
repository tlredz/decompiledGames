local createVector = vector.create
local ProximityPromptService = game:GetService("ProximityPromptService")
local parent = script.Parent
local carValue = script:WaitForChild("CarValue", 99999)

if carValue.Value == nil then
	carValue.Value = script.Parent.Parent.Parent
end

local value = carValue.Value
local Keymap = require(value.Scripts.Keymap)
local InputImageLibrary = require(value.Scripts.InputImageLibrary)

-- equivalent calls inferred from this helper; original call sites unknown
local function isFlipped(p)
	return math.deg((math.acos((p.CFrame.upVector:Dot(createVector(0, 1, 0)))))) >= 70
end

local function createPrompt(object, p)
	local IMAGE_ID = "rbxassetid://2848307983"
	local parent2 = object.Parent.Parent
	local clone = script:WaitForChild("ButtonGuiPrototype"):Clone()
	clone.Name = "ButtonGui"
	clone.Enabled = true
	clone.Adornee = object.Parent
	local buttonImage = clone:WaitForChild("ButtonImage")
	local flipImage = clone:WaitForChild("FlipImage")
	local backgroundDesktop = clone:WaitForChild("BackgroundDesktop")
	local backgroundConsole = clone:WaitForChild("BackgroundConsole")
	local buttonPrompt = clone:WaitForChild("ButtonPrompt")
	local image = nil
	local image2 = nil
	local image3 = nil
	local image4 = nil

	if p == Enum.ProximityPromptInputType.Keyboard then
		buttonImage.Size = UDim2.new(0, 36, 0, 36)
		flipImage.Image = IMAGE_ID
		local pressed = flipImage:WaitForChild("Pressed")
		pressed.Image = IMAGE_ID
		flipImage.Size = UDim2.new(0, 44, 0, 44)
		backgroundConsole.Visible = false
		backgroundDesktop.Visible = true
		backgroundDesktop.Size = UDim2.new(0, 97, 0, 46)
		backgroundDesktop.Position = UDim2.new(0.5, 28, 0.5, 0)
		buttonPrompt.Visible = true
		buttonPrompt.Image = "rbxassetid://2935912536"
		buttonPrompt.Size = UDim2.new(0, 36, 0, 36)
		buttonPrompt.Position = UDim2.new(0.5, -46, 0.5, 0)
		buttonPrompt.TextLabel.Visible = true
		buttonPrompt.TextLabel.Text = Keymap.EnterVehicleKeyboard.Name
		image3 = "rbxassetid://2848251564"
		image4 = "rbxassetid://2848251564"
		image = "rbxassetid://2848250902"
		image2 = "rbxassetid://2848250902"
	elseif p == Enum.ProximityPromptInputType.Gamepad then
		buttonImage.Size = UDim2.new(0, 60, 0, 60)
		flipImage.Image = IMAGE_ID
		local pressed_2 = flipImage:WaitForChild("Pressed")
		pressed_2.Image = IMAGE_ID
		flipImage.Size = UDim2.new(0, 44, 0, 44)
		backgroundDesktop.Visible = false
		backgroundConsole.Visible = true
		backgroundConsole.Size = UDim2.new(0, 136, 0, 66)
		backgroundConsole.Position = UDim2.new(0.5, 40, 0.5, 0)
		buttonPrompt.Visible = true
		buttonPrompt.Size = UDim2.new(0, 46, 0, 46)
		buttonPrompt.Position = UDim2.new(0.5, -63, 0.5, 0)
		buttonPrompt.ImageRectSize = Vector2.new(71, 71)
		buttonPrompt.ImageRectOffset = Vector2.new(512, 600)
		buttonPrompt.TextLabel.Visible = false
		local imageLabel = InputImageLibrary:GetImageLabel(Keymap.EnterVehicleGamepad, "Light")
		buttonPrompt.Image = imageLabel.Image
		buttonPrompt.ImageRectOffset = imageLabel.ImageRectOffset
		buttonPrompt.ImageRectSize = imageLabel.ImageRectSize
		image3 = "rbxassetid://2848636545"
		image4 = "rbxassetid://2848636545"
		image = "rbxassetid://2848635029"
		image2 = "rbxassetid://2848635029"
	elseif p == Enum.ProximityPromptInputType.Touch then
		backgroundDesktop.Visible = false
		backgroundConsole.Visible = false
		buttonPrompt.Visible = false
		buttonImage.Size = UDim2.new(0, 44, 0, 44)
		flipImage.Image = "rbxassetid://2848187559"
		local pressed_3 = flipImage:WaitForChild("Pressed")
		pressed_3.Image = "rbxassetid://2848187982"
		flipImage.Size = UDim2.new(0, 44, 0, 44)
		buttonImage.InputBegan:Connect(function(_)
			object:InputHoldBegin()
		end)
		buttonImage.InputEnded:Connect(function(_)
			object:InputHoldEnd()
		end)
		flipImage.InputBegan:Connect(function(_)
			object:InputHoldBegin()
		end)
		flipImage.InputEnded:Connect(function(_)
			object:InputHoldEnd()
		end)
		clone.Active = true
		image3 = "rbxassetid://2848217831"
		image4 = "rbxassetid://2848218107"
		image = "rbxassetid://2847898200"
		image2 = "rbxassetid://2847898354"
	end

	if isFlipped(parent2) then
		flipImage.Visible = true
		buttonImage.Visible = false
	else
		flipImage.Visible = false
		buttonImage.Visible = true
	end

	if parent2.Name == "VehicleSeat" then
		buttonImage.Image = image
		buttonImage.Pressed.Image = image2
	else
		buttonImage.Image = image3
		buttonImage.Pressed.Image = image4
	end

	return clone
end

ProximityPromptService.PromptShown:Connect(function(p, p2)
	if p.Name == "EndorsedVehicleProximityPromptV1" then
		local prompt = createPrompt(p, p2)
		prompt.Parent = parent
		p.PromptHidden:Wait()
		prompt.Parent = nil
	end
end)