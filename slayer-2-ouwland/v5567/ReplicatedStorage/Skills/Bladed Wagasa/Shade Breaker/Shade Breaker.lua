local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local CAM = ReplicatedStorage.CAM
local skills = ReplicatedStorage.Skills
local cleanit = require(ReplicatedStorage.Packages.cleanit)
local maid = cleanit.new()
local DebrisModule = require(CAM.DebrisModule)
local Utility = require(CAM.Global.Utility)
local RaycastHelper = require(CAM.Global.RaycastHelper)
local ArcLanding = require(CAM.Global.Subsets.Gameplay.ArcLanding)
local Platform_Handler = require(CAM.Client.Controllers.Platform_Handler)
local ManuelCancel = require(CAM.Global.Subsets.Gameplay.ManuelCancel)
local SkillAimMarker = require(CAM.Client.Modules.Effects.SkillAimMarker)
local Config = require(script.Parent.Config)
local ShadeBreaker = {
	Id = 0
}
local skill_stand_still = skills.holder.skill_stand_still
local shadeBreaker = script.ShadeBreaker
local umbrellaShadeBreaker = script.UmbrellaShadeBreaker
local track = nil
local track2 = nil
local v = nil
local v2 = nil
local v3 = nil
local v4 = nil

function ShadeBreaker.Hold(player)
	maid:Clean()

	if track then
		track:Stop()
		track = nil
	end

	if track2 then
		track2:Stop()
		track2 = nil
	end

	v = nil
	v2 = nil
	v3 = nil
	v4 = nil
	local character = player.Character
	local humanoid = character and character:FindFirstChild("Humanoid")
	local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if not (animator and humanoidRootPart) then
		return
	end

	local id = ShadeBreaker.Id
	local getvaluesfolder = Utility.getvaluesfolder(character)
	maid:Add(Utility.AddValue(getvaluesfolder, "NR", Config.MAX_DURATION))
	local air_combo_bp = humanoidRootPart:FindFirstChild("air_combo_bp")

	if air_combo_bp then
		air_combo_bp:Destroy()
	end

	humanoidRootPart.AssemblyLinearVelocity = createVector(0, 0, 0)
	local clone = skill_stand_still:Clone()
	clone.Parent = humanoidRootPart
	maid:Add(clone)
	DebrisModule:AddItem(clone, Config.MAX_DURATION + 0.2)
	local alignOrientationWithAttachment, v5 = Utility.CreateAlignOrientationWithAttachment(
		humanoidRootPart,
		"skill_look_at",
		{
			AlignType = Enum.AlignType.PrimaryAxisParallel,
			Responsiveness = 45,
			MaxTorque = 3000
		}
	)
	maid:Add(alignOrientationWithAttachment)
	maid:Add(v5)
	DebrisModule:AddItem(alignOrientationWithAttachment, Config.MAX_DURATION + 0.2)
	DebrisModule:AddItem(v5, Config.MAX_DURATION + 0.2)
	local v6 = SkillAimMarker.new({
		GroundCircle = {
			CFrame = humanoidRootPart.CFrame * CFrame.new(0, -2.5, 0)
		},
		Highlight = {
			FillColor = Color3.fromRGB(255, 200, 60),
			OutlineColor = Color3.fromRGB(190, 120, 0)
		},
		Beam = {
			Part0 = humanoidRootPart,
			Part1 = humanoidRootPart,
			Height = Config.ARC_HEIGHT,
			Properties = {
				FaceCamera = true
			}
		}
	})
	maid:Add(v6)
	maid:Connect(RunService.PostSimulation, function()
		if ShadeBreaker.Id ~= id or humanoidRootPart.Parent == nil then
			return
		end

		local maximizeRayClient, _, _, target = RaycastHelper.MaximizeRayClient(
			humanoidRootPart.Position,
			Platform_Handler.mousepos(500),
			Config.AIM_RANGE,
			true,
			5,
			15,
			3
		)
		local humanoidRootPart2 = target and target:FindFirstChild("HumanoidRootPart")
		local position = humanoidRootPart.Position
		local position2 = humanoidRootPart2 and humanoidRootPart2.Position or maximizeRayClient or position + humanoidRootPart.CFrame.LookVector * Config.AIM_RANGE

		if not humanoidRootPart2 then
			target = nil
		end

		v, v2, v3 = v6:Update({
			target = target,
			startpos = position,
			goalpos = position2
		})
		v4 = humanoidRootPart2 or position2
		alignOrientationWithAttachment.CFrame = CFrame.new(position, position2)
	end)
	track = animator:LoadAnimation(shadeBreaker)
	track:Play()
	track2 = animator:LoadAnimation(umbrellaShadeBreaker)
	track2:Play()
	task.delay(Config.HOLD_PAUSE, function()
		if ShadeBreaker.Id ~= id then
			return
		end

		if track and track.IsPlaying then
			track:AdjustSpeed(0)
		end

		if track2 and track2.IsPlaying then
			track2:AdjustSpeed(0)
		end
	end)
