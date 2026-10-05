local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("TweenService")
game:GetService("RunService")
local Lighting = game:GetService("Lighting")
game:GetService("Players")
require(ReplicatedStorage.Shared.EventTypes)
local Divine = {}
local ClientEventUtils = require(ReplicatedStorage.Controllers.EventController.ClientEventUtils)
local EffectController = require(ReplicatedStorage.Controllers.EffectController)
local AnimalController = require(ReplicatedStorage.Controllers.AnimalController)
local SoundController = require(ReplicatedStorage.Controllers.SoundController)
local EventController = require(ReplicatedStorage.Controllers.EventController)
local CycleController = require(ReplicatedStorage.Controllers.CycleController)
local Observers = require(ReplicatedStorage.Packages.Observers)
local ServerData = require(ReplicatedStorage.Datas.ServerData)
local Timer = require(ReplicatedStorage.Packages.Timer)
local Trove = require(ReplicatedStorage.Packages.Trove)
local Net = require(ReplicatedStorage.Packages.Net)
require(ReplicatedStorage.Packages.Spr)
require(ReplicatedStorage.Shared.VFX)
local name = script.Name
local remoteEvent = Net:RemoteEvent("EventService/Divine/Hit")
local maid = Trove.new()

function Divine.OnStart(_)
	assert((EventController:GetActiveEventData(name)))
	local atmosphere = Lighting:FindFirstChild("Atmosphere")

	if atmosphere then
		atmosphere.Parent = script
		maid:Add(function()
			atmosphere.Parent = Lighting
		end)
	end

	local clone_2 = maid:Clone(script.AtmosphereDivine)
	clone_2.Parent = Lighting
	EffectController:Activate("Blink")
	maid:Add(function()
		EffectController:Activate("Blink")
	end)
	EffectController:Run("DivineEvent", "GrassRecolor")
	maid:Add(function()
		EffectController:Stop("DivineEvent", "GrassRecolor")
	end)
	EffectController:Run("DivineEvent", "WallRecolor")
	maid:Add(function()
		EffectController:Stop("DivineEvent", "WallRecolor")
	end)
	EffectController:Run("DivineEvent", "WallBottomRecolor")
	maid:Add(function()
		EffectController:Stop("DivineEvent", "WallBottomRecolor")
	end)
	maid:Add(remoteEvent.OnClientEvent:Connect(function(p)
		ClientEventUtils.playBurst(script.Burst, p, { ReplicatedStorage.Sounds.Events.Divine.Hit })
	end))

	if not ServerData.IsJumpLTMServer() then
		if ServerData.IsTsunamiServer() then
			local clone_3 = maid:Clone(script.DivineMapTsunami)
			clone_3.Parent = workspace
		else
			local v = nil
			local clone

			if ServerData.IsBiggerServer() then
				clone = maid:Clone(script.DivineMapBigger)
			else
				clone = maid:Clone(script.DivineMap)
			end

			local v2 = maid:Add(clone.Decor.Stairs)
			local v3 = maid:Add(clone.Gate)
			local v4 = maid:Add(clone.Fill)
			local v5 = nil

			local function updateFill()
				local divineStairsEnabled = ReplicatedStorage:GetAttribute("DivineStairsEnabled") == true

				if v5 == divineStairsEnabled then
					return
				end

				v5 = divineStairsEnabled

				if v then
					v()
					v = nil
				end

				if divineStairsEnabled then
					v = Observers.observeTag("HideInDivineTiedToStairs", function(p)
						local parent = p.Parent
						p.Parent = script
						return function()
							pcall(function()
								p.Parent = parent
							end)
						end
					end, { workspace, script })
					pcall(function()
						v2.Parent = clone.Decor
					end)
					pcall(function()
						v4.Parent = script
					end)
				else
					pcall(function()
						v2.Parent = script
					end)
					pcall(function()
						v4.Parent = clone
					end)
				end
			end

			maid:Add(ReplicatedStorage:GetAttributeChangedSignal("DivineStairsEnabled"):Connect(updateFill))
			maid:Add(clone.Decor.ChildAdded:Connect(updateFill))
			maid:Add(clone.Decor.ChildRemoved:Connect(updateFill))
			maid:Add(task.spawn(updateFill))
			clone.Parent = workspace
			local track = v3.AnimationController.Animator:LoadAnimation(v3.Animation)
			track.Looped = false
			maid:Add(function()
				track:Stop(0)
				track:Destroy()
			end)
			maid:Add(track:GetMarkerReachedSignal("Freeze"):Connect(function()
				track:AdjustSpeed(0)
			end))
			maid:Add(Timer.Simple(0.25, function()
				local flag = false

				for _, v7 in AnimalController:GetAnimals() do
					if not v7.Instance:GetAttribute("InDivineRoad") then
						continue
					end

					local position = v7.Instance:GetPivot().Position

					if not ((v3.Gate.Position - position).Magnitude <= 60) then
						continue
					end

					flag = true
					break
				end

				if flag then
					if not track.IsPlaying then
						track:Play()
					end
				elseif track.IsPlaying then
					track:AdjustSpeed(1)
				end
			end, true))
		end
	end

	maid:Add(Observers.observeTag("HideInDivine", function(p)
		local parent = p.Parent
		p.Parent = script
		return function()
			pcall(function()
				p.Parent = parent
			end)
		end
	end, { workspace, script }))
	maid:Add(Observers.observeTag("ShowInDivine", function(instance)
		local parent = instance.Parent
		local v = false
		local destroyingConnection = parent.Destroying:Once(function()
			v = true
			instance:Destroy()
		end)
		instance.Parent = script
		return function()
			destroyingConnection:Disconnect()

			if not v then
				pcall(function()
					instance.Parent = parent
				end)
			end
		end
	end, { workspace, script }))
	CycleController:Update()
	SoundController:UpdateOST()
end

function Divine.OnStop(_)
	maid:Destroy()
end

function Divine.OnLoad(_) end

return Divine