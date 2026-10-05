local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local RenderstepForLoop = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Utility"):WaitForChild("RenderstepForLoop"))
local EventLibrary = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("EventLibrary"))
local glowyBackground = Players.LocalPlayer:WaitForChild("PlayerScripts"):WaitForChild("UserInterface"):WaitForChild("GlowyBackground")
local v = {
	"Black",
	"Yellow",
	"Purple",
	"Purple2"
}
local color = Color3.fromRGB(255, 255, 255)
local color2 = Color3.fromRGB(220, 220, 220)
local GlowyBackground = {}
GlowyBackground.__index = GlowyBackground

function GlowyBackground.new(name)
	local self = setmetatable({}, GlowyBackground)
	self.Frame = glowyBackground:Clone()
	self._name = name
	self._backdrop_transparency = 0
	self._elements = {}
	self._blur = Instance.new("BlurEffect")
	self._colorcorrection = Instance.new("ColorCorrectionEffect")
	self._is_enabled = false
	self._current_hash = 0
	self._start = tick()
	self._start_transparencies = {}
	self._connection = nil
	self._fade_in_alpha = 1
	self:_Init()
	return self
end

function GlowyBackground.SetParent(p, parent)
	p.Frame.Parent = parent
end

function GlowyBackground:SetBlurEnabled(enabled)
	self._blur.Enabled = enabled

	if not self._blur.Enabled then
		self._blur.Size = 0
	end
end

function GlowyBackground:SetBackdropTransparency(backdrop_transparency)
	self._backdrop_transparency = backdrop_transparency
	self:_UpdateElementsTransparency()
end

function GlowyBackground:DisableElement(p, isDisabled)
	self._elements[p].IsDisabled = isDisabled
	self:_UpdateElementsTransparency()
end

function GlowyBackground:SetEnabled(is_enabled, p)
	if self._is_enabled == is_enabled and not p then
		return
	end

	self._is_enabled = is_enabled
	task.spawn(self._Update, self, p)
	self:_UpdateElementsTransparency()
end

function GlowyBackground:SetColor(p2, p3)
	if not self._elements[p2] then
		return
	end

	self._elements[p2].Object.ImageColor3 = p3 or self._elements[p2].OriginalColor
end

function GlowyBackground:Destroy()
	self.Frame:Destroy()
	self._blur:Destroy()
	self._colorcorrection:Destroy()
	self._current_hash += 1
end

function GlowyBackground:_GetTransparency(p, p2, p3)
	self._start_transparencies[p] = self._start_transparencies[p] or p[p2]
	local _start_transparency = self._start_transparencies[p]
	local v2 = 1 - (1 - self._fade_in_alpha) ^ 4
	return _start_transparency + ((not self._is_enabled and 1 or p3) - _start_transparency) * v2
end

function GlowyBackground:_UpdateElementsTransparency()
	self.Frame.BackgroundTransparency = self:_GetTransparency(
		self.Frame,
		"BackgroundTransparency",
		self._backdrop_transparency
	)

	for _, _element in pairs(self._elements) do
		_element.Object.ImageTransparency = self:_GetTransparency(
			_element.Object,
			"ImageTransparency",
			_element.IsDisabled and 1 or _element.OriginalTransparency
		)
	end
end

function GlowyBackground:_Update(p)
	for _, _element in pairs(self._elements) do
		_element.Direction = Vector2.new(math.random() - 0.5, math.random() - 0.5).Unit
		_element.Speed = 0.0125 + 0.025 * math.random()
	end

	self._start_transparencies = {}
	self._current_hash += 1
	local _current_hash = self._current_hash
	local v2 = {}

	for _, _element in pairs(self._elements) do
		v2[_element.Object] = _element.Object.ImageTransparency
	end

	if self._is_enabled and not self._connection then
		self._connection = RunService.RenderStepped:Connect(function()
			local v3 = tick() - self._start

			for _, _element in pairs(self._elements) do
				local v4 = _element.Direction * v3
				_element.Object.Position = UDim2.new(
					0.5,
					_element.Object.TileSize.X.Offset * v4.X * _element.Speed % _element.Object.TileSize.X.Offset,
					0.5,
					_element.Object.TileSize.Y.Offset * v4.Y % 1 * _element.Speed % _element.Object.TileSize.Y.Offset
				)
			end
		end)
	elseif not self._is_enabled and self._connection then
		self._connection:Disconnect()
		self._connection = nil
	end

	if p then
		self._fade_in_alpha = 1
		self:_UpdateElementsTransparency()
	else
		task.spawn(RenderstepForLoop, (1 - self._fade_in_alpha) * 100, 100, self._is_enabled and 0.5 or 1, function(p2)
			if _current_hash ~= self._current_hash then
				return true
			end

			self._fade_in_alpha = p2 / 100
			self:_UpdateElementsTransparency()
		end)
	end

	local tintColor = self._colorcorrection.TintColor
	local contrast = self._colorcorrection.Contrast
	local brightness = self._colorcorrection.Brightness
	local size = self._blur.Size
	local v3 = self._is_enabled and color2 or color
	local v4 = self._is_enabled and -0.3 or 0
	local _ = self._is_enabled
	local v5 = 0
	local v6 = self._is_enabled and 24 or 0

	local function set(p2)
		local v7 = math.clamp(1 - (1 - p2) ^ 5, 0, 1)
		self._blur.Size = not self._blur.Enabled and 0 or size + (v6 - size) * v7
		self._colorcorrection.Brightness = brightness + (v4 - brightness) * v7
		self._colorcorrection.Contrast = contrast + (v5 - contrast) * v7
		self._colorcorrection.TintColor = tintColor:Lerp(v3, v7)
	end

	if not p then
		task.spawn(RenderstepForLoop, 0, 100, 2, function(p2)
			if _current_hash ~= self._current_hash then
				return true
			end

			set(p2 / 100)
		end)
		return
	end

	self._blur.Size = not self._blur.Enabled and 0 or size + (v6 - size) * 1
	self._colorcorrection.Brightness = brightness + (v4 - brightness) * 1
	self._colorcorrection.Contrast = contrast + (v5 - contrast) * 1
	self._colorcorrection.TintColor = tintColor:Lerp(v3, 1)
end

function GlowyBackground:_Setup()
	self._blur.Size = 0
	self._blur.Name = "GlowyBackgroundBlur - " .. self._name
	self._blur.Parent = Lighting
	self._colorcorrection.Name = "GlowyBackgroundColorCorrection - " .. self._name
	self._colorcorrection.Parent = Lighting
	self.Frame.BackgroundTransparency = 1

	for _, childName in pairs(v) do
		local child = self.Frame:WaitForChild(childName)
		self._elements[childName] = {
			Object = child,
			OriginalColor = child.ImageColor3,
			OriginalTransparency = child.ImageTransparency,
			Direction = nil,
			Speed = nil,
			IsDisabled = false
		}
		child.ImageTransparency = 1
	end

	for k, v2 in pairs(EventLibrary.IS_ACTIVE and EventLibrary.EVENT_DETAILS.GLOWY_BACKGROUND_COLOR_OVERRIDES or {}) do
		self:SetColor(k, v2)
	end
end

function GlowyBackground:_Init()
	self:_Setup()
	self:_UpdateElementsTransparency()
	self:SetEnabled(false, true)
	self:SetBackdropTransparency(0)
end

return GlowyBackground