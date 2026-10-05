local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local Observers = require(ReplicatedStorage.Packages.Observers)
local v = { workspace.Alive, workspace.Dead }
return Observers.observeTag("SeraphimSwordFollow", function(instance)
	local sord = instance:WaitForChild("sord")
	local parent = instance.Parent

	if not (parent and parent:FindFirstChildWhichIsA("Humanoid") and (instance:IsDescendantOf(workspace.Alive) or instance:IsDescendantOf(workspace.Dead))) then
		return function() end
	end

	local v2 = nil
	local v3 = nil
	local currentEmote = parent:GetAttribute("CurrentEmote")
	local currentEmoteChangedConnection = parent:GetAttributeChangedSignal("CurrentEmote"):Connect(function()
		currentEmote = parent:GetAttribute("CurrentEmote")
	end)
	local deadChangedConnection = parent:GetAttributeChangedSignal("Dead"):Connect(function()
		if parent:GetAttribute("Dead") then
			instance:RemoveTag("SeraphimSwordFollow")
		end
	end)
	local total = 0
	local total2 = 0
	local v4 = nil
	local pivot = parent:GetPivot()
	local preRenderConnection = RunService.PreRender:Connect(function(_: number)
		if v2 and not v2.Enabled then
			instance:PivotTo(pivot)
		end
	end)
	local preAnimationConnection = RunService.PreAnimation:Connect(function(dt: number)
		local primaryPart = parent.PrimaryPart

		if not primaryPart then
			return
		end

		local v5 = parent == localPlayer.Character
		local v6

		if v5 and v4 == false then
			v6 = (parent:GetAttribute("ParryTime") or 0) > 0.35
		else
			v6 = parent:GetAttribute("Parrying")
		end

		if currentEmote or v6 then
			if v4 == nil then
				v4 = true
			end

			if v2 then
				v2.Enabled = true
			end

			if v5 then
				parent:SetAttribute("ParryTime", (math.max((parent:GetAttribute("ParryTime") or 0) - dt, 0)))
			end
		else
			if v4 == true then
				v4 = false
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

			local v7 = math.sin(total) * 0.5 + 1.15

			if not v3 or v2.Enabled then
				v3 = primaryPart.CFrame * CFrame.new(0, v7, 0.85)
				total2 = 0.1
			end

			v2.Enabled = false
			total2 += (0.6 - total2) * math.min(dt * 0.1 * 60, 1)
			total += dt * 3
			v3 = v3:Lerp(primaryPart.CFrame * CFrame.new(0, v7, 1.5), (math.min(total2 * dt * 60, 1)))
			pivot = v3 * CFrame.Angles(0, 1.5707963267948966, 0)
		end
	end)
	return function()
		currentEmoteChangedConnection:Disconnect()
		preAnimationConnection:Disconnect()
		preRenderConnection:Disconnect()
		deadChangedConnection:Disconnect()
	end
end, v)