local createVector = vector.create
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local GlobalUtil = require(game.ReplicatedStorage.GlobalUtil)
game:GetService("CollectionService")
local RunService = game:GetService("RunService")
local v = RunService:IsRunning() and GlobalUtil.FFlags.IsUnitTest == false
local RunService2 = game:GetService("RunService")
local isServer = RunService2:IsServer()
local RunService3 = game:GetService("RunService")
local isClient = RunService3:IsClient()
local PositionValidationService

if isServer then
	PositionValidationService = require(game.ServerScriptService.Services.PositionValidationService)
else
	PositionValidationService = nil
end

require(script.Types)
local v2 = {
	BodyVelocity = {
		MaxForce = createVector(300000, 300000, 300000),
		P = 15000
	},
	BodyPosition = {
		MaxForce = createVector(30000000, 30000000, 30000000),
		P = 9000,
		D = 325
	},
	BodyGyro = {
		MaxTorque = createVector(400000, 400000, 400000),
		P = 10000,
		D = 150
	},
	AlignPosition = {
		ApplyAtCenterOfMass = true,
		RigidityEnabled = true,
		Mode = Enum.PositionAlignmentMode.OneAttachment
	}
}
require(game.ReplicatedStorage.Util.Anims)

local function special(character)
	if not character then
		return nil
	end

	local playerFromCharacter = Players:GetPlayerFromCharacter(character)

	if isServer and playerFromCharacter and isClient == false then
		return playerFromCharacter
	end

	return nil
end

local v3 = {}
local v4 = {}
task.spawn(function()
	while task.wait(10) do
		for k, _ in next, v3, nil do
			if k.Parent ~= nil then
				continue
			end

			v3[k] = nil
			v4[k] = nil
		end
	end
end)

function removeEntry(list, p: string)
	for i = 1, #list do
		if list[i].key ~= p then
			continue
		end

		table.remove(list, i)
		break
	end
end

function insertEntry(list, p)
	local GUID = HttpService:GenerateGUID(false)
	table.insert(list, {
		key = GUID,
		value = p
	})
	return GUID
end

local bodyMover = game.ReplicatedStorage.Remotes.BodyMover
local v5 = {}
local class = {}
class.__index = class
local class2 = {}
class2.__index = class2

