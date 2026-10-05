local createVector = vector.create
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local t = require(ReplicatedStorage.Packages.t)
local GuardWakeLookAt = require(script.Parent.GuardWakeLookAt)
local Log = require(ReplicatedStorage.Packages.Log)
local Trove = require(ReplicatedStorage.Packages.Trove)
local WaitFor = require(ReplicatedStorage.Packages.WaitFor)
local v = Log.new()
local GuardComponent = {}
GuardComponent.__index = GuardComponent
GuardComponent.__class = "GuardComponent"
local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, true)
local tweenInfo2 = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local tweenInfo3 = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local tweenInfo4 = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

function GuardComponent.new(instance)
	t.strict(t.instanceIsA("Model"))(instance)
	local object = setmetatable({}, GuardComponent)
	local guard = instance:WaitForChild("Guard")
	assert(guard:IsA("Model"), (`{instance:GetFullName()}.Guard must be a Model`))
	local v2, part = WaitFor.Descendant(guard, "Head"):await()
	assert(v2 and part ~= nil, (`{guard:GetFullName()} requires a Head descendant for alert GUI`))
	assert(part:IsA("BasePart"), (`{part:GetFullName()} must be a BasePart`))
	local humanoidRootPart

	if instance.Name == "Forest" then
		humanoidRootPart = guard:WaitForChild("HumanoidRootPart")
		assert(
			humanoidRootPart,
			(`{guard:GetFullName()} requires a HumanoidRootPart descendant for Forest shake effects`)
		)
		assert(humanoidRootPart:IsA("BasePart"), (`{humanoidRootPart:GetFullName()} must be a BasePart`))
	end

	local v3, billboardGui = WaitFor.Descendant(part, "AlertGui"):await()
	assert(
		v3 and billboardGui and billboardGui:IsA("BillboardGui"),
		(`{part:GetFullName()} requires an AlertGui descendant`)
	)
	object._alertGuiTemplate = billboardGui
	object._alertGui = nil
	object._guardModel = guard
	object._head = part
	object._lastAlertAt = -1e999
	object._root = humanoidRootPart
	object._sleepColorTrove = Trove.new()
	object._trove = Trove.new()

	if not guard:GetAttribute("HeadLookAtDisabled") then
		object._wakeLookAt = GuardWakeLookAt.new(guard)
	end

	object._trove:Add(object._sleepColorTrove)
	object._trove:Add(guard:GetAttributeChangedSignal("TargetPlayer"):Connect(function()
		object:_updateTargetAlert()
	end))
	object._trove:Add(guard:GetAttributeChangedSignal("Sleeping"):Connect(function()
		object:_applySleepVfx()

		if guard:GetAttribute("Sleeping") == true then
			object:_clearAlert()
		end
	end))
	object._trove:Add(guard:GetAttributeChangedSignal("GuardState"):Connect(function()
		object:_applySleepVfx()
		object:_applyGuardStatePresentation()
	end))
	object._trove:Add(guard:GetAttributeChangedSignal("WakeTargetPlayer"):Connect(function()
		object:_applyGuardStatePresentation()
	end))
	object._trove:Add(guard:GetAttributeChangedSignal("Hidden"):Connect(function()
		object:_applySleepVfx()
	end))
	object:_applySleepVfx()
	object:_applyGuardStatePresentation()
	object:_updateTargetAlert()
	local v4 = false
	object._trove:Add(guard.DescendantAdded:Connect(function(part2)
		if not part2:IsA("BasePart") then
			return
		end

		task.delay(1, function()
			if not v4 then
				v4 = true
				object:_applyGuardStatePresentation()
				task.wait(1)
				v4 = false
			end
		end)
	end))
	return object
end

function GuardComponent:_updateTargetAlert()
	local targetPlayer = self._guardModel:GetAttribute("TargetPlayer")

	if typeof(targetPlayer) ~= "string" or targetPlayer == "" then
		return
	end

	local now = os.clock()

	if now - self._lastAlertAt < 3 then
		return
	end

	self._lastAlertAt = now
	self:_showAlert()
end

