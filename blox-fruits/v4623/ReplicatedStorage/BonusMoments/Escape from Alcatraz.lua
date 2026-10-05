local createVector = vector.create
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
require(game.ReplicatedStorage.Controllers.BonusMomentsController.Types)
local DialogueController = require(game.ReplicatedStorage.DialogueController)
local CameraController = require(game.ReplicatedStorage.Controllers.CameraController)
local NPCInteractionConfig = require(game.ReplicatedStorage.NPCManager.NPCInteractionConfig)
local localPlayer = Players.LocalPlayer
local v = {
	Digger = {
		EscapeAnim = "rbxassetid://73223582386164",
		ConfrontLines = {
			"Almost there... just gotta dig this hole a little deeper and I'm gone!",
			"You gonna help me dig out of here?"
		}
	},
	Puncher = {
		EscapeAnim = "rbxassetid://75043506776220",
		ConfrontLines = {
			"This wall's about to give way... I knew all that training would pay off!",
			"Just... a few more... and I'm sure the wall will break down!",
			"Hey! You gonna help me get through, or...?"
		}
	},
	Raft = {
		EscapeAnim = "rbxassetid://127446133487377",
		ConfrontLines = {
			"Just gotta patch up these last planks and she'll float...",
			"You gonna grab a hammer and help, or...?"
		},
		HeldAsset = "Hammer"
	}
}

local function getRoot(instance)
	local primaryPart = instance.PrimaryPart or instance:FindFirstChild("HumanoidRootPart")

	if primaryPart and primaryPart:IsA("BasePart") then
		return primaryPart
	end

	return nil
end

local function playLoopedAnimation(model, escapeAnim: string)
	if escapeAnim == "" then
		return nil
	end

	local humanoid = model:FindFirstChildWhichIsA("Humanoid")

	if not humanoid then
		return nil
	end

	local v2 = humanoid:FindFirstChildWhichIsA("Animator")

	if not v2 then
		v2 = Instance.new("Animator")
		v2.Parent = humanoid
	end

	local animation = Instance.new("Animation")
	animation.AnimationId = escapeAnim
	local track = v2:LoadAnimation(animation)
	track.Looped = true
	track.Priority = Enum.AnimationPriority.Action
	track:Play(0)
	return track
end

local function attachHeldItem(model, heldAsset: string)
	local child = script:FindFirstChild(heldAsset)

	if not child then
		return nil
	end

	local rightHand = model:FindFirstChild("RightHand")

	if not (rightHand and rightHand:IsA("BasePart")) then
		return nil
	end

	local clone = child:Clone()
	clone.Parent = model

	if clone:IsA("BasePart") then
		clone.CanCollide = false
		clone.Massless = true
	end

	for _, part in clone:GetDescendants() do
		if not part:IsA("BasePart") then
			continue
		end

		part.CanCollide = false
		part.Massless = true
	end

	local motor6D = clone:FindFirstChildWhichIsA("Motor6D", true)

	if motor6D then
		motor6D.Part0 = rightHand

		if motor6D.Part1 ~= nil then
			return clone
		end

		local parent = motor6D.Parent

		if not (parent and parent:IsA("BasePart")) then
			parent = nil
		end

		motor6D.Part1 = parent
		return clone
	else
		local rigidConstraint = clone:FindFirstChildWhichIsA("RigidConstraint", true)

		if not rigidConstraint then
			return clone
		end

		if rigidConstraint.Attachment0 == nil then
			local grip = clone:FindFirstChild("Grip", true)

			if grip and grip:IsA("Attachment") then
				rigidConstraint.Attachment0 = grip
			end
		end

		local attachment = rightHand:FindFirstChild("RightGripAttachment")

		if not (attachment and attachment:IsA("Attachment")) then
			attachment = Instance.new("Attachment")
			attachment.Name = "RightGripAttachment"
			attachment.CFrame = CFrame.Angles(-1.5707963267948966, 0, 0)
			attachment.Parent = rightHand
		end

		rigidConstraint.Attachment1 = attachment
		return clone
	end
