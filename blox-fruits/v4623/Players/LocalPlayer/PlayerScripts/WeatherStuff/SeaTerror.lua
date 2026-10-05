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
local localPlayer = game.Players.LocalPlayer

local function lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

local v = {
	Value = 0,
	CCEffect = nil,
	Cam = workspace.CurrentCamera,
	Loop = false,
	Goals = { 255, 0, 0 },
	timeToChange = 1,
	lastAdjust = tick(),
	inc = 0
}

-- equivalent calls inferred from this helper; original call sites unknown
local function cleanUp()
	RunService:UnbindFromRenderStep("seaTerrorEffects")

	if v.CCEffect then
		v.CCEffect:Destroy()
	end

	v.CCEffect = nil
	v.Active = false
end

-- equivalent calls inferred from this helper; original call sites unknown
local function updateGoals(value)
	v.Value = value
	v.Goals = { 155, -(0.5 * value), 0.3 * value }
	v.lastAdjust = tick()
end

local function Render(p)
	if v.Cam and v.CCEffect then
		local v2 = p * 60
		local v3 = math.min(1, (tick() - v.lastAdjust) / v.timeToChange)
		v.lastInc = v.inc
		v.inc += 1.5 * v2
		local value = v.Value
		local v5

		if localPlayer and localPlayer.Character and localPlayer.Character:GetAttribute("TerrorReducer") then
			v5 = 1 - localPlayer.Character:GetAttribute("TerrorReducer")
			value *= v5
		else
			v5 = 1
		end

		local v6 = { v.Cam.CFrame:GetComponents() }
		local v7 = v6[10]
		v6[10] = v7 + (v6[10] + 0.05 * value / 2 - 0.2 * value / 2 * math.sin(v.inc / 120) - v7) * v3
		local v8 = v6[11]
		v6[11] = v8 + (v6[11] + 0 * value - 0.1 * value / 2 * math.cos(v.inc / 240) - v8) * v3
		v6[10] = v6[10] < -1 and -1 or v6[10] > 1 and 1 or v6[10]
		v6[11] = v6[11] < -1 and -1 or v6[11] > 1 and 1 or v6[11]
		v.Cam.CFrame = CFrame.new(table.unpack(v6))
		local v9 = math.min(255, v.Goals[1] / value)
		v.CCEffect.TintColor = v.CCEffect.TintColor:Lerp(Color3.fromRGB(v9, v9, v9), v3)
		local cCEffect = v.CCEffect
		local saturation = v.CCEffect.Saturation
		cCEffect.Saturation = saturation + (v.Goals[2] * v5 - saturation) * v3
		local cCEffect2 = v.CCEffect
		local contrast = v.CCEffect.Contrast
		cCEffect2.Contrast = contrast + (v.Goals[3] * v5 - contrast) * v3

		if v.Value <= 0 and v3 == 1 then
			cleanUp() -- equivalent call inferred; original call site unknown
		end
	end
end

return function(p)
	local value = p.Value
	v.Cam = workspace.CurrentCamera
	updateGoals(value) -- equivalent call inferred; original call site unknown

	if not v.CCEffect then
		local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
		colorCorrectionEffect.Name = "SeaTerrorCC"
		colorCorrectionEffect.Parent = game:GetService("Lighting")
		v.CCEffect = colorCorrectionEffect
	end

	if v.Active or not (value > 0) then
		return
	end

	v.lastAdjust = tick()
	RunService:BindToRenderStep("seaTerrorEffects", Enum.RenderPriority.Camera.Value + 1, Render)
	v.Active = true
end