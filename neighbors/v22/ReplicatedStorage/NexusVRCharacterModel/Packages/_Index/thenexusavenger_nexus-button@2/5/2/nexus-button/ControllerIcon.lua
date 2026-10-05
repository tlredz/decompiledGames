local v = {
	Xbox = {
		ButtonA = {
			Image = "rbxassetid://408444495",
			Size = Vector2.new(95, 95),
			Offset = Vector2.new(318, 416)
		},
		ButtonB = {
			Image = "rbxassetid://408444495",
			Size = Vector2.new(95, 95),
			Offset = Vector2.new(520, 522)
		},
		ButtonX = {
			Image = "rbxassetid://408444495",
			Size = Vector2.new(95, 95),
			Offset = Vector2.new(510, 416)
		},
		ButtonY = {
			Image = "rbxassetid://408444495",
			Size = Vector2.new(95, 95),
			Offset = Vector2.new(616, 318)
		},
		DPadUp = {
			Image = "rbxassetid://408444495",
			Size = Vector2.new(105, 105),
			Offset = Vector2.new(616, 530)
		},
		DPadDown = {
			Image = "rbxassetid://408444495",
			Size = Vector2.new(105, 105),
			Offset = Vector2.new(212, 522)
		},
		DPadLeft = {
			Image = "rbxassetid://408444495",
			Size = Vector2.new(105, 105),
			Offset = Vector2.new(318, 522)
		},
		DPadRight = {
			Image = "rbxassetid://408444495",
			Size = Vector2.new(105, 105),
			Offset = Vector2.new(212, 416)
		},
		ButtonSelect = {
			Image = "rbxassetid://408444495",
			Size = Vector2.new(95, 95),
			Offset = Vector2.new(424, 522)
		},
		ButtonLB = {
			Image = "rbxassetid://408444495",
			Size = Vector2.new(115, 64),
			Offset = Vector2.new(116, 628)
		},
		ButtonRB = {
			Image = "rbxassetid://408444495",
			Size = Vector2.new(115, 64),
			Offset = Vector2.new(0, 628)
		},
		ButtonLT = {
			Image = "rbxassetid://408444495",
			Size = Vector2.new(105, 115),
			Offset = Vector2.new(616, 0)
		},
		ButtonRT = {
			Image = "rbxassetid://408444495",
			Size = Vector2.new(105, 115),
			Offset = Vector2.new(616, 414)
		},
		ButtonLS = {
			Image = "rbxassetid://408444495",
			Size = Vector2.new(105, 105),
			Offset = Vector2.new(0, 522)
		},
		ButtonRS = {
			Image = "rbxassetid://408444495",
			Size = Vector2.new(105, 105),
			Offset = Vector2.new(0, 416)
		},
		Thumbstick1 = {
			Image = "rbxassetid://408444495",
			Size = Vector2.new(105, 105),
			Offset = Vector2.new(616, 116)
		},
		Thumbstick2 = {
			Image = "rbxassetid://408444495",
			Size = Vector2.new(105, 105),
			Offset = Vector2.new(106, 522)
		}
	},
	PlayStation = {
		ButtonCross = {
			Image = "rbxassetid://15530886548",
			Size = Vector2.new(58, 58),
			Offset = Vector2.new(0, 0)
		},
		ButtonCircle = {
			Image = "rbxassetid://15530886548",
			Size = Vector2.new(58, 58),
			Offset = Vector2.new(58, 0)
		},
		ButtonSquare = {
			Image = "rbxassetid://15530886548",
			Size = Vector2.new(58, 58),
			Offset = Vector2.new(116, 0)
		},
		ButtonTriangle = {
			Image = "rbxassetid://15530886548",
			Size = Vector2.new(58, 58),
			Offset = Vector2.new(0, 58)
		},
		ButtonL1 = {
			Image = "rbxassetid://15530886548",
			Size = Vector2.new(58, 58),
			Offset = Vector2.new(58, 58)
		},
		ButtonR1 = {
			Image = "rbxassetid://15530886548",
			Size = Vector2.new(58, 58),
			Offset = Vector2.new(116, 58)
		},
		ButtonL2 = {
			Image = "rbxassetid://15530886548",
			Size = Vector2.new(58, 58),
			Offset = Vector2.new(0, 116)
		},
		ButtonR2 = {
			Image = "rbxassetid://15530886548",
			Size = Vector2.new(58, 58),
			Offset = Vector2.new(58, 116)
		},
		ButtonTouchpad = {
			Image = "rbxassetid://15530886548",
			Size = Vector2.new(58, 58),
			Offset = Vector2.new(116, 116)
		}
	}
}
v.Default = v.Xbox
v.Default.ButtonL1 = v.Xbox.ButtonLB
v.Default.ButtonR1 = v.Xbox.ButtonRB
v.Default.ButtonL2 = v.Xbox.ButtonLT
v.Default.ButtonR2 = v.Xbox.ButtonRT
v.Default.ButtonL3 = v.Xbox.ButtonLS
v.Default.ButtonR3 = v.Xbox.ButtonRS
local UserInputService = game:GetService("UserInputService")
local NexusInstance = require(script.Parent:WaitForChild("Packages"):WaitForChild("NexusInstance"))
local ThemedFrame = require(script.Parent:WaitForChild("ThemedFrame"))
local SimpleWrappedInstance = require(script.Parent:WaitForChild("SimpleWrappedInstance"))
local class = {}
class.__index = class
setmetatable(class, ThemedFrame)
local v2 = {}

