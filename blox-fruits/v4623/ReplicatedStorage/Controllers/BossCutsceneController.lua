local createVector = vector.create
local Players = game:GetService("Players")
local Net = require(game.ReplicatedStorage.Modules.Net)
local CameraController = require(game.ReplicatedStorage.Controllers.CameraController)
local DialogueController = require(game.ReplicatedStorage.DialogueController)
local IrisLog = require(game.ReplicatedStorage.Util.IrisLog)
local Groups = require(game.ReplicatedStorage.Util.Sound.Groups)
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local Lighting = game:GetService("Lighting")
local BossCutsceneController = {
	forceReplay = false
}
local v = {}
local v2 = {}
local v3 = {}
local flag = false

-- equivalent calls inferred from this helper; original call sites unknown
local function getRoot(instance)
	return instance:FindFirstChild("HumanoidRootPart") or instance.PrimaryPart
end

local function isBoss(model)
	local isA = model:IsA("Model")

	if isA then
		if model:GetAttribute("IsBoss") == true then
			isA = not model:GetAttribute("RaidBoss")
		else
			isA = false
		end
	end

	return isA
end

local function isPlainBoss(instance)
	return instance:GetAttribute("BossPrimed") ~= true and instance:GetAttribute("BossIndicatorAwakened") ~= true
end

-- equivalent calls inferred from this helper; original call sites unknown
local function isAlive(instance)
	local humanoid = instance:FindFirstChildOfClass("Humanoid")

	if humanoid then
		return humanoid.Health > 0
	end

	local health = instance:FindFirstChild("Health")
	return not (health and health:IsA("IntValue")) or health.Value > 0
end

local function hasLineOfSight(humanoidRootPart, root, k)
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	local characters = { k }
	local character = Players.LocalPlayer.Character

	if character then
		table.insert(characters, character)
	end

	raycastParams.FilterDescendantsInstances = characters
	return workspace:Raycast(humanoidRootPart.Position, root.Position - humanoidRootPart.Position, raycastParams) == nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function revealCFrame(instance, p: number, p2: number)
	local v4 = instance.Position + createVector(0, 3, 0)
	local v5 = v4 + instance.CFrame.LookVector * p + Vector3.new(0, p2, 0)
	return CFrame.lookAt(v5, v4)
end

local function playBassDrop(parent)
	local sound = Instance.new("Sound")
	sound.Name = "BossBassDrop"
	sound.SoundId = "rbxassetid://9043179511"
	sound.Volume = 1
	sound.RollOffMode = Enum.RollOffMode.InverseTapered
	sound.RollOffMinDistance = 20
	sound.RollOffMaxDistance = 400
	sound.Parent = parent
	Groups.assign(sound, "LowPriority")
	sound:Play()
	Debris:AddItem(sound, 10)
end

local function darkenLighting()
	local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
	colorCorrectionEffect.Name = "BossCinematicDark"
	colorCorrectionEffect.Brightness = 0
	colorCorrectionEffect.Contrast = 0
	colorCorrectionEffect.Saturation = 0
	colorCorrectionEffect.Parent = Lighting
	TweenService:Create(colorCorrectionEffect, TweenInfo.new(0.4), {
		Brightness = -0.35,
		Contrast = 0.15,
		Saturation = -0.5
	}):Play()
	return colorCorrectionEffect
end

local function findFaceMask(folder)
	for _, accessory in folder:GetChildren() do
		if not accessory:IsA("Accessory") then
			continue
		end

		local handle = accessory:FindFirstChild("Handle")

		if handle and handle:IsA("BasePart") and handle:FindFirstChild("HatAttachment") then
			return handle
		end
	end

	return nil
end

