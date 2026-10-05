local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local VRService = game:GetService("VRService")
local parent = script.Parent
local Head = require(parent:WaitForChild("Character"):WaitForChild("Head"))
local Torso = require(parent:WaitForChild("Character"):WaitForChild("Torso"))
local Appendage = require(parent:WaitForChild("Character"):WaitForChild("Appendage"))
local FootPlanter = require(parent:WaitForChild("Character"):WaitForChild("FootPlanter"))
local EnigmaService = require(parent:WaitForChild("State"):WaitForChild("EnigmaService"))
local instance = EnigmaService.GetInstance()
local Settings = require(parent:WaitForChild("State"):WaitForChild("Settings"))
local instance2 = Settings.GetInstance()
local VRInputService = require(parent:WaitForChild("State"):WaitForChild("VRInputService"))
local instance3 = VRInputService.GetInstance()
local NexusAppendage = require(parent:WaitForChild("Packages"):WaitForChild("NexusAppendage"))
local updateInputs = parent:WaitForChild("UpdateInputs")
local appendage = NexusAppendage.Appendage
local Character = {}
Character.__index = Character

function Character.new(instance4)
	local object = setmetatable({
		CharacterModel = instance4,
		TweenComponents = instance4 ~= Players.LocalPlayer.Character,
		UseIKControl = instance2:GetSetting("Extra.TEMPORARY_UseIKControl")
	}, Character)
	local preventArmDisconnection

	if Players.LocalPlayer and Players.LocalPlayer.Character == instance4 then
		preventArmDisconnection = instance2:GetSetting("Appearance.LocalAllowArmDisconnection") == false or false
	else
		preventArmDisconnection = instance2:GetSetting("Appearance.NonLocalAllowArmDisconnection") == false or false
	end

	object.Humanoid = instance4:WaitForChild("Humanoid")
	object.CurrentWalkspeed = 0
	object.Humanoid.Running:Connect(function(p)
		object.CurrentWalkspeed = VRService.AvatarGestures and instance3:GetThumbstickPosition(Enum.KeyCode.Thumbstick1).Magnitude < 0.2 and 0 or p
	end)
	object.PreventArmDisconnection = preventArmDisconnection
	object:SetUpVRParts()
	object.AppearanceChangedConnection = nil
	object:SetUpAppearanceChanged()
	object.CurrentMotor6DTransforms = {}
	object.LastMotor6DTransforms = {}
	object.LastRefreshTime = tick()

	if Players.LocalPlayer and Players.LocalPlayer.Character == instance4 then
		task.spawn(function()
			while object.Humanoid.Health > 0 do
				local replicationCFrames = object.ReplicationCFrames
				local replicationTrackerData = object.ReplicationTrackerData

				if replicationCFrames and object.LastReplicationCFrames ~= replicationCFrames and object.LastReplicationTrackerData ~= replicationTrackerData then
					object.LastReplicationCFrames = replicationCFrames
					object.LastReplicationTrackerData = replicationTrackerData
					local v3 = {
						UpdateTime = tick(),
						CurrentWalkspeed = object.CurrentWalkspeed,
						LeftFootCFrame = replicationTrackerData and replicationTrackerData.LeftFoot,
						RightFootCFrame = replicationTrackerData and replicationTrackerData.RightFoot
					}

					if not VRService.AvatarGestures then
						v3.HeadCFrame = replicationCFrames.HeadCFrame
						v3.LeftHandCFrame = replicationCFrames.LeftHandCFrame
						v3.RightHandCFrame = replicationCFrames.RightHandCFrame
					end

					updateInputs:FireServer(v3)
				end

				task.wait(0.03333333333333333)
			end
		end)
	end

	return object
end

