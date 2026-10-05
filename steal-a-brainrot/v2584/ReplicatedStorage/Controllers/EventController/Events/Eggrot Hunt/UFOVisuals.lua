local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ClientEventUtils = require(ReplicatedStorage.Controllers.EventController.ClientEventUtils)
local CreateTween = require(ReplicatedStorage.Packages.CreateTween)
local Observers = require(ReplicatedStorage.Packages.Observers)
local Trove = require(ReplicatedStorage.Packages.Trove)
local Net = require(ReplicatedStorage.Packages.Net)
local UFO = ReplicatedStorage.Models.Events.UFO.UFO
local remoteEvent = Net:RemoteEvent("EventService/UFO/AbductionBurst")
return table.freeze({
	Start = function(_)
		local maid = Trove.new()
		maid:Add(Observers.observeTag("EggrotUFO", function(part)
			if not part:IsA("BasePart") then
				return nil
			end

			local maid2 = maid:Extend()
			local clone = maid2:Clone(UFO)

			for _, part2 in clone:GetDescendants() do
				if not part2:IsA("BasePart") then
					continue
				end

				part2.Anchored = true
				part2.CanCollide = false
				part2.CanQuery = false
				part2.CanTouch = false
			end

			local clone2 = ReplicatedStorage.Sounds.Events.UFO.Flying:Clone()
			clone2.Parent = part
			clone2:Play()
			clone.Parent = workspace
			local beamPart = clone:FindFirstChild("BeamPart", true)
			local att0 = beamPart and beamPart:FindFirstChild("att0")
			local att1 = beamPart and beamPart:FindFirstChild("att1")

			if not (beamPart and att0 and att1 and att0:IsA("Attachment") and att1:IsA("Attachment")) then
				maid2:Destroy()
				return nil
			end

			local beams = {}

			for _, beam in att1:GetChildren() do
				if not beam:IsA("Beam") then
					continue
				end

				beam.Attachment0 = att0
				beam.Attachment1 = att1
				beam.Enabled = false
				table.insert(beams, beam)
			end

			local position = att1.Position
			local v = nil

			-- equivalent calls inferred from this helper; original call sites unknown
			local function stopTween()
				if v then
					v:Cancel()
					v = nil
				end
			end

			-- equivalent calls inferred from this helper; original call sites unknown
			local function setBeams(enabled: boolean)
				for _, v2 in beams do
					v2.Enabled = enabled
				end
			end

			-- equivalent calls inferred from this helper; original call sites unknown
			local function tweenAtt1(position2: Vector3, duration: number)
				stopTween() -- equivalent call inferred; original call site unknown
				v = CreateTween(att1, TweenInfo.new(duration, Enum.EasingStyle.Quad), {
					Position = position2
				})
				return v
			end

			local function setState(beamState: string)
				if beamState == "down" then
					local clone3 = ReplicatedStorage.Sounds.Events.UFO.Abducting:Clone()
					clone3.Parent = part
					clone3:Play()
					setBeams(true) -- equivalent call inferred; original call site unknown
					att1.Position = att0.Position
					stopTween() -- equivalent call inferred; original call site unknown
					v = CreateTween(att1, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {
						Position = position
					})
				elseif beamState == "off" then
					local v2 = tweenAtt1(att0.Position, 0.5) -- equivalent call inferred; original call site unknown

					if v2 then
						v2.Completed:Wait()
					end

					setBeams(false) -- equivalent call inferred; original call site unknown
					att1.Position = position
				end
			end

			maid2:Add(part:GetAttributeChangedSignal("BeamState"):Connect(function()
				local beamState = part:GetAttribute("BeamState")

				if typeof(beamState) == "string" then
					setState(beamState)
				end
			end))
			maid2:Add(RunService.PostSimulation:Connect(function()
				if clone.PrimaryPart == nil or part.Parent == nil then
					maid2:Destroy()
				else
					clone:PivotTo(part.CFrame)
				end
			end))
			maid2:Add(stopTween)
			maid2:Add(task.spawn(function()
				local beamState = part:GetAttribute("BeamState")

				if typeof(beamState) == "string" then
					setState(beamState)
					return
				end

				setBeams(false) -- equivalent call inferred; original call site unknown
				att1.Position = position
			end))
			return function()
				maid2:Destroy()
			end
		end, { workspace }))
		maid:Add(remoteEvent.OnClientEvent:Connect(function(vector: Vector3)
			local effects = ReplicatedStorage.Controllers.EventController.Events.UFO:FindFirstChild("Effects")
			local ufoemit = effects and effects:FindFirstChild("ufoemit")

			if ufoemit then
				ClientEventUtils.playBurst(ufoemit, vector, { ReplicatedStorage.Sounds.Events.UFO.Burst })
			end
		end))
		return function()
			maid:Destroy()
		end
	end
})