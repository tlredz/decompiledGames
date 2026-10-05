local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Cam_Shaker = require(ReplicatedStorage.CAM.Client.Modules.Effects.Cam_Shaker)
local DebrisModule = require(ReplicatedStorage.CAM.DebrisModule)
local Ouwmit = require(ReplicatedStorage.CAM.Client.Modules.Effects.Ouwmit)
local v = false

local function scaled(size, p: number)
	local numberSequenceKeypoints = {}

	for _, keypoint in size.Keypoints do
		table.insert(
			numberSequenceKeypoints,
			NumberSequenceKeypoint.new(keypoint.Time, keypoint.Value * p, keypoint.Envelope * p)
		)
	end

	return NumberSequence.new(numberSequenceKeypoints)
end

return function(worldPosition: Vector3?, p: string?, value: number?)
	if worldPosition == nil then
		return
	end

	local attachment = script:FindFirstChild("Attachment")

	if attachment == nil then
		if not v then
			v = true
			warn((`[QuestDeposit] no Attachment child on {script:GetFullName()} — deposits run undressed`))
		end
	elseif p == "Start" then
		if workspace.Debree:FindFirstChild("QuestDepositSfx") ~= nil then
			return
		end

		local attachment2 = Instance.new("Attachment")
		attachment2.Name = "QuestDepositSfx"
		attachment2.Parent = workspace.Debree
		attachment2.WorldPosition = worldPosition

		for _, sound in attachment:GetChildren() do
			if not sound:IsA("Sound") then
				continue
			end

			local clone = sound:Clone()
			clone.Parent = attachment2

			if sound.Name ~= "DepositEnd" then
				clone:Play()
			end
		end
	elseif p == "Stop" then
		local questDepositSfx = workspace.Debree:FindFirstChild("QuestDepositSfx")

		if questDepositSfx == nil then
			return
		end

		questDepositSfx.Name = "--"

		for _, sound in questDepositSfx:GetChildren() do
			if not sound:IsA("Sound") then
				continue
			end

			if sound.Name == "DepositEnd" then
				sound:Play()
			else
				sound:Stop()
			end
		end

		DebrisModule:AddItem(questDepositSfx, 5)
	else
		local clone = attachment:Clone()
		clone.Parent = workspace.Debree
		clone.WorldPosition = worldPosition
		DebrisModule:AddItem(clone, 4)
		local v2 = value or 1

		for _, descendant in clone:GetDescendants() do
			if descendant:IsA("Sound") then
				descendant:Destroy()
			elseif descendant:IsA("ParticleEmitter") then
				descendant.ZOffset += 2

				if v2 ~= 1 then
					descendant.Size = scaled(descendant.Size, v2)
					descendant.Speed = NumberRange.new(descendant.Speed.Min * v2, descendant.Speed.Max * v2)
					descendant.Acceleration *= v2
				end
			end
		end

		Ouwmit.Emit(clone)
		Cam_Shaker(worldPosition, "tinyshake_less_aggresive_preset")
	end
end