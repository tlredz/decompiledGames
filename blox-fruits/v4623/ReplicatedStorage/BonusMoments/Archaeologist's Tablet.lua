local createVector = vector.create
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local ModelUtil = require(game.ReplicatedStorage.Modules.ModelUtil)
local CameraShaker = require(game.ReplicatedStorage.Util.CameraShaker)
require(game.ReplicatedStorage.Controllers.BonusMomentsController.Types)
local Sound = require(game.ReplicatedStorage.Util.Sound)
local color = Color3.fromRGB(110, 221, 255)
local color2 = Color3.fromRGB(0, 49, 65)
local v = {
	Magnitude = 1.4,
	Roughness = 8,
	FadeIn = 0.05,
	FadeOut = 0.45,
	PositionInfluence = createVector(0.12, 0.2, 0.12),
	RotationInfluence = createVector(0.35, 0.25, 0.35)
}
local v2 = {
	Magnitude = 6,
	Roughness = 14,
	FadeIn = 0,
	FadeOut = 0.8,
	PositionInfluence = createVector(0.25, 0.4, 0.25),
	RotationInfluence = createVector(1, 0.7, 0.8)
}
local frozen = table.freeze({
	"DesertBonusMoments.BF_DesertBonus_Punch_Rock_Gravel_SandFall_01",
	"DesertBonusMoments.BF_DesertBonus_Punch_Rock_Gravel_SandFall_03",
	"DesertBonusMoments.BF_DesertBonus_Punch_Rock_Gravel_SandFall_05",
	"DesertBonusMoments.BF_DesertBonus_Punch_Rock_Gravel_SandFall_07",
	"DesertBonusMoments.BF_DesertBonus_Punch_Rock_Gravel_SandFall_09"
})
local frozen2 = table.freeze({
	"DesertBonusMoments.BF_DesertBonus_Rock_FullyCleaned_01",
	"DesertBonusMoments.BF_DesertBonus_Rock_FullyCleaned_03",
	"DesertBonusMoments.BF_DesertBonus_Rock_FullyCleaned_05",
	"DesertBonusMoments.BF_DesertBonus_Rock_FullyCleaned_07",
	"DesertBonusMoments.BF_DesertBonus_Rock_FullyCleaned_10"
})
local frozen3 = table.freeze({
	"DesertBonusMoments.BF_DesertBonus_Stone_Puzzle_Complete_Animation_01",
	"DesertBonusMoments.BF_DesertBonus_Stone_Puzzle_Complete_Animation_02",
	"DesertBonusMoments.BF_DesertBonus_Stone_Puzzle_Complete_Animation_03"
})
local archaeologistsTablet = script["Archaeologist's Tablet"]
local pivot = archaeologistsTablet:GetPivot()
local v3 = pivot * CFrame.new(0, 9, 0)
local pillars = archaeologistsTablet.Pillars
local count = 0
local v4 = nil