function class.new(instance, options)
	local meta = options or {}
	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")
	local v7

	if isClient and not Players:GetPlayerFromCharacter(instance) and humanoidRootPart and not humanoidRootPart:FindFirstChild("CharacterMimic") then
		warn("DANGEROUS BODYMOVER DETECTED. DO NOT INSTANCE ENEMY BODYMOVERS IN THE CLIENT.")
		v7 = true
	else
		v7 = false
	end

	local antiMover = instance:FindFirstChild("AntiMover")

	if meta.BypassAntiMover then
		antiMover = nil
	end

	if humanoidRootPart and not (antiMover or v7) then
		assert(humanoidRootPart:IsA("BasePart"))

		if isServer then
			local Global = require(game.ReplicatedStorage.Global)
			humanoidRootPart = Global.ensureOriginalRoot(humanoidRootPart)
		end

		local playerFromCharacter

		if instance then
			playerFromCharacter = Players:GetPlayerFromCharacter(instance)

			if not isServer or not playerFromCharacter or isClient ~= false then
				playerFromCharacter = nil
			end
		end

		if playerFromCharacter then
			return (setmetatable({
				Parent = humanoidRootPart,
				Player = Players:GetPlayerFromCharacter(instance),
				Meta = meta
			}, {
				__index = class
			}))
		end

		local v8 = v4[instance]

		if v8 then
			return v8
		end

		local bodyVelocity = humanoidRootPart:FindFirstChild("BodyVelocity") or instance:FindFirstChild("BodyVelocity")
		local bodyPosition = humanoidRootPart:FindFirstChild("BodyPosition") or instance:FindFirstChild("BodyPosition")
		local bodyGyro = humanoidRootPart:FindFirstChild("BodyGyro") or instance:FindFirstChild("BodyGyro")

		if not (bodyVelocity and bodyPosition and bodyGyro) then
			bodyVelocity = Instance.new("BodyVelocity")
			bodyPosition = Instance.new("BodyPosition")
			bodyGyro = Instance.new("BodyGyro")
			assert(bodyVelocity and bodyVelocity:IsA("BodyVelocity"))
			assert(bodyPosition and bodyPosition:IsA("BodyPosition"))
			assert(bodyGyro and bodyGyro:IsA("BodyGyro"))
			bodyVelocity.MaxForce = Vector3.new()
			bodyPosition.MaxForce = Vector3.new()
			bodyGyro.MaxTorque = Vector3.new()
		end

		if not v3[instance] then
			v3[instance] = {
				BodyVelocity = {},
				BodyPosition = {},
				BodyGyro = {}
			}
		end

		assert(bodyVelocity and bodyVelocity:IsA("BodyVelocity"))
		assert(bodyPosition and bodyPosition:IsA("BodyPosition"))
		assert(bodyGyro and bodyGyro:IsA("BodyGyro"))
		local running = v3[instance]
		assert(running)
		local object = setmetatable({
			Running = running,
			Parent = humanoidRootPart,
			BodyVelocity = bodyVelocity,
			BodyPosition = bodyPosition,
			BodyGyro = bodyGyro
		}, {
			__index = class
		})
		v4[instance] = object

		if isClient and game.Players:GetPlayerFromCharacter(instance) == game.Players.LocalPlayer then
			object.Player2 = true
		end

		if isServer then
			object.Meta = meta
		end

		return object
	else
		local v8 = nil
		v8 = setmetatable({}, {
			__index = function()
				return v8
			end,
			__call = function()
				return v8
			end
		})
		return v8
	end
end

function class.GetActive(_, p)
	return v3[p]
end

