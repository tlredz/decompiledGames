local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local CAM = ReplicatedStorage:WaitForChild("CAM")
local client = CAM:WaitForChild("Client")
local global = CAM:WaitForChild("Global")
local Platform_Handler = require(client:WaitForChild("Controllers"):WaitForChild("Platform_Handler"))
local Utility = require(global:WaitForChild("Utility"))
local cleanit = require(ReplicatedStorage.Packages.cleanit)
local v = cleanit.new()
local DebrisModule = require(CAM:WaitForChild("DebrisModule"))
local Config = require(script.Parent.Config)
local track = nil
local v2 = nil
local v3 = nil
local v4 = nil
local v5 = nil
local v6 = Config.STARTUP_AT + Config.SLASH_WAITS[2] + Config.DASH_DELAY + Config.DASH_DURATION
local v7 = v6 + Config.DASH_DURATION
local v8 = "PosPart" .. script.Parent.Name

-- equivalent calls inferred from this helper; original call sites unknown
local function clearNR()
	if v4 then
		if v4.Parent ~= nil then
			v4:Destroy()
		end

		v4 = nil
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function lockAim()
	v:Clean()
end

-- equivalent calls inferred from this helper; original call sites unknown
local function clearAim()
	lockAim() -- equivalent call inferred; original call site unknown

	if v2 then
		v2:Destroy()
		v2 = nil
	end

	if v3 then
		v3:Destroy()
		v3 = nil
	end
end

local PredatorClaws = {}
PredatorClaws.Id = 0

function PredatorClaws.Hold(player)
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

	local v9 = {}
	v5 = v9
	clearAim() -- equivalent call inferred; original call site unknown
	clearNR() -- equivalent call inferred; original call site unknown

	if track then
		track:Stop()
		track = nil
	end

	local getvaluesfolder = Utility.getvaluesfolder(character)

	if getvaluesfolder then
		v4 = Utility.AddValue(getvaluesfolder, "NR", v7)
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function lookTarget()
		local mousepos = Platform_Handler.mousepos(Config.AIM_RANGE)
		return CFrame.lookAt(
			humanoidRootPart.Position,
			(Vector3.new(mousepos.X, humanoidRootPart.Position.Y, mousepos.Z))
		)
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function updatePointer()
		local child = character:FindFirstChild(v8)

		if not child then
			return
		end

		local mousepos = Platform_Handler.mousepos(Config.AIM_RANGE)
		child.CFrame = CFrame.new(mousepos)
		local bp = child:FindFirstChild("bp")

		if bp then
			bp.Position = mousepos
		end
	end

	local cFrame = lookTarget() -- equivalent call inferred; original call site unknown
	humanoidRootPart.CFrame = cFrame
	v2, v3 = Utility.CreateAlignOrientationWithAttachment(humanoidRootPart, "skill_look_at", {
		AlignType = Enum.AlignType.PrimaryAxisParallel,
		Responsiveness = 75,
		MaxTorque = 3000,
		CFrame = cFrame
	})
	DebrisModule:AddItem(v3, Config.ATTACHMENT_LIFETIME)
	v:Connect(RunService.Heartbeat, function()
		if not v2 or humanoidRootPart.Parent == nil then
			return
		end

		updatePointer() -- equivalent call inferred; original call site unknown
		cFrame = cFrame:Lerp(lookTarget(), Config.AIM_LERP)
		v2.CFrame = cFrame
	end)
	task.delay(v6, function()
		if v9 ~= v5 then
			return
		end

		lockAim() -- equivalent call inferred; original call site unknown
	end)
	task.delay(v7, function()
		if v9 ~= v5 then
			return
		end

		clearAim() -- equivalent call inferred; original call site unknown
	end)
	track = humanoid.Animator:LoadAnimation(script.start_up)
	track:Play()
end

function PredatorClaws.UnHold(_)
	clearNR() -- equivalent call inferred; original call site unknown

	if track then
		track:Stop()
		track = nil
	end

	task.wait(Config.RELEASE_ENDLAG)
end

function PredatorClaws.Cancel(_)
	v5 = nil
	clearAim() -- equivalent call inferred; original call site unknown
	clearNR() -- equivalent call inferred; original call site unknown

	if track then
		track:Stop()
		track = nil
	end
end

return PredatorClaws