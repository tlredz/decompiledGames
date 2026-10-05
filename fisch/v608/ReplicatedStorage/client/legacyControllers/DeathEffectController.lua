local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
local currentCamera = workspace.CurrentCamera
local packages = ReplicatedStorage.packages
local shared = ReplicatedStorage.shared
local v = currentCamera:FindFirstChild("DeathColorCorrection")

if not v then
	v = Instance.new("ColorCorrectionEffect")
	v.Name = "DeathColorCorrection"
	v.Brightness = -2
	v.Contrast = 5
	v.Enabled = false
	v.Saturation = -1
	v.Parent = currentCamera
end

local v2 = currentCamera:FindFirstChild("DeathBlur")

if not v2 then
	v2 = Instance.new("BlurEffect")
	v2.Name = "DeathBlur"
	v2.Enabled = false
	v2.Parent = currentCamera
end

local GeneralUtils = require(shared.utils.GeneralUtils)
local Promise = require(packages.Promise)
local Shake = require(packages.Shake)
local Trove = require(packages.Trove)
local maid = Trove.new()
return {
	DeathEffect = function(_, value: number?)
		maid:Clean()
		v2.Size = 0
		v.Brightness = 0
		v.Contrast = 0
		v.Saturation = 0
		v2.Enabled = true
		v.Enabled = true
		maid:Add(function()
			GeneralUtils.fastTween(currentCamera, TweenInfo.new(1, Enum.EasingStyle.Back), {
				FieldOfView = 70
			})
		end)
		maid:Add((GeneralUtils.fastTween(currentCamera, TweenInfo.new(1, Enum.EasingStyle.Back), {
			FieldOfView = 40
		})))
		maid:Add((GeneralUtils.fastTween(v2, TweenInfo.new(1, Enum.EasingStyle.Back), {
			Size = 24
		})))
		maid:Add((GeneralUtils.fastTween(v, TweenInfo.new(1, Enum.EasingStyle.Back), {
			Brightness = -3.25,
			Contrast = 4,
			Saturation = -1,
			TintColor = Color3.fromRGB(255, 92, 92)
		}))):Play()
		maid:AddPromise(Promise.delay(value or 1):andThen(function()
			maid:Add((GeneralUtils.fastTween(v2, TweenInfo.new(0.75, Enum.EasingStyle.Back), {
				Size = 0
			})))
			GeneralUtils.fastTween(currentCamera, TweenInfo.new(1, Enum.EasingStyle.Back), {
				FieldOfView = 70
			})
			maid:Add((GeneralUtils.fastTween(v, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
				Contrast = 0,
				Saturation = 0,
				TintColor = Color3.fromRGB(255, 255, 255)
			})))
			maid:Add((GeneralUtils.fastTween(
				v,
				TweenInfo.new(0.75, Enum.EasingStyle.Back, Enum.EasingDirection.InOut),
				{
					Brightness = 0
				}
			)))
		end):andThenCall(Promise.delay, 0.75):finally(function()
			v.Enabled = false
		end))
		local v3 = maid:Add(Shake.new(), "Destroy")
		v3.Amplitude = 4
		v3.Frequency = 0.5
		v3.FadeInTime = 0.1
		v3.FadeOutTime = 2.5
		v3.PositionInfluence = createVector(0.5, 0.5, 0.5)
		v3.RotationInfluence = createVector(0.01, 0.01, 0.01)
		v3:Start()
		v3:BindToRenderStep(Shake.NextRenderName(), Enum.RenderPriority.Last.Value, function(position, data)
			currentCamera.CFrame *= CFrame.new(position) * CFrame.Angles(data.X, data.Y, data.Z)
		end)

		repeat
			task.wait()
		until not v3:IsShaking()

		if v3 and v3.Destroy then
			v3:Destroy()
		end
	end
}