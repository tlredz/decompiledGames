local createVector = vector.create
game:GetService("Debris")
local Utility = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Utility"))
local Platform_Handler = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Client"):WaitForChild("Controllers"):WaitForChild("Platform_Handler"))
local Config = require(script.Parent.Config)
local gameSettings = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("gameSettings"))
local RampantArcRampage = {
	Id = 0
}
local track = nil

function RampantArcRampage.Hold(player)
	local id = RampantArcRampage.Id
	local character = player.Character
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	local humanoid = character:FindFirstChild("Humanoid")
	local attachment = Instance.new("Attachment", humanoidRootPart)
	attachment.Name = "skill_stand_still"
	local linearVelocity = Instance.new("LinearVelocity")
	linearVelocity.Attachment0 = attachment
	linearVelocity.Name = "bv"
	linearVelocity.MaxForce = gameSettings.skillStandStillForce
	linearVelocity.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
	linearVelocity.VectorVelocity = createVector(0, 0, 0)
	linearVelocity.Parent = attachment
	attachment.Parent = humanoidRootPart
	local mousepos = Platform_Handler.mousepos(Config.MOUSE_RANGE)
	local alignOrientationWithAttachment, v = Utility.CreateAlignOrientationWithAttachment(
		humanoidRootPart,
		"skill_look_at",
		{
			AlignType = Enum.AlignType.PrimaryAxisParallel,
			Responsiveness = 60,
			MaxTorque = 10000,
			CFrame = Utility.SafeLookAt(humanoidRootPart.Position, mousepos, humanoidRootPart.CFrame)
		}
	)
	track = humanoid.Animator:LoadAnimation(script.RARStartup)
	track:Play()
	task.wait(Config.STARTUP_DUR)
	track:Stop()

	if RampantArcRampage.Id ~= id then
		return
	end

	task.spawn(function()
		local unit = (mousepos - humanoidRootPart.Position).Unit

		while attachment ~= nil and humanoidRootPart and linearVelocity ~= nil and attachment.Parent == humanoidRootPart and linearVelocity.Parent == attachment and attachment.Name == "skill_stand_still" and v:FindFirstChild("Cancel") == nil and linearVelocity:FindFirstChild("Cancel") == nil do
			local v4 = task.wait()
			mousepos = Platform_Handler.mousepos(Config.MOUSE_RANGE)
			unit = unit:Lerp((mousepos - humanoidRootPart.Position).Unit, Config.AIM_TURN_SPEED * v4)
			alignOrientationWithAttachment.CFrame = CFrame.lookAlong(humanoidRootPart.Position, unit)
		end
	end)
	track = humanoid.Animator:LoadAnimation(script.RARLoop)
	track:Play()
	task.wait(0.15)
end

local function clearDebris(character)
	if character then
		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
		character:FindFirstChild("Humanoid")

		if humanoidRootPart ~= nil and (humanoidRootPart:FindFirstChild("skill_stand_still") ~= nil or humanoidRootPart:FindFirstChild("skill_look_at") ~= nil) then
			for _, child in pairs(humanoidRootPart:GetChildren()) do
				if child.Name == "skill_stand_still" or child.Name == "skill_look_at" then
					child:Destroy()
				end
			end
		end
	end
end

function RampantArcRampage.UnHold(player)
	local _ = RampantArcRampage.Id
	local character = player.Character
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	local humanoid = character:FindFirstChild("Humanoid")

	if track then
		track.Priority = Enum.AnimationPriority.Core
		track:Stop()
	end

	if humanoidRootPart:FindFirstChild("skill_look_at") ~= nil then
		local boolValue = Instance.new("BoolValue", humanoidRootPart:FindFirstChild("skill_look_at"))
		boolValue.Name = "Cancel"
	end

	track = humanoid.Animator:loadAnimation(script.RAREnd)
	track:Play()
	task.wait(Config.END_ANIM_DUR)
	clearDebris(character)
end

function RampantArcRampage.Cancel(player)
	local character = player.Character
	character:FindFirstChild("HumanoidRootPart")
	character:FindFirstChild("Humanoid")
	clearDebris(character)

	if track then
		track.Priority = Enum.AnimationPriority.Core
		track:Stop()
	end
end

return RampantArcRampage