function class:Create(p, p2)
	if not self.Player then
		for k, v6 in next, v2[p], nil do
			if not p2[k] then
				p2[k] = v6
			end
		end

		local values = {}
		local v7 = 2.35
		local lastClassicScale = self.Parent:GetAttribute("LastClassicScale")

		if lastClassicScale then
			v7 *= lastClassicScale
		elseif not self.Parent:GetAttribute("HrpSizeScale") then
			v7 = math.max(self.Parent.Size.Y, v7)
		end

		for k, v8 in next, p2, nil do
			if not (k ~= "Duration" and k ~= "Priority" and k ~= "AirFix" and k ~= "AnimationType") then
				continue
			end

			if k == "Meta" then
				continue
			end

			values[k] = k == "Velocity" and (v8 ~= v8 or v8.Magnitude < 0.001) and createVector(0, 0.001, 0) or v8

			if not (k == "MaxForce" or k == "MaxTorque") then
				continue
			end

			local v9 = values[k] * (v7 - 1) ^ 2
			values[k] = Vector3.new(math.min(600000, v9.X), math.min(600000, v9.Y), (math.min(600000, v9.Z))) * (p == "BodyVelocity" and 1.5 or 15)
		end

		p2.Values = values
		p2.Priority = p2.Priority or 1
		p2.Duration = p2.Duration or 1e999
		p2.AirFix = p2.AirFix or false
		p2.Type = p
		p2.StartTime = tick()
		p2.Enabled = true
		p2.LastCurrent = false
		p2.ApplyCounter = 0
		p2.Parent = self
	end

	if self.Player then
		p2.ID = math.random(9999999)
		p2.Character = self.Player.Character
	elseif self.Player2 then
		local v6 = 1e999

		if p == "BodyPosition" then
			local values = p2.Values
			v6 = ((values.MaxForce or createVector(0, 0, 0)).X > 0 or (values.MaxForce or createVector(0, 0, 0)).Z > 0) and 600 or v6
		end

		p2.Duration = math.min(p2.Duration or 1e999, v6)
	end

	if self.Meta then
		p2.Meta = self.Meta
	end

	if p2.Velocity and p2.Velocity ~= p2.Velocity then
		p2.Velocity = createVector(0, 0, 0)
	end

	local stunObjects = isServer and p2.AnimationType ~= "None" and self.Parent:FindFirstChild("StunObjects")

	if stunObjects then
		if p2.Velocity then
			local folder = Instance.new("Folder")
			folder.Name = "_"
			folder:SetAttribute("LastBodyVelocityValue", p2.Velocity)
			folder:SetAttribute("LastBodyVelocityDuration", p2.Duration or 1e999)
			folder:SetAttribute("LastBodyVelocityTimestamp", workspace:GetServerTimeNow())
			folder:SetAttribute("LastBodyVelocityPriority", p2.Priority or 1)

			if p2.AnimationType then
				folder:SetAttribute("AnimationType", p2.AnimationType)
			end

			folder.Parent = stunObjects

			function p2.DestroyCallback()
				p2.DestroyCallback = nil
				folder.Name = "_"
				folder:Destroy()
			end

			if p2.Duration and p2.Duration < 1000000 then
				task.delay(p2.Duration, p2.DestroyCallback)
			end

			local StunAnimator = require(game.ServerStorage.StunAnimator)
			StunAnimator(self.Parent.Parent, nil)
		elseif p2.Position then
			local folder = Instance.new("Folder")
			folder.Name = "_"
			folder:SetAttribute("LastBodyVelocityValue", createVector(0, 0.001, 0))
			folder:SetAttribute("LastBodyVelocityDuration", p2.Duration or 1e999)
			folder:SetAttribute("LastBodyVelocityTimestamp", workspace:GetServerTimeNow())
			folder:SetAttribute("LastBodyVelocityPriority", p2.Priority or 1)

			if p2.AnimationType then
				folder:SetAttribute("AnimationType", p2.AnimationType)
			end

			folder.Parent = stunObjects

			function p2.DestroyCallback()
				p2.DestroyCallback = nil
				folder.Name = "_"
				folder:Destroy()
			end

			if p2.Duration and p2.Duration < 1000000 then
				task.delay(p2.Duration, p2.DestroyCallback)
			end

			local StunAnimator = require(game.ServerStorage.StunAnimator)
			StunAnimator(self.Parent.Parent, nil)
		end
	end

	local object = setmetatable(p2, {
		__index = class2
	})

	if self.Player then
		if not (self.Player and isServer) then
			return object
		end

		if PositionValidationService then
			PositionValidationService.onBodyMoverCreated(self.Player, object, p, p2)
		end

		local player = self.Player
		local Global = require(game.ReplicatedStorage.Global)
		bodyMover:FireClient(player, Global.Encode(object), "Create", p, p2)
		return object
	else
		insertEntry(self.Running[p], object)
		self:UpdateAll(0)
		return object
	end
end

function class:UpdateAll(_: number)
	local now = tick()

	for k, v6 in next, v3, nil do
		local humanoidRootPart = k and k:FindFirstChild("HumanoidRootPart")

		for _, v7 in next, { "BodyVelocity", "BodyGyro", "BodyPosition" }, nil do
			local v8 = v6[v7]
			local object = setmetatable({
				Priority = -1e999,
				Enabled = false,
				Type = v7,
				Parent = humanoidRootPart,
				Values = {
					[v7 == "BodyGyro" and "MaxTorque" or "MaxForce"] = Vector3.new(),
					P = 0,
					[v7 == "BodyVelocity" and "_D" or "D"] = 0
				}
			}, {
				__index = class2
			})

			for _, v9 in pairs(v8) do
				local key = v9.key
				local value = v9.value

				if now - value.StartTime > value.Duration or value.Removing then
					value.Enabled = false
					value.Removing = true

					if value.DestroyCallback then
						task.spawn(value.DestroyCallback)
					end

					local v10 = v3[k]
					assert(v10)
					removeEntry(v10[v7], key)
					v5[v7] = nil

					if v7 == "BodyPosition" then
						if humanoidRootPart and humanoidRootPart:IsA("BasePart") then
							humanoidRootPart.AssemblyLinearVelocity = Vector3.new()
						end
					elseif v7 == "BodyVelocity" and value.AirFix and humanoidRootPart and humanoidRootPart:IsA("BasePart") then
						humanoidRootPart.AssemblyLinearVelocity *= createVector(0.2, 0.2, 0.2)
					end
				end

				if not (value.Priority >= object.Priority) or value.Removing then
					continue
				end

				object = value
			end

			if object.Enabled then
				if v5[v7] ~= object then
					v5[v7] = object
					object:_SetActive(true)
				end
			else
				if object[v7] ~= object then
					v5[v7] = object

					if humanoidRootPart and humanoidRootPart:FindFirstChild(object.Type) then
						object:_SetActive(false)
					end
				end

				if not object.Parent then
					v5[v7] = nil
				end
			end
		end
	end