end

local function startDialogueCamera(model)
	local currentCamera = workspace.CurrentCamera
	local character = localPlayer.Character

	if not (currentCamera and character) then
		return {
			stop = function() end
		}
	end

	local v2 = CameraController.new()
	local head = model:FindFirstChild("Head")

	-- equivalent calls inferred from this helper; original call sites unknown
	local function npcLookPoint()
		if head and head:IsA("BasePart") then
			return head.Position
		end

		return model:GetPivot().Position
	end

	local function npcToPlayer()
		local character2 = localPlayer.Character
		local v3

		if character2 then
			v3 = character2:GetPivot().Position
		else
			v3 = model:GetPivot().Position
		end

		local v4 = (v3 - model:GetPivot().Position) * createVector(1, 0, 1)
		local magnitude = v4.Magnitude

		if magnitude < 0.05 then
			return model:GetPivot().LookVector * createVector(1, 0, 1), 0
		end

		return v4 / magnitude, magnitude
	end

	local v3 = (currentCamera.CFrame.Position - model:GetPivot().Position) * createVector(1, 0, 1)
	local unit

	if v3.Magnitude > 0.05 then
		unit = v3.Unit
	else
		unit = npcToPlayer()
	end

	local total = 0
	local v4 = 0

	local function dialogueGoal(p: number)
		local character2 = localPlayer.Character
		local v5 = npcLookPoint() -- equivalent call inferred; original call site unknown
		local v6

		if character2 then
			v6 = character2:GetPivot().Position
		else
			v6 = v5
		end

		local v7 = v6 + createVector(0, 1.5, 0)
		local vector2, v8 = npcToPlayer()
		local v9 = math.deg((math.atan2(vector2:Cross(unit).Y, (math.clamp(vector2:Dot(unit), -1, 1)))))
		local v10 = 0

		if math.abs(v9) < NPCInteractionConfig.DIALOGUE_CAMERA_ANGLE then
			if v4 == 0 then
				v4 = v9 >= 0 and 1 or -1
			end

			v10 = v4 * NPCInteractionConfig.DIALOGUE_CAMERA_ANGLE - v9
		elseif math.abs(v9) > NPCInteractionConfig.DIALOGUE_CAMERA_ANGLE + NPCInteractionConfig.DIALOGUE_CAMERA_SIDE_RESET then
			v4 = 0
		end

		local v11 = NPCInteractionConfig.DIALOGUE_CAMERA_SWING_SPEED * p
		total += math.clamp(v10 - total, -v11, v11)
		local vector3 = CFrame.fromAxisAngle(createVector(0, 1, 0), (math.rad(total))) * unit
		local v12 = NPCInteractionConfig.DIALOGUE_CAMERA_BASE_DISTANCE + v8 * NPCInteractionConfig.DIALOGUE_CAMERA_PULLBACK
		local v13 = v8 * vector3:Dot(vector2)
		local v14 = math.sqrt((math.max(v8 ^ 2 - v13 ^ 2, 0)))

		if v14 < NPCInteractionConfig.DIALOGUE_CAMERA_PLAYER_GAP then
			v12 = math.max(v12, v13 + math.sqrt(NPCInteractionConfig.DIALOGUE_CAMERA_PLAYER_GAP ^ 2 - v14 ^ 2))
		end

		local v15 = v5 + vector3 * v12 + Vector3.new(0, NPCInteractionConfig.DIALOGUE_CAMERA_HEIGHT, 0)
		return CFrame.lookAt(v15, v5:Lerp(v7, 0.5))
	end

	local flag = false

	-- equivalent calls inferred from this helper; original call sites unknown
	local function stop(flag2: boolean?)
		if flag then
			return
		end

		flag = true

		if flag2 then
			v2:FadeOut(0.25)
		else
			v2:Destroy()
		end
	end

	task.spawn(function()
		local v5 = 0.016666666666666666

		while not flag and model.Parent and localPlayer.Character do
			local _, v6 = npcToPlayer()

			if v6 > 34 then
				if not DialogueController.Active then
					break
				end

				DialogueController.close()
				break
			else
				v2.Animations:AnimateTo(dialogueGoal(v5), 1, NPCInteractionConfig.DIALOGUE_CAMERA_FREQUENCY)
				v5 = task.wait()
			end
		end

		stop(true) -- equivalent call inferred; original call site unknown
	end)
	return {
		stop = stop
	}
