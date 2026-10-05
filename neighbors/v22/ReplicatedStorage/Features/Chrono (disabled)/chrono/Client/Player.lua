local Warn = require(script.Parent.Parent.Shared.Warn)
local Events = require(script.Parent.Parent.Shared.Events)
local Entity = require(script.Parent.Parent.Shared.Entity)
local Holder = require(script.Parent.Parent.Shared.Holder)
require(script.Parent.Parent.Shared.Types)
local Config = require(script.Parent.Parent.Shared.Config)
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
Events.PlayerCharacterRegistered:Connect(function(p, p2)
	if not (Config._GetConfig("PLAYER_REPLICATION") == "AUTOMATIC" and Entity.GetModelReplicationType(p2) == "CUSTOM") then
		return
	end

	if not p2.model then
		return Warn.high((`No model found for {p}`))
	end

	if p2.model then
		if not p2.model:IsA("Model") then
			return Warn.high((`Model for {p} is not a Model instance.`))
		end

		p.Character = p2.model
	end

	local function newModel(p3, model)
		if not model then
			return
		end

		if not model:IsA("Model") then
			Warn.high((`Model for {p} is not a Model instance.`))
			return
		end

		localPlayer.Character = p3.model
		local cFrame = workspace.CurrentCamera.CFrame
		workspace.CurrentCamera.CameraSubject = p3.model:FindFirstChildWhichIsA("Humanoid") or p3.model.PrimaryPart
		workspace.CurrentCamera.CFrame = cFrame

		for _, script2 in model:QueryDescendants("LocalScript") do
			if not (script2:IsA("LocalScript") and script2.Disabled == false) then
				continue
			end

			script2.Disabled = true
			script2.Disabled = false
		end
	end

	if localPlayer == p then
		Entity.GetEvent(p2, "ModelChanged"):Connect(newModel)
		newModel(p2, p2.model)
	end
end)
local death = script.Parent.Parent.Shared.Remotes.Death
Config._WaitForLock(function()
	if Config._GetConfig("PLAYER_REPLICATION") ~= "AUTOMATIC" then
		return
	end

	Events.PlayerOwnedAdded:Connect(function(_, data)
		local diedConnection = nil

		-- equivalent calls inferred from this helper; original call sites unknown
		local function newModel(_, model)
			if diedConnection then
				diedConnection:Disconnect()
				diedConnection = nil
			end

			if not (model and data.isContextOwner and model:IsA("Model")) then
				return
			end

			local humanoid = model:FindFirstChildWhichIsA("Humanoid")

			if humanoid then
				diedConnection = humanoid.Died:Connect(function()
					if not data.isContextOwner then
						return
					end

					death:FireServer(data.id)
				end)
			end
		end

		Entity.GetEvent(data, "ModelChanged"):Connect(newModel)
		newModel(data, data.model)
		Entity.GetEvent(data, "Destroying"):Connect(function()
			newModel(nil) -- equivalent call inferred; original call site unknown
		end)
	end)
end)
death.OnClientEvent:Connect(function(p)
	local entity = Holder.GetEntityFromId(p)

	if not entity or entity.isContextOwner then
		return
	end

	local model = entity.model

	if model then
		task.wait()
		local humanoid = model:FindFirstChildWhichIsA("Humanoid")

		if humanoid and humanoid:GetState() ~= Enum.HumanoidStateType.Dead then
			humanoid.Health = 0
			humanoid.Health = 10
			humanoid.Health = 0
		end
	end
end)
return nil