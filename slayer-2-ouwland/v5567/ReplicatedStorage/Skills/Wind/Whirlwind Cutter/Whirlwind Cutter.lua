local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local CAM = ReplicatedStorage:WaitForChild("CAM")
local client = CAM:WaitForChild("Client")
local global = CAM:WaitForChild("Global")
local Platform_Handler = require(client:WaitForChild("Controllers"):WaitForChild("Platform_Handler"))
local Utility = require(global:WaitForChild("Utility"))
local ServerClientPortal = require(global:WaitForChild("ServerClientPortal"))
local cleanit = require(ReplicatedStorage.Packages.cleanit)
local v = cleanit.new()
local DebrisModule = require(CAM:FindFirstChild("DebrisModule"))
local Config = require(script.Parent.Config)
local WhirlwindCutter = {
	Id = 0
}
local v2 = nil
local v3 = nil
local attachment = nil
local linearVelocity = nil
local track = nil
local flag = false
local v4 = nil
local track2 = nil

function WhirlwindCutter.Hold(player)
	if not player then
		return
	end

	local character = player.Character

	if not character then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart") or character.PrimaryPart
	local humanoid = character:FindFirstChild("Humanoid")

	if not (humanoidRootPart and humanoid) then
		return
	end

	flag = false
	v4 = ServerClientPortal.Link(script.Parent.Name, Config.HOLD_MAX_DURATION + Config.FINISHER_LOCK_DURATION + 2)
	attachment = Instance.new("Attachment")
	attachment.Name = "skill_stand_still"
	attachment.Parent = humanoidRootPart
	linearVelocity = Instance.new("LinearVelocity")
	linearVelocity.Attachment0 = attachment
	linearVelocity.ForceLimitMode = Enum.ForceLimitMode.PerAxis
	linearVelocity.MaxAxesForce = createVector(10000, 10000, 10000)
	linearVelocity.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
	linearVelocity.VectorVelocity = createVector(0, 0, 0)
	linearVelocity.Parent = attachment
	local mousepos = Platform_Handler.mousepos(1500)
	v2, v3 = Utility.CreateAlignOrientationWithAttachment(humanoidRootPart, "skill_look_at", {
		AlignType = Enum.AlignType.PrimaryAxisParallel,
		Responsiveness = 45,
		MaxTorque = 1000,
		CFrame = Utility.SafeLookAt(humanoidRootPart.Position, mousepos, humanoidRootPart.CFrame)
	})
	DebrisModule:AddItem(v3, 6)
	local run = script:FindFirstChild("Run") or script:FindFirstChild("run")

	if run then
		track = humanoid.Animator:LoadAnimation(run)
		track:Play()
	end

	local id = WhirlwindCutter.Id
	task.delay(Config.HOLD_TRANSPARENT_DELAY, function()
		if WhirlwindCutter.Id == id then
			flag = true
		end
	end)
	v:Connect(RunService.Heartbeat, function()
		if attachment == nil or attachment.Parent == nil or (linearVelocity == nil or linearVelocity.Parent == nil) then
			return
		end

		mousepos = Platform_Handler.mousepos(1500)
		local v5 = mousepos - humanoidRootPart.Position
		local unit

		if v5.Magnitude > 0.001 then
			unit = v5.Unit
		else
			unit = humanoidRootPart.CFrame.LookVector
		end

		if flag then
			linearVelocity.VectorVelocity = unit * 72
		end

		if v2 and v2.Parent then
			v2.CFrame = Utility.SafeLookAt(humanoidRootPart.Position, mousepos, v2.CFrame)
		end
	end)
	track2 = humanoid.Animator:LoadAnimation(script.Startup)
	track2:Play()
end

local function tearDown()
	v:Clean()

	if v2 ~= nil then
		v2:Destroy()
		v2 = nil
	end

	if v3 ~= nil then
		v3:Destroy()
		v3 = nil
	end

	if linearVelocity ~= nil then
		linearVelocity:Destroy()
		linearVelocity = nil
	end

	if attachment ~= nil then
		attachment:Destroy()
		attachment = nil
	end

	if track ~= nil then
		track:Stop()
		track:Destroy()
		track = nil
	end

	if v4 ~= nil then
		if v4.__Active then
			v4:Destroy()
		end

		v4 = nil
	end
end

function WhirlwindCutter.UnHold(player)
	if not player then
		return
	end

	local character = player.Character

	if not (character and (character:FindFirstChild("HumanoidRootPart") or character.PrimaryPart)) then
		return
	end

	if track2 ~= nil then
		track2:Stop()
		track2 = nil
	end

	flag = false

	if linearVelocity then
		linearVelocity.VectorVelocity = createVector(0, 0, 0)
	end

	if v2 then
		v2:Destroy()
		v2 = nil
	end

	local FINISHER_LOCK_DURATION = Config.FINISHER_LOCK_DURATION
	local getvaluesfolder = Utility.getvaluesfolder(player, true)
	local v5

	if getvaluesfolder == nil then
		v5 = nil
	else
		v5 = Utility.AddValue(getvaluesfolder, "NR", FINISHER_LOCK_DURATION)
	end

	local id = WhirlwindCutter.Id
	local flag2 = false

	-- equivalent calls inferred from this helper; original call sites unknown
	local function finish()
		if flag2 then
			return
		end

		flag2 = true

		if v5 ~= nil and v5.Parent ~= nil then
			v5:Destroy()
		end

		tearDown()
	end

	if v4 ~= nil then
		v4:Once(function(p, value)
			if id ~= WhirlwindCutter.Id then
				return
			end

			if p == false then
				task.delay(value or 0, function()
					if id ~= WhirlwindCutter.Id then
						return
					end

					finish() -- equivalent call inferred; original call site unknown
				end)
			end
		end)
	end

	task.delay(FINISHER_LOCK_DURATION, function()
		if id ~= WhirlwindCutter.Id then
			return
		end

		finish() -- equivalent call inferred; original call site unknown
	end)
end

function WhirlwindCutter.Cancel(_)
	if track2 ~= nil then
		track2:Stop()
		track2 = nil
	end

	flag = false
	tearDown()
end

return WhirlwindCutter