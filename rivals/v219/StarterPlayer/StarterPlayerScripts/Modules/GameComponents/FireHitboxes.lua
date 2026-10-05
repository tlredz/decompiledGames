local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local BetterDebris = require(ReplicatedStorage.Modules.BetterDebris)
local Utility = require(ReplicatedStorage.Modules.Utility)
require(ReplicatedStorage.Modules.Spring)
local FighterController = require(Players.LocalPlayer.PlayerScripts.Controllers.FighterController)
local WrapController = require(Players.LocalPlayer.PlayerScripts.Controllers.WrapController)
local fireHitboxes = Players.LocalPlayer.PlayerScripts.Assets:WaitForChild("Misc"):WaitForChild("FireHitboxes")
local class = {}
class.__index = class

function class._new()
	local self = setmetatable({}, class)
	self._fire_hitboxes = {}
	self:_Init()
	return self
end

function class:Extinguish(p2)
	for k, _fire_hitbox in pairs(self._fire_hitboxes) do
		if k:GetAttribute("FireHitboxID") ~= p2 then
			continue
		end

		_fire_hitbox.Visual:Destroy()
		self._fire_hitboxes[k] = nil
		return _fire_hitbox.Visual:GetPivot().Position
	end
end

function class:Update(_)
	for k, _fire_hitbox in pairs(self._fire_hitboxes) do
		_fire_hitbox.Visual:PivotTo(k.CFrame)
	end
end

function class:_Setup()
	local function fire_hitbox_removed(p2)
		local _fire_hitbox = self._fire_hitboxes[p2]

		if not _fire_hitbox then
			return
		end

		_fire_hitbox.Destroyed = true

		for _, emitter in pairs(_fire_hitbox.Visual:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end

		BetterDebris:AddItem(_fire_hitbox.Visual, 10)

		if _fire_hitbox.Visual.Name == "Hot Coals" then
			for _, child in pairs(_fire_hitbox.Visual.Coals:GetChildren()) do
				child.Color = Color3.fromRGB(0, 0, 0)
				local v = child
				task.delay(0.5 * math.random(), function()
					TweenService:Create(
						v,
						TweenInfo.new(0.25 + 0.5 * math.random(), Enum.EasingStyle.Quint, Enum.EasingDirection.In),
						{
							Size = createVector(0, 0, 0)
						}
					):Play()
				end)
			end
		end

		local volume = _fire_hitbox.Sound1 and _fire_hitbox.Sound1.Volume
		local volume2 = _fire_hitbox.Sound2 and _fire_hitbox.Sound2.Volume
		local pointLight = _fire_hitbox.Visual.Primary.PointLight
		Utility:RenderstepForLoop(0, 100, 1, function(p3)
			local v = 1 - (p3 / 100) ^ 2

			if _fire_hitbox.Sound1 then
				_fire_hitbox.Sound1.Volume = volume * v
			end

			if _fire_hitbox.Sound2 then
				_fire_hitbox.Sound2.Volume = volume2 * v
			end

			pointLight.Brightness = 3 * v
		end)
		self._fire_hitboxes[p2] = nil
	end

	CollectionService:GetInstanceRemovedSignal("FireHitbox"):Connect(fire_hitbox_removed)

	local function fire_hitbox_added(instance)
		local isMain = instance:GetAttribute("IsMain")
		local objectID = instance:GetAttribute("ObjectID")
		local viewModelName = instance:GetAttribute("ViewModelName") or "Default"
		local clone = (fireHitboxes:FindFirstChild(viewModelName) or fireHitboxes.Default):Clone()
		clone.PrimaryPart = clone.Primary
		clone.Primary.Size = instance.Size
		clone:PivotTo(instance.CFrame)
		clone.Parent = workspace

		if isMain and clone.Primary:FindFirstChild("Fire") then
			clone.Primary.Fire.Acceleration = createVector(0, 10, 0)
		end

		local wrap = FighterController:GetWrap(objectID)

		if wrap then
			WrapController:ApplyWrap(WrapController:RecordOriginalWrapProperties(clone), wrap, true)
		end

		local sound, sound2

		if isMain then
			local v3 = math.max(instance.Size.X, instance.Size.Y, instance.Size.Z) * 1.5
			sound = Utility:CreateSound(
				"rbxassetid://13702989275",
				0.5,
				0.7 + 0.3 * math.random(),
				clone.Primary,
				true,
				nil,
				v3
			)

			if viewModelName == "Campfire Stick" then
				sound2 = Utility:CreateSound("rbxassetid://115255932685592", 1.25, 1, clone.Primary, true, nil, v3)
			else
				sound2 = Utility:CreateSound("rbxassetid://14812827622", 1.25, 0.875, clone.Primary, true, nil, v3)
			end
		end

		local v3 = {
			Visual = clone,
			Sound1 = sound,
			Sound2 = sound2,
			Destroyed = false
		}
		self._fire_hitboxes[instance] = v3

		if v3.Visual.Name == "Hot Coals" then
			for _, child in pairs(v3.Visual.Coals:GetChildren()) do
				local size = child.Size
				child.Size = createVector(0, 0, 0)
				child.CFrame *= CFrame.Angles(
					6.283185307179586 * math.random(),
					6.283185307179586 * math.random(),
					6.283185307179586 * math.random()
				)
				local v4 = child
				task.delay(0.5 * math.random(), function()
					if v3.Destroyed then
						return
					end

					TweenService:Create(
						v4,
						TweenInfo.new(1 * math.random(), Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
						{
							Size = size
						}
					):Play()
				end)
			end
		end
	end

	CollectionService:GetInstanceAddedSignal("FireHitbox"):Connect(fire_hitbox_added)

	for _, v in pairs(CollectionService:GetTagged("FireHitbox")) do
		task.spawn(fire_hitbox_added, v)
	end
end

function class:_Init()
	self:_Setup()
end

return class._new()