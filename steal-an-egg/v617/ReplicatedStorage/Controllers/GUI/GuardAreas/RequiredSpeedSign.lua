local ReplicatedStorage = game:GetService("ReplicatedStorage")
local t = require(ReplicatedStorage.Packages.t)
local TreadmillUtil = require(ReplicatedStorage.Shared.Util.TreadmillUtil)
local Trove = require(ReplicatedStorage.Packages.Trove)
local RequiredSpeedSign = {}
RequiredSpeedSign.__index = RequiredSpeedSign
RequiredSpeedSign.__class = "RequiredSpeedSign"
local color = Color3.fromRGB(0, 255, 0)
local color2 = Color3.fromRGB(153, 255, 0)
local color3 = Color3.fromRGB(255, 170, 0)
local color4 = Color3.fromRGB(255, 0, 0)

function RequiredSpeedSign.new(areaModel)
	t.strict(t.instanceIsA("Model"))(areaModel)
	local object = setmetatable({}, RequiredSpeedSign)
	object._areaModel = areaModel
	object._color = Color3.new(1, 1, 1)
	object._text = "Loading..."
	object._trove = Trove.new()
	object._trove:Add(areaModel.DescendantAdded:Connect(function()
		object:_render()
	end))
	object:_render()
	return object
end

function RequiredSpeedSign:_render()
	local requiredSpeedSign = self._areaModel:FindFirstChild("RequiredSpeedSign")
	local main

	if requiredSpeedSign then
		main = requiredSpeedSign:FindFirstChild("Main")
	end

	local surfaceGui

	if main then
		surfaceGui = main:FindFirstChild("SurfaceGui")
	end

	local info

	if surfaceGui then
		info = surfaceGui:FindFirstChild("Info")
	end

	local required

	if surfaceGui then
		required = surfaceGui:FindFirstChild("Required")
	end

	local speed

	if required then
		speed = required:FindFirstChild("Speed")
	end

	if info and info:IsA("TextLabel") then
		info.TextColor3 = self._color
	end

	if speed and speed:IsA("TextLabel") then
		speed.Text = self._text
		speed.TextColor3 = self._color
	end
end

function RequiredSpeedSign:SetLoading()
	self._text = "Loading..."
	self._color = Color3.new(1, 1, 1)
	self:_render()
end

function RequiredSpeedSign:SetSlowdownTolerance(p: number)
	t.strict(t.number)(p)
	local color5

	if p < 0.03 then
		color5 = color4
	elseif p < 0.1 then
		color5 = color3:Lerp(color2, (p - 0.03) / 0.07)
	elseif p < 0.4 then
		color5 = color2:Lerp(color, (p - 0.1) / 0.30000000000000004)
	else
		color5 = color
	end

	self._color = color5
	self:_render()
end

function RequiredSpeedSign:SetSpeedPowerRequirement(p: number)
	t.strict(t.number)(p)
	self._text = TreadmillUtil.FormatSpeedPower(p)
	self:_render()
end

function RequiredSpeedSign:Destroy()
	self._trove:Destroy()
end

return RequiredSpeedSign