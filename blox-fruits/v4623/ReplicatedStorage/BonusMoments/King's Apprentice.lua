local createVector = vector.create
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
local CompassTracker = require(game.ReplicatedStorage.GuideModule.CompassTracker)
require(game.ReplicatedStorage.Controllers.BonusMomentsController.Types)
local Sound = require(game.ReplicatedStorage.Util.Sound)
local localPlayer = game.Players.LocalPlayer
local kingsApprentice = script["King's Apprentice"]
local v = false
local flag = false
local flag2 = false
local frozen = table.freeze({
	"ColosseumBonusMoments.BF_GladiatorChallenge_DefeatWave_01",
	"ColosseumBonusMoments.BF_GladiatorChallenge_DefeatWave_02",
	"ColosseumBonusMoments.BF_GladiatorChallenge_DefeatWave_03"
})
local v2 = nil
local count = 0

local function playCrowdSound(soundId: string)
	local sound = Instance.new("Sound")
	sound.SoundId = soundId
	sound.Volume = 0.5
	sound.Parent = SoundService
	sound:Play()
	sound.Ended:Once(function()
		sound:Destroy()
	end)
	task.delay(6, function()
		if sound.Parent ~= nil then
			sound:Destroy()
		end
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function startCheerLoop()
	count += 1
	local v3 = count
	task.spawn(function()
		while count == v3 do
			task.wait(6 + math.random() * 4)

			if count ~= v3 then
				break
			end

			playCrowdSound("rbxassetid://126615573673174")
		end
	end)
end

local function stopCheerLoop()
	count += 1
end

-- equivalent calls inferred from this helper; original call sites unknown
local function startCircleAura()
	if v2 ~= nil then
		return
	end

	local v3 = Sound:Play(
		"ColosseumBonusMoments.BF_GladiatorChallenge_RedCircle_Aura_01",
		kingsApprentice.StartMatchHitbox
	)
	v3.Looped = true
	v2 = v3
end

-- equivalent calls inferred from this helper; original call sites unknown
local function stopCircleAura()
	if v2 ~= nil then
		Sound:Kill(v2)
		v2 = nil
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function stopCompass()
	if not flag then
		return
	end

	flag = false
	pcall(function()
		CompassTracker.removeTracker("KINGS_APPRENTICE")
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function startCompass()
	if flag then
		return
	end

	flag = true
	pcall(function()
		CompassTracker.createTracker("KINGS_APPRENTICE", {
			Target = function()
				return kingsApprentice.Visual:GetPivot()
			end,
			AlertIconSettings = {
				MaxDistance = 1000
			},
			IconSettings = {
				ShowIsland = false
			},
			ShowOffScreenAlert = true
		})
	end)
end

local function emperorPosition()
	local nPCs = workspace:FindFirstChild("NPCs")
	local colosseumEmperor

	if nPCs then
		colosseumEmperor = nPCs:FindFirstChild("Colosseum Emperor")
	end

	if colosseumEmperor and colosseumEmperor:IsA("PVInstance") then
		return colosseumEmperor:GetPivot().Position
	end

	return createVector(0, 0, 0)
end

local function stopReportStar()
	if not flag2 then
		return
	end

	flag2 = false
	pcall(function()
		CompassTracker.removeTracker("KINGS_APPRENTICE_REPORT")
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function startReportStar()
	if flag2 then
		return
	end

	flag2 = true
	pcall(function()
		CompassTracker.createTracker("KINGS_APPRENTICE_REPORT", {
			Target = emperorPosition,
			AlertIconSettings = {
				Sprite = "Badge Star"
			},
			IconSettings = {
				Sprite = "Badge Star",
				ShowIsland = false
			},
			ViewportSettings = {
				UseIconAsBackground = false
			},
			ShowOffScreenAlert = true
		})
	end)
end

local function toggleModelTransparency(folder, p: number?)
	for _, descendant in folder:GetDescendants() do
		if descendant:IsA("BasePart") then
			local transparency = p or descendant:GetAttribute("OriginalTransparency")
			TweenService:Create(descendant, TweenInfo.new(0.25), {
				Transparency = transparency
			}):Play()
		elseif descendant:IsA("Beam") then
			local numberValue = Instance.new("NumberValue")
			numberValue.Value = descendant.Transparency.Keypoints[1].Value
			local v3 = descendant
			numberValue.Changed:Connect(function(p2)
				v3.Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, p2),
					NumberSequenceKeypoint.new(0.5, p2),
					NumberSequenceKeypoint.new(1, p2)
				})
			end)
			local v4 = p or descendant:GetAttribute("OriginalTransparency")

			if v4 ~= 1 then
				descendant.Enabled = false
			end

			TweenService:Create(numberValue, TweenInfo.new(0.25), {
				Value = v4
			}):Play()
			local v7 = descendant
			task.delay(0.5, function()
				numberValue:Destroy()

				if v4 == 1 then
					v7.Enabled = false
				end
			end)
		elseif descendant:IsA("ParticleEmitter") then
			descendant.Enabled = p ~= 1
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function markWon(p)
	if p.Progress == 1 then
		return
	end

	p.Progress = 1
	v = false
	count += 1
	stopCircleAura() -- equivalent call inferred; original call site unknown
	stopCompass() -- equivalent call inferred; original call site unknown
	toggleModelTransparency(kingsApprentice.Visual, 1)
	playCrowdSound("rbxassetid://126615573673174")
	startReportStar() -- equivalent call inferred; original call site unknown
