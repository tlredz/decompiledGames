local createVector = vector.create
local DebrisModule = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("DebrisModule"))
local ReapOfDespair = {
	Id = 0
}
game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local track = nil
local Platform_Handler = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Client"):WaitForChild("Controllers"):WaitForChild("Platform_Handler"))
local Utility = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Utility"))
local SkillAimMarker = require(ReplicatedStorage.CAM.Client.Modules.Effects.SkillAimMarker)
local _ = table.find
local _ = table.remove
require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Checker"))
local Config = require(script.Parent.Config)
local v = {}
local RaycastHelper = require(ReplicatedStorage.CAM.Global.RaycastHelper)

function ReapOfDespair.Hold(player)
	if track then
		track:Stop()
		track = nil
	end

	local character = player.Character
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	local humanoid = character:FindFirstChild("Humanoid")
	local v2 = SkillAimMarker.new({
		Ground = {
			CFrame = humanoidRootPart.CFrame * CFrame.new(0, -2.5, 0),
			LifeTime = 6,
			Color = Color3.new(0, 0.6, 1),
			Radius = Config.TELEPORT_RANGE
		},
		Highlight = {
			OutlineTransparency = 0,
			FillTransparency = 0.5,
			OutlineColor = Color3.new(0, 0.6, 1),
			FillColor = Color3.new(0.403922, 0.792157, 1)
		}
	})
	table.insert(v, v2)
	local attachment = Instance.new("Attachment", humanoidRootPart)
	attachment.Name = "skill_stand_still"
	local linearVelocity = Instance.new("LinearVelocity")
	linearVelocity.Attachment0 = attachment
	linearVelocity.MaxForce = 10000
	linearVelocity.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
	linearVelocity.VectorVelocity = Vector3.new()
	linearVelocity.Parent = attachment
	local alignOrientationWithAttachment, v3 = Utility.CreateAlignOrientationWithAttachment(
		humanoidRootPart,
		"skill_look_at",
		{
			Responsiveness = 80,
			MaxTorque = 3000
		}
	)
	local getvaluesfolder = Utility.getvaluesfolder(character)
	local boolValue = Instance.new("BoolValue")
	boolValue.Name = "NR"
	boolValue.Parent = getvaluesfolder
	DebrisModule:AddItem(boolValue, 6)
	table.insert(v, boolValue)
	task.spawn(function()
		while attachment ~= nil and humanoidRootPart and linearVelocity ~= nil and attachment.Parent == humanoidRootPart and linearVelocity.Parent == attachment and attachment.Name == "skill_stand_still" and v3:FindFirstChild("Cancel") == nil and linearVelocity:FindFirstChild("Cancel") == nil do
			local maximizeRayClient, _, _, target = RaycastHelper.MaximizeRayClient(
				humanoidRootPart.Position,
				Platform_Handler.mousepos(),
				Config.TELEPORT_RANGE,
				true,
				5,
				7,
				3
			)

			if target == nil then
				v2:Update({})
			else
				v2:Update({
					target = target
				})
			end

			alignOrientationWithAttachment.CFrame = Utility.SafeLookAt(
				humanoidRootPart.Position,
				maximizeRayClient,
				alignOrientationWithAttachment.CFrame
			)
			task.wait()
		end

		task.wait(0.2)
		v2:Destroy()
	end)
	track = humanoid.Animator:LoadAnimation(script.Init)
	track:Play(0)
	track:AdjustSpeed(0)
end

function ReapOfDespair.UnHold(player, p)
	local _ = ReapOfDespair.Id
	local character = player.Character

	for _, v2 in pairs(v) do
		if v2.Name == "NR" then
			DebrisModule:AddItem(v2, 0.5)
		else
			v2:Destroy()
		end
	end

	if character ~= nil then
		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
		character:FindFirstChild("Humanoid")

		if track then
			track:AdjustSpeed(0.8)
		end

		if humanoidRootPart ~= nil then
			local v2 = nil

			if humanoidRootPart:FindFirstChild("skill_stand_still") ~= nil or humanoidRootPart:FindFirstChild("skill_look_at") then
				for _, child in pairs(humanoidRootPart:GetChildren()) do
					if child.Name == "skill_look_at" then
						local boolValue = Instance.new("BoolValue")
						boolValue.Name = "Cancel"
						boolValue.Parent = child
						DebrisModule:AddItem(child, 0.5)
					elseif child.Name == "skill_stand_still" then
						child:ClearAllChildren()
						DebrisModule:AddItem(child, 0.5)
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

			local maximizeRayClient, _, _, _ = RaycastHelper.MaximizeRayClient(
				humanoidRootPart.Position,
				p,
				Config.TELEPORT_RANGE,
				true,
				5,
				7,
				3
			)
			local alignPosition = Instance.new("AlignPosition")
			alignPosition.Attachment0 = v2
			alignPosition.Mode = Enum.PositionAlignmentMode.OneAttachment
			alignPosition.Position = maximizeRayClient
			alignPosition.MaxForce = 10000
			alignPosition.Responsiveness = 200
			alignPosition.MaxVelocity = 200
			alignPosition.Parent = v2
			v2.Destroying:Connect(function()
				if humanoidRootPart ~= nil and humanoidRootPart.Parent ~= nil then
					humanoidRootPart.AssemblyLinearVelocity = createVector(0, 0, 0)
					humanoidRootPart.AssemblyAngularVelocity = createVector(0, 0, 0)
				end
			end)
		end
	end
end

game:GetService("TweenService")

function ReapOfDespair.Cancel(player)
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

return ReapOfDespair