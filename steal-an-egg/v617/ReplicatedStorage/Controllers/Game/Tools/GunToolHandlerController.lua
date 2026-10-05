local createVector = vector.create
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Audio = require(ReplicatedStorage.Shared.Audio)
require(ReplicatedStorage.Data.Gears)
require(ReplicatedStorage.Shared.Globals.Constants)
local Gears = require(ReplicatedStorage.Data.Gears)
local GunCatalog = require(ReplicatedStorage.Client.Util.GunCatalog)
local Log = require(ReplicatedStorage.Packages.Log)
local v = Log.new()
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local ToolSetup = require(ReplicatedStorage.Client.Util.ToolSetup)
local t = require(ReplicatedStorage.Packages.t)
return {
	Start = function()
		local listGearNames = GunCatalog.ListGearNames()
		local localPlayer = Players.LocalPlayer
		local currentCamera = workspace.CurrentCamera
		local v2 = nil

		local function createWallCheckParams(instance)
			local raycastParams = RaycastParams.new()
			raycastParams.FilterType = Enum.RaycastFilterType.Exclude
			local tools = { instance }
			local tool = instance:FindFirstChildOfClass("Tool")

			if tool then
				table.insert(tools, tool)
			end

			raycastParams.FilterDescendantsInstances = tools
			raycastParams.IgnoreWater = true
			return raycastParams
		end

		local function isShootPathBlocked(p, _: Vector3, instance)
			if not (instance and p) then
				return true
			end

			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not (humanoidRootPart and humanoidRootPart:IsA("BasePart")) then
				return true
			end

			local rightArm = instance:FindFirstChild("Right Arm")

			if not rightArm then
				return true
			end

			local rightShoulderAttachment = rightArm:FindFirstChild("RightShoulderAttachment")

			if not rightShoulderAttachment then
				return true
			end

			local v3 = p.WorldPosition - rightShoulderAttachment.WorldPosition
			local wallCheckParams = createWallCheckParams(instance)
			return workspace:Raycast(rightShoulderAttachment.WorldPosition, v3, wallCheckParams) ~= nil
		end

		local function getArmShootPosition(p, character)
			if not p then
				return createVector(0, 0, 0), createVector(0, 0, 0), true
			end

			local mouse = localPlayer:GetMouse()
			local screenPointToRay = currentCamera:ScreenPointToRay(mouse.X, mouse.Y)
			local position = screenPointToRay.Origin + screenPointToRay.Direction * 1000
			local raycastParams = RaycastParams.new()
			raycastParams.FilterType = Enum.RaycastFilterType.Exclude
			local tools = { character }
			local tool = character:FindFirstChildOfClass("Tool")

			if tool then
				table.insert(tools, tool)
			end

			raycastParams.FilterDescendantsInstances = tools
			raycastParams.IgnoreWater = true
			local raycastResult = workspace:Raycast(
				screenPointToRay.Origin,
				screenPointToRay.Direction * 1000,
				raycastParams
			)

			if raycastResult then
				position = raycastResult.Position
			end

			local worldPosition = p.WorldPosition
			local unit = (position - worldPosition).Unit
			return worldPosition, unit, (isShootPathBlocked(p, unit, character))
		end

		local function onActivated(instance)
			local character = localPlayer.Character

			if not character then
				return
			end

			local v3 = assert(instance:FindFirstChild("Shoot", true), "Shoot Attachment not found")
			t.strict(t.instanceIsA("Attachment"))(v3)
			local armShootPosition, v4, v5 = getArmShootPosition(v3, character)

			if v5 then
				v:AtDebug():Log("Shoot blocked by wall - preventing fire")
			else
				Remotes.GunGadget.AskDischarge:FireServer(v2:GetCurrentToolGearName(), armShootPosition, v4)
			end
		end

		local function onEquipped()
			local currentToolGearName = v2:GetCurrentToolGearName()

			if not currentToolGearName then
				return
			end

			local EQUIP_SFX = Gears.Directory[currentToolGearName].EQUIP_SFX

			if not EQUIP_SFX then
				return
			end

			Audio.PlayFile(EQUIP_SFX, script)
		end

		local function onUnequipped()
			Remotes.GunGadget.DropCaster:FireServer(v2:GetCurrentToolGearName())
		end

		v2 = ToolSetup.Attach(listGearNames, {
			onActivated = onActivated,
			onEquipped = onEquipped,
			onUnequipped = onUnequipped
		})
	end
}