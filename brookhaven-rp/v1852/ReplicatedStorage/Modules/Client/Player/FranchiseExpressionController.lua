local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local GameUtil = require(ReplicatedStorage.Modules.Shared.Game.GameUtil)
local UgcDynamicHeadConstants = require(ReplicatedStorage.Modules.Shared.AvatarEditor.UgcDynamicHeadConstants)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = {
	[Enum.KeyCode.Five] = 134487708911289,
	[Enum.KeyCode.Six] = 106315642685381,
	[Enum.KeyCode.Seven] = 125127541829088,
	[Enum.KeyCode.Eight] = 109342227672377,
	[Enum.KeyCode.Nine] = 123143488464833,
	[Enum.KeyCode.Zero] = 71493741441368
}
local v2 = {
	[Enum.KeyCode.Five] = 134487708911289,
	[Enum.KeyCode.Six] = 139505803283852,
	[Enum.KeyCode.Seven] = 95706122246766,
	[Enum.KeyCode.Eight] = 132888070720391,
	[Enum.KeyCode.Nine] = 101570351179815,
	[Enum.KeyCode.Zero] = 110502155927093
}
local v3 = {
	[UgcDynamicHeadConstants.SKYE] = v,
	[UgcDynamicHeadConstants.BRIAN] = v2
}
local localPlayer = Players.LocalPlayer
local maid = Janitor.new()
local v4 = {}
local tracks = {}
local v5 = nil

local function getAnimator(instance)
	local humanoid = instance:FindFirstChildOfClass("Humanoid")

	if humanoid == nil then
		return nil
	end

	local animator = humanoid:FindFirstChildOfClass("Animator")

	if animator == nil then
		return instance:FindFirstChildWhichIsA("Animator", true)
	end

	return animator
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getAnimationsForCharacter(character)
	local name = UgcDynamicHeadConstants.GetNameFromCharacter(character)

	if name == nil then
		return nil
	end

	return v3[name]
end

local function getOrLoadTrack(animator, p: number)
	local v6 = tracks[p]

	if v6 ~= nil and v6.Parent ~= nil then
		return v6
	end

	local v7 = v4[p]

	if v7 == nil then
		v7 = Instance.new("Animation")
		v7.Name = "FranchiseExpression_" .. tostring(p)
		v7.AnimationId = "rbxassetid://" .. tostring(p)
		v4[p] = v7
	end

	local track = animator:LoadAnimation(v7)
	track.Priority = Enum.AnimationPriority.Action4
	track.Looped = true
	tracks[p] = track
	return track
end

local function playExpression(keyCode)
	local character = localPlayer.Character

	if character == nil then
		return
	end

	local animationsForCharacter = getAnimationsForCharacter(character) -- equivalent call inferred; original call site unknown

	if animationsForCharacter == nil then
		return
	end

	local v6 = animationsForCharacter[keyCode]

	if v6 == nil then
		return
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local animator

	if humanoid ~= nil then
		animator = humanoid:FindFirstChildOfClass("Animator")

		if animator == nil then
			animator = character:FindFirstChildWhichIsA("Animator", true)
		end
	end

	if animator == nil then
		return
	end

	local loadTrack = getOrLoadTrack(animator, v6)

	if v5 ~= nil and v5 ~= loadTrack and v5.IsPlaying then
		v5:Stop(0.1)
	end

	if not loadTrack.IsPlaying then
		loadTrack:Play(0.1)
	end

	v5 = loadTrack
end

-- equivalent calls inferred from this helper; original call sites unknown
local function onCharacterAdded(_)
	if v5 ~= nil then
		v5:Stop(0)
		v5 = nil
	end

	table.clear(tracks)
end

local FranchiseExpressionController = {}

function FranchiseExpressionController.FrameworkInit() end

function FranchiseExpressionController.FrameworkStart()
	if not GameUtil.IsFranchise() then
		return
	end

	maid:Add(UserInputService.InputBegan:Connect(function(input, gameProcessed: boolean)
		if gameProcessed or v[input.KeyCode] == nil then
			return
		end

		playExpression(input.KeyCode)
	end))
	maid:Add(localPlayer.CharacterAdded:Connect(onCharacterAdded))

	if localPlayer.Character ~= nil then
		local _ = localPlayer.Character
		onCharacterAdded() -- equivalent call inferred; original call site unknown
	end
end

return FranchiseExpressionController