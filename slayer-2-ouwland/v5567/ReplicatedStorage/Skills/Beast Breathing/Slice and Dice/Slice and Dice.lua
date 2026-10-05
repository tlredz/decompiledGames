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
local SliceAndDice = {
	Id = 0
}
local skill_stand_still = skills.holder.skill_stand_still
local startup = script.Startup
local loop = script.Loop
local v = script.End
local color = Color3.fromRGB(40, 200, 255)
local color2 = Color3.fromRGB(0, 150, 230)
local assets = ReplicatedStorage:FindFirstChild("Assets")
local ground_aim_effect = assets and assets:FindFirstChild("ground_aim_effect")
local particleEmitter = ground_aim_effect and ground_aim_effect:FindFirstChildWhichIsA("ParticleEmitter", true)
local radius

if particleEmitter == nil then
	radius = nil
else
	radius = particleEmitter.Size.Keypoints[1].Value * Config.RING_SCALE
end

local v3 = nil
local v4 = nil
local v5 = nil
local v6 = nil
local v7 = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function stopStartup()
	if v7 then
		v7:Stop()
		v7 = nil
	end
end

function SliceAndDice.Hold(player)
	maid:Clean()
	stopStartup() -- equivalent call inferred; original call site unknown
	v3 = nil
	v4 = nil
	v5 = nil
	v6 = nil
	local character = player.Character
	local humanoid = character and character:FindFirstChild("Humanoid")
	local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart == nil then
		return
	end

	local id = SliceAndDice.Id
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
	local alignOrientationWithAttachment, v8 = Utility.CreateAlignOrientationWithAttachment(
		humanoidRootPart,
		"skill_look_at",
		{
			AlignType = Enum.AlignType.PrimaryAxisParallel,
			Responsiveness = 45,
			MaxTorque = 3000
		}
	)
	maid:Add(alignOrientationWithAttachment)
	maid:Add(v8)
	DebrisModule:AddItem(alignOrientationWithAttachment, Config.MAX_DURATION + 0.2)
	DebrisModule:AddItem(v8, Config.MAX_DURATION + 0.2)
	local v9 = SkillAimMarker.new({
		GroundCircle = {
			CFrame = humanoidRootPart.CFrame * CFrame.new(0, -2.5, 0),
			Radius = radius,
			Color = color
		},
		Highlight = {
			FillColor = color,
			OutlineColor = color2
		},
		Beam = {
			Part0 = humanoidRootPart,
			Part1 = humanoidRootPart,
			Height = Config.ARC_HEIGHT,
			Properties = {
				FaceCamera = true,
				Color = color
			}
		}
	})
	maid:Add(v9)
	maid:Connect(RunService.PostSimulation, function()
		if SliceAndDice.Id ~= id or humanoidRootPart.Parent == nil then
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

		v3, v4, v5 = v9:Update({
			target = target,
			startpos = position,
			goalpos = position2
		})
		v6 = humanoidRootPart2 or position2
		alignOrientationWithAttachment.CFrame = Utility.SafeLookAt(
			position,
			position2,
			alignOrientationWithAttachment.CFrame
		)
	end)

	if animator then
		local track = animator:LoadAnimation(startup)
		v7 = track
		track:Play()
		task.delay(Config.HOLD_PAUSE, function()
			if SliceAndDice.Id ~= id or v7 ~= track then
				return
			end

			if track.IsPlaying then
				track:AdjustSpeed(0)
			end
		end)
	end
end

