local Players = game:GetService("Players")
local WrapGroupObject = require(Players.LocalPlayer.PlayerScripts.Modules.WrapGroupObject)
local v = {
	"rbxassetid://2590541",
	"rbxassetid://83032711602009",
	"rbxassetid://128727548904352",
	"rbxassetid://90166684921447",
	"rbxassetid://140239100555084",
	"rbxassetid://97272253453870",
	"rbxassetid://126082024890331",
	"rbxassetid://131249583090004",
	"rbxassetid://130283158493590",
	"rbxassetid://114556019900394",
	"rbxassetid://112466666772902",
	"rbxassetid://117101826648137",
	"rbxassetid://114538468748606",
	"rbxassetid://139873735674722",
	"rbxassetid://103775503564962",
	"rbxassetid://98373420251654",
	"rbxassetid://79425698371704",
	"rbxassetid://87166826689312",
	"rbxassetid://90076189567688",
	"rbxassetid://139561695601892",
	"rbxassetid://140445824066751",
	"rbxassetid://90343553347218",
	"rbxassetid://80578694078644",
	"rbxassetid://75411897165689",
	"rbxassetid://120909749571199",
	"rbxassetid://112084468503688",
	"rbxassetid://126283045144965",
	"rbxassetid://129853781030059",
	"rbxassetid://136743858401776",
	"rbxassetid://119486130155706",
	"rbxassetid://132663054692921",
	"rbxassetid://133945106822765",
	"rbxassetid://70983245593146",
	"rbxassetid://115582632329247",
	"rbxassetid://129297227277092",
	"rbxassetid://87912065660686",
	"rbxassetid://81705944196717",
	"rbxassetid://78878769229079"
}
local v2 = #v / 2
local v3 = #v - 8
local object = setmetatable({}, WrapGroupObject)
object.__index = object

function object.new(...)
	local self = setmetatable(WrapGroupObject.new(...), object)
	self._fire_ring = {}
	self._fire_ring_glow = {}
	self._last_update = 0
	self._last_interval = 0.04
	self._current_frame = 0
	self:_Init()
	return self
end

function object.GetPreloadedImageIDs(_)
	return v
end

function object:Update(_)
	local serverTimeNow = workspace:GetServerTimeNow()

	if serverTimeNow < self._last_update + self._last_interval then
		return
	end

	self._last_update = serverTimeNow
	local v4 = 0
	self._last_interval = 0.04
	self._current_frame -= 1

	if self._current_frame < 1 then
		self._current_frame = #v
	end

	if self._current_frame == #v or self._current_frame == 1 then
		v4 = 1
	elseif v3 <= self._current_frame then
		v4 = (self._current_frame - v3) / v3 * 10
	elseif self._current_frame < v2 then
		v4 += 1 - self._current_frame / v2
		self._last_interval = 0.04 / (v4 + 1)
	end

	local transparency = math.clamp(v4, 0, 1)

	for _, v6 in pairs(self._fire_ring) do
		v6.Texture = v[self._current_frame]
		v6.Transparency = transparency
	end

	for _, v6 in pairs(self._fire_ring_glow) do
		v6.Transparency = math.max(transparency, 0.5)
	end
end

function object:_Setup()
	for _, extraObject in pairs(self.ExtraObjects) do
		if extraObject.Name == "FireRing" then
			table.insert(self._fire_ring, extraObject)
		elseif extraObject.Name == "FireRingGlow" then
			table.insert(self._fire_ring_glow, extraObject)
		end
	end
end

function object:_Init()
	self:_Setup()
end

return object