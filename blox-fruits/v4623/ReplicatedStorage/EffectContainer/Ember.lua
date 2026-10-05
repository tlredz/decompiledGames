local createVector = vector.create
local class = {}
class.__index = class
local spr = require(game.ReplicatedStorage.Modules.Util.spr)
local v = {}
local random = Random.new()
local v2 = {}
local v3 = false
local v4 = {
	DragonDojo = {
		Position = createVector(5280.21, 1007.665, 391.7),
		Radius = NumberRange.new(1200, 1500)
	}
}

-- equivalent calls inferred from this helper; original call sites unknown
local function getRandomDirection()
	return Vector3.new(random:NextNumber() - 0.5, random:NextNumber() - 0.5, random:NextNumber() - 0.5).Unit
end

local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage:WaitForChild("FX"))
require(game.ReplicatedStorage.Util)
require(ReplicatedStorage:WaitForChild("Effect"))

local function spawnModel(object, color: Color3?)
	local clone = script.EmberTemplate:Clone()
	clone:FindFirstChildWhichIsA("BodyPosition", true):Destroy()
	local basePart = clone:FindFirstChildWhichIsA("BasePart", true)
	basePart:SetAttribute("ParticleScale", 1)
	clone.PrimaryPart = basePart
	clone:PivotTo(object.Data.emberCF)
	basePart.Anchored = true

	if object.State == "Chase" then
		if object.Touched then
			local touchedConnection = nil

			local function onTouch(p)
				if not (p.Parent and object.Character and p.Parent:IsDescendantOf(object.Character)) then
					return
				end

				if touchedConnection then
					touchedConnection:Disconnect()
					touchedConnection = nil
				end

				object.Touched(object)
			end

			touchedConnection = basePart.Touched:Connect(onTouch)
		end
	elseif object.State == "Attach" then
		clone.Name = `Attached{object.Context}`
		basePart:SetAttribute("ParticleScale", 1)
		basePart:SetAttribute("IsPlayerEmber", true)
		basePart.Size = createVector(1, 1, 1)
	end

	clone.Parent = workspace

	if object.Context == "AzureEmber" then
		local Effect = require(game.ReplicatedStorage.Effect)
		Effect.new("MoonShrine.Wisps"):replicate({
			ID = 1,
			Adornees = { clone.PrimaryPart }
		})
	elseif object.Context == "BlazeEmber" then
		local Effect = require(game.ReplicatedStorage.Effect)
		Effect.new("MoonShrine.Wisps"):replicate({
			ID = 1,
			Adornees = { clone.PrimaryPart },
			Color = color
		})
	end

	object.Data.emberSize = clone:GetExtentsSize()
	return clone
end

function class:Destroy()
	v2[self.UID] = nil

	if self.Model and self.Model.Parent then
		local primaryPart = self.Model.PrimaryPart

		if primaryPart then
			pcall(function()
				spr.stop(primaryPart)
			end)
			local Effect = require(game.ReplicatedStorage.Effect)
			Effect.new("MoonShrine.Wisps"):replicate({
				ID = 2,
				Adornees = { primaryPart },
				Color = self.Color
			})
		end

		self.Model:Destroy()
	end
end

