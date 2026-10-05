local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local WrapGroupObject = require(Players.LocalPlayer.PlayerScripts.Modules.WrapGroupObject)
local tweenInfo = TweenInfo.new(0.75, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local object = setmetatable({}, WrapGroupObject)
object.__index = object

function object.new(...)
	local self = setmetatable(WrapGroupObject.new(...), object)
	self._glyphs = {
		{},
		{}
	}
	self._elapsed = 0
	self._elapsed2 = 0
	self._number_value = Instance.new("NumberValue")
	self._jitter_u = 0
	self._jitter_v = 0
	self:_Init()
	return self
end

function object:Update(p)
	self._elapsed += p / 5
	self._elapsed2 += p

	if self._elapsed2 >= 2 then
		self._elapsed2 = 0
		self._number_value.Value = 0.05
		local tween = TweenService:Create(self._number_value, tweenInfo, {
			Value = 0
		})
		tween:Play()
		table.insert(self._tweens, tween)
	end

	for _, v in pairs(self._glyphs[1]) do
		v.OffsetStudsU = -(self._elapsed % v.StudsPerTileU) + self._jitter_u
		v.OffsetStudsV = -(self._elapsed % v.StudsPerTileV) + self._jitter_v
		v.Transparency = 0.55 + self._number_value.Value * 2
	end

	for _, v in pairs(self._glyphs[2]) do
		v.OffsetStudsU = self._elapsed % v.StudsPerTileU + self._jitter_u
		v.OffsetStudsV = self._elapsed % v.StudsPerTileV + self._jitter_v
		v.Transparency = 0.55 + self._number_value.Value * 2
	end
end

function object:Destroy()
	self._number_value:Destroy()
	WrapGroupObject.Destroy(self)
end

function object:_Setup()
	for _, extraObject in pairs(self.ExtraObjects) do
		if extraObject.Name == "Glyphs1" then
			table.insert(self._glyphs[1], extraObject)
		elseif extraObject.Name == "Glyphs2" then
			table.insert(self._glyphs[2], extraObject)
		end
	end
end

function object:_Init()
	self._number_value:GetPropertyChangedSignal("Value"):Connect(function()
		self._jitter_u = Random.new():NextNumber(-self._number_value.Value, self._number_value.Value)
		self._jitter_v = Random.new():NextNumber(-self._number_value.Value, self._number_value.Value)
	end)
	self:_Setup()
end

return object