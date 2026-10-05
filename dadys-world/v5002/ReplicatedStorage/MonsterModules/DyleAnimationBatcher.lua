local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DyleAnimationBatcher = {}
DyleAnimationBatcher.__index = DyleAnimationBatcher

function DyleAnimationBatcher.new()
	local self = setmetatable({}, DyleAnimationBatcher)
	self.pendingUpdates = {}
	local events = ReplicatedStorage:FindFirstChild("Events")

	if events then
		self.batchedAnimationEvent = events:FindFirstChild("DyleBatchedAnimation")

		if not self.batchedAnimationEvent then
			self.batchedAnimationEvent = events:FindFirstChild("AnimateTower")
		end
	end

	self:startBatchProcessor()
	return self
end

function DyleAnimationBatcher.queueUpdate(p, character, p3, p4)
	local v = tostring(character)

	if not p.pendingUpdates[v] then
		p.pendingUpdates[v] = {
			character = character,
			updates = {}
		}
	end

	p.pendingUpdates[v].updates[p3] = p4
end

function DyleAnimationBatcher:startBatchProcessor()
	local v = 0
	self.connection = RunService.Heartbeat:Connect(function()
		local now = tick()

		if now - v >= 0.1 then
			self:processBatch()
			v = now
		end
	end)
end

function DyleAnimationBatcher:processBatch()
	local v = false

	for _ in pairs(self.pendingUpdates) do
		v = true
		break
	end

	if not (v and self.batchedAnimationEvent) then
		return
	end

	for _, pendingUpdate in pairs(self.pendingUpdates) do
		local character = pendingUpdate.character

		if not (character and character.Parent) then
			continue
		end

		local v3 = {
			movementState = pendingUpdate.updates.movementState,
			animationSpeed = pendingUpdate.updates.animationSpeed,
			clockAnimation = pendingUpdate.updates.clockAnimation,
			faceTexture = pendingUpdate.updates.faceTexture,
			musicTempo = pendingUpdate.updates.musicTempo
		}
		self.batchedAnimationEvent:FireAllClients(character, "BatchedUpdate", v3)
	end

	self.pendingUpdates = {}
end

function DyleAnimationBatcher:cleanup()
	if self.connection then
		self.connection:Disconnect()
		self.connection = nil
	end

	self.pendingUpdates = {}
end

local v = nil

function DyleAnimationBatcher.getInstance()
	if not v then
		v = DyleAnimationBatcher.new()
	end

	return v
end

return DyleAnimationBatcher