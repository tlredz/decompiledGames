local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local GameSdkShared = require(ReplicatedStorage.Packages.GameSdkShared)
local ABTest = require(GameSdkShared.Modules.ABTest)
local v = Component.new({
	Tag = "AdaptiveSound",
	Extensions = {
		{
			ShouldConstruct = function(_)
				local v2, v3 = ABTest.GetExperimentVariable("adaptive-sounds", "enabled"):timeout(5):await()
				return v2 and v3
			end
		}
	}
})
local Promise = require(ReplicatedStorage.Packages.Promise)
local total = 0
local currentCamera = workspace.CurrentCamera
local v2 = {}
local heartbeatConnection = nil
local v3 = {}
setmetatable(v3, {
	__mode = "k"
})

-- equivalent calls inferred from this helper; original call sites unknown
local function CreateRenderSteppedMethod()
	if heartbeatConnection then
		heartbeatConnection:Disconnect()
	end

	heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
		total += dt

		if total >= 0.3333333333333333 then
			total = 0
			local position = currentCamera.CFrame.Position

			for _, v4 in v2 do
				local parent = v4.Instance.Parent

				if parent and not v3[parent] then
					if parent:IsA("BasePart") then
						v3[parent] = "Position"
					elseif parent:IsA("Attachment") then
						v3[parent] = "WorldPosition"
					end
				end

				local v5 = v3[parent] and parent[v3[parent]] or nil

				if not v5 then
					continue
				end

				local v6 = (position.X - v5.X) ^ 2 + (position.Y - v5.Y) ^ 2 + (position.Z - v5.Z) ^ 2

				if v6 <= v4.MaxDistanceSquared then
					v4:StreamIn()
				elseif v4.MaxDistanceSquared < v6 then
					v4:StreamOut()
				end
			end
		end
	end)
end

function v:Construct()
	self._Janitor = Janitor.new()

	if self.Instance.Parent and (self.Instance.Parent:IsA("Attachment") or self.Instance.Parent:IsA("BasePart")) then
		self.IsStreamed = true
		self:SetupWorkspaceBehaviour()
		return self
	else
		self.IsStreamed = false

		if self.Instance.IsPlaying then
			self:StreamIn()
		else
			self._Janitor:Add(self.Instance.Played:Once(function()
				self:StreamIn()
			end))
		end
	end
end

function v.Adios(p)
	p.Instance:SetAttribute("s", nil)
	CollectionService:RemoveTag(p.Instance, p.Tag)
end

function v:StreamOut()
	if self.IsStreamed == false or not CollectionService:HasTag(self.Instance, self.Tag) then
		return
	end

	self.IsStreamed = false

	if self.Instance.Playing then
		self.streamOutTime = os.clock()
		self.timePositionAtStreamOut = self.Instance.TimePosition
	end

	if self.Instance.SoundId ~= self.cachedSoundId then
		self.cachedSoundId = self.Instance.SoundId
		self.Instance:SetAttribute("s", self.cachedSoundId)
	end

	self.Instance.SoundId = "rbxassetid://122929786531506"
end

function v:StreamIn()
	if self.IsStreamed == true or not CollectionService:HasTag(self.Instance, self.Tag) or self.Instance.SoundId ~= "rbxassetid://122929786531506" then
		return
	end

	local playing = self.Instance.Playing
	self.Instance.SoundId = self.Instance:GetAttribute("s")
	self.IsStreamed = true

	if not playing then
		if self._promiseJanitor then
			self._promiseJanitor:Destroy()
			self._promiseJanitor = nil
		end

		self._promiseJanitor = Janitor.new()
		self._promiseJanitor:Add(self.Instance:GetPropertyChangedSignal("Playing"):Once(function()
			playing = true
		end))
	end

	local function adjustTimePosition()
		if not (self.streamOutTime and self.timePositionAtStreamOut) then
			return
		end

		local v4 = os.clock() - self.streamOutTime
		local timePosition = self.timePositionAtStreamOut + v4

		if self.Instance.Playing then
			if self.Instance.Looped then
				self.Instance.TimePosition = timePosition % self.Instance.TimeLength
			else
				self.Instance.TimePosition = timePosition
			end
		end
	end

	if self.Instance.IsLoaded then
		if playing or self.Instance.Playing then
			self.Instance:Play()
			adjustTimePosition()
		end
	else
		Promise.new(function(callback)
			self._Janitor:Add(self.Instance:GetPropertyChangedSignal("IsLoaded"):Connect(function()
				callback()
			end))

			if self.Instance.IsLoaded then
				callback()
			end
		end):timeout(20):andThen(function(_)
			if playing or self.Instance.Playing then
				if self._promiseJanitor then
					self._promiseJanitor:Destroy()
					self._promiseJanitor = nil
				end

				self.Instance:Play()
				adjustTimePosition()
			end
		end):catch(function(_) end)
	end
end

function v:SetupWorkspaceBehaviour()
	if self.Instance.RollOffMaxDistance == 10000 then
		self.MaxDistanceSquared = (self.Instance.RollOffMinDistance * 20) ^ 2
	else
		self.MaxDistanceSquared = self.MaxDistanceSquared and self.MaxDistanceSquared or (self.Instance.RollOffMinDistance * 10) ^ 2
	end

	self.IsWorkspaceSound = false
	table.insert(v2, self)

	if self.MaxDistanceSquared < 250000 and not self.Instance.Playing then
		if not heartbeatConnection then
			CreateRenderSteppedMethod() -- equivalent call inferred; original call site unknown
		end
	else
		self._Janitor:Add(self.Instance:GetPropertyChangedSignal("Playing"):Once(function()
			self:StreamIn()
		end))
	end
end

function v:Stop()
	local index = table.find(v2, self)

	if index then
		table.remove(v2, index)

		if #v2 == 0 then
			heartbeatConnection:Disconnect()
			heartbeatConnection = nil
		end
	end

	if self._promiseMaid then
		self._promiseMaid:Destroy()
		self._promiseMaid = nil
	end

	if self._promiseJanitor then
		self._promiseJanitor:Destroy()
		self._promiseJanitor = nil
	end

	self._Janitor:Destroy()
end

return v