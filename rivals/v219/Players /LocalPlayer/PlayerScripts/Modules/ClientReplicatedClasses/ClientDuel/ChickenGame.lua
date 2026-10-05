local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Utility = require(ReplicatedStorage.Modules.Utility)
local ChickenGame = {}
ChickenGame.__index = ChickenGame

function ChickenGame.new(clientDuel)
	local self = setmetatable({}, ChickenGame)
	self.ClientDuel = clientDuel
	self._cc = Instance.new("ColorCorrectionEffect")
	self._red_light_hash = 0
	self._jingle_sfx = nil
	self:_Init()
	return self
end

function ChickenGame:RedLight(p, p2)
	self._red_light_hash += 1
	local _red_light_hash = self._red_light_hash
	self._cc.Contrast = 0
	self._cc.Saturation = 0
	self._cc.TintColor = Color3.fromRGB(255, 255, 255)
	self._cc.Parent = Lighting
	local lastTime = tick()

	while tick() < lastTime + p do
		local v = math.clamp((tick() - lastTime) / p, 0, 1) ^ 4
		self._cc.Contrast = 0
		self._cc.Saturation = 0
		self._cc.TintColor = Color3.fromRGB(255, 255, 255):Lerp(Color3.fromRGB(255, 127, 127), v)
		RunService.RenderStepped:Wait()

		if _red_light_hash ~= self._red_light_hash then
			return
		end
	end

	self._cc.Contrast = 0
	self._cc.Saturation = 0
	self._cc.TintColor = Color3.fromRGB(255, 0, 0)
	self.ClientDuel.DuelInterface:CreateSound("rbxassetid://115599786018668", 0.5, 0.875, script, true, 5)
	local lastTime2 = tick()
	Utility:RenderstepForLoop(0, 100, 4, function(p3)
		if _red_light_hash ~= self._red_light_hash then
			return true
		end

		local v = (p3 / 100) ^ 2
		self._cc.Contrast = 1 + -1 * v
		self._cc.Saturation = 1 + -1 * v
		self._cc.Brightness = 0.25 + -0.25 * v
	end)
	wait(p2 - (tick() - lastTime2))

	if _red_light_hash ~= self._red_light_hash then
		return
	end

	self._cc.Parent = nil
end

function ChickenGame:GreenLight(p, p2, p3)
	self._red_light_hash += 1
	local _red_light_hash = self._red_light_hash

	if not p then
		self._cc.Parent = nil
		return
	end

	self.ClientDuel.DuelInterface:CreateSound("rbxassetid://115599786018668", 0.25, 2, script, true, 5)
	self._jingle_sfx = self.ClientDuel.DuelInterface:CreateSound(
		"rbxassetid://81396691367613",
		0.25,
		5 / p,
		script,
		true,
		10
	)
	self._cc.Contrast = 1
	self._cc.Saturation = 0.5
	self._cc.TintColor = Color3.fromRGB(100, 255, 50)
	local _cc = self._cc
	local parent

	if not p3 then
		parent = Lighting or nil
	end

	_cc.Parent = parent
	local lastTime = tick()
	wait(0.25)
	Utility:RenderstepForLoop(0, 100, 4, function(p4)
		if _red_light_hash ~= self._red_light_hash then
			return true
		end

		local v2 = 1 - (1 - p4 / 100) ^ 2
		self._cc.Contrast = 1 + -1 * v2
		self._cc.Saturation = 0.5 + -0.5 * v2
		self._cc.TintColor = Color3.fromRGB(100, 255, 50):Lerp(Color3.fromRGB(255, 255, 255), v2)
	end)

	if _red_light_hash ~= self._red_light_hash then
		return
	end

	self._cc.Parent = nil
	self:RedLight(p - (tick() - lastTime), p2)
end

function ChickenGame:Stop()
	if self._jingle_sfx then
		self._jingle_sfx:Destroy()
		self._jingle_sfx = nil
	end
end

function ChickenGame.Elimination(p)
	p.ClientDuel.DuelInterface:CreateSound("rbxassetid://13270206222", 1, 1.25 + 0.5 * math.random(), script, true, 5)
	p.ClientDuel.DuelInterface:CreateSound("rbxassetid://13270206087", 1, 1.25 + 0.5 * math.random(), script, true, 5)
end

function ChickenGame:Destroy()
	self._red_light_hash += 1
	self._cc:Destroy()
end

function ChickenGame:_Init()
	self.ClientDuel:GetDataChangedSignal("IsSpectating"):Connect(function()
		if not self.ClientDuel:Get("IsSpectating") then
			self._cc.Parent = nil
		end
	end)
end

return ChickenGame