local function lightUpEyes(folder)
	local bossCutsceneAssets = game.ReplicatedStorage:FindFirstChild("BossCutsceneAssets")

	if not bossCutsceneAssets then
		return function() end
	end

	local clones = {}

	local function spawnGlow(child, parent)
		local clone = child:Clone()

		for _, descendant in clone:GetDescendants() do
			if descendant:IsA("PointLight") then
				local brightness = descendant.Brightness
				descendant.Brightness = 0
				TweenService:Create(descendant, TweenInfo.new(0.4), {
					Brightness = brightness
				}):Play()
			elseif descendant:IsA("ParticleEmitter") then
				descendant.Enabled = true
			end
		end

		clone.Parent = parent
		table.insert(clones, clone)
		return clone
	end

	local v4 = {}

	for _, attachment in folder:GetDescendants() do
		if not attachment:IsA("Attachment") then
			continue
		end

		local name = attachment.Name

		if name == "Eye1" or name == "Eyes1" then
			v4["1"] = attachment
		elseif name == "Eye2" or name == "Eyes2" then
			v4["2"] = attachment
		end
	end

	if v4["1"] or v4["2"] then
		for _, v5 in {
			{ "1", "Glow1" },
			{ "2", "Glow2" }
		} do
			local v6 = v4[v5[1]]
			local child = bossCutsceneAssets:FindFirstChild(v5[2])
			local parent = v6 and v6.Parent

			if not (v6 and child and parent and parent:IsA("BasePart")) then
				continue
			end

			local attachment = spawnGlow(child, parent)

			if attachment:IsA("Attachment") then
				attachment.CFrame = v6.CFrame
			end
		end
	else
		local head = folder:FindFirstChild("Head")

		if head and head:IsA("BasePart") and not (head:FindFirstChild("Glow1") or findFaceMask(folder)) then
			local v5 = head.Size.Z * 0.4
			local v6 = head.Size.Y * 0.2

			for _, childName in { "Glow1", "Glow2" } do
				local child = bossCutsceneAssets:FindFirstChild(childName)

				if not child then
					continue
				end

				local attachment = spawnGlow(child, head)

				if attachment:IsA("Attachment") then
					attachment.Position += Vector3.new(0, v6, -v5)
				end
			end
		end
	end

	return function()
		for _, folder2 in clones do
			for _, descendant in folder2:GetDescendants() do
				if descendant:IsA("PointLight") then
					TweenService:Create(descendant, TweenInfo.new(0.5), {
						Brightness = 0
					}):Play()
				elseif descendant:IsA("ParticleEmitter") then
					descendant.Enabled = false
				end
			end

			Debris:AddItem(folder2, 1)
		end
	end
end

local function clearCinematicFilters()
	for _, child in Lighting:GetChildren() do
		if child.Name == "BossCinematicDark" then
			child:Destroy()
		end
	end
end

local function localPlayerAlive()
	local character = Players.LocalPlayer.Character

	if character == nil or character.Parent == nil then
		return false
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")

	if humanoid then
		return humanoid.Health > 0
	end

	local health = character:FindFirstChild("Health")
	return not (health and health:IsA("IntValue")) or health.Value > 0
end

local function playCutscene(parent, p2)
	clearCinematicFilters()
	playBassDrop(parent)
	local v4 = darkenLighting()
	local v5 = nil
	local v6 = CameraController.new(workspace.CurrentCamera, 1, 0.35)
	local success, result = pcall(function()
		local total = 0

		while total < 2.2 and parent.Parent do
			local character = Players.LocalPlayer.Character
			local v7

			if character == nil or character.Parent == nil then
				v7 = false
			else
				local humanoid = character:FindFirstChildOfClass("Humanoid")

				if humanoid then
					v7 = humanoid.Health > 0
				else
					local health = character:FindFirstChild("Health")
					v7 = not (health and health:IsA("IntValue")) or health.Value > 0
				end
			end

			if not v7 then
				break
			end

			local v8 = math.clamp(total / 1.2, 0, 1)

			if not v5 and v8 >= 0.6 then
				v5 = lightUpEyes(p2)
			end

			v6.Animations:AnimateTo(revealCFrame(parent, 24 - v8 * 9, 9 - v8 * 5.5), 1, 2.2)
			total += task.wait()
		end

		v6:FadeOut(0.6)
	end)

	if not success then
		warn((`[BossCutscene] "{p2.Name}" ended early: {result}`))
	end

	if v5 then
		v5()
	end

	TweenService:Create(v4, TweenInfo.new(0.6), {
		Brightness = 0,
		Contrast = 0,
		Saturation = 0
	}):Play()
	Debris:AddItem(v4, 0.75)
end

