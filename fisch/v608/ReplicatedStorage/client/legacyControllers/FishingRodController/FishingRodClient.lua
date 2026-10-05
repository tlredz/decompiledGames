game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
game:GetService("ServerStorage")
game:GetService("TweenService")
game:GetService("HttpService")
local localPlayer = Players.LocalPlayer
local Net = require(ReplicatedStorage.packages.Net)
local Trove = require(ReplicatedStorage.packages.Trove)
local Signal = require(ReplicatedStorage.packages.Signal)
local modules = ReplicatedStorage.shared.modules
local BiteTypes = require(modules.fishing.BiteTypes)
local fx = require(modules.fx)
local fishing = require(modules.fishing)
require(ReplicatedStorage.shared.utils.assets)
require(modules.FishModel)
require(modules.SaneDebris)
require(modules.FFlags)
require(modules.CatchMilestones)
require(modules.character.level)
require(modules.library.rods.enchants)
require(modules.library.bait)
require(modules.library.fish)
require(modules.library.rarities)
require(modules.fishing.mutations)
require(modules.character.titles)
require(modules.library.fish.zones)
local sfx = ReplicatedStorage.resources.sounds.sfx
local _ = ReplicatedStorage.resources.replicated.fishing
local fishing2 = ReplicatedStorage.resources.animations.fishing
Net:RemoteEvent("FishingRod/HandleBobber")
Net:RemoteEvent("FishingRod/BreakBobber")
local remoteEvent = Net:RemoteEvent("FishingRod/Reset")
local FishingRodClient = {
	Active = nil
}
local rodState = BiteTypes.RodState
local v = {
	fighting = Enum.AnimationPriority.Action4,
	idle = Enum.AnimationPriority.Idle,
	bite = Enum.AnimationPriority.Action4,
	fling = Enum.AnimationPriority.Action4,
	linesnap = Enum.AnimationPriority.Action4,
	equip = Enum.AnimationPriority.Action,
	shake = Enum.AnimationPriority.Action3
}

local function sendDebugInfo(p: string, flag: boolean?)
	if game.GameId ~= 5750914919 then
		ReplicatedStorage.events.anno_localthought:Fire(p)
	end

	if flag or localPlayer:GetAttribute("PrintCastRejections") then
		warn(p)
	end
end

local function displayState(p: number)
	for k, v2 in rodState do
		if v2 == p then
			return k
		end
	end

	return (`UNKNOWN ({p})`)
end

function FishingRodClient:ChangeState(state2: number)
	if self.State == state2 or self.State == rodState.Destroyed then
		return
	end

	self.StateChanged:Fire(state2, self.State)
	self.State = state2
	local values = self.Tool:FindFirstChild("values")
	local state = values and values:FindFirstChild("state")

	if state then
		state.Value = state2
	end

	self:UpdateInspect()
end

function FishingRodClient.Cast(_, _: number, _: boolean)
	return true
end

function FishingRodClient:CanReset()
	return self.State < rodState.PreReel and self.State ~= rodState.Equipping
end

function FishingRodClient:Reset(p)
	if p or self:CanReset() then
	end
end

function FishingRodClient:Bite() end

function FishingRodClient:HandleEquip()
	self:ChangeState(rodState.Equipping)
	self.IsEquipped = true
	fishing:WeldToArm(self.Character, self.Handle)
	local humanoid = self.Character:FindFirstChildOfClass("Humanoid")

	if humanoid and humanoid:FindFirstChildOfClass("Animator") then
		task.spawn(function()
			local v2 = self:PlayAnimation("equip")

			if v2 and v2.IsPlaying then
				task.wait((math.clamp(v2.Length - v2.TimePosition, 0, v2.Length)))
			end

			self:PlayAnimation("idle", v2 and 0 or 0.2)
			self:ChangeState(rodState.Equipped)
		end)
	else
		task.defer(function()
			self:ChangeState(rodState.Equipped)
		end)
	end

	local equip = self.Handle:FindFirstChild("Equip")

	if equip and equip:IsA("Sound") then
		equip:Play()
	end

	self.Player:SetAttribute("CurrentRod", self.Name)
end

function FishingRodClient:HandleUnequip()
	self.IsEquipped = false
	local equip = self.Handle:FindFirstChild("Equip")

	if equip and equip:IsA("Sound") then
		equip:Stop()
	end

	self:StopAnimation("equip")
	self:StopAnimation("idle")
	self:Reset(self.Player:GetAttribute("TeleportInProgress") == true)
end

function FishingRodClient:GetAnimation(childName: string, flag: boolean?)
	if self._Animations[childName] then
		return self._Animations[childName]
	end

	if flag then
		return nil
	end

	local humanoid = self.Character:FindFirstChildOfClass("Humanoid")
	local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")

	if not animator then
		return nil
	end

	local animation = self.Handle:FindFirstChild(childName)

	if animation and not animation:IsA("Animation") then
		animation = nil
	end

	local animation2 = animation or fishing2:FindFirstChild(childName)

	if not (animation2 and animation2:IsA("Animation")) then
		return nil
	end

	local track = animator:LoadAnimation(animation2)

	if v[childName] then
		track.Priority = v[childName]
	end

	self.Trove:Add(track)
	self._Animations[childName] = track
	self.Trove:Add(function()
		track:Stop()
	end)
	return track
