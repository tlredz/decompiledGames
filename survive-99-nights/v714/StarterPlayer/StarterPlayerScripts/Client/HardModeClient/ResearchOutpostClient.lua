local ResearchOutpostClient = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
local random = Random.new()
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local CollectionService = game:GetService("CollectionService")
local flag = false
local v = nil
local v2 = {
	["true"] = {
		Color = Color3.fromRGB(255, 60, 60),
		Material = Enum.Material.Neon
	},
	["false"] = {
		Color = Color3.fromRGB(80, 0, 0),
		Material = Enum.Material.Glass
	}
}

local function Tween(p, p2, p3)
	local tween = TweenService:Create(p, p2, p3)
	tween:Play()
	tween:Destroy()
end

local function RandomNumber(p, p2)
	return math.random(p * 1000, p2 * 1000) / 1000
end

local function RescaleParticle(state, p)
	state.Speed = NumberRange.new(state.Speed.Min * p, state.Speed.Max * p)
	state.Acceleration *= p
	local keypoints = state.Size.Keypoints
	local numberSequenceKeypoints = {}

	for i = 1, #keypoints do
		table.insert(
			numberSequenceKeypoints,
			NumberSequenceKeypoint.new(keypoints[i].Time, keypoints[i].Value * p, keypoints[i].Envelope * p)
		)
	end

	state.Size = NumberSequence.new(numberSequenceKeypoints)
end

function ToggleEmergencyLights(items)
	for _, item in pairs(items) do
		if not item:FindFirstChild("Light") then
			continue
		end

		item.Light.Color = v2[tostring(true)].Color
		item.Light.Material = v2[tostring(true)].Material

		for _, child in pairs(item.Light.LightPoint:GetChildren()) do
			if child:IsA("ParticleEmitter") or child:IsA("Light") then
				child.Enabled = true
			end
		end
	end
end

function ResearchOutpostClient.TransformResearchOutpost()
	if flag then
		return
	end

	flag = true

	if not v then
		repeat
			wait(1)
		until v
	end

	for _, child in pairs(v.AmbientEmissionArea_Inside:GetChildren()) do
		child.Enabled = true
	end

	for _, child in pairs(v.AmbientEmissionArea_Outside:GetChildren()) do
		child.Enabled = true
	end

	v.MusicEmitter:AddTag("MusicEmitter")
	local children = v.EmergencyLights:GetChildren()
	ToggleEmergencyLights(children)

	for _, v3 in pairs(CollectionService:GetTagged("ResearchFacilityLights")) do
		v3.Enabled = true
	end

	task.spawn(function()
		while true do
			wait(2)

			for _, v3 in pairs(CollectionService:GetTagged("ResearchBlinky")) do
				v3.Color = Color3.fromRGB(255, 0, 4)
			end

			wait(2)

			for _, v3 in pairs(CollectionService:GetTagged("ResearchBlinky")) do
				v3.Color = Color3.fromRGB(255, 255, 0)
			end
		end
	end)
end

Client.Events.FirstHardmodeLeverPulled:Connect(function()
	task.spawn(function()
		Client.UtilityAlec.preload(game.ReplicatedStorage.Assets.CutsceneSets:FindFirstChild("HardmodeCutscene").Animations:GetChildren())
		Client.UtilityAlec.preload(game.ReplicatedStorage.Assets.CutsceneSets:FindFirstChild("HardmodeCutscene").Sounds:GetChildren())
	end)
end)
local v3 = true

function ResearchOutpostClient.PullLever(p)
	if not v3 then
		Client.Events.RequestActivateHardModeLever:FireServer(p)
		return
	end

	local hardmodeVote = Client.Interface.HardmodeVote
	hardmodeVote.Visible = true
	hardmodeVote.yes.Activated:Connect(function()
		Client.Events.RequestActivateHardModeLever:FireServer(p)
		hardmodeVote.Visible = false
		Client.Sound.Play("CloseButton")
	end)
	hardmodeVote.no.Activated:Connect(function()
		v3 = false
		hardmodeVote.Visible = false
		Client.Sound.Play("CloseButton")
	end)
end

function ResearchOutpostClient.OpenCrate(instance, flag2: boolean, flag3: boolean)
	local pivot = instance.ChestLid:GetPivot()
	instance.ChestLid:PivotTo(pivot * CFrame.Angles(-1.3089969389957472, 0, 0))

	if flag2 then
		return
	end

	Client.Sound.Play("OpenHardModeCrate", {
		Volume = 0.25,
		Replicate = true,
		ReplicationProperties = {
			Instance = localPlayer.Character.Head,
			Volume = 0.15
		}
	})
	local pivot2 = instance:GetPivot()
	Client.Utility.SpawnParticles("OpenHardModeCrate", pivot2)

	if not flag3 then
		Client.Events.RequestOpenItemChest:FireServer(instance)
	end
end

Client.Events.VisualOpenHardModeCrate:Connect(function(p)
	ResearchOutpostClient.OpenCrate(p, false, true)
end)

function VoteTerminalAdded(instance)
	local function update()
		local proximityInteraction = instance:WaitForChild("Lever"):WaitForChild("ProximityAttachment"):WaitForChild("ProximityInteraction")

		if instance:GetAttribute("UserId") == localPlayer.UserId then
			instance:AddTag("Interaction")
			proximityInteraction.Enabled = true
		else
			instance:RemoveTag("Interaction")
			proximityInteraction.Enabled = false
		end
	end

	instance:GetAttributeChangedSignal("UserId"):Connect(update)
	update()
end

local v4 = {
	CorruptionDial = function(instance)
		local dial = instance:WaitForChild("Screen"):WaitForChild("SurfaceGui"):WaitForChild("Frame"):WaitForChild("Background"):WaitForChild("Dial")
		local v5 = nil
		local number = random:NextNumber()

		if workspace:GetAttribute("CorruptionLevel") == nil then
			task.spawn(function()
				workspace:GetAttributeChangedSignal("CorruptionLevel"):Wait()
				Client.TweenModule.new(function(p)
					v5 = p
				end, 0.3):Play()
				task.wait(5)
				Client.TweenModule.new(function(p)
					v5 = 1 - p
				end, 5, "Quad", "InOut"):Play()
				task.wait(5)
				v5 = nil
			end)
		end

		task.spawn(function()
			local total = 0

			while true do
				dial.Rotation = -135 + 300 * ((v5 or (workspace:GetAttribute("CorruptionLevel") or 0) / 100) + math.noise(
					number,
					total * 6
				) * 0.03)
				total += RunService.RenderStepped:Wait()
			end
		end)
	end
}

function ResearchOutpostAdded(p)
	if p.Parent == workspace.Map.Landmarks then
		v = p
	end
end

function ScreenAdded(instance)
	if not instance:IsDescendantOf(workspace) then
		return
	end

	local screenType = instance:GetAttribute("ScreenType")

	if screenType and v4[screenType] then
		v4[screenType](instance)
	end
end

function ResearchOutpostClient.Init()
	Client.Utility.ForAllTagged("HardModeScreen", ScreenAdded)
	Client.Utility.ForAllTagged("ResearchOutpost", ResearchOutpostAdded)
end

return ResearchOutpostClient