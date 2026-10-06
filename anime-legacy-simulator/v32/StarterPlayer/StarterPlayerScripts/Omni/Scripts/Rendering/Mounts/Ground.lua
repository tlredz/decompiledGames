local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Omni = require(ReplicatedStorage:WaitForChild("Omni"))
local mounts = Omni.Services.ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Mounts")
local v = {}
local raycastParams = RaycastParams.new()
raycastParams.RespectCanCollide = true
raycastParams.FilterType = Enum.RaycastFilterType.Include
raycastParams.FilterDescendantsInstances = { workspace.Client.Maps }
local class = {}
class.__index = class

function class:Destroy()
	if self.Folder then
		self.Folder:Destroy()
	end

	for k, connection in self.Connections do
		connection:Disconnect()
		self.Connections[k] = nil
	end

	if self.IsLocal then
		local animate = Omni:GetAnimate()

		if animate then
			animate:RemoveForcedState("Mount")

			for _, child in self.AnimationsFolder.Player:GetChildren() do
				animate:RemoveCustomAnimationForState("Mount", child.Name)
			end
		end
	end

	v[self.Character] = nil
end

function class:Update(_: number)
	local assemblyLinearVelocity = self.HRP.AssemblyLinearVelocity
	local animationState = Vector3.new(assemblyLinearVelocity.X, 0, assemblyLinearVelocity.Z).Magnitude > 1 and "Run" or "Idle"

	if animationState ~= self.AnimationState then
		local animate = Omni:GetAnimate()

		if animate then
			if self.AnimationState then
				local mountAnimation = self.MountAnimations[self.AnimationState]

				if mountAnimation then
					mountAnimation.Track:Stop()
				end

				if self.IsLocal then
					animate:RemoveForcedState("Mount")
				end
			end

			local mountAnimation = self.MountAnimations[animationState]

			if mountAnimation then
				mountAnimation.Track:Play(nil, nil, mountAnimation.Speed)
			end

			if self.IsLocal then
				animate:AddForcedState("Mount", animationState)
			end
		end

		self.AnimationState = animationState
	end
end

local Ground = {}

function Ground.Get(p)
	return v[p]
end

function Ground.Create(player, character, name: string)
	if v[character] then
		return true, v[character]
	end

	local info = Omni.Shared.Mounts.List[name]

	if not info then
		return
	end

	local child = mounts:FindFirstChild(name)

	if not (child and child.Animations and (child.Model and child.Model.PrimaryPart)) then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")

	if not humanoid then
		return
	end

	if not humanoidRootPart:FindFirstChild("RootAttachment") then
		local attachment = Instance.new("Attachment")
		attachment.Name = "RootAttachment"
		attachment.Parent = humanoidRootPart
	end

	local folder = Instance.new("Folder")
	folder.Name = "Mount"
	folder.Parent = workspace.Cache
	local clone = child.Model:Clone()
	clone.Name = "Mount"

	for _, part in clone:GetChildren() do
		if not part:IsA("BasePart") then
			continue
		end

		local name2 = part.Name
		local child2 = character:FindFirstChild(name2 == "RootPart" and "HumanoidRootPart" or name2)

		if not child2 then
			continue
		end

		local characterMotor = part:FindFirstChild("CharacterMotor")

		if characterMotor then
			characterMotor.Part0 = part
			characterMotor.Part1 = child2
			break
		else
			local characterWeld = part:FindFirstChild("CharacterWeld")

			if characterWeld then
				characterWeld.Part0 = part
				characterWeld.Part1 = child2
				clone:PivotTo(child2.CFrame)
				break
			end
		end
	end

	for _, part in clone:GetChildren() do
		if not part:IsA("BasePart") then
			continue
		end

		part.Massless = true
		part.Anchored = false
		part.CanCollide = false
		part.CollisionGroup = "Units"
	end

	clone.Parent = folder
	local mountAnimations = {}
	local animationController = clone:FindFirstChildOfClass("AnimationController") or clone:FindFirstChildOfClass("Humanoid")

	if animationController then
		local v4 = animationController:FindFirstChildOfClass("Animator")

		if not v4 then
			v4 = Instance.new("Animator")
			v4.Parent = animationController
		end

		for _, child2 in child.Animations.Model:GetChildren() do
			if child2.AnimationId == "" then
				continue
			end

			local speed = child2:GetAttribute("Speed") or 1
			local track = v4:LoadAnimation(child2)
			track.Priority = Enum.AnimationPriority.Action4
			track.Looped = true
			mountAnimations[child2.Name] = {
				Track = track,
				Speed = speed
			}
		end
	end

	local object = setmetatable({}, class)
	object.Name = name
	object.Info = info
	object.Player = player
	object.HRP = humanoidRootPart
	object.Humanoid = humanoid
	object.Character = character
	object.Model = clone
	object.Folder = folder
	object.AnimationsFolder = child.Animations
	object.MountAnimations = mountAnimations
	object.AnimationState = nil
	object.IsLocal = player == Omni.Instance
	object.Connections = {}
	object.Connections.Destroyed = character.AncestryChanged:Connect(function(_, parent)
		if not (character and parent) then
			object:Destroy()
		end
	end)

	if object.IsLocal then
		local animate = Omni:GetAnimate()

		if animate then
			for _, child2 in object.AnimationsFolder.Player:GetChildren() do
				animate:AddCustomAnimationForState("Mount", child2.Name, {
					Animation = child2,
					Priority = Enum.AnimationPriority.Action4,
					Looped = true
				}, 2)
			end
		end
	end

	object.Connections.Update = Omni.Services.RunService.RenderStepped:Connect(function(dt)
		object:Update(dt)
	end)
	v[character] = object
	return true, object
end

return Ground