local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local CharacterUtil = require(ReplicatedStorage.Modules.Shared.Utils.CharacterUtil)
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local v = Component.new({
	Tag = "EggHuntCollectable"
})

function v:Construct()
	self._Janitor = Janitor.new()
	self._cframeValue = self._Janitor:Add(Instance.new("CFrameValue"))
	self._originalPivot = self.Instance:GetPivot()
	self._cframeValue.Value = self._originalPivot
	self._Janitor:Add(self._cframeValue.Changed:Connect(function()
		self.Instance:PivotTo(self._cframeValue.Value)
	end))
	self._alive = true
	self._debounce = false
	self._activeVehicle = nil
	self._lastCheckTime = 0
end

function v:Collect()
	warn("Collecting egg")

	if not self._alive then
		warn("Egg is not alive")
		return false
	end

	if self._debounce then
		warn("Debounce active")
		return false
	end

	self._debounce = true
	task.delay(0.5, function()
		self._debounce = false
	end)

	if not Remotes.invokeServer("EggCollected", self.Instance.Name) then
		warn("Could not collect egg")
		return false
	end

	self.Instance:SetAttribute("Collected", true)
	self._alive = false

	for _, child in ReplicatedStorage.LiveOps.EggHunts.EggCollectedEffects:GetChildren() do
		local clone = child:Clone()
		clone.Parent = self.Instance
	end

	for _, descendant in self.Instance:GetDescendants() do
		if descendant:IsA("ParticleEmitter") then
			descendant:Emit((descendant:GetAttribute("EmitCount")))
		elseif descendant:IsA("Sound") then
			descendant.PlaybackSpeed = math.random(90, 130) / 100
			descendant:Play()
		end
	end

	local height = self.Instance:GetAttribute("Height") or 5
	TweenService:Create(self._cframeValue, TweenInfo.new(0.75, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Value = self.Instance:GetPivot() + Vector3.new(0, height, 0)
	}):Play()
	task.wait(0.4)

	for _, part in self.Instance:GetDescendants() do
		if part:IsA("BasePart") then
			TweenService:Create(part, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
				Transparency = 1
			}):Play()
		end
	end

	task.delay(0.5, function()
		self.Instance:Destroy()
	end)
	return true
end

function v:Start()
	self._Janitor:Add(Players.LocalPlayer.CharacterAdded:Connect(function(character)
		self:CharacterAdded(character)
	end))
	local character = Players.LocalPlayer.Character

	if character ~= nil then
		self:CharacterAdded(character)
	end
end

function v:CharacterAdded(instance)
	local humanoid = instance:WaitForChild("Humanoid")
	self._Janitor:Add(humanoid:GetPropertyChangedSignal("SeatPart"):Connect(function()
		self:SeatChanged(humanoid.SeatPart)
	end))
	self:SeatChanged(humanoid.SeatPart)
end

function v:SeatChanged(instance)
	if instance then
		for _, ancestor in workspace.Vehicles:GetChildren() do
			if not instance:IsDescendantOf(ancestor) then
				continue
			end

			self._activeVehicle = ancestor
			return
		end
	end

	self._activeVehicle = nil
end

function v:RenderSteppedUpdate()
	if not self._alive then
		return
	end

	local v2 = (math.sin(os.clock() * 2) + 1) * 0.5
	local v3 = self._originalPivot * CFrame.new(0, v2, 0) * CFrame.Angles(0, 0, 0)
	self._cframeValue.Value = v3
	self:CheckDistance()
end

function v:CheckDistance()
	local v2 = self._activeVehicle and 20 or 3
	local _isNearby = self._isNearby
	local now = os.clock()

	if not _isNearby and now - self._lastCheckTime < 0.1 then
		return
	end

	self._lastCheckTime = now

	if not Players.LocalPlayer.Character then
		return
	end

	local distanceTo = CharacterUtil.distanceTo(Players.LocalPlayer.Character, self.Instance)
	self._isNearby = distanceTo and distanceTo <= v2 * 4

	if distanceTo and distanceTo <= v2 then
		self:Collect()
	end
end

function v:Stop()
	self._Janitor:Destroy()
end

return v