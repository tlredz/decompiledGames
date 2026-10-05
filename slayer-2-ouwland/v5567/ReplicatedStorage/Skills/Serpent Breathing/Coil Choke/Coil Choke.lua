local createVector = vector.create
local DebrisModule = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("DebrisModule"))
local CoilChoke = {
	Id = 0
}
local _ = Vector3.new
local Platform_Handler = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Client"):WaitForChild("Controllers"):WaitForChild("Platform_Handler"))
local track = nil
local _ = os.clock
local Debris = game:GetService("Debris")
game:GetService("TweenService")
TweenInfo.new(0.115, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0)
local v = {}
local Utility = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Utility"))
local Config = require(script.Parent.Config)
local gameSettings = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("gameSettings"))

function CoilChoke.Hold(player)
	local character = player.Character
	local humanoidRootPart = character.HumanoidRootPart
	local humanoid = character.Humanoid
	local _ = CoilChoke.Id

	if track then
		track:Stop()
		track = nil
	end

	for _, v2 in pairs(v) do
		v2:Destroy()
	end

	track = humanoid.Animator:LoadAnimation(script.coilchoke_start_up_anim)
	track:Play()
	track:AdjustSpeed(0)
	local attachment = Instance.new("Attachment", humanoidRootPart)
	attachment.Name = "skill_stand_still"
	local linearVelocity = Instance.new("LinearVelocity")
	linearVelocity.Attachment0 = attachment
	linearVelocity.MaxForce = gameSettings.skillStandStillForce
	linearVelocity.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
	local mousepos = Platform_Handler.mousepos(1500)
	linearVelocity.VectorVelocity = createVector(0, 0, 0)
	linearVelocity.Parent = attachment
	local alignOrientationWithAttachment, v2 = Utility.CreateAlignOrientationWithAttachment(
		humanoidRootPart,
		"skill_look_at",
		{
			AlignType = Enum.AlignType.PrimaryAxisParallel,
			Responsiveness = 20,
			MaxTorque = 10000,
			CFrame = Utility.SafeLookAt(humanoidRootPart.Position, mousepos, humanoidRootPart.CFrame)
		}
	)
	task.spawn(function()
		while attachment ~= nil and humanoidRootPart and linearVelocity ~= nil and attachment.Parent == humanoidRootPart and linearVelocity.Parent == attachment and attachment.Name == "skill_stand_still" and v2:FindFirstChild("Cancel") == nil and linearVelocity:FindFirstChild("Cancel") == nil do
			mousepos = Platform_Handler.mousepos(Config.MOUSE_RANGE)
			alignOrientationWithAttachment.CFrame = Utility.SafeLookAt(
				humanoidRootPart.Position,
				mousepos,
				alignOrientationWithAttachment.CFrame
			)
			task.wait()
		end

		if alignOrientationWithAttachment and v2:FindFirstChild("Cancel") ~= nil then
			linearVelocity.VectorVelocity = createVector(0, 0, 0)
		end
	end)
end

local ManuelCancel = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Subsets"):WaitForChild("Gameplay"):WaitForChild("ManuelCancel"))

function CoilChoke.UnHold(player)
	for _, v2 in pairs(v) do
		Debris:AddItem(v2, Config.UNHOLD_LOCK_DUR)
	end

	local _ = CoilChoke.Id
	local character = player.Character

	if character == nil then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	local humanoid = character:FindFirstChild("Humanoid")

	if humanoidRootPart == nil or humanoid == nil then
		return
	end

	if track then
		track:AdjustSpeed(1)
	end

	if humanoidRootPart:FindFirstChild("skill_stand_still") ~= nil or humanoidRootPart:FindFirstChild("skill_look_at") then
		for _, child in pairs(humanoidRootPart:GetChildren()) do
			if not (child.Name == "skill_stand_still" or child.Name == "skill_look_at") then
				continue
			end

			local boolValue = Instance.new("BoolValue")
			boolValue.Name = "Cancel"
			boolValue.Parent = child
			Debris:AddItem(child, Config.UNHOLD_LOCK_DUR)
		end
	end

	local getvaluesfolder = Utility.getvaluesfolder(character)
	local stringValue = Instance.new("StringValue")
	stringValue.Name = "NR"
	stringValue.Value = script.Parent.Name
	stringValue.Parent = getvaluesfolder
	DebrisModule:AddItem(stringValue, Config.UNHOLD_LOCK_DUR)
	table.insert(v, stringValue)
	local v2, _ = ManuelCancel.new(player, Config.UNHOLD_CANCEL_WINDOW)
	v2:Connect(function()
		CoilChoke.Id = math.random(1, 9999999)

		if track and track.IsPlaying then
			track:Stop()
			track:Destroy()
		end

		for _, v3 in pairs(v) do
			if v3:IsDescendantOf(workspace) then
				v3:Destroy()
			end

			if not (humanoidRootPart:FindFirstChild("skill_stand_still") ~= nil or humanoidRootPart:FindFirstChild("skill_look_at")) then
				continue
			end

			for _, child in pairs(humanoidRootPart:GetChildren()) do
				if child.Name == "skill_stand_still" or child.Name == "skill_look_at" then
					child:Destroy()
				end
			end
		end
	end)
	task.wait(Config.UNHOLD_LOCK_DUR)
end

function CoilChoke.Cancel(player)
	for _, v2 in pairs(v) do
		v2:Destroy()
	end

	local id = CoilChoke.Id
	local character = player.Character

	if character == nil then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	local humanoid = character:FindFirstChild("Humanoid")

	if humanoidRootPart == nil or humanoid == nil then
		return
	end

	if CoilChoke.Id == id and track then
		track:Stop()
		track = nil
	end

	if humanoidRootPart:FindFirstChild("skill_stand_still") ~= nil or humanoidRootPart:FindFirstChild("skill_look_at") then
		for _, child in pairs(humanoidRootPart:GetChildren()) do
			if not (child.Name == "skill_stand_still" or child.Name == "skill_look_at") then
				continue
			end

			local boolValue = Instance.new("BoolValue")
			boolValue.Name = "Cancel"
			boolValue.Parent = child
			child:Destroy()
		end
	end
end

return CoilChoke