local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Observers = require(ReplicatedStorage.Packages.Observers)
local isServer = RunService:IsServer()

local function findTargetObject(model, target)
	local pVInstance = nil

	for _, child in model:GetChildren() do
		if not (child:IsA("Model") or child:IsA("BasePart")) then
			continue
		end

		if child.Name == target then
			pVInstance = child
			break
		else
			pVInstance = child:FindFirstChild(target, true)

			if pVInstance then
				break
			end
		end
	end

	if pVInstance and pVInstance:IsA("PVInstance") then
		return pVInstance
	end

	return nil
end

return Observers.observeTag("EmoteVFXAttachNoSpin", function(instance)
	if isServer then
		instance.Anchored = true
		return function()
			instance.Anchored = false
		end
	end

	local model = instance:FindFirstAncestorWhichIsA("Model")

	if not model then
		instance:Destroy()
		return nil
	end

	local target = instance:GetAttribute("Target")
	local targetObject = findTargetObject(model, target)

	if not (targetObject and targetObject:IsA("PVInstance")) then
		instance:Destroy()
		return nil
	end

	local attachmentOffset = instance:FindFirstChild("AttachmentOffset")
	local descendantAddedConnection = model.DescendantAdded:Connect(function(descendant)
		if descendant.Name == target then
			targetObject = findTargetObject(model, target)
		end
	end)
	instance.Anchored = false
	local postSimulationConnection = RunService.PostSimulation:Connect(function()
		local position = model:GetPivot().Position
		local position2 = targetObject:GetPivot().Position
		local v = CFrame.lookAt(Vector3.new(position2.X, position.Y, position2.Z), position) * CFrame.Angles(
			0,
			1.5707963267948966,
			0
		)
		local v2

		if attachmentOffset then
			v2 = attachmentOffset.CFrame
		else
			v2 = CFrame.identity
		end

		instance:PivotTo(v * v2)
	end)
	return function()
		descendantAddedConnection:Disconnect()
		postSimulationConnection:Disconnect()
	end
end, { workspace })