function class:Update(p: number)
	if self.ShouldDestroy and self.ShouldDestroy(self) then
		self:Destroy()
		return
	end

	if not self.Character.Parent or not self.Humanoid.Parent or self.Humanoid.Health == 0 then
		self:Destroy()
		return
	end

	local character = self.Character
	local v5 = assert(self.Model)
	local v6 = assert(v5.PrimaryPart)
	local now = os.clock()

	if self.State == "Chase" then
		debug.profilebegin("Ember/Chase")
		local v7 = v[character]

		if not v7 or now - v7.Last >= 0.1 then
			v[character] = {
				Last = now,
				CFrame = character:GetPivot()
			}
			v7 = v[character]
		end

		if now - self.Data.lastGotEmberCF >= 0.1 then
			self.Data.lastGotEmberCF = now
			self.Data.emberCF = v5:GetPivot()
		end

		local position = v7.CFrame.Position
		local position2 = self.Data.emberCF.Position
		local magnitude = (position2 - position).Magnitude
		local minY = self.Data.minY or position.Y + 1
		local v8 = math.max(position.Y + 25, minY)
		local v9 = true
		local v10

		if self.Data.region then
			local v11 = self.Data.region.Radius.Max * 0.5
			v10 = (position2 - self.Data.region.Position).Magnitude <= v11

			if v10 then
				if (position - self.Data.region.Position).Magnitude <= v11 then
					v9 = true
				else
					v9 = false
				end
			end
		else
			v10 = true
		end

		if v10 and v9 then
			if magnitude <= self.Data.runDistance then
				self.Data.secondsChased += p

				if self.Data.secondsChased >= self.Data.stamina then
					self.Data.currentRunAwaySpeed = math.max(
						self.Data.minRunAwaySpeed,
						self.Data.currentRunAwaySpeed - p * (self.Data.staminaMod or 1)
					)
				end

				local v11 = CFrame.lookAt(position2, position) * CFrame.Angles(0, 3.141592653589793, 0)
				local v12 = math.rad((math.random(-35, 35)))
				local position3 = (v11 * CFrame.Angles(0, v12, 0) * CFrame.new(0, 0, self.Data.runLength)).Position
				spr.target(v6, 1, self.Data.currentRunAwaySpeed, {
					Position = Vector3.new(position3.X, math.clamp(position.Y + 1, minY, v8), position3.Z)
				})
			elseif magnitude <= self.Data.idleDistance then
				if now - self.Data.lastChosePos >= random:NextInteger(2, 3) then
					self.Data.lastChosePos = now
					local v11 = position2 + getRandomDirection() * self.Data.idleLength
					local vector2 = Vector3.new(v11.X, math.clamp(v11.Y, minY, v8), v11.Z)
					spr.target(v6, 1, 0.3, {
						Position = vector2
					})
				end
			else
				spr.target(v6, 1, 0.3, {
					Position = position
				})
			end
		else
			assert(self.Data.region)

			if now - self.Data.lastChosePos >= random:NextInteger(4, 6) then
				self.Data.lastChosePos = now
				local position3 = self.Data.region.Position
				local v11 = position + Vector3.new(random:NextInteger(-60, 10), 0, 0)
				local v12 = v11.Y + random:NextInteger(0, v8)
				local position4 = position3 + (Vector3.new(v11.X, math.clamp(v12, minY, v8), v11.Z) - position3).Unit * (self.Data.region.Radius.Min * 0.5)
				spr.target(v6, 1, 0.15, {
					Position = position4
				})
			end
		end

		debug.profileend()

		if self.OnUpdate then
			self.OnUpdate(self)
		end
	elseif self.State == "Attach" and now - self.Data.lastChoseAttach >= 1 then
		debug.profilebegin("Ember/Attach")
		self.Data.lastChoseAttach = now
		local emberSize = self.Data.emberSize
		local v7 = math.max(emberSize.X, emberSize.Y, emberSize.Z)
		local boundingBox, v8 = character:GetBoundingBox()
		local position = (boundingBox * CFrame.new(0, 0, v8.Z) * CFrame.new(3, -0.5, v7)).Position
		spr.target(v6, 1, 1, {
			Position = position
		})
		debug.profileend()

		if self.OnUpdate then
			self.OnUpdate(self)
		end
	end
end

local total = 0.1
return function(player)
	local v5 = {
		Character = assert(player.Character),
		Humanoid = assert(player.Humanoid),
		Context = assert(player.Context),
		State = player.State or "Chase",
		OnUpdate = player.OnUpdate,
		Touched = player.Touched,
		ShouldDestroy = player.ShouldDestroy,
		UID = 0,
		Data = 0
	}
	local HttpService = game:GetService("HttpService")
	v5.UID = HttpService:GenerateGUID(false)
	v5.Data = {
		expires = player.Expires or nil,
		emberCF = player.CFrame,
		emberSize = createVector(0, 0, 0),
		secondsChased = 0,
		lastGotEmberCF = 0,
		lastChosePos = 0,
		lastAttachedPos = 0,
		lastChoseAttach = 0,
		staminaMod = player.StaminaMod or 1,
		minRunAwaySpeed = player.MinRunAwaySpeed or 0.5,
		maxRunAwaySpeed = player.MaxRunAwaySpeed or 0.9,
		currentRunAwaySpeed = player.CurrentRunAwaySpeed or player.MaxRunAwaySpeed or 0.9,
		stamina = player.Stamina or 5,
		runDistance = player.RunDistance or 100,
		idleDistance = player.IdleDistance or 500,
		chaseDistance = player.ChaseDistance or 1000,
		idleLength = player.IdleLength or 75,
		runLength = player.RunLength or -35,
		minY = player.MinY or nil
	}

	if player.Region then
		v5.Data.region = table.clone(assert(v4[player.Region]))
	end

	local object = setmetatable(v5, class)
	v5.Model = spawnModel(object, player.Color)
	v5.Color = player.Color
	total = 0.1

	if not v3 then
		v3 = true
		local RunService = game:GetService("RunService")
		RunService:BindToRenderStep("EmberMovement", Enum.RenderPriority.Last.Value - 1000, function(p)
			if next(v2) or not v3 then
				total += p

				if total >= 0.1 then
					total = 0

					for _, v6 in pairs(v2) do
						v6:Update(p)

						if v6.Data.expires and v6.Data.expires - workspace:GetServerTimeNow() <= 0 then
							v6:Destroy()
						end
					end
				end
			else
				local RunService2 = game:GetService("RunService")
				RunService2:UnbindFromRenderStep("EmberMovement")
				v3 = false
				table.clear(v)
			end
		end)
	end

	v2[v5.UID] = object
	return object
end