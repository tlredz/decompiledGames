local createVector = vector.create
require(game.ReplicatedStorage.MovesetTypes)
local RunService = game:GetService("RunService")
local Shared = require(script.Parent.Shared)
local Anims = require(game.ReplicatedStorage.Util.Anims)
local BodyMover = require(game.ReplicatedStorage.Util.BodyMover)
local Cast = require(game.ReplicatedStorage.MovesetUtil.Cast)
local SharkmanMasterServiceClient

if RunService:IsClient() then
	SharkmanMasterServiceClient = require(game.ReplicatedStorage.Controllers.MapServices.SharkmanMasterServiceClient)
else
	SharkmanMasterServiceClient = nil
end

local function hasHiddenX()
	local cachedQuestData = SharkmanMasterServiceClient and SharkmanMasterServiceClient.CachedQuestData
	local upgrades = cachedQuestData and cachedQuestData.Upgrades
	return upgrades ~= nil and upgrades[2] ~= nil and upgrades[2].en == true
end

return {
	onInput = function(object, _: string, _, _)
		local character = object.character
		local rootPart = object.rootPart
		local humanoid = object.humanoid
		local tool = object.tool
		humanoid.AutoRotate = false
		local v = rootPart.Size.Y * 0.5 + humanoid.HipHeight
		local aim = object:aim()
		local cframe = CFrame.new(rootPart.CFrame.Position, aim + createVector(0, 1, 0) * v)
		local v2 = BodyMover.new(character):Create("BodyGyro", {
			CFrame = cframe
		})
		local v3 = BodyMover.new(character):Create("BodyPosition", {
			Position = rootPart.Position
		})
		object.remotes.event:FireServer(aim)
		rootPart.CFrame = cframe
		local flag = false
		local v4 = false
		local flag2 = true
		local sKXLaunch = Anims:Get(character, "SK_XLaunch")
		sKXLaunch.Stopped:Once(function()
			if flag then
				return
			end

			sKXLaunch = Anims:Get(character, "SK_XLaunchLoop")
			sKXLaunch:Play()
		end)
		sKXLaunch:Play()
		task.spawn(function()
			if object.holdingInstance.Value then
				object.holdingInstance.Changed:Wait()
			end

			flag = true
			sKXLaunch:Stop()
			local sKXEnd = Anims:Get(character, "SK_XEnd")
			sKXEnd:Play(nil, nil, 1.25)
			task.delay(0.45, function()
				sKXEnd:Stop(0.2)
			end)
		end)
		task.spawn(function()
			while Cast.isAlive(tool, character) and not v4 do
				local aim2 = object:aim()

				if flag2 then
					v2:Set(CFrame.new(rootPart.CFrame.Position, aim2 + createVector(0, 1, 0) * v))
				end

				object.remotes.event:FireServer(aim2)
				task.wait()
			end
		end)
		object.remotes.func:InvokeServer("X")
		v3:Destroy()
		flag2 = false
		v2:Destroy()
		humanoid.AutoRotate = true
		local cachedQuestData = SharkmanMasterServiceClient and SharkmanMasterServiceClient.CachedQuestData
		local upgrades = cachedQuestData and cachedQuestData.Upgrades
		local v5

		if upgrades == nil or upgrades[2] == nil then
			v5 = false
		else
			v5 = upgrades[2].en == true
		end

		if v5 then
			task.delay(Shared.Timing.MaxHiddenHold + 0.5, function()
				v4 = true
			end)
		else
			v4 = true
			flag = true
		end
	end
}