end

local function notifyMovementChanged(player, p: string, p2)
	if not (isServer and PositionValidationService and player.Character) then
		return
	end

	local playerFromCharacter = Players:GetPlayerFromCharacter(player.Character)

	if playerFromCharacter then
		PositionValidationService.onBodyMoverChanged(playerFromCharacter, player, p, p2)
	end
end

function class2.SetForce(player, vector2: Vector3)
	local v6 = 2.35
	local lastClassicScale = player.Parent.Parent:GetAttribute("LastClassicScale")

	if lastClassicScale then
		v6 *= lastClassicScale
	elseif not player.Parent.Parent:GetAttribute("HrpSizeScale") then
		v6 = math.max(player.Parent.Parent.Size.Y, v6)
	end

	local vector3 = vector2 * (v6 - 1) ^ 2
	local v7 = Vector3.new(math.min(600000, vector3.X), math.min(600000, vector3.Y), (math.min(600000, vector3.Z))) * 15
	local character = player.Character
	local playerFromCharacter

	if character then
		playerFromCharacter = Players:GetPlayerFromCharacter(character)

		if not isServer or not playerFromCharacter or isClient ~= false then
			playerFromCharacter = nil
		end
	end

	if playerFromCharacter then
		if isServer then
			local playerFromCharacter2 = isServer and PositionValidationService and player.Character and Players:GetPlayerFromCharacter(player.Character)

			if playerFromCharacter2 then
				PositionValidationService.onBodyMoverChanged(playerFromCharacter2, player, "SetForce", v7)
			end

			local character2 = player.Character
			local playerFromCharacter3

			if character2 then
				playerFromCharacter3 = Players:GetPlayerFromCharacter(character2)

				if not isServer or not playerFromCharacter3 or isClient ~= false then
					playerFromCharacter3 = nil
				end
			end

			local Global = require(game.ReplicatedStorage.Global)
			bodyMover:FireClient(playerFromCharacter3, Global.Encode(player), "SetForce", v7)
		end
	else
		local v8 = player.Parent[player.Type]
		local v9 = v5[player.Type] == player

		if player.Type == "BodyVelocity" then
			player.Values.MaxForce = v7

			if v9 then
				v8.MaxForce = v7
			end
		elseif player.Type == "BodyPosition" then
			player.Values.MaxForce = v7

			if v9 then
				v8.MaxForce = v7
			end
		elseif player.Type == "BodyGyro" then
			player.Values.MaxTorque = v7

			if v9 then
				v8.MaxTorque = v7
			end
		end
	end
end

