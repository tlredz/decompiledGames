local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local ItemLibrary = require(ReplicatedStorage.Modules.ItemLibrary)
require(ReplicatedStorage.Modules.Utility)
local statusTextOverlay = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("StatusTextOverlay")
local v = {
	"Text",
	"RichText",
	"FontFace",
	"TextXAlignment",
	"TextYAlignment",
	"TextTransparency"
}
local v2 = { "ImageTransparency", "ScaleType", "Image" }
local colorSequence = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(253, 255, 114)),
	ColorSequenceKeypoint.new(0.384, Color3.fromRGB(252, 251, 108)),
	ColorSequenceKeypoint.new(0.768, Color3.fromRGB(237, 186, 14)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(235, 177, 2))
})
local colorSequence2 = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(154, 114, 255)),
	ColorSequenceKeypoint.new(0.384, Color3.fromRGB(149, 108, 252)),
	ColorSequenceKeypoint.new(0.768, Color3.fromRGB(77, 14, 237)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(68, 2, 235))
})
local color = Color3.fromRGB(64, 64, 64)
local color2 = Color3.fromRGB(127, 127, 127)
local class = {}
class.__index = class

function class._new()
	local self = setmetatable({}, class)
	self._connections = {}
	self:_Init()
	return self
end

function class:ApplyItemStatusToText(p, p2)
	if p2 == "Prime" then
		local _CreateTextOverlay = self:_CreateTextOverlay(p, colorSequence)
		_CreateTextOverlay.Cover:Destroy()
		_CreateTextOverlay.Shine:AddTag("UISparkleEffect")
		_CreateTextOverlay.Shine:AddTag("UIShinyText")
	elseif p2 == "Contraband" then
		local _CreateTextOverlay = self:_CreateTextOverlay(p, colorSequence2)
		_CreateTextOverlay.Highlight:AddTag("UIGlitchEffect")
		_CreateTextOverlay.Shine.TextColor3 = Color3.fromRGB(0, 0, 0)
		_CreateTextOverlay.Shine:SetAttribute("IsDoubleFlash", true)
		_CreateTextOverlay.Shine:AddTag("UIShinyText")
	end
end

function class:ApplyItemStatusToBackground(instance, p, p2)
	self:_RecolorBackground(instance, p, p2)

	if p2 == "Prime" then
		instance:AddTag("UISparkleEffect")
	elseif p2 == "Contraband" then
		instance:AddTag("UIGlitchEffect")
	end
end

function class:ApplyItemStatusToImage(p, p2)
	if p2 == "Prime" then
		self:_CreateImageOverlay(p, colorSequence):AddTag("UISparkleEffect")
	elseif p2 == "Contraband" then
		self:_CreateImageOverlay(p, colorSequence2):AddTag("UIGlitchEffect")
	end
end

function class:ClearStatusElements(instance)
	for _, child in pairs(instance:GetChildren()) do
		if child:HasTag("WeaponStatusElement") then
			child:Destroy()
		end
	end
end

function class:_CreateTextOverlay(parent, color3)
	local clone = statusTextOverlay:Clone()
	clone.Highlight.UIGradient.Color = color3
	self:_CopyElement(clone.Cover, parent, v)
	self:_CopyElement(clone.Highlight, parent, v)
	self:_CopyElement(clone.Shine, parent, v)
	self:_TagStatusElement(clone)
	clone.Parent = parent
	local highlight = clone.Highlight
	local uIStroke = highlight.UIStroke

	-- equivalent calls inferred from this helper; original call sites unknown
	local function update()
		uIStroke.Transparency = highlight.TextTransparency
		uIStroke.Color = color2:Lerp(color, (math.clamp(highlight.TextTransparency / 0.25, 0, 1)))
	end

	highlight:GetPropertyChangedSignal("TextTransparency"):Connect(update)
	update() -- equivalent call inferred; original call site unknown
	return clone
end

function class:_CreateImageOverlay(parent, color3)
	local instance = Instance.fromExisting(parent)
	instance.Size = UDim2.new(1, 0, 1, 0)
	instance.AnchorPoint = Vector2.new(0.5, 0.5)
	instance.Position = UDim2.new(0.5, 0, 0.5, 0)
	instance.Active = false
	instance.Interactable = false
	instance.Selectable = false
	instance.SizeConstraint = Enum.SizeConstraint.RelativeXY
	instance.ImageColor3 = Color3.fromRGB(255, 255, 255)
	local uIGradient = Instance.new("UIGradient")
	uIGradient.Rotation = 90
	uIGradient.Color = color3
	uIGradient.Parent = instance
	self:_CopyElement(instance, parent, v2)
	self:_TagStatusElement(instance)
	instance.Parent = parent
	return instance
end

function class:_RecolorBackground(image, p, p2)
	local status = ItemLibrary.Statuses[p2]

	if not status then
		return
	end

	if image:IsA("ImageLabel") then
		image.ImageColor3 = status.Color
	end

	image.BackgroundColor3 = status.Color
	p.Color = status.Color
end

function class:_TagStatusElement(instance)
	instance:AddTag("WeaponStatusElement")
	instance.Name = "_ITEMSTATUSCLONE"
end

function class:_CopyElement(instance, instance2, items)
	if not self._connections[instance] then
		self._connections[instance] = {}
		table.insert(self._connections[instance], instance.Destroying:Connect(function()
			for _, connection in pairs(self._connections[instance] or {}) do
				connection:Disconnect()
			end

			self._connections[instance] = nil
		end))
	end

	for _, propertyName in pairs(items) do
		-- equivalent calls inferred from this helper; original call sites unknown
		local v3 = propertyName

		local function update()
			instance[v3] = instance2[v3]
		end

		table.insert(self._connections[instance], instance2:GetPropertyChangedSignal(propertyName):Connect(update))
		update() -- equivalent call inferred; original call site unknown
	end
end

function class:_ObjectAdded(label)
	local status = label:GetAttribute("Status")
	assert(ItemLibrary.Statuses[status] ~= nil, label:GetFullName())
	self:ClearStatusElements(label)

	if label:IsA("TextLabel") then
		self:ApplyItemStatusToText(label, status)
	else
		assert(false, label:GetFullName())
	end
end

function class:_Init()
	CollectionService:GetInstanceAddedSignal("ApplyWeaponStatus"):Connect(function(p)
		self:_ObjectAdded(p)
	end)

	for _, v3 in pairs(CollectionService:GetTagged("ApplyWeaponStatus")) do
		task.defer(self._ObjectAdded, self, v3)
	end
end

return class._new()