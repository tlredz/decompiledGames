local createVector = vector.create
local DebrisModule = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("DebrisModule"))
local OnSlaught = {
	Id = 0
}
local new = Vector3.new
local Platform_Handler = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Client"):WaitForChild("Controllers"):WaitForChild("Platform_Handler"))
local track = nil
local clock = os.clock
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Utility"))
local ServerClientPortal = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("ServerClientPortal"))
local Settings = require(ReplicatedStorage.CAM.Client.Controllers.Skill_Controller.Settings)
local Config = require(script.Parent.Config)
local gameSettings = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("gameSettings"))
local tweenInfo = TweenInfo.new(Config.DASH_DECAY_DUR, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0)

function OnSlaught.Hold(player)
	local id = OnSlaught.Id
	local character = player.Character
	local humanoidRootPart = character.HumanoidRootPart
	local humanoid = character.Humanoid

	if track then
		track:Stop()
		track = nil
	end

	track = humanoid:LoadAnimation(script.onslaught_startup)
	track:Play()

	for _, child in pairs(humanoidRootPart:GetChildren()) do
		if child.Name == "skill_stand_still" or child.Name == "skill_look_at" or child.Name == "air_combo_bp" then
			child:Destroy()
		end
	end

	local attachment = Instance.new("Attachment", humanoidRootPart)
	attachment.Name = "skill_stand_still"
	local linearVelocity = Instance.new("LinearVelocity")
	linearVelocity.Attachment0 = attachment
	linearVelocity.ForceLimitMode = Enum.ForceLimitMode.PerAxis
	linearVelocity.MaxAxesForce = Vector3.new(gameSettings.skillStandStillForce, 0, gameSettings.skillStandStillForce)
	linearVelocity.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
	local mousepos = Platform_Handler.mousepos(Config.MOUSE_RANGE)
	linearVelocity.VectorVelocity = (new(mousepos.X, humanoidRootPart.Position.Y, mousepos.Z) - humanoidRootPart.Position).Unit * 0
	linearVelocity.Parent = attachment
	local alignOrientationWithAttachment, v = Utility.CreateAlignOrientationWithAttachment(
		humanoidRootPart,
		"skill_look_at",
		{
			AlignType = Enum.AlignType.PrimaryAxisParallel,
			Responsiveness = 75,
			MaxTorque = 3000,
			CFrame = Utility.SafeLookAt(humanoidRootPart.Position, mousepos, humanoidRootPart.CFrame)
		}
	)
	local now = clock()
	local v2 = nil
	task.spawn(function()
		local v3 = false
		v2 = ServerClientPortal.Link(script.Parent.Name)
		v2:Once(function(_: string)
			Settings.AutoUnholdDisabled = true

			if track ~= nil then
				track:Stop(0.15)
				track = nil
			end

			if linearVelocity.Parent ~= nil then
				linearVelocity.VectorVelocity = createVector(0, 0, 0)
				v3 = true
			end
		end)

		while attachment ~= nil and humanoidRootPart and linearVelocity ~= nil and attachment.Parent == humanoidRootPart and linearVelocity.Parent == attachment and attachment.Name == "skill_stand_still" and v:FindFirstChild("Cancel") == nil and linearVelocity:FindFirstChild("Cancel") == nil do
			mousepos = Platform_Handler.mousepos(Config.MOUSE_RANGE)

			if clock() - now > Config.DASH_START_DELAY and not v3 then
				linearVelocity.VectorVelocity = (new(mousepos.X, humanoidRootPart.Position.Y, mousepos.Z) - humanoidRootPart.Position).Unit * Config.DASH_SPEED
			end

			local child = character:FindFirstChild("PosPart" .. script.Parent.Name)

			if child ~= nil then
				child.Position = mousepos
				child.bp.Position = mousepos
			end

			alignOrientationWithAttachment.CFrame = Utility.SafeLookAt(
				humanoidRootPart.Position,
				mousepos,
				alignOrientationWithAttachment.CFrame
			)
			task.wait()
		end

		if linearVelocity then
			TweenService:Create(linearVelocity, tweenInfo, {
				VectorVelocity = new()
			}):Play()
		end
	end)
	task.wait(Config.LOOP_ANIM_AT)

	if OnSlaught.Id ~= id then
		return
	end

	if track then
		track:Stop()
		track = humanoid:LoadAnimation(script.onslaught_loop)
		track:Play()
	end
end

function OnSlaught.UnHold(player)
	local _ = OnSlaught.Id

	if track ~= nil then
		track:Stop()
		track = nil
	end

	local character = player.Character

	if character == nil then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	local humanoid = character:FindFirstChild("Humanoid")

	if humanoidRootPart == nil or humanoid == nil then
		return
	end

	if humanoidRootPart:FindFirstChild("skill_stand_still") ~= nil or humanoidRootPart:FindFirstChild("skill_look_at") then
		for _, child in pairs(humanoidRootPart:GetChildren()) do
			if not (child.Name == "skill_stand_still" or child.Name == "skill_look_at") then
				continue
			end

			local boolValue = Instance.new("BoolValue")
			boolValue.Name = "Cancel"
			boolValue.Parent = child
			DebrisModule:AddItem(child, Config.DASH_DECAY_DUR)
		end
	end

	task.wait(Config.DASH_DECAY_DUR)
end

function OnSlaught.Cancel(player)
	local character = player.Character

	if track ~= nil then
		track:Stop()
		track = nil
	end

	if character == nil then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	local humanoid = character:FindFirstChild("Humanoid")

	if humanoidRootPart == nil or humanoid == nil then
		return
	end

	if humanoidRootPart:FindFirstChild("skill_stand_still") ~= nil or humanoidRootPart:FindFirstChild("skill_look_at") then
		for _, child in pairs(humanoidRootPart:GetChildren()) do
			if child.Name == "skill_stand_still" or child.Name == "skill_look_at" then
				child:Destroy()
			end
		end
	end
end

return OnSlaught