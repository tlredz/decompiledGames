local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local CAM = ReplicatedStorage:WaitForChild("CAM")
local client = CAM:WaitForChild("Client")
local global = CAM:WaitForChild("Global")
local Platform_Handler = require(client:WaitForChild("Controllers"):WaitForChild("Platform_Handler"))
local Utility = require(global:WaitForChild("Utility"))
local cleanit = require(ReplicatedStorage.Packages.cleanit)
local maid = cleanit.new()
local IdatenTyphoon = {
	Id = 0
}
local v = nil
local heartbeatConnection = nil
local track = nil
local v2 = "PosPart" .. script.Parent.Name

function IdatenTyphoon.Hold(player)
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

	local clone = script.Parent.Parent.Parent.holder.skill_stand_still:Clone()
	clone.Parent = humanoidRootPart
	maid:Add(clone)
	local getvaluesfolder = Utility.getvaluesfolder(player, true)

	if getvaluesfolder ~= nil then
		maid:Add(Utility.AddValue(getvaluesfolder, "NR", 10))
	end

	local startup = script:FindFirstChild("Startup")

	if startup then
		if track then
			track:Stop()
			track:Destroy()
		end

		track = humanoid.Animator:LoadAnimation(startup)
		track:Play()
		maid:Add(track)
		local id = IdatenTyphoon.Id
		local v3 = track
		task.delay(0.5, function()
			if IdatenTyphoon.Id ~= id then
				return
			end

			if v3 and v3.IsPlaying then
				v3:AdjustSpeed(0)
			end
		end)
	end

	local mousepos = Platform_Handler.mousepos(500)
	local createAlignOrientationWithAttachment = Utility.CreateAlignOrientationWithAttachment
	local v3 = {
		AlignType = Enum.AlignType.AllAxes,
		Responsiveness = 80,
		MaxTorque = 500000,
		CFrame = 0
	}
	local safeLookAt = Utility.SafeLookAt
	local position = humanoidRootPart.Position
	local X = mousepos.X
	v3.CFrame = safeLookAt(position, Vector3.new(X, humanoidRootPart.Position.Y, mousepos.Z), humanoidRootPart.CFrame)
	local alignOrientationWithAttachment, v4 = createAlignOrientationWithAttachment(
		humanoidRootPart,
		"skill_look_at",
		v3
	)
	v = alignOrientationWithAttachment
	maid:Add(v)
	maid:Add(v4)
	local id = IdatenTyphoon.Id
	local v5 = false
	task.spawn(function()
		character:WaitForChild(v2, 0.5)

		if IdatenTyphoon.Id == id then
			v5 = true
		end
	end)

	if heartbeatConnection then
		heartbeatConnection:Disconnect()
	end

	heartbeatConnection = RunService.Heartbeat:Connect(function()
		local child = character:FindFirstChild(v2)

		if child and child.Parent then
			mousepos = Platform_Handler.mousepos(500)

			if v and v.Parent then
				v.CFrame = Utility.SafeLookAt(
					humanoidRootPart.Position,
					Vector3.new(mousepos.X, humanoidRootPart.Position.Y, mousepos.Z),
					v.CFrame
				)
			end

			child.Position = mousepos
			local bp = child:FindFirstChild("bp")

			if bp then
				bp.Position = mousepos
			end
		elseif v5 and heartbeatConnection then
			heartbeatConnection:Disconnect()
			heartbeatConnection = nil
		end
	end)
end

function IdatenTyphoon.UnHold(player)
	if not player then
		return
	end

	local character = player.Character

	if not (character and (character:FindFirstChild("HumanoidRootPart") or character.PrimaryPart)) then
		return
	end

	if v then
		v:Destroy()
		v = nil
	end

	local id = IdatenTyphoon.Id
	task.delay(0.3, function()
		if IdatenTyphoon.Id ~= id then
			return
		end

		maid:Clean()
		track = nil
	end)
end

function IdatenTyphoon.Cancel(_)
	maid:Clean()

	if heartbeatConnection then
		heartbeatConnection:Disconnect()
		heartbeatConnection = nil
	end

	v = nil
	track = nil
end

return IdatenTyphoon