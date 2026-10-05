local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local util = ReplicatedStorage:WaitForChild("Util")
local Tween = require(util.Tween)
local currentCamera = workspace.CurrentCamera
local v = {
	FarIntensity = 0,
	FocusDistance = 0,
	NearIntensity = 0,
	InFocusRadius = 300
}
local v2 = currentCamera and currentCamera:FindFirstChild(script.Parent.Name .. "-" .. script.Name)
local v3 = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function clearEffect()
	if v2 then
		v2:Destroy()
		v2 = nil
	end

	table.clear(v3)
end

workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
	clearEffect() -- equivalent call inferred; original call site unknown
	currentCamera = workspace.CurrentCamera
end)
RunService:BindToRenderStep(script.Parent.Name .. "-" .. script.Name, Enum.RenderPriority.Last.Value - 1000, function(_)
	if v2 and v2.Parent then
		local now = tick()

		for _, v4 in pairs(v3) do
			local v5 = now - v4.Start

			if v4.FadeIn + v4.Lifetime + v4.FadeOut <= v5 then
				clearEffect() -- equivalent call inferred; original call site unknown
				return
			elseif v4.FadeIn + v4.Lifetime < v5 then
				local v6 = v5 - (v4.FadeIn + v4.Lifetime)
				local quad = Tween.ease.out.quad(v6, 0, 1, v4.FadeOut)

				for k, v7 in next, v4.Target, nil do
					local v8 = v[k]
					local v9

					if type(v7) == "number" then
						v9 = Tween.point(v7, v8, quad)
					else
						v9 = v7:Lerp(v8, quad)
					end

					v2[k] = v9
				end
			elseif v4.FadeIn <= v5 then
				for k, v6 in next, v4.Target, nil do
					v2[k] = v6
				end
			else
				local quad = Tween.ease.out.quad(v5, 0, 1, v4.FadeIn)

				for k, v6 in next, v4.Target, nil do
					local v7 = v4.Current[k]
					local v8

					if type(v6) == "number" then
						v8 = Tween.point(v7, v6, quad)
					else
						v8 = v7:Lerp(v6, quad)
					end

					v2[k] = v8
				end
			end
		end
	else
		clearEffect() -- equivalent call inferred; original call site unknown
	end
end)
local DepthOfField = {}

function DepthOfField.new(data)
	local v4 = {
		FarIntensity = data.FarIntensity,
		FocusDistance = data.FocusDistance,
		Brightness = data.Brightness,
		NearIntensity = data.NearIntensity,
		InFocusRadius = data.InFocusRadius,
		FadeIn = data.FadeIn or 0.25
	}
	v4.Lifetime = data.Lifetime or v4.FadeIn * 2
	v4.FadeOut = data.FadeOut or v4.FadeIn
	return (setmetatable(v4, {
		__index = DepthOfField
	}))
end

function DepthOfField:__init()
	self.Target = {}
	self.Current = {}

	if not (v2 and v2.Parent) then
		v2 = Instance.new("DepthOfFieldEffect")
		v2:AddTag("FastModeDepthOfField")

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

function DepthOfField:Run()
	self:__init()
	table.remove(v3, 1)
	self.Start = tick()
	table.insert(v3, self)
end

return DepthOfField