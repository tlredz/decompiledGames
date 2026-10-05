local CollectionService = game:GetService("CollectionService")
local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local UILibrary = require(Players.LocalPlayer.PlayerScripts.Modules.UILibrary)
local class = {}
class.__index = class

function class._new()
	local self = setmetatable({}, class)
	self:_Init()
	return self
end

function class:_UpdateCoreGuiBackground(instance)
	if instance:IsA("Frame") then
		instance.BackgroundColor3 = UILibrary.BUTTON_BACKGROUND_COLOR
		instance.BackgroundTransparency = UILibrary.BUTTON_BACKGROUND_TRANSPARENCY
	elseif instance:IsA("ImageLabel") then
		instance.ImageColor3 = UILibrary.BUTTON_BACKGROUND_COLOR
		instance.ImageTransparency = UILibrary.BUTTON_BACKGROUND_TRANSPARENCY
	elseif instance:IsA("UIStroke") then
		instance.Color = UILibrary.BUTTON_BACKGROUND_COLOR
		instance.Transparency = UILibrary.BUTTON_BACKGROUND_TRANSPARENCY
	end
end

function class:_UpdateElementSimple(frame)
	local preferredTransparency = GuiService.PreferredTransparency
	local baseTransparency = frame:GetAttribute("BaseTransparency") or 1
	frame[frame:IsA("Frame") and "BackgroundTransparency" or "ImageTransparency"] = 0 + (baseTransparency - 0) * preferredTransparency
	local transparentColor = frame:GetAttribute("TransparentColor")
	local opaqueColor = frame:GetAttribute("OpaqueColor")

	if transparentColor and opaqueColor then
		frame[frame:IsA("Frame") and "BackgroundColor3" or "ImageColor3"] = opaqueColor:Lerp(
			transparentColor,
			preferredTransparency
		)
	end
end

function class:_UpdateElement(instance)
	local uIGradient = instance:WaitForChild("UIGradient")
	local preferredTransparency = GuiService.PreferredTransparency
	instance.ImageTransparency = 0 + 0.25 * preferredTransparency
	instance.ImageColor3 = Color3.fromRGB(31, 31, 31):Lerp(Color3.fromRGB(0, 0, 0), preferredTransparency)
	uIGradient.Transparency = NumberSequence.new(0, 0 + 0.5 * preferredTransparency)
	uIGradient.Color = ColorSequence.new(
		Color3.fromRGB(127, 127, 127):Lerp(Color3.fromRGB(255, 255, 255), preferredTransparency),
		Color3.fromRGB(255, 255, 255)
	)
end

function class:_UpdateAllElements()
	for _, v in pairs(CollectionService:GetTagged("UIBackground")) do
		self:_UpdateElement(v)
	end

	for _, v in pairs(CollectionService:GetTagged("UIBackgroundSimple")) do
		self:_UpdateElementSimple(v)
	end
end

function class:_Init()
	CollectionService:GetInstanceAddedSignal("UIBackground"):Connect(function(p)
		self:_UpdateElement(p)
	end)
	CollectionService:GetInstanceAddedSignal("UIBackgroundSimple"):Connect(function(p)
		self:_UpdateElementSimple(p)
	end)
	CollectionService:GetInstanceAddedSignal("CoreGuiBackground"):Connect(function(p)
		self:_UpdateCoreGuiBackground(p)
	end)
	GuiService:GetPropertyChangedSignal("PreferredTransparency"):Connect(function()
		self:_UpdateAllElements()
	end)

	for _, v in pairs(CollectionService:GetTagged("CoreGuiBackground")) do
		self:_UpdateCoreGuiBackground(v)
	end

	task.defer(self._UpdateAllElements, self)
end

return class._new()