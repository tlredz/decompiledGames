local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
game:GetService("Lighting")
local Players = game:GetService("Players")
require(ReplicatedStorage.Shared.EventTypes)
local ClientEventUtils = require(ReplicatedStorage.Controllers.EventController.ClientEventUtils)
local EffectController = require(ReplicatedStorage.Controllers.EffectController)
local SoundController = require(ReplicatedStorage.Controllers.SoundController)
local EventController = require(ReplicatedStorage.Controllers.EventController)
local CycleController = require(ReplicatedStorage.Controllers.CycleController)
local Observers = require(ReplicatedStorage.Packages.Observers)
local ServerData = require(ReplicatedStorage.Datas.ServerData)
local Trove = require(ReplicatedStorage.Packages.Trove)
local Net = require(ReplicatedStorage.Packages.Net)
local name = script.Name
local remoteEvent = Net:RemoteEvent("EventService/Easter/Burst")
local maid = Trove.new()

-- equivalent calls inferred from this helper; original call sites unknown
local function loadAnimation(animator, animation, maid2)
	local track = animator:LoadAnimation(animation);
	(maid2 or maid):Add(function()
		track:Stop(0)
		track:Destroy()
	end)
	return track
end

local Easter = {}

function Easter.OnStart(_)
	assert((EventController:GetActiveEventData(name)))
	maid:Add(function()
		EffectController:Activate("Blink")
		CycleController:Update()
		SoundController:UpdateOST()
		SoundController:UpdateAmbience()
	end)

	if ServerData.IsBiggerServer() then
		local clone_2 = maid:Clone(script.MapBigger)
		clone_2.Parent = workspace
	elseif ServerData.IsTsunamiServer() then
		local clone_3 = maid:Clone(script.MapTsunami)
		clone_3.Parent = workspace
	else
		local clone_4 = maid:Clone(script.Map)
		clone_4.Parent = workspace
	end

	maid:Add(Observers.observeTag("HideInEaster", function(p)
		local parent = p.Parent
		p.Parent = script
		return function()
			pcall(function()
				p.Parent = parent
			end)
		end
	end, { workspace, script }))
	EffectController:Activate("Blink")
	CycleController:Update()
	SoundController:UpdateOST()
	SoundController:UpdateAmbience()
	EffectController:Run("EasterEvent", "GrassRecolor")
	maid:Add(function()
		EffectController:Stop("EasterEvent", "GrassRecolor")
	end)
	EffectController:Run("EasterEvent", "WallBottomRecolor")
	maid:Add(function()
		EffectController:Stop("EasterEvent", "WallBottomRecolor")
	end)
	maid:Add(Observers.observeTag("EasterEventBunny", function(part)
		local maid2 = Trove.new()
		local parent = part.Parent
		local clone = maid2:Clone(script.Bunny)
		clone:ScaleTo(parent:GetAttribute("Scale") or 1)
		clone.Parent = workspace
		local weld = Instance.new("Weld")
		weld.Part0 = clone.PrimaryPart
		weld.Part1 = part
		weld.C0 = clone.PrimaryPart.PivotOffset
		weld.Parent = clone.PrimaryPart
		local animator = clone.AnimationController.Animator
		local track = loadAnimation(animator, script.BunnyIdle, maid2) -- equivalent call inferred; original call site unknown
		track.Priority = Enum.AnimationPriority.Idle
		track.Looped = true
		track:Play()
		local track2 = loadAnimation(animator, script.BunnyRun, maid2) -- equivalent call inferred; original call site unknown
		track2.Priority = Enum.AnimationPriority.Action
		track2.Looped = true
		local track3 = loadAnimation(animator, script.BunnyAttack, maid2) -- equivalent call inferred; original call site unknown
		track3.Priority = Enum.AnimationPriority.Action4
		track3.Looped = false
		maid2:Add(Observers.observeAttribute(parent, "Moving", function(p)
			if p then
				track2:Play()
			else
				track2:Stop()
			end

			return nil
		end))
		local v4 = nil
		maid2:Add(Observers.observeAttribute(parent, "Jumping", function(p)
			if v4 then
				v4:Destroy()
				v4 = nil
			end

			if p then
				track2:Stop()
				track3:Play()
				local maid3 = maid2:Extend()
				v4 = maid3
				local jumpTarget = parent:GetAttribute("JumpTarget")

				if not jumpTarget then
					return nil
				end

				local jumpTargetIsPlayer = parent:GetAttribute("JumpTargetIsPlayer") or false

				local function getTargetCFrame(flag: boolean?)
					if not jumpTargetIsPlayer then
						return ClientEventUtils.getAnimalCFrame(jumpTarget, flag and {
							top = true
						} or nil)
					end

					local child = Players:FindFirstChild(jumpTarget)

					if not (child and child.Character) then
						return CFrame.identity
					end

					local character = child.Character
					local head = flag and character:FindFirstChild("Head")

					if head then
						return head.CFrame
					end

					return character:GetPivot()
				end

				weld.Enabled = false
				clone.PrimaryPart.Anchored = true
				local position = clone:GetPivot().Position
				local pivot

				if jumpTargetIsPlayer then
					local child = Players:FindFirstChild(jumpTarget)

					if child and child.Character then
						pivot = child.Character:GetPivot()
					else
						pivot = CFrame.identity
					end
				else
					pivot = ClientEventUtils.getAnimalCFrame(jumpTarget, nil)
				end

				local v5 = math.clamp(((pivot.Position - position) * createVector(1, 0, 1)).Magnitude / 20, 0, 1) * 4 + 1
				local total = 0
				maid3:Add(RunService.PreRender:Connect(function(dt: number)
					total += dt

					if total < 0.7666666666666667 then
						local pivot2

						if jumpTargetIsPlayer then
							local child = Players:FindFirstChild(jumpTarget)

							if child and child.Character then
								pivot2 = child.Character:GetPivot()
							else
								pivot2 = CFrame.identity
							end
						else
							pivot2 = ClientEventUtils.getAnimalCFrame(jumpTarget, nil)
						end

						local position2 = pivot2.Position
						local position3 = clone:GetPivot().Position
						local v6 = (position2 - position3) * createVector(1, 0, 1)

						if v6.Magnitude > 0.01 then
							clone:PivotTo(CFrame.lookAt(position3, position3 + v6.Unit))
						end
					else
						local v6 = math.clamp((total - 0.7666666666666667) / 0.5666666666666667, 0, 1)
						local cFrame

						if jumpTargetIsPlayer then
							local child = Players:FindFirstChild(jumpTarget)

							if child and child.Character then
								local character = child.Character
								local head = character:FindFirstChild("Head")

								if head then
									cFrame = head.CFrame
								else
									cFrame = character:GetPivot()
								end
							else
								cFrame = CFrame.identity
							end
						else
							cFrame = ClientEventUtils.getAnimalCFrame(jumpTarget, {
								top = true
							})
						end

						local position2 = cFrame.Position
						local v7 = position.X + (position2.X - position.X) * v6
						local v8 = position.Z + (position2.Z - position.Z) * v6
						local v9

						if v6 <= 0.47058823529411764 then
							v9 = math.sin(v6 / 0.47058823529411764 * 3.141592653589793 * 0.5) * v5
						else
							v9 = math.cos((v6 - 0.47058823529411764) / 0.5294117647058824 * 3.141592653589793 * 0.5) * v5
						end

						local vector2 = Vector3.new(v7, position.Y + v9, v8)
						local v10 = (position2 - position) * createVector(1, 0, 1)

						if v10.Magnitude > 0.01 then
							clone:PivotTo(CFrame.lookAt(vector2, vector2 + v10.Unit))
						else
							clone:PivotTo(CFrame.new(vector2))
						end

						if v6 >= 0.95 then
							local head = jumpTarget

							if jumpTargetIsPlayer then
								local child = Players:FindFirstChild(jumpTarget)

								if child and child.Character then
									head = child.Character:FindFirstChild("Head") or head
								end
							end

							ClientEventUtils.playBurst(
								script.Burst,
								head,
								{ ReplicatedStorage.Sounds.Events.Easter.Hit }
							)
							clone:Destroy()
							maid3:Destroy()
							v4 = nil
						end
					end
				end))
				maid3:Add(function()
					weld.Enabled = true

					if clone.PrimaryPart then
						clone.PrimaryPart.Anchored = false
					end
				end)
				return nil
			else
				track3:Stop(0)
				weld.Enabled = true

				if clone.PrimaryPart then
					clone.PrimaryPart.Anchored = false
				end

				return nil
			end
		end))
		maid2:Add(function()
			if v4 then
				v4:Destroy()
				v4 = nil
			end
		end)
		return maid2:WrapClean()
	end, { workspace }))
	return nil
end

function Easter.OnStop(_)
	maid:Destroy()
end

function Easter.OnLoad(_)
	remoteEvent.OnClientEvent:Connect(function(p)
		ClientEventUtils.playBurst(script.Burst, p, { ReplicatedStorage.Sounds.Events.Easter.Hit })
	end)
end

return Easter