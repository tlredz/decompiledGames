local RepairShipClient = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
local random = Random.new()
local v = {}
local v2 = 0
local alienBeams = {}

function LiftOffShip(instance, flag: boolean)
	local origin = instance:GetAttribute("Origin")
	local total = 0
	local v3 = 400
	local v4 = 35
	local v5 = 0
	local v6 = 0
	local hatch = instance:WaitForChild("Hatch")
	local pivot = hatch:GetPivot()
	local v7 = not instance.Parent:FindFirstChild("ParticlesPart") and {} or instance.Parent.ParticlesPart:GetChildren()
	local v8 = alienBeams[instance]

	if flag then
		v4 = 0
		v5 = -25
		v3 = 0
		task.spawn(function()
			Client.TweenModule.new(function(p)
				local v9 = -1.1344640137963142 * p
				hatch:PivotTo(pivot * CFrame.Angles(v9, 0, 0))
			end, 0.25, "Quad", "In"):Play()
			task.wait(0.25)
			hatch.PrimaryPart.CloseHatch:Play()
			task.spawn(function()
				hatch.PrimaryPart.SpaceshipTakeoff:Play()
			end)

			for i = 1, 8 do
				task.wait(random:NextInteger(10, 20) / 100)

				for _, v9 in pairs(v7) do
					v9.Enabled = true
				end

				v3 = i * 50
				task.wait(random:NextInteger(8, 14) / 100)

				for _, v9 in pairs(v7) do
					v9.Enabled = false
				end

				v3 = 0
			end

			Client.TweenModule.new(function(p)
				v5 = -25 * (1 - p)
			end, 6, "Linear"):Play()
			Client.TweenModule.new(function(p)
				v3 = 400 + 400 * p
			end, 1, "Linear"):Play()

			for _, v9 in pairs(v7) do
				v9.Enabled = true
			end

			task.delay(3, function()
				for _, v9 in pairs(v7) do
					v9.Enabled = false
				end
			end)
			task.wait(1)
			Client.TweenModule.new(function(p)
				if p < 0.2 then
					v4 = 0
				else
					v4 = 35 * (p - 0.2) / 0.8
				end

				v6 = 200 * p
			end, 8, "Quad", "InOut"):Play()
			task.wait(6)

			if v8 then
				task.spawn(function()
					local v9 = {}

					for _, part in pairs(v8.Visual:GetDescendants()) do
						if not part:IsA("BasePart") then
							continue
						end

						v9[part] = {
							Size = part.Size,
							Transparency = part.Transparency
						}
						part.Transparency = 1
					end

					v8.Parent = instance.Parent
					Client.TweenModule.new(function(p)
						for k, v10 in pairs(v9) do
							local size = v10.Size
							k.Size = Vector3.new(size.X * p, size.Y, size.Z * p)
							k.Transparency = v10.Transparency
						end
					end, 1, "Quad", "Out"):Play()
				end)
			end

			task.wait(9)
			Client.TweenModule.new(function(p)
				v3 = 800 - 400 * p
			end, 4, "Linear")
		end)
	else
		hatch:PivotTo(pivot * CFrame.Angles(-1.1344640137963142, 0, 0))
		print("fast close angle")
		v8.Parent = instance.Parent
	end

	task.spawn(function()
		while true do
			local v9 = task.wait()

			if not instance.Parent then
				break
			end

			total += v3 * v9
			local v10 = CFrame.Angles(0, math.rad(v6), 0) * CFrame.Angles(math.rad(v5), 0, 0) * CFrame.Angles(
				0,
				math.rad(-v6),
				0
			)
			instance:PivotTo((origin + Vector3.new(0, v4, 0)) * v10 * CFrame.Angles(0, math.rad(total), 0))
		end
	end)
end

function RepairedShipAdded(instance)
	if instance:GetAttribute("Origin") == nil then
		instance:SetAttribute("Origin", instance:GetPivot() * CFrame.Angles(0.4363323129985824, 0, 0))
	end

	local repairTime = instance:GetAttribute("RepairTime")
	local v3 = math.max(workspace:GetServerTimeNow() - repairTime, 0)
	print("REPAIRED", v3)
	local v4 = v3 < 4
	local alienBeam = v4 and instance.Parent:FindFirstChild("AlienBeam")

	if alienBeam then
		alienBeams[instance] = alienBeam
		alienBeam.Parent = nil
	end

	LiftOffShip(instance, v4)