function SliceAndDice.UnHold(player)
	local id = SliceAndDice.Id
	local character = player.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart == nil then
		maid:Clean()
		stopStartup() -- equivalent call inferred; original call site unknown
		return true
	else
		maid:Clean()
		local v8 = v3
		local v9 = v4
		local v10 = v5
		local v11 = v6

		if v8 == nil or v9 == nil or v10 == nil or v11 == nil then
			stopStartup() -- equivalent call inferred; original call site unknown
			return true
		else
			local v12, v13 = ManuelCancel.new(player, Config.RELEASE_WINDUP + Config.MAX_HANG_TIME + 1)
			v12:Connect(function()
				id = -1
				SliceAndDice.Cancel(player)
			end)
			local humanoid = character:FindFirstChild("Humanoid")
			local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")
			local v14 = v7
			v7 = nil
			local track = nil
			local flag = false

			if v14 then
				if v14.TimePosition < Config.HOLD_PAUSE then
					v14.TimePosition = Config.HOLD_PAUSE
				end

				v14:AdjustSpeed(1)
				maid:Add(v14)
				task.delay(Config.STARTUP_LENGTH - Config.HOLD_PAUSE, function()
					if flag or SliceAndDice.Id ~= id or animator == nil then
						return
					end

					v14:Stop()
					track = animator:LoadAnimation(loop)
					track.Looped = true
					maid:Add(track)
					track:Play()
				end)
			end

			local clone = skill_stand_still:Clone()
			clone.Parent = humanoidRootPart
			maid:Add(clone)
			DebrisModule:AddItem(clone, Config.RELEASE_WINDUP + 0.2)
			task.wait(Config.RELEASE_WINDUP)
			clone:Destroy()

			if SliceAndDice.Id ~= id or humanoidRootPart.Parent == nil then
				v13()
				return true
			end

			local air_combo_bp = humanoidRootPart:FindFirstChild("air_combo_bp")

			if air_combo_bp then
				air_combo_bp:Destroy()
			end

			local getvaluesfolder = Utility.getvaluesfolder(character)
			local attachment = Instance.new("Attachment")
			attachment.Name = "SliceAndDiceFlight"
			attachment.Parent = humanoidRootPart
			DebrisModule:AddItem(attachment, Config.MAX_HANG_TIME + 1)
			local alignPosition = Instance.new("AlignPosition")
			alignPosition.Mode = Enum.PositionAlignmentMode.OneAttachment
			alignPosition.Attachment0 = attachment
			alignPosition.Responsiveness = 165
			alignPosition.MaxForce = 30000
			alignPosition.Position = v8
			alignPosition.Parent = attachment
			local v15 = Utility.AddValue(getvaluesfolder, "NOMouvementlines", Config.MAX_HANG_TIME + 1)
			local v16 = Utility.AddValue(getvaluesfolder, "NR", Config.MAX_HANG_TIME + 1)

			-- equivalent calls inferred from this helper; original call sites unknown
			local function teardownFlight()
				attachment:Destroy()

				if v15 then
					v15:Destroy()
				end

				if v16 then
					v16:Destroy()
				end
			end

			local v17 = typeof(v11) == "Instance"
			local position

			if v17 then
				position = v11.Position
			else
				position = v11
			end

			local v18 = math.min((v8 - position).Magnitude / Config.SEGMENTS * 0.3, 1.15)

			-- equivalent calls inferred from this helper; original call sites unknown
			local function playEnd()
				if flag then
					return
				end

				flag = true

				if v14 then
					v14:Stop()
				end

				if track then
					track:Stop()
				end

				if animator then
					local track2 = animator:LoadAnimation(v)
					maid:Add(track2)
					track2:Play()
				end
			end

			local now = os.clock()
			local v19 = Config.MAX_HANG_TIME / Config.SEGMENTS

			local function checkEndLead(p: number, p2: number)
				local v20

				if p > 1 then
					v20 = (p2 - now) / (p - 1)
				else
					v20 = v19
				end

				if v20 * (Config.SEGMENTS - p + 1) - (os.clock() - p2) <= Config.END_LEAD then
					playEnd() -- equivalent call inferred; original call site unknown
				end
			end

			for i = 1, Config.SEGMENTS do
				local lastTime = os.clock()

				if SliceAndDice.Id == id then
					local v20 = v17 and v11.Parent ~= nil

					if v20 then
						position = v11.Position
					end

					local resolve = ArcLanding.Resolve
					local target

					if v20 then
						target = v11.Parent
					end

					position = resolve({
						Character = character,
						From = v8,
						Goal = position,
						Target = target,
						Range = Config.AIM_RANGE
					}) or position
					alignPosition.Position = Utility.GetPosInBeam(i / Config.SEGMENTS, v8, v9, v10, position)

					repeat
						task.wait()
						local v23

						if i > 1 then
							v23 = (lastTime - now) / (i - 1)
						else
							v23 = v19
						end

						if v23 * (Config.SEGMENTS - i + 1) - (os.clock() - lastTime) <= Config.END_LEAD and not flag then
							flag = true

							if v14 then
								v14:Stop()
							end

							if track then
								track:Stop()
							end

							if animator then
								local track2 = animator:LoadAnimation(v)
								maid:Add(track2)
								track2:Play()
							end
						end
					until SliceAndDice.Id ~= id or humanoidRootPart.Parent == nil or (humanoidRootPart.Position - alignPosition.Position).Magnitude <= v18 or v19 < os.clock() - lastTime
				else
					teardownFlight() -- equivalent call inferred; original call site unknown
					return true
				end
			end

			teardownFlight() -- equivalent call inferred; original call site unknown
			humanoidRootPart.AssemblyLinearVelocity = createVector(0, 0, 0)
			humanoidRootPart.AssemblyAngularVelocity = createVector(0, 0, 0)
			playEnd() -- equivalent call inferred; original call site unknown
			local clone2 = skill_stand_still:Clone()
			clone2.Parent = humanoidRootPart
			DebrisModule:AddItem(clone2, Config.ENDLAG)
			Utility.AddValue(getvaluesfolder, "NR", Config.ENDLAG)
			v13()
			return SliceAndDice.Id ~= id or humanoidRootPart.CFrame
		end
	end
end

function SliceAndDice.Cancel(player)
	maid:Clean()
	stopStartup() -- equivalent call inferred; original call site unknown
	local character = player.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart then
		humanoidRootPart.AssemblyLinearVelocity = createVector(0, 0, 0)
		humanoidRootPart.AssemblyAngularVelocity = createVector(0, 0, 0)
		local sliceAndDiceFlight = humanoidRootPart:FindFirstChild("SliceAndDiceFlight")

		if sliceAndDiceFlight then
			sliceAndDiceFlight:Destroy()
		end

		for _, child in humanoidRootPart:GetChildren() do
			if child.Name == "skill_stand_still" or child.Name == "skill_look_at" then
				child:Destroy()
			end
		end
	end
end

return SliceAndDice