function class.ResolveImage(p)
	local stringForKeyCode = UserInputService:GetStringForKeyCode(p)
	local imageForKeyCode = UserInputService:GetImageForKeyCode(p)

	for k, v3 in v do
		if string.find(string.lower(imageForKeyCode), string.lower(k)) and v3[stringForKeyCode] then
			return v3[stringForKeyCode]
		end
	end

	if v.Default[stringForKeyCode] then
		return v.Default[stringForKeyCode]
	end

	if not v2[stringForKeyCode] then
		warn((`No override exists for {stringForKeyCode} (from {p.Name}) with {imageForKeyCode}. Returning default image.`))
		v2[stringForKeyCode] = true
	end

	return {
		Image = imageForKeyCode,
		Size = Vector2.zero,
		Offset = Vector2.zero,
		Color = Color3.fromRGB(60, 60, 60)
	}
end

function class:__new()
	ThemedFrame.__new(self)
	self.SubTheme = "GamepadIconBackground"
	self:DisableChangeReplication("IconScale")
	self.IconScale = 0.9
	self:DisableChangeReplication("Icon")
	self:DisableChangeReplication("IconUIScale")
	self:DisableChangeReplication("KeyCode")
	self:DisableChangeReplication("EventConnections")
	self.EventConnections = {}
	table.insert(self.EventConnections, UserInputService.GamepadConnected:Connect(function()
		self:UpdateVisibility()
	end))
	table.insert(self.EventConnections, UserInputService.GamepadDisconnected:Connect(function()
		self:UpdateVisibility()
	end))
	self:DisableChangeReplication("IconVisible")
	self.IconVisible = false
	self:UpdateVisibility()
end

function class:UpdateVisibility()
	if self.Icon then
		local v3 = #UserInputService:GetConnectedGamepads() ~= 0
		self.Visible = v3
		self.IconVisible = v3
	else
		self.Visible = false
		self.IconVisible = false
	end
end

function class:SetIcon(keyCode)
	if keyCode == nil then
		self.KeyCode = nil

		if self.Icon then
			self.Icon:Destroy()
			self.Icon = nil
		end

		self:UpdateVisibility()
	else
		if type(keyCode) == "string" then
			keyCode = Enum.KeyCode[keyCode]
		end

		if self.Icon then
			self.Icon:Destroy()
		end

		local image = self.ResolveImage(keyCode)
		local imageLabel = Instance.new("ImageLabel")
		imageLabel.BackgroundTransparency = 1
		imageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
		imageLabel.Position = UDim2.new(0.5, 0, 0.5, 0)

		if image.Size.X > image.Size.Y then
			imageLabel.Size = UDim2.new(1, 0, image.Size.Y / image.Size.X, 0)
		elseif image.Size.X < image.Size.Y then
			imageLabel.Size = UDim2.new(image.Size.X / image.Size.Y, 0, 1, 0)
		else
			imageLabel.Size = UDim2.new(1, 0, 1, 0)
		end

		imageLabel.ZIndex = self.ZIndex
		imageLabel.Image = image.Image
		imageLabel.ImageRectSize = image.Size
		imageLabel.ImageRectOffset = image.Offset
		imageLabel.ImageColor3 = image.Color or Color3.fromRGB(255, 255, 255)
		imageLabel.Parent = self:GetWrappedInstance()
		local uIScale = Instance.new("UIScale")
		uIScale.Scale = self.IconScale or 1
		uIScale.Parent = imageLabel
		self.IconUIScale = uIScale
		self.Icon = imageLabel
		self.KeyCode = keyCode
		self:UpdateVisibility()
	end
end

function class:SetScale(p2: number)
	self.IconScale = p2

	if self.IconUIScale then
		self.IconUIScale.Scale = p2
	end
end

function class:Destroy()
	SimpleWrappedInstance.Destroy(self)

	for _, eventConnection in self.EventConnections do
		eventConnection:Disconnect()
	end

	self.EventConnections = {}
end

return (NexusInstance.ToInstance(class))