local function tryTrigger(instance, p: string)
	if not flag then
		local v4

		if instance:GetAttribute("BossPrimed") == true then
			v4 = false
		else
			v4 = instance:GetAttribute("BossIndicatorAwakened") ~= true
		end

		if v4 then
			flag = true
			local result

			if BossCutsceneController.forceReplay then
				result = true
			else
				v2[p] = true
				local remoteFunction = Net:RemoteFunction("BossCutscene")
				local success
				success, result = pcall(function()
					return remoteFunction:InvokeServer(instance)
				end)

				if not success then
					v2[p] = nil
					flag = false
					return
				end
			end

			if result then
				local root = getRoot(instance) -- equivalent call inferred; original call site unknown

				if root and instance.Parent then
					-- equivalent call inferred; original call site unknown
					if isAlive(instance) then
						v3[instance] = tick()
						playCutscene(root, instance)
					end
				end
			end

			flag = false
		end
	end
end

function BossCutsceneController.reset()
	table.clear(v2)
	table.clear(v3)
	flag = false
	clearCinematicFilters()
end

function BossCutsceneController.playNearest()
	if flag then
		return
	end

	local character = Players.LocalPlayer.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
	local v4 = 1e999
	local v5 = nil
	local v6 = nil

	for k in v do
		if not k.Parent then
			continue
		end

		-- equivalent call inferred; original call site unknown
		if not isAlive(k) then
			continue
		end

		local root = getRoot(k) -- equivalent call inferred; original call site unknown

		if not root then
			continue
		end

		local v7 = not humanoidRootPart and 0 or (root.Position - humanoidRootPart.Position).Magnitude

		if not (v7 < v4) then
			continue
		end

		v6 = root
		v5 = k
		v4 = v7
	end

	if v5 and v6 then
		flag = true
		v3[v5] = tick()
		playCutscene(v6, v5)
		flag = false
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function trackChild(model)
	local isA = model:IsA("Model")

	if isA then
		if model:GetAttribute("IsBoss") == true then
			isA = not model:GetAttribute("RaidBoss")
		else
			isA = false
		end
	end

	if isA then
		v[model] = true
	end
end

function BossCutsceneController.OnStart()
	local bossCutscene = IrisLog.new("Boss Cutscene", "Developer", {
		Hidden = true
	})
	bossCutscene:AppendHeader(bossCutscene:Checkbox("Force replay (ignore first-seen)", function(forceReplay: boolean)
		BossCutsceneController.forceReplay = forceReplay
	end))
	bossCutscene:AppendHeader(bossCutscene:Button("Reset (re-arm encounter)", function()
		BossCutsceneController.reset()
	end))
	bossCutscene:AppendHeader(bossCutscene:Button("Play nearest boss now", function()
		BossCutsceneController.playNearest()
	end))

	for _, v4 in { workspace.Enemies, workspace.SeaBeasts } do
		v4.ChildAdded:Connect(trackChild)
		v4.ChildRemoved:Connect(function(child)
			v[child] = nil
			v3[child] = nil
		end)

		for _, child in v4:GetChildren() do
			trackChild(child) -- equivalent call inferred; original call site unknown
		end
	end

	task.spawn(function()
		while task.wait(0.25) do
			if flag or DialogueController.Active then
				continue
			end

			local character = Players.LocalPlayer.Character
			local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				continue
			end

			for k in v do
				if k.Parent then
					if BossCutsceneController.forceReplay then
						if tick() - (v3[k] or 0) < 5 then
							continue
						end
					elseif v2[k.Name] then
						continue
					end

					local root = getRoot(k) -- equivalent call inferred; original call site unknown

					if root then
						-- equivalent call inferred; original call site unknown
						if isAlive(k) then
							local v4

							if k:GetAttribute("BossPrimed") == true then
								v4 = false
							else
								v4 = k:GetAttribute("BossIndicatorAwakened") ~= true
							end

							if v4 and (root.Position - humanoidRootPart.Position).Magnitude <= 120 and hasLineOfSight(
								humanoidRootPart,
								root,
								k
							) then
								task.spawn(tryTrigger, k, k.Name)
								break
							end
						end
					end
				else
					v[k] = nil
				end
			end
		end
	end)
end

return BossCutsceneController