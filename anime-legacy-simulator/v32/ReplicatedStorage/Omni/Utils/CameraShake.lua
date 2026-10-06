local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Math = require(script.Parent.Math)
local ClientData = require(ReplicatedStorage.Omni.ClientData)
local Shake = require(script.Parent.Parent.Libs.Shake)
local isClient = RunService:IsClient()
return {
	Play = function(_, data)
		if isClient and ClientData.Ready then
			if ClientData.Data.Settings["Low Mode"] or ClientData.Data.Settings["Camera Shake"] == false then
				return
			end
		end

		local currentCamera = workspace.CurrentCamera

		if not currentCamera then
			return
		end

		if data.Position then
			local magnitude = (currentCamera.CFrame.Position - data.Position).Magnitude

			if Math.Falloff(magnitude, data.MaxDistance or 80) <= 0 then
				return
			end
		end

		local v = Shake.new()
		v.Amplitude = (data.Amplitude or 1) * 3
		v.Frequency = data.Frequency or 1
		v.FadeInTime = data.FadeInTime or 0
		v.FadeOutTime = data.FadeOutTime or 0.5
		v.SustainTime = data.SustainTime or 0
		v.RotationInfluence = createVector(0, 0, 0)
		v:Start()
		v:BindToRenderStep(Shake.NextRenderName(), Enum.RenderPriority.Last.Value, function(position, data2)
			if data.Position then
				local magnitude = (currentCamera.CFrame.Position - data.Position).Magnitude
				local falloff = Math.Falloff(magnitude, data.MaxDistance or 80)
				position *= falloff
				data2 *= falloff
			end

			currentCamera.CFrame *= CFrame.new(position) * CFrame.Angles(data2.X, data2.Y, data2.Z)
		end)
		return v
	end
}