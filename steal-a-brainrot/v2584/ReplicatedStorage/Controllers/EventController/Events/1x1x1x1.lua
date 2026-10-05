local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContentProvider = game:GetService("ContentProvider")
game:GetService("TweenService")
local RunService = game:GetService("RunService")
game:GetService("Lighting")
local Players = game:GetService("Players")
game:GetService("Debris")
require(ReplicatedStorage.Shared.EventTypes)
local _1x1x1x1 = {}
require(ReplicatedStorage.Controllers.EncryptedAssetsController)
require(ReplicatedStorage.Controllers.AnimalController)
require(ReplicatedStorage.Controllers.EffectController)
require(ReplicatedStorage.Controllers.CameraController)
local SoundController = require(ReplicatedStorage.Controllers.SoundController)
local EventController = require(ReplicatedStorage.Controllers.EventController)
require(ReplicatedStorage.Controllers.CycleController)
require(ReplicatedStorage.Shared.SharedEventUtils)
require(ReplicatedStorage.Packages.CreateTween)
require(ReplicatedStorage.Shared.TweenPivot)
local ServerData = require(ReplicatedStorage.Datas.ServerData)
local Observers = require(ReplicatedStorage.Packages.Observers)
local MathUtils = require(ReplicatedStorage.Utils.MathUtils)
require(ReplicatedStorage.Shared.Animals)
require(ReplicatedStorage.Packages.Signal)
local Trove = require(ReplicatedStorage.Packages.Trove)
require(ReplicatedStorage.Packages.Shake)
local Timer = require(ReplicatedStorage.Packages.Timer)
local Spr = require(ReplicatedStorage.Packages.Spr)
require(ReplicatedStorage.Packages.Net)
require(ReplicatedStorage.Shared.VFX)
local localPlayer = Players.LocalPlayer
local currentCamera = workspace.CurrentCamera
local v = CFrame.new(-410.5, -8, -228.54) + (ServerData.IsBiggerServer() and createVector(0, 0, -251) or createVector(
	0,
	0,
	0
))
local name = script.Name
local maid = Trove.new()

local function initActivationVisual()
	local maid2 = maid:Extend()
	local v2 = table.create(4)
	maid2:Add(function()
		table.clear(v2)
	end)
	local total = 0
	maid2:Add(RunService.PreRender:Connect(function(dt: number)
		debug.profilebegin("1x1x1x1 Event")
		total += dt

		for k, v3 in v2 do
			if not (v3.target and v3.targetAttachment) then
				continue
			end

			v3.beam.First.Enabled = true
			v3.beam.Second.Enabled = true
			local v4 = math.clamp(total - k + 1, 0, 1)
			local worldPosition = v3.beam.WorldPosition
			v3.targetAttachment.Position = worldPosition + (v3.target:GetPivot().Position - worldPosition) * v4
		end

		debug.profileend()
	end))
	maid2:Add(Observers.observeTag("1x1x1x1PlayerVFX", function(parent)
		local _1x1x1x1PlayerVFXVariant = parent:GetAttribute("1x1x1x1PlayerVFXVariant") or "Green"
		local v3 = script[`PlayerVFX_{_1x1x1x1PlayerVFXVariant}`]
		local clone = v3.Beam:Clone()
		clone.Parent = parent
		local clone2 = v3.Torso:Clone()
		clone2.Parent = parent
		local _1x1x1x1Index = parent:GetAttribute("1x1x1x1Index")
		v2[_1x1x1x1Index] = {
			beam = clone,
			target = nil
		}
		local v4 = Observers.observeTag("1x1x1x1PlayerVFX", function(target)
			if not (target ~= parent and target:GetAttribute("1x1x1x1Index") == parent:GetAttribute("1x1x1x1Index") % 4 + 1) then
				return nil
			end

			local attachment = Instance.new("Attachment")
			attachment.Position = clone.WorldPosition
			attachment.Parent = workspace.Terrain
			local v5 = v2[parent:GetAttribute("1x1x1x1Index")]
			v5.target = target
			v5.beam.First.Attachment0 = attachment
			v5.beam.Second.Attachment0 = attachment
			v5.targetAttachment = attachment
			return function()
				attachment:Destroy()
			end
		end)
		total = 0
		return function()
			clone2:Destroy()
			clone:Destroy()
			v4()
			v2[_1x1x1x1Index] = nil
		end
	end))
end

local function loadAnimation(animator, animation, p)
	local track = animator:LoadAnimation(animation);
	(p or maid):Add(function()
		track:Stop(0)
		track:Destroy()
	end)
	return track
end

function _1x1x1x1.OnStart(_)
	assert((EventController:GetActiveEventData(name)))
	maid:Add(task.spawn(initActivationVisual))
end

function _1x1x1x1.OnStop(_)
	maid:Destroy()
end

function _1x1x1x1.OnLoad(_)
	task.spawn(pcall, function()
		ContentProvider:PreloadAsync(script:GetChildren())
	end)
	Observers.observeTag("1x1x1x1Map", function(p)
		local maid2 = Trove.new()
		maid2:Add(Observers.observeTag("HideIn1x1x1x1", function(p2)
			local parent = p2.Parent
			p2.Parent = script
			return function()
				pcall(function()
					p2.Parent = parent
				end)
			end
		end, { workspace, script }))
		local v2 = nil
		maid2:Add(Timer.Simple(0.25, function()
			if not localPlayer.Character then
				return
			end

			if MathUtils.isPointInVolume(currentCamera.CFrame.Position, v, createVector(129, 52, 169.264)) then
				if not v2 then
					v2 = Observers.observeTag("MapVFX", function(p2)
						local parent = p2.Parent
						p2.Parent = script
						return function()
							pcall(function()
								p2.Parent = parent
							end)
						end
					end, { workspace, script })
				end
			elseif v2 then
				v2()
				v2 = nil
			end
		end))
		maid2:Add(function()
			if v2 then
				v2()
				v2 = nil
			end
		end)
		maid2:Add(Observers.observeTag("1x1x1x1Latch", function(instance)
			local pivot = instance:GetPivot()
			return Observers.observeAttribute(instance, "Open", function(p2)
				if p2 then
					Spr.target(instance, 0.75, 3.5, {
						Pivot = pivot * CFrame.Angles(0, -1.5707963267948966, 0)
					})
				else
					Spr.target(instance, 0.75, 3.5, {
						Pivot = pivot
					})
				end

				SoundController:PlaySound(script.Door, pivot.Position, false)
				return function()
					if instance:IsDescendantOf(workspace) then
						Spr.target(instance, 0.75, 3.5, {
							Pivot = pivot
						})
						SoundController:PlaySound(script.Door, pivot.Position, false)
					end
				end
			end)
		end, { p }))
		return maid2:WrapClean()
	end)
end

return _1x1x1x1