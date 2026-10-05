local RunService = game:GetService("RunService")
local GlobalUtil = require(game.ReplicatedStorage.GlobalUtil)
local isServer = RunService:IsServer()

if not isServer then
	local RunService2 = game:GetService("RunService")

	if RunService2:IsRunning() and GlobalUtil.FFlags.IsUnitTest == false and script.Parent == game.ReplicatedStorage.Util then
		if RunService:IsRunning() and GlobalUtil.FFlags.IsUnitTest == false then
			task.spawn(function()
				script:WaitForChild("Actor")
				local clone = script:Clone()
				local actor = clone.Actor
				actor.Parent = game.ReplicatedStorage
				clone.Parent = actor.Script
				actor.Script.Enabled = true
				script.Actor:Destroy()
			end)
		end

		return {}
	end
end

local RigidConstraintFix = {
	new = function(attachment, bone)
		if bone:IsA("Bone") then
			bone, attachment = attachment, bone
		end

		for _, child in pairs(script.Folder:GetChildren()) do
			if child.Attachment0 == attachment and child.Attachment1 == bone then
				return
			end
		end

		local rigidConstraint = Instance.new("RigidConstraint")
		rigidConstraint.Enabled = false
		rigidConstraint.Attachment0 = attachment
		rigidConstraint.Attachment1 = bone
		bone.AncestryChanged:Connect(function(_, _)
			if bone:IsDescendantOf(workspace) then
				local networkOwner = nil
				local v = false
				local parent = bone.Parent
				bone.Destroying:Once(function()
					v = true
				end)

				repeat
					task.wait()
					v = v or not bone.Parent
				until pcall(function()
					networkOwner = parent:GetNetworkOwner()
				end) or v or not bone.Parent

				if not bone.Parent then
					v = true
				end

				if v then
					return
				else
					pcall(function()
						while not v do
							if parent:GetNetworkOwner() ~= networkOwner then
								parent:SetNetworkOwner(networkOwner)
							end

							task.wait(0.5)
						end
					end)
				end
			end
		end)
		rigidConstraint.Parent = script.Folder

		if bone:FindFirstChild("align") then
			bone:FindFirstChild("align"):Destroy()
		end

		local alignPosition = Instance.new("AlignPosition", bone)
		alignPosition.Mode = Enum.PositionAlignmentMode.OneAttachment
		alignPosition.Name = "align"
		alignPosition.RigidityEnabled = true
		alignPosition.Attachment0 = bone
		alignPosition.Responsiveness = 200
		local alignOrientation = Instance.new("AlignOrientation", bone)
		alignOrientation.Mode = Enum.OrientationAlignmentMode.OneAttachment
		alignOrientation.Name = "aligno"
		alignOrientation.RigidityEnabled = true
		alignOrientation.Attachment0 = bone
		alignOrientation.Responsiveness = 200
		rigidConstraint:SetAttribute("IsServer", isServer)
	end
}

-- equivalent calls inferred from this helper; original call sites unknown
local function canIgnoreInstance(rigidConstraint)
	local parent = rigidConstraint.Parent
	local parent2 = parent and parent.Parent

	if parent and (parent.Name == "ProxyHead" or parent2 and parent2.Parent and parent2.Parent.Name == "YetiRig") then
		return true
	end

	return false
end

if isServer then
	local RunService2 = game:GetService("RunService")

	if RunService2:IsRunning() and GlobalUtil.FFlags.IsUnitTest == false then
		workspace.DescendantAdded:Connect(function(rigidConstraint)
			if rigidConstraint:IsA("RigidConstraint") then
				if canIgnoreInstance(rigidConstraint) then
					return
				end

				if rigidConstraint.Attachment0 and rigidConstraint.Attachment1 then
					if rigidConstraint.Attachment0:IsA("Bone") then
						RigidConstraintFix.new(rigidConstraint.Attachment0, rigidConstraint.Attachment1)
						rigidConstraint.Enabled = false
					elseif rigidConstraint.Attachment1:IsA("Bone") then
						RigidConstraintFix.new(rigidConstraint.Attachment1, rigidConstraint.Attachment0)
						rigidConstraint.Enabled = false
					end
				end
			end
		end)
	elseif RunService:IsRunning() and GlobalUtil.FFlags.IsUnitTest == false then
		workspace.DescendantAdded:ConnectParallel(function(rigidConstraint)
			if rigidConstraint:IsA("RigidConstraint") then
				if canIgnoreInstance(rigidConstraint) then
					return
				end

				if rigidConstraint.Attachment0 and rigidConstraint.Attachment1 then
					if rigidConstraint.Attachment0:IsA("Bone") then
						task.synchronize()
						RigidConstraintFix.new(rigidConstraint.Attachment0, rigidConstraint.Attachment1)
						rigidConstraint.Enabled = false
					elseif rigidConstraint.Attachment1:IsA("Bone") then
						task.synchronize()
						RigidConstraintFix.new(rigidConstraint.Attachment1, rigidConstraint.Attachment0)
						rigidConstraint.Enabled = false
					end
				end
			end
		end)
	end
elseif RunService:IsRunning() and GlobalUtil.FFlags.IsUnitTest == false then
	workspace.DescendantAdded:ConnectParallel(function(rigidConstraint)
		if rigidConstraint:IsA("RigidConstraint") then
			if canIgnoreInstance(rigidConstraint) then
				return
			end

			if rigidConstraint.Attachment0 and rigidConstraint.Attachment1 then
				if rigidConstraint.Attachment0:IsA("Bone") then
					task.synchronize()
					RigidConstraintFix.new(rigidConstraint.Attachment0, rigidConstraint.Attachment1)
					rigidConstraint.Enabled = false
				elseif rigidConstraint.Attachment1:IsA("Bone") then
					task.synchronize()
					RigidConstraintFix.new(rigidConstraint.Attachment1, rigidConstraint.Attachment0)
					rigidConstraint.Enabled = false
				end
			end
		end
	end)
end

local total = 0
local RunService2 = game:GetService("RunService")

if RunService2:IsRunning() and GlobalUtil.FFlags.IsUnitTest == false then
	RunService[isServer and "Heartbeat" or "PostSimulation"]:Connect(function(p)
		if isServer then
			total += p

			if total < 2 then
				return
			else
				total = 0
			end
		else
			total += 1
		end

		for _, child in pairs(script.Folder:GetChildren()) do
			local attachment0 = child.Attachment0
			local attachment1 = child.Attachment1

			if attachment0 and attachment1 and attachment1.Parent and attachment0.Parent then
				local cFrame = attachment0.TransformedWorldCFrame * attachment1.CFrame:Inverse()

				if cFrame == cFrame then
					attachment1.Parent.CFrame = cFrame

					if isServer then
					end

					attachment1.align.Position = cFrame.Position
					attachment1.aligno.CFrame = cFrame
				end
			else
				local _ = child.Attachment0
				local _ = child.Attachment1

				if child:GetAttribute("IsServer") == isServer then
					child:Destroy()
				end
			end
		end

		if not isServer and total >= 2 then
			total = 0
		end
	end)
end

return RigidConstraintFix