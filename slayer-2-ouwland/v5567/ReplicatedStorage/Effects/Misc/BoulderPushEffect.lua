local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Cam_Shaker = require(ReplicatedStorage.CAM.Client.Modules.Effects.Cam_Shaker)
local Ouwmit = require(ReplicatedStorage.CAM.Client.Modules.Effects.Ouwmit)
local DebrisModule = require(ReplicatedStorage.CAM.DebrisModule)
require(ReplicatedStorage.CAM.Global.RaycastHelper)
local tweenInfo = TweenInfo.new(0.5)
return function(parent, flag: boolean)
	local attachment = parent:FindFirstChild("Attachment")

	if attachment ~= nil then
		attachment.Name = "--"
		Ouwmit.Enable(attachment, false)
		DebrisModule:AddItem(attachment, 3)
	end

	if flag then
		local clone = script.Attachment:Clone()
		clone.Parent = parent
		Ouwmit.Enable(clone, true)
		local clone2 = script.PS2trainingBOULDPUSHpush:Clone()
		clone2.Parent = clone
		clone2:Play()
		local clone3 = script.PS2trainingBOULDPUSHpushLOOP:Clone()
		clone3.Parent = clone
		clone3:Play()
		local cam_Shaker = Cam_Shaker(clone, {
			FadeInTime = 0.1,
			Frequency = 0.3,
			Amplitude = 0.25,
			SustainTime = 360,
			FadeOutTime = 0.3,
			RotationInfluence = createVector(0.1, 0.1, 0.1),
			PositionInfluence = createVector(0.5, 0.5, 0.5)
		})

		while clone ~= nil and clone.Parent ~= nil and clone.Name ~= "--" do
			task.wait(0.1)
		end

		if clone ~= nil and clone.Parent ~= nil then
			local clone4 = script.PS2trainingBOULDPUSHstop:Clone()
			clone4.Parent = clone
			clone4:Play()
			TweenService:Create(clone3, tweenInfo, {
				Volume = 0
			}):Play()
		end

		cam_Shaker:Destroy()
	end
end