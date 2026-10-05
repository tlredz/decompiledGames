local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local ReplicatedDataController = require(ReplicatedStorage.Modules.Client.Data.ReplicatedDataController)
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local v = Component.new({
	Tag = "Summer2026TokenCollectable"
})

function v:Construct()
	self._Janitor = Janitor.new()
	self._originalPivot = {}
	self._originalPitch = {}
	self._originalYaw = {}
	self._originalRoll = {}
	self._currentYawDegrees = {}
	local v2 = math.random(360)

	for _, child in self.Instance:GetChildren() do
		self._originalPivot[child] = child.CFrame
		local _originalPitch = self._originalPitch
		local _originalYaw = self._originalYaw
		local _originalRoll = self._originalRoll
		local eulerAnglesXYZ, v3, v4 = self._originalPivot[child]:ToEulerAnglesXYZ()
		_originalPitch[child] = eulerAnglesXYZ
		_originalYaw[child] = v3
		_originalRoll[child] = v4
		self._currentYawDegrees[child] = math.deg(self._originalYaw[child]) + v2
	end

	self._alive = false
	self._debounce = false
	self._accDeltaTime = 0
end

function v:_forEachPart(callback)
	if self.Instance:IsA("BasePart") then
		callback(self.Instance)
	end

	for _, part in self.Instance:GetDescendants() do
		if part:IsA("BasePart") then
			callback(part)
		end
	end
end

function v:_hideLocally()
	self._alive = false
	self:_forEachPart(function(p)
		p.LocalTransparencyModifier = 1
	end)
end

function v:Collect()
	if not self._alive or self._debounce then
		return
	end

	self._debounce = true
	task.delay(0.5, function()
		self._debounce = false
	end)

	if Remotes.invokeServer("Summer2026_TokenCollected", self.Instance) ~= true then
		return
	end

	self._alive = false

	for _, child in ReplicatedStorage.LiveOps.EggCollectedEffects:GetChildren() do
		local clone = child:Clone()
		Debris:AddItem(clone, 3)
		clone.Parent = self.Instance:FindFirstChildWhichIsA("BasePart")
	end

	for _, descendant in self.Instance:GetDescendants() do
		if descendant:IsA("ParticleEmitter") then
			descendant:Emit(descendant:GetAttribute("EmitCount") or 10)
		elseif descendant:IsA("Sound") then
			descendant.PlaybackSpeed = math.random(90, 130) / 100
			descendant:Play()
		end
	end

	local height = self.Instance:GetAttribute("Height") or 5

	for _, child in self.Instance:GetChildren() do
		TweenService:Create(child, TweenInfo.new(0.75, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			CFrame = child.CFrame + Vector3.new(0, height, 0)
		}):Play()
	end

	task.wait(0.4)
	self:_forEachPart(function(p)
		TweenService:Create(p, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
			LocalTransparencyModifier = 1
		}):Play()
	end)
end

function v:Start()
	local v2, v3 = ReplicatedDataController.GetClientReplicaPromise():await()

	if not v2 or v3 == nil then
		return
	end

	local v4 = (v3.Data.LiveOpsEventData.SummerCarnival2026.TokensCollected or {})[self.Instance.Name]

	if typeof(v4) == "number" and math.floor((v4 - 1783551600) / 86400) >= math.floor((os.time() - 1783551600) / 86400) then
		self:_hideLocally()
		return
	end

	self._alive = true
	self:_forEachPart(function(p)
		self._Janitor:Add(p.Touched:Connect(function(otherPart)
			if Players.LocalPlayer.Character ~= nil and otherPart:IsDescendantOf(Players.LocalPlayer.Character) then
				self:Collect()
			end
		end))
	end)
end

function v:RenderSteppedUpdate(p: number)
	if not self._alive then
		return
	end

	local _, v2 = workspace.CurrentCamera:WorldToViewportPoint(self.Instance:GetChildren()[1].CFrame.Position)

	if not v2 or (workspace.CurrentCamera.CFrame.Position - self.Instance:GetChildren()[1].Position).Magnitude > 220 then
		return
	end

	local v3 = (math.sin(os.clock() * 2) + 1) * 0.5 * 1

	for _, child in self.Instance:GetChildren() do
		self._currentYawDegrees[child] = self._currentYawDegrees[child] + p * 30
		local cframe = CFrame.fromEulerAnglesXYZ(
			self._originalPitch[child],
			math.rad(self._currentYawDegrees[child]),
			self._originalRoll[child]
		)
		child.CFrame = CFrame.new(self._originalPivot[child].Position + Vector3.new(0, v3, 0)) * cframe
	end
end

function v:Stop()
	self._Janitor:Destroy()
end

return v