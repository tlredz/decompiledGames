local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local WrapGroupObject = require(Players.LocalPlayer.PlayerScripts.Modules.WrapGroupObject)
local tweenInfo = TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
local tweenInfo2 = TweenInfo.new(0, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
local numberRange = NumberRange.new(0.3, 0.5)
local numberRange2 = NumberRange.new(0.25, 0.3)
local numberRange3 = NumberRange.new(1, 3)
local numberRange4 = NumberRange.new(0, 5)
local object = setmetatable({}, WrapGroupObject)
object.__index = object

function object.new(...)
	local self = setmetatable(WrapGroupObject.new(...), object)
	self._flashes1 = {}
	self._flashes2 = {}
	self._flashes3 = {}
	self._flashes4 = {}
	self._flashes_large = {}
	self._started = 0
	self._next_flash = 0
	self._last_index = 0
	self:_Init()
	return self
end

function object:Update(p)
	self._started += p

	if self._started < self._next_flash then
		return
	end

	self._next_flash = self._started + Random.new():NextNumber(numberRange.Min, numberRange.Max)
	local v = {}

	if self._last_index ~= 1 then
		table.insert(v, 1)
	end

	if self._last_index ~= 2 then
		table.insert(v, 2)
	end

	if self._last_index ~= 3 then
		table.insert(v, 3)
	end

	if self._last_index ~= 4 then
		table.insert(v, 4)
	end

	self._last_index = v[Random.new():NextInteger(1, #v)]
	local number = Random.new():NextNumber(numberRange2.Min, numberRange2.Max)
	local number2 = Random.new():NextNumber(numberRange4.Min, numberRange4.Max)
	local number3 = Random.new():NextNumber(numberRange4.Min, numberRange4.Max)
	local integer = Random.new():NextInteger(numberRange3.Min, numberRange3.Max)

	for _, v2 in pairs(self[`_flashes{self._last_index}`]) do
		v2.OffsetStudsU = number2
		v2.OffsetStudsV = number3
		local v3 = v2
		task.spawn(function()
			for i = 1, integer do
				local tween = TweenService:Create(v3, tweenInfo, {
					Transparency = 0.1
				})
				tween:Play()
				table.insert(self._tweens, tween)
				task.wait(tweenInfo.Time)
				local tween2 = TweenService:Create(
					v3,
					TweenInfo.new(number, tweenInfo2.EasingStyle, tweenInfo2.EasingDirection),
					{
						Transparency = 1
					}
				)
				tween2:Play()
				table.insert(self._tweens, tween2)
				task.wait(number / 1.5)
			end
		end)
	end

	for _, v2 in pairs(self._flashes_large) do
		v2.Transparency = 0.85
		local tween = TweenService:Create(
			v2,
			TweenInfo.new(number + 0.5, tweenInfo2.EasingStyle, tweenInfo2.EasingDirection),
			{
				Transparency = 1
			}
		)
		tween:Play()
		table.insert(self._tweens, tween)
	end
end

function object:_Setup()
	for _, extraObject in pairs(self.ExtraObjects) do
		if extraObject.Name == "FlashesBackground" then
			table.insert(self._flashes_large, extraObject)
		else
			for i = 1, 4 do
				if extraObject.Name ~= `Flashes{i}` then
					continue
				end

				table.insert(self[`_flashes{i}`], extraObject)
				extraObject.Transparency = 1
			end
		end
	end

	self._started = workspace:GetServerTimeNow()
end

function object:_Init()
	self:_Setup()
end

return object