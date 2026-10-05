local createVector = vector.create
local localPlayer = game.Players.LocalPlayer
local currentCamera = workspace.CurrentCamera
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
local HttpService = game:GetService("HttpService")
local import = _G.import("event")
local import2 = _G.import("animUtil")
local import3 = _G.import("mathUtil")
local import4 = _G.import("clientUtil")
local import5 = _G.import("dictUtil")
_G.import("bodyUtil")
_G.import("cameraUtil")
local import6 = _G.import("petConfig")
local v = false
local inGame = nil
local top = nil
local v2 = nil
local v3 = 0
local v4 = 0
local v5 = 0
local v6 = {}

local function setChatBubblesVisible(p)
	for _, instance in pairs(CollectionService:GetTagged("ChatBubble")) do
		if instance:IsA("GuiObject") then
			instance.Visible = p
		elseif instance:IsA("LayerCollector") then
			instance.Enabled = p
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function normalize()
	v6 = {}
	import.fire("setGameplayInvisible", false)
	import.fire("setGameplayAbilityPopup", nil)
end

local function updateRound(_, p, p2, _, p3)
	normalize() -- equivalent call inferred; original call site unknown
	v = true
	top = p
	v2 = p2
	setChatBubblesVisible(false)

	if not (p3 and v2) then
		return
	end

	local character = v2.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return
	end

	local vector2 = Vector3.new(top.Position.X, humanoidRootPart.Position.Y, top.Position.Z)
	local v7 = humanoidRootPart.Position - vector2

	if v7.Magnitude <= 0.001 then
		return
	end

	v5 = math.atan2(v7.X, v7.Z) + 3.141592653589793
end

-- equivalent calls inferred from this helper; original call sites unknown
local function endGame()
	v = false
	inGame = nil
	top = nil
	v2 = nil
	currentCamera.CameraType = "Custom"
	v3 = 0
	v4 = 0
	import.fire("setGameplayAbilityPopup", nil)
	setChatBubblesVisible(true)
end

local function inGame2()
	inGame = localPlayer:GetAttribute("InGame")
	top = inGame and workspace.Meta.Tables[tostring(inGame)].Table.Top

	if inGame then
		setChatBubblesVisible(false)
		return
	end

	endGame() -- equivalent call inferred; original call site unknown
end

local function lerpAngle(p, p2, p3)
	return p + ((p2 - p + 3.141592653589793) % 6.283185307179586 - 3.141592653589793) * p3
end

local function cameraMotion(p)
	if not (v2 and v) then
		return
	end

	local character = v2.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return
	end

	local vector2 = Vector3.new(top.Position.X, humanoidRootPart.Position.Y, top.Position.Z)
	local v7 = humanoidRootPart.Position - vector2

	if v7.Magnitude > 0.001 then
		local v8 = math.atan2(v7.X, v7.Z) + 3.141592653589793
		local v9 = 1 - 0.01 ^ p
		local v10 = v5
		local quadOut = import3.quadOut(v9)
		v5 = v10 + ((v8 - v10 + 3.141592653589793) % 6.283185307179586 - 3.141592653589793) * quadOut
	end

	if import5.count(v6) == 0 then
		currentCamera.CFrame = CFrame.new((Vector3.new(top.Position.X, humanoidRootPart.Position.Y, top.Position.Z))) * CFrame.Angles(
			0,
			v5,
			0
		) * CFrame.new(0, 2 - v4 * 0.5, 0) * CFrame.Angles(
			math.sin(os.clock() * 0.75) * 3.141592653589793 * 2 / 180,
			0,
			0
		) * CFrame.Angles(0, math.cos(os.clock() * 0.2) * 3.141592653589793 * 2 / 180, 0)
	end

	v3 *= 0.9 ^ (p * 60)

	if v3 > 0.001 then
		local v8 = v3 * 0.08726646259971647
		currentCamera.CFrame *= CFrame.Angles(math.sin(os.clock() * 25) * 2 * v8, math.sin(os.clock() * 50) * 2 * v8, 0)
	end
end

local function highlight(duration, p)
	local character = v2.Character
	local highlight2 = Instance.new("Highlight")
	highlight2.FillColor = p or highlight2.FillColor
	highlight2.OutlineTransparency = 1
	highlight2.Parent = character
	TweenService:Create(highlight2, TweenInfo.new(duration, Enum.EasingStyle.Quad), {
		FillTransparency = 1
	}):Play()
	task.delay(1, function()
		highlight2:Destroy()
	end)
end

local function correct(_)
	task.spawn(import2.animate, 0.1, function(p)
		v4 = -import3.cubicInOut(p) * 0.5
	end)
	task.wait(0.1)
	task.spawn(import2.animate, 0.4, function(p)
		v4 = -0.5 + import3.backOut(p) * 0.5
	end)
	highlight(0.5, Color3.new(0, 1, 0))
	import4.sound("Correct")
end

local function takeDamage(_)
	v3 = 0.3
	highlight(0.5)
	import4.sound("HpLoss")
end

local function strike(_, p, p2)
	if p == 5 then
		return
	end

	v3 = 0.15
	highlight(0.25)

	if not p2 then
		import4.sound("Error")
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function catalystOffset(p)
	local v7 = import6.BaseOffset * createVector(0, 1, 0)
	return import6.BaseOffset * createVector(1, 0, 1) * (p * 2 - 3) + v7
end

local function cutscene(fn)
	local GUID = HttpService:GenerateGUID()
	v6[GUID] = true
	import.fire("setGameplayInvisible", true)
	local success, result = pcall(fn)

	if not success then
		warn(result)
	end

	v6[GUID] = nil
	import.fire("setGameplayInvisible", false)
end

local function castAbility(p, catalystRef, abilityId, casterUserId, catalystId, abilityConfig)
	v2 = p
	cutscene(function()
		local v7, v8 = unpack(catalystRef)
		local cframe = workspace.Meta.Tables[tostring(inGame)].Chairs[tostring(v7)].CFrame * CFrame.new(0, 1.5, 0)
		local v9 = cframe.Position + cframe:VectorToWorldSpace(catalystOffset(v8))
		import.fire("setGameplayAbilityPopup", {
			AbilityId = abilityId,
			CatalystId = catalystId,
			CatalystRef = catalystRef,
			CasterUserId = casterUserId,
			AbilityConfig = abilityConfig
		})
		currentCamera.CameraType = "Scriptable"
		currentCamera.CFrame = CFrame.lookAt(v9 + createVector(0, 1.25, 0) + cframe.LookVector * 3, v9)
		task.wait(1)
		import.fire("setGameplayAbilityPopup", nil)
	end)
end

return {
	Priority = 1,
	Run = function()
		import.connect("cutscene", cutscene, {
			Blocking = true
		})
		import.connect("strike", strike, {
			Blocking = true
		})
		import.remoteConnect("normalize", normalize)
		import.remoteConnect("updateRound", updateRound)
		import.remoteConnect("endGame", endGame)
		import.remoteConnect("takeDamage", takeDamage)
		import.remoteConnect("correct", correct)
		import.remoteConnect("strike", function(_, p)
			if p == 5 then
				return
			end

			v3 = 0.15
			highlight(0.25)
			import4.sound("Error")
		end)
		import.remoteConnect("castAbility", castAbility)
		localPlayer:GetAttributeChangedSignal("InGame"):Connect(inGame2)
		RunService.RenderStepped:Connect(cameraMotion)
	end
}