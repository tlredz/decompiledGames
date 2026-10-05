local createVector = vector.create
local SubmarineTransportationController = {}
local Realm = require(game.ReplicatedStorage.Util.Realm)
local Net = require(game.ReplicatedStorage.Modules.Net)
local GetWaterHeightAtLocation = require(game.ReplicatedStorage.Util.GetWaterHeightAtLocation)
local v = nil
local v2 = nil
local MapTransitionEffect = require(game.ReplicatedStorage.Controllers.MapServices.Transitions.MapTransitionEffect)
local BuildInfo = require(game.ReplicatedStorage.BuildInfo)
local runAsync = require(game.ReplicatedStorage.Util.runAsync)
local Maid = require(game.ReplicatedStorage.Util.Maid)
local TikiSubmarineController = require(script.TikiSubmarineController)
local maid = Maid.new()

if Realm.getIfCurrentRealmHasTagAsync("IsThirdSea") == false then
	return SubmarineTransportationController
end

SubmarineTransportationController.Enabled = true
local cframe = CFrame.new()
local cframe2 = CFrame.new()
local v3 = not BuildInfo.IS_PUBLISHED

local function log(...)
	if v3 then
		warn(`[{script.Name}]:`, ...)
	end
end

function SubmarineTransportationController.OnStart()
	local DialogueController = require(game.ReplicatedStorage.DialogueController)
	v2 = DialogueController
	v = Net:RemoteFunction("SubmarineTransportation")
end

function SubmarineTransportationController.InvokeAsync(p: string, ...)
	return runAsync(v.InvokeServer, v, p, ...)
end

local Sound = require(game.ReplicatedStorage.Util.Sound)

function SubmarineTransportationController.OpenPortalMenu(p)
	local v4 = {
		Text = 0
	}
	v4.Text = { "Changed your mind?" }
	v2.resumeWhenCallbackFinishes(function()
		maid.PortalMenu = coroutine.running()
		local v5 = {}

		function maid.PortalClose()
			v5.close = true
		end

		local GatewayController = require(game.Players.LocalPlayer.PlayerGui.Main.Gateway.GatewayController)
		local submarine, v6 = SubmarineTransportationController.SpawnSubmarine()
		task.spawn(submarine)
		local v7 = nil
		local thread = task.spawn(function()
			v7 = GatewayController.LoadPriceListAndAwaitSelection(p, v5)
		end)

		while coroutine.status(thread) ~= "dead" do
			task.wait()
		end

		v5.close = true

		if not v7 then
			task.spawn(function()
				v6.sinkSubmarineDeparture()
			end)
			return nil
		end

		v4 = nil
		submarine()
		task.spawn(submarine)
		Sound:Play("LoweringSub", nil)
		task.wait(2.5)
		maid.Transition = MapTransitionEffect.StopEarly
		runAsync(MapTransitionEffect.Play)
		task.wait(0.2)
		local v8 = SubmarineTransportationController.InvokeAsync("InitiateTeleport", v7)
		task.wait(0.2)
		local v9 = v8:awaitResult()

		if typeof(v9) == "table" then
			log("?", v9, v8)
			cframe = v9.Submarine - v9.Submarine.Position.Y * createVector(0, 1, 0) + createVector(0, 1, 0) * GetWaterHeightAtLocation(v9.Submarine.Position)
			cframe2 = cframe - createVector(0, 35, 0)
			warn("arrival", cframe, "below", cframe2)
			submarine()
			task.delay(2, function()
				maid.Transition = nil
				task.wait(5)
				submarine()
				task.delay(3, function()
					submarine()
				end)
			end)
		else
			v4 = {
				Text = { v9 == -1 and "If you'd stop fighting, maybe I would let you into my submarine!" or "... Sorry, I can't do that right now." }
			}
			submarine(true)
			maid.Transition = nil
		end

		local v10

		if not v4 then
			return false
		end

		return v10
	end)
	return v4
end

local function OnSubmarineCaptainInteracted()
	local humanoid = game.Players.LocalPlayer.Character.Humanoid
	local health = humanoid.Health
	local thread = coroutine.running()
	maid.onDamageTaken = humanoid.Changed:Connect(function()
		local health2 = humanoid.Health

		if health2 < health then
			task.defer(function()
				pcall(maid.DoCleaning, maid)

				if coroutine.status(thread) ~= "dead" then
					warn("took dmg while in dialogue")
					task.cancel(thread)
					v2.close()
				end
			end)
		end

		health = health2
	end)
	task.spawn(function()
		repeat
			task.wait()
		until coroutine.status(thread) == "dead"

		task.wait(10)
		pcall(maid.DoCleaning, maid)
	end)
	local v4 = SubmarineTransportationController.InvokeAsync("GetAvailableLocations")
	return {
		Text = { "Ready to head back up? I can make a stop to any island on the way if you'll pay for the fuel" },
		Option1 = {
			Label = "Travel",
			JumpTo = function()
				local v5 = v4:awaitResult()

				if v5 == -1 then
					return {
						Text = { "If you'd stop fighting, maybe I would let you into my submarine!" }
					}
				end

				if v5 then
					return SubmarineTransportationController.OpenPortalMenu(v5)
				end

				return {
					Text = { "... Sorry, I can't do that right now." }
				}
			end
		}
	}
