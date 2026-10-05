local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local v = Component.new({
	Tag = "VelociraptorInteractZone"
})
local localPlayer = Players.LocalPlayer

function v:Construct()
	self._Janitor = Janitor.new()
	self._lockJanitor = nil
	self._animationPlaying = nil
end

function v:_Unlock()
	if self._lockJanitor == nil then
		return
	end

	self._lockJanitor:Destroy()
	self._lockJanitor = nil
	local character = localPlayer.Character

	if character == nil then
		return
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")

	if humanoid ~= nil then
		humanoid.WalkSpeed = StarterPlayer.CharacterWalkSpeed
	end
end

function v:_Lock()
	if self._lockJanitor ~= nil then
		return
	end

	local character = localPlayer.Character

	if character == nil then
		return
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")

	if humanoid == nil then
		return
	end

	self._lockJanitor = Janitor.new()

	-- equivalent calls inferred from this helper; original call sites unknown
	local function freezeWalk()
		if humanoid.WalkSpeed ~= 0 then
			humanoid.WalkSpeed = 0
		end
	end

	freezeWalk() -- equivalent call inferred; original call site unknown
	self._lockJanitor:Add(humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(freezeWalk))
	self._lockJanitor:Add(humanoid.Jumping:Connect(function(flag: boolean)
		if flag == true then
			self:_Unlock()
		end
	end))
	local _animationPlaying = self._animationPlaying

	if _animationPlaying ~= nil then
		local value = _animationPlaying.Value == true
		local _lockJanitor = self._lockJanitor
		self._lockJanitor:Add(_animationPlaying:GetPropertyChangedSignal("Value"):Connect(function()
			if _animationPlaying.Value == true then
				value = true
				return
			end

			if value ~= true then
				return
			end

			task.defer(function()
				if not (self._lockJanitor == _lockJanitor and _animationPlaying.Value ~= true) then
					return
				end

				Remotes.fireServerComponent(self.Instance, "StopStandDown")
				self:_Unlock()
			end)
		end))
	end

	self._lockJanitor:Add(localPlayer.CharacterRemoving:Connect(function()
		self:_Unlock()
	end))
end

function v:_BindCharacter(instance)
	local maid = Janitor.new()
	self._Janitor:Add(maid, "Destroy", "Character")

	-- equivalent calls inferred from this helper; original call sites unknown
	local function onStandDownChanged()
		if instance:GetAttribute("VelociraptorStandDown") == true then
			self:_Lock()
		else
			self:_Unlock()
		end
	end

	maid:Add(instance:GetAttributeChangedSignal("VelociraptorStandDown"):Connect(onStandDownChanged))
	onStandDownChanged() -- equivalent call inferred; original call site unknown
end

function v:Start()
	self._animationPlaying = localPlayer:WaitForChild("PlayerGui"):WaitForChild("Player8Handler"):WaitForChild("AnimationPlaying")

	if localPlayer.Character ~= nil then
		self:_BindCharacter(localPlayer.Character)
	end

	self._Janitor:Add(localPlayer.CharacterAdded:Connect(function(character)
		self:_BindCharacter(character)
	end))
end

function v:Stop()
	self:_Unlock()
	self._Janitor:Destroy()
end

return v