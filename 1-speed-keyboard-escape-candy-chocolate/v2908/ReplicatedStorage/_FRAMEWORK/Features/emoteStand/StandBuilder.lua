local ContentProvider = game:GetService("ContentProvider")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Dummy = require(script.Parent.Dummy)
local LoggerManager = require(ReplicatedStorage._FRAMEWORK.Libraries.LoggerManager)
local RelicsBridge = require(script.Parent.RelicsBridge)
require(script.Parent.Types)
local logger = LoggerManager.createLogger("emoteStand", {
	feature = script:GetFullName()
})
local StandBuilder = {}
local v = {}
local v2 = {}

local function preloadAnimation(animation)
	if v2[animation] then
		return
	end

	if v[animation] then
		while not v2[animation] do
			task.wait()
		end
	else
		v[animation] = true
		pcall(function()
			ContentProvider:PreloadAsync({ animation })
		end)
		v2[animation] = true
		v[animation] = nil
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function halfWorldHeight(cFrame: CFrame, size: Vector3)
	local rotation = cFrame.Rotation
	return (math.abs(rotation.XVector.Y) * size.X + math.abs(rotation.YVector.Y) * size.Y + math.abs(rotation.ZVector.Y) * size.Z) * 0.5
end

local function getRigBottomY(folder)
	local v3 = nil

	for _, part in folder:GetDescendants() do
		if not part:IsA("BasePart") or part:FindFirstAncestorWhichIsA("Accessory") then
			continue
		end

		local v4 = part.Position.Y - halfWorldHeight(part.CFrame, part.Size)

		if not v3 or v4 < v3 then
			v3 = v4
		end
	end

	return v3
end

local function getStandTop(stand)
	local cFrame, size

	if stand:IsA("BasePart") then
		cFrame = stand.CFrame
		size = stand.Size
	else
		if not stand:IsA("Model") then
			return nil
		end

		local primaryPart = stand.PrimaryPart

		if primaryPart then
			cFrame = primaryPart.CFrame
			size = primaryPart.Size
		else
			cFrame, size = stand:GetBoundingBox()
		end
	end

	local lookVector = cFrame.LookVector
	local vector = Vector3.new(lookVector.X, 0, lookVector.Z)

	if vector.Magnitude < 0.01 then
		local rightVector = cFrame.RightVector
		vector = Vector3.new(rightVector.Z, 0, -rightVector.X)
	end

	local v3 = not (vector.Magnitude > 0.01) and 0 or math.atan2(-vector.X, -vector.Z)
	local v4 = cFrame.Position + Vector3.new(0, halfWorldHeight(cFrame, size), 0)
	return CFrame.new(v4) * CFrame.Angles(0, v3, 0)
end

local function clearStrayMannequins(stand)
	for _, model in stand:GetChildren() do
		if not (model:IsA("Model") and (model.Name == "EmoteStandDummy" or string.match(model.Name, "^EmoteStand_") ~= nil)) then
			continue
		end

		logger:warn((`{stand:GetFullName()} already had a mannequin named "{model.Name}" — destroying it.`))
		model:Destroy()
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getPromptParent(model)
	if model:IsA("Model") then
		return model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart") or model
	end

	return model
end

-- equivalent calls inferred from this helper; original call sites unknown
local function isStale(p, p2: number)
	return p.destroyed or p.buildId ~= p2
end

local function playEmoteMusic(state, p, rootPart)
	if not p.SongId or p.Animation:GetAttribute("SongIsEncrypted") then
		return
	end

	local humanoid = rootPart:FindFirstChildOfClass("Humanoid")
	local sound = Instance.new("Sound")
	sound.Name = "EmoteStandMusic"
	sound.SoundId = `rbxassetid://{p.SongId}`
	sound.Looped = true
	sound.Volume = tonumber(state.stand:GetAttribute("MusicVolume")) or 0.35
	sound.RollOffMode = Enum.RollOffMode.InverseTapered
	sound.RollOffMinDistance = 8
	sound.RollOffMaxDistance = 40

	if humanoid then
		rootPart = humanoid.RootPart or rootPart
	end

	sound.Parent = rootPart
	sound:Play()
	state.showJanitor:Add(function()
		local tween = TweenService:Create(sound, TweenInfo.new(0.35), {
			Volume = 0
		})
		tween.Completed:Once(function()
			sound:Destroy()
		end)
		tween:Play()
	end, true)
end

