local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("ServerStorage")
local DebrisModule = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("DebrisModule"))
local Reaptide = {
	Id = 0
}
local _ = Vector3.new
local Platform_Handler = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Client"):WaitForChild("Controllers"):WaitForChild("Platform_Handler"))
local v = {}
local Utility = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Utility"))
local Config = require(script.Parent.Config)
require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Checker"))
require(game.ReplicatedStorage.CAM.Client.Modules.Effects.vfxUtility)
local ManuelCancel = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Subsets"):WaitForChild("Gameplay"):WaitForChild("ManuelCancel"))
local SkillAimMarker = require(ReplicatedStorage.CAM.Client.Modules.Effects.SkillAimMarker)
local v2 = nil
local v3 = nil
local v4 = nil
local v5 = nil
local _ = table.find
local _ = table.remove
local RaycastHelper = require(ReplicatedStorage.CAM.Global.RaycastHelper)
local ArcLanding = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.ArcLanding)
local gameSettings = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("gameSettings"))
local color = Color3.new(0, 0.6, 1)
local color2 = Color3.new(0.403922, 0.792157, 1)
local formatted = `PosPart{script.Parent.Name}`

function Reaptide.Hold(player)
	local id = Reaptide.Id
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
	DebrisModule:AddItem(boolValue, 6)
	table.insert(v, boolValue)
	local alignOrientationWithAttachment, v6 = Utility.CreateAlignOrientationWithAttachment(
		humanoidRootPart,
		"skill_look_at",
		{
			AlignType = Enum.AlignType.PrimaryAxisParallel,
			Responsiveness = 45,
			MaxTorque = 3000
		}
	)
	local v7 = SkillAimMarker.new({
		Beam = {
			Part0 = humanoidRootPart,
			Part1 = humanoidRootPart,
			Height = Config.BEAM_HEIGHT,
			Properties = {
				Color = color
			}
		},
		Highlight = {
			FillColor = color2,
			OutlineColor = color2
		},
		Ground = {
			Color = color,
			radius = Config.TARGET_RANGE,
			CFrame = humanoidRootPart.CFrame * CFrame.new(0, -2.5, 0)
		}
	})
	DebrisModule:AddItem(v7, 6)
	table.insert(v, v7)
	local child = nil
	task.spawn(function()
		while humanoidRootPart and (attachment ~= nil and linearVelocity ~= nil and attachment.Parent == humanoidRootPart and linearVelocity.Parent == attachment and attachment.Name == "skill_stand_still" and v6:FindFirstChild("Cancel") == nil and linearVelocity:FindFirstChild("Cancel") == nil or child and child.Parent ~= nil) do
			local mousepos = Platform_Handler.mousepos()

			if v7._isactive then
				child = character:FindFirstChild(formatted)
				local position, _, _, target = RaycastHelper.MaximizeRayClient(
					humanoidRootPart.Position,
					mousepos,
					Config.TARGET_RANGE,
					true,
					5,
					15,
					3
				)
				local primaryPart

				if target ~= nil then
					primaryPart = target.PrimaryPart
				end

				local position2 = humanoidRootPart.Position

				if humanoidRootPart ~= nil and target ~= nil then
					position = target.HumanoidRootPart.Position
				end

				v2, v3, v4, v5 = v7:Update({
					startpos = position2,
					goalpos = position,
					target = target
				})
				v5 = primaryPart or v5
				alignOrientationWithAttachment.CFrame = Utility.SafeLookAt(
					humanoidRootPart.Position,
					position,
					alignOrientationWithAttachment.CFrame
				)
			end

			if child ~= nil then
				child.Position = mousepos
				child.bp.Position = mousepos
			end

			task.wait()
		end
	end)
	anim = humanoid.Animator:LoadAnimation(script.Init)
	anim:Play()
	task.wait(Config.ANIM_FREEZE_AT)

	if id == Reaptide.Id then
		anim:AdjustSpeed(0)
	end
end

function Reaptide.UnHold(player)
	if anim then
		anim:AdjustSpeed(1)

		if anim.TimePosition < Config.RELEASE_ANIM_SKIP_TO then
			anim.TimePosition = Config.RELEASE_ANIM_SKIP_TO
		end
	end

	local id = Reaptide.Id
	local v6, v7 = ManuelCancel.new(player, 1)
	v6:Connect(function()
		id = -1
		Reaptide.Cancel(player)
	end)
	local character = player.Character

	for _, v8 in pairs(v) do
		if v8.Name == "NR" then
			DebrisModule:AddItem(v8, 1)
		else
			v8:Destroy()
		end
	end

	table.clear(v)

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

			if v4 ~= nil and v5 ~= nil and v3 ~= nil and v2 ~= nil then
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
				game.Debris:AddItem(boolValue, Config.TRAVEL_LOCK_DURATION)
				local boolValue2 = Instance.new("BoolValue")
				boolValue2.Name = "NOMouvementlines"
				boolValue2.Parent = getvaluesfolder
				local typeName = typeof(v5)
				local position = v5

				if typeName == "Instance" then
					position = v5.Position
				end

				local v8 = (cFrame.Position - position).Magnitude / 10 * 0.3

				for i = 1, Config.TRAVEL_SEGMENTS do
					local lastTime = os.clock()

					if Reaptide.Id == id then
						local position2

						if typeName == "Instance" and v5 ~= nil and v5.Parent ~= nil then
							position2 = v5.Position
						else
							position2 = false
						end

						if position2 then
							position = position2
						elseif typeName ~= "Instance" then
							position = v5 or position
						end

						local resolve = ArcLanding.Resolve
						local v9 = {
							Character = character,
							From = cFrame.Position,
							Goal = position,
							Target = 0,
							Range = 0
						}
						local target

						if position2 then
							target = v5.Parent
						end

						v9.Target = target
						v9.Range = Config.TARGET_RANGE
						position = resolve(v9) or position
						local posInBeam = Utility.GetPosInBeam(i / Config.TRAVEL_SEGMENTS, v2, v3, v4, position)
						alignPosition.Position = posInBeam

						repeat
							task.wait()
						until Reaptide.Id ~= id or humanoidRootPart == nil or (humanoidRootPart.Position - posInBeam).Magnitude <= math.min(
							v8,
							1.15
						) or os.clock() - lastTime > Config.MAX_HANG_TIME / Config.TRAVEL_SEGMENTS
					else
						attachment:Destroy()
						boolValue:Destroy()
						boolValue2:Destroy()
						humanoidRootPart.AssemblyLinearVelocity = createVector(0, 0, 0)
						return
					end
				end

				humanoidRootPart.AssemblyLinearVelocity = createVector(0, 0, 0)
				humanoidRootPart.AssemblyAngularVelocity = createVector(0, 0, 0)

				if anim and anim.TimePosition < Config.LAND_ANIM_SKIP_TO then
					anim.TimePosition = Config.LAND_ANIM_SKIP_TO
				end

				if boolValue2 then
					boolValue2:Destroy()
				end

				if attachment ~= nil and attachment.Parent ~= nil then
					attachment:Destroy()
				end

				for _, v9 in ipairs(children) do
					v9:Destroy()
				end

				if boolValue ~= nil then
					boolValue:Destroy()
				end
			end
		end
	end

	v7()

	if id == Reaptide.Id then
		return character.PrimaryPart.CFrame
	end
end

function Reaptide.Cancel(player)
	if anim then
		anim:Stop()
		anim = nil
	end

	for _, v6 in pairs(v) do
		v6:Destroy()
	end

	table.clear(v)
	local _ = Reaptide.Id
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

return Reaptide