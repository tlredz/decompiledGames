local createVector = vector.create
local v = nil
local v2 = {}
local RunService = game:GetService("RunService")
return {
	A = function(p)
		if p then
			local CollectionService = game:GetService("CollectionService")
			local Lighting = game:GetService("Lighting")
			local Players = game:GetService("Players")
			local ReplicatedStorage = game:GetService("ReplicatedStorage")
			local TweenService = game:GetService("TweenService")
			local LensFlare = require(ReplicatedStorage.Resources.CosmicUtils.LensFlare)
			local Configuration = require(ReplicatedStorage.Resources.CosmicUtils.Configuration)
			local currentCamera = workspace.CurrentCamera
			local _ = Players.LocalPlayer
			local SUN_EXPOSURE_ADJUSTMENT = Configuration.SUN_EXPOSURE_ADJUSTMENT
			local SUN_EXPOSURE_TIME = Configuration.SUN_EXPOSURE_TIME
			local SUN_BRIGHTNESS_THRESHOLD = Configuration.SUN_BRIGHTNESS_THRESHOLD
			local SUN_ANGLE_THRESHOLD = Configuration.SUN_ANGLE_THRESHOLD
			local part = Instance.new("Part")
			part.Anchored = true
			part.CanCollide = false
			part.CanQuery = false
			part.CanTouch = false
			part.Transparency = 0.5
			part.Size = createVector(1, 1, 1)
			part.Name = "SunFlareTestPart"
			part.Parent = workspace.Thrown
			game.Debris:AddItem(part, 13)
			part:SetAttribute("LensFlareStrength", 1)
			v = LensFlare.new(currentCamera, "Default", part)

			-- equivalent calls inferred from this helper; original call sites unknown
			local function updateColor()
				part.Color = Lighting.ColorShift_Top
			end

			updateColor() -- equivalent call inferred; original call site unknown
			Lighting:GetPropertyChangedSignal("ColorShift_Top"):Connect(updateColor)

			-- equivalent calls inferred from this helper; original call sites unknown
			local function updateStrength()
				local v3 = math.clamp(Lighting:GetSunDirection().Y * 90 / SUN_ANGLE_THRESHOLD, 0, 1) * math.clamp(
					Lighting.Brightness / SUN_BRIGHTNESS_THRESHOLD,
					0,
					1
				)

				if v and v.Enabled ~= nil then
					v.Enabled = v3 > 0
				end

				part:SetAttribute("LensFlareStrength", v3)
			end

			updateStrength() -- equivalent call inferred; original call site unknown
			Lighting:GetPropertyChangedSignal("Brightness"):Connect(updateStrength)
			Lighting:GetPropertyChangedSignal("ClockTime"):Connect(updateStrength)
			RunService:BindToRenderStep("UpdateLensFlarePart", Enum.RenderPriority.Camera.Value + 9, function()
				part.Position = currentCamera.CFrame.Position + Lighting:GetSunDirection() * 5000
			end)
			local v3 = 0
			local v4 = 0
			RunService:BindToRenderStep("UpdateExposure", Enum.RenderPriority.Camera.Value + 11, function(p2: number)
				Lighting.ExposureCompensation -= v3 * SUN_EXPOSURE_ADJUSTMENT
				v3, v4 = TweenService:SmoothDamp(v3, v.Alpha ^ 2, v4, SUN_EXPOSURE_TIME, nil, p2)
				Lighting.ExposureCompensation += v3 * SUN_EXPOSURE_ADJUSTMENT
			end)
			local v5 = {}

			for _, instance in CollectionService:GetTagged("LensFlare") do
				if not (instance:IsA("BasePart") or instance:IsA("Attachment") and not v5[instance]) then
					continue
				end

				v5[instance] = LensFlare.new(currentCamera, instance:GetAttribute("LensFlareStyle"), instance)
			end

			CollectionService:GetInstanceAddedSignal("LensFlare"):Connect(function(instance)
				if instance:IsA("BasePart") or instance:IsA("Attachment") and not v5[instance] then
					v5[instance] = LensFlare.new(currentCamera, instance:GetAttribute("LensFlareStyle"), instance)
				end
			end)
			CollectionService:GetInstanceRemovedSignal("LensFlare"):Connect(function(p2)
				if v5[p2] then
					v5[p2]:Destroy()
					v5[p2] = nil
				end
			end)
		else
			local currentCamera = workspace.CurrentCamera

			for _, attachment in ipairs(currentCamera:GetChildren()) do
				if attachment:IsA("Attachment") and attachment.Name:find("LensFlare") then
					attachment:Destroy()
				end
			end

			game.Lighting.ExposureCompensation = 0

			if v then
				v:Destroy()
				v = nil
			end

			for _, v3 in pairs(v2) do
				v3:Destroy()
			end

			table.clear(v2)
			RunService:UnbindFromRenderStep("UpdateLensFlarePart")
			RunService:UnbindFromRenderStep("UpdateExposure")

			if workspace:FindFirstChild("SunFlareTestPart") then
				workspace.SunFlareTestPart:Destroy()
			end
		end
	end
}