function class2:Set(p)
	local character = self.Character
	local playerFromCharacter

	if character then
		playerFromCharacter = Players:GetPlayerFromCharacter(character)

		if not isServer or not playerFromCharacter or isClient ~= false then
			playerFromCharacter = nil
		end
	end

	if playerFromCharacter then
		local playerFromCharacter2 = isServer and PositionValidationService and self.Character and Players:GetPlayerFromCharacter(self.Character)

		if playerFromCharacter2 then
			PositionValidationService.onBodyMoverChanged(playerFromCharacter2, self, "Set", p)
		end

		local character2 = self.Character
		local playerFromCharacter3

		if character2 then
			playerFromCharacter3 = Players:GetPlayerFromCharacter(character2)

			if not isServer or not playerFromCharacter3 or isClient ~= false then
				playerFromCharacter3 = nil
			end
		end

		local Global = require(game.ReplicatedStorage.Global)
		bodyMover:FireClient(playerFromCharacter3, Global.Encode(self), "Set", p)
	else
		local v6 = self.Parent[self.Type]
		local v7 = v5[self.Type] == self

		if self.Type == "BodyVelocity" then
			local velocity = (p ~= p or p.Magnitude < 0.001) and createVector(0, 0.001, 0) or p
			assert(typeof(velocity) == "Vector3")
			self.Values.Velocity = velocity

			if v7 then
				v6.Velocity = velocity
			end
		elseif self.Type == "BodyPosition" then
			local values = self.Values
			assert(typeof(p) == "Vector3")
			values.Position = p

			if v7 then
				v6.Position = p
			end
		elseif self.Type == "AlignPosition" then
			local values = self.Values
			assert(typeof(p) == "Vector3")
			values.Position = p

			if v7 then
				v6.Position = p
			end
		elseif self.Type == "BodyGyro" then
			local values = self.Values
			assert(typeof(p) == "CFrame")
			values.CFrame = p

			if v7 then
				v6.CFrame = p
			end
		end
	end
end

function class2:Enable()
	local character = self.Character
	local playerFromCharacter

	if character then
		playerFromCharacter = Players:GetPlayerFromCharacter(character)

		if not isServer or not playerFromCharacter or isClient ~= false then
			playerFromCharacter = nil
		end
	end

	if playerFromCharacter then
		local playerFromCharacter2 = isServer and PositionValidationService and self.Character and Players:GetPlayerFromCharacter(self.Character)

		if playerFromCharacter2 then
			PositionValidationService.onBodyMoverChanged(playerFromCharacter2, self, "Enable", nil)
		end

		local character2 = self.Character
		local playerFromCharacter3

		if character2 then
			playerFromCharacter3 = Players:GetPlayerFromCharacter(character2)

			if not isServer or not playerFromCharacter3 or isClient ~= false then
				playerFromCharacter3 = nil
			end
		end

		local Global = require(game.ReplicatedStorage.Global)
		bodyMover:FireClient(playerFromCharacter3, Global.Encode(self), "Enable")
	else
		self.Enabled = true
		class:UpdateAll(0)
	end
end

function class2:Disable()
	local character = self.Character
	local playerFromCharacter

	if character then
		playerFromCharacter = Players:GetPlayerFromCharacter(character)

		if not isServer or not playerFromCharacter or isClient ~= false then
			playerFromCharacter = nil
		end
	end

	if playerFromCharacter then
		local playerFromCharacter2 = isServer and PositionValidationService and self.Character and Players:GetPlayerFromCharacter(self.Character)

		if playerFromCharacter2 then
			PositionValidationService.onBodyMoverChanged(playerFromCharacter2, self, "Disable", nil)
		end

		local character2 = self.Character
		local playerFromCharacter3

		if character2 then
			playerFromCharacter3 = Players:GetPlayerFromCharacter(character2)

			if not isServer or not playerFromCharacter3 or isClient ~= false then
				playerFromCharacter3 = nil
			end
		end

		local Global = require(game.ReplicatedStorage.Global)
		bodyMover:FireClient(playerFromCharacter3, Global.Encode(self), "Disable")
	else
		self.Enabled = false
		class:UpdateAll(0)
	end
end