end

function ShadeBreaker.UnHold(player)
	local id = ShadeBreaker.Id
	local character = player.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart == nil then
		maid:Clean()
		return true
	end

	for _, v5 in { track, track2 } do
		if not v5 then
			continue
		end

		if v5.TimePosition < Config.HOLD_PAUSE then
			v5.TimePosition = Config.HOLD_PAUSE
		end

		v5:AdjustSpeed(1.5)
	end

	maid:Clean()
	local v5 = v
	local v6 = v2
	local v7 = v3
	local v8 = v4

	if v5 == nil or v6 == nil or v7 == nil or v8 == nil then
		return true
	end

	local v9, v10 = ManuelCancel.new(player, Config.MAX_HANG_TIME + 1)
	v9:Connect(function()
		id = -1
		ShadeBreaker.Cancel(player)
	end)
	local air_combo_bp = humanoidRootPart:FindFirstChild("air_combo_bp")

	if air_combo_bp then
		air_combo_bp:Destroy()
	end

	local getvaluesfolder = Utility.getvaluesfolder(character)
	local attachment = Instance.new("Attachment")
	attachment.Name = "ShadeBreakerFlight"
	attachment.Parent = humanoidRootPart
	DebrisModule:AddItem(attachment, Config.MAX_HANG_TIME + 1)
	local alignPosition = Instance.new("AlignPosition")
	alignPosition.Mode = Enum.PositionAlignmentMode.OneAttachment
	alignPosition.Attachment0 = attachment
	alignPosition.Responsiveness = 165
	alignPosition.MaxForce = 30000
	alignPosition.Position = v5
	alignPosition.Parent = attachment
	local v11 = Utility.AddValue(getvaluesfolder, "NOMouvementlines", Config.MAX_HANG_TIME + 1)
	local v12 = Utility.AddValue(getvaluesfolder, "NR", Config.MAX_HANG_TIME + 1)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function teardownFlight()
		attachment:Destroy()

		if v11 then
			v11:Destroy()
		end

		if v12 then
			v12:Destroy()
		end
	end

	local v13 = typeof(v8) == "Instance"
	local position

	if v13 then
		position = v8.Position
	else
		position = v8
	end

	local v14 = math.min((v5 - position).Magnitude / Config.SEGMENTS * 0.3, 1.15)

	for i = 1, Config.SEGMENTS do
		local lastTime = os.clock()

		if ShadeBreaker.Id == id then
			local v15 = v13 and v8.Parent ~= nil

			if v15 then
				position = v8.Position
			end

			local resolve = ArcLanding.Resolve
			local target

			if v15 then
				target = v8.Parent
			end

			position = resolve({
				Character = character,
				From = v5,
				Goal = position,
				Target = target,
				Range = Config.AIM_RANGE
			}) or position
			alignPosition.Position = Utility.GetPosInBeam(i / Config.SEGMENTS, v5, v6, v7, position)

			repeat
				task.wait()
			until ShadeBreaker.Id ~= id or humanoidRootPart.Parent == nil or (humanoidRootPart.Position - alignPosition.Position).Magnitude <= v14 or os.clock() - lastTime > Config.MAX_HANG_TIME / Config.SEGMENTS
		else
			teardownFlight() -- equivalent call inferred; original call site unknown
			return true
		end
	end

	teardownFlight() -- equivalent call inferred; original call site unknown
	humanoidRootPart.AssemblyLinearVelocity = createVector(0, 0, 0)
	humanoidRootPart.AssemblyAngularVelocity = createVector(0, 0, 0)
	local clone = skill_stand_still:Clone()
	clone.Parent = humanoidRootPart
	DebrisModule:AddItem(clone, Config.ENDLAG)
	Utility.AddValue(getvaluesfolder, "NR", Config.ENDLAG)
	v10()
	return ShadeBreaker.Id ~= id or humanoidRootPart.CFrame
end

function ShadeBreaker.Cancel(player)
	maid:Clean()

	if track then
		track:Stop()
		track = nil
	end

	if track2 then
		track2:Stop()
		track2 = nil
	end

	local character = player.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart then
		humanoidRootPart.AssemblyLinearVelocity = createVector(0, 0, 0)
		humanoidRootPart.AssemblyAngularVelocity = createVector(0, 0, 0)
		local shadeBreakerFlight = humanoidRootPart:FindFirstChild("ShadeBreakerFlight")

		if shadeBreakerFlight then
			shadeBreakerFlight:Destroy()
		end

		for _, child in humanoidRootPart:GetChildren() do
			if child.Name == "skill_stand_still" or child.Name == "skill_look_at" then
				child:Destroy()
			end
		end
	end
end

return ShadeBreaker