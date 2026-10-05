local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local CameraController = require(game.ReplicatedStorage.Controllers.CameraController)
local Effect = require(game.ReplicatedStorage.Effect)
local PodiumClient = require(game.ReplicatedStorage.ClientComponents.PodiumClient)
local Sound = require(game.ReplicatedStorage.Util.Sound)
require(game.ReplicatedStorage.Controllers.BonusMomentsController.Types)
local localPlayer = Players.LocalPlayer
local frozen = table.freeze({
	"ColosseumBonusMoments.BF_Statue_Incorrect_Hit_Type_01",
	"ColosseumBonusMoments.BF_Statue_Incorrect_Hit_Type_02",
	"ColosseumBonusMoments.BF_Statue_Incorrect_Hit_Type_03"
})
local frozen2 = table.freeze({
	"ColosseumBonusMoments.BF_Statue_Activate_Move_Into_Pose_01",
	"ColosseumBonusMoments.BF_Statue_Activate_Move_Into_Pose_02",
	"ColosseumBonusMoments.BF_Statue_Activate_Move_Into_Pose_03"
})
local frozen3 = table.freeze({
	"ColosseumBonusMoments.BF_Statue_Eyes_Glow_01",
	"ColosseumBonusMoments.BF_Statue_Eyes_Glow_02",
	"ColosseumBonusMoments.BF_Statue_Eyes_Glow_03"
})
local v = {
	{
		Attachment = "Eye1",
		Glow = "Glow1"
	},
	{
		Attachment = "Eye2",
		Glow = "Glow2"
	}
}
local v2 = {
	Melee = Color3.fromRGB(255, 60, 60),
	Sword = Color3.fromRGB(80, 255, 120),
	Gun = Color3.fromHex("ffd941"),
	Fruit = Color3.fromRGB(200, 90, 255),
	["Demon Fruit"] = Color3.fromRGB(200, 90, 255)
}
local v3 = CFrame.new(-1331.92, 29.568, -2761.583) * CFrame.Angles(0, 1.6406094968746698, 0)
local v4 = CFrame.new(-1390.426, 29.726, -2900.766) * CFrame.Angles(0, 2.4085543677521746, 0)
local v5 = CFrame.new(-1364.856, 27.162, -2927.679) * CFrame.Angles(0, -0.7330382858376184, 0)
local v6 = CFrame.new(-1293.242, 26.85, -2827.787) * CFrame.Angles(0, -1.413716694115407, 0)
local completed = false
local object = setmetatable({}, {
	__mode = "k"
})
local object2 = setmetatable({}, {
	__mode = "k"
})