function GuardComponent:_applySleepVfx()
	local enabled

	if self._guardModel:GetAttribute("GuardState") == "Sleeping" then
		enabled = self._guardModel:GetAttribute("Hidden") ~= true
	else
		enabled = false
	end

	local sleepVFXAttachment = self._guardModel:FindFirstChild("SleepVFXAttachment", true)

	if not sleepVFXAttachment then
		v:AtWarning():Log((`Guard model {self._guardModel:GetFullName()} is missing SleepVFXAttachment`))
		return
	end

	for _, emitter in ipairs(sleepVFXAttachment:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		emitter.Enabled = enabled

		if not enabled then
			emitter:Clear()
		end
	end
end

function GuardComponent:_applyGuardStatePresentation()
	local guardState = self._guardModel:GetAttribute("GuardState")
	local wakeTargetPlayer = self._guardModel:GetAttribute("WakeTargetPlayer")
	t.strict(t.optional(t.string))(wakeTargetPlayer)

	if self._wakeLookAt then
		local _wakeLookAt = self._wakeLookAt
		local v2 = guardState == "Waking"

		if wakeTargetPlayer == "" then
			wakeTargetPlayer = nil
		end

		_wakeLookAt:SetWaking(v2, wakeTargetPlayer)
	end

	if guardState == "Sleeping" then
		self:_applySleepDetailColors()
		return
	end

	if guardState ~= "Waking" then
		return
	end

	self:_animateSleepDetailColorsToOriginal()
end

function GuardComponent:_applySleepDetailColors()
	self._sleepColorTrove:Clean()

	for _, part in ipairs(self._guardModel:GetDescendants()) do
		if not part:IsA("BasePart") then
			continue
		end

		local sleepColor = part:GetAttribute("SleepColor")

		if not sleepColor then
			continue
		end

		if part:GetAttribute("OriginalColor") == nil then
			part:SetAttribute("OriginalColor", part.Color)
		end

		part.Color = sleepColor
	end
end

function GuardComponent:_animateSleepDetailColorsToOriginal()
	self._sleepColorTrove:Clean()

	for _, part in ipairs(self._guardModel:GetDescendants()) do
		if not (part:IsA("BasePart") and part:GetAttribute("SleepColor")) then
			continue
		end

		local originalColor = part:GetAttribute("OriginalColor")

		if originalColor == nil then
			originalColor = part.Color
			part:SetAttribute("OriginalColor", originalColor)
		end

		assert(originalColor, "luau")
		part.Color = originalColor
	end
end

function GuardComponent:_clearAlert()
	local _alertGui = self._alertGui

	if _alertGui == nil then
		return
	end

	self._alertGui = nil
	_alertGui:Destroy()
end

function GuardComponent:_showAlert()
	if self._alertGui ~= nil then
		return
	end

	local clone = self._alertGuiTemplate:Clone()
	local v2 = assert(clone:FindFirstChildWhichIsA("ImageLabel"))
	v2.Transparency = 1
	clone.AlwaysOnTop = true
	clone.Enabled = true
	clone.Parent = self._head
	self._alertGui = clone
	self._trove:Add(clone)
	TweenService:Create(v2, tweenInfo2, {
		ImageTransparency = 0
	}):Play()
	local tween = TweenService:Create(clone, tweenInfo3, {
		StudsOffset = clone.StudsOffset + createVector(0, 1, 0) * math.max(clone.StudsOffset.Y * 0.6, 1)
	})
	tween.Completed:Once(function()
		task.wait(1)
		TweenService:Create(v2, tweenInfo4, {
			ImageTransparency = 1
		}):Play()
	end)
	tween:Play()
	task.delay(3, function()
		if clone.Parent == nil then
			return
		end

		if self._alertGui == clone then
			self._alertGui = nil
		end

		clone:Destroy()
	end)
	v:AtTrace():Log((`Guard alert shown for {self._guardModel:GetFullName()}`))
end

function GuardComponent:Destroy()
	if self._wakeLookAt then
		self._wakeLookAt:Destroy()
	end

	self._trove:Destroy()
end

function GuardComponent:GetGuardModel()
	return self._guardModel
end

function GuardComponent:PlayWakeUp()
	local highlight = Instance.new("Highlight")
	highlight.Name = "GuardWakeHighlight"
	highlight.FillColor = Color3.fromRGB(255, 0, 0)
	highlight.OutlineColor = Color3.fromRGB(132, 0, 0)
	highlight.FillTransparency = 1
	highlight.OutlineTransparency = 1
	highlight.DepthMode = Enum.HighlightDepthMode.Occluded
	highlight.Parent = self._guardModel
	TweenService:Create(highlight, tweenInfo, {
		FillTransparency = 0.35,
		OutlineTransparency = 0
	}):Play()
	Debris:AddItem(highlight, tweenInfo.Time * 2 + 0.05)
end

return GuardComponent