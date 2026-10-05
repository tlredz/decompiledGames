local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Players = game:GetService("Players")
local CONSTANTS = require(ReplicatedStorage.Modules.CONSTANTS)
local TestLibrary = require(ReplicatedStorage.Modules.TestLibrary)
local Utility = require(ReplicatedStorage.Modules.Utility)
local CollisionsService = CONSTANTS.IS_SERVER and require(ServerStorage.Services.CollisionsService)

if CONSTANTS.IS_CLIENT then
	require(Players.LocalPlayer.PlayerScripts.Controllers.PlayerDataController)
end

local SpectateController = CONSTANTS.IS_CLIENT and require(Players.LocalPlayer.PlayerScripts.Controllers.SpectateController)
local testAttribute = TestLibrary:GetTestAttribute("StudioPing")
local IS_STUDIO = CONSTANTS.IS_STUDIO
local Finisher = {}
Finisher.__index = Finisher

function Finisher.new(instance, is_final_finisher, eliminator)
	local v

	if typeof(instance) == "Instance" then
		v = instance:IsA("Humanoid") or instance:IsA("BasePart")
	else
		v = false
	end

	assert(v, "Argument 1 invalid, expected a Humanoid or BasePart")
	local object = setmetatable({}, Finisher)
	object._subject = instance
	object._is_humanoid = object._subject:IsA("Humanoid")
	object._is_final_finisher = is_final_finisher
	object._eliminator = eliminator
	object._anchor_model_hash = 0
	object._destroy_these = {}
	object._connections = {}
	object._threads = {}
	object._destroyed = false
	object._serial = nil
	object._seed = math.random(1, 1000000)
	object._original_collision_groups = {}
	object._ragdolled = false
	object:_Init()
	return object
end

function Finisher:CreateSound(p, p2, p3, p4, p5, p6, p7, p8, _, p9)
	local sound = Utility:CreateSound(
		p,
		p2,
		p3,
		p4 or self._is_humanoid and self._subject.RootPart,
		p5,
		p6,
		p7,
		p8,
		self:_GetSoundGroup(),
		p9
	)
	table.insert(self._destroy_these, sound)
	return sound
end

function Finisher:Simulate(callback)
	local bindableEvent = Instance.new("BindableEvent")
	table.insert(self._destroy_these, bindableEvent)
	local count = 0
	task.spawn(function()
		local success, result = pcall(self.PlayServer, self, true)

		if not success and callback then
			callback(result)
		end

		if not success and IS_STUDIO then
			error(result)
		end

		count += 1
		bindableEvent:Fire()
	end)
	task.spawn(function()
		if testAttribute and testAttribute > 0 then
			wait(testAttribute / 1000)
		end

		local success, result = pcall(self.PlayClient, self, true)

		if not success and callback then
			callback(result)
		end

		if not success and IS_STUDIO then
			error(result)
		end

		count += 1
		bindableEvent:Fire()
	end)

	while count < 2 do
		bindableEvent.Event:Wait()
	end
end

function Finisher.PlayServer(_, _) end

function Finisher.PlayClient(_, _) end

function Finisher:SetSerial(serial)
	self._serial = serial
end

function Finisher:Serialize()
	return {
		Seed = self._seed
	}
end

function Finisher:Destroy()
	self._destroyed = true

	for _, _connection in pairs(self._connections) do
		_connection:Disconnect()
	end

	for _, v in pairs(self._destroy_these) do
		v:Destroy()
	end

	for _, _thread in pairs(self._threads) do
		pcall(task.cancel, _thread)
	end
end

function Finisher:_GetSoundGroup()
	local _eliminator

	if typeof(self._eliminator) == "Instance" then
		_eliminator = self._eliminator
	else
		_eliminator = false
	end

	local player = SpectateController and SpectateController.CurrentSubject and SpectateController.CurrentSubject.Player

	if _eliminator and _eliminator ~= player then
		return "FinisherFromOthers"
	end

	return "Finisher"
end

function Finisher._GetGroundPosition(_, p, p2)
	return Utility:Raycast(p, p + createVector(0, -100, 0), 100, p2, Enum.RaycastFilterType.Exclude).Position
end

function Finisher:_HideBody(list)
	for _, part in pairs(self:_GetObjects(true)) do
		if list and table.find(list, part) then
			continue
		end

		if part:IsA("BasePart") then
			part.Transparency = 1
			part.Size = createVector(0, 0, 0)
		elseif part ~= self._subject then
			part:Destroy()
		end
	end
