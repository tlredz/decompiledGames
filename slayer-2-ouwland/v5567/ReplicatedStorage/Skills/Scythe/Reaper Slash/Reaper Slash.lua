local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DebrisModule = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("DebrisModule"))
local ReaperSlash = {
	Id = 0
}
local Platform_Handler = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Client"):WaitForChild("Controllers"):WaitForChild("Platform_Handler"))
local v = {}
local Utility = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Utility"))
local ManuelCancel = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Subsets"):WaitForChild("Gameplay"):WaitForChild("ManuelCancel"))
local worldPosition = nil
local p = nil
local p2 = nil
local v2 = nil
local RaycastHelper = require(ReplicatedStorage.CAM.Global.RaycastHelper)
local ArcLanding = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.ArcLanding)
local Config = require(script.Parent.Config)
local gameSettings = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("gameSettings"))
local track = nil
local track2 = nil
local track3 = nil

function ReaperSlash.Hold(player)
	local id = ReaperSlash.Id
	local character = player.Character
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	local humanoid = character:FindFirstChild("Humanoid")

	if track then
		track:Stop()
		track = nil
	end

	if track2 then
		track2:Stop()
		track2 = nil
	end

	if track3 then
		track3:Stop()
		track3 = nil
	end

	local getvaluesfolder = Utility.getvaluesfolder(character)
	local attachment = Instance.new("Attachment", humanoidRootPart)
	attachment.Name = "skill_stand_still"
	local linearVelocity = Instance.new("LinearVelocity")
	linearVelocity.Attachment0 = attachment
	linearVelocity.MaxForce = gameSettings.skillStandStillForce
	linearVelocity.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
	linearVelocity.VectorVelocity = createVector(0, 0, 0)
	linearVelocity.Parent = attachment
	local boolValue = Instance.new("BoolValue")
	boolValue.Name = "NR"
	boolValue.Parent = getvaluesfolder
	DebrisModule:AddItem(boolValue, 6)
	table.insert(v, boolValue)
	local alignOrientationWithAttachment, v3 = Utility.CreateAlignOrientationWithAttachment(
		humanoidRootPart,
		"skill_look_at",
		{
			AlignType = Enum.AlignType.PrimaryAxisParallel,
			Responsiveness = 45,
			MaxTorque = 3000
		}
	)
	local attachment2 = Instance.new("Attachment")
	local attachment3 = Instance.new("Attachment")
	attachment2.Parent = humanoidRootPart
	attachment3.Parent = humanoidRootPart
	local clone = script.Beam:Clone()
	clone.Parent = humanoidRootPart
	clone.Attachment0 = attachment2
	clone.Attachment1 = attachment3
	clone.FaceCamera = true
	table.insert(v, clone)
	DebrisModule:AddItem(attachment2, 6)
	DebrisModule:AddItem(attachment3, 6)
	DebrisModule:AddItem(clone, 6)
	table.insert(v, attachment2)
	table.insert(v, attachment3)
	local cframe = CFrame.Angles(0, 1.5707963267948966, 0)
	local highlight = Instance.new("Highlight")
	highlight.FillColor = Color3.fromRGB(220, 50, 50)
	highlight.DepthMode = Enum.HighlightDepthMode.Occluded
	highlight.OutlineColor = Color3.fromRGB(180, 0, 0)
	DebrisModule:AddItem(highlight, 15)
	table.insert(v, highlight)
	task.spawn(function()
		while attachment ~= nil and humanoidRootPart and linearVelocity ~= nil and attachment.Parent == humanoidRootPart and linearVelocity.Parent == attachment and attachment.Name == "skill_stand_still" and v3:FindFirstChild("Cancel") == nil and linearVelocity:FindFirstChild("Cancel") == nil do
			local maximizeRayClient, _, _, parent = RaycastHelper.MaximizeRayClient(
				humanoidRootPart.Position,
				Platform_Handler.mousepos(),
				Config.MAX_RANGE,
				true,
				5,
				15,
				3
			)
			local humanoidRootPart2 = nil

			if parent == nil then
				if highlight then
					highlight.Parent = workspace.Debree
				end
			elseif highlight then
				humanoidRootPart2 = parent:FindFirstChild("HumanoidRootPart")

				if humanoidRootPart2 then
					highlight.Parent = parent
				end
			end

			local position = maximizeRayClient or humanoidRootPart.Position + humanoidRootPart.CFrame.LookVector * Config.MAX_RANGE
			local position2 = humanoidRootPart.Position

			if clone ~= nil and humanoidRootPart ~= nil and parent ~= nil and attachment3 and attachment2 then
				position = parent.HumanoidRootPart.Position
			end

			if clone and attachment3 and attachment2 and attachment2.Parent ~= nil and attachment3 ~= nil then
				local bezier_Curve_beam_curve_calc, v5 = Utility.Bezier_Curve_beam_curve_calc(
					position2,
					position,
					Config.BEAM_ARC_HEIGHT
				)
				clone.CurveSize0 = (bezier_Curve_beam_curve_calc - position2).Magnitude
				clone.CurveSize1 = (v5 - position).Magnitude
				attachment2.WorldCFrame = CFrame.new(position2, bezier_Curve_beam_curve_calc) * cframe
				attachment3.WorldCFrame = CFrame.new(position, v5) * cframe:Inverse()
				worldPosition = attachment2.WorldPosition
				p = (attachment2.WorldCFrame * CFrame.new(clone.CurveSize0, 0, 0)).p
				p2 = (attachment3.WorldCFrame * CFrame.new(-clone.CurveSize1, 0, 0)).p
				v2 = humanoidRootPart2 or attachment3.WorldPosition
			end

			alignOrientationWithAttachment.CFrame = Utility.SafeLookAt(
				humanoidRootPart.Position,
				position,
				alignOrientationWithAttachment.CFrame
			)
			task.wait()
		end
	end)
	track = humanoid.Animator:LoadAnimation(script.Startup)
	track:Play()
	track:AdjustSpeed(1)
	task.wait(Config.HOLD_FREEZE_AT)

	if id == ReaperSlash.Id then
		track:AdjustSpeed(0)
	end