function Character:SetUpVRParts()
	local characterModel = self.CharacterModel
	local preventArmDisconnection = self.PreventArmDisconnection
	self.Parts = {
		Head = characterModel:WaitForChild("Head"),
		UpperTorso = characterModel:WaitForChild("UpperTorso"),
		LowerTorso = characterModel:WaitForChild("LowerTorso"),
		HumanoidRootPart = characterModel:WaitForChild("HumanoidRootPart"),
		RightUpperArm = characterModel:WaitForChild("RightUpperArm"),
		RightLowerArm = characterModel:WaitForChild("RightLowerArm"),
		RightHand = characterModel:WaitForChild("RightHand"),
		LeftUpperArm = characterModel:WaitForChild("LeftUpperArm"),
		LeftLowerArm = characterModel:WaitForChild("LeftLowerArm"),
		LeftHand = characterModel:WaitForChild("LeftHand"),
		RightUpperLeg = characterModel:WaitForChild("RightUpperLeg"),
		RightLowerLeg = characterModel:WaitForChild("RightLowerLeg"),
		RightFoot = characterModel:WaitForChild("RightFoot"),
		LeftUpperLeg = characterModel:WaitForChild("LeftUpperLeg"),
		LeftLowerLeg = characterModel:WaitForChild("LeftLowerLeg"),
		LeftFoot = characterModel:WaitForChild("LeftFoot")
	}
	self.Motors = {
		Neck = self.Parts.Head:WaitForChild("Neck"),
		Waist = self.Parts.UpperTorso:WaitForChild("Waist"),
		Root = self.Parts.LowerTorso:WaitForChild("Root"),
		RightShoulder = self.Parts.RightUpperArm:WaitForChild("RightShoulder"),
		RightElbow = self.Parts.RightLowerArm:WaitForChild("RightElbow"),
		RightWrist = self.Parts.RightHand:WaitForChild("RightWrist"),
		LeftShoulder = self.Parts.LeftUpperArm:WaitForChild("LeftShoulder"),
		LeftElbow = self.Parts.LeftLowerArm:WaitForChild("LeftElbow"),
		LeftWrist = self.Parts.LeftHand:WaitForChild("LeftWrist"),
		RightHip = self.Parts.RightUpperLeg:WaitForChild("RightHip"),
		RightKnee = self.Parts.RightLowerLeg:WaitForChild("RightKnee"),
		RightAnkle = self.Parts.RightFoot:WaitForChild("RightAnkle"),
		LeftHip = self.Parts.LeftUpperLeg:WaitForChild("LeftHip"),
		LeftKnee = self.Parts.LeftLowerLeg:WaitForChild("LeftKnee"),
		LeftAnkle = self.Parts.LeftFoot:WaitForChild("LeftAnkle")
	}
	self.Attachments = {
		Head = {
			NeckRigAttachment = self.Parts.Head:WaitForChild("NeckRigAttachment")
		},
		UpperTorso = {
			NeckRigAttachment = self.Parts.UpperTorso:WaitForChild("NeckRigAttachment"),
			LeftShoulderRigAttachment = self.Parts.UpperTorso:WaitForChild("LeftShoulderRigAttachment"),
			RightShoulderRigAttachment = self.Parts.UpperTorso:WaitForChild("RightShoulderRigAttachment"),
			WaistRigAttachment = self.Parts.UpperTorso:WaitForChild("WaistRigAttachment")
		},
		LowerTorso = {
			WaistRigAttachment = self.Parts.LowerTorso:WaitForChild("WaistRigAttachment"),
			LeftHipRigAttachment = self.Parts.LowerTorso:WaitForChild("LeftHipRigAttachment"),
			RightHipRigAttachment = self.Parts.LowerTorso:WaitForChild("RightHipRigAttachment"),
			RootRigAttachment = self.Parts.LowerTorso:WaitForChild("RootRigAttachment")
		},
		HumanoidRootPart = {
			RootRigAttachment = self.Parts.HumanoidRootPart:WaitForChild("RootRigAttachment")
		},
		RightUpperArm = {
			RightShoulderRigAttachment = self.Parts.RightUpperArm:WaitForChild("RightShoulderRigAttachment"),
			RightElbowRigAttachment = self.Parts.RightUpperArm:WaitForChild("RightElbowRigAttachment")
		},
		RightLowerArm = {
			RightElbowRigAttachment = self.Parts.RightLowerArm:WaitForChild("RightElbowRigAttachment"),
			RightWristRigAttachment = self.Parts.RightLowerArm:WaitForChild("RightWristRigAttachment")
		},
		RightHand = {
			RightWristRigAttachment = self.Parts.RightHand:WaitForChild("RightWristRigAttachment")
		},
		LeftUpperArm = {
			LeftShoulderRigAttachment = self.Parts.LeftUpperArm:WaitForChild("LeftShoulderRigAttachment"),
			LeftElbowRigAttachment = self.Parts.LeftUpperArm:WaitForChild("LeftElbowRigAttachment")
		},
		LeftLowerArm = {
			LeftElbowRigAttachment = self.Parts.LeftLowerArm:WaitForChild("LeftElbowRigAttachment"),
			LeftWristRigAttachment = self.Parts.LeftLowerArm:WaitForChild("LeftWristRigAttachment")
		},
		LeftHand = {
			LeftWristRigAttachment = self.Parts.LeftHand:WaitForChild("LeftWristRigAttachment")
		},
		RightUpperLeg = {
			RightHipRigAttachment = self.Parts.RightUpperLeg:WaitForChild("RightHipRigAttachment"),
			RightKneeRigAttachment = self.Parts.RightUpperLeg:WaitForChild("RightKneeRigAttachment")
		},
		RightLowerLeg = {
			RightKneeRigAttachment = self.Parts.RightLowerLeg:WaitForChild("RightKneeRigAttachment"),
			RightAnkleRigAttachment = self.Parts.RightLowerLeg:WaitForChild("RightAnkleRigAttachment")
		},
		RightFoot = {
			RightAnkleRigAttachment = self.Parts.RightFoot:WaitForChild("RightAnkleRigAttachment"),
			RightFootAttachment = self.Parts.RightFoot:FindFirstChild("RightFootAttachment")
		},
		LeftUpperLeg = {
			LeftHipRigAttachment = self.Parts.LeftUpperLeg:WaitForChild("LeftHipRigAttachment"),
			LeftKneeRigAttachment = self.Parts.LeftUpperLeg:WaitForChild("LeftKneeRigAttachment")
		},
		LeftLowerLeg = {
			LeftKneeRigAttachment = self.Parts.LeftLowerLeg:WaitForChild("LeftKneeRigAttachment"),
			LeftAnkleRigAttachment = self.Parts.LeftLowerLeg:WaitForChild("LeftAnkleRigAttachment")
		},
		LeftFoot = {
			LeftAnkleRigAttachment = self.Parts.LeftFoot:WaitForChild("LeftAnkleRigAttachment"),
			LeftFootAttachment = self.Parts.LeftFoot:FindFirstChild("LeftFootAttachment")
		}
	}

	if not self.Attachments.RightFoot.RightFootAttachment then
		local attachment = Instance.new("Attachment")
		attachment.Position = Vector3.new(0, -self.Parts.RightFoot.Size.Y / 2, 0)
		attachment.Name = "RightFootAttachment"
		local vector3Value = Instance.new("Vector3Value")
		vector3Value.Name = "OriginalPosition"
		vector3Value.Value = attachment.Position
		vector3Value.Parent = attachment
		attachment.Parent = self.Parts.RightFoot
		self.Attachments.RightFoot.RightFootAttachment = attachment
	end

	if not self.Attachments.LeftFoot.LeftFootAttachment then
		local attachment = Instance.new("Attachment")
		attachment.Position = Vector3.new(0, -self.Parts.LeftFoot.Size.Y / 2, 0)
		attachment.Name = "LeftFootAttachment"
		local vector3Value = Instance.new("Vector3Value")
		vector3Value.Name = "OriginalPosition"
		vector3Value.Value = attachment.Position
		vector3Value.Parent = attachment
		attachment.Parent = self.Parts.LeftFoot
		self.Attachments.LeftFoot.LeftFootAttachment = attachment
	end

	self.Head = Head.new(self.Parts.Head)
	self.Torso = Torso.new(self.Parts.LowerTorso, self.Parts.UpperTorso)

	if self.UseIKControl then
		self.LeftArm = appendage.FromPreset(
			"LeftArm",
			characterModel,
			not preventArmDisconnection,
			self.TweenComponents and 0.1 or 0
		)
		self.RightArm = appendage.FromPreset(
			"RightArm",
			characterModel,
			not preventArmDisconnection,
			self.TweenComponents and 0.1 or 0
		)
		self.LeftLeg = appendage.FromPreset("LeftLeg", characterModel, false, self.TweenComponents and 0.1 or 0)
		self.RightLeg = appendage.FromPreset("RightLeg", characterModel, false, self.TweenComponents and 0.1 or 0)
	else
		local leftArm = Appendage.new(
			characterModel:WaitForChild("LeftUpperArm"),
			characterModel:WaitForChild("LeftLowerArm"),
			characterModel:WaitForChild("LeftHand"),
			"LeftShoulderRigAttachment",
			"LeftElbowRigAttachment",
			"LeftWristRigAttachment",
			"LeftGripAttachment",
			preventArmDisconnection
		)
		local rightArm = Appendage.new(
			characterModel:WaitForChild("RightUpperArm"),
			characterModel:WaitForChild("RightLowerArm"),
			characterModel:WaitForChild("RightHand"),
			"RightShoulderRigAttachment",
			"RightElbowRigAttachment",
			"RightWristRigAttachment",
			"RightGripAttachment",
			preventArmDisconnection
		)
		local leftLeg = Appendage.new(
			characterModel:WaitForChild("LeftUpperLeg"),
			characterModel:WaitForChild("LeftLowerLeg"),
			characterModel:WaitForChild("LeftFoot"),
			"LeftHipRigAttachment",
			"LeftKneeRigAttachment",
			"LeftAnkleRigAttachment",
			"LeftFootAttachment",
			true
		)
		leftLeg.InvertBendDirection = true
		local rightLeg = Appendage.new(
			characterModel:WaitForChild("RightUpperLeg"),
			characterModel:WaitForChild("RightLowerLeg"),
			characterModel:WaitForChild("RightFoot"),
			"RightHipRigAttachment",
			"RightKneeRigAttachment",
			"RightAnkleRigAttachment",
			"RightFootAttachment",
			true
		)
		rightLeg.InvertBendDirection = true
		self.LeftArm = leftArm
		self.RightArm = rightArm
		self.LeftLeg = leftLeg
		self.RightLeg = rightLeg
	end

	self.FootPlanter = FootPlanter:CreateSolver(
		characterModel:WaitForChild("LowerTorso"),
		self.Humanoid:FindFirstChild("BodyHeightScale")
	)
