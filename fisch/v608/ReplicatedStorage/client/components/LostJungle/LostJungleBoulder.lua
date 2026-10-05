local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local packages = ReplicatedStorage.packages
local Net = require(packages.Net)
local Component = require(packages.Component)
local DataController = require(ReplicatedStorage.client.legacyControllers.DataController)
local playerDataReplicator = DataController.PlayerDataReplicator
local SettingsController = require(ReplicatedStorage.client.legacyControllers.SettingsController)
local Trove = require(packages.Trove)
local remoteEvent = Net:RemoteEvent("LostJungle/DestroyBoulder")
local v = Component.new({
	Tag = "LostJungleBoulder"
})
local v2 = false

local function setFumesState(folder, flag: boolean)
	for _, emitter in ipairs(folder:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = flag and SettingsController:GetSettingValue("shownVfx") ~= "HideAll"
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function applyFumesAll(flag: boolean)
	for _, v3 in ipairs(CollectionService:GetTagged("ToxicFumes")) do
		setFumesState(v3, flag)
	end
end

local function playExplosion(instance)
	local sfx_1 = instance:FindFirstChild("sfx_1")

	if sfx_1 then
		sfx_1:Play()
	end

	local sfx_2 = instance:FindFirstChild("sfx_2")

	if sfx_2 then
		sfx_2:Play()
	end

	local ohmygahhh = math.random(100) == 1 and instance:FindFirstChild("ohmygahhh")

	if ohmygahhh then
		ohmygahhh:Play()
	end
end

function v:Construct()
	self._trove = Trove.new()
end

function v:Start()
	applyFumesAll(v2) -- equivalent call inferred; original call site unknown
	self._trove:Add(CollectionService:GetInstanceAddedSignal("ToxicFumes"):Connect(function(p2)
		setFumesState(p2, v2)
	end))
	self._trove:Connect(SettingsController:GetSettingChangedSignal("shownVfx"), function()
		applyFumesAll(v2) -- equivalent call inferred; original call site unknown
	end)
	playerDataReplicator:WaitForLoaded()
	local index = playerDataReplicator:Index({ "LostJungle" })

	if not (index and index.BoulderDestroyed) then
		self._trove:Add(remoteEvent.OnClientEvent:Connect(function()
			playExplosion(self.Instance)
			task.wait(1.5)

			for _, part in ipairs(self.Instance:GetDescendants()) do
				if not part:IsA("BasePart") then
					continue
				end

				part.Transparency = 1
				part.CanCollide = false
			end

			v2 = true
			applyFumesAll(true) -- equivalent call inferred; original call site unknown
			task.spawn(function()
				task.wait(2.5)
				local currentCamera = workspace.CurrentCamera
				local lastTime = tick()

				while true do
					local v4 = tick() - lastTime

					if v4 >= 2 then
						break
					end

					local v5 = 1 - v4 / 2
					local v6 = v4 * 4 * 3.141592653589793 * 2
					local cframe = CFrame.Angles(
						math.rad(math.sin(v6) * 0.15 * v5),
						math.rad(math.cos(v6 * 0.7) * 0.15 * v5),
						0
					)
					currentCamera.CFrame *= cframe
					task.wait()
				end
			end)
			task.delay(15, function()
				if self.Instance then
					self.Instance:Destroy()
				end
			end)
		end))
		return
	end

	v2 = true
	applyFumesAll(true) -- equivalent call inferred; original call site unknown
	self.Instance:Destroy()
end

function v:Stop()
	if self._trove then
		self._trove:Destroy()
		self._trove = nil
	end
end

return v