local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local CAM = ReplicatedStorage.CAM
local Cam_Shaker = require(CAM.Client.Modules.Effects.Cam_Shaker)
local Ouwmit = require(CAM.Client.Modules.Effects.Ouwmit)
local vfxUtility = require(CAM.Client.Modules.Effects.vfxUtility)
local RaycastHelper = require(CAM.Global.RaycastHelper)
local DebrisModule = require(CAM.DebrisModule)
local Combat_Swings = require(script.Parent:WaitForChild("Combat_Swings"))
local v = {
	"PS2dreamM1s1",
	"PS2dreamM1s2",
	"PS2dreamM1s3",
	"PS2dreamM1s4",
	"PS2dreamM1s5",
	"PS2dreamM1sUPTILT",
	"PS2dreamM1sDOWNSLAM"
}

local function playDreamSound(childName: string?, parent, childName2: string?)
	if parent.Parent == nil then
		return
	end

	local sounds = script:FindFirstChild("Sounds")

	if sounds == nil then
		return
	end

	local v2 = childName ~= nil and sounds:FindFirstChild(childName) or childName2 ~= nil and sounds:FindFirstChild(childName2) or nil

	if v2 == nil then
		return
	end

	local clone = v2:Clone()
	clone.Parent = parent
	clone:Play()
	DebrisModule:AddItem(clone, clone.TimeLength + 1)
end

local v2 = {
	[5] = true,
	[7] = true
}
local cframe = CFrame.new(-1.16265869, 2.33672333, -4.97831726, -1, 0, 0, 0, 1, 0, 0, 0, -1)
local v3 = { 1.8 }
local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
local tweenInfo2 = TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.In)
local v4 = {}

local function playTentaSwing(state, p: number)
	local animationController = state.Model:FindFirstChildOfClass("AnimationController")
	local animator

	if animationController ~= nil then
		animator = animationController:FindFirstChildOfClass("Animator") or nil
	end

	local tenta_Swings = script:FindFirstChild("Tenta_Swings")

	if animator == nil or tenta_Swings == nil then
		return
	end

	local v5 = tenta_Swings:FindFirstChild("Swing_" .. p) or tenta_Swings:FindFirstChild("Swing_1")

	if v5 == nil then
		return
	end

	if state.Track ~= nil then
		state.Track:Stop()
	end

	local track = state.Tracks[v5.Name]

	if track == nil then
		track = animator:LoadAnimation(v5)
		state.Tracks[v5.Name] = track
	end

	track:Play()
	state.Track = track
end

local function tentaFade(p, flag: boolean, tweenInfo3)
	for _, part in p.Parts do
		TweenService:Create(part.Part, tweenInfo3, {
			Transparency = not flag and 1 or part.Authored
		}):Play()
	end
end

local function raiseTenta(instance, humanoidRootPart, p: number)
	local v5 = v4[instance]

	if v5 == nil or v5.Model.Parent == nil then
		local tenta = script:FindFirstChild("Tenta")

		if tenta == nil then
			return
		end

		local clone = tenta:Clone()
		v5 = {
			Model = clone,
			Token = 0,
			FadingOut = false,
			Parts = {},
			Tracks = {}
		}

		for _, part in clone:GetDescendants() do
			if not part:IsA("BasePart") then
				continue
			end

			table.insert(v5.Parts, {
				Part = part,
				Authored = part.Transparency
			})
			part.Transparency = 1
		end

		clone.Parent = workspace.Debree
		v4[instance] = v5
		tentaFade(v5, true, tweenInfo)
		playDreamSound("PS2dreamM1sSUMMON", humanoidRootPart)
	elseif v5.FadingOut then
		v5.FadingOut = false
		tentaFade(v5, true, tweenInfo)
	end

	v5.Model:PivotTo(humanoidRootPart.CFrame * cframe)
	playTentaSwing(v5, p)
	v5.Token += 1
	local token = v5.Token
	local v6 = v3[p] or 2
	local v7 = math.max(v6 - 1, 0)
	task.delay(v7, function()
		if v4[instance] ~= v5 or v5.Token ~= token then
			return
		end

		v5.FadingOut = true
		tentaFade(v5, false, tweenInfo2)
		playDreamSound("PS2dreamM1sDESUMMON", humanoidRootPart)
		task.delay(v6 - v7, function()
			if v4[instance] == v5 and v5.Token == token then
				v4[instance] = nil
				v5.Model:Destroy()
			end
		end)
	end)
end

return function(instance, p: number?, flag: boolean?)
	if flag == true and p == 1 then
		Combat_Swings(instance, 1, true)
		return
	end

	if instance == nil or p == nil then
		return
	end

	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart == nil or (humanoidRootPart.Position - workspace.CurrentCamera.CFrame.Position).Magnitude > 100 then
		return
	end

	Cam_Shaker(humanoidRootPart.Position, v2[p] and "dream_final_shake" or "dream_swing_shake")
	raiseTenta(instance, humanoidRootPart, p)
	playDreamSound(v[p], humanoidRootPart, "PS2dreamM1s1")
	local swings = script:FindFirstChild("Swings")

	if swings == nil then
		return
	end

	local v5 = vfxUtility.cloneAsset(swings, workspace.Debree, "m" .. p, humanoidRootPart.CFrame, 3) or vfxUtility.cloneAsset(
		swings,
		workspace.Debree,
		"m1",
		humanoidRootPart.CFrame,
		3
	)

	if v5 == nil then
		return
	end

	local raycastResult = workspace:Raycast(
		humanoidRootPart.Position + createVector(0, 5, 0),
		createVector(-0, -15, -0),
		RaycastHelper.Crater
	)
	local v6 = raycastResult and vfxUtility.GetDustColorSettings(raycastResult.Instance) or nil
	Ouwmit.Emit(v5, Ouwmit.Owned(instance, v6))
end