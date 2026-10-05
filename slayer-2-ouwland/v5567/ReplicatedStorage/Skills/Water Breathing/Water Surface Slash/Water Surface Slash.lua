local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local global = ReplicatedStorage.CAM.Global
local DebrisModule = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("DebrisModule"))
local Platform_Handler = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Client"):WaitForChild("Controllers"):WaitForChild("Platform_Handler"))
local Utility = require(global.Utility)
local Config = require(script.Parent.Config)
local v = {}
local track = nil
local track2 = nil
local flag = false
local new = Vector3.new
local TweenService = game:GetService("TweenService")

local function canceleverything(player, p, p2)
	if flag == true then
		return
	end

	if track ~= nil then
		track:Stop()
		track = nil
	end

	local character = player.Character

	if character == nil then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	local humanoid = character:FindFirstChild("Humanoid")

	if humanoidRootPart == nil or humanoid == nil then
		return
	end

	if humanoidRootPart:FindFirstChild("skill_stand_still") ~= nil or humanoidRootPart:FindFirstChild("skill_look_at") then
		for _, child in pairs(humanoidRootPart:GetChildren()) do
			if not (child.Name == "skill_stand_still" or child.Name == "skill_look_at") then
				continue
			end

			if child.Name == "skill_stand_still" then
				if p == "customtimer" then
					local v2 = child
					task.delay(0.1, function()
						if v2 ~= nil and v2:FindFirstChild("bp") ~= nil then
							TweenService:Create(v2.bp, TweenInfo.new(0.25, Enum.EasingStyle.Sine), {
								VectorVelocity = new()
							}):Play()
						end
					end)
				else
					TweenService:Create(child.bp, TweenInfo.new(0.25, Enum.EasingStyle.Sine), {
						VectorVelocity = new()
					}):Play()
				end
			end

			local boolValue = Instance.new("BoolValue")
			boolValue.Name = "Cancel"
			boolValue.Parent = child
			DebrisModule:AddItem(child, p == "customtimer" and p2 or 0.25)
		end
	end
end

local WaterSurfaceSlash = {}
WaterSurfaceSlash.Id = 0

function WaterSurfaceSlash.Hold(player)
	flag = false
	local character = player.Character
	local humanoidRootPart = character.HumanoidRootPart
	local humanoid = character.Humanoid

	if track then
		track:Stop()
		track = nil
	end

	for _, v2 in pairs(v) do
		v2:Destroy()
	end

	local getvaluesfolder = Utility.getvaluesfolder(character)
	local boolValue = Instance.new("BoolValue")
	boolValue.Name = "NOMouvementlines"
	boolValue.Parent = getvaluesfolder
	DebrisModule:AddItem(boolValue, 5)
	table.insert(v, boolValue)
	local attachment = Instance.new("Attachment", humanoidRootPart)
	attachment.Name = "skill_stand_still"
	local linearVelocity = Instance.new("LinearVelocity")
	linearVelocity.Attachment0 = attachment
	linearVelocity.Name = "bp"
	linearVelocity.ForceLimitMode = Enum.ForceLimitMode.PerAxis
	linearVelocity.MaxAxesForce = createVector(10000, 0, 10000)
	linearVelocity.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
	local mousepos = Platform_Handler.mousepos(Config.MOUSE_RANGE)
	linearVelocity.VectorVelocity = (new(mousepos.X, humanoidRootPart.Position.Y, mousepos.Z) - humanoidRootPart.Position).Unit * 0
	linearVelocity.Parent = attachment
	local alignOrientationWithAttachment, v2 = Utility.CreateAlignOrientationWithAttachment(
		humanoidRootPart,
		"skill_look_at",
		{
			AlignType = Enum.AlignType.PrimaryAxisParallel,
			Responsiveness = 45,
			MaxTorque = 1000,
			CFrame = Utility.SafeLookAt(humanoidRootPart.Position, mousepos, humanoidRootPart.CFrame)
		}
	)
	task.spawn(function()
		track = humanoid.Animator:LoadAnimation(script.run)
		track:Play()

		while attachment ~= nil and humanoidRootPart and linearVelocity ~= nil and attachment.Parent == humanoidRootPart and linearVelocity.Parent == attachment and attachment.Name == "skill_stand_still" and v2:FindFirstChild("Cancel") == nil and linearVelocity:FindFirstChild("Cancel") == nil do
			mousepos = Platform_Handler.mousepos(Config.MOUSE_RANGE)
			linearVelocity.VectorVelocity = (new(mousepos.X, humanoidRootPart.Position.Y, mousepos.Z) - humanoidRootPart.Position).Unit * Config.DASH_SPEED
			alignOrientationWithAttachment.CFrame = Utility.SafeLookAt(
				humanoidRootPart.Position,
				mousepos,
				alignOrientationWithAttachment.CFrame
			)
			task.wait()
		end
	end)
end

function WaterSurfaceSlash.UnHold(player)
	task.spawn(function()
		if flag then
			return
		end

		canceleverything(player, "customtimer", 0.35)
	end)
	local character = player.Character

	if character == nil then
		return
	end

	local humanoid = character:FindFirstChild("Humanoid")

	if humanoid == nil then
		return
	end

	flag = true
	track2 = humanoid.Animator:LoadAnimation(script.slash)
	track2:Play()
end

function WaterSurfaceSlash.Cancel(p)
	canceleverything(p, "customtimer", 0.35)
	flag = true

	if track2 ~= nil then
		track2:Stop()
		track2 = nil
	end
end

return WaterSurfaceSlash