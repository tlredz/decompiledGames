local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("ContentProvider")
game:GetService("TweenService")
game:GetService("RunService")
game:GetService("Lighting")
local Players = game:GetService("Players")
game:GetService("Debris")
require(ReplicatedStorage.Shared.EventTypes)
local _3Roads = {}
require(ReplicatedStorage.Controllers.EncryptedAssetsController)
require(ReplicatedStorage.Controllers.AnimalController)
local EffectController = require(ReplicatedStorage.Controllers.EffectController)
require(ReplicatedStorage.Controllers.CameraController)
require(ReplicatedStorage.Controllers.SoundController)
require(ReplicatedStorage.Controllers.EventController)
require(ReplicatedStorage.Controllers.CycleController)
require(ReplicatedStorage.Shared.SharedEventUtils)
require(ReplicatedStorage.Packages.CreateTween)
require(ReplicatedStorage.Shared.TweenPivot)
local Observers = require(ReplicatedStorage.Packages.Observers)
require(ReplicatedStorage.Utils.MathUtils)
require(ReplicatedStorage.Shared.Animals)
require(ReplicatedStorage.Packages.Signal)
require(ReplicatedStorage.Packages.Trove)
require(ReplicatedStorage.Packages.Shake)
require(ReplicatedStorage.Packages.Timer)
require(ReplicatedStorage.Packages.Spr)
require(ReplicatedStorage.Packages.Net)
require(ReplicatedStorage.Shared.VFX)
local _ = Players.LocalPlayer
local _ = workspace.CurrentCamera
local _ = script.Name

function _3Roads.OnStart(_) end

function _3Roads.OnStop(_) end

function _3Roads.OnLoad(_)
	local v = nil
	local v2 = nil

	local function updateRoads(p)
		if ReplicatedStorage:GetAttribute("3RoadsEvent") then
			if not p then
				EffectController:Activate("Blink")
			end

			if v then
				v()
				v = nil
			end

			if not v2 then
				v2 = Observers.observeTag("HideIn3Roads", function(p2)
					local parent = p2.Parent
					p2.Parent = script
					return function()
						pcall(function()
							p2.Parent = parent
						end)
					end
				end, { workspace, script })
			end
		else
			if not p then
				EffectController:Activate("Blink")
			end

			if not v then
				v = Observers.observeTag("ShowIn3Roads", function(instance)
					local parent = instance.Parent
					local v3 = false
					local destroyingConnection = parent.Destroying:Once(function()
						v3 = true
						instance:Destroy()
					end)
					instance.Parent = script
					return function()
						destroyingConnection:Disconnect()

						if not v3 then
							pcall(function()
								instance.Parent = parent
							end)
						end
					end
				end, { workspace, script })
			end

			if v2 then
				v2()
				v2 = nil
			end
		end
	end

	ReplicatedStorage:GetAttributeChangedSignal("3RoadsEvent"):Connect(updateRoads)
	task.spawn(updateRoads, true)
end

return _3Roads