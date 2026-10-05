local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local BetterDebris = require(ReplicatedStorage.Modules.BetterDebris)
local Utility = require(ReplicatedStorage.Modules.Utility)
local ClientViewModel = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("ClientReplicatedClasses"):WaitForChild("ClientFighter"):WaitForChild("ClientItem"):WaitForChild("ClientViewModel"))
local attachment = Players.LocalPlayer.PlayerScripts.Assets.Misc:WaitForChild("PaintGrenadeExplosionEffect"):WaitForChild("Attachment")
local object = setmetatable({}, ClientViewModel)
object.__index = object

function object.new(...)
	local self = setmetatable(ClientViewModel.new(...), object)
	self._last_splat_sound = 0
	self:_Init()
	return self
end

function object.GetPaintballColor(_)
	return Color3.fromHSV(math.random(), 0.75, 1)
end

function object:PlaySplatSound(p2)
	local v = tick() - self._last_splat_sound < 0.001
	self._last_splat_sound = tick()

	-- equivalent calls inferred from this helper; original call sites unknown
	local function play_sound()
		Utility:CreateSound("rbxassetid://16835701807", 0.5 * (v and 0.5 or 1), 1 + 0.4 * math.random(), p2, true, 1)
	end

	if v then
		task.delay(0.25 * math.random(), play_sound)
	else
		play_sound() -- equivalent call inferred; original call site unknown
	end
end

function object.CustomImpactMarker(_, _) end

function object:ExplosionEffect(position, p2)
	local part = Instance.new("Part")
	part.CanCollide = false
	part.CanQuery = false
	part.Anchored = true
	part.Transparency = 1
	part.CFrame = CFrame.new(position)
	part.Parent = workspace
	BetterDebris:AddItem(part, 5)
	Utility:CreateSound("rbxassetid://13455969017", 0.25, 1.4 + 0.2 * math.random(), part, true, 10)
	Utility:CreateSound("rbxassetid://102872919640755", 1.5, 0.9 + 0.2 * math.random(), part, true, 10)
	local clone = attachment:Clone()

	for _, emitter in pairs(clone:GetChildren()) do
		if emitter:IsA("ParticleEmitter") then
			Utility:ScaleParticleEmitter(emitter, p2 / 18)
		end
	end

	clone.Parent = part
	Utility:PlayParticles(clone)
	local v = position + workspace.CurrentCamera.CFrame.LookVector * -3
	local raycastWhitelist = self.ClientItem.ClientFighter:GetRaycastWhitelist()
	local v2 = {
		IsFromPaintGrenade = true
	}

	for i = 1, 4 do
		for i2 = 1, 4 do
			local raycastResult = Utility:Raycast(
				v,
				v + (CFrame.Angles(0, 6.283185307179586 * (i / 4 + 0.2617993877991494 * math.random()), 0) * CFrame.Angles(
					6.283185307179586 * (i2 / 4 + 0.2617993877991494 * math.random()),
					0,
					0
				)).LookVector * p2,
				p2,
				raycastWhitelist,
				Enum.RaycastFilterType.Include
			)

			for _ = 1, 2 do
				local v3 = raycastResult
				task.delay(0.25 * math.random(), function()
					if self._destroyed then
						return
					end

					self.ClientItem:_ImpactMarkers({ v3 }, v2)
				end)
			end
		end
	end
end

function object:_Init() end

return object