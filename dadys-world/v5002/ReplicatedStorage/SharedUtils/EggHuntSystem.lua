local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local UserInputService = game:GetService("UserInputService")
local fn
local Network = require(ReplicatedStorage:WaitForChild("SharedUtils"):WaitForChild("Network"))
local Universe = require(ReplicatedStorage.SharedUtils.Universe)
local InputService = require(ReplicatedStorage.SharedUtils.InputService)

local function _Server()
	if script:GetAttribute("ServerStarted") then
		return
	end

	script:SetAttribute("ServerStarted", true)
	local ReplicaCache = require(ServerScriptService.Modules.ReplicaCache)
	local AchievementGiver = require(ServerStorage.SharedModules.AchievementGiver)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function getReplica(p)
		return p and ReplicaCache[p.UserId]
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function SetReplicaValue(p, p2, p3)
		local replica = getReplica(p) -- equivalent call inferred; original call site unknown

		if replica then
			replica:SetValue(p2, p3)
		end
	end

	local editData = ReplicatedStorage:WaitForChild("editData")
	local parentsByName = {}

	-- equivalent calls inferred from this helper; original call sites unknown
	local function clickEgg(instance, p)
		local name = instance.Name

		if not parentsByName[name] then
			return
		end

		instance:SetAttribute(tostring(p.UserId), true)
		editData:Invoke(p, function(p2)
			if not (p2 and p2.Data and (p2.Data.Seasonal and p2.Data.Seasonal)) then
				return
			end

			if not p2.Data.Seasonal.EasterEggsCollected then
				SetReplicaValue(p, "Seasonal.EasterEggsCollected", {}) -- equivalent call inferred; original call site unknown
			end

			SetReplicaValue(p, string.format("Seasonal.EasterEggsCollected.%s", name), DateTime.now().UnixTimestamp) -- equivalent call inferred; original call site unknown
			local count = 0

			for _, _ in pairs(p2.Data.Seasonal.EasterEggsCollected) do
				count += 1
			end

			AchievementGiver:UpdateKey(p, "ID_39_EggHunt26", true, count)
		end)
	end

	fn = function(parent)
		local clickDetector = Instance.new("ClickDetector")
		clickDetector.MaxActivationDistance = parent:GetAttribute("ClickRange") or 12
		clickDetector.Parent = parent
		local proximityPrompt = Instance.new("ProximityPrompt")
		proximityPrompt.RequiresLineOfSight = parent:GetAttribute("RequiresLOS") == true
		proximityPrompt.Style = Enum.ProximityPromptStyle.Custom
		proximityPrompt.ActionText = "Pick Up"
		proximityPrompt.ObjectText = "Easter Egg"
		proximityPrompt.MaxActivationDistance = 0
		proximityPrompt.KeyboardKeyCode = Enum.KeyCode.E
		proximityPrompt.GamepadKeyCode = Enum.KeyCode.ButtonX
		proximityPrompt.Enabled = false
		proximityPrompt.Parent = parent
		clickDetector.MouseClick:Connect(function(p)
			clickEgg(parent, p) -- equivalent call inferred; original call site unknown
		end)
		parentsByName[parent.Name] = parent
	end

	Network:AddAction("ClickEgg", function(player, part)
		local character = player and player.Character
		local position = character and character:GetPivot().Position
		local position2 = part and part:IsA("BasePart") and part.Position

		if not (position and position2) or (position - position2).Magnitude > (part:GetAttribute("ConsoleClickRange") or 16) then
			return
		end

		clickEgg(part, player) -- equivalent call inferred; original call site unknown
	end)
end

