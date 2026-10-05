local createVector = vector.create
local DebrisModule = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("DebrisModule"))
local TwinHeadedReptile = {
	Id = 0
}
local _ = Vector3.new
local Platform_Handler = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Client"):WaitForChild("Controllers"):WaitForChild("Platform_Handler"))
local v = {}
local Utility = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Utility"))
local Config = require(script.Parent.Config)
local gameSettings = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("gameSettings"))
local track = nil
local _ = table.find
local _ = table.remove
local TweenService = game:GetService("TweenService")
local tweenInfo = TweenInfo.new(0.75, Enum.EasingStyle.Back, Enum.EasingDirection.Out, 0, false, 0)
local tweenInfo2 = TweenInfo.new(0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, 0, false, 0)

function TwinHeadedReptile.Hold(player)
	for _, v2 in pairs(v) do
		v2:Destroy()
	end

	local id = TwinHeadedReptile.Id
	local character = player.Character
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	local humanoid = character:FindFirstChild("Humanoid")

	if track then
		track:Stop()
		track = nil
	end

	local getvaluesfolder = Utility.getvaluesfolder(character)
	local attachment = Instance.new("Attachment", humanoidRootPart)
	attachment.Name = "skill_stand_still"
	local linearVelocity = Instance.new("LinearVelocity")
	linearVelocity.Attachment0 = attachment
	linearVelocity.Name = "bv"
	linearVelocity.MaxForce = gameSettings.skillStandStillForce
	linearVelocity.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
	linearVelocity.VectorVelocity = createVector(0, 0, 0)
	linearVelocity.Parent = attachment
	local clone = game.ReplicatedStorage.Assets:WaitForChild("Dash_Aim_Part"):Clone()
	local weld = Instance.new("Weld")
	weld.Part0 = humanoidRootPart
	weld.Part1 = clone
	weld.C0 = CFrame.new(0, -2.6, -3)
	weld.Parent = clone
	clone.Parent = workspace.Debree
	TweenService:Create(clone.SurfaceGui.Frame, tweenInfo, {
		Size = UDim2.new(45, 0, 1, 0)
	}):Play()
	DebrisModule:AddItem(clone, Config.HOLD_SAFETY_DUR)
	table.insert(v, clone)
	local boolValue = Instance.new("BoolValue")
	boolValue.Name = "NR"
	boolValue.Parent = getvaluesfolder
	DebrisModule:AddItem(boolValue, Config.HOLD_SAFETY_DUR)
	table.insert(v, boolValue)
	local mousepos = Platform_Handler.mousepos(Config.MOUSE_RANGE)
	local alignOrientationWithAttachment, v2 = Utility.CreateAlignOrientationWithAttachment(
		humanoidRootPart,
		"skill_look_at",
		{
			AlignType = Enum.AlignType.PrimaryAxisParallel,
			Responsiveness = 45,
			MaxTorque = 3000,
			CFrame = Utility.SafeLookAt(humanoidRootPart.Position, mousepos, humanoidRootPart.CFrame)
		}
	)
	alignOrientationWithAttachment.CFrame = Utility.SafeLookAt(
		humanoidRootPart.Position,
		mousepos,
		alignOrientationWithAttachment.CFrame
	)
	task.spawn(function()
		while attachment ~= nil and humanoidRootPart and linearVelocity ~= nil and attachment.Parent == humanoidRootPart and linearVelocity.Parent == attachment and attachment.Name == "skill_stand_still" and v2:FindFirstChild("Cancel") == nil and linearVelocity:FindFirstChild("Cancel") == nil do
			mousepos = Platform_Handler.mousepos(Config.MOUSE_RANGE)
			alignOrientationWithAttachment.CFrame = Utility.SafeLookAt(
				humanoidRootPart.Position,
				mousepos,
				alignOrientationWithAttachment.CFrame
			)
			task.wait()
		end
	end)
	track = humanoid.Animator:LoadAnimation(script.Reptile_Startup)
	track:Play()
	track:AdjustSpeed(1)
	task.delay(Config.HOLD_FREEZE_AT, function()
		if id == TwinHeadedReptile.Id then
			track:AdjustSpeed(0)
		end
	end)
	task.wait(Config.MIN_HOLD_DUR)
end

function TwinHeadedReptile.UnHold(player, vector2: Vector3)
	if track then
		track:AdjustSpeed(1)
	end

	local _ = TwinHeadedReptile.Id
	local character = player.Character

	for _, v2 in pairs(v) do
		if v2.Name == "NR" then
			DebrisModule:AddItem(v2, Config.UNHOLD_NR_LINGER)
		else
			v2:Destroy()
		end
	end

	if character ~= nil then
		local getvaluesfolder = Utility.getvaluesfolder(character)
		local boolValue = Instance.new("BoolValue")
		boolValue.Name = "NOMouvementlines"
		boolValue.Parent = getvaluesfolder
		DebrisModule:AddItem(boolValue, Config.UNHOLD_LOCK_DUR)
		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
		character:FindFirstChild("Humanoid")

		if humanoidRootPart ~= nil then
			local unit = (vector2 - humanoidRootPart.Position).Unit
			local vector3 = Vector3.new(unit.X, 0, unit.Z)

			if humanoidRootPart:FindFirstChild("skill_stand_still") ~= nil or humanoidRootPart.Name == "skill_look_at" then
				for _, child in pairs(humanoidRootPart:GetChildren()) do
					if not (child.Name == "skill_stand_still" or child.Name == "skill_look_at") then
						continue
					end

					local boolValue2 = Instance.new("BoolValue")

					if child.Name == "skill_stand_still" then
						child.bv.VectorVelocity = vector3 * Config.DASH_SPEED
						local v2 = child
						task.delay(Config.DASH_DUR, function()
							if v2 and v2:IsDescendantOf(workspace) then
								TweenService:Create(v2.bv, tweenInfo2, {
									VectorVelocity = Vector3.new()
								}):Play()
							end
						end)
					end

					boolValue2.Name = "Cancel"
					boolValue2.Parent = child
					DebrisModule:AddItem(child, Config.UNHOLD_LOCK_DUR)
				end
			end
		end
	end

	task.wait(Config.UNHOLD_LOCK_DUR)
end

function TwinHeadedReptile.Cancel(player)
	if track then
		track:Stop()
		track = nil
	end

	for _, v2 in pairs(v) do
		v2:Destroy()
	end

	local _ = TwinHeadedReptile.Id
	local character = player.Character

	if character ~= nil then
		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
		character:FindFirstChild("Humanoid")

		if humanoidRootPart ~= nil and (humanoidRootPart:FindFirstChild("skill_stand_still") ~= nil or humanoidRootPart.Name == "skill_look_at") then
			for _, child in pairs(humanoidRootPart:GetChildren()) do
				if child.Name == "skill_stand_still" or child.Name == "skill_look_at" then
					child:Destroy()
				end
			end
		end
	end
end

return TwinHeadedReptile