local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ArrowFlight = {
	Id = 0
}
local clock = os.clock
local v = false
local now = 0
local flag = nil
local ServerClientPortal = require(ReplicatedStorage.CAM.Global.ServerClientPortal)
local Platform_Handler = require(ReplicatedStorage.CAM.Client.Controllers.Platform_Handler)
require(ReplicatedStorage.Packages.cleanit)
game:GetService("TweenService")
TweenInfo.new(0.2)
local name = script.Parent.Name
require(ReplicatedStorage.CAM.DebrisModule)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local Config = require(script.Parent.Config)
local track = nil
local attachment = nil
local v2 = nil

function clearAttachment()
	if track then
		track:Stop()
		track = nil
	end

	if attachment == nil then
		return
	end

	if v2 ~= nil then
		v2:Destroy()
		v2 = nil
	end

	if attachment == nil then
		return
	end

	attachment:Destroy()
	attachment = nil
end

function ArrowFlight.Hold(_)
	local character = game.Players.LocalPlayer.Character
	local humanoid = character:FindFirstChild("Humanoid")
	track = humanoid.Animator:LoadAnimation(script.Start)
	track:Play()
	now = clock()
	v = true
	local id = ArrowFlight.Id
	local v3 = clock() - now
	task.spawn(function()
		while ArrowFlight.Id == id and v3 > 0 and v3 < Config.SWITCH_AT do
			task.wait()
			v3 = clock() - now
		end

		if ArrowFlight.Id == id and v3 >= Config.SWITCH_AT and v then
			if character == nil or character.Parent == nil then
				return
			end

			local primaryPart = character.PrimaryPart

			if primaryPart == nil then
				return
			end

			flag = true
			ServerClientPortal.Server(name)
			attachment = Instance.new("Attachment", primaryPart)
			attachment.Name = "skill_stand_still"
			local linearVelocity = Instance.new("LinearVelocity")
			linearVelocity.Name = "bp"
			linearVelocity.Attachment0 = attachment
			linearVelocity.MaxForce = Config.FLIGHT_MAX_FORCE
			linearVelocity.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
			Platform_Handler.mousepos(1500)
			linearVelocity.VectorVelocity = createVector(0, 0, 0)
			linearVelocity.Parent = attachment
			v2 = Utility.CreateAlignOrientationWithAttachment(primaryPart, "skill_look_at", {
				AlignType = Enum.AlignType.AllAxes,
				Responsiveness = 80,
				MaxTorque = 10000
			})
			track = humanoid.Animator:LoadAnimation(script.Looped)
			track:Play()

			while ArrowFlight.Id == id and attachment ~= nil and primaryPart ~= nil and primaryPart.Parent ~= nil do
				local position = primaryPart.Position
				local mousepos = Platform_Handler.mousepos()
				linearVelocity.VectorVelocity = linearVelocity.VectorVelocity:Lerp(
					vector.normalize(mousepos - position) * Config.FLIGHT_SPEED,
					0.25
				)
				v2.CFrame = v2.CFrame:Lerp(CFrame.lookAt(position, mousepos), 0.25)
				task.wait()
			end

			clearAttachment()
		end
	end)
end

function ArrowFlight.UnHold(_)
	local humanoid = game.Players.LocalPlayer.Character:FindFirstChild("Humanoid")

	if humanoid then
		if flag then
			humanoid.Animator:LoadAnimation(script.End):Play()
		else
			local track2 = humanoid.Animator:LoadAnimation(script.Summon)
			track2:Play()
			track2.TimePosition = Config.SUMMON_ANIM_SKIP_TO
		end
	end

	v = false
	flag = nil
	clearAttachment()
end

function ArrowFlight.Cancel(_)
	v = false
	flag = nil
	clearAttachment()
end

function ArrowFlight.Switch(player)
	if player ~= nil and player.Character ~= nil then
		local humanoid = player.Character:FindFirstChild("Humanoid")

		if humanoid ~= nil then
			local track2 = humanoid.Animator:LoadAnimation(script.Throw)
			track2:Play()
			track2.TimePosition = Config.THROW_ANIM_SKIP_TO
		end
	end
end

return ArrowFlight