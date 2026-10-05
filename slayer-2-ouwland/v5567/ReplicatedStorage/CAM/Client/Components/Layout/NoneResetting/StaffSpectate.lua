local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local faye = require(ReplicatedStorage.Packages.faye)
local InputHandler = require(ReplicatedStorage.CAM.Client.Components.Client.InputHandler)
local SpectateUI = require(ReplicatedStorage.CAM.Client.Components.Misc.SpectateUI)
local StaffSpectateController = require(ReplicatedStorage.CAM.Client.Controllers.StaffSpectateController)
local localPlayer = Players.LocalPlayer
return function(p)
	local maid = faye.new()
	local v = nil
	local value = maid:Value("")
	local v2 = nil
	local v3 = nil

	local function cycle(p2: number)
		local v4 = {}

		for _, v5 in Players:GetPlayers() do
			if v5 ~= localPlayer then
				table.insert(v4, v5)
			end
		end

		if #v4 == 0 then
			return
		end

		local v5 = v4[((table.find(v4, v3) or 1) - 1 + p2) % #v4 + 1]

		if v5 == v3 then
			return
		end

		v3 = v5
		local remoteFunction = ReplicatedStorage.OCIServerHolder.RemoteFunction
		task.spawn(remoteFunction.InvokeServer, remoteFunction, "Staff", "Spectate", v5.Name)
	end

	local function watch(watched: number?)
		local playerByUserId

		if watched ~= nil then
			playerByUserId = Players:GetPlayerByUserId(watched)
		end

		local child

		if playerByUserId ~= nil then
			child = ReplicatedStorage.Player_Service.Values:FindFirstChild(localPlayer.Name)
		end

		if playerByUserId == nil or child == nil then
			if v ~= nil then
				v:Destroy()
				v = nil
			end

			v2 = nil
			v3 = nil
		else
			v2 = playerByUserId
			v3 = playerByUserId
			value:Set(playerByUserId.Name)

			if v ~= nil then
				return
			end

			local maid2 = maid:Extend()
			v = maid2
			local objectValue = Instance.new("ObjectValue")
			objectValue.Name = "camsubject"
			objectValue.Parent = child
			maid2:Add(objectValue)
			maid2:Spawn(function()
				while true do
					local character

					if v2 ~= nil then
						character = v2.Character
					end

					local humanoid

					if character ~= nil then
						humanoid = character:FindFirstChildOfClass("Humanoid")
					end

					if objectValue.Value ~= humanoid then
						objectValue.Value = humanoid
					end

					task.wait(0.1)
				end
			end)
			maid2:Add(InputHandler.Block())
			maid2:Add(InputHandler.ListenTo("Spectate_Prev", function(p2, p3)
				if p2 == "Down" and not p3 then
					cycle(-1)
				end
			end), true)
			maid2:Add(InputHandler.ListenTo("Spectate_Next", function(p2, p3)
				if p2 == "Down" and not p3 then
					cycle(1)
				end
			end), true)
			SpectateUI(p, maid2, value, cycle)
		end
	end

	watch(StaffSpectateController.Watched)
	maid:Add(StaffSpectateController.Changed:Connect(watch))
	return function()
		maid:Destroy()
	end
end