end

function Character:SetUpAppearanceChanged()
	local humanoid = self.CharacterModel:WaitForChild("Humanoid")

	if self.AppearanceChangedConnection then
		self.AppearanceChangedConnection:Disconnect()
		self.AppearanceChangedConnection = nil
	end

	self.AppearanceChangedConnection = humanoid.ChildAdded:Connect(function(humanoidDescription)
		if humanoidDescription:IsA("HumanoidDescription") then
			self:SetUpVRParts()
		end
	end)
end

function Character.GetHumanoidScale(instance4, childName: string)
	local child = instance4.Humanoid:FindFirstChild(childName)

	if child then
		return child.Value
	end

	if childName == "BodyTypeScale" then
		return 0
	end

	return 1
end

function Character:GetHumanoidSeatPart()
	if not self.Humanoid.Sit then
		return nil
	end

	if self.Humanoid.SeatPart then
		return self.Humanoid.SeatPart
	end

	for _, instance5 in self.Parts.HumanoidRootPart:GetConnectedParts() do
		if instance5:IsA("Seat") or instance5:IsA("VehicleSeat") then
			return instance5
		end
	end

	return nil
end

function Character:SetCFrameProperty(p2, p3: string, p4)
	if self.TweenComponents and p3 ~= "Transform" then
		TweenService:Create(p2, TweenInfo.new(0.03333333333333333, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			[p3] = p4
		}):Play()
	else
		p2[p3] = p4
	end

	if p3 == "Transform" then
		self.CurrentMotor6DTransforms[p2] = p4
	end
