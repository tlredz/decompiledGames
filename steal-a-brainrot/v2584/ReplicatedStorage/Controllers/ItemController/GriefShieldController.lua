local createVector = vector.create
local ContentProvider = game:GetService("ContentProvider")
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local packages = ReplicatedStorage:WaitForChild("Packages")
local Observers = require(packages.Observers)
local Net = require(packages.Net)
local SoundController = require(ReplicatedStorage.Controllers.SoundController)
local SharedEventUtils = require(ReplicatedStorage.Shared.SharedEventUtils)
local GriefShieldFlags = require(ReplicatedStorage.Shared.Flags.GriefShieldFlags)
local griefShieldForcefield = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Tools"):WaitForChild("Grief Shield"):WaitForChild("GriefShieldForcefield")
local localPlayer = Players.LocalPlayer
local remoteEvent = Net:RemoteEvent("UseItem")
local color = Color3.fromRGB(0, 235, 255)
local v2 = {
	"ColorMapContent",
	"MetalnessMapContent",
	"NormalMapContent",
	"RoughnessMapContent"
}

local function createSoundTemplate(soundId: string)
	local sound = Instance.new("Sound")
	sound.SoundId = soundId
	sound.Volume = 0.6
	sound.RollOffMode = Enum.RollOffMode.InverseTapered
	sound.RollOffMinDistance = 10
	sound.RollOffMaxDistance = 150
	local toolsSounds = SoundService:FindFirstChild("ToolsSounds")

	if toolsSounds and toolsSounds:IsA("SoundGroup") then
		sound.SoundGroup = toolsSounds
	end

	return sound
end

local sound = Instance.new("Sound")
sound.SoundId = "rbxassetid://84948211996446"
sound.Volume = 0.6
sound.RollOffMode = Enum.RollOffMode.InverseTapered
sound.RollOffMinDistance = 10
sound.RollOffMaxDistance = 150
local toolsSounds = SoundService:FindFirstChild("ToolsSounds")

if toolsSounds and toolsSounds:IsA("SoundGroup") then
	sound.SoundGroup = toolsSounds
end

local sound2 = Instance.new("Sound")
sound2.SoundId = "rbxassetid://140063375998939"
sound2.Volume = 0.6
sound2.RollOffMode = Enum.RollOffMode.InverseTapered
sound2.RollOffMinDistance = 10
sound2.RollOffMaxDistance = 150
local toolsSounds2 = SoundService:FindFirstChild("ToolsSounds")

if toolsSounds2 and toolsSounds2:IsA("SoundGroup") then
	sound2.SoundGroup = toolsSounds2
end

local v3 = {}

for _, soundId in { "rbxassetid://97485137367830", "rbxassetid://134979913080761" } do
	local sound3 = Instance.new("Sound")
	sound3.SoundId = soundId
	sound3.Volume = 0.6
	sound3.RollOffMode = Enum.RollOffMode.InverseTapered
	sound3.RollOffMinDistance = 10
	sound3.RollOffMaxDistance = 150
	local toolsSounds3 = SoundService:FindFirstChild("ToolsSounds")

	if toolsSounds3 and toolsSounds3:IsA("SoundGroup") then
		sound3.SoundGroup = toolsSounds3
	end

	table.insert(v3, sound3)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function playSound(p, position: Vector3)
	SoundController:PlaySound(p, position, false)
end

local function isShieldActive(instance)
	local griefShieldEndTime = instance:GetAttribute("GriefShieldEndTime")
	return type(griefShieldEndTime) == "number" and workspace:GetServerTimeNow() < griefShieldEndTime
end

-- equivalent calls inferred from this helper; original call sites unknown
local function isHiddenFromLocalPlayer(player)
	return player:GetAttribute("GriefShieldExemptUserId") == localPlayer.UserId
end

local function wasJustCracked(instance)
	local griefShieldCracked = instance:GetAttribute("GriefShieldCracked")
	return type(griefShieldCracked) == "number" and workspace:GetServerTimeNow() - griefShieldCracked < 1
end

