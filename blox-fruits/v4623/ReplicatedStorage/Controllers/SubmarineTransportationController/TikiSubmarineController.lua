local createVector = vector.create
local TweenService = game:GetService("TweenService")
local Net = require(game.ReplicatedStorage.Modules.Net)
local Result = require(game.ReplicatedStorage.Packages.Result)
require(game.ReplicatedStorage.Packages.Future)
require(game.ReplicatedStorage.Util.runAsync)
local Maid = require(game.ReplicatedStorage.Util.Maid)
local Realm = require(game.ReplicatedStorage.Util.Realm)
require(game.ReplicatedStorage.Util.GetWaterHeightAtLocation)
require(game.ReplicatedStorage.Controllers.MapServices.SubmergedIslandController)
local MapTransitionEffect = require(game.ReplicatedStorage.Controllers.MapServices.Transitions.MapTransitionEffect)
local v = nil
local v2 = nil
local CharacterTransparency = require(game.ReplicatedStorage.CharacterTransparency)
local maid = Maid.new()
local Sound = require(game.ReplicatedStorage.Util.Sound)
local TikiSubmarineController = {}

if Realm.getIfCurrentRealmHasTagAsync("IsThirdSea") == false then
	return TikiSubmarineController
end

local tikiOutpost = nil
local pivot = nil
local submarineWorker = nil
local whalesubmarine = nil
local cFrame = nil
local v3 = nil
local extending = nil
local cFrame2 = nil
local motor6D = nil
local C0 = nil
local size = nil

function TikiSubmarineController.ResetState()
	maid:DoCleaning()
end

function TikiSubmarineController.GetCraneModel()
	if v3 or not tikiOutpost then
		return v3
	end

	local submarineCraneModel = nil

	for _ = 1, 10 do
		submarineCraneModel = tikiOutpost:FindFirstChild("SubmarineCraneModel", true)

		if submarineCraneModel then
			break
		else
			task.wait()
		end
	end

	task.wait()
	v3 = submarineCraneModel
	extending = submarineCraneModel.Extending
	cFrame2 = submarineCraneModel.Extending.CFrame
	size = submarineCraneModel.Extending.Size
	motor6D = submarineCraneModel.Extending.Motor6D
	C0 = submarineCraneModel.Extending.Motor6D.C0
	return v3
end

function TikiSubmarineController.HideCharacters()
	local character = game.Players.LocalPlayer.Character
	character.Humanoid:UnequipTools()
	local _ = character.Parent
	local v4 = CharacterTransparency:AddStack(character, "SubmarineInvis", 2)
	submarineWorker:PivotTo(CFrame.new(0, 9999999, 0))

	function maid.RestoreCharacters()
		submarineWorker:PivotTo(pivot)
		v4:Destroy()
	end
end

function TikiSubmarineController.LowerSubmarineIntoWater()
	pcall(function()
		TikiSubmarineController.GetCraneModel()
	end)

	if not v3 then
		warn("no crane")
		return false
	end

	local cylinder025 = workspace:FindFirstChild("whalesubmarine", true)["Cylinder.025"]
	local tween = TweenService:Create(cylinder025, TweenInfo.new(5), {
		CFrame = cFrame - createVector(0, 40, 0)
	})
	local tween2 = TweenService:Create(extending, TweenInfo.new(5), {
		CFrame = cFrame2 - createVector(0, 20, 0),
		Size = size + createVector(0, 40, 0)
	})
	local tween3 = TweenService:Create(motor6D, TweenInfo.new(5), {
		C0 = C0 - createVector(0, 20, 0)
	})
	maid:GiveTask(function()
		task.spawn(tween.Cancel, tween)
		task.spawn(tween2.Cancel, tween2)
		task.spawn(tween3.Cancel, tween3)
		cylinder025.CFrame = cFrame
		extending.CFrame = cFrame2
		extending.Size = size
		motor6D.C0 = C0
	end)
	Sound:Play("LoweringSub", cylinder025)
	tween:Play()
	tween2:Play()
	tween3:Play()
	task.wait(3.3333333333333335)
	return true
end

function TikiSubmarineController.GetMainGUI()
	return game.Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("Main")
end

function TikiSubmarineController.FadeToBlack()
	local blackScreen = TikiSubmarineController.GetBlackScreen()
	blackScreen.Position = UDim2.new(0, 0, 0, -50)
	blackScreen.BackgroundTransparency = 1
	TweenService:Create(blackScreen, TweenInfo.new(0.3), {
		BackgroundTransparency = 0
	}):Play()
	task.wait(0.3)
