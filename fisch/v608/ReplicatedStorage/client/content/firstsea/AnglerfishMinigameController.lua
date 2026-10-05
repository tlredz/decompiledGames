local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local currentCamera = workspace.CurrentCamera
local packages = ReplicatedStorage.packages
local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
colorCorrectionEffect.Name = "AnglerMinigame_DeathColorCorrection"
colorCorrectionEffect.Brightness = -2
colorCorrectionEffect.Contrast = 5
colorCorrectionEffect.Enabled = false
colorCorrectionEffect.Saturation = -1
colorCorrectionEffect.Parent = currentCamera
local blurEffect = Instance.new("BlurEffect")
blurEffect.Name = "AnglerMinigame_DeathBlur"
blurEffect.Enabled = false
blurEffect.Parent = currentCamera
local Net = require(packages.Net)
local Promise = require(packages.Promise)
local Shake = require(packages.Shake)
local Trove = require(packages.Trove)
local remoteEvent = Net:RemoteEvent("AnglerfishMinigame/FishSpawn")
local remoteEvent2 = Net:RemoteEvent("AnglerfishMinigame/DeathEffect")
local AnglerfishMinigameController = {
	deathEffectTrove = Trove.new()
}

function pivotTween(instance, p, cframe: CFrame)
	local cFrameValue = Instance.new("CFrameValue")
	cFrameValue.Value = instance:GetPivot()
	local tween = TweenService:Create(cFrameValue, p, {
		Value = cframe
	})
	tween:Play()
	cFrameValue:GetPropertyChangedSignal("Value"):Connect(function()
		instance:PivotTo(cFrameValue.Value)
	end)
	tween.Completed:Connect(function()
		cFrameValue:Destroy()
		tween:Destroy()
	end)
	tween.Destroying:Connect(function()
		cFrameValue:Destroy()
	end)
	return tween, cFrameValue
end

function fastTween(p, p2, p3, _: boolean?)
	local tween = TweenService:Create(p, p2, p3)
	tween:Play()
	tween.Completed:Connect(function()
		tween:Destroy()
	end)
	return tween
end

function AnglerfishMinigameController:DeathEffect()
	self.deathEffectTrove:Clean()
	blurEffect.Size = 0
	colorCorrectionEffect.Brightness = 0
	colorCorrectionEffect.Contrast = 0
	colorCorrectionEffect.Saturation = 0
	blurEffect.Enabled = true
	colorCorrectionEffect.Enabled = true
	self.deathEffectTrove:Add(function()
		fastTween(currentCamera, TweenInfo.new(1, Enum.EasingStyle.Back), {
			FieldOfView = 70
		})
	end)
	local v = fastTween(currentCamera, TweenInfo.new(1, Enum.EasingStyle.Back), {
		FieldOfView = 40
	})
	self.deathEffectTrove:Add(v)
	local v2 = fastTween(blurEffect, TweenInfo.new(1, Enum.EasingStyle.Back), {
		Size = 24
	})
	self.deathEffectTrove:Add(v2)
	local v3 = fastTween(colorCorrectionEffect, TweenInfo.new(1, Enum.EasingStyle.Back), {
		Brightness = -3.25,
		Contrast = 4,
		Saturation = -1,
		TintColor = Color3.fromRGB(255, 92, 92)
	})
	self.deathEffectTrove:Add(v3):Play()
	self.deathEffectTrove:AddPromise(Promise.delay(1):andThen(function()
		local v4 = fastTween(blurEffect, TweenInfo.new(0.75, Enum.EasingStyle.Back), {
			Size = 0
		})
		self.deathEffectTrove:Add(v4)
		fastTween(currentCamera, TweenInfo.new(1, Enum.EasingStyle.Back), {
			FieldOfView = 70
		})
		local v5 = fastTween(
			colorCorrectionEffect,
			TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.In),
			{
				Contrast = 0,
				Saturation = 0,
				TintColor = Color3.fromRGB(255, 255, 255)
			}
		)
		self.deathEffectTrove:Add(v5)
		local v6 = fastTween(
			colorCorrectionEffect,
			TweenInfo.new(0.75, Enum.EasingStyle.Back, Enum.EasingDirection.InOut),
			{
				Brightness = 0
			}
		)
		self.deathEffectTrove:Add(v6)
	end):andThenCall(Promise.delay, 0.75):finally(function()
		colorCorrectionEffect.Enabled = false
	end))
	local v4 = Shake.new()
	v4.Amplitude = 4
	v4.Frequency = 0.5
	v4.FadeInTime = 0.1
	v4.FadeOutTime = 2.5
	v4.PositionInfluence = createVector(0.5, 0.5, 0.5)
	v4.RotationInfluence = createVector(0.01, 0.01, 0.01)
	v4:Start()
	v4:BindToRenderStep(Shake.NextRenderName(), Enum.RenderPriority.Last.Value, function(position, data)
		currentCamera.CFrame *= CFrame.new(position) * CFrame.Angles(data.X, data.Y, data.Z)
	end)

	repeat
		task.wait()
	until not v4:IsShaking()

	v4:Destroy()
end

function AnglerfishMinigameController:Start()
	remoteEvent2.OnClientEvent:Connect(function()
		self:DeathEffect()
	end)
	remoteEvent.OnClientEvent:Connect(function(_, cframe: CFrame, cframe2: CFrame, duration: number)
		if not (cframe and cframe2 and duration) then
			return
		end

		local clone = ReplicatedStorage.AnglerMinigame.FakeAngler:Clone()
		clone:PivotTo(cframe)
		clone.Parent = workspace.active
		local track = clone.AnimationController.Animator:LoadAnimation(ReplicatedStorage.AnglerMinigame.Angler_Swim)
		track.Looped = true
		track:Play()
		pivotTween(clone, TweenInfo.new(duration, Enum.EasingStyle.Linear), cframe2).Completed:Once(function()
			clone:Destroy()
		end)
		local spine = clone.PrimaryPart and clone.PrimaryPart:FindFirstChild("Spine")

		if spine then
			local cFrame = spine.CFrame

			while clone.Parent do
				task.wait()
				local now = os.clock()
				spine.CFrame = cFrame + Vector3.new(0, cFrame.Y + math.sin(now * 2) * 2, 0)
			end
		end
	end)
end

return AnglerfishMinigameController