local function preloadForcefield()
	local v4 = { griefShieldForcefield, sound, sound2 }

	for _, v5 in v3 do
		table.insert(v4, v5)
	end

	ContentProvider:PreloadAsync(v4)
	local v5 = {}
	local uris = {}

	for _, v6 in griefShieldForcefield:QueryDescendants("SurfaceAppearance") do
		for _, v7 in v2 do
			local v8 = v6[v7]

			if typeof(v8) ~= "Content" then
				continue
			end

			local uri = v8.Uri

			if not uri or uri == "" or v5[uri] then
				continue
			end

			v5[uri] = true
			table.insert(uris, uri)
		end
	end

	if #uris == 0 then
		return
	end

	ContentProvider:PreloadAsync(uris)
end

local function warmupForcefield()
	local clone = griefShieldForcefield:Clone()
	local effect = clone:FindFirstChild("Effect")

	if not (effect and effect:IsA("BasePart")) then
		clone:Destroy()
		return
	end

	local surfaceAppearances = effect:FindFirstChild("SurfaceAppearances")

	if not surfaceAppearances then
		clone:Destroy()
		return
	end

	local surfaceAppearances2 = {}

	for i = 1, #surfaceAppearances:GetChildren() do
		local surfaceAppearance = surfaceAppearances:FindFirstChild((tostring(i)))

		if surfaceAppearance and surfaceAppearance:IsA("SurfaceAppearance") then
			table.insert(surfaceAppearances2, surfaceAppearance)
		end
	end

	if #surfaceAppearances2 == 0 then
		clone:Destroy()
		return
	end

	local surfaceAppearance = effect:FindFirstChildOfClass("SurfaceAppearance")

	if surfaceAppearance then
		surfaceAppearance:Destroy()
	end

	for _, v4 in clone:QueryDescendants("BasePart"), nil, nil do
		v4.Anchored = true
		v4.CanCollide = false
		v4.CanQuery = false
		v4.CanTouch = false
		v4.CastShadow = false
		v4.Transparency = 0.99
	end

	clone:PivotTo(CFrame.new(0, 10000, 0))
	clone.Parent = workspace
	local preRenderConnection = nil

	-- equivalent calls inferred from this helper; original call sites unknown
	local function finish()
		if preRenderConnection then
			preRenderConnection:Disconnect()
		end

		clone:Destroy()
	end

	local count = 0
	local v4 = nil
	preRenderConnection = RunService.PreRender:Connect(function()
		local currentCamera = workspace.CurrentCamera

		if not currentCamera then
			return
		end

		clone:PivotTo(currentCamera.CFrame * CFrame.new(0, 0, -8))

		if count >= #surfaceAppearances2 then
			finish() -- equivalent call inferred; original call site unknown
		else
			count += 1

			if v4 then
				v4.Parent = surfaceAppearances
			end

			v4 = surfaceAppearances2[count]
			surfaceAppearances2[count].Parent = effect
		end
	end)
	task.delay(10, finish)
end