-- equivalent calls inferred from this helper; original call sites unknown
local function playRandom(list, p)
	Sound:Play(list[math.random(1, #list)], p)
end

local function podiumPosition(object3, instance)
	local model

	if object3 ~= nil then
		model = object3:GetModel()
	end

	if model ~= nil then
		return model:GetPivot().Position
	end

	if instance:IsA("BasePart") then
		return instance.Position
	end

	if instance:IsA("Model") then
		return instance:GetPivot().Position
	end

	return nil
end

local function poseTime(p)
	local track

	if p == nil then
		track = nil
	else
		track = p.Track
	end

	if typeof(track) ~= "Instance" then
		return 1.5
	end

	local success, result = pcall(function()
		return track:GetTimeOfKeyframe("End")
	end)

	if success and typeof(result) == "number" and result > 0 then
		return result
	end

	if track.Length > 0 then
		return track.Length
	end

	return 1.5
end

local function statueHead(instance)
	for _, v7 in v do
		local attachment = instance:FindFirstChild(v7.Attachment, true)

		if attachment ~= nil and attachment:IsA("Attachment") then
			return attachment
		end
	end

	local head = instance:FindFirstChild("head", true)

	if head == nil or not head:IsA("Attachment") then
		return nil
	end

	return head
end

-- equivalent calls inferred from this helper; original call sites unknown
local function startStatueAura(p)
	if object2[p] ~= nil then
		return
	end

	local v7 = statueHead(p)

	if v7 == nil then
		return
	end

	local v8 = Sound:Play("ColosseumBonusMoments.BF_Statue_Activated_Loop_Aura_01", v7)
	v8.Looped = true
	object2[p] = v8
end

-- equivalent calls inferred from this helper; original call sites unknown
local function stopStatueAura(p)
	local v7 = object2[p]

	if v7 ~= nil then
		object2[p] = nil
		Sound:Kill(v7)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function stopAllStatueAuras()
	for k, v7 in object2 do
		object2[k] = nil
		Sound:Kill(v7)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function freezeAll()
	for _, v7 in PodiumClient:GetAll() do
		v7:PlayFrozen()
	end
end

local function setEyes(model, color: Color3?)
	if object[model] ~= nil then
		return
	end

	local assets = ReplicatedStorage:FindFirstChild("Assets")
	local glowingEyes

	if assets ~= nil then
		glowingEyes = assets:FindFirstChild("GlowingEyes")
	end

	if glowingEyes == nil then
		return
	end

	local clones = {}

	for _, v7 in v do
		local attachment = model:FindFirstChild(v7.Attachment, true)
		local folder = glowingEyes:FindFirstChild(v7.Glow)

		if not (attachment ~= nil and attachment:IsA("Attachment") and folder ~= nil) then
			continue
		end

		for _, descendant in folder:GetDescendants() do
			if descendant:IsA("ParticleEmitter") then
				local clone = descendant:Clone()

				if color ~= nil then
					clone.Color = ColorSequence.new(color)
				end

				clone.Enabled = true
				clone.Parent = attachment
				table.insert(clones, clone)
			elseif descendant:IsA("PointLight") then
				local clone = descendant:Clone()

				if color ~= nil then
					clone.Color = color
				end

				clone.Parent = attachment
				table.insert(clones, clone)
			end
		end
	end

	if #clones > 0 then
		object[model] = clones
		playRandom(frozen3, statueHead(model) or model:GetPivot().Position) -- equivalent call inferred; original call site unknown
	end
end

local function clearEyes(model)
	stopStatueAura(model) -- equivalent call inferred; original call site unknown
	local v7 = object[model]

	if v7 == nil then
		return
	end

	object[model] = nil

	for _, instance in v7 do
		if instance:IsA("ParticleEmitter") then
			instance.Enabled = false
		elseif instance:IsA("PointLight") then
			TweenService:Create(instance, TweenInfo.new(0.4), {
				Brightness = 0
			}):Play()
		end
	end

	task.delay(1.4, function()
		for _, v8 in v7 do
			v8:Destroy()
		end
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function playEyes(object3, value: string)
	local model = object3:GetModel()

	if model ~= nil then
		setEyes(model, v2[value])
	end
end

local function playSpark(boundingBox: CFrame)
	local spark = script:FindFirstChild("Spark")

	if spark == nil or not spark:IsA("BasePart") then
		return
	end

	local clone = spark:Clone()
	clone.CFrame = boundingBox
	clone.Parent = workspace

	for _, emitter in clone:GetDescendants() do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		local emitCount = emitter:GetAttribute("EmitCount")
		emitter:Emit(typeof(emitCount) ~= "number" and 15 or emitCount)
	end

	task.delay(3, function()
		clone:Destroy()
	end)
end

local function linearMove(object3, cframe: CFrame, cframe2: CFrame, p: number, stopped)
	local total = 0

	while total < p do
		if stopped ~= nil and stopped() then
			return
		end

		object3:SetCFrame(cframe:Lerp(cframe2, total / p))
		total += RunService.RenderStepped:Wait()
	end

	object3:SetCFrame(cframe2)
end

local function setAura(model, flag: boolean, color: Color3?)
	local auraRoot = model:FindFirstChild("AuraRoot")

	if auraRoot == nil or not auraRoot:IsA("Model") then
		return
	end

	Effect.new("Auras.PurpleAura"):play({
		Stage = flag and 1 or 0,
		Character = auraRoot,
		Player = localPlayer
	})

	if flag then
		task.spawn(function()
			local humanoidRootPart = auraRoot:FindFirstChild("HumanoidRootPart")
			local purple_Aura_FX

			if humanoidRootPart ~= nil then
				purple_Aura_FX = humanoidRootPart:WaitForChild("Purple_Aura_FX", 2)
			end

			if purple_Aura_FX ~= nil and color ~= nil then
				for _, emitter in purple_Aura_FX:GetDescendants() do
					if emitter:IsA("ParticleEmitter") then
						emitter.Color = ColorSequence.new(color)
					end
				end
			end

			auraRoot:ScaleTo(3)
		end)
	end
end

local function collectStatues()
	local result = {}

	for _, v7 in PodiumClient:GetAll() do
		local model = v7:GetModel()
		local podiumType = v7.PodiumType

		if model ~= nil and podiumType ~= nil then
			table.insert(result, {
				Model = model,
				Color = v2[podiumType]
			})
		end
	end

	return result
end

local function playFinale()
	local v7 = collectStatues()

	for _, v8 in v7 do
		setAura(v8.Model, true, v8.Color)
		setEyes(v8.Model, v8.Color)
	end

	local v8 = false
	local character = localPlayer.Character
	local humanoid

	if character ~= nil then
		humanoid = character:FindFirstChildWhichIsA("Humanoid")
	end

	local diedConnection

	if humanoid ~= nil then
		diedConnection = humanoid.Died:Connect(function()
			v8 = true
		end)
	end

	local function stopped()
		return v8
	end

	local currentCamera = workspace.CurrentCamera
	local v9

	if currentCamera ~= nil then
		v9 = CameraController.new(currentCamera, 1, 0.4)
	end

	if v9 == nil then
		task.wait(10)
	else
		v9:SetCFrame(v3)
		linearMove(v9, v3, v4, 5, stopped)

		if not v8 then
			linearMove(v9, v5, v6, 5, stopped)
		end
	end

	if diedConnection ~= nil then
		diedConnection:Disconnect()
	end

	for _, v10 in v7 do
		local auraRoot = v10.Model:FindFirstChild("AuraRoot")

		if auraRoot ~= nil and auraRoot:IsA("Model") then
			Effect.new("Auras.PurpleAura"):play({
				Stage = 0,
				Character = auraRoot,
				Player = localPlayer
			})
		end

		clearEyes(v10.Model)
	end

	if v9 ~= nil then
		v9:FadeOut(0.6)
	end
end

local LegendaryCreatorStatues = {}
LegendaryCreatorStatues.LoadWhenCompleted = true

function LegendaryCreatorStatues.OnLoad(p)
	completed = p.Completed
	p.Trove:Add(function()
		stopAllStatueAuras() -- equivalent call inferred; original call site unknown

		if not completed then
			freezeAll() -- equivalent call inferred; original call site unknown
		end
	end)
end

function LegendaryCreatorStatues.OnComplete(_, p)
	if not p then
		return
	end

	completed = true
end

LegendaryCreatorStatues.RemoteEvents = {
	PodiumHit = function(_, instance, value)
		if typeof(instance) == "Instance" and typeof(value) == "string" then
			local v7 = PodiumClient:FromInstance(instance)

			if v7 ~= nil then
				v7:Nudge(0.13962634015954636)
				playEyes(v7, value) -- equivalent call inferred; original call site unknown
				local model = v7:GetModel()

				if model ~= nil then
					playSpark(model:GetBoundingBox())
				end
			end
		end
	end,
	PodiumLit = function(_, instance)
		if typeof(instance) ~= "Instance" then
			return
		end

		local v7 = PodiumClient:FromInstance(instance)

		if v7 ~= nil then
			v7:Free()
		end

		playRandom(frozen2, podiumPosition(v7, instance)) -- equivalent call inferred; original call site unknown
		local model

		if v7 == nil then
			model = nil
		else
			model = v7:GetModel()
		end

		if model ~= nil then
			task.delay(poseTime(v7), function()
				startStatueAura(model) -- equivalent call inferred; original call site unknown
			end)
		end
	end,
	PodiumWrong = function(_, instance)
		if typeof(instance) ~= "Instance" then
			return
		end

		local v7 = PodiumClient:FromInstance(instance)

		if v7 ~= nil then
			v7:Nudge(0.05235987755982989)
		end

		playRandom(frozen, podiumPosition(v7, instance)) -- equivalent call inferred; original call site unknown
	end,
	AllLit = function(_)
		completed = true
		Sound:Play("ColosseumBonusMoments.BF_Statues_All_Activated_Cutscene_01")
		task.spawn(playFinale)
	end
}
return LegendaryCreatorStatues