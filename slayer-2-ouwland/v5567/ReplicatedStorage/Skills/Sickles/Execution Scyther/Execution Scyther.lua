local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
local Config = require(script.Parent.Config)
local CAM = ReplicatedStorage.CAM
local Platform_Handler = require(CAM.Client.Controllers.Platform_Handler)
local cleanit = require(ReplicatedStorage.Packages.cleanit)
local Utility = require(CAM.Global.Utility)
local vfxUtility = require(CAM.Client.Modules.Effects.vfxUtility)
local ExecutionScyther_effs = require(ReplicatedStorage.Effects["Sickles Weapon"]["Execution Scyther_effs"])
local maid = cleanit.new()
local maid2 = cleanit.new()
local ExecutionScyther = {
	Id = 0
}
local track = nil
local v = "PosPart" .. script.Parent.Name
local v2 = nil

function ExecutionScyther.Hold(player)
	maid:Clean()
	maid2:Clean()

	if track then
		track:Stop()
		track = nil
	end

	local character = player.Character

	if not character then
		return
	end

	local humanoid = character:FindFirstChild("Humanoid")
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if not (humanoid and humanoidRootPart) then
		return
	end

	local id = ExecutionScyther.Id
	local animator = humanoid:FindFirstChildOfClass("Animator")
	local run = script:FindFirstChild("Run")

	if animator and run then
		track = animator:LoadAnimation(run)
		track:Play()
	end

	v2 = id
	maid2:Add(task.spawn(function()
		local child = character:WaitForChild(v, 2)

		if not child or ExecutionScyther.Id ~= v2 then
			return
		end

		maid2:Add(RunService.PostSimulation:Connect(function()
			if ExecutionScyther.Id ~= v2 then
				return
			end

			if child.Parent and humanoidRootPart.Parent then
				child.CFrame = humanoidRootPart.CFrame
				local bp = child:FindFirstChild("bp")

				if bp then
					bp.Position = humanoidRootPart.Position
				end
			end
		end))
	end))
	maid:Add(task.delay(Config.STARTUP, function()
		if id ~= ExecutionScyther.Id then
			return
		end

		local v3 = maid:Add(script.Parent.Parent.Parent.holder.skill_stand_still:Clone())
		v3.Parent = humanoidRootPart
		local linearVelocity = v3.LinearVelocity
		vfxUtility.TweenFOV(0.9, 60)
		local mousepos = Platform_Handler.mousepos(500)
		local createAlignOrientationWithAttachment = Utility.CreateAlignOrientationWithAttachment
		local v5 = {
			AlignType = Enum.AlignType.PrimaryAxisParallel,
			Responsiveness = 75,
			MaxTorque = 3000,
			CFrame = 0
		}
		local safeLookAt = Utility.SafeLookAt
		local position = humanoidRootPart.Position
		local X = mousepos.X
		v5.CFrame = safeLookAt(
			position,
			Vector3.new(X, humanoidRootPart.Position.Y, mousepos.Z),
			humanoidRootPart.CFrame
		)
		local alignOrientationWithAttachment, v6 = createAlignOrientationWithAttachment(
			humanoidRootPart,
			"skill_look_at",
			v5
		)
		maid:Add(v6)
		Debris:AddItem(v6, Config.MAX_DURATION + 1)
		maid:Add(RunService.PostSimulation:Connect(function()
			mousepos = Platform_Handler.mousepos(500)
			alignOrientationWithAttachment.CFrame = Utility.SafeLookAt(
				humanoidRootPart.Position,
				Vector3.new(mousepos.X, humanoidRootPart.Position.Y, mousepos.Z),
				alignOrientationWithAttachment.CFrame
			)
			local lookVector = humanoidRootPart.CFrame.LookVector
			linearVelocity.VectorVelocity = Vector3.new(lookVector.X, 0, lookVector.Z) * Config.SPEED
		end))
	end))
end

function ExecutionScyther.UnHold(player)
	local character = player.Character
	local humanoid = character and character:FindFirstChild("Humanoid")
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if not (humanoidRootPart and humanoid) then
		maid:Clean()
		return
	end

	local function launch(LAUNCH_HEIGHT: number, p: number, value: number?)
		local air_combo_bp = humanoidRootPart:FindFirstChild("air_combo_bp")

		if air_combo_bp then
			air_combo_bp:Destroy()
		end

		local attachment = Instance.new("Attachment")
		attachment.Name = "air_combo_bp"
		local numberValue = Instance.new("NumberValue")
		numberValue.Name = "added"
		numberValue.Value = Utility.Tick()
		numberValue.Parent = attachment
		local alignPosition = Instance.new("AlignPosition")
		alignPosition.Name = "bpv"
		alignPosition.Mode = Enum.PositionAlignmentMode.OneAttachment
		alignPosition.ForceLimitMode = Enum.ForceLimitMode.PerAxis
		alignPosition.MaxAxesForce = createVector(0, 40000, 0)
		alignPosition.Attachment0 = attachment
		alignPosition.Responsiveness = value or 25
		alignPosition.Position = humanoidRootPart.Position + Vector3.new(0, LAUNCH_HEIGHT, 0)
		alignPosition.Parent = attachment
		attachment.Parent = humanoidRootPart
		Debris:AddItem(attachment, p)
	end

	maid:Clean()
	humanoidRootPart.AssemblyLinearVelocity = createVector(0, 0, 0)

	if track then
		track:Stop(0)
		track = nil
	end

	local id = ExecutionScyther.Id
	v2 = id
	local animator = humanoid:FindFirstChildOfClass("Animator")
	ExecutionScyther_effs(character, "Hit")
	local xSlash = script:FindFirstChild("XSlash")

	if animator and xSlash then
		track = animator:LoadAnimation(xSlash)
		track.Priority = Enum.AnimationPriority.Action4
		track.Looped = false
		track:Play()
	end

	launch(Config.LAUNCH_HEIGHT, Config.AIR_TIME + 0.1, 60)
	maid:Add(task.delay(Config.AIR_TIME, function()
		if id ~= ExecutionScyther.Id or not humanoidRootPart.Parent then
			return
		end

		local air_combo_bp = humanoidRootPart:FindFirstChild("air_combo_bp")

		if air_combo_bp then
			air_combo_bp:Destroy()
		end
	end))
	task.delay(Config.SECOND_AOE_AT + Config.FINISHER_ENDLAG, function()
		if id ~= ExecutionScyther.Id then
			return
		end

		vfxUtility.TweenFOV(0.5, 70)

		if track then
			track:Stop()
			track = nil
		end

		maid:Clean()
		maid2:Clean()
		v2 = nil
	end)
end

function ExecutionScyther.Cancel(player)
	local character = player.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
	maid:Clean()
	maid2:Clean()
	v2 = nil

	if track then
		track:Stop()
		track = nil
	end

	if humanoidRootPart then
		humanoidRootPart.AssemblyLinearVelocity = createVector(0, 0, 0)

		for _, child in humanoidRootPart:GetChildren() do
			local name = child.Name

			if name == "skill_stand_still" or name == "skill_look_at" or name == "air_combo_bp" then
				child:Destroy()
			end
		end
	end

	vfxUtility.TweenFOV(0.5, 70)
end

return ExecutionScyther