local function attachEmoteEffect(data, data2, dummy, showId: number)
	local v3 = false

	local function attach(p)
		if v3 or data.destroyed or data.showId ~= showId or data.dummy ~= dummy then
			return
		end

		v3 = true
		local success, result = pcall(function()
			local effect = RelicsBridge.buildEffect(p, dummy, data2.SongId)

			if effect then
				data.showJanitor:Add(effect, "Destroy")
			end
		end)

		if not success then
			logger:warn((`VFX failed for {data2.Name}: {result}`))
		end
	end

	local effect = data2.Animation:FindFirstChild("Effect")

	if effect then
		attach(effect)
	else
		data.showJanitor:Add(data2.Animation.ChildAdded:Connect(function(child)
			if child.Name == "Effect" then
				attach(child)
			end
		end), "Disconnect")
	end
end

function StandBuilder:showEmote(p, p2: number)
	local dummy = self.dummy

	if isStale(self, p2) or not dummy then
		return
	end

	self.showId += 1
	local showId = self.showId
	self.showJanitor:Cleanup()
	local humanoid = dummy:FindFirstChildOfClass("Humanoid")
	local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")
	playEmoteMusic(self, p, dummy)
	attachEmoteEffect(self, p, dummy, showId)

	if not animator then
		return
	end

	preloadAnimation(p.Animation)

	if isStale(self, p2) or self.showId ~= showId then
		return
	end

	local success, result = pcall(function()
		return animator:LoadAnimation(p.Animation)
	end)

	if not (success and result) then
		logger:warn((`LoadAnimation failed for {p.Name}`))
		return
	end

	result.Priority = Enum.AnimationPriority.Action
	result.Looped = true
	result:Play(0.35, 1, 1)
	self.showJanitor:Add(function()
		result:Stop(0.35)
		task.delay(0.35, function()
			result:Destroy()
		end)
	end, true)
end

function StandBuilder:build(p, p2: number, p3)
	local stand = self.stand
	clearStrayMannequins(stand)
	local standTop = getStandTop(stand)

	if not standTop then
		logger:warn((`{stand:GetFullName()} is neither a BasePart nor a Model.`))
		return false
	end

	if isStale(self, p2) then
		return false
	end

	local attachment = Instance.new("Attachment")
	attachment.Name = "EmoteStandPromptAttachment"
	local promptParent = getPromptParent(stand) -- equivalent call inferred; original call site unknown
	attachment.Parent = promptParent
	attachment.WorldCFrame = standTop * CFrame.new(0, 2.5, 0)
	local proximityPrompt = Instance.new("ProximityPrompt")
	proximityPrompt.Name = "EmoteStandPrompt"
	proximityPrompt.MaxActivationDistance = 20
	proximityPrompt.RequiresLineOfSight = false
	proximityPrompt.ActionText = ""
	proximityPrompt.Parent = attachment
	self.prompt = proximityPrompt
	self.buildJanitor:Add(attachment, "Destroy")
	self.buildJanitor:Add(proximityPrompt.Triggered:Connect(p3.onTriggered), "Disconnect")
	p3.onPromptReady()
	local dummy = Dummy.create()

	if not dummy then
		logger:warn("Failed to create dummy (CreateHumanoidModelFromUserIdAsync failed).")
		return false
	end

	if isStale(self, p2) then
		dummy:Destroy()
		return false
	end

	self.dummy = dummy
	self.buildJanitor:Add(dummy, "Destroy")
	local scale = tonumber(stand:GetAttribute("Scale")) or 1

	if scale ~= 1 then
		dummy:ScaleTo(scale)
	end

	local humanoid = dummy:FindFirstChildOfClass("Humanoid")
	local rootPart = humanoid and humanoid.RootPart

	if rootPart then
		local rotationY = tonumber(stand:GetAttribute("RotationY")) or 0
		local offsetY = tonumber(stand:GetAttribute("OffsetY")) or 0
		local v4 = getRigBottomY(dummy) or rootPart.Position.Y - rootPart.Size.Y / 2
		local v5 = rootPart.Position.Y - v4
		rootPart.Anchored = true
		rootPart.CFrame = standTop * CFrame.Angles(0, math.rad(rotationY), 0) * CFrame.new(0, v5 + offsetY, 0)
	end

	dummy.Name = "EmoteStandDummy"
	dummy.Parent = stand
	StandBuilder.showEmote(self, p, p2)
	return true
end

function StandBuilder:clear()
	self.buildId += 1
	self.emote = nil
	self.nextRollClock = 1e999
	self.showJanitor:Cleanup()
	self.buildJanitor:Cleanup()
	self.dummy = nil
	self.prompt = nil
end

return StandBuilder