end

local function confront(object, p: string)
	local prisoner = object.MiscData.Prisoners[p]

	if not prisoner or prisoner.Confronted or (DialogueController.Active or DialogueController.Terminating) then
		return
	end

	local model = prisoner.Model

	if not (model and model.Parent) then
		return
	end

	prisoner.Confronted = true
	local v2 = v[p]
	local v3 = false
	local v4 = DialogueController.new()
	v4:setTitle("Escaped Prisoner")
	v4:addPage("Confront", function(object2)
		object2:noCancel()

		if v2 then
			for _, confrontLine in v2.ConfrontLines do
				object2:addText(confrontLine)
			end
		end

		object2:addOptionType("Chat", function(object3)
			object3:setText("Not this time!")
			object3:onSelected(function()
				v3 = true

				if prisoner.EscapeTrack then
					prisoner.EscapeTrack:Stop(0.2)
					prisoner.EscapeTrack = nil
				end

				if prisoner.HeldItem then
					prisoner.HeldItem:Destroy()
					prisoner.HeldItem = nil
				end

				task.spawn(function()
					object:InvokeServer("Provoke", p)
				end)
			end)
		end)
	end)
	local v5 = startDialogueCamera(model)
	DialogueController.start(v4:build())
	v5.stop(true)

	if not v3 then
		prisoner.Confronted = false
	end
end

return {
	DataName = script.Name,
	LoadWhenCompleted = true,
	OnLoad = function(maid)
		maid.MiscData.Prisoners = {}

		if maid.Completed then
			return
		end

		maid:GiveTask(RunService.Heartbeat:Connect(function()
			local character = localPlayer.Character
			local humanoidRootPart

			if character then
				humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
			end

			if not (humanoidRootPart and humanoidRootPart:IsA("BasePart")) or (DialogueController.Active or DialogueController.Terminating) then
				return
			end

			for k, prisoner in maid.MiscData.Prisoners do
				if prisoner.Confronted then
					continue
				end

				local model = prisoner.Model
				local primaryPart

				if model and model.Parent then
					primaryPart = model.PrimaryPart or model:FindFirstChild("HumanoidRootPart")

					if not (primaryPart and primaryPart:IsA("BasePart")) then
						primaryPart = nil
					end
				end

				if not (primaryPart and (primaryPart.Position - humanoidRootPart.Position).Magnitude <= 16) then
					continue
				end

				task.spawn(confront, maid, k)
				break
			end
		end))
	end,
	RemoteEvents = {
		PrisonerSpawned = function(p, value, model)
			if typeof(value) ~= "string" or typeof(model) ~= "Instance" or not model:IsA("Model") then
				return
			end

			local v2 = v[value]
			local escapeTrack

			if v2 then
				escapeTrack = playLoopedAnimation(model, v2.EscapeAnim)
			end

			local heldItem

			if v2 and v2.HeldAsset then
				heldItem = attachHeldItem(model, v2.HeldAsset)
			end

			p.MiscData.Prisoners[value] = {
				Model = model,
				EscapeTrack = escapeTrack,
				HeldItem = heldItem,
				Confronted = false
			}
		end,
		UpdateProgress = function(p, progress)
			p.Progress = progress
		end
	}
}