end

function Character:SetTransform(p: string, p2: string, p3: string, p4: string, cframe: CFrame, cframe2: CFrame)
	self:SetCFrameProperty(
		self.Motors[p],
		"Transform",
		(cframe * self.Attachments[p3][p2].CFrame):Inverse() * (cframe2 * self.Attachments[p4][p2].CFrame)
	)
end

function Character.RefreshCharacter(data)
	if data.TweenComponents then
		local v = math.min((tick() - data.LastRefreshTime) / 0.03333333333333333, 1)

		for k, currentMotor6DTransform in data.CurrentMotor6DTransforms do
			local lastMotor6DTransform = data.LastMotor6DTransforms[k]

			if lastMotor6DTransform then
				k.Transform = lastMotor6DTransform:Lerp(currentMotor6DTransform, v)
			else
				k.Transform = currentMotor6DTransform
			end
		end
	else
		for k, currentMotor6DTransform in data.CurrentMotor6DTransforms do
			k.Transform = currentMotor6DTransform
		end
	end
end

function Character:UpdateFromInputs(cframe: CFrame?, cframe2: CFrame?, cframe3: CFrame?, p: number?, p2)
	if self.Humanoid.Health <= 0 then
		return
	end

	if self:GetHumanoidSeatPart() then
		self:UpdateFromInputsSeated(cframe, cframe2, cframe3)
		return
	end

	for k, _ in self.CurrentMotor6DTransforms do
		self.LastMotor6DTransforms[k] = k.Transform
	end

	self.LastRefreshTime = tick()
	local v = cframe or self.Parts.Head.CFrame * self.Head:GetEyesOffset()
	local headCFrame = self.Head:GetHeadCFrame(v)
	local neckCFrame = self.Head:GetNeckCFrame(v)
	local torsoCFrames, v2 = self.Torso:GetTorsoCFrames(neckCFrame)
	local appendageJointCFrames = self.Torso:GetAppendageJointCFrames(torsoCFrames, v2)
	local v3 = Players.LocalPlayer and Players.LocalPlayer.Character == self.CharacterModel
	local feetCFrames, v4 = self.FootPlanter:GetFeetCFrames()
	local v5 = false
	local v6 = false
	local leftFoot

	if p2 and p2.LeftFoot then
		leftFoot = p2.LeftFoot
		v5 = true
	else
		leftFoot = feetCFrames * CFrame.Angles(0, 3.141592653589793, 0)
	end

	local rightFoot

	if p2 and p2.RightFoot then
		rightFoot = p2.RightFoot
		v6 = true
	else
		rightFoot = v4 * CFrame.Angles(0, 3.141592653589793, 0)
	end

	if v3 then
		local cFrames = instance:GetCFrames(self)

		if cFrames.LeftFoot then
			leftFoot = cFrames.LeftFoot
			v5 = true
		end

		if cFrames.RightFoot then
			rightFoot = cFrames.RightFoot
			v6 = true
		end

		self.ReplicationTrackerData = {
			LeftFoot = cFrames.LeftFoot,
			RightFoot = cFrames.RightFoot
		}
	end

	local avatarGestures = VRService.AvatarGestures
	local v7 = (p or self.CurrentWalkspeed) > 0.1
	local v8 = torsoCFrames * self.Attachments.LowerTorso.RootRigAttachment.CFrame * self.Attachments.HumanoidRootPart.RootRigAttachment.CFrame:Inverse()
	local v9 = self.Parts.HumanoidRootPart.CFrame.Y - v8.Y
	local v10 = CFrame.new(v8.Position) * CFrame.Angles(
		0,
		math.atan2(v8.LookVector.X, v8.LookVector.Z) + 3.141592653589793,
		0
	)

	if not avatarGestures then
		self:SetCFrameProperty(self.Parts.HumanoidRootPart, "CFrame", CFrame.new(0, v9, 0) * v10)
		self:SetCFrameProperty(
			self.Motors.Root,
			"Transform",
			CFrame.new(0, -v9, 0) * (v10 * self.Attachments.HumanoidRootPart.RootRigAttachment.CFrame):Inverse() * torsoCFrames * self.Attachments.LowerTorso.RootRigAttachment.CFrame
		)
		self:SetTransform("Neck", "NeckRigAttachment", "UpperTorso", "Head", v2, headCFrame)
		self:SetTransform("Waist", "WaistRigAttachment", "LowerTorso", "UpperTorso", torsoCFrames, v2)
	end

	if self.UseIKControl then
		if not avatarGestures and cframe2 and cframe3 then
			self.LeftArm:MoveToWorld(cframe2)
			self.RightArm:MoveToWorld(cframe3)
		end

		if v7 or avatarGestures and not v5 then
			self.LeftLeg:Disable()
		else
			self.LeftLeg:MoveToWorld(leftFoot)
			self.LeftLeg:Enable()
		end

		if v7 or avatarGestures and not v6 then
			self.RightLeg:Disable()
		else
			self.RightLeg:MoveToWorld(rightFoot)
			self.RightLeg:Enable()
		end
	else
		if not avatarGestures then
			local appendageCFrames, v11, v12 = self.LeftArm:GetAppendageCFrames(
				appendageJointCFrames.LeftShoulder,
				cframe2
			)
			local appendageCFrames2, v13, v14 = self.RightArm:GetAppendageCFrames(
				appendageJointCFrames.RightShoulder,
				cframe3
			)
			self:SetTransform(
				"RightShoulder",
				"RightShoulderRigAttachment",
				"UpperTorso",
				"RightUpperArm",
				v2,
				appendageCFrames2
			)
			self:SetTransform(
				"RightElbow",
				"RightElbowRigAttachment",
				"RightUpperArm",
				"RightLowerArm",
				appendageCFrames2,
				v13
			)
			self:SetTransform("RightWrist", "RightWristRigAttachment", "RightLowerArm", "RightHand", v13, v14)
			self:SetTransform(
				"LeftShoulder",
				"LeftShoulderRigAttachment",
				"UpperTorso",
				"LeftUpperArm",
				v2,
				appendageCFrames
			)
			self:SetTransform(
				"LeftElbow",
				"LeftElbowRigAttachment",
				"LeftUpperArm",
				"LeftLowerArm",
				appendageCFrames,
				v11
			)
			self:SetTransform("LeftWrist", "LeftWristRigAttachment", "LeftLowerArm", "LeftHand", v11, v12)
		end

		if v7 or avatarGestures and not v5 then
			self.CurrentMotor6DTransforms[self.Motors.LeftHip] = nil
			self.CurrentMotor6DTransforms[self.Motors.LeftKnee] = nil
			self.CurrentMotor6DTransforms[self.Motors.LeftAnkle] = nil
		else
			local appendageCFrames, v11, v12 = self.LeftLeg:GetAppendageCFrames(appendageJointCFrames.LeftHip, leftFoot)
			self:SetTransform(
				"LeftHip",
				"LeftHipRigAttachment",
				"LowerTorso",
				"LeftUpperLeg",
				torsoCFrames,
				appendageCFrames
			)
			self:SetTransform(
				"LeftKnee",
				"LeftKneeRigAttachment",
				"LeftUpperLeg",
				"LeftLowerLeg",
				appendageCFrames,
				v11
			)
			self:SetTransform("LeftAnkle", "LeftAnkleRigAttachment", "LeftLowerLeg", "LeftFoot", v11, v12)
		end

		if v7 or avatarGestures and not v6 then
			self.CurrentMotor6DTransforms[self.Motors.RightHip] = nil
			self.CurrentMotor6DTransforms[self.Motors.RightKnee] = nil
			self.CurrentMotor6DTransforms[self.Motors.RightAnkle] = nil
		else
			local appendageCFrames, v11, v12 = self.RightLeg:GetAppendageCFrames(
				appendageJointCFrames.RightHip,
				rightFoot
			)
			self:SetTransform(
				"RightHip",
				"RightHipRigAttachment",
				"LowerTorso",
				"RightUpperLeg",
				torsoCFrames,
				appendageCFrames
			)
			self:SetTransform(
				"RightKnee",
				"RightKneeRigAttachment",
				"RightUpperLeg",
				"RightLowerLeg",
				appendageCFrames,
				v11
			)
			self:SetTransform("RightAnkle", "RightAnkleRigAttachment", "RightLowerLeg", "RightFoot", v11, v12)
		end
	end

	if v3 then
		self.ReplicationCFrames = {
			HeadCFrame = cframe,
			LeftHandCFrame = cframe2,
			RightHandCFrame = cframe3
		}
	end