end

function CrashedShipAdded(p)
	local alienBeam = p.Parent:WaitForChild("AlienBeam", 5)

	if alienBeam then
		alienBeams[p] = alienBeam
		alienBeam.Parent = nil
	end
end

function SetTransparency(folder, transparency: number, p: number)
	if p == nil then
		for _, part in pairs(folder:GetDescendants()) do
			if part:IsA("BasePart") and part.Name ~= "Main" and part.Name ~= "TouchPart" then
				part.Transparency = transparency
			end
		end
	else
		for _, part in pairs(folder:GetDescendants()) do
			if not (part:IsA("BasePart") and part.Name ~= "Main" and part.Name ~= "TouchPart") then
				continue
			end

			if part:GetAttribute("OrigTransparency") == nil then
				part:SetAttribute("OrigTransparency", part.Transparency)
			end

			local transparency2 = part.Transparency
			local v4 = part
			Client.TweenModule.new(function(p2)
				if not (v2 == p and v[folder] ~= nil) then
					return true
				end

				v4.Transparency = transparency2 + (transparency - transparency2) * p2
			end, 0.5):Play()
		end
	end
end

function ShowRepairPieces()
	local v3 = v2 + 1
	v2 = v3

	for k, _ in v do
		if not k:GetAttribute("Repaired") then
			SetTransparency(k, 0.7, v3)
		end
	end
end

function HideRepairPieces()
	local v3 = v2 + 1
	v2 = v3

	for k, _ in v do
		if not k:GetAttribute("Repaired") then
			SetTransparency(k, 1, v3)
		end
	end
end

function ListenForRepairPartDragged()
	Client.Events.StartDraggingItem:Connect(function(instance)
		if instance:GetAttribute("AlienTechId") then
			ShowRepairPieces()
		end
	end)
	Client.Events.ItemDraggingEnded:Connect(function(_)
		task.wait()
		local draggingItem = Client.InteractionHandler.GetDraggingItem()

		if draggingItem == nil or draggingItem:GetAttribute("AlienTechId") == nil then
			HideRepairPieces()
		end
	end)
end

function ShipPartRepaired(p)
	SetTransparency(p, 0)
end

function AlienShipRepairPartAdded(instance)
	if instance:GetAttribute("Repaired") then
		return
	end

	SetTransparency(instance, 1)
	v[instance] = true
	local touchedConnection = instance.Parent.Parent:WaitForChild("ShipRepairZone").Touched:Connect(function(otherPart)
		if instance:GetAttribute("Repaired") then
			return
		end

		local parent = otherPart.Parent

		if parent.Parent == workspace.Items and parent:GetAttribute("AlienTechId") and (parent:GetAttribute("Owner") == localPlayer.UserId or parent:GetAttribute("LastOwner") == localPlayer.UserId) and parent:GetAttribute("AlienTechId") == instance:GetAttribute("AlienTechId") then
			print("we have a repair match!")
			parent.Parent = game.ReplicatedStorage.TempStorage
			Client.Sound.Play("AlienBatteryAdded", {
				Volume = 0.45,
				Replicate = true,
				ReplicationProperties = {
					Instance = localPlayer.Character.Head,
					Volume = 0.4
				}
			})
			local v3 = Client.Events.RequestRepairAlienShip:InvokeServer(parent, instance)

			if not (v3 and v3.Success) then
				task.delay(0.5, function()
					parent.Parent = workspace.Items
				end)
			end
		end
	end)
	instance:GetAttributeChangedSignal("Repaired"):Connect(function()
		if instance:GetAttribute("Repaired") then
			v[instance] = nil
			touchedConnection:Disconnect()
			ShipPartRepaired(instance)
		end
	end)
end

function RepairShipClient.Init()
	Client.Utility.ForAllTagged("AlienShipRepairPart", AlienShipRepairPartAdded)
	Client.Utility.ForAllTagged("RepairableAlienShip", CrashedShipAdded)
	Client.Utility.ForAllTagged("RepairedShip", RepairedShipAdded)
	ListenForRepairPartDragged()
end

return RepairShipClient