local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local LightingSnapshot = {}
LightingSnapshot.__index = LightingSnapshot

function LightingSnapshot.capture(props)
	local self = setmetatable({}, LightingSnapshot)
	self._saved = {}
	self._props = props

	for _, v in props do
		self._saved[v] = Lighting[v]
	end

	return self
end

function LightingSnapshot.apply(_, items)
	for k, item in items do
		Lighting[k] = item
	end
end

function LightingSnapshot:restore()
	for k, v in self._saved do
		Lighting[k] = v
	end
end

local v = {
	"ClockTime",
	"Brightness",
	"Ambient",
	"OutdoorAmbient",
	"FogEnd",
	"FogColor"
}
local v2 = 0
local v3 = nil

function LightingSnapshot.acquireShared()
	v2 += 1

	if v2 == 1 then
		v3 = {}

		for _, v4 in v do
			v3[v4] = Lighting[v4]
		end
	end
end

function LightingSnapshot.releaseShared(value)
	if v2 <= 0 then
		return
	end

	v2 -= 1

	if v2 > 0 or not v3 then
		return
	end

	local v4 = v3
	v3 = nil
	local v5 = value or 0

	if v5 > 0 then
		TweenService:Create(Lighting, TweenInfo.new(v5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), v4):Play()
	else
		for k, v6 in v4 do
			Lighting[k] = v6
		end
	end
end

return LightingSnapshot