function class2:Destroy()
	if self.DestroyCallback then
		task.spawn(self.DestroyCallback)
	end

	local character = self.Character
	local playerFromCharacter

	if character then
		playerFromCharacter = Players:GetPlayerFromCharacter(character)

		if not isServer or not playerFromCharacter or isClient ~= false then
			playerFromCharacter = nil
		end
	end

	if playerFromCharacter then
		if isClient then
			return
		end

		local playerFromCharacter2 = isServer and PositionValidationService and self.Character and Players:GetPlayerFromCharacter(self.Character)

		if playerFromCharacter2 then
			PositionValidationService.onBodyMoverChanged(playerFromCharacter2, self, "Destroy", nil)
		end

		local character2 = self.Character
		local playerFromCharacter3

		if character2 then
			playerFromCharacter3 = Players:GetPlayerFromCharacter(character2)

			if not isServer or not playerFromCharacter3 or isClient ~= false then
				playerFromCharacter3 = nil
			end
		end

		local Global = require(game.ReplicatedStorage.Global)
		bodyMover:FireClient(playerFromCharacter3, Global.Encode(self), "Destroy")
	else
		self.Removing = true
		class:UpdateAll(0)
	end
end

function class2:_SetActive(p)
	local v6 = self.Parent[self.Type]

	local function apply()
		for k, value in pairs(self.Values) do
			if not (k ~= "ID" and k ~= "Character" and k ~= "FaceCameraAtEnd" and k ~= "StopOnCollision") then
				continue
			end

			if not (k ~= "FollowVelocity" and k ~= "MaxForce" and k ~= "MaxTorque" and k ~= "_D") then
				continue
			end

			if not (k ~= "DestroyCallback" and k ~= "Meta") then
				continue
			end

			v6[k] = value
		end
	end

	if p then
		apply()
	end

	for k, value in pairs(self.Values) do
		if k == "MaxForce" or k == "MaxTorque" or k == "P" then
			v6[k] = value * (p and 1 or 0)
		end
	end

	local success, result = pcall(function()
		v6.Parent = p and self.Parent.Parent or nil
	end)

	if not (success or result:match("current parent: NULL")) then
		warn(result)
	end
end

local RunService4 = game:GetService("RunService")

if RunService4:IsServer() and v then
	local RunService5 = game:GetService("RunService")
	RunService5.Heartbeat:Connect(function(dt)
		class:UpdateAll(dt)
	end)
else
	local RunService5 = game:GetService("RunService")

	if RunService5:IsClient() and v then
		local RunService6 = game:GetService("RunService")
		RunService6.Stepped:Connect(function(time)
			class:UpdateAll(time)
		end)
	end
end

local RunService5 = game:GetService("RunService")

if RunService5:IsClient() and v then
	task.spawn(function()
		local v6 = {}
		bodyMover.OnClientEvent:Connect(function(p, p2, ...)
			local Global = require(game.ReplicatedStorage.Global)
			local encoded = Global.Encode(p)

			if encoded.Character ~= game.Players.LocalPlayer.Character then
				return
			end

			local v7 = class.new(encoded.Character, encoded.Meta)

			if p2 == "Create" then
				local v8, v9 = ...
				local v10 = class.Create(v7, v8, v9)
				v6[encoded.ID] = v10

				if v9.Duration and v9.Duration < 1000000 then
					delay(v9.Duration + 0.1, function()
						if v6[encoded.ID] then
							v10:Destroy()
							v6[encoded.ID] = nil
						end
					end)
				end
			elseif p2 == "Set" then
				if v6[encoded.ID] then
					v6[encoded.ID]:Set(...)
				end
			elseif p2 == "Enable" then
				if v6[encoded.ID] then
					v6[encoded.ID]:Enable()
				end
			elseif p2 == "Disable" then
				if v6[encoded.ID] then
					v6[encoded.ID]:Disable()
				end
			elseif p2 == "Destroy" and v6[encoded.ID] then
				v6[encoded.ID]:Destroy()
				v6[encoded.ID] = nil
			end
		end)
	end)
end

return {
	new = class.new,
	GetActive = class.GetActive,
	UpdateAll = class.UpdateAll
}