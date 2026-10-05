local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DebrisModule = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("DebrisModule"))
local SerpentSlash = {
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
local AIM_RADIUS = Config.AIM_RADIUS
local v = nil
local RaycastHelper = require(ReplicatedStorage.CAM.Global.RaycastHelper)
local gameSettings = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("gameSettings"))

function SerpentSlash.Hold(player)
	local _ = SerpentSlash.Id
	local character = player.Character
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	local humanoid = character:FindFirstChild("Humanoid")

	if track then
		track:Stop()
		track = nil
	end

	if v then
		v:Destroy()
		v = nil
	end

	local id = SerpentSlash.Id
	Utility.getvaluesfolder(character)
	local attachment = Instance.new("Attachment", humanoidRootPart)
	attachment.Name = "skill_stand_still"
	local linearVelocity = Instance.new("LinearVelocity")
	linearVelocity.Attachment0 = attachment
	linearVelocity.Name = "bv"
	linearVelocity.ForceLimitMode = Enum.ForceLimitMode.PerAxis
	linearVelocity.MaxAxesForce = Vector3.new(gameSettings.skillStandStillForce, 0, gameSettings.skillStandStillForce)
	linearVelocity.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
	linearVelocity.VectorVelocity = createVector(0, 0, 0)
	linearVelocity.Parent = attachment
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
			Highlight = true
		})
		DebrisModule:AddItem(v, 15)

		while attachment ~= nil and humanoidRootPart and linearVelocity ~= nil and attachment.Parent == humanoidRootPart and linearVelocity.Parent == attachment and attachment.Name == "skill_stand_still" and v2:FindFirstChild("Cancel") == nil and linearVelocity:FindFirstChild("Cancel") == nil do
			local position, _, _, target = RaycastHelper.MaximizeRayClient(
				humanoidRootPart.Position,
				Platform_Handler.mousepos(),
				AIM_RADIUS,
				true,
				3
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
	track = humanoid.Animator:LoadAnimation(script.SerpentSlash_Start)
	track:Play(0.1, 1, 1)
	task.wait(Config.HOLD_FREEZE_AT)

	if SerpentSlash.Id ~= id then
		return
	end

	track:AdjustSpeed(0)
end

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

function SerpentSlash.UnHold(player)
	local _ = SerpentSlash.Id
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

	task.wait(Config.UNHOLD_RELEASE_DUR)
	destroyBodyMovers(character)
end

function SerpentSlash.Cancel(player)
	local character = player.Character
	character:FindFirstChild("HumanoidRootPart")
	character:FindFirstChild("Humanoid")

	if track then
		track:Stop()
		track = nil
	end

	destroyBodyMovers(character)
end

return SerpentSlash