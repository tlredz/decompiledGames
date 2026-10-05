local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContentProvider = game:GetService("ContentProvider")
local RunService = game:GetService("RunService")
require(ReplicatedStorage.Shared.EventTypes)
local ClientEventUtils = require(ReplicatedStorage.Controllers.EventController.ClientEventUtils)
local EffectController = require(ReplicatedStorage.Controllers.EffectController)
local EventController = require(ReplicatedStorage.Controllers.EventController)
local SoundController = require(ReplicatedStorage.Controllers.SoundController)
local ServerData = require(ReplicatedStorage.Datas.ServerData)
local Observers = require(ReplicatedStorage.Packages.Observers)
local Trove = require(ReplicatedStorage.Packages.Trove)
local Net = require(ReplicatedStorage.Packages.Net)
local remoteEvent = Net:RemoteEvent("EventService/Job Job Job Sahur/Burst")
local name = script.Name
local maid = Trove.new()

local function initActivationVisual()
	local maid2 = maid:Extend()
	local v = table.create(4)
	maid2:Add(function()
		table.clear(v)
	end)
	local total = 0
	maid2:Add(RunService.PreRender:Connect(function(dt: number)
		debug.profilebegin("Job Job Job Sahur Event")
		total += dt

		for k, v2 in pairs(v) do
			if not (v2.target and v2.targetAttachment) then
				continue
			end

			v2.beam.First.Enabled = true
			v2.beam.Second.Enabled = true
			local v3 = math.clamp(total - k + 1, 0, 1)
			local worldPosition = v2.beam.WorldPosition
			v2.targetAttachment.Position = worldPosition + (v2.target:GetPivot().Position - worldPosition) * v3
		end

		debug.profileend()
	end))
	maid2:Add(Observers.observeTag("JobJobJobSahurPlayerVFX", function(parent)
		local clone = script.PlayerVFX.Beam:Clone()
		clone.Parent = parent
		local clone2 = script.PlayerVFX.Torso:Clone()
		clone2.Parent = parent
		local jobJobJobSahurIndex = parent:GetAttribute("JobJobJobSahurIndex")

		if type(jobJobJobSahurIndex) == "number" then
			v[jobJobJobSahurIndex] = {
				beam = clone,
				target = nil
			}
			local v2 = Observers.observeTag("JobJobJobSahurPlayerVFX", function(target)
				if target == parent then
					return nil
				end

				local jobJobJobSahurIndex2 = target:GetAttribute("JobJobJobSahurIndex")

				if type(jobJobJobSahurIndex2) ~= "number" or jobJobJobSahurIndex2 ~= jobJobJobSahurIndex % 4 + 1 then
					return nil
				end

				local attachment = Instance.new("Attachment")
				attachment.Position = clone.WorldPosition
				attachment.Parent = workspace.Terrain
				local v3 = v[jobJobJobSahurIndex]
				v3.target = target
				v3.beam.First.Attachment0 = attachment
				v3.beam.Second.Attachment0 = attachment
				v3.targetAttachment = attachment
				return function()
					attachment:Destroy()
				end
			end)
			return function()
				clone2:Destroy()
				clone:Destroy()
				v2()
				v[jobJobJobSahurIndex] = nil
			end
		else
			clone:Destroy()
			clone2:Destroy()
			return nil
		end
	end))
end

local JobJobJobSahur = {}

function JobJobJobSahur.OnStart(_)
	local activeEventData = EventController:GetActiveEventData(name)
	assert(activeEventData)

	local function showMap()
		ReplicatedStorage:SetAttribute("JobJobJobSahurEvent", true)
		SoundController:UpdateAmbience()
		maid:Add(function()
			ReplicatedStorage:SetAttribute("JobJobJobSahurEvent", nil)
			SoundController:UpdateAmbience()
		end)
		EffectController:Activate("Blink")
		maid:Add(function()
			EffectController:Activate("Blink")
		end)
		EffectController:Run(name, "GrassRecolor")
		EffectController:Run(name, "WallRecolor")
		EffectController:Run(name, "WallBottomRecolor")
		maid:Add(function()
			EffectController:Stop(name, "GrassRecolor")
			EffectController:Stop(name, "WallRecolor")
			EffectController:Stop(name, "WallBottomRecolor")
		end)
		maid:Add(Observers.observeTag("HideInJobJobJobSahur", function(p)
			local parent = p.Parent
			p.Parent = script
			return function()
				pcall(function()
					p.Parent = parent
				end)
			end
		end, { workspace, script }))

		if not ServerData.IsJumpLTMServer() then
			local clone = maid:Clone(script.JobJobJobSahurMap)
			clone.Parent = workspace
		end
	end

	local v = math.max(0, activeEventData.startedAt + 4 - workspace:GetServerTimeNow())

	if v > 0 then
		maid:Add(task.spawn(initActivationVisual))
	end

	maid:Add(task.delay(v, showMap))
end

function JobJobJobSahur.OnStop(_)
	maid:Destroy()
end

function JobJobJobSahur.OnLoad(_)
	task.spawn(pcall, function()
		ContentProvider:PreloadAsync(script:GetChildren())
	end)
	remoteEvent.OnClientEvent:Connect(function(p: string, vector: Vector3?)
		ClientEventUtils.playBurst(script.Burst, vector or p, { ReplicatedStorage.Sounds.Events[name].Burst })
	end)
end

return JobJobJobSahur