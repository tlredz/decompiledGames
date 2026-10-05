local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local SettingsFlags = require(ReplicatedStorage.SharedUtils.SettingsFlags)
local localPlayer = Players.LocalPlayer
local tweenInfo = TweenInfo.new(120, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1, false, 0)
local heartbeatConnection = nil
local tweens = {}
local textures = {}
local textures2 = {}
local v = true

-- equivalent calls inferred from this helper; original call sites unknown
local function onTextureAdd(p)
	p.OffsetStudsU = 0
	p.OffsetStudsV = 0
	local tween = TweenService:Create(p, tweenInfo, {
		OffsetStudsU = 50,
		OffsetStudsV = 50
	})
	tween:Play()
	tweens[#tweens + 1] = tween
end

local function addTexture(texture)
	if not texture:IsA("Texture") then
		return
	end

	local isDescendant = texture:IsDescendantOf(localPlayer.Character)
	local v2 = UserInputService.PreferredInput ~= Enum.PreferredInput.Touch

	if isDescendant then
		textures[#textures + 1] = texture
	else
		textures2[#textures2 + 1] = texture
	end

	if v2 and v then
		onTextureAdd(texture) -- equivalent call inferred; original call site unknown
	end
end

local function removeTexture(p)
	-- equivalent calls inferred from this helper; original call sites unknown
	local function scan(list)
		local index = table.find(list, p)

		if index then
			table.remove(list, index)
		end
	end

	scan(textures) -- equivalent call inferred; original call site unknown
	scan(textures2) -- equivalent call inferred; original call site unknown
end

-- equivalent calls inferred from this helper; original call sites unknown
local function UseHeartbeat()
	heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
		for _, v2 in pairs(textures) do
			v2.OffsetStudsU = v2.OffsetStudsU % 50 + dt * 0.4
			v2.OffsetStudsV = v2.OffsetStudsV % 50 + dt * 0.4
		end
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function UseTweens()
	-- equivalent calls inferred from this helper; original call sites unknown
	local function apply(items)
		for _, item in pairs(items) do
			onTextureAdd(item) -- equivalent call inferred; original call site unknown
		end
	end

	apply(textures) -- equivalent call inferred; original call site unknown
	apply(textures2) -- equivalent call inferred; original call site unknown
end

local function preferenceChanged()
	local v2 = UserInputService.PreferredInput == Enum.PreferredInput.Touch

	if #tweens > 0 then
		for _, v3 in pairs(tweens) do
			v3:Cancel()
		end

		table.clear(tweens)
	end

	if heartbeatConnection then
		heartbeatConnection:Disconnect()
	end

	if not v then
		return
	end

	if v2 then
		UseHeartbeat() -- equivalent call inferred; original call site unknown
		return
	end

	UseTweens() -- equivalent call inferred; original call site unknown
end

UserInputService:GetPropertyChangedSignal("PreferredInput"):Connect(preferenceChanged)
preferenceChanged()
local modules = ReplicatedStorage:WaitForChild("Modules", 60)

if not modules then
	warn("[TextureMover] Modules folder not found")
	return
end

local myDataController = modules:FindFirstChild("MyDataController")

if not myDataController then
	local clientUI = modules:FindFirstChild("ClientUI")
	myDataController = clientUI and clientUI:WaitForChild("MyDataController", 60)
end

if not myDataController then
	warn("[TextureMover] MyDataController module not found")
	return
end

local module = require(myDataController)
module:onReplicaReady(function(object)
	-- equivalent calls inferred from this helper; original call sites unknown
	local function updateSetting()
		local movingTextureToggle = object.Data.Settings and object.Data.Settings.MovingTextureToggle
		v = SettingsFlags:GetEffective(movingTextureToggle, "MovingTextureToggle") == true
		preferenceChanged()
	end

	object:ListenToChange({ "Settings", "MovingTextureToggle" }, function(_, _)
		updateSetting() -- equivalent call inferred; original call site unknown
	end)
	updateSetting() -- equivalent call inferred; original call site unknown
end)
return {
	AddTag = function(_, tag: string)
		if not tag or typeof(tag) ~= "string" then
			return
		end

		for _, v2 in pairs(CollectionService:GetTagged(tag)) do
			task.spawn(addTexture, v2)
		end

		CollectionService:GetInstanceRemovedSignal(tag):Connect(removeTexture)
		CollectionService:GetInstanceAddedSignal(tag):Connect(addTexture)
	end
}