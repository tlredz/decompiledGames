local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
local CompanionBehavior = require(script.Parent.Parent.CompanionBehavior)
local Net = require(ReplicatedStorage.packages.Net)
local fish = require(ReplicatedStorage.shared.modules.library.fish)
local clientdialog = ReplicatedStorage.events.clientdialog
local remoteEvent = Net:RemoteEvent("Companion/SillySeal/Feed")
local remoteEvent2 = Net:RemoteEvent("Companion/SillySeal/Hunger")
local v = {
	Sleep = {
		Chance = 0,
		Interval = 1e999
	},
	BellyPat = {
		Chance = 0,
		Interval = 1e999
	},
	BellySlap = {
		Chance = 0,
		Interval = 1e999
	},
	Flop = {
		Chance = 0,
		Interval = 1e999
	},
	Eat = {
		Chance = 0,
		Interval = 1e999
	}
}
local v2 = {
	Flop = 0.5,
	BellySlap = 0.3,
	BellyPat = 0.2
}
local v3 = {
	BellyPat = 0.6,
	BellySlap = 0.2,
	Flop = 0.2
}
local v4 = {
	Sleep = 0.7,
	BellyPat = 0.3
}
local v5 = {
	"Arf!",
	"Rrf!",
	"(Mmm... Yummy.)",
	"(Feesh..) *rubs belly*"
}
local v6 = {
	"(I was hungy...)",
	"Hehe... Arf.",
	"*rubs belly* *slaps belly* (yeeuusss..)",
	"(Yum.)",
	"(Sorry (Not sorry))",
	"<b>I like to cause pain.</b>"
}
local SillySeal = {}
SillySeal.__index = SillySeal
setmetatable(SillySeal, CompanionBehavior)

function SillySeal.new(p)
	local v7 = CompanionBehavior.new(p)
	setmetatable(v7, SillySeal)
	v7:RegisterMoods(v)
	v7.hunger = 0
	v7.tier = "Sleeping"
	v7.ambientSwapTimer = 0
	v7.ambientSwapDuration = 12
	v7._moodEnded = false
	v7._moodPhaseGen = 0
	v7:_SetupPrompt()
	v7:_SetupHungerSync()
	v7:_ApplyTier()
	return v7
end

function SillySeal:_HasAnim(p2: string)
	return self.companion.Animations and self.companion.Animations[p2] ~= nil
end

function SillySeal:_PlayIfExists(p: string)
	if self:_HasAnim(p) then
		self:PlayAnimation(p)
	end
end

function SillySeal:_WeightedPick(items)
	local total = 0

	for _, item in items do
		total += item
	end

	local v7 = math.random() * total
	local total2 = 0

	for k, item in items do
		total2 += item

		if v7 <= total2 then
			return k
		end
	end

	return (next(items))
end

function SillySeal:_ComputeTier()
	if self.hunger >= 60 then
		return "Active"
	end

	if self.hunger >= 25 then
		return "Lazy"
	end

	if self.hunger >= 5 then
		return "Sleepy"
	end

	return "Sleeping"
end

function SillySeal:_Say(text: string)
	local v7 = {
		locked = false,
		npc = self.companion.Model,
		dialog = {
			{
				text = text,
				t = 0.1
			}
		}
	}
	clientdialog:Fire(v7, self.companion.RootPart, {
		dialog = v7.dialog
	})
end

function SillySeal:_SetupHungerSync()
	self.trove:Add(remoteEvent2.OnClientEvent:Connect(function(hunger: number)
		self.hunger = hunger
		local _ComputeTier = self:_ComputeTier()

		if _ComputeTier ~= self.tier then
			self.tier = _ComputeTier
			self:_ApplyTier()
		end
	end))
end

function SillySeal:_ApplyTier()
	if self.tier == "Active" then
		self.companion.FollowSpeed = 14
	elseif self.tier == "Lazy" then
		self.companion.FollowSpeed = 8
	elseif self.tier == "Sleepy" then
		self.companion.FollowSpeed = 5
	else
		self.companion.FollowSpeed = 3
	end

	if not self.activeMood then
		self:_PlayIfExists("Idle")
	end
end

