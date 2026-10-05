local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local CAM = ReplicatedStorage.CAM
local skills = ReplicatedStorage.Skills
local cleanit = require(ReplicatedStorage.Packages.cleanit)
local maid = cleanit.new()
local DebrisModule = require(CAM.DebrisModule)
local Utility = require(CAM.Global.Utility)
local Platform_Handler = require(CAM.Client.Controllers.Platform_Handler)
local Config = require(script.Parent.Config)
local DevouringRush = {
	Id = 0
}
local skill_stand_still = skills.holder.skill_stand_still
local startup = script.Startup
local loop = script.Loop

function DevouringRush.Hold(player)
	maid:Clean()
	local id = DevouringRush.Id
	local character = player.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart == nil then
		return
	end

	local getvaluesfolder = Utility.getvaluesfolder(character)
	maid:Add(Utility.AddValue(getvaluesfolder, "NR", Config.MAX_HOLD))
	local humanoid = character:FindFirstChild("Humanoid")
	local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")

	if animator ~= nil then
		local track = animator:LoadAnimation(startup)
		maid:Add(track)
		track:Play()
		task.delay(math.max(Config.STARTUP_CLIP - Config.LOOP_LEAD, 0), function()
			if DevouringRush.Id ~= id then
				return
			end

			local track2 = animator:LoadAnimation(loop)
			maid:Add(track2)
			track2:Play()
		end)
	end

	local clone = skill_stand_still:Clone()
	clone.LinearVelocity.ForceLimitMode = Enum.ForceLimitMode.PerAxis
	clone.LinearVelocity.MaxAxesForce = createVector(20000, 20000, 20000)
	clone.LinearVelocity.VectorVelocity = createVector(0, 0, 0)
	clone.Parent = humanoidRootPart
	maid:Add(clone)
	DebrisModule:AddItem(clone, Config.MAX_HOLD + 0.2)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function flatAim(cFrame: CFrame)
		local mousepos = Platform_Handler.mousepos(Config.MOUSE_RANGE)
		return Utility.SafeLookAt(
			humanoidRootPart.Position,
			Vector3.new(mousepos.X, humanoidRootPart.Position.Y, mousepos.Z),
			cFrame
		)
	end

	local alignOrientationWithAttachment, v2 = Utility.CreateAlignOrientationWithAttachment(
		humanoidRootPart,
		"skill_look_at",
		{
			AlignType = Enum.AlignType.PrimaryAxisParallel,
			Responsiveness = 80,
			MaxTorque = 500000,
			CFrame = flatAim(humanoidRootPart.CFrame)
		}
	)
	maid:Add(alignOrientationWithAttachment)
	maid:Add(v2)
	DebrisModule:AddItem(alignOrientationWithAttachment, Config.MAX_HOLD + 0.2)
	DebrisModule:AddItem(v2, Config.MAX_HOLD + 0.2)
	local RUSH_SPEED = 0
	maid:Connect(RunService.Heartbeat, function()
		if DevouringRush.Id ~= id then
			return
		end

		alignOrientationWithAttachment.CFrame = flatAim(alignOrientationWithAttachment.CFrame)

		if RUSH_SPEED > 0 then
			clone.LinearVelocity.VectorVelocity = clone.LinearVelocity.VectorVelocity:Lerp(
				alignOrientationWithAttachment.CFrame.LookVector * RUSH_SPEED,
				Config.RUSH_STEER_LERP
			)
		end
	end)
	task.delay(Config.STARTUP, function()
		if DevouringRush.Id ~= id then
			return
		end

		RUSH_SPEED = Config.RUSH_SPEED
	end)
end

function DevouringRush.UnHold(player)
	maid:Clean()
	local character = player.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart then
		humanoidRootPart.AssemblyLinearVelocity = createVector(0, 0, 0)
	end

	return true
end

function DevouringRush.Cancel(_)
	maid:Clean()
end

return DevouringRush