end

function ReaperSlash.UnHold(player)
	local v3 = track
	track = nil

	if v3 then
		v3:AdjustSpeed(1)
	end

	local id = ReaperSlash.Id
	local v4, v5 = ManuelCancel.new(player, 1)
	v4:Connect(function()
		id = -1
		ReaperSlash.Cancel(player)
	end)
	local character = player.Character
	local cframe = nil

	for _, v6 in pairs(v) do
		if v6.Name == "NR" then
			DebrisModule:AddItem(v6, 1)
		else
			v6:Destroy()
		end
	end

	if character ~= nil then
		local getvaluesfolder = Utility.getvaluesfolder(character)
		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
		local humanoid = character:FindFirstChild("Humanoid")

		if humanoidRootPart ~= nil then
			local children = {}

			if humanoidRootPart:FindFirstChild("skill_stand_still") ~= nil or humanoidRootPart.Name == "skill_look_at" then
				for _, child in pairs(humanoidRootPart:GetChildren()) do
					if not (child.Name == "skill_stand_still" or child.Name == "skill_look_at") then
						continue
					end

					if child.Name == "skill_look_at" then
						local boolValue = Instance.new("BoolValue")
						boolValue.Name = "Cancel"
						boolValue.Parent = child
						DebrisModule:AddItem(child, 1)
						table.insert(children, child)
					else
						child:Destroy()
					end
				end
			end

			if p2 ~= nil and v2 ~= nil and p ~= nil and worldPosition ~= nil then
				if humanoidRootPart:FindFirstChild("air_combo_bp") ~= nil then
					humanoidRootPart.air_combo_bp:Destroy()
				end

				local cFrame = humanoidRootPart.CFrame
				local attachment = Instance.new("Attachment", humanoidRootPart)
				DebrisModule:AddItem(attachment, 3)
				local alignPosition = Instance.new("AlignPosition")
				alignPosition.Mode = Enum.PositionAlignmentMode.OneAttachment
				alignPosition.Attachment0 = attachment
				alignPosition.Responsiveness = 165
				alignPosition.MaxForce = 30000
				alignPosition.Position = cFrame.Position
				alignPosition.Parent = attachment
				local boolValue = Instance.new("BoolValue")
				boolValue.Name = "pause_gameplay"
				boolValue.Parent = getvaluesfolder
				game.Debris:AddItem(boolValue, 1.25)
				local boolValue2 = Instance.new("BoolValue")
				boolValue2.Name = "NOMouvementlines"
				boolValue2.Parent = getvaluesfolder
				local typeName = typeof(v2)
				local position = v2

				if typeName == "Instance" then
					position = v2.Position
				end

				local v6 = (cFrame.Position - position).Magnitude / 10 * 0.3

				if humanoid then
					if v3 then
						v3:Stop()
					end

					track2 = humanoid.Animator:LoadAnimation(script.Loop)
					track2.Looped = true
					track2:Play()
				end

				for i = 1, Config.TRAVEL_SEGMENTS do
					local lastTime = os.clock()

					if ReaperSlash.Id == id then
						local position2

						if typeName == "Instance" and v2 ~= nil and v2.Parent ~= nil then
							position2 = v2.Position
						else
							position2 = false
						end

						if position2 then
							position = position2
						elseif typeName ~= "Instance" then
							position = v2 or position
						end

						local resolve = ArcLanding.Resolve
						local v7 = {
							Character = character,
							From = cFrame.Position,
							Goal = position,
							Target = 0,
							Range = 0
						}
						local target

						if position2 then
							target = v2.Parent
						end

						v7.Target = target
						v7.Range = Config.MAX_RANGE
						position = resolve(v7) or position
						local posInBeam = Utility.GetPosInBeam(
							i / Config.TRAVEL_SEGMENTS,
							worldPosition,
							p,
							p2,
							position
						)
						alignPosition.Position = posInBeam

						repeat
							task.wait()
						until ReaperSlash.Id ~= id or humanoidRootPart == nil or (humanoidRootPart.Position - posInBeam).Magnitude <= math.min(
							v6,
							1.15
						) or os.clock() - lastTime > Config.MAX_HANG_TIME / Config.TRAVEL_SEGMENTS
					else
						attachment:Destroy()
						boolValue:Destroy()
						boolValue2:Destroy()
						return
					end
				end

				alignPosition.Position = position
				humanoidRootPart.AssemblyLinearVelocity = createVector(0, 0, 0)
				humanoidRootPart.AssemblyAngularVelocity = createVector(0, 0, 0)
				local v7 = (position - cFrame.Position) * createVector(1, 0, 1)
				local v8

				if v7.Magnitude > 0.01 then
					v8 = v7.Unit
				else
					v8 = (cFrame.LookVector * createVector(1, 0, 1)).Unit
				end

				cframe = CFrame.lookAt(position, position + v8)

				if boolValue2 then
					DebrisModule:AddItem(boolValue2, 0.35)
				end

				if attachment ~= nil and attachment.Parent ~= nil then
					DebrisModule:AddItem(attachment, 0.35)
				end

				for _, v9 in ipairs(children) do
					DebrisModule:AddItem(v9, 0.35)
				end

				if boolValue ~= nil then
					boolValue:Destroy()
				end

				if track2 then
					track2:Stop()
					track2 = nil
				end

				if humanoid and ReaperSlash.Id == id then
					track3 = humanoid.Animator:LoadAnimation(script.End)
					track3:Play()
				end
			end
		end
	end

	v5()

	if id == ReaperSlash.Id then
		return cframe or character.PrimaryPart.CFrame
	end
end

function ReaperSlash.Cancel(player)
	if track then
		track:Stop()
		track = nil
	end

	if track2 then
		track2:Stop()
		track2 = nil
	end

	if track3 then
		track3:Stop()
		track3 = nil
	end

	for _, v3 in pairs(v) do
		v3:Destroy()
	end

	local character = player.Character

	if character ~= nil then
		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart ~= nil then
			humanoidRootPart.AssemblyLinearVelocity = createVector(0, 0, 0)
			humanoidRootPart.AssemblyAngularVelocity = createVector(0, 0, 0)

			if humanoidRootPart:FindFirstChild("skill_stand_still") ~= nil or humanoidRootPart.Name == "skill_look_at" then
				for _, child in pairs(humanoidRootPart:GetChildren()) do
					if child.Name == "skill_stand_still" or child.Name == "skill_look_at" then
						child:Destroy()
					end
				end
			end
		end
	end
end

return ReaperSlash