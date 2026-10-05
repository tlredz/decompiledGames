local createVector = vector.create
local DebrisModule = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("DebrisModule"))
local UnknowingFire = {
	Id = 0
}
game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local track = nil
local Platform_Handler = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Client"):WaitForChild("Controllers"):WaitForChild("Platform_Handler"))
local Utility = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Utility"))
local _ = table.find
local _ = table.remove
require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Checker"))
local Config = require(script.Parent.Config)
local v = {}
local RaycastHelper = require(ReplicatedStorage.CAM.Global.RaycastHelper)

function UnknowingFire.Hold(player)
	if track then
		track:Stop()
		track = nil
	end

	local id = UnknowingFire.Id
	local character = player.Character
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	local humanoid = character:FindFirstChild("Humanoid")
	local attachment = Instance.new("Attachment", humanoidRootPart)
	attachment.Name = "skill_stand_still"
	local linearVelocity = Instance.new("LinearVelocity")
	linearVelocity.Attachment0 = attachment
	linearVelocity.MaxForce = 10000
	linearVelocity.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
	linearVelocity.VectorVelocity = Vector3.new()
	linearVelocity.Parent = attachment
	local alignOrientationWithAttachment, v2 = Utility.CreateAlignOrientationWithAttachment(
		humanoidRootPart,
		"skill_look_at",
		{
			Responsiveness = 80,
			MaxTorque = 3000
		}
	)
	local getvaluesfolder = Utility.getvaluesfolder(character)
	local clone = script.ground_ef:Clone()
	clone.CFrame = humanoidRootPart.CFrame * CFrame.new(0, -2.5, 0)
	clone.Parent = workspace.Debree
	clone.base_ef123asd:Emit(1)
	table.insert(v, clone)
	DebrisModule:AddItem(clone, 6)
	local boolValue = Instance.new("BoolValue")
	boolValue.Name = "NR"
	boolValue.Parent = getvaluesfolder
	DebrisModule:AddItem(boolValue, Config.HOLD_NR_DURATION)
	table.insert(v, boolValue)
	local highlight = Instance.new("Highlight")
	highlight.FillColor = Color3.fromRGB(255, 101, 29)
	highlight.DepthMode = Enum.HighlightDepthMode.Occluded
	highlight.OutlineColor = Color3.fromRGB(255, 25, 25)
	DebrisModule:AddItem(highlight, 15)
	table.insert(v, highlight)
	task.spawn(function()
		while attachment ~= nil and humanoidRootPart and linearVelocity ~= nil and attachment.Parent == humanoidRootPart and linearVelocity.Parent == attachment and attachment.Name == "skill_stand_still" and v2:FindFirstChild("Cancel") == nil and linearVelocity:FindFirstChild("Cancel") == nil do
			local maximizeRayClient, _, _, parent = RaycastHelper.MaximizeRayClient(
				humanoidRootPart.Position,
				Platform_Handler.mousepos(),
				Config.AIM_RANGE,
				true,
				5,
				7,
				3
			)

			if parent == nil then
				if highlight then
					highlight.Parent = workspace.Debree
				end
			elseif highlight and parent:FindFirstChild("HumanoidRootPart") then
				highlight.Parent = parent
			end

			alignOrientationWithAttachment.CFrame = Utility.SafeLookAt(
				humanoidRootPart.Position,
				maximizeRayClient,
				alignOrientationWithAttachment.CFrame
			)
			task.wait()
		end

		task.wait(0.2)
		highlight:Destroy()
	end)
	track = humanoid.Animator:LoadAnimation(script.Initiate)
	track:Play(nil, nil, Config.HOLD_ANIM_SPEED)
	task.wait(Config.HOLD_FREEZE_AT)

	if id == UnknowingFire.Id then
		track:AdjustSpeed(0)
	end
end

