local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Net = require(ReplicatedStorage.Packages.Net)
local Observers = require(ReplicatedStorage.Packages.Observers)
local Trove = require(ReplicatedStorage.Packages.Trove)
local VFX = require(ReplicatedStorage.Shared.VFX)
local SoundController = require(ReplicatedStorage.Controllers.SoundController)
require(ReplicatedStorage.Controllers.WorldBrainrotController)
local remoteEvent = Net:RemoteEvent("EggrotHunt/VolcanoLaunch")
return table.freeze({
	Start = function(_, p)
		local maid = Trove.new()
		local animator = nil
		local v = nil
		local eruptionVFX = nil
		local rippleVFX = nil
		local VFX2 = nil
		local position = nil
		maid:Add(Observers.observeTag("EggrotVolcanoMachine", function(instance)
			local animatedEggSequences = (instance.Parent or instance):FindFirstChild("AnimatedEggSequences", true)

			if not animatedEggSequences then
				return
			end

			local mutateSequence = animatedEggSequences:FindFirstChild("MutateSequence")

			if not mutateSequence then
				return
			end

			local animationController = mutateSequence:FindFirstChild("AnimationController")

			if animationController then
				animator = animationController:FindFirstChild("Animator")
			end

			local anchor = mutateSequence:FindFirstChild("Anchor")
			VFX2 = anchor and anchor:FindFirstChild("VFX")
			local egg = mutateSequence:FindFirstChild("Egg")

			if egg and egg:IsA("BasePart") then
				v = egg
			end

			eruptionVFX = mutateSequence:FindFirstChild("EruptionVFX")
			rippleVFX = animatedEggSequences:FindFirstChild("RippleVFX")
			position = instance:GetPivot().Position
			return function()
				animator = nil
				v = nil
				eruptionVFX = nil
				rippleVFX = nil
				VFX2 = nil
				position = nil
			end
		end, { workspace }))
		maid:Add(remoteEvent.OnClientEvent:Connect(function(p2: string, _: CFrame, _: CFrame, _: number)
			local animator2 = animator
			local v2 = v
			local v3 = true
			local v4 = nil
			local connection = nil
			local v5 = {}
			local v6 = nil

			local function cleanup()
				if v6 then
					maid:Pop(v6)
				end

				if connection then
					connection:Disconnect()
					connection = nil
				end

				for _, v7 in v5 do
					v7.Anchored = false
				end

				table.clear(v5)

				if v4 then
					v4:Stop(0)
					v4:Destroy()
					v4 = nil
				end

				if VFX2 then
					VFX.disable(VFX2)
				end
			end

			if animator2 then
				local track = animator2:LoadAnimation(script.Sequence)
				v4 = track
				track.Looped = false
				track:GetMarkerReachedSignal("VFX_Start"):Once(function()
					if VFX2 then
						VFX.enable(VFX2)
					end
				end)
				track:GetMarkerReachedSignal("Erupt"):Once(function()
					if eruptionVFX then
						VFX.emit(eruptionVFX)
					end

					if position then
						SoundController:PlaySound("Sounds.Events.Easter.VolcanoEruption", position, false)
					end
				end)
				track:GetMarkerReachedSignal("Ripple"):Once(function()
					if rippleVFX then
						VFX.emit(rippleVFX)
					end

					if position then
						SoundController:PlaySound("Sounds.Events.Easter.VolcanoRipple", position, false)
					end
				end)
				track:GetMarkerReachedSignal("VFX_Stop"):Once(function()
					if VFX2 then
						VFX.disable(VFX2)
					end

					v3 = false
					track:Stop(0)
				end)
				track:Play(0)
			end

			if not v2 then
				return
			end

			local function anchorModel(object)
				for _, v7 in object:QueryDescendants("BasePart [Anchored = false]") do
					v7.Anchored = true
					table.insert(v5, v7)
				end
			end

			RunService.PostSimulation:Connect(function()
				if not v3 then
					cleanup()
					return
				end

				local v7 = p[p2]

				if not (v7 and v7.model) then
					return
				end

				if #v5 == 0 then
					for _, v8 in v7.model:QueryDescendants("BasePart [Anchored = false]") do
						v8.Anchored = true
						table.insert(v5, v8)
					end
				end

				v7.model:PivotTo(v2:GetPivot())
			end)
			v6 = maid:Add(cleanup)
		end))
		return function()
			maid:Destroy()
		end
	end
})