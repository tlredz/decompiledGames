game:GetService("TweenService")
local Players = game:GetService("Players")
local WrapGroupObject = require(Players.LocalPlayer.PlayerScripts.Modules.WrapGroupObject)
local object = setmetatable({}, WrapGroupObject)
object.__index = object

function object.new(...)
	local self = setmetatable(WrapGroupObject.new(...), object)
	self._waves = {}
	self._waves_foam = {}
	self._waves_shade1 = {}
	self._waves_shade2 = {}
	self._caustics1 = {}
	self._caustics2 = {}
	self:_Init()
	return self
end

function object:Update(_)
	local serverTimeNow = workspace:GetServerTimeNow()
	local v = serverTimeNow / 7.5
	local transparency = math.clamp(math.sin(v * 24) / 3 + 0.5, 0, 1)
	local transparency2 = math.clamp(math.sin((v + 3.5342917352885173) * 24) / 3 + 0.5, 0, 1)

	for _, _wave in pairs(self._waves) do
		object:_MoveTexture(_wave, 0, 0, 0, serverTimeNow)
	end

	for _, v4 in pairs(self._waves_foam) do
		object:_MoveTexture(v4, 0, 0, 0.05, serverTimeNow)
	end

	for _, v4 in pairs(self._waves_shade1) do
		object:_MoveTexture(v4, 0.01, 0.6, 0, serverTimeNow)
	end

	for _, v4 in pairs(self._waves_shade2) do
		object:_MoveTexture(v4, 0.035, 0.9, 0, serverTimeNow)
	end

	for _, v4 in pairs(self._caustics1) do
		v4.Transparency = transparency
	end

	for _, v4 in pairs(self._caustics2) do
		v4.Transparency = transparency2
	end
end

function object:_MoveTexture(state, p, p2, p3, p4)
	local v = p3 - 0.1
	local v2 = p4 / 1.5
	local studsPerTileU = state.StudsPerTileU
	local studsPerTileV = state.StudsPerTileV
	state.OffsetStudsU = -(v2 / 10 - p) % studsPerTileU
	state.OffsetStudsV = (math.sin(v2 - p2) / 6 + 0.2) % studsPerTileV + v
end

function object:_Setup()
	for _, extraObject in pairs(self.ExtraObjects) do
		if extraObject.Name == "Waves" or extraObject.Name == "WavesCaustics" then
			table.insert(self._waves, extraObject)
		elseif extraObject.Name == "WavesFoam" then
			table.insert(self._waves_foam, extraObject)
		elseif extraObject.Name == "WavesShade1" then
			table.insert(self._waves_shade1, extraObject)
		elseif extraObject.Name == "WavesShade2" then
			table.insert(self._waves_shade2, extraObject)
		elseif extraObject.Name == "Caustics" then
			table.insert(self._caustics1, extraObject)
		elseif extraObject.Name == "Caustics2" then
			table.insert(self._caustics2, extraObject)
		end
	end
end

function object:_Init()
	self:_Setup()
end

return object