local function playRandomSound(list, p)
	return Sound:Play(list[math.random(1, #list)], p)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function stopAmbience()
	if v4 then
		Sound:Kill(v4)
		v4 = nil
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function startAmbience()
	if v4 then
		return
	end

	local v5 = Sound:Play(
		"DesertBonusMoments.BF_DesertBonus_Stone_Puzzle_Completed_Ambience_01",
		archaeologistsTablet.CircularPad.CenterStone
	)
	v5.Looped = true
	v4 = v5
end

local v5 = {
	[archaeologistsTablet.CircularPad] = pivot:ToObjectSpace(archaeologistsTablet.CircularPad:GetPivot())
}

for _, model in pillars:GetChildren() do
	if model:IsA("Model") then
		v5[model] = pivot:ToObjectSpace(model:GetPivot())
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function placeAssembly(cframe: CFrame)
	for k, v6 in v5 do
		k:PivotTo(cframe * v6)
	end
end

local function countProgress()
	local count2 = 0

	for _, child in pillars:GetChildren() do
		if (child:GetAttribute("NumHits") or 0) >= 3 then
			count2 += 1
		end
	end

	return count2
end

local function setGlowState(folder, flag: boolean)
	for _, part in folder:GetDescendants() do
		if not ((part.Name == "Glow" or part.Name == "Rune") and part:IsA("BasePart")) then
			continue
		end

		for _, child in part:GetChildren() do
			if child.Name == "GlowParticle" then
				child:Destroy()
			end
		end

		if flag then
			part.Material = Enum.Material.Neon
			TweenService:Create(part, TweenInfo.new(0.3), {
				Color = color
			}):Play()

			for _, child in script.GlowParticles:GetChildren() do
				local clone = child:Clone()
				clone.Name = "GlowParticle"
				clone.Parent = part
			end
		else
			part.Material = Enum.Material.Slate
			TweenService:Create(part, TweenInfo.new(0.3), {
				Color = color2
			}):Play()
		end
	end
end

local function getOrderedPillars()
	local models = {}

	for _, model in pillars:GetChildren() do
		if model:IsA("Model") then
			table.insert(models, model)
		end
	end

	table.sort(models, function(a, b)
		return (tonumber(string.match(a.Name, "%d+")) or 0) < (tonumber(string.match(b.Name, "%d+")) or 0)
	end)
	return models
end

local function tweenNumber(p: number, p2, p3, fn)
	local total = 0

	while total < p do
		total += task.wait()
		fn(TweenService:GetValue(math.min(total / p, 1), p2, p3))
	end

	fn(1)
end

local function emitSmashDust(pillar)
	local stone = pillar:FindFirstChild("Stone")
	local hitParticleAttachment = stone and stone:FindFirstChild("HitParticleAttachment")
	local sandSplash = hitParticleAttachment and hitParticleAttachment:FindFirstChild("SandSplash")

	if sandSplash and sandSplash:IsA("ParticleEmitter") then
		sandSplash:Emit(sandSplash.Rate)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function playShake(data, position: Vector3)
	local currentCamera = workspace.CurrentCamera

	if not currentCamera then
		return
	end

	local v6 = 1 - math.clamp(((currentCamera.CFrame.Position - position).Magnitude - 70) / 230, 0, 1)

	if v6 <= 0 then
		return
	end

	CameraShaker:ShakeOnce(
		data.Magnitude * v6,
		data.Roughness,
		data.FadeIn,
		data.FadeOut,
		data.PositionInfluence,
		data.RotationInfluence
	)
end

local function runAirborneSequence(items, p: number)
	local position = archaeologistsTablet.CircularPad.CenterStone.Position
	local lastTime = os.clock()
	local v6 = {}
	local v7 = 0

	for k, item in items do
		v6[k] = {
			pillar = item,
			home = item:GetPivot(),
			phase = k * 0.8,
			lift = 0,
			sway = 0
		}
	end

	local heartbeatConnection = RunService.Heartbeat:Connect(function()
		local v8 = os.clock() - lastTime
		local v9 = CFrame.new(position) * CFrame.Angles(0, v7, 0) * CFrame.new(-position)

		for _, v10 in v6 do
			local v11 = 0.55 * v10.sway
			local v12 = CFrame.new(
				math.sin(v8 * 1.1 + v10.phase) * v11,
				math.sin(v8 * 1.6 + v10.phase * 1.7) * 0.9 * v10.sway,
				math.cos(v8 * 1.1 * 0.8 + v10.phase) * v11
			) * CFrame.Angles(
				math.sin(v8 * 1.3 + v10.phase) * 0.06981317007977318 * v10.sway,
				math.sin(v8 * 1.3 * 0.7 + v10.phase) * 0.12217304763960307 * v10.sway,
				math.cos(v8 * 1.3 * 1.1 + v10.phase) * 0.06981317007977318 * v10.sway
			)
			v10.pillar:PivotTo(v9 * v10.home * CFrame.new(0, v10.lift, 0) * v12)
		end
	end)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function stop()
		heartbeatConnection:Disconnect()

		if p ~= count then
			return false
		end

		for _, v8 in v6 do
			v8.pillar:PivotTo(v8.home)
		end

		return true
	end

	for _, v8 in v6 do
		setGlowState(v8.pillar, true)
		playShake(v, v8.home.Position) -- equivalent call inferred; original call site unknown
		local v10 = v8
		task.spawn(function()
			tweenNumber(1.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, function(sway)
				v10.lift = 12 * sway
				v10.sway = sway
			end)
		end)
		task.wait(0.35)

		if p ~= count then
			return stop()
		end
	end

	task.wait(1.1)

	if p ~= count then
		return stop()
	end

	tweenNumber(4.5, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut, function(p2)
		v7 = 18.84955592153876 * p2
	end)
	v7 = 0
	task.wait(0.4)

	if p ~= count then
		return stop()
	end

	tweenNumber(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, function(p2)
		for _, v8 in v6 do
			v8.lift = 12 + 6 * p2
			v8.sway = 1 - p2 * 0.75
		end
	end)

	if p == count then
		task.wait(0.12)

		if p == count then
			tweenNumber(0.16, Enum.EasingStyle.Quart, Enum.EasingDirection.In, function(p2)
				for _, v8 in v6 do
					v8.lift = 18 * (1 - p2)
					v8.sway = 0.25 * (1 - p2)
				end
			end)

			if p == count then
				for _, v8 in v6 do
					v8.pillar:PivotTo(v8.home)
					emitSmashDust(v8.pillar)
				end

				playShake(v2, position) -- equivalent call inferred; original call site unknown
				return stop()
			end
		end
	end

	return stop()
end

-- equivalent calls inferred from this helper; original call sites unknown
local function reflectActivatedColor(completed)
	setGlowState(archaeologistsTablet, completed or countProgress() >= 8)
end

local function reflectPillarState(child, flag: boolean?)
	local numHits = child:GetAttribute("NumHits") or 0

	for i = 1, 3 do
		local v6 = i <= numHits
		local transparency = v6 and 1 or 0
		local part = child:FindFirstChild("SandLayer" .. tostring(i))

		if not (part and part:IsA("BasePart")) then
			continue
		end

		if flag then
			part.Transparency = transparency
		else
			TweenService:Create(part, TweenInfo.new(0.35), {
				Transparency = transparency
			}):Play()
		end

		part.CanCollide = not v6
	end
end

local ArchaeologistSTablet = {}
ArchaeologistSTablet.LoadWhenCompleted = true

function ArchaeologistSTablet.OnLoad(p)
	count += 1

	if p.Completed then
		for _, child in pillars:GetChildren() do
			child:SetAttribute("NumHits", 3)
		end

		placeAssembly(v3) -- equivalent call inferred; original call site unknown
	else
		for _, child in pillars:GetChildren() do
			child:SetAttribute("NumHits", 0)
		end

		placeAssembly(pivot) -- equivalent call inferred; original call site unknown
	end

	for _, child in pillars:GetChildren() do
		if not child.Stone:FindFirstChild("HitParticleAttachment") then
			local clone = script.HitParticleAttachment:Clone()
			clone.Parent = child.Stone
		end

		reflectPillarState(child, true)
	end

	reflectActivatedColor(p.Completed) -- equivalent call inferred; original call site unknown
	archaeologistsTablet.Parent = workspace
	stopAmbience() -- equivalent call inferred; original call site unknown

	if p.Completed then
		startAmbience() -- equivalent call inferred; original call site unknown
	end
end

ArchaeologistSTablet.RemoteEvents = {
	HitPillar = function(_, childName, numHits)
		local child = pillars:FindFirstChild(childName)

		if child then
			child:SetAttribute("NumHits", numHits)
			reflectPillarState(child)
			local sandSplash = child.Stone.HitParticleAttachment.SandSplash
			sandSplash:Emit(sandSplash.Rate, false)
			local position = child:GetPivot().Position

			if numHits >= 3 then
				local v6 = frozen2
				Sound:Play(v6[math.random(1, #v6)], position)
			else
				local v6 = frozen
				Sound:Play(v6[math.random(1, #v6)], position)
			end
		end
	end
}

function ArchaeologistSTablet.OnComplete(_, p, _)
	if p then
		count += 1
		local v6 = count
		local v7 = frozen3
		Sound:Play(v7[math.random(1, #v7)], nil)

		if not runAirborneSequence(getOrderedPillars(), v6) then
			return
		end

		archaeologistsTablet.CircularPad.CenterStone.SandSplash.Enabled = true
		ModelUtil.tweenModelCFrame(
			archaeologistsTablet,
			archaeologistsTablet:GetPivot() * CFrame.new(0, 9, 0),
			TweenInfo.new(4)
		)
		task.wait(4)
		archaeologistsTablet.CircularPad.CenterStone.SandSplash.Enabled = false

		if v6 ~= count then
			return
		end

		placeAssembly(v3) -- equivalent call inferred; original call site unknown
		setGlowState(archaeologistsTablet.CircularPad, true)
		startAmbience() -- equivalent call inferred; original call site unknown
		task.delay(0.5, function()
			if countProgress() >= 8 then
				local DialogueController = require(game.ReplicatedStorage.DialogueController)
				local v9 = DialogueController.new()
				v9:setTitle(Players.LocalPlayer.DisplayName)
				v9:addPage("Main", function(object)
					object:addText("Aha! So this is what the sand was hiding...")
					object:addText("I can't read a word of it, but these carvings are ancient. Some kind of study of power.")
					object:addText("The Desert Adventurer speaks with everyone who passes by these parts. He should hear about this.")
				end)
				v9:build()
				DialogueController.start(v9)
			end
		end)
	else
		stopAmbience() -- equivalent call inferred; original call site unknown
		reflectActivatedColor() -- equivalent call inferred; original call site unknown
	end
end

return ArchaeologistSTablet