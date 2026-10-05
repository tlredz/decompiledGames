local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local ReplicatedStorage3 = game:GetService("ReplicatedStorage")
require3(ReplicatedStorage3:WaitForChild("UserInputService"))
game:GetService("GamepadService")
game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local v = require3(ReplicatedStorage2.Packages.Promise)
require3(ReplicatedStorage2.Packages.Signal)
require3(ReplicatedStorage2.Packages.Trove)
local v2 = require3(ReplicatedStorage2.Common.Utils)
require3(ReplicatedStorage2.Shared.FastUtils)
local v3 = require3(script.Parent.Parent)
local v4 = require3(ReplicatedStorage2.Controllers.FinishersController)
require3(ReplicatedStorage2.Shared.ReplicatedInstances.Swords)
require3(ReplicatedStorage2.Shared.SwordAPI)
local v5 = require3(ReplicatedStorage2.ClientGameModules.CoreCall)
local atmosphere = Lighting:FindFirstChild("Atmosphere")
local localPlayer = Players.LocalPlayer
local currentCamera = workspace.CurrentCamera
local v6 = v.try(function()
	local friendsAsync = Players:GetFriendsAsync(localPlayer.UserId)
	local v7 = {}

	repeat
		local currentPage = friendsAsync:GetCurrentPage()
		table.move(currentPage, 1, #currentPage, #v7 + 1, v7)
	until friendsAsync.IsFinished or not pcall(function(...)
		friendsAsync:AdvanceToNextPageAsync()
	end)

	return v7
end):catch(function() end)

local function loadFriendFor(NPC2)
	if not pcall(function()
		local v7, v8 = v6:timeout(2):await()
		local v9

		if v7 then
			v9 = v8[math.random(1, #v8)]
		end

		assert(v9, "No friend found")
		local humanoidDescriptionFromUserId = Players:GetHumanoidDescriptionFromUserId(v9.Id)
		NPC2.Humanoid:ApplyDescription(humanoidDescriptionFromUserId)
	end) then
		pcall(function()
			NPC2.Humanoid:ApplyDescription(ReplicatedStorage2.Misc.NoobHumanoidDescription)
		end)
	end
end

local Finisher = {}
Finisher.Template = ReplicatedStorage2.Misc.ShowRooms.Finisher

function Finisher.AfterInit(data)
	local instance = data.Instance
	local _ = data.Trove
	local character = localPlayer.Character

	if character then
		character:FindFirstChildWhichIsA("Humanoid")
	end

	local humanoidDescriptionFromUserId = nil

	if not humanoidDescriptionFromUserId then
		pcall(function()
			humanoidDescriptionFromUserId = Players:GetHumanoidDescriptionFromUserId(localPlayer.UserId)
		end)
	end

	if not humanoidDescriptionFromUserId then
		return
	end

	local NPC = instance.NPC
	local NPC2 = instance.NPC2
	NPC2:SetAttribute("LobbySwordName", "Base Sword")
	NPC2:AddTag("GiveSwordNPC")
	NPC:SetAttribute("LobbySwordName", "Base Sword")
	NPC:AddTag("GiveSwordNPC")
	xpcall(function()
		NPC.Humanoid:ApplyDescription(humanoidDescriptionFromUserId)
	end, warn)
	local pivot = NPC:GetPivot()
	local pivot2 = NPC2:GetPivot()

	function data.Info:PlayFinisher()
		v5(Enum.CoreGuiType.Chat, false)
		v5(Enum.CoreGuiType.PlayerList, false)
		NPC:SetAttribute("LobbySwordName", self)
		NPC:PivotTo(pivot)
		NPC2:PivotTo(pivot2)
		xpcall(function()
			local lastTime = os.clock()
			local _, maid = v4:PlayFinisher(self, NPC, NPC2, pivot, workspace:GetServerTimeNow())
			local v7 = os.clock() - lastTime

			if type(maid) == "table" then
				data.Trove:Add(maid)
				local thread = coroutine.running()
				maid:Add(function()
					v2.Thread.SafeResume(thread)
				end)
				coroutine.yield()
			else
				local dataFinisher = ReplicatedStorage2.Misc.DataFinishers[self]
				task.wait(dataFinisher:GetAttribute("Duration") - v7)
			end
		end, warn)
		v5(Enum.CoreGuiType.Chat, true)
		v5(Enum.CoreGuiType.PlayerList, true)
		v3:Close()
		task.spawn(loadFriendFor, NPC2)
	end

	loadFriendFor(NPC2)
end

function Finisher.BeforeShow(p)
	local instance = p.Instance
	currentCamera.CFrame = instance.Camera.CFrame
	local density, densityChangedConnection

	if atmosphere then
		density = atmosphere.Density
		atmosphere.Density = 0
		densityChangedConnection = atmosphere:GetPropertyChangedSignal("Density"):Connect(function()
			if atmosphere.Density == 0 then
				return
			end

			density = atmosphere.Density
			atmosphere.Density = 0
		end)
	else
		densityChangedConnection = nil
		density = nil
	end

	p.Trove:Add(function()
		if densityChangedConnection then
			densityChangedConnection:Disconnect()
		end

		if atmosphere and density then
			atmosphere.Density = density
		end
	end)
	p.Trove:Add(currentCamera.Changed:Connect(function(p2: string)
		if p2 == "CameraType" and currentCamera.CameraType ~= Enum.CameraType.Scriptable and v3.ShowRoom then
			currentCamera.CameraType = Enum.CameraType.Scriptable
			currentCamera.CFrame = instance.Camera.CFrame
		end
	end))
end

return Finisher