local function animateSurface(effect)
	local surfaceAppearances = effect:FindFirstChild("SurfaceAppearances")

	if not surfaceAppearances then
		return function() end
	end

	local surfaceAppearances2 = {}

	for i = 1, #surfaceAppearances:GetChildren() do
		local surfaceAppearance = surfaceAppearances:FindFirstChild((tostring(i)))

		if surfaceAppearance and surfaceAppearance:IsA("SurfaceAppearance") then
			table.insert(surfaceAppearances2, surfaceAppearance)
		end
	end

	if #surfaceAppearances2 == 0 then
		return function() end
	end

	local surfaceAppearance = effect:FindFirstChildOfClass("SurfaceAppearance")

	if surfaceAppearance then
		surfaceAppearance:Destroy()
	end

	local v4 = nil
	local preRenderConnection = RunService.PreRender:Connect(function()
		local v5 = surfaceAppearances2[math.floor(os.clock() * 24) % #surfaceAppearances2 + 1]

		if v5 == v4 then
			return
		end

		if v4 then
			v4.Parent = surfaceAppearances
		end

		v5.Parent = effect
		v4 = v5
	end)
	return function()
		preRenderConnection:Disconnect()
	end
end

local function createBubble(character)
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if not (humanoidRootPart and humanoidRootPart:IsA("BasePart")) then
		return nil
	end

	local clone = griefShieldForcefield:Clone()
	local cframe = CFrame.new(clone:GetPivot().Position)
	local v4 = {}
	local v5 = {}
	local v6 = {}
	local tweens = {}

	for _, v7 in clone:QueryDescendants("BasePart"), nil, nil do
		local objectSpace = cframe:ToObjectSpace(v7.CFrame)
		local v8 = v7.Size * 1.2
		table.insert(v4, v7)
		table.insert(v5, CFrame.new(objectSpace.Position * 1.2) * objectSpace.Rotation)
		table.insert(v6, v8)
		local transparency = v7.Transparency
		v7.Transparency = 1
		v7.Size = v8 * 0.2
		local tween = TweenService:Create(v7, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Transparency = transparency
		})
		tween:Play()
		table.insert(tweens, tween)
	end

	local effect = clone:FindFirstChild("Effect")
	local fn = not (effect and effect:IsA("BasePart")) and function() end or animateSurface(effect)
	clone:PivotTo(CFrame.new(humanoidRootPart:GetPivot().Position + createVector(0, 0, 0)))
	clone.Parent = workspace
	local lastTime = os.clock()
	local v7 = true
	local postSimulationConnection = RunService.PostSimulation:Connect(function()
		local cframe2 = CFrame.new(humanoidRootPart:GetPivot().Position + createVector(0, 0, 0))
		local v8

		if v7 then
			local v9 = math.min((os.clock() - lastTime) / 0.4, 1)
			v8 = 0.2 + 0.8 * TweenService:GetValue(v9, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
			v7 = v9 < 1
		else
			v8 = 1
		end

		for k, v9 in v4 do
			local v10 = v5[k]

			if v8 == 1 then
				if v9.Size ~= v6[k] then
					v9.Size = v6[k]
				end
			else
				v9.Size = v6[k] * v8
				v10 = CFrame.new(v10.Position * v8) * v10.Rotation
			end

			SharedEventUtils.pushPartCFrame(v9, cframe2 * v10)
		end
	end)
	local flag = false

	local function stop()
		if flag then
			return
		end

		flag = true
		postSimulationConnection:Disconnect()
		fn()

		for _, v8 in tweens do
			v8:Cancel()
		end
	end

	clone.Destroying:Once(stop)
	return {
		Model = clone,
		Stop = stop
	}
end

local function fadeBubble(p, flag: boolean)
	p.Stop()

	if flag then
		playSound(sound2, p.Model:GetPivot().Position) -- equivalent call inferred; original call site unknown
	end

	for _, v4 in p.Model:QueryDescendants("BasePart"), nil, nil do
		TweenService:Create(v4, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Transparency = 1
		}):Play()
	end

	Debris:AddItem(p.Model, 0.35)
end

local function crackBubble(p)
	p.Stop()
	local model = p.Model
	local position = model:GetPivot().Position
	local v4 = model:GetExtentsSize().X * 0.5

	for _, v5 in v3 do
		playSound(v5, position) -- equivalent call inferred; original call site unknown
	end

	for _, v5 in model:QueryDescendants("BasePart"), nil, nil do
		TweenService:Create(v5, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = v5.Size * 1.2,
			Transparency = 1
		}):Play()
	end

	for _ = 1, 24 do
		local unit = Vector3.new(math.random() * 2 - 1, math.random() * 0.8, math.random() * 2 - 1).Unit
		local part = Instance.new("Part")
		part.Name = "GriefShieldShard"
		part.Size = createVector(0.6, 0.9, 0.15)
		part.Color = color
		part.Material = Enum.Material.Glass
		part.Transparency = 0.2
		part.CanCollide = false
		part.CanQuery = false
		part.CanTouch = false
		part.CastShadow = false
		part.CFrame = CFrame.lookAt(position + unit * v4, position + unit * v4 * 2)
		part.Parent = workspace
		part.AssemblyLinearVelocity = unit * 28
		part.AssemblyAngularVelocity = Vector3.new(math.random(-8, 8), math.random(-8, 8), math.random(-8, 8))
		Debris:AddItem(part, 0.8)
	end

	Debris:AddItem(model, 0.3)