local function _Client()
	if script:GetAttribute("ClientStarted") then
		return
	end

	script:SetAttribute("ClientStarted", true)

	if not Universe:IsLobby() then
		return
	end

	local v = {}
	local parentsByName = {}
	local userId = tostring(Players.LocalPlayer.UserId)
	local proximityPrompts = {}

	fn = function(parent)
		local attachment = parent.Parent:FindFirstChild("Attachment")

		if attachment then
			attachment = attachment:Clone()
			attachment.Parent = parent
		end

		local particleEmitter = attachment and attachment:FindFirstChild("ParticleEmitter")
		local billboardGui = attachment and attachment:FindFirstChild("BillboardGui")
		local sound = attachment and attachment:FindFirstChild("Sound")

		if billboardGui then
			InputService:BindGlyph(billboardGui:WaitForChild("ImageLabel"), "Interact", "Gamepad")
		end

		local proximityPrompt = parent:WaitForChild("ProximityPrompt")
		local clickDetector = parent:WaitForChild("ClickDetector")
		local v2 = 0
		proximityPrompt.PromptShown:Connect(function()
			if parent:GetAttribute(userId) then
				return
			end

			local now = tick()
			v2 = now
			task.delay(1, function()
				if parent:GetAttribute(userId) then
					return
				end

				if v2 == now then
					billboardGui.Enabled = true
				end
			end)
		end)
		proximityPrompt.PromptHidden:Connect(function()
			v2 = 0
			billboardGui.Enabled = false
		end)
		local clickRange = parent:GetAttribute("ClickRange") or 12
		local consoleClickRange = parent:GetAttribute("ConsoleClickRange") or 16

		local function setEggVisible(p, p2)
			parent.Transparency = p and 0 or 1
			clickDetector.MaxActivationDistance = p and clickRange or 0
			local enabled = p and UserInputService.PreferredInput == Enum.PreferredInput.Gamepad
			proximityPrompt.Enabled = enabled
			proximityPrompt.MaxActivationDistance = enabled and consoleClickRange or 0

			if not p and p2 then
				if particleEmitter then
					particleEmitter:Emit(1)
				end

				if sound then
					sound:Play()
				end
			end
		end

		parent:GetAttributeChangedSignal(userId):Connect(function()
			setEggVisible(parent:GetAttribute(userId) ~= true, true)
		end)
		proximityPrompts[#proximityPrompts + 1] = proximityPrompt
		proximityPrompt.Triggered:Connect(function()
			if not proximityPrompt.Enabled then
				return
			end

			Network:Post("ClickEgg", parent)
		end)
		setEggVisible(v[parent.Name] == nil, false)
		parentsByName[parent.Name] = parent
	end

	local modules = ReplicatedStorage.Modules
	local module = require(modules:FindFirstChild("MyDataController") or modules:FindFirstChild("ClientUI"):WaitForChild("MyDataController"))
	module:onReplicaReady(function(p)
		if not (p and p.Data) then
			return
		end

		local v2 = module:getDataFromPath("Seasonal.EasterEggsCollected") or {}

		for k, v3 in pairs(v2) do
			v[k] = v3

			if parentsByName[k] then
				parentsByName[k]:SetAttribute(userId, true)
			end
		end
	end)

	local function updatePreferredInput()
		for _, v2 in pairs(proximityPrompts) do
			local enabled = UserInputService.PreferredInput == Enum.PreferredInput.Gamepad
			local consoleClickRange = v2.Parent:GetAttribute("ConsoleClickRange") or 16
			v2.MaxActivationDistance = enabled and consoleClickRange or 0
			v2.Enabled = enabled
		end
	end

	UserInputService:GetPropertyChangedSignal("PreferredInput"):Connect(updatePreferredInput)
	task.spawn(updatePreferredInput)
end

local function Start()
	if RunService:IsServer() then
		_Server()
	else
		_Client()
	end

	CollectionService:GetInstanceAddedSignal("EggHuntDandyEgg"):Connect(fn)

	for _, v in pairs(CollectionService:GetTagged("EggHuntDandyEgg")) do
		task.spawn(fn, v)
	end
end

task.spawn(Start)
return {}