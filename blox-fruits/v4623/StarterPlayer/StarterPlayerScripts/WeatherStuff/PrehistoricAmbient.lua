workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
require(ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
require(ReplicatedStorage:WaitForChild("Util").BoatTween.Lerps)
local _ = Util.BoatTween
local _ = Util.Sound
local _ = Util.MasterClock
local _ = Util.Debris

local function lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

local v = {
	Value = 0,
	CCEffect = nil,
	Loop = false,
	Goals = { Color3.new(1, 1, 1), 0, 0 },
	timeToChange = 1,
	lastAdjust = tick(),
	inc = 0
}

-- equivalent calls inferred from this helper; original call sites unknown
local function cleanUp()
	RunService:UnbindFromRenderStep("prehistoricEffects")

	if v.CCEffect then
		v.CCEffect:Destroy()
	end

	v.CCEffect = nil
	v.Active = false
end

local function updateGoals(value)
	v.Value = value
	v.Goals = {
		Color3.fromRGB(255, 114, 44),
		0.5 * value,
		0.1 * value,
		0.1
	}
	v.lastAdjust = tick()
end

local function Render(p)
	if v.CCEffect then
		local v2 = p * 60
		local v3 = math.min(1, (tick() - v.lastAdjust) / v.timeToChange)
		v.lastInc = v.inc
		v.inc += 1.5 * v2
		local v5 = math.min(1, v.Goals[1].R / v.Value)
		local v6 = math.min(1, v.Goals[1].G / v.Value)
		local v7 = math.min(1, v.Goals[1].B / v.Value)
		v.CCEffect.TintColor = v.CCEffect.TintColor:Lerp(Color3.fromRGB(v5 * 255, v6 * 255, v7 * 255), v3)
		local cCEffect = v.CCEffect
		local saturation = v.CCEffect.Saturation
		cCEffect.Saturation = saturation + (v.Goals[2] - saturation) * v3
		local cCEffect2 = v.CCEffect
		local contrast = v.CCEffect.Contrast
		cCEffect2.Contrast = contrast + (v.Goals[3] - contrast) * v3
		local cCEffect3 = v.CCEffect
		local brightness = v.CCEffect.Brightness
		cCEffect3.Brightness = brightness + (v.Goals[4] - brightness) * v3

		if v.Value <= 0 and v3 == 1 then
			cleanUp() -- equivalent call inferred; original call site unknown
		end
	end
end

return function(p)
	local value = p.Value
	updateGoals(value)

	if not v.CCEffect then
		local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
		colorCorrectionEffect.Name = "PrehistoricAmbientCC"
		colorCorrectionEffect.Parent = game:GetService("Lighting")
		v.CCEffect = colorCorrectionEffect
	end

	if v.Active or not (value > 0) then
		return
	end

	v.lastAdjust = tick()
	RunService:BindToRenderStep("prehistoricEffects", Enum.RenderPriority.Camera.Value + 1, Render)
	v.Active = true
end