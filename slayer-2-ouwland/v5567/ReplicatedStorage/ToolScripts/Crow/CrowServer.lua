local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local ManuelCancel = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.ManuelCancel)
local SignalEvent = require(ReplicatedStorage.Communication.ServerAndClient.Signals.SignalEvent)
local ServerClientPortal = require(ReplicatedStorage.CAM.Global.ServerClientPortal)
local Crow = require(ReplicatedStorage.Items.Misc.Crow)
local gameSettings = require(ReplicatedStorage.CAM.Global.gameSettings)
local CrowHandler = require(ServerStorage.SAM.Services.CrowHandler)
local v = {
	"Cancel",
	"Stun",
	"CombatStun",
	"Strict_Stun"
}
local parent = script.Parent
local CrowServer = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function shout(p, sound: string)
	SignalEvent.ToClient(p, "NpcNotify", {
		Icon = Crow.Icon,
		Text = "CAHH!!",
		Sound = sound
	})
end

local v2 = {}
local v3 = {}

local function resolveAnimator(p, p2)
	if p2.animator ~= nil then
		return p2.animator
	end

	local model = CrowHandler.Model(p)
	local humanoid

	if model ~= nil then
		humanoid = model:FindFirstChild("Humanoid") or nil
	end

	local animator

	if humanoid ~= nil then
		animator = humanoid:FindFirstChildOfClass("Animator") or nil
	end

	p2.animator = animator
	return p2.animator
end

local function playCrowAnim(p, state, currentAnimName: string)
	if state.animator == nil then
		local model = CrowHandler.Model(p)
		local humanoid

		if model ~= nil then
			humanoid = model:FindFirstChild("Humanoid") or nil
		end

		local animator2

		if humanoid ~= nil then
			animator2 = humanoid:FindFirstChildOfClass("Animator") or nil
		end

		state.animator = animator2
	end

	local animator = state.animator

	if animator == nil or state.currentAnimName == currentAnimName then
		return
	end

	local child = parent:FindFirstChild(currentAnimName)

	if child == nil then
		warn((`Crow: no "{currentAnimName}" Animation under {parent:GetFullName()} -- the crow will hold its default pose`))
		return
	end

	for _, v4 in animator:GetPlayingAnimationTracks() do
		v4:Stop()
	end

	local track = animator:LoadAnimation(child)
	track.Looped = true
	track.Priority = Enum.AnimationPriority.Idle
	track:Play()
	state.currentTrack = track
	state.currentAnimName = currentAnimName
end

-- equivalent calls inferred from this helper; original call sites unknown
local function raceAllowsCrow(p)
	local data = Utility.GetData(p)
	local race = data and data:FindFirstChild("Race")
	local value = race and race.Value
	return value == "Slayer" or value == "Hybrid"
end

local function despawnCrow(player, p)
	local v4 = v2[player]

	if v4 == nil then
		return
	end

	v2[player] = nil

	if v4.cancelDestroy then
		v4.cancelDestroy()
	end

	if v4.charConn then
		v4.charConn:Disconnect()
	end

	if v4.animPortal then
		v4.animPortal:Destroy()
	end

	playCrowAnim(player, v4, "fly")
	CrowHandler.Despawn(player, p or player.Character)
	shout(player, "PS2crowLEAVE") -- equivalent call inferred; original call site unknown
end

function CrowServer.check(p, _, _, _: string)
	if (v3[p] or 0) > os.clock() then
		return false
	end

	return raceAllowsCrow(p)
end

function CrowServer.Equipped(p, instance, _, _: string)
	if v2[p] ~= nil then
		if CrowHandler.Model(p) ~= nil then
			return
		end

		despawnCrow(p, instance)
	end

	if instance == nil or instance:FindFirstChild("HumanoidRootPart") == nil then
		return
	end

	CrowHandler.Spawn(p, instance)
	shout(p, "PS2crowCAW") -- equivalent call inferred; original call site unknown
	local v4 = {}
	v2[p] = v4
	local animPortal = ServerClientPortal.Create(p, "CrowAnim", -1)
	v4.animPortal = animPortal
	animPortal:Connect(function(currentAnimName: string)
		if currentAnimName == "idle" or currentAnimName == "fly" then
			playCrowAnim(p, v4, currentAnimName)
		end
	end)
	playCrowAnim(p, v4, "fly")
	local v6, cancelDestroy = ManuelCancel.new(p, -1, v)
	v4.cancelDestroy = cancelDestroy

	if v6 then
		v6:Connect(function()
			despawnCrow(p, instance)
		end)
	end

	v4.charConn = p.CharacterRemoving:Connect(function()
		despawnCrow(p, instance)
	end)
end

function CrowServer.UnEquipped(p, p2, _, _: string)
	despawnCrow(p, p2)
	v3[p] = os.clock() + gameSettings.crowEquipCooldown
end

function CrowServer.MouseDown(_, _, _, _: string) end

function CrowServer.MouseUp(_, _, _, _: string) end

function CrowServer.Dismiss(player)
	despawnCrow(player, player.Character)
end

function CrowServer.DisposePlayer(p)
	CrowServer.Dismiss(p)
	v3[p] = nil
end

return CrowServer