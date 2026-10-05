local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local CAM = ReplicatedStorage.CAM
local Platform_Handler = require(CAM.Client.Controllers.Platform_Handler)
local Utility = require(CAM.Global.Utility)
local DebrisModule = require(CAM.DebrisModule)
local cleanit = require(ReplicatedStorage.Packages.cleanit)
local v = cleanit.new()
local Config = require(script.Parent.Config)
local v2 = {}
local v3 = {}
local BloodLust = {
	Id = 0
}

for _, SLASH in Config.SLASHES do
	table.insert(v2, {
		gap = SLASH.gap,
		lunge = SLASH.lunge,
		speed = SLASH.speed
	})
end

table.insert(v2, {
	gap = Config.FINISHER.lunge + Config.FINISHER.aoeGap,
	lunge = Config.FINISHER.lunge,
	speed = Config.FINISHER.speed
})

local function speedAt(p: number)
	if p < Config.STARTUP then
		return Config.SLOW_SPEED
	end

	local v4 = p - Config.STARTUP

	for _, v5 in v2 do
		if v4 < v5.gap then
			if v5.lunge <= v4 then
				return Config.SLOW_SPEED
			end

			local v6 = math.sin(v4 / v5.lunge * 3.141592653589793)
			return Config.SLOW_SPEED + (v5.speed - Config.SLOW_SPEED) * v6
		else
			v4 -= v5.gap
		end
	end

	return 0
end

-- equivalent calls inferred from this helper; original call sites unknown
local function stop()
	v:Clean()

	if v3.anim then
		v3.anim:Stop()
		v3.anim:Destroy()
		v3.anim = nil
	end

	if v3.mover then
		v3.mover:Destroy()
		v3.mover = nil
	end
end

function BloodLust.Hold(player)
	local character = player.Character
	local humanoid = character and character:FindFirstChild("Humanoid")

	if not humanoid then
		return
	end

	local rootPart = humanoid.RootPart

	if not rootPart then
		return
	end

	local animator = humanoid:FindFirstChild("Animator")

	if not animator then
		return
	end

	stop() -- equivalent call inferred; original call site unknown
	local track = animator:LoadAnimation(script.ReaperSlash)
	track:Play()
	v3.anim = track
	local mousepos = Platform_Handler.mousepos(500)
	local alignOrientationWithAttachment, v4 = Utility.CreateAlignOrientationWithAttachment(rootPart, "skill_look_at", {
		AlignType = Enum.AlignType.PrimaryAxisParallel,
		Responsiveness = 75,
		MaxTorque = 3000,
		CFrame = Utility.SafeLookAt(rootPart.Position, mousepos, rootPart.CFrame)
	})
	v:Add(v4)
	local clone = script.Parent.Parent.Parent.holder.skill_stand_still:Clone()
	clone.Parent = rootPart
	DebrisModule:AddItem(clone, 8)
	v3.mover = clone
	local linearVelocity = clone.LinearVelocity
	local lastTime = os.clock()
	v:Connect(RunService.Heartbeat, function()
		local mousepos2 = Platform_Handler.mousepos(500)
		alignOrientationWithAttachment.CFrame = Utility.SafeLookAt(
			rootPart.Position,
			mousepos2,
			alignOrientationWithAttachment.CFrame
		)
		linearVelocity.VectorVelocity = rootPart.CFrame.LookVector * speedAt(os.clock() - lastTime) * createVector(
			1,
			0,
			1
		)
	end)
end

function BloodLust.UnHold(_)
	stop() -- equivalent call inferred; original call site unknown
end

function BloodLust.Cancel(player)
	stop() -- equivalent call inferred; original call site unknown
	local character = player.Character
	local primaryPart = character and character.PrimaryPart

	if primaryPart then
		primaryPart.AssemblyLinearVelocity = createVector(0, 0, 0)
		primaryPart.AssemblyAngularVelocity = createVector(0, 0, 0)
	end
end

return BloodLust