local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("Lighting")
game:GetService("TweenService")
local services = ReplicatedStorage.Services
require(services.Effects)
local reusable = ReplicatedStorage.Remotes:WaitForChild("Reusable")
local services2 = ReplicatedStorage.Services
local Effects = require(services2.Effects)
require(services2.Spacial)
ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Effects")
local dump = workspace.Dump
reusable.PlayVFX.OnClientEvent:Connect(function(instance, options)
	local v = options or {}
	local position = v.Position
	local cleanupTime = v.CleanupTime or 3
	local alreadyPlaying = v.AlreadyPlaying
	local beamConnector = v.BeamConnector
	local clone = instance:Clone()
	local name = clone.Name
	local type = v.Type
	local character = v.Character
	local bodyPart = v.BodyPart
	local child

	if bodyPart then
		child = character:FindFirstChild(bodyPart)
	end

	local motor6D = clone:FindFirstChildOfClass("Motor6D")

	if clone:IsA("Model") then
		motor6D = clone.PrimaryPart:FindFirstChildOfClass("Motor6D")
	end

	if beamConnector then
		for _, beam in clone:GetDescendants() do
			if beam:IsA("Beam") then
				beam.Attachment1 = beamConnector
			end
		end
	end

	if type == "Aura" or clone:IsA("Attachment") then
		if child then
			for _, v2 in type ~= "Aura" and { clone } or clone:GetChildren() do
				v2.Parent = child
				v2:SetAttribute("EffectName", name)
			end
		else
			warn(clone.Name .. "is missing some arguments")
		end
	elseif motor6D then
		if child then
			clone.Parent = character
			motor6D.Part1 = child
		else
			warn(clone.Name .. "is missing some arguments")
		end
	elseif child then
		clone.Parent = child
	else
		clone.Parent = dump
	end

	if position then
		clone.Position = position
	end

	if alreadyPlaying == true then
		local sound = clone:FindFirstChildOfClass("Sound")

		if sound then
			sound:Play()
		end
	else
		Effects:PlayVFX(clone)
	end

	if cleanupTime > 0 then
		Debris:AddItem(clone, cleanupTime)
	end
end)
reusable.RemoveVFX.OnClientEvent:Connect(function(folder, p)
	for _, descendant in pairs(folder:GetDescendants()) do
		if descendant.Name == p then
			descendant:Destroy()
		end
	end
end)