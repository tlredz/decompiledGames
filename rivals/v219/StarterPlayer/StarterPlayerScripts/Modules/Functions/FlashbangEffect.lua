local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local CONSTANTS = require(ReplicatedStorage.Modules.CONSTANTS)
local BetterDebris = require(ReplicatedStorage.Modules.BetterDebris)
local Utility = require(ReplicatedStorage.Modules.Utility)
local SpectateController = require(Players.LocalPlayer.PlayerScripts.Controllers.SpectateController)
local flashbangEffect = Players.LocalPlayer.PlayerScripts.Assets.Misc:WaitForChild("FlashbangEffect")

-- equivalent calls inferred from this helper; original call sites unknown
local function default_flash_sound_callback(position)
	Utility:CreateSound("rbxassetid://14778230670", 1, 1, position, true, 10)
end

return function(p, position, p2, p3, p4, callback, p5)
	if (workspace.CurrentCamera.CFrame.Position - position).Magnitude > CONSTANTS.RENDER_DISTANCE then
		return
	end

	local clone = flashbangEffect:Clone()
	clone.CFrame = CFrame.new(position)
	clone.Parent = workspace
	clone.Attachment.Glow:Emit(5)
	BetterDebris:AddItem(clone, 5)
	local pointLight = clone.PointLight
	task.spawn(Utility.RenderstepForLoop, Utility, 0, 100, 4, function(p6)
		pointLight.Brightness = 40 * (1 - p6 / 100)
	end)

	if callback then
		callback(position)
	else
		default_flash_sound_callback(position) -- equivalent call inferred; original call site unknown
	end

	if SpectateController.CurrentSubject and SpectateController.CurrentSubject.FighterInterface then
		SpectateController.CurrentSubject.FighterInterface.Flashed:AttemptToFlash(p, position, p2, p3, p4, p5)
	end
end