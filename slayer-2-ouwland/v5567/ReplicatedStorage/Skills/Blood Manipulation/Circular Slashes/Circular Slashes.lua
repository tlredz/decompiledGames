local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DebrisModule = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("DebrisModule"))
local CircularSlashes = {
	Id = 0
}
local _ = Vector3.new
local Platform_Handler = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Client"):WaitForChild("Controllers"):WaitForChild("Platform_Handler"))
local Utility = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Utility"))
local SkillAimMarker = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Client"):WaitForChild("Modules"):WaitForChild("Effects"):WaitForChild("SkillAimMarker"))
local track = nil
local _ = table.find
local _ = table.remove
require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Checker"))
local Config = require(script.Parent.Config)
local v = nil
local RaycastHelper = require(ReplicatedStorage.CAM.Global.RaycastHelper)
local gameSettings = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("gameSettings"))

function CircularSlashes.Hold(player)
	local _ = CircularSlashes.Id
	local character = player.Character
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	local humanoid = character:FindFirstChild("Humanoid")

	if track then
		track:Stop()
		track = nil
	end

	Utility.getvaluesfolder(character)
	local attachment = Instance.new("Attachment", humanoidRootPart)
	attachment.Name = "skill_stand_still"
	local alignPosition = Instance.new("AlignPosition")
	alignPosition.Attachment0 = attachment
	alignPosition.Mode = Enum.PositionAlignmentMode.OneAttachment
	alignPosition.Position = humanoidRootPart.Position
	alignPosition.MaxForce = gameSettings.skillStandStillForce
	alignPosition.Responsiveness = 18
	alignPosition.Parent = attachment
	local alignOrientationWithAttachment, v2 = Utility.CreateAlignOrientationWithAttachment(
		humanoidRootPart,
		"skill_look_at",
		{
			Responsiveness = 70,
			MaxTorque = 500000
		}
	)
	task.spawn(function()
		v = SkillAimMarker.new({
			Dot = true,
			Highlight = {
				FillColor = Color3.fromRGB(255, 155, 187),
				OutlineColor = Color3.fromRGB(255, 89, 92),
				FillTransparency = 0.85
			}
		})
		DebrisModule:AddItem(v, 15)

		while attachment ~= nil and humanoidRootPart and alignPosition ~= nil and attachment.Parent == humanoidRootPart and alignPosition.Parent == attachment and attachment.Name == "skill_stand_still" and v2:FindFirstChild("Cancel") == nil and alignPosition:FindFirstChild("Cancel") == nil do
			local position, _, _, target = RaycastHelper.MaximizeRayClient(
				humanoidRootPart.Position,
				Platform_Handler.mousepos(),
				Config.AIM_RADIUS,
				true,
				8
			)

			if v then
				v:Update({
					position = position,
					target = target
				})
			end

			local child = character:FindFirstChild("PosPart" .. script.Name .. "Server")

			if child then
				child.Position = position
				child.bp.Position = position
			end

			local v6 = alignOrientationWithAttachment
			local safeLookAt = Utility.SafeLookAt
			local position2 = humanoidRootPart.Position

			if target ~= nil then
				position = target.PrimaryPart.Position or position
			end

			v6.CFrame = safeLookAt(position2, position, alignOrientationWithAttachment.CFrame)
			task.wait()
		end

		task.wait(0.2)

		if v then
			v:Destroy()
			v = nil
		end
	end)
	track = humanoid.Animator:LoadAnimation(script.CircularSlashes_Throw)
	track:Play(0.1, 1, 1)
	task.wait(Config.HOLD_FREEZE_AT)
	track:AdjustSpeed(0)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function destroyBodyMovers(character)
	if v then
		v:Destroy()
		v = nil
	end

	if character then
		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
		character:FindFirstChild("Humanoid")

		if humanoidRootPart ~= nil and (humanoidRootPart:FindFirstChild("skill_stand_still") ~= nil or humanoidRootPart:FindFirstChild("skill_look_at") ~= nil) then
			for _, child in pairs(humanoidRootPart:GetChildren()) do
				if child.Name == "skill_stand_still" or child.Name == "skill_look_at" then
					child:Destroy()
				end
			end
		end
	end
end

function CircularSlashes.UnHold(player)
	local _ = CircularSlashes.Id
	local character = player.Character
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	character:FindFirstChild("Humanoid")

	if track then
		track:AdjustSpeed(1)
	end

	if humanoidRootPart:FindFirstChild("skill_look_at") ~= nil then
		local boolValue = Instance.new("BoolValue", humanoidRootPart:FindFirstChild("skill_look_at"))
		boolValue.Name = "Cancel"
	end

	task.wait(Config.THROW_ANIM_DUR)
	destroyBodyMovers(character)
end

function CircularSlashes.Cancel(player)
	local character = player.Character
	character:FindFirstChild("HumanoidRootPart")
	character:FindFirstChild("Humanoid")

	if track then
		track:Stop()
		track = nil
	end

	destroyBodyMovers() -- equivalent call inferred; original call site unknown
	destroyBodyMovers(character)
end

return CircularSlashes