function SillySeal:_SetupPrompt()
	local rootPart = self.companion.RootPart

	if not (rootPart and self.companion.IsOwner) then
		return
	end

	local proximityPrompt = Instance.new("ProximityPrompt")
	proximityPrompt.KeyboardKeyCode = Enum.KeyCode.F
	proximityPrompt.ActionText = ""
	proximityPrompt.ObjectText = ""
	proximityPrompt.MaxActivationDistance = 10
	proximityPrompt.HoldDuration = 0.5
	proximityPrompt.RequiresLineOfSight = false
	proximityPrompt.Style = Enum.ProximityPromptStyle.Custom
	proximityPrompt.Enabled = false
	proximityPrompt.Parent = rootPart
	self.trove:Add(proximityPrompt)
	self.trove:Connect(proximityPrompt.Triggered, function()
		remoteEvent:FireServer()
	end)
	self.trove:Add(task.spawn(function()
		while true do
			task.wait(0.1)
			proximityPrompt.Enabled = self:_IsLocalPlayerHoldingFish()

			if proximityPrompt.Enabled then
				proximityPrompt.ObjectText = `{self.companion.DisplayName or "Silly Seal"} ({math.round(self.hunger)} Hunger)`
				proximityPrompt.ActionText = `Feed "{self:_IsLocalPlayerHoldingFish()}"`
			else
				proximityPrompt.ActionText = ""
				proximityPrompt.ObjectText = ""
			end
		end
	end))
end

function SillySeal:_IsLocalPlayerHoldingFish()
	local character = Players.LocalPlayer.Character

	if not character then
		return false
	end

	local tool = character:FindFirstChildOfClass("Tool")
	return not not tool and fish[tool.Name] ~= nil and tool.Name
end

function SillySeal:Update(p: number)
	self.ambientSwapTimer += p

	if self.ambientSwapTimer < self.ambientSwapDuration then
		return nil
	end

	self.ambientSwapTimer = 0
	local v7, v8, v9

	if self.tier == "Active" then
		v7 = v2
		v8 = 7
		v9 = 3
	elseif self.tier == "Lazy" then
		v7 = v3
		v8 = 16
		v9 = 8
	else
		v7 = v4
		v8 = 22
		v9 = 12
	end

	self.ambientSwapDuration = math.random() * (v8 - v9) + v9
	return self:_WeightedPick(v7)
end

function SillySeal:StartMood(activeMood: string, p)
	self.activeMood = activeMood
	self._moodEnded = false
	self._moodPhaseGen += 1
	local _moodPhaseGen = self._moodPhaseGen

	if activeMood == "Sleep" then
		self:SetState("MoodAction")
		self:_PlayIfExists("Sleeping")
		local v7 = math.random(6, 14)
		task.delay(v7, function()
			if self._moodPhaseGen == _moodPhaseGen then
				self._moodEnded = true
			end
		end)
	elseif activeMood == "BellyPat" then
		self:SetState("MoodAction")
		self:SetFaceOwner(true)
		self:_PlayIfExists("Happy")
		task.delay(3, function()
			if self._moodPhaseGen == _moodPhaseGen then
				self._moodEnded = true
			end
		end)
	elseif activeMood == "BellySlap" then
		self:SetState("MoodAction")
		self:SetFaceOwner(true)
		self:_PlayIfExists("SlappingBelly")
		task.delay(2.5, function()
			if self._moodPhaseGen == _moodPhaseGen then
				self._moodEnded = true
			end
		end)
	elseif activeMood == "Flop" then
		self:SetState("MoodAction")
		self:_PlayIfExists("Jump")
		task.delay(2, function()
			if self._moodPhaseGen == _moodPhaseGen then
				self._moodEnded = true
			end
		end)
	elseif activeMood == "Eat" then
		self:SetState("MoodAction")
		self:SetFaceOwner(true)
		self:_PlayIfExists("Run")
		local v7 = p.Stolen and v6 or v5
		self:_Say(v7[math.random(1, #v7)])
		self:PlaySound("Feed", true)
		task.delay(1.8, function()
			if self._moodPhaseGen == _moodPhaseGen then
				self._moodEnded = true
			end
		end)
	end
end

function SillySeal:UpdateMood(p: number)
	self:_TickMovement(p)
	return self._moodEnded
end

function SillySeal:StopMood()
	if not self.activeMood then
		return
	end

	self:SetFaceOwner(false)
	self.activeMood = nil
	self:_PlayIfExists("Idle")
end

function SillySeal:Destroy()
	if self.activeMood then
		self:StopMood()
	end

	CompanionBehavior.Destroy(self)
end

return SillySeal