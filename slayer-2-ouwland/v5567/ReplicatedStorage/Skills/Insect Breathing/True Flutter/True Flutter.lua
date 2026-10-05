local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
game:GetService("Workspace")
local CAM = ReplicatedStorage:WaitForChild("CAM")
local client = CAM:WaitForChild("Client")
local global = CAM:WaitForChild("Global")
local Platform_Handler = require(client:WaitForChild("Controllers"):WaitForChild("Platform_Handler"))
local Utility = require(global:WaitForChild("Utility"))
local ReplicatedStorage3 = game:GetService("ReplicatedStorage")
local maid = require(ReplicatedStorage3.Packages.cleanit).new()
local DebrisModule = require(CAM:FindFirstChild("DebrisModule"))
local Config = require(script.Parent.Config)
local TrueFlutter = {
	Id = 0
}
local raycastParams = RaycastParams.new()
raycastParams.FilterDescendantsInstances = { workspace.Map }
raycastParams.FilterType = Enum.RaycastFilterType.Include
local v = nil
local v2 = nil
local track = nil
local now = 0

function TrueFlutter.Hold(player)
	if not player then
		return
	end

	now = os.clock()
	local character = player.Character
	local id = TrueFlutter.Id

	if not character then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart") or character.PrimaryPart
	local humanoid = character:FindFirstChild("Humanoid")

	if not (humanoidRootPart and humanoid) then
		return
	end

	local animator = humanoid:FindFirstChild("Animator")
	local add = maid:Add(script.Parent.Parent.Parent.holder.skill_stand_still:Clone())
	add.Parent = humanoidRootPart
	local mousepos = Platform_Handler.mousepos(Config.MOUSE_RANGE)
	v, v2 = Utility.CreateAlignOrientationWithAttachment(humanoidRootPart, "skill_look_at", {
		AlignType = Enum.AlignType.AllAxes,
		Responsiveness = 80,
		MaxTorque = 500000,
		CFrame = Utility.SafeLookAt(humanoidRootPart.Position, mousepos, humanoidRootPart.CFrame)
	})
	DebrisModule:AddItem(v2, 6)
	maid:Connect(RunService.Heartbeat, function(_: number)
		mousepos = Platform_Handler.mousepos(Config.MOUSE_RANGE)
		v.CFrame = Utility.SafeLookAt(humanoidRootPart.Position, mousepos, v.CFrame)
	end)
	track = animator:LoadAnimation(script["Out of Range"])
	track:Play()
	task.delay(Config.HOLD_FREEZE_AT, function()
		if id ~= TrueFlutter.Id then
			return
		end

		track:AdjustSpeed(0)
	end)
end

local ServerClientPortal = require(ReplicatedStorage2.CAM.Global.ServerClientPortal)
local localPlayer = game.Players.LocalPlayer
local getvaluesfolder = Utility.getvaluesfolder(localPlayer, true)
local RaycastHelper = require(ReplicatedStorage2.CAM.Global.RaycastHelper)

function TrueFlutter.UnHold(player, p)
	local v3 = Config.WINDUP - (os.clock() - now)

	if v3 > 0 then
		if track ~= nil and track.TimePosition < Config.HOLD_FREEZE_AT then
			track:AdjustSpeed((Config.HOLD_FREEZE_AT - track.TimePosition) / v3)
		end

		task.wait(v3)
	end

	maid:Clean()

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

	if track.TimePosition < Config.HOLD_FREEZE_AT then
		track.TimePosition = Config.HOLD_FREEZE_AT
	end

	track:AdjustSpeed(1)
	ServerClientPortal.Link(script.Parent.Name, 1):Once(function(p2)
		if p2 then
			if v2 ~= nil then
				v2:Destroy()
			end

			if track ~= nil then
				track:Stop()
				track = nil
			end
		else
			local cFrame = humanoidRootPart.CFrame
			local normalized = vector.normalize(p - cFrame.Position)
			local position = cFrame.Position + normalized * Config.MAX_DASH_DISTANCE
			local raycastResult = workspace:Raycast(
				cFrame.Position,
				normalized * Config.MAX_DASH_DISTANCE,
				RaycastHelper.Crater
			)

			if v2 ~= nil then
				DebrisModule:AddItem(v2, Config.MISS_ENDLAG)
				v2 = nil
			end

			if raycastResult then
				position = raycastResult.Position + raycastResult.Normal * 2.5
			end

			Utility.AddValue(getvaluesfolder, "pause_gameplay", Config.MISS_ENDLAG)
			Utility.AddValue(getvaluesfolder, "NR", Config.MISS_ENDLAG)
			local attachment = Instance.new("Attachment")
			attachment.Parent = humanoidRootPart
			DebrisModule:AddItem(attachment, Config.MISS_ENDLAG)

			if v2 ~= nil then
				DebrisModule:AddItem(v2, Config.MISS_ENDLAG)
				v2 = nil
			end

			local alignPosition = Instance.new("AlignPosition")
			alignPosition.Mode = Enum.PositionAlignmentMode.OneAttachment
			alignPosition.Attachment0 = attachment
			alignPosition.Responsiveness = Config.DASH_RESPONSIVENESS
			alignPosition.Position = position
			alignPosition.MaxForce = Config.DASH_MAX_FORCE
			alignPosition.Parent = attachment
		end
	end)
end

function TrueFlutter.Cancel(player)
	maid:Clean()

	if track then
		track:Stop()
		track = nil
	end

	if not player then
		return
	end

	if v ~= nil then
		v:Destroy()
		v = nil
	end

	if v2 ~= nil then
		v2:Destroy()
		v2 = nil
	end

	local character = player.Character

	if not character then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart") or character.PrimaryPart
	humanoidRootPart.AssemblyLinearVelocity = createVector(0, 0, 0)
	humanoidRootPart.AssemblyAngularVelocity = createVector(0, 0, 0)
end

return TrueFlutter