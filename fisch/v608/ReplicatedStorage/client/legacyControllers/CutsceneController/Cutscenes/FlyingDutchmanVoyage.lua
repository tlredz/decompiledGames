local createVector = vector.create
local Players = game:GetService("Players")
local ProximityPromptService = game:GetService("ProximityPromptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Promise = require(ReplicatedStorage.packages.Promise)
local Trove = require(ReplicatedStorage.packages.Trove)
local legacyControllers = ReplicatedStorage.client.legacyControllers
local CutsceneController = require(legacyControllers.CutsceneController)
local PlayerController = require(legacyControllers.PlayerController)
local FlyingDutchmanFerryController = require(legacyControllers.FlyingDutchmanFerryController)
local FlyingDutchmanFerry = require(ReplicatedStorage.shared.modules.FlyingDutchmanFerry)
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")
local currentCamera = workspace.CurrentCamera
local attributes = FlyingDutchmanFerry.Attributes
local fadeTime = FlyingDutchmanFerry.FadeTime

local function serverNow()
	return workspace:GetServerTimeNow()
end

local function waitForState(instance, p: string, p2: number)
	local v = os.clock() + p2

	while instance:GetAttribute(attributes.State) ~= p do
		if v < os.clock() or not instance.Parent then
			return false
		else
			task.wait(0.1)
		end
	end

	return true
end

local function waitForLegEnd(instance, p: number)
	local attribute = instance:GetAttribute(attributes.LegStart)
	local attribute2 = instance:GetAttribute(attributes.LegDuration) or FlyingDutchmanFerry.LegDuration

	if type(attribute) ~= "number" then
		return
	end

	local v = attribute + attribute2 - p

	while workspace:GetServerTimeNow() < v and instance.Parent do
		task.wait(0.05)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function playSound(childName: string)
	local sounds = script:FindFirstChild("Sounds")
	local sound = sounds and sounds:FindFirstChild(childName)

	if sound and sound:IsA("Sound") then
		sound:Play()
	end
end

local function showTitle(displayName: string)
	local hud = playerGui:FindFirstChild("hud")
	local location = hud and hud:FindFirstChild("location")
	local cutscene = playerGui:FindFirstChild("Cutscene")

	if location and cutscene then
		task.spawn(function()
			local clone = location:Clone()
			clone.Position = UDim2.fromScale(0.5, 0.08)
			clone.title.Text = `• {displayName} •`
			clone.Parent = cutscene
			local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Linear)
			TweenService:Create(clone.title, tweenInfo, {
				TextTransparency = 0
			}):Play()
			TweenService:Create(clone.title.UIStroke, tweenInfo, {
				Transparency = 0
			}):Play()
			task.wait(4)
			TweenService:Create(clone.title, tweenInfo, {
				TextTransparency = 1
			}):Play()
			TweenService:Create(clone.title.UIStroke, tweenInfo, {
				Transparency = 1
			}):Play()
			task.wait(1)
			clone:Destroy()
		end)
	end
end

return {
	Start = function(_, p, p2, _: string, p3: string, p4: string)
		if p ~= localPlayer then
			return Promise.resolve()
		end

		local maid = Trove.new()
		return Promise.new(function(callback)
			local character = localPlayer.Character
			local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")

			if not (p2 and p2.Parent and humanoidRootPart and humanoid) then
				return callback()
			end

			local dock = FlyingDutchmanFerry.GetDock(p3, p2)
			local dock2 = FlyingDutchmanFerry.GetDock(p4, p2)

			if not (dock and dock2) then
				return callback()
			end

			local function aboard()
				return character.Parent ~= nil and humanoidRootPart.Parent == character and humanoid.Health > 0
			end

			local flag = false

			-- equivalent calls inferred from this helper; original call sites unknown
			local function finish()
				if flag then
					return
				end

				flag = true
				maid:Destroy()
				callback()
			end

			maid:Add(character.AncestryChanged:Connect(function()
				if not character.Parent then
					finish() -- equivalent call inferred; original call site unknown
				end
			end))
			PlayerController:ToggleControls(false)
			ProximityPromptService.Enabled = false
			maid:Add(function()
				PlayerController:ToggleControls(true)
				ProximityPromptService.Enabled = true
			end)
			CutsceneController:DisableAllScreens(function(p5)
				maid:Add(p5)
			end)
			local objectSpace = FlyingDutchmanFerryController:GetShipCFrame(p2):ToObjectSpace(humanoidRootPart.CFrame)
			maid:Add(FlyingDutchmanFerryController:OnStep(function(p5, cframe: CFrame)
				if p5 == p2 then
					local v

					if character.Parent == nil or humanoidRootPart.Parent ~= character then
						v = false
					else
						v = humanoid.Health > 0
					end

					if v then
						if FlyingDutchmanFerry.IsSeatedOnShip(character, p2) then
							return
						end

						humanoidRootPart.CFrame = cframe * objectSpace
						humanoidRootPart.AssemblyLinearVelocity = createVector(0, 0, 0)
						humanoidRootPart.AssemblyAngularVelocity = createVector(0, 0, 0)
					end
				end
			end))
			local fieldOfView = currentCamera.FieldOfView
			local camera = dock.Camera

			-- equivalent calls inferred from this helper; original call sites unknown
			local function frameShip()
				local shipCFrame = FlyingDutchmanFerryController:GetShipCFrame(p2)
				currentCamera.CFrame = CFrame.lookAt(camera.Position, shipCFrame.Position + createVector(0, 10, 0))
			end

			CutsceneController:FadeToggle(0, true)
			currentCamera.CameraType = Enum.CameraType.Scriptable
			currentCamera.FieldOfView = 55
			frameShip() -- equivalent call inferred; original call site unknown
			maid:Add(RunService.PreRender:Connect(frameShip))
			maid:Add(function()
				currentCamera.CameraType = Enum.CameraType.Custom
				currentCamera.FieldOfView = fieldOfView

				if humanoid.Parent then
					currentCamera.CameraSubject = humanoid
				end
			end)
			CutsceneController:ShowBars(
				FlyingDutchmanFerry.LegDuration * 2 + FlyingDutchmanFerry.CrossingBlackout + 6,
				0.05,
				0.05
			)
			task.wait(0.1)
			waitForState(p2, "Departing", 5)
			CutsceneController:FadeToggle(0.8, false)
			playSound("Depart") -- equivalent call inferred; original call site unknown
			waitForLegEnd(p2, fadeTime)
			CutsceneController:FadeToggle(fadeTime, true)
			task.wait(fadeTime)
			local v2 = waitForState(p2, "Arriving", 20)
			camera = dock2.Camera
			frameShip() -- equivalent call inferred; original call site unknown

			if v2 then
				local v3

				if character.Parent == nil or humanoidRootPart.Parent ~= character then
					v3 = false
				else
					v3 = humanoid.Health > 0
				end

				if v3 then
					task.wait(0.3)
					CutsceneController:FadeToggle(fadeTime, false)
					showTitle(dock2.DisplayName)
					playSound("Arrive") -- equivalent call inferred; original call site unknown
					waitForLegEnd(p2, 0)
					waitForState(p2, "Docked", 5)
				end
			end

			CutsceneController:FadeWithSaneFuckingArgumentsFuckThisShit(0.6, 0.8)
			task.wait(0.6)
			finish() -- equivalent call inferred; original call site unknown
		end):catch(warn):finally(function()
			maid:Destroy()
		end)
	end
}