local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ConcertSharedConfig = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("ConcertSharedConfig"))
local ConcertOrbController = {}
ConcertOrbController.__index = ConcertOrbController

function ConcertOrbController.new()
	local object = setmetatable({}, ConcertOrbController)
	object._winsSpawnPart = nil
	object._player = Players.LocalPlayer
	object._activeOrbs = {}
	task.spawn(function()
		object._orbCollectedRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("ConcertOrbCollected", 10)

		if not object._orbCollectedRemote then
			warn("[ConcertOrbController] RemoteEvent 'ConcertOrbCollected' not found in Remotes!")
		end
	end)
	return object
end

function ConcertOrbController:scan(parent)
	if not parent then
		return
	end

	if parent.Parent and parent.Parent:IsA("Model") then
		parent = parent.Parent
	end

	local winsSpawnPart = nil

	for _, part in ipairs(parent:GetDescendants()) do
		if not (part:IsA("BasePart") and part.Name == "WinsSpawn") then
			continue
		end

		winsSpawnPart = part
		break
	end

	if winsSpawnPart then
		self._winsSpawnPart = winsSpawnPart
	else
		warn("[ConcertOrbController] Missing part 'WinsSpawn' in scene.")
	end
end

function ConcertOrbController:spawnOrbs(p: number)
	if not self._winsSpawnPart or (not p or p <= 0) then
		return
	end

	local collectibleOrb = ReplicatedStorage:WaitForChild("AdminAbuse"):WaitForChild("CollectibleOrb", 5)

	if not collectibleOrb then
		warn("[ConcertOrbController] CollectibleOrb template not found in ReplicatedStorage.AdminAbuse")
		return
	end

	local cFrame = self._winsSpawnPart.CFrame
	local halfSize = self._winsSpawnPart.Size / 2

	for _ = 1, p do
		local clone = collectibleOrb:Clone()
		local vector = Vector3.new(
			(math.random() * 2 - 1) * halfSize.X,
			(math.random() * 2 - 1) * halfSize.Y,
			(math.random() * 2 - 1) * halfSize.Z
		)
		clone.CFrame = cFrame * CFrame.new(vector)
		clone.Anchored = false
		clone.CanCollide = true
		local currentPhysicalProperties = clone.CurrentPhysicalProperties
		local v2 = (not currentPhysicalProperties and 0.7 or currentPhysicalProperties.Density) * (ConcertSharedConfig.OrbMassMultiplier or 1)
		clone.CustomPhysicalProperties = PhysicalProperties.new(
			v2,
			not currentPhysicalProperties and 0.3 or currentPhysicalProperties.Friction or 0.3,
			not currentPhysicalProperties and 0.5 or currentPhysicalProperties.Elasticity or 0.5,
			not currentPhysicalProperties and 1 or currentPhysicalProperties.FrictionWeight or 1,
			currentPhysicalProperties and currentPhysicalProperties.ElasticityWeight or 1
		)
		clone.Parent = game:GetService("Workspace")
		table.insert(self._activeOrbs, clone)
		local flag = false
		local touchedConnection = nil
		touchedConnection = clone.Touched:Connect(function(otherPart)
			local character = self._player.Character

			if not character then
				return
			end

			if otherPart:IsDescendantOf(character) then
				if flag then
					return
				end

				flag = true
				touchedConnection:Disconnect()
				clone:Destroy()

				if self._orbCollectedRemote then
					self._orbCollectedRemote:FireServer()
				end
			end
		end)
	end
end

function ConcertOrbController:destroy()
	for _, _activeOrb in ipairs(self._activeOrbs) do
		if _activeOrb and _activeOrb.Parent then
			_activeOrb:Destroy()
		end
	end

	table.clear(self._activeOrbs)
	self._winsSpawnPart = nil
end

return ConcertOrbController