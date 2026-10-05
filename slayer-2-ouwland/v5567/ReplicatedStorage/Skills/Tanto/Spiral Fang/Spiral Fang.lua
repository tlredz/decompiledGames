local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local CAM = ReplicatedStorage.CAM
local client = CAM.Client
local global = CAM.Global
local skills = ReplicatedStorage.Skills
local cleanit = require(ReplicatedStorage.Packages.cleanit)
local maid = cleanit.new()
local Platform_Handler = require(client.Controllers.Platform_Handler)
local Utility = require(global.Utility)
local Config = require(script.Parent.Config)
local SpiralFang = {
	Id = 0
}
local skill_stand_still = skills.holder.skill_stand_still
local spiralFang = script.SpiralFang

function SpiralFang.Hold(player)
	maid:Clean()
	local character = player.Character
	local humanoidRootPart = character.HumanoidRootPart
	local animator = character.Humanoid.Animator
	local getvaluesfolder = Utility.getvaluesfolder(character)
	local id = SpiralFang.Id
	local track = animator:LoadAnimation(spiralFang)
	track.Looped = true
	maid:Add(track)
	track:Play()
	maid:Add(Utility.AddValue(getvaluesfolder, "NR", Config.MAX_DASH_DURATION))
	local clone = skill_stand_still:Clone()
	clone.LinearVelocity.ForceLimitMode = Enum.ForceLimitMode.PerAxis
	clone.LinearVelocity.MaxAxesForce = createVector(20000, 0, 20000)
	clone.LinearVelocity.VectorVelocity = createVector(0, 0, 0)
	clone.Parent = humanoidRootPart
	maid:Add(clone)
	local mousepos = Platform_Handler.mousepos(Config.MOUSE_RANGE)
	local alignOrientationWithAttachment, v = Utility.CreateAlignOrientationWithAttachment(
		humanoidRootPart,
		"skill_look_at",
		{
			AlignType = Enum.AlignType.PrimaryAxisParallel,
			Responsiveness = Config.STEER_RESPONSIVENESS,
			MaxTorque = 500000,
			CFrame = Utility.SafeLookAt(
				humanoidRootPart.Position,
				Vector3.new(mousepos.X, humanoidRootPart.Position.Y, mousepos.Z),
				humanoidRootPart.CFrame
			)
		}
	)
	maid:Add(alignOrientationWithAttachment)
	maid:Add(v)
	local overlapParams = OverlapParams.new()
	overlapParams.FilterType = Enum.RaycastFilterType.Exclude
	overlapParams.FilterDescendantsInstances = { character, workspace.Map, workspace.Debree }
	local DASH_SPEED = Config.DASH_SPEED
	local DASH_SPEED2 = Config.DASH_SPEED
	local v2 = (Config.DASH_SPEED - Config.DASH_REDUCED_SPEED) / math.max(Config.SLOWDOWN_TIME, 0.001)
	local v3 = false
	maid:Connect(RunService.PostSimulation, function(p: number)
		if SpiralFang.Id ~= id then
			return
		end

		local mousepos2 = Platform_Handler.mousepos(Config.MOUSE_RANGE)
		local cframe = CFrame.new(
			humanoidRootPart.Position,
			(Vector3.new(mousepos2.X, humanoidRootPart.Position.Y, mousepos2.Z))
		)
		alignOrientationWithAttachment.CFrame = cframe

		if not v3 then
			local v4 = humanoidRootPart.CFrame * Config.CONTACT_CHECK_OFFSET

			for _, v6 in workspace:GetPartBoundsInBox(v4, Config.CONTACT_CHECK_SIZE, overlapParams) do
				local model = v6:FindFirstAncestorWhichIsA("Model")

				if not (model and model ~= character and model:FindFirstChildOfClass("Humanoid")) then
					continue
				end

				v3 = true
				DASH_SPEED2 = Config.DASH_REDUCED_SPEED
				break
			end
		end

		if DASH_SPEED2 < DASH_SPEED then
			DASH_SPEED = math.max(DASH_SPEED2, DASH_SPEED - v2 * p)
		end

		clone.LinearVelocity.VectorVelocity = cframe.LookVector * DASH_SPEED
	end)
end

function SpiralFang.UnHold(p)
	SpiralFang.Cancel(p)
end

function SpiralFang.Cancel(player)
	maid:Clean()
	local character = player.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart then
		humanoidRootPart.AssemblyLinearVelocity = createVector(0, 0, 0)
		humanoidRootPart.AssemblyAngularVelocity = createVector(0, 0, 0)
	end
end

return SpiralFang