end

function Finisher:_GetObjects(p2)
	return self._is_humanoid and (not self._subject.Parent and {} or self._subject.Parent[p2 and "GetDescendants" or "GetChildren"](self._subject.Parent)) or { self._subject }
end

function Finisher:_BreakJoints()
	if not (self._is_humanoid and self._subject.Parent) then
		return
	end

	for _, descendant in pairs(self._subject.Parent:GetDescendants()) do
		if descendant:IsA("Motor6D") then
			descendant.Part0 = nil
			descendant.Part1 = nil
			descendant:Destroy()
		elseif descendant:IsA("MeshPart") then
			descendant.AssemblyLinearVelocity = self._subject.RootPart.AssemblyLinearVelocity
			descendant.AssemblyAngularVelocity = self._subject.RootPart.AssemblyAngularVelocity

			if descendant.Name == "Head" and descendant.Parent == self._subject.Parent then
				descendant.CanCollide = true
			end
		end
	end

	self._subject.Parent.DescendantAdded:Connect(function(motor6D)
		if not motor6D:IsA("Motor6D") then
			return
		end

		motor6D.Part0 = nil
		motor6D.Part1 = nil
		task.defer(motor6D.Destroy, motor6D)
	end)
end

function Finisher:_AnchorModel(value, p)
	self._anchor_model_hash += 1
	local _anchor_model_hash = self._anchor_model_hash

	if not self._is_humanoid then
		return
	end

	local v = value or 3
	local anchored = p == nil or p

	local function anchor()
		if not self._subject.Parent or _anchor_model_hash ~= self._anchor_model_hash then
			return
		end

		for _, part in pairs(self._subject.Parent:GetDescendants()) do
			if not part:IsA("BasePart") then
				continue
			end

			if CollisionsService then
				CollisionsService:ClearSetDescendantsLogic(part, true)
			end

			self._original_collision_groups[part] = self._original_collision_groups[part] or part.CollisionGroup
			part.CollisionGroup = anchored and "Noclip" or self._original_collision_groups[part] or part.CollisionGroup
			part.Anchored = anchored
		end
	end

	if v <= 0 then
		task.spawn(anchor)
	else
		task.delay(v or 3, anchor)
	end
end

function Finisher:_Ragdoll()
	if not (self._is_humanoid and self._subject.Parent) then
		return
	end

	self._ragdolled = true

	for _, descendant in pairs(self._subject.Parent:GetDescendants()) do
		if descendant:IsA("AnimationConstraint") then
			descendant.Enabled = false
		elseif descendant:IsA("Motor6D") then
			local attachment = Instance.new("Attachment")
			attachment.CFrame = descendant.C0
			attachment.Name = descendant.Name .. " - A0"
			attachment.Parent = descendant.Part0
			local attachment2 = Instance.new("Attachment")
			attachment2.CFrame = descendant.C1
			attachment2.Name = descendant.Name .. " - A1"
			attachment2.Parent = descendant.Part1
			local ballSocketConstraint = Instance.new("BallSocketConstraint")
			ballSocketConstraint.Attachment0 = attachment
			ballSocketConstraint.Attachment1 = attachment2
			ballSocketConstraint.Name = "RagdollBSC"
			ballSocketConstraint.LimitsEnabled = true
			ballSocketConstraint.TwistLimitsEnabled = true
			ballSocketConstraint.MaxFrictionTorque = 10
			ballSocketConstraint.Parent = descendant.Part0
			descendant:Destroy()
		end
	end

	self._subject.Parent.DescendantAdded:Connect(function(motor6D)
		if motor6D:IsA("Motor6D") then
			task.defer(motor6D.Destroy, motor6D)
		end
	end)
end

function Finisher:_InternalThread(callback, ...)
	local v = nil

	if IS_STUDIO then
		v = callback(...)
	else
		pcall(function(...)
			v = callback(...)
		end, ...)
	end

	table.insert(self._threads, v)
	return v
end

function Finisher:_Setup()
	if not (self._is_humanoid and CONSTANTS.IS_SERVER) then
		return
	end

	for _, numberValue in pairs(self._subject:GetChildren()) do
		if numberValue:IsA("NumberValue") then
			task.defer(numberValue.Destroy, numberValue)
		end
	end
end

function Finisher:_Init()
	self._subject.Destroying:Connect(function()
		self:Destroy()
	end)
	self:_Setup()
end

return Finisher