local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local Observers = require(ReplicatedStorage.Packages.Observers)
local v = { workspace.Alive, workspace.Dead }
return Observers.observeTag("RyuzakuraSwordFollow", function(instance)
	local sord = instance:WaitForChild("sord")
	local parent = instance.Parent

	if not (parent and parent:FindFirstChildWhichIsA("Humanoid") and (instance:IsDescendantOf(workspace.Alive) or instance:IsDescendantOf(workspace.Dead))) then
		return function() end
	end

	local v2 = nil
	local v3 = nil
	local v4 = nil
	local total = 0
	local v5 = nil
	local currentEmote = parent:GetAttribute("CurrentEmote")
	local currentEmoteChangedConnection = parent:GetAttributeChangedSignal("CurrentEmote"):Connect(function()
		currentEmote = parent:GetAttribute("CurrentEmote")
	end)
	local deadChangedConnection = parent:GetAttributeChangedSignal("Dead"):Connect(function()
		if parent:GetAttribute("Dead") then
			instance:RemoveTag("RyuzakuraSwordFollow")
		end
	end)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function getPlacement(data)
		local part0 = data.Part0

		if part0 then
			return part0.CFrame * data.C0 * data.Transform * data.C1:Inverse()
		end

		return nil
	end

	local preRenderConnection = RunService.PreRender:Connect(function()
		if v2 and not v2.Enabled and v4 then
			instance:PivotTo(instance:GetPivot() * sord.CFrame:Inverse() * v4)
		end
	end)
	local preSimulationConnection = RunService.PreSimulation:Connect(function(dt: number)
		local v6 = parent == localPlayer.Character
		local parrying

		if v6 and v5 == false then
			parrying = (parent:GetAttribute("ParryTime") or 0) > 0.35
		else
			parrying = parent:GetAttribute("Parrying")
		end

		if not v2 then
			for _, motor6D in sord:GetJoints() do
				if not (motor6D:IsA("Motor6D") and motor6D.Part0 and (motor6D.Part0.Name == "Torso" or motor6D.Part0.Name == "LowerTorso")) then
					continue
				end

				v2 = motor6D
				break
			end
		end

		if not v2 then
			return
		end

		if currentEmote or parrying then
			if v5 == nil then
				v5 = true
			end

			v2.Enabled = true
			v3 = nil
			v4 = nil

			if v6 then
				parent:SetAttribute("ParryTime", (math.max((parent:GetAttribute("ParryTime") or 0) - dt, 0)))
			end
		else
			if v5 == true then
				v5 = false
			end

			local placement = getPlacement(v2) -- equivalent call inferred; original call site unknown

			if not placement then
				return
			end

			total += dt * 2.5
			local v8 = placement * CFrame.new(0, math.sin(total) * 0.15, 0)
			local primaryPart = parent.PrimaryPart

			if primaryPart then
				v8 -= primaryPart.CFrame.LookVector * 0.3
			end

			if not v3 or (v3.Position - v8.Position).Magnitude > 12 then
				v3 = v8
			end

			local v9 = v3
			local lerped = v9.Position:Lerp(v8.Position, 1 - math.exp(dt * -28))
			v3 = v9.Rotation:Lerp(v8.Rotation, 1 - math.exp(dt * -32)) + lerped
			v4 = v3
			v2.Enabled = false
		end
	end)
	return function()
		currentEmoteChangedConnection:Disconnect()
		preSimulationConnection:Disconnect()
		preRenderConnection:Disconnect()
		deadChangedConnection:Disconnect()

		if v2 then
			v2.Enabled = true
		end
	end
end, v)