function UnknowingFire.UnHold(player, p)
	local _ = UnknowingFire.Id
	local character = player.Character

	for _, v2 in pairs(v) do
		if v2.Name == "NR" then
			DebrisModule:AddItem(v2, Config.RELEASE_NR_DURATION)
		else
			v2:Destroy()
		end
	end

	if character ~= nil then
		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
		character:FindFirstChild("Humanoid")

		if track then
			track:AdjustSpeed(Config.INITIATE_ANIM_SPEED)
		end

		if humanoidRootPart ~= nil then
			local v2 = nil

			if humanoidRootPart:FindFirstChild("skill_stand_still") ~= nil or humanoidRootPart:FindFirstChild("skill_look_at") then
				for _, child in pairs(humanoidRootPart:GetChildren()) do
					if child.Name == "skill_look_at" then
						local boolValue = Instance.new("BoolValue")
						boolValue.Name = "Cancel"
						boolValue.Parent = child
						DebrisModule:AddItem(child, Config.DASH_DURATION)
					elseif child.Name == "skill_stand_still" then
						child:ClearAllChildren()
						DebrisModule:AddItem(child, Config.DASH_DURATION)
						local connections = {}

						-- equivalent calls inferred from this helper; original call sites unknown
						local function cleanUp()
							for k, connection in pairs(connections) do
								connection:Disconnect()
							end
						end

						table.insert(connections, child.AncestryChanged:Connect(cleanUp))
						local v4 = connections
						local v5 = child
						table.insert(connections, character.AttributeChanged:Connect(function(p2: string)
							if p2 ~= script.Parent.Name:gsub(" ", "") .. "UpDrafted" then
								return
							end

							cleanUp() -- equivalent call inferred; original call site unknown
							v5:Destroy()
						end))
						v2 = child
					end
				end
			end

			if humanoidRootPart:FindFirstChild("air_combo_bp") ~= nil then
				humanoidRootPart.air_combo_bp:Destroy()
			end

			local maximizeRayClient, _, _, _ = RaycastHelper.MaximizeRayClient(
				humanoidRootPart.Position,
				p,
				Config.AIM_RANGE,
				true,
				5,
				7,
				2.5
			)
			local alignPosition = Instance.new("AlignPosition")
			alignPosition.Attachment0 = v2
			alignPosition.Mode = Enum.PositionAlignmentMode.OneAttachment
			alignPosition.Position = maximizeRayClient
			alignPosition.MaxForce = Config.DASH_MAX_FORCE
			alignPosition.Responsiveness = Config.DASH_RESPONSIVENESS
			alignPosition.MaxVelocity = Config.DASH_MAX_VELOCITY
			alignPosition.Parent = v2
			v2.Destroying:Connect(function()
				if humanoidRootPart ~= nil and humanoidRootPart.Parent ~= nil then
					humanoidRootPart.AssemblyLinearVelocity = createVector(0, 0, 0)
					humanoidRootPart.AssemblyAngularVelocity = createVector(0, 0, 0)
				end
			end)
		end
	end

	task.wait(Config.DASH_DURATION)
	local humanoidRootPart = character ~= nil and character:FindFirstChild("HumanoidRootPart") or nil

	if humanoidRootPart ~= nil then
		humanoidRootPart.AssemblyLinearVelocity = createVector(0, 0, 0)
		humanoidRootPart.AssemblyAngularVelocity = createVector(0, 0, 0)
	end
end

function UnknowingFire.Cancel(player)
	if track then
		track:Stop()
		track = nil
	end

	for _, v2 in pairs(v) do
		v2:Destroy()
	end

	local character = player.Character

	if character ~= nil then
		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
		character:FindFirstChild("Humanoid")

		if humanoidRootPart ~= nil and (humanoidRootPart:FindFirstChild("skill_stand_still") ~= nil or humanoidRootPart:FindFirstChild("skill_look_at")) then
			for _, child in pairs(humanoidRootPart:GetChildren()) do
				if child.Name == "skill_stand_still" or child.Name == "skill_look_at" then
					child:Destroy()
				end
			end
		end
	end
end

return UnknowingFire