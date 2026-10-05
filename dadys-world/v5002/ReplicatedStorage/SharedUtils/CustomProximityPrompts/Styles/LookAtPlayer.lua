local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local fredokaOne = Enum.Font.FredokaOne
local color = Color3.fromRGB(255, 255, 255)
local color2 = Color3.fromRGB(0, 0, 0)
local scaledSize = Enum.StrokeSizingMode.ScaledSize
local colorSequence = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(198, 198, 198))
})
local vector = Vector2.new(0.5, 1)
local uDim = UDim2.fromScale(0.5, 1.18)
local v = false
local v2 = false

local function addKeyLabel(clone)
	local inputImage = clone:FindFirstChild("InputImage", true)

	if inputImage and inputImage:IsA("GuiObject") then
		local textLabel = Instance.new("TextLabel")
		textLabel.Name = "KeyText"
		textLabel.AnchorPoint = inputImage.AnchorPoint
		textLabel.Position = inputImage.Position
		textLabel.Size = inputImage.Size
		textLabel.BackgroundTransparency = 1
		textLabel.Font = fredokaOne
		textLabel.TextColor3 = color
		textLabel.TextScaled = true
		textLabel.Text = ""
		textLabel.Visible = false
		textLabel.ZIndex = inputImage.ZIndex
		textLabel.Parent = inputImage.Parent
		local uIGradient = Instance.new("UIGradient")
		uIGradient.Color = colorSequence
		uIGradient.Rotation = 90
		uIGradient.Parent = textLabel
		local uIStroke = Instance.new("UIStroke")
		uIStroke.Color = color2
		uIStroke.StrokeSizingMode = scaledSize
		uIStroke.Thickness = 0.15
		uIStroke.Parent = textLabel
	elseif not v2 then
		v2 = true
		warn(string.format(
			"%s %s has no %s — the keyboard key name has nowhere to draw",
			"[LookAtPlayer]",
			"LoadoutFrame2",
			"InputImage"
		))
	end
end

local LookAtPlayer = {
	touchImage = "rbxasset://textures/ui/Controls/TouchTapIcon.png",
	formatKeyText = function(value)
		return "[" .. value:upper() .. "]"
	end,
	partNames = {
		container = "Profile",
		buttonImage = "InputImage",
		buttonText = "KeyText"
	},
	template = function()
		local assets = ReplicatedStorage:FindFirstChild("Assets")
		local loadoutFrame2 = assets and assets:FindFirstChild("LoadoutFrame2")

		if loadoutFrame2 then
			local clone = loadoutFrame2:Clone()
			addKeyLabel(clone)
			return clone
		else
			if not v then
				v = true
				warn(string.format(
					"%s ReplicatedStorage.Assets.%s missing — falling back to the default widget",
					"[LookAtPlayer]",
					"LoadoutFrame2"
				))
			end

			return nil
		end
	end
}

-- equivalent calls inferred from this helper; original call sites unknown
local function currentDevice()
	local preferredInput = UserInputService.PreferredInput

	if preferredInput == Enum.PreferredInput.Touch then
		return "Touch"
	end

	if preferredInput == Enum.PreferredInput.Gamepad then
		return "Gamepad"
	end

	return "Keyboard"
end

function LookAtPlayer.apply(data)
	local buttonImage = data.parts.buttonImage

	if not buttonImage then
		return
	end

	local anchorPoint = buttonImage.AnchorPoint
	local position = buttonImage.Position

	-- equivalent calls inferred from this helper; original call sites unknown
	local function place(p)
		if p == "Touch" then
			buttonImage.AnchorPoint = vector
			buttonImage.Position = uDim
		else
			buttonImage.AnchorPoint = anchorPoint
			buttonImage.Position = position
		end
	end

	place(data.device) -- equivalent call inferred; original call site unknown
	data.maid:GiveTask(UserInputService:GetPropertyChangedSignal("PreferredInput"):Connect(function()
		place(currentDevice()) -- equivalent call inferred; original call site unknown
	end))
end

return LookAtPlayer