end

function FishingRodClient:PlayAnimation(p: string, p2: number?, p3: number?, p4: number?)
	local animation = self:GetAnimation(p)

	if not animation then
		return nil
	end

	animation:Play(p2, p3, p4)
	return animation
end

function FishingRodClient:StopAnimation(p: string, p2: number?)
	local animation = self:GetAnimation(p, true)

	if not animation then
		return nil
	end

	animation:Stop(p2)
	return animation
end

function FishingRodClient.Tick(_, _: number) end

function FishingRodClient:Destroy()
	self.Destroying:Fire()
	self:ChangeState(rodState.Destroyed)
	self.Trove:Clean()

	if FishingRodClient.Active == self then
		FishingRodClient.Active = nil
	end
end

function FishingRodClient.new(tool)
	local object = setmetatable({}, {
		__index = FishingRodClient
	})

	if FishingRodClient.Active then
		FishingRodClient.Active:Destroy()
		FishingRodClient.Active = nil
	end

	object.Player = localPlayer
	object.Character = localPlayer.Character
	object.Tool = tool
	object.Name = tool.Name
	object.Trove = Trove.new()
	object.CastTrove = object.Trove:Extend()
	object._Animations = {}
	object.StateChanged = object.Trove:Add(Signal.new())
	object.Equipped = object.Trove:Add(Signal.new())
	object.Unequipped = object.Trove:Add(Signal.new())
	object.Destroying = object.Trove:Add(Signal.new())
	local v2, v3 = legacyPlayerData.forPlayerNow(player)

	if not (v2 and v3) then
		warn((`[FishingRodClient] Failed to load data for {player.Name}`))
		return nil
	end

	local rods = v3.Data.NewFormat.Rods

	if not rods then
		warn((`[FishingRodClient] Failed to Rods folder for {player.Name}`))
		return nil
	end

	local rod = rods[tool.Name]

	if not rod then
		warn((`[FishingRodClient] Couldn't find {tool.Name} in {player.Name}'s Rods inventory`))
		return nil
	end

	local handle = tool:FindFirstChild("handle")

	if not handle then
		warn((`[FishingRodClient] No handle found in {object.Player.Name} / {object.Name} / {object.Skin}`))
		return nil
	end

	object.Handle = handle
	object:GetAnimation("idle")
	object:GetAnimation("equip")
	object:GetAnimation("fling")
	object:GetAnimation("linesnap")
	object:GetAnimation("fighting")
	object:GetAnimation("shake")
	local humanoid = object.Character:FindFirstChildOfClass("Humanoid")

	if humanoid then
		object.Trove:Connect(humanoid.Died, function()
			object:Reset(true)

			if object.Tool.Parent == object.Character then
				object.Tool.Parent = player.Character:FindFirstChildOfClass("Backpack")
			end
		end)
	end

	object.Trove:Add(function()
		table.clear(object._Animations)
	end)
	object.State = rodState.Unequipped
	FishingRodClient.Active = object
	object.Enchant = rod.enchant
	object.SecondaryEnchant = rod.secondaryEnchant

	if rod.skin and rod.skin ~= "Default" then
		object.Skin = rod.skin
	end

	local stringValue = PlayerService:ReadDataPathNow(player, "Stats.bait")

	if stringValue and stringValue:IsA("StringValue") then
		object.Bait = stringValue.Value
		object.Trove:Add(stringValue.Changed:Connect(function(bait)
			object.Bait = bait
		end))
	end

	object.Trove:Add(LureShakeService.OnShakeFinished:Connect(function(p, _, p2)
		if p ~= object.Player or object.State ~= rodState.Luring then
			return
		end

		if p2 then
			object:Bite()
		else
			object:Reset(false)
		end
	end))
	object.Trove:Add(LureShakeService.OnShakeClicked:Connect(function(p, _)
		if p ~= object.Player or object.State ~= rodState.Luring then
			return
		end

		object:PlayAnimation("shake", 0)
		local shakeparticle = object.Bobber and object.Bobber:FindFirstChild("shakeparticle")

		if shakeparticle and shakeparticle:IsA("ParticleEmitter") then
			shakeparticle:Emit(1)
		end

		fx:PlaySound(sfx.fishing["splash" .. tostring(math.random(1, 2))], object.Bobber, true)
		PlayerService.OnRodShook:Fire(object.Player)
		object:UpdateInspect()
	end))
	object.Trove:Add(tool.Equipped:Connect(function()
		if object.State == rodState.Unequipped then
			object:HandleEquip()
		end
	end))
	object.Trove:Add(tool.Unequipped:Connect(function()
		if object:CanReset() or object.Player:GetAttribute("TeleportInProgress") then
			object:HandleUnequip()
			return
		end

		local humanoid2 = object.Character:FindFirstChildOfClass("Humanoid")

		if humanoid2 then
			humanoid2:EquipTool(tool)
		end
	end))
	object.Trove:Add(remoteEvent.OnServerEvent:Connect(function(p)
		if object.Player == p then
			object:Reset(false)
		end
	end))
	object:UpdateInspect()
	return object
end

return FishingRodClient