end

local function inHitbox(vector2: Vector3, instance)
	local pointToObjectSpace = instance.CFrame:PointToObjectSpace(vector2)
	local v3 = instance.Size * 0.5
	return math.abs(pointToObjectSpace.X) <= v3.X and math.abs(pointToObjectSpace.Z) <= v3.Z and math.abs(pointToObjectSpace.Y) <= v3.Y + 15
end

local KingSApprentice = {}

function KingSApprentice.OnLoad(object)
	for _, descendant in kingsApprentice.Visual:GetDescendants() do
		if descendant:IsA("BasePart") then
			descendant:SetAttribute("OriginalTransparency", descendant.Transparency)
		elseif descendant:IsA("Beam") or descendant:IsA("ParticleEmitter") then
			descendant:SetAttribute("OriginalTransparency", descendant.Transparency.Keypoints[1].Value)
		end
	end

	toggleModelTransparency(kingsApprentice.Visual, 1)
	kingsApprentice.Parent = workspace
	object.Trove:Add(function()
		stopCircleAura() -- equivalent call inferred; original call site unknown
		count += 1
		kingsApprentice.Parent = script
		v = false
		toggleModelTransparency(kingsApprentice.Visual)
	end)
	local heartbeatConnection = RunService.Heartbeat:Connect(function()
		if v or not object.Active or object.Completed then
			return
		end

		local character = localPlayer.Character
		local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart == nil or not humanoidRootPart:IsA("BasePart") then
			return
		end

		local position = humanoidRootPart.Position
		local startMatchHitbox = kingsApprentice.StartMatchHitbox
		local pointToObjectSpace = startMatchHitbox.CFrame:PointToObjectSpace(position)
		local v3 = startMatchHitbox.Size * 0.5
		local v4

		if math.abs(pointToObjectSpace.X) <= v3.X and math.abs(pointToObjectSpace.Z) <= v3.Z then
			v4 = math.abs(pointToObjectSpace.Y) <= v3.Y + 15
		else
			v4 = false
		end

		if not v4 then
			return
		end

		v = true
		stopCircleAura() -- equivalent call inferred; original call site unknown
		object:FireServer("StartMatch")
		toggleModelTransparency(kingsApprentice.Visual, 1)
	end)
	object.Trove:Add(function()
		heartbeatConnection:Disconnect()
	end)
	object.Trove:Add(stopReportStar)
	task.spawn(function()
		local success, result = pcall(function()
			return object:InvokeServer("State")
		end)

		if success and typeof(result) == "table" and result.Won and not object.Completed then
			markWon(object) -- equivalent call inferred; original call site unknown
		end
	end)
end

function KingSApprentice.OnComplete(_)
	if not flag2 then
		return
	end

	flag2 = false
	pcall(function()
		CompassTracker.removeTracker("KINGS_APPRENTICE_REPORT")
	end)
end

KingSApprentice.RemoteEvents = {
	MatchStarted = function(_)
		v = true
		stopCircleAura() -- equivalent call inferred; original call site unknown
		stopCompass() -- equivalent call inferred; original call site unknown
		Sound:Play("ColosseumBonusMoments.BF_GladiatorChallenge_Start_01")
		startCheerLoop() -- equivalent call inferred; original call site unknown
	end,
	Interact = function(_)
		toggleModelTransparency(kingsApprentice.Visual)
		startCompass() -- equivalent call inferred; original call site unknown
		startCircleAura() -- equivalent call inferred; original call site unknown
	end,
	WaveCleared = function(_)
		Sound:Play(frozen[math.random(1, #frozen)])
	end,
	MatchWon = function(p)
		if p.Progress == 1 then
			return
		end

		p.Progress = 1
		v = false
		count += 1
		stopCircleAura() -- equivalent call inferred; original call site unknown
		stopCompass() -- equivalent call inferred; original call site unknown
		toggleModelTransparency(kingsApprentice.Visual, 1)
		playCrowdSound("rbxassetid://126615573673174")
		startReportStar() -- equivalent call inferred; original call site unknown
	end,
	Reset = function(_)
		v = false
		count += 1
		playCrowdSound("rbxassetid://140141868547789")
		stopCircleAura() -- equivalent call inferred; original call site unknown
		stopCompass() -- equivalent call inferred; original call site unknown
		toggleModelTransparency(kingsApprentice.Visual, 1)
	end
}
return KingSApprentice