local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local BetterDebris = require(ReplicatedStorage.Modules.BetterDebris)
local Utility = require(ReplicatedStorage.Modules.Utility)
local Gun = require(Players.LocalPlayer.PlayerScripts.Modules.ItemTypes.Gun)
local impactMarkerSplat = Players.LocalPlayer.PlayerScripts.Assets.Misc:WaitForChild("ImpactMarkerSplat")
local v = { "rbxassetid://17098901439", "rbxassetid://17098901515", "rbxassetid://16833617681" }
local object = setmetatable({}, Gun)
object.__index = object

function object.new(...)
	local self = setmetatable(Gun.new(...), object)
	self._grenade_cooldown = 0
	self:_Init()
	return self
end

function object:StartAiming(p)
	if not p and (tick() < self._grenade_cooldown or tick() < self._reload_cooldown or self:IsEquipping()) then
		return
	end

	self._grenade_cooldown = tick() + self.Info.GrenadeCooldown
	self._shoot_cooldown = math.max(self._shoot_cooldown, tick() + self.Info.GrenadeShootCooldown)
	self.ViewModel:StopAnimation("Inspect")
	self.ViewModel:PlayAnimation("Throw", 1)
	self:CooldownEffect("rbxassetid://77802568386086", self.Info.GrenadeCooldown, "Cooldown")
	return true, "StartAiming", (self.ClientFighter:GetCameraData())
end

function object.FinishAiming(_, _)
	return false
end

function object.StartSprinting(_, _)
	return false
end

function object.ReplicateFromServer(object2, p, ...)
	if p ~= "PaintballSplatter" then
		Gun.ReplicateFromServer(object2, p, ...)
		return
	end

	if not object2:IsRendered() then
		return
	end

	local vector, v2, v3 = ...

	if not vector or not v2 or not v3 or vector:FuzzyEq(v2) then
		return
	end

	local raycastResult = Utility:Raycast(
		vector,
		v2,
		(vector - v2).Magnitude + 1,
		{ v3 },
		Enum.RaycastFilterType.Whitelist
	)

	if not raycastResult.Instance then
		return
	end

	object2:_ImpactMarkers({ raycastResult })
end

function object:_ImpactMarker(data)
	local color

	if data.IsFromPaintGrenade then
		color = Color3.fromHSV(math.random(), 0.75, 1)
	else
		color = self.ViewModel:GetPaintballColor()
	end

	local v2 = impactMarkerSplat.Size * (0.5 + 0.75 * math.random()) * 2

	for i = #self._impact_markers, 1, -1 do
		local _impact_marker = self._impact_markers[i]

		if not ((_impact_marker.Position - data.Position).Magnitude <= v2.X / 2 + _impact_marker.Size.X / 2 and _impact_marker.Size.Magnitude < 10) then
			continue
		end

		v2 += _impact_marker.Size
		color:Lerp(_impact_marker.Decal.Color3, 0.5)
		_impact_marker.Decal.Transparency = 1
		BetterDebris:AddItem(_impact_marker, 1)
		table.remove(self._impact_markers, i)
	end

	local clone = impactMarkerSplat:Clone()
	clone.Decal.Color3 = color
	clone.Decal.Texture = v[math.random(#v)]
	clone.Decal.ZIndex = 0.75 + 0.5 * math.random()
	clone.Attachment.Particles.Color = ColorSequence.new(color)
	clone.Size = Vector3.new(math.min(v2.X, 10), math.min(v2.X, 10), 0)
	clone.CFrame = CFrame.new(data.Position, data.Position + data.Normal) * CFrame.Angles(
		0,
		0,
		math.random() * 3.141592653589793 * 2
	)
	clone.Parent = data.Part or workspace
	self:_AddImpactMarker(clone, 10, 40)
	local v3 = v2.Magnitude / impactMarkerSplat.Size.Magnitude
	clone.Attachment.Particles.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.075 * v3, 0.05 * v3),
		NumberSequenceKeypoint.new(1, 0.05 * v3, 0.05 * v3)
	})
	clone.Attachment.Particles:Emit(10)
	self.ViewModel:CustomImpactMarker(clone)

	if not data.IsFromPaintGrenade then
		self.ViewModel:PlaySplatSound(clone)
	end
end

function object._Tracers(p, p2)
	local v2 = {
		Color = ColorSequence.new(p.ViewModel:GetPaintballColor()),
		BeamProperties = {
			LightEmission = 0,
			Brightness = 2
		},
		MaxLength = 2,
		MaxLengthFirstPerson = 5
	}
	return Gun._Tracers(p, p2, v2)
end

function object:_Init()
	self.ProjectileShot:Connect(function(_, p2)
		if p2.Name == "_paintballgun_grenade" then
			return
		end

		local paintballColor = self.ViewModel:GetPaintballColor()
		p2.Ball.Color = paintballColor
		p2.Ball.Trail.Color = ColorSequence.new(paintballColor)
	end)
end

return object