end

function TikiSubmarineController.UnfadeFromBlack()
	TweenService:Create(TikiSubmarineController.GetBlackScreen(), TweenInfo.new(0.3), {
		BackgroundTransparency = 1
	}):Play()
	task.wait(0.3)
end

function TikiSubmarineController.GetBlackScreen()
	return TikiSubmarineController.GetMainGUI():WaitForChild("Blackscreen")
end

function TikiSubmarineController.ControlCamera()
	local CameraController = require(game.ReplicatedStorage.Controllers.CameraController)
	local restoreCamera = CameraController.new()
	maid.RestoreCamera = restoreCamera
	restoreCamera:TeleportTo(script.SubmarineCamera.CFrame)
end

function TikiSubmarineController.RunCutscene(callback)
	local thread = task.defer(function()
		TikiSubmarineController.FadeToBlack()
		TikiSubmarineController.HideCharacters()
		TikiSubmarineController.ControlCamera()
		TikiSubmarineController.UnfadeFromBlack()
		TikiSubmarineController.LowerSubmarineIntoWater()
		task.spawn(MapTransitionEffect.Play)
		task.wait(0.2)

		if callback() then
			task.wait(0.5)
			task.spawn(TikiSubmarineController.ResetState)
			task.wait(2)
		else
			task.spawn(TikiSubmarineController.ResetState)
		end

		task.spawn(MapTransitionEffect.StopEarly)
	end)

	while coroutine.status(thread) ~= "dead" do
		task.wait(0.1)
	end
end

local function GetBaseSubmarinerDialogue()
	local SubmergedIslandController = require(game.ReplicatedStorage.Controllers.MapServices.SubmergedIslandController)
	local runAsync = require(game.ReplicatedStorage.Util.runAsync)
	local v4 = runAsync(
		Net:RemoteFunction("SubmarineWorkerSpeak").InvokeServer,
		Net:RemoteFunction("SubmarineWorkerSpeak"),
		"AskKilledTikiBoss"
	)
	local v5 = {
		Text = { "Your help cleaning up the trouble on this island has earned you our trust. I'd be happy to give you a ride to our homeland down below. Want to take a ride?" },
		Option1 = {
			Label = "Yes",
			JumpTo = function()
				v2.resumeWhenCallbackFinishes(function()
					return Result.try(function()
						TikiSubmarineController.RunCutscene(function()
							SubmergedIslandController:LockState()
							runAsync(function()
								SubmergedIslandController:LoadMap()
							end):awaitResult()
							Net:RemoteFunction("SubmarineWorkerSpeak"):InvokeServer("TravelToSubmergedIsland")
							task.spawn(function()
								task.wait(1)
								task.delay(1, function()
									SubmergedIslandController:UnlockState()
								end)
								MapTransitionEffect.StopEarly()
							end)
							return true
						end)
						return false
					end):unwrapOr({
						Text = { "I can't take you there right now.." }
					})
				end)
			end
		},
		Option2 = {
			Label = "No",
			JumpTo = function()
				return {
					Text = { "That's a shame. Come back anytime and I'll take you." }
				}
			end
		}
	}
	return {
		Text = { "Eh...? You like what I've done with this thing?" },
		Option1 = {
			Label = "Yes",
			JumpTo = function()
				if v4:awaitResult() == true then
					return v5
				end

				return {
					Text = { "Thanks.. Maybe if the island weren't occupied by so many bandits, I'd be able to acquire enough fuel to leave this place." }
				}
			end
		}
	}
end

-- equivalent calls inferred from this helper; original call sites unknown
local function OnSubmarineWorkerInteracted()
	return {
		Title = "Submarine Worker",
		Get = GetBaseSubmarinerDialogue
	}
end

function TikiSubmarineController.OnStart(p)
	local DialogueController = require(game.ReplicatedStorage.DialogueController)
	v2 = DialogueController
	v = Net:RemoteFunction("SubmarineTransportation")
	p.new("Submarine Worker", function(_)
		return OnSubmarineWorkerInteracted()
	end, 4)
	submarineWorker = workspace.NPCs:WaitForChild("Submarine Worker", 999999)
	pivot = submarineWorker:GetPivot()
	tikiOutpost = workspace.Map:WaitForChild("TikiOutpost", 999999)
	whalesubmarine = tikiOutpost:WaitForChild("whalesubmarine", 999999)
	cFrame = whalesubmarine:WaitForChild("Cylinder.025", 999999).CFrame
end

return TikiSubmarineController