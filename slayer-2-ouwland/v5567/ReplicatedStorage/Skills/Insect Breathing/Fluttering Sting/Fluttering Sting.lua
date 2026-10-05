local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DebrisModule = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("DebrisModule"))
local FlutteringSting = {
	Id = 0
}
local _ = Vector3.new
local Platform_Handler = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Client"):WaitForChild("Controllers"):WaitForChild("Platform_Handler"))
local v = {}
local Utility = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Utility"))
require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Checker"))
require(game.ReplicatedStorage.CAM.Client.Modules.Effects.vfxUtility)
local ManuelCancel = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Subsets"):WaitForChild("Gameplay"):WaitForChild("ManuelCancel"))
local worldPosition = nil
local p = nil
local p2 = nil
local v2 = nil
local _ = table.find
local _ = table.remove
local RaycastHelper = require(ReplicatedStorage.CAM.Global.RaycastHelper)
local ArcLanding = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.ArcLanding)
local Config = require(script.Parent.Config)
local gameSettings = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("gameSettings"))

function FlutteringSting.Hold(player)
	local id = FlutteringSting.Id
	local character = player.Character
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	local humanoid = character:FindFirstChild("Humanoid")

	if anim then
		anim:Stop()
		anim = nil
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
	DebrisModule:AddItem(boolValue, Config.HOLD_NR_DURATION)
	table.insert(v, boolValue)
	local clone = script.ground_ef:Clone()
	clone.CFrame = humanoidRootPart.CFrame * CFrame.new(0, -2.5, 0)
	clone.Parent = workspace.Debree
	clone.base_ef123asd:Emit(1)
	table.insert(v, clone)
	local alignOrientationWithAttachment, v3 = Utility.CreateAlignOrientationWithAttachment(
		humanoidRootPart,
		"skill_look_at",
		{
			AlignType = Enum.AlignType.PrimaryAxisParallel,
			Responsiveness = 45,
			MaxTorque = 3000
		}
	)
	local highlight = Instance.new("Highlight")
	highlight.FillColor = Color3.fromRGB(243, 111, 255)
	highlight.DepthMode = Enum.HighlightDepthMode.Occluded
	highlight.OutlineColor = Color3.fromRGB(255, 0, 255)
	DebrisModule:AddItem(highlight, 15)
	table.insert(v, highlight)
	local attachment2 = Instance.new("Attachment")
	local attachment3 = Instance.new("Attachment")
	attachment2.Parent = humanoidRootPart
	attachment3.Parent = humanoidRootPart
	local clone2 = script.Beam:Clone()
	clone2.Parent = humanoidRootPart
	clone2.Attachment0 = attachment2
	clone2.Attachment1 = attachment3
	clone2.FaceCamera = true
	table.insert(v, clone2)
	DebrisModule:AddItem(attachment2, 6)
	DebrisModule:AddItem(attachment3, 6)
	DebrisModule:AddItem(clone2, 6)
	table.insert(v, attachment2)
	table.insert(v, attachment3)
	local cframe = CFrame.Angles(0, 1.5707963267948966, 0)
	task.spawn(function()
		while attachment ~= nil and humanoidRootPart and linearVelocity ~= nil and attachment.Parent == humanoidRootPart and linearVelocity.Parent == attachment and attachment.Name == "skill_stand_still" and v3:FindFirstChild("Cancel") == nil and linearVelocity:FindFirstChild("Cancel") == nil do
			local position, _, _, parent = RaycastHelper.MaximizeRayClient(
				humanoidRootPart.Position,
				Platform_Handler.mousepos(),
				Config.RANGE,
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

			local position2 = humanoidRootPart.Position

			if clone2 ~= nil and humanoidRootPart ~= nil and parent ~= nil and attachment3 and attachment2 then
				position = parent.HumanoidRootPart.Position
			end

			if clone2 and attachment3 and attachment2 and attachment2.Parent ~= nil and attachment3 ~= nil then
				local bezier_Curve_beam_curve_calc, v5 = Utility.Bezier_Curve_beam_curve_calc(
					position2,
					position,
					Config.BEAM_ARC_HEIGHT
				)
				clone2.CurveSize0 = (bezier_Curve_beam_curve_calc - position2).Magnitude
				clone2.CurveSize1 = (v5 - position).Magnitude
				attachment2.WorldCFrame = CFrame.new(position2, bezier_Curve_beam_curve_calc) * cframe
				attachment3.WorldCFrame = CFrame.new(position, v5) * cframe:Inverse()
				worldPosition = attachment2.WorldPosition
				p = (attachment2.WorldCFrame * CFrame.new(clone2.CurveSize0, 0, 0)).p
				p2 = (attachment3.WorldCFrame * CFrame.new(-clone2.CurveSize1, 0, 0)).p
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
	anim = humanoid.Animator:LoadAnimation(script.Start)
	anim:Play()
	anim:AdjustSpeed(1)
	task.wait(Config.HOLD_FREEZE_AT)

	if id == FlutteringSting.Id then
		anim:AdjustSpeed(0)
	end
end

function FlutteringSting.UnHold(player)
	if anim then
		anim:AdjustSpeed(1)
		anim = nil
	end

	local id = FlutteringSting.Id
	local v3, v4 = ManuelCancel.new(player, Config.UNHOLD_CANCEL_WINDOW)
	v3:Connect(function()
		id = -1
		FlutteringSting.Cancel(player)
	end)
	local character = player.Character

	for _, v5 in pairs(v) do
		if v5.Name == "NR" then
			DebrisModule:AddItem(v5, Config.UNHOLD_NR_DURATION)
		else
			v5:Destroy()
		end
	end

	if character ~= nil then
		local getvaluesfolder = Utility.getvaluesfolder(character)
		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
		character:FindFirstChild("Humanoid")

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
				alignPosition.Responsiveness = Config.TRAVEL_RESPONSIVENESS
				alignPosition.MaxForce = Config.TRAVEL_MAX_FORCE
				alignPosition.Position = cFrame.Position
				alignPosition.Parent = attachment
				local boolValue = Instance.new("BoolValue")
				boolValue.Name = "pause_gameplay"
				boolValue.Parent = getvaluesfolder
				game.Debris:AddItem(boolValue, Config.TRAVEL_LOCK_DURATION)
				local boolValue2 = Instance.new("BoolValue")
				boolValue2.Name = "NOMouvementlines"
				boolValue2.Parent = getvaluesfolder
				local typeName = typeof(v2)
				local position = v2

				if typeName == "Instance" then
					position = v2.Position
				end

				local v5 = (cFrame.Position - position).Magnitude / 10 * 0.3

				for i = 1, Config.TRAVEL_SEGMENTS do
					local lastTime = os.clock()

					if FlutteringSting.Id == id then
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
						local v6 = {
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

						v6.Target = target
						v6.Range = Config.RANGE
						position = resolve(v6) or position
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
						until FlutteringSting.Id ~= id or humanoidRootPart == nil or (humanoidRootPart.Position - posInBeam).Magnitude <= math.min(
							v5,
							1.15
						) or os.clock() - lastTime > Config.MAX_TRAVEL_TIME / Config.TRAVEL_SEGMENTS
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

				if boolValue2 then
					DebrisModule:AddItem(boolValue2, 0.35)
				end

				if attachment ~= nil and attachment.Parent ~= nil then
					DebrisModule:AddItem(attachment, 0.35)
				end

				for _, v6 in ipairs(children) do
					DebrisModule:AddItem(v6, 0.35)
				end

				if boolValue ~= nil then
					boolValue:Destroy()
				end
			end
		end
	end

	v4()

	if id == FlutteringSting.Id then
		return character.PrimaryPart.CFrame
	end
end

function FlutteringSting.Cancel(player)
	if anim then
		anim:Stop()
		anim = nil
	end

	for _, v3 in pairs(v) do
		v3:Destroy()
	end

	local _ = FlutteringSting.Id
	local character = player.Character

	if character ~= nil then
		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
		character:FindFirstChild("Humanoid")

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

return FlutteringSting