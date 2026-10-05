local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local Utility = require(ReplicatedStorage.Modules.Utility)
local color = Color3.fromRGB(255, 255, 255)
local color2 = Color3.fromRGB(220, 220, 220)
local Blur = {}
Blur.__index = Blur

function Blur.new(duelInterface)
	local self = setmetatable({}, Blur)
	self.DuelInterface = duelInterface
	self._blur = Instance.new("BlurEffect")
	self._colorcorrection = Instance.new("ColorCorrectionEffect")
	self._last_blur_enabled = nil
	self._last_cc_enabled = nil
	self._tween_hash = 0
	self:_Init()
	return self
end

function Blur:Update()
	local parent = self.DuelInterface:IsActive() and Lighting or nil
	self._blur.Parent = parent
	self._colorcorrection.Parent = parent
end

function Blur:Destroy()
	self._blur:Destroy()
	self._colorcorrection:Destroy()
	self._tween_hash += 1
end

function Blur:_Tween(tween_last, p)
	local v = tween_last and not self.DuelInterface.Voting:IsOpen()

	if tween_last == self._last_blur_enabled and v == self._last_cc_enabled then
		return
	end

	self._tween_last = tween_last
	self._tween_hash += 1
	local _tween_hash = self._tween_hash
	local size = self._blur.Size
	local brightness = self._colorcorrection.Brightness
	local tintColor = self._colorcorrection.TintColor
	local v2 = tween_last and 24 or 0
	local v3 = v and -0.1 or 0
	local v4 = v and color2 or color
	task.spawn(Utility.RenderstepForLoop, Utility, 0, 100, p and 100 or 4, function(p2)
		if _tween_hash ~= self._tween_hash then
			return true
		end

		local v5 = 1 - (1 - p2 / 100) ^ 3
		self._blur.Size = size + (v2 - size) * v5
		self._colorcorrection.Brightness = brightness + (v3 - brightness) * v5
		self._colorcorrection.TintColor = tintColor:Lerp(v4, v5)
	end)
end

function Blur:_UpdateLighting()
	local visible = self.DuelInterface.Frame.Visible
	local v = self.DuelInterface.Scoreboard:IsOpen() or self.DuelInterface.FinalResults.CurrentPage == "Summary" or self.DuelInterface.Voting:IsOpen()
	self:_Tween(visible and v)
end

function Blur:_Setup()
	self._blur.Name = "DuelInterface"
	self._colorcorrection.Name = "DuelInterface"
end

function Blur:_Init()
	self.DuelInterface.Frame:GetPropertyChangedSignal("Visible"):Connect(function()
		self:_UpdateLighting()
	end)
	self.DuelInterface.Scoreboard.VisibilityChanged:Connect(function()
		self:_UpdateLighting()
	end)
	self.DuelInterface.FinalResults.PageChanged:Connect(function()
		self:_UpdateLighting()
	end)
	self.DuelInterface.Voting.VisibilityChanged:Connect(function()
		self:_UpdateLighting()
	end)
	self:_Setup()
	task.defer(self._Tween, self, false, true)
end

return Blur