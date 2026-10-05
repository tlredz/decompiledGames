local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CAM = ReplicatedStorage:WaitForChild("CAM")
local client = CAM:WaitForChild("Client")
local global = CAM:WaitForChild("Global")
local Platform_Handler = require(client:WaitForChild("Controllers"):WaitForChild("Platform_Handler"))
local Utility = require(global:WaitForChild("Utility"))
local ServerClientPortal = require(global:WaitForChild("ServerClientPortal"))
local cleanit = require(ReplicatedStorage2.Packages.cleanit)
local v = cleanit.new()
local Config = require(script.Parent.Config)
local track = nil
local ExplodingBeads = {
	Id = 0
}
local localPlayer = game.Players.LocalPlayer
local getvaluesfolder = Utility.getvaluesfolder(localPlayer, true)

function ExplodingBeads.Hold(player)
	v:Clean()

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

	local animator = humanoid:FindFirstChild("Animator")
	local id = ExplodingBeads.Id
	local mousepos = Platform_Handler.mousepos(Config.MOUSE_RANGE)
	local vector2 = Vector3.new(mousepos.X, humanoidRootPart.Position.Y, mousepos.Z)
	local alignOrientationWithAttachment, v2 = Utility.CreateAlignOrientationWithAttachment(
		humanoidRootPart,
		"skill_look_at",
		{
			AlignType = Enum.AlignType.AllAxes,
			Responsiveness = 80,
			MaxTorque = 500000,
			CFrame = Utility.SafeLookAt(humanoidRootPart.Position, vector2, humanoidRootPart.CFrame)
		}
	)
	v:Add(alignOrientationWithAttachment)
	v:Add(v2)
	local clone = script.Parent.Parent.Parent.holder.skill_stand_still:Clone()
	clone.Parent = humanoidRootPart
	v:Add(clone)
	local link = ServerClientPortal.Link(script.Parent.Name, 3)
	v:Add(link)
	local v3 = nil
	link:Once(function(p: string)
		v3 = p
	end)
	local lastTime = os.clock()

	while v3 == nil and os.clock() - lastTime < Config.BRANCH_SIGNAL_TIMEOUT do
		task.wait()
	end

	if ExplodingBeads.Id ~= id then
		return
	end

	local v4 = v3 or "Far"
	track = animator:LoadAnimation(script[v4 == "Close" and "Swing_6" or v4])
	track:Play()

	if ExplodingBeads.Id == id then
		if v4 == "Close" then
			Utility.AddValue(getvaluesfolder, "NR", Config.CLOSE_TOTAL_DURATION)
			task.wait(Config.CLOSE_PLACE_DURATION)

			if ExplodingBeads.Id ~= id then
				return
			end

			local v5 = -humanoidRootPart.CFrame.LookVector
			local v6 = Config.DASH_BACK_DISTANCE / Config.CLOSE_DASH_DURATION * 2
			local linearVelocity = clone:FindFirstChildWhichIsA("LinearVelocity")

			if linearVelocity then
				linearVelocity.VectorVelocity = v5 * v6
				TweenService:Create(
					linearVelocity,
					TweenInfo.new(Config.CLOSE_DASH_DURATION, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
					{
						VectorVelocity = createVector(0, 0, 0)
					}
				):Play()
			end

			task.wait(Config.CLOSE_DASH_DURATION)
		else
			Utility.AddValue(getvaluesfolder, "NR", Config.FAR_LOCK_DURATION)
			v:Connect(RunService.Heartbeat, function()
				if ExplodingBeads.Id ~= id then
					return
				end

				local mousepos2 = Platform_Handler.mousepos(Config.MOUSE_RANGE)
				local vector3 = Vector3.new(mousepos2.X, humanoidRootPart.Position.Y, mousepos2.Z)
				alignOrientationWithAttachment.CFrame = Utility.SafeLookAt(
					humanoidRootPart.Position,
					vector3,
					alignOrientationWithAttachment.CFrame
				)
			end)
			task.wait(Config.FAR_LOCK_DURATION)
		end

		v:Clean()
	else
		track:Stop(0)
		track:Destroy()
		track = nil
	end
end

function ExplodingBeads.Cancel(player)
	v:Clean()

	if track ~= nil then
		track:Stop(0)
		track:Destroy()
		track = nil
	end

	if not player then
		return
	end

	local character = player.Character

	if not character then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart") or character.PrimaryPart

	if not humanoidRootPart then
		return
	end

	humanoidRootPart.AssemblyLinearVelocity = createVector(0, 0, 0)
	humanoidRootPart.AssemblyAngularVelocity = createVector(0, 0, 0)
end

return ExplodingBeads