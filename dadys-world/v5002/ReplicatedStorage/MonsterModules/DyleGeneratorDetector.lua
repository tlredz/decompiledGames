local RunService = game:GetService("RunService")
game:GetService("Players")
local DyleGeneratorDetector = {}
DyleGeneratorDetector.__index = DyleGeneratorDetector

function DyleGeneratorDetector.new(character, chaser, rageBar)
	local object = setmetatable({}, DyleGeneratorDetector)
	object.character = character
	object.chaser = chaser
	object.rageBar = rageBar
	object.humanoid = character:WaitForChild("Humanoid")
	object.isPlayerOnGenerator = false
	object.enabled = true
	local DyleMonster = require(game.ReplicatedStorage.MonsterData.DyleMonster)
	object.stopOnGenerators = DyleMonster.StopOnGenerators or false
	object.detectionRange = DyleMonster.GeneratorDetectionRange or 80
	object.freezeTime = DyleMonster.GeneratorFreezeTime or 2.5
	object.isFrozen = false
	object.freezeEndTime = 0

	if not object.stopOnGenerators then
		return nil
	end

	object:startDetection()
	return object
end

function DyleGeneratorDetector:checkPlayersOnGenerators()
	local CollectionService = game:GetService("CollectionService")
	local tagged = CollectionService:GetTagged("Generator")

	if #tagged == 0 then
		local v = {
			workspace:FindFirstChild("Generators"),
			workspace:FindFirstChild("CurrentRoom"),
			workspace:FindFirstChild("Map")
		}

		for _, folder in ipairs(v) do
			if not folder then
				continue
			end

			for _, descendant in ipairs(folder:GetDescendants()) do
				if descendant:FindFirstChild("activeplayer") and descendant.activeplayer:IsA("ObjectValue") then
					table.insert(tagged, descendant)
				end
			end
		end
	end

	for _, v in ipairs(tagged) do
		local activeplayer = v:FindFirstChild("activeplayer")

		if not (activeplayer and activeplayer:IsA("ObjectValue")) then
			continue
		end

		local value = activeplayer.Value

		if value and value.Parent and self:canSeePlayer(value) then
			return true
		end
	end

	return false
end

function DyleGeneratorDetector:canSeePlayer(p2)
	if not self.character:FindFirstChild("HumanoidRootPart") then
		return false
	end

	local position = self.character.HumanoidRootPart.Position
	local position2 = p2.HumanoidRootPart.Position

	if (position - position2).Magnitude > self.detectionRange then
		return false
	end

	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
	raycastParams.FilterDescendantsInstances = { self.character, p2 }
	return workspace:Raycast(position, position2 - position, raycastParams) == nil
end

function DyleGeneratorDetector:updateMovement()
	local now = tick()

	if self.isFrozen then
		if now < self.freezeEndTime then
			return
		end

		self.isFrozen = false

		if self.rageBar then
			self.rageBar:clearSpeedOverride()
		end

		print("DyleGeneratorDetector: Freeze time ended")
	end

	local v = self:checkPlayersOnGenerators()

	if v and not self.isPlayerOnGenerator then
		self.isPlayerOnGenerator = true
		self.isFrozen = true
		self.freezeEndTime = now + self.freezeTime

		if self.rageBar then
			self.rageBar:setSpeedOverride(0, self.freezeTime)
		end

		self.character:SetAttribute("DyleStoppedByGenerator", true)
		print("DyleGeneratorDetector: Stopping for", self.freezeTime, "seconds - player on generator")
	elseif not v and self.isPlayerOnGenerator and not self.isFrozen then
		self.isPlayerOnGenerator = false

		if self.rageBar then
			self.rageBar:clearSpeedOverride()
		end

		self.character:SetAttribute("DyleStoppedByGenerator", false)
		print("DyleGeneratorDetector: Resuming - player left generator")
	end
end

function DyleGeneratorDetector:startDetection()
	self.connection = RunService.Heartbeat:Connect(function()
		if self.enabled and self.character.Parent then
			self:updateMovement()
		end
	end)
end

function DyleGeneratorDetector:stop()
	self.enabled = false

	if self.connection then
		self.connection:Disconnect()
		self.connection = nil
	end

	if self.rageBar then
		self.rageBar:clearSpeedOverride()
	end

	self.character:SetAttribute("DyleStoppedByGenerator", false)
end

function DyleGeneratorDetector:destroy()
	self:stop()
end

return DyleGeneratorDetector