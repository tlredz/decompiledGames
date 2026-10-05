local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local util = ReplicatedStorage:WaitForChild("Util")
local Tween = require(util.Tween)
local currentCamera = workspace.CurrentCamera
local v = {
	TintColor = Color3.new(1, 1, 1),
	Saturation = 0,
	Brightness = 0,
	Contrast = 0
}
local v2 = currentCamera:FindFirstChildOfClass(script.Parent.Name .. "-" .. script.Name)
local v3 = {}
RunService:BindToRenderStep(script.Parent.Name .. "-" .. script.Name, Enum.RenderPriority.Last.Value - 1000, function(_)
	local now = tick()

	for k, v4 in pairs(v3) do
		local v5 = now - v4.Start

		if v4.FadeIn + v4.Lifetime + v4.FadeOut < v5 then
			for k2, v6 in next, v, nil do
				v2[k2] = v6
			end

			v3[k] = nil
		elseif v4.FadeIn + v4.Lifetime < v5 then
			local v6 = v5 - (v4.FadeIn + v4.Lifetime)
			local quad = Tween.ease.out.quad(v6, 0, 1, v4.FadeOut)

			for k2, v7 in next, v4.Target, nil do
				local v8 = v[k2]
				local v9

				if type(v7) == "number" then
					v9 = Tween.point(v7, v8, quad)
				else
					v9 = v7:Lerp(v8, quad)
				end

				v2[k2] = v9
			end
		elseif v4.FadeIn < v5 then
			for k2, v6 in next, v4.Target, nil do
				v2[k2] = v6
			end
		else
			local quad = Tween.ease.out.quad(v5, 0, 1, v4.FadeIn)

			for k2, v6 in next, v4.Target, nil do
				local v7 = v4.Current[k2]
				local v8

				if type(v6) == "number" then
					v8 = Tween.point(v7, v6, quad)
				else
					v8 = v7:Lerp(v6, quad)
				end

				v2[k2] = v8
			end
		end
	end
end)
local ColorCorrection = {}

function ColorCorrection.new(data)
	local v4 = {
		TintColor = data.TintColor,
		Saturation = data.Saturation,
		Brightness = data.Brightness,
		Contrast = data.Contrast,
		FadeIn = data.FadeIn or 0.25
	}
	v4.Lifetime = data.Lifetime or v4.FadeIn * 2
	v4.FadeOut = data.FadeOut or v4.FadeIn
	return (setmetatable(v4, {
		__index = ColorCorrection
	}))
end

function ColorCorrection:__init()
	if self.Model then
		return self
	end

	self.Target = {}
	self.Current = {}

	if not (v2 and v2.Parent) then
		v2 = Instance.new("ColorCorrectionEffect")

		for k, v4 in next, v, nil do
			v2[k] = v4
		end

		v2.Name = script.Parent.Name .. "-" .. script.Name
		v2.Parent = currentCamera
	end

	for k, v4 in next, v, nil do
		self.Current[k] = v2[k]
		self.Target[k] = self[k] or v4
	end

	self.Initialized = true
	return self
end

function ColorCorrection:Run()
	if not self.Initialized then
		self:__init()
	end

	table.remove(v3, 1)
	self.Start = tick()
	table.insert(v3, self)
end

return ColorCorrection