end

function Character:UpdateFromInputsSeated(cframe: CFrame?, cframe2: CFrame?, cframe3: CFrame?)
	if self.Humanoid.Health <= 0 then
		return
	end

	if VRService.AvatarGestures or not (cframe and cframe2 and cframe3) then
		return
	end

	local headCFrame = self.Head:GetHeadCFrame(cframe)
	local neckCFrame = self.Head:GetNeckCFrame(cframe, 0)
	local torsoCFrames, v = self.Torso:GetTorsoCFrames(neckCFrame)
	local appendageJointCFrames = self.Torso:GetAppendageJointCFrames(torsoCFrames, v)
	local eyesOffset = self.Head:GetEyesOffset()
	local cframe4 = CFrame.new(0, (CFrame.new(0, eyesOffset.Y, 0) * (cframe * eyesOffset:Inverse())).Y, 0)
	self:SetCFrameProperty(self.Motors.Root, "Transform", cframe4 * CFrame.new(0, -torsoCFrames.Y, 0) * torsoCFrames)
	self:SetTransform("Neck", "NeckRigAttachment", "UpperTorso", "Head", v, headCFrame)
	self:SetTransform("Waist", "WaistRigAttachment", "LowerTorso", "UpperTorso", torsoCFrames, v)

	if self.UseIKControl then
		local v2 = self.Parts.Head.CFrame * eyesOffset
		self.LeftArm:MoveToWorld(v2 * cframe:Inverse() * cframe2)
		self.RightArm:MoveToWorld(v2 * cframe:Inverse() * cframe3)
		self.LeftLeg:Disable()
		self.RightLeg:Disable()
	else
		local appendageCFrames, v2, v3 = self.LeftArm:GetAppendageCFrames(appendageJointCFrames.LeftShoulder, cframe2)
		local appendageCFrames2, v4, v5 = self.RightArm:GetAppendageCFrames(
			appendageJointCFrames.RightShoulder,
			cframe3
		)
		self:SetTransform(
			"RightShoulder",
			"RightShoulderRigAttachment",
			"UpperTorso",
			"RightUpperArm",
			v,
			appendageCFrames2
		)
		self:SetTransform(
			"RightElbow",
			"RightElbowRigAttachment",
			"RightUpperArm",
			"RightLowerArm",
			appendageCFrames2,
			v4
		)
		self:SetTransform("RightWrist", "RightWristRigAttachment", "RightLowerArm", "RightHand", v4, v5)
		self:SetTransform(
			"LeftShoulder",
			"LeftShoulderRigAttachment",
			"UpperTorso",
			"LeftUpperArm",
			v,
			appendageCFrames
		)
		self:SetTransform("LeftElbow", "LeftElbowRigAttachment", "LeftUpperArm", "LeftLowerArm", appendageCFrames, v2)
		self:SetTransform("LeftWrist", "LeftWristRigAttachment", "LeftLowerArm", "LeftHand", v2, v3)
	end

	self.CurrentMotor6DTransforms[self.Motors.RightHip] = nil
	self.CurrentMotor6DTransforms[self.Motors.LeftHip] = nil
	self.CurrentMotor6DTransforms[self.Motors.RightKnee] = nil
	self.CurrentMotor6DTransforms[self.Motors.LeftKnee] = nil
	self.CurrentMotor6DTransforms[self.Motors.RightAnkle] = nil
	self.CurrentMotor6DTransforms[self.Motors.LeftAnkle] = nil

	if Players.LocalPlayer and Players.LocalPlayer.Character == self.CharacterModel then
		self.ReplicationCFrames = {
			HeadCFrame = cframe,
			LeftHandCFrame = cframe2,
			RightHandCFrame = cframe3
		}
	end
end

return Character