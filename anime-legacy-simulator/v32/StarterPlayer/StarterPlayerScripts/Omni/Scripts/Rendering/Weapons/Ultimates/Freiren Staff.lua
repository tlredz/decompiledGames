local module = require("@game/ReplicatedStorage/Omni")
local color = Color3.fromRGB(255, 195, 135)
local parentModule = require(script.Parent.Parent)

local function CanShowCameraEffects()
	return not (module.Data.Settings["Low Mode"] or module.Data.Settings["Hide Effects"])
end

-- equivalent calls inferred from this helper; original call sites unknown
local function ClearCamera(p)
	for _, cameraResource in p.CameraResources do
		cameraResource()
	end

	table.clear(p.CameraResources)
	p.FlightShake = nil
	p.ShakeParams = nil
end

local function PlayImpact(p, vector: Vector3, amplitude: number, duration: number, flag: boolean?)
	if module.Data.Settings["Low Mode"] or module.Data.Settings["Hide Effects"] then
		return
	end

	local currentCamera = workspace.CurrentCamera

	if not currentCamera then
		return
	end

	local falloff = module.Utils.Math.Falloff((currentCamera.CFrame.Position - vector).Magnitude, 70)

	if falloff <= 0 then
		return
	end

	local v = module.Utils.CameraShake:Play({
		Position = vector,
		MaxDistance = 70,
		Amplitude = amplitude,
		Frequency = 0.065,
		FadeOutTime = duration
	})
	local blurEffect = Instance.new("BlurEffect")
	blurEffect.Name = "FreirenSkillBlur"
	blurEffect.Size = amplitude * 7 * falloff
	blurEffect.Parent = currentCamera
	local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
	colorCorrectionEffect.Name = "FreirenSkillImpact"
	colorCorrectionEffect.TintColor = Color3.new(1, 1, 1):Lerp(color, amplitude * 0.45 * falloff)
	colorCorrectionEffect.Brightness = amplitude * 0.12 * falloff
	colorCorrectionEffect.Contrast = amplitude * 0.25 * falloff
	colorCorrectionEffect.Saturation = amplitude * -0.2 * falloff
	colorCorrectionEffect.Parent = currentCamera
	local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local v2 = module.Services.TweenService:Create(blurEffect, tweenInfo, {
		Size = 0
	})
	local v3 = module.Services.TweenService:Create(colorCorrectionEffect, tweenInfo, {
		TintColor = Color3.new(1, 1, 1),
		Brightness = 0,
		Contrast = 0,
		Saturation = 0
	})
	v2:Play()
	v3:Play()
	module.Services.Debris:AddItem(blurEffect, duration + 0.05)
	module.Services.Debris:AddItem(colorCorrectionEffect, duration + 0.05)

	if not flag then
		table.insert(p.CameraResources, function()
			if v then
				v:Stop()
			end

			v2:Cancel()
			v3:Cancel()
			blurEffect:Destroy()
			colorCorrectionEffect:Destroy()
		end)
	end
end

local FreirenStaff = {}

function FreirenStaff:Setup()
	self.CameraResources = {}
	table.insert(self.Resources, function()
		ClearCamera(self) -- equivalent call inferred; original call site unknown
	end)
end

function FreirenStaff.OnPhase(p)
	if p.Phase.Name == "Launching" then
		PlayImpact(p, p.Transform.Position, 2, 0.18)
	end
end

function FreirenStaff:Update()
	if module.Data.Settings["Low Mode"] or module.Data.Settings["Hide Effects"] then
		ClearCamera(self) -- equivalent call inferred; original call site unknown
	else
		local visual = self.Skill.Visual
		local v = self.Phase.Name == "Preparing"

		if v and self.Elapsed < visual.SpawnAt then
			return
		end

		if not self.Spawned then
			self.Spawned = true
			self.ShakeParams = {
				Position = self.HRP.Position,
				MaxDistance = 70,
				Amplitude = 0.12,
				Frequency = 0.09,
				FadeInTime = 0.1,
				SustainTime = module.Shared.Weapons.Ultimate.GetDuration(self.Skill),
				FadeOutTime = 0.12
			}
			self.FlightShake = module.Utils.CameraShake:Play(self.ShakeParams)

			if self.FlightShake then
				local flightShake = self.FlightShake
				table.insert(self.CameraResources, function()
					flightShake:Stop()
				end)
			end

			self.BlackHole = parentModule.CreateEffect(self.Character, "Freiren Staff", "Skill", {
				Name = "BlackHole",
				Enable = true,
				Duration = 1e999
			}, self.Transform)

			if self.BlackHole then
				self.BaseScale = self.BlackHole:GetScale()
				table.insert(self.Resources, function()
					parentModule.RemoveEffect(self.BlackHole)
				end)
			end
		end

		local blackHole = self.BlackHole

		if not (blackHole and blackHole.Parent) then
			return
		end

		local transform = self.Transform
		local maximumScale = visual.MaximumScale

		if v then
			local child = self.Character:FindFirstChild(visual.Part)

			if not child then
				return
			end

			transform = child.CFrame * visual.Offset
			local v2 = math.clamp((self.Elapsed - visual.SpawnAt) / (self.Phase.Duration - visual.SpawnAt), 0, 1)
			maximumScale = visual.InitialScale * math.max(0.01, v2)
		elseif self.Phase.Name == "Launching" then
			maximumScale = visual.InitialScale + (visual.MaximumScale - visual.InitialScale) * self.Progress
		elseif self.Phase.Name == "Ending" then
			maximumScale = visual.MaximumScale * math.max(0.001, 1 - self.Progress)
		end

		local appliedScale = self.BaseScale * maximumScale

		if self.AppliedScale ~= appliedScale then
			self.AppliedScale = appliedScale
			blackHole:ScaleTo(appliedScale)
		end

		blackHole:PivotTo(transform)

		if self.ShakeParams then
			self.ShakeParams.Position = transform.Position
		end
	end
end

function FreirenStaff.Clear(player)
	if not player.Completed or not player.Character:IsDescendantOf(workspace) or player.Player and player.Player.Character ~= player.Character then
		return
	end

	local endPosition = player.EndPosition or player.Player and player.Player:GetAttribute("SkillEndPosition")

	if typeof(endPosition) ~= "Vector3" then
		return
	end

	local cframe = CFrame.lookAt(endPosition, endPosition + player.Direction)
	PlayImpact(player, endPosition, 3, 0.3, true)
	parentModule.CreateEffect(player.Character, "Freiren Staff", "Skill", {
		Name = "Explosion"
	}, cframe)
end

return FreirenStaff