end

local function observeShield(player)
	local v4 = nil
	local v5 = nil

	-- equivalent calls inferred from this helper; original call sites unknown
	local function removeBubble(flag: boolean, flag2: boolean)
		local v6 = v4
		v4 = nil

		if not v6 then
			return
		end

		if flag then
			crackBubble(v6)
		else
			fadeBubble(v6, flag2)
		end
	end

	local function refresh()
		local griefShieldEndTime = player:GetAttribute("GriefShieldEndTime")
		local v6

		if type(griefShieldEndTime) == "number" then
			v6 = workspace:GetServerTimeNow() < griefShieldEndTime
		else
			v6 = false
		end

		if v6 then
			local hiddenFromLocalPlayer = isHiddenFromLocalPlayer(player) -- equivalent call inferred; original call site unknown
			v6 = not hiddenFromLocalPlayer
		end

		if v6 == (v4 ~= nil) then
			return
		end

		if v6 then
			local character = player.Character

			if not character then
				return
			end

			local bubble = createBubble(character)
			v4 = bubble
			local griefShieldEndTime2 = player:GetAttribute("GriefShieldEndTime")

			if bubble and griefShieldEndTime2 ~= v5 then
				v5 = griefShieldEndTime2
				playSound(sound, bubble.Model:GetPivot().Position) -- equivalent call inferred; original call site unknown
			end

			if bubble then
				bubble.Model.Destroying:Once(function()
					if v4 == bubble then
						v4 = nil
					end
				end)
			end
		else
			local griefShieldEndTime2 = player:GetAttribute("GriefShieldEndTime")
			local v8 = type(griefShieldEndTime2) ~= "number" or not (workspace:GetServerTimeNow() < griefShieldEndTime2)
			local v9

			if v8 then
				local griefShieldCracked = player:GetAttribute("GriefShieldCracked")

				if type(griefShieldCracked) == "number" then
					v9 = workspace:GetServerTimeNow() - griefShieldCracked < 1
				else
					v9 = false
				end
			else
				v9 = v8
			end

			removeBubble(v9, v8) -- equivalent call inferred; original call site unknown
		end
	end

	local v6 = {
		player:GetAttributeChangedSignal("GriefShieldEndTime"):Connect(refresh),
		player:GetAttributeChangedSignal("GriefShieldExemptUserId"):Connect(refresh)
	}
	local v7 = Observers.observeCharacter(player, function()
		refresh()
		return function()
			local v8 = v4
			v4 = nil

			if not v8 then
				return
			end

			fadeBubble(v8, false)
		end
	end)
	return function()
		for _, connection in v6 do
			connection:Disconnect()
		end

		v7()
		removeBubble(false, false) -- equivalent call inferred; original call site unknown
	end
end

local function observeEquippedTool(tool)
	if not tool:IsA("Tool") or tool.Name ~= "Grief Shield" then
		return nil
	end

	local activatedConnection = tool.Activated:Connect(function()
		remoteEvent:FireServer()
	end)
	return function()
		activatedConnection:Disconnect()
	end
end

return {
	Start = function(_)
		task.spawn(function()
			local bubbleWarmupEnabled = GriefShieldFlags.BubbleWarmupEnabled
			local v4 = os.clock() + 5
			pcall(preloadForcefield)

			while not bubbleWarmupEnabled:IsLoaded() and os.clock() < v4 do
				task.wait(0.25)
			end

			if bubbleWarmupEnabled:Get() then
				pcall(warmupForcefield)
			end
		end)
		Observers.observePlayer(function(p)
			return (observeShield(p))
		end)
		Observers.observeCharacter(localPlayer, function(_, p)
			return Observers.observeChildren(p, observeEquippedTool)
		end)
	end
}