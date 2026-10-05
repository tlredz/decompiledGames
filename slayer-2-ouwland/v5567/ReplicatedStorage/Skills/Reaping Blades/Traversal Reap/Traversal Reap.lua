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
local maid = cleanit.new()
local TraversalReap = {
	Id = 0
}
local track = nil
local v = "PosPart" .. script.Parent.Name

function TraversalReap.Hold(player)
	maid:Clean()

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

	local id = TraversalReap.Id
	track = humanoid.Animator:LoadAnimation(script.Startup)
	track:Play()
	local v2 = track
	maid:Add(task.spawn(function()
		v2.Stopped:Wait()

		if track ~= v2 or id ~= TraversalReap.Id then
			return
		end

		track = humanoid.Animator:LoadAnimation(script.Loop)
		track:Play()
	end))
	maid:Add(task.spawn(function()
		local child = character:WaitForChild(v, 2)

		if not child or id ~= TraversalReap.Id then
			return
		end

		maid:Add(RunService.PostSimulation:Connect(function()
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
		if id ~= TraversalReap.Id then
			return
		end

		local air_combo_bp = humanoidRootPart:FindFirstChild("air_combo_bp")

		if air_combo_bp then
			air_combo_bp:Destroy()
		end

		local v3 = maid:Add(script.Parent.Parent.Parent.holder.skill_stand_still:Clone())
		v3.Parent = humanoidRootPart
		local linearVelocity = v3.LinearVelocity
		vfxUtility.TweenFOV(0.9, 90)
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
			linearVelocity.VectorVelocity = humanoidRootPart.CFrame.LookVector * Config.SPEED * Config.FORCE_SCALE
		end))
	end))
end

function TraversalReap.UnHold(player)
	local character = player.Character
	local humanoid = character and character:FindFirstChild("Humanoid")
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
	maid:Clean()

	if humanoidRootPart then
		humanoidRootPart.AssemblyLinearVelocity = createVector(0, 0, 0)
	end

	if track then
		track:Stop()
		track = nil
	end

	local v2 = humanoid and script:FindFirstChild("End")

	if v2 then
		track = humanoid.Animator:LoadAnimation(v2)
		track:Play()
		Debris:AddItem(track, 2)
	end

	vfxUtility.TweenFOV(0.5, 70)
end

function TraversalReap.Cancel(player)
	local character = player.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
	maid:Clean()

	if track then
		track:Stop()
		track = nil
	end

	if humanoidRootPart then
		humanoidRootPart.AssemblyLinearVelocity = createVector(0, 0, 0)

		for _, child in pairs(humanoidRootPart:GetChildren()) do
			if child.Name == "skill_stand_still" or child.Name == "skill_look_at" then
				child:Destroy()
			end
		end
	end

	vfxUtility.TweenFOV(0.5, 70)
end

return TraversalReap