end

function SubmarineTransportationController.InitializeNPC(p)
	p.new("Submarine Worker2", function(_)
		return {
			Title = "Submarine Worker",
			Get = OnSubmarineCaptainInteracted
		}
	end, 4)
	TikiSubmarineController.OnStart(p)
end

local TweenService = game:GetService("TweenService")
local tweenInfo = TweenInfo.new(5, Enum.EasingStyle.Back, Enum.EasingDirection.InOut)
require(game.ReplicatedStorage.Util.Debris)
local v4 = 0

function SubmarineTransportationController.SpawnSubmarine()
	local v5 = math.random()
	v4 = v5
	local v6 = 0
	local currentCamera = workspace.CurrentCamera
	local clone = script.SubmarineModel:Clone()
	local alignPosition = clone:FindFirstChild("AlignPosition", true)
	local alignOrientation = clone:FindFirstChild("AlignOrientation", true)
	alignPosition.Enabled = false
	alignOrientation.Enabled = false
	local cFrame = clone.PrimaryPart.CFrame.Rotation + clone.PrimaryPart.CFrame.Position * createVector(1, 0, 1) + createVector(
		0,
		1,
		0
	) * GetWaterHeightAtLocation(workspace._WorldOrigin.Locations["Submerged Island"].Position) - createVector(0, 35, 0)
	clone.PrimaryPart.CFrame = cFrame
	task.wait()
	local attachment = clone:FindFirstChild("Attachment", true)
	alignPosition.Attachment0 = attachment
	alignOrientation.Attachment0 = attachment
	alignPosition.Position = attachment.WorldPosition
	alignOrientation.CFrame = attachment.WorldCFrame
	task.wait()
	alignPosition.RigidityEnabled = false
	alignPosition.Responsiveness = 50
	alignPosition.MaxForce = 999999999
	alignPosition.MaxVelocity = 20
	task.wait()
	alignPosition.Enabled = true
	alignOrientation.Enabled = true
	clone.Parent = workspace

	local function sinkSubmarineDeparture()
		v6 = 3
		local tween = TweenService:Create(alignPosition, tweenInfo, {
			Position = attachment.WorldPosition - createVector(0, 55, 0)
		})
		tween:Play()

		function maid.LastTween()
			if tween.PlaybackState ~= Enum.PlaybackState.Completed then
				tween:Cancel()
			end
		end

		if tween.PlaybackState ~= Enum.PlaybackState.Completed then
			tween.Completed:Wait()
		end
	end

	local function teleportSubmarineToArrivalLocation()
		maid.LastTween = nil
		v6 = 4
		maid.RestoreCamera = nil
		clone.PrimaryPart.CFrame = cframe
		warn("moved to arrival pivot", cframe)
		alignPosition.Position = attachment.WorldPosition
		alignOrientation.CFrame = attachment.WorldCFrame
	end

	local function sinkSubmarineArrival()
		v6 = 5
		local tween = TweenService:Create(alignPosition, tweenInfo, {
			Position = attachment.WorldPosition - createVector(0, 55, 0)
		})
		tween:Play()

		function maid.LastTween()
			if tween.PlaybackState ~= Enum.PlaybackState.Completed then
				tween:Cancel()
			end
		end

		if tween.PlaybackState ~= Enum.PlaybackState.Completed then
			tween.Completed:Wait()
		end
	end

	local v8 = {
		function()
			v6 = 1
			local tween = TweenService:Create(alignPosition, tweenInfo, {
				Position = attachment.WorldPosition + createVector(0, 35, 0)
			})
			tween:Play()

			function maid.LastTween()
				if tween.PlaybackState ~= Enum.PlaybackState.Completed then
					tween:Cancel()
				end
			end

			if tween.PlaybackState ~= Enum.PlaybackState.Completed then
				tween.Completed:Wait()
			end
		end,
		function()
			v6 = 2
			local CameraController = require(game.ReplicatedStorage.Controllers.CameraController)
			local restoreCamera = CameraController.new()
			maid.RestoreCamera = restoreCamera
			restoreCamera.Animations:AnimateTo(CFrame.lookAt(currentCamera.CFrame.Position, clone:GetPivot().Position))
			task.wait(0.5)
		end,
		sinkSubmarineDeparture,
		teleportSubmarineToArrivalLocation,
		sinkSubmarineArrival,
		function()
			v6 = 6
			maid.RestoreCamera = nil
			clone:Destroy()
		end
	}

	local function fn(flag: boolean?)
		if v5 ~= v4 then
			return
		end

		log("proceedSubmarinePart", flag, v6, clone)

		if flag then
			if clone then
				clone:Destroy()
			end

			if #v8 > 0 then
				maid.RestoreCamera = nil
				table.clear(v8)
			end
		else
			local v9 = table.remove(v8, 1)

			if v9 then
				return v9()
			end
		end
	end

	maid:GiveTask(function()
		if v5 ~= v4 then
			return
		end

		log("proceedSubmarinePart", true, v6, clone)

		if clone then
			clone:Destroy()
		end

		if #v8 > 0 then
			maid.RestoreCamera = nil
			table.clear(v8)
		end
	end)
	return fn, {
		sinkSubmarineDeparture = sinkSubmarineDeparture
	}
end

return SubmarineTransportationController