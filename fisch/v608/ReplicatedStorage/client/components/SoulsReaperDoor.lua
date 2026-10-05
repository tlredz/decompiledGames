local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local modules = ReplicatedStorage:WaitForChild("shared").modules
local Factions = require(modules.Factions)
local legacyLocalPlayerData = require(ReplicatedStorage:WaitForChild("client").modules.legacyLocalPlayerData)
local packages = ReplicatedStorage:WaitForChild("packages")
local Component = require(packages.Component)
local Trove = require(packages.Trove)
local localPlayer = Players.LocalPlayer
local reputations = legacyLocalPlayerData.fetch():WaitForChild("Reputations")
local midasMates = reputations:WaitForChild("Midas' Mates")
local redMarlins = reputations:WaitForChild("Red Marlins")
local v = Component.new({
	Tag = "SoulsReaperDoor"
})

local function LerpToOriginal(sequence, p: number)
	local numberSequenceKeypoints = table.create(#sequence.Keypoints)

	for i, keypoint in ipairs(sequence.Keypoints) do
		local v2 = 1 - p * (1 - keypoint.Value)
		numberSequenceKeypoints[i] = NumberSequenceKeypoint.new(keypoint.Time, v2, keypoint.Envelope)
	end

	return NumberSequence.new(numberSequenceKeypoints)
end

local function RemapClamped(p, p2, p3, p4, p5)
	local v2 = math.clamp((p - p2) / (p3 - p2), 0, 1)
	return p4 + (p5 - p4) * v2
end

function v:ToggleVfx(enabled: boolean)
	local door = self.Instance:FindFirstChild("Door")
	local effects = door and door:FindFirstChild("Effects")
	local v2 = 0 + 1 * math.clamp((self.ElapsedTimeInArea - 0) / 1.9600000000000002, 0, 1)

	for _, descendant in effects:GetDescendants() do
		if not (descendant:IsA("PointLight") or descendant:IsA("ParticleEmitter") or descendant:IsA("Beam")) then
			continue
		end

		if descendant:IsA("Beam") then
			self.BeamTransparency[descendant] = self.BeamTransparency[descendant] or descendant.Transparency
			descendant.Transparency = LerpToOriginal(self.BeamTransparency[descendant], v2)
		else
			descendant.Enabled = enabled
		end
	end
end

function v:Setup()
	self.Setuped = true

	-- equivalent calls inferred from this helper; original call sites unknown
	local function timeLogic(lastIncrementValue: number)
		self.LastIncrementValue = lastIncrementValue
		self.ElapsedTimeInArea = math.clamp(self.ElapsedTimeInArea + lastIncrementValue, 0, 7)
	end

	local function renderLogic(_: number)
		if self.LastIncrementValue > 0 then
			self:ToggleVfx(true)
		elseif self.ElapsedTimeInArea <= 1.9600000000000002 then
			self:ToggleVfx(false)
		end

		local v2 = math.clamp(self.ElapsedTimeInArea / 7, 0, 1)
		self.Instance.Door.Effects.MainSound.Volume = v2 * 0.5
		local v3 = 0 + 1 * math.clamp((self.ElapsedTimeInArea - 4.97) / 2.0300000000000002, 0, 1)
		local lerped = CFrame.new(0, 0, 0):Lerp(CFrame.new(-2.8, 0, -3) * CFrame.Angles(0, -1.9198621771937625, 0), v3)
		self.Instance.Weld.C0 = lerped
		local v4 = self.ElapsedTimeInArea >= 4.97

		if v4 and not self._openSoundPlayed then
			self.Instance.Door.Effects.DoorSound:Play()
			self._openSoundPlayed = true
		end

		if not v4 and self._openSoundPlayed then
			self._openSoundPlayed = false
		end
	end

	self.Collector:Add(RunService.RenderStepped:Connect(function(dt: number)
		local character = localPlayer.Character
		local primaryPart = character and character.PrimaryPart

		if primaryPart then
			if (primaryPart.Position - self.Instance.Root.Door.Position).Magnitude <= 15 then
				timeLogic(dt) -- equivalent call inferred; original call site unknown
			else
				timeLogic(-dt) -- equivalent call inferred; original call site unknown
			end
		else
			timeLogic(-dt) -- equivalent call inferred; original call site unknown
		end

		renderLogic(dt)
	end))
end

function v:Construct()
	self.Setuped = false
	self.BeamTransparency = {}
	self.ElapsedTimeInArea = 0
	self.Collector = Trove.new()
end

function v:Start()
	self:ToggleVfx(false)

	local function canSetup()
		local v2 = not (midasMates.Value < Factions["Midas' Mates"].Ranks.Vaultkeeper.MinimumReputation)
		return not (redMarlins.Value < Factions["Red Marlins"].Ranks.Mythwalker.MinimumReputation) and v2
	end

	local v2 = not (midasMates.Value < Factions["Midas' Mates"].Ranks.Vaultkeeper.MinimumReputation)

	if redMarlins.Value < Factions["Red Marlins"].Ranks.Mythwalker.MinimumReputation then
		v2 = false
	end

	if v2 then
		return self:Setup()
	end

	self.Collector:Add(midasMates.Changed:Connect(function()
		if self.Setuped == true then
			return
		end

		local v3 = not (midasMates.Value < Factions["Midas' Mates"].Ranks.Vaultkeeper.MinimumReputation)

		if redMarlins.Value < Factions["Red Marlins"].Ranks.Mythwalker.MinimumReputation then
			v3 = false
		end

		if v3 then
			self:Setup()
		end
	end))
	self.Collector:Add(redMarlins.Changed:Connect(function()
		if self.Setuped == true then
			return
		end

		local v3 = not (midasMates.Value < Factions["Midas' Mates"].Ranks.Vaultkeeper.MinimumReputation)

		if redMarlins.Value < Factions["Red Marlins"].Ranks.Mythwalker.MinimumReputation then
			v3 = false
		end

		if v3 then
			self:Setup()
		end
	end))
end

function v.Stop(p)
	p.Collector:Destroy()
end

return v