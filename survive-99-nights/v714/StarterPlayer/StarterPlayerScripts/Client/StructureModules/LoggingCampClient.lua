local createVector = vector.create
local LoggingCampClient = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local v = {
	Log = true,
	["Super Log"] = true
}
local v2 = {}
local v3 = {}
local v4 = {}
local overlapParams = OverlapParams.new()
overlapParams.FilterType = Enum.RaycastFilterType.Include

function GetSpinSpeed(p)
	if p < 6 then
		return math.max(p, 0) * 6.283185307179586 / 6
	end

	if p < 120 then
		return 6.283185307179586
	end

	if p < 122 then
		return 6.283185307179586 * (1 - (p - 120) / 2)
	end

	return 0
end

function StartBlade(instance)
	if v2[instance] then
		return
	end

	v2[instance] = true
	task.spawn(function()
		local serverTimeNow = workspace:GetServerTimeNow()
		local v5 = 0
		local v6 = nil
		local cFrame = nil
		local v7 = false

		while v2[instance] do
			local shelter = instance:FindFirstChild("Shelter")
			local meshessawblade = shelter and shelter:FindFirstChild("Meshes/sawblade")
			local serverTimeNow2 = workspace:GetServerTimeNow()
			local v8 = serverTimeNow2 - (instance:GetAttribute("SawmillStartTime") or serverTimeNow2)
			v5 = (v5 + GetSpinSpeed(v8) * (serverTimeNow2 - serverTimeNow)) % 6.283185307179586

			if meshessawblade then
				if meshessawblade ~= v6 then
					cFrame = meshessawblade.CFrame

					if v8 >= 120 then
						v6 = meshessawblade
						v7 = true
					else
						v6 = meshessawblade
						v7 = false
					end
				end

				meshessawblade.CFrame = cFrame * CFrame.Angles(0, v5, 0)
			end

			if v8 >= 122 then
				v2[instance] = nil

				if meshessawblade and cFrame and not v7 then
					TweenService:Create(
						meshessawblade,
						TweenInfo.new(2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
						{
							CFrame = cFrame + createVector(0, -2.2, 0)
						}
					):Play()
					break
				else
					break
				end
			else
				RunService.Heartbeat:Wait()
				serverTimeNow = serverTimeNow2
			end
		end
	end)
end

function TrySawLog(instance, instance2)
	if not (instance2 and v[instance2.Name]) or v4[instance2] then
		return
	end

	if instance2:GetAttribute("Interaction") ~= "Item" then
		print("Sawmill: reject Interaction", instance2.Name)
		return
	end

	if instance2.Parent ~= workspace.Items and not instance2:FindFirstAncestorOfClass("Player") then
		print("Sawmill: reject parent", instance2.Name, instance2.Parent and instance2.Parent:GetFullName())
		return
	end

	if instance2:GetAttribute("Owner") ~= localPlayer.UserId and instance2:GetAttribute("LastOwner") ~= localPlayer.UserId then
		print(
			"Sawmill: reject owner",
			instance2.Name,
			tostring(instance2:GetAttribute("Owner")),
			(tostring(instance2:GetAttribute("LastOwner")))
		)
		return
	end

	v4[instance2] = true
	local parent = instance2.Parent
	instance2.Parent = game.ReplicatedStorage.TempStorage
	local touchPart = instance:FindFirstChild("Functional") and instance.Functional:FindFirstChild("TouchPart")
	local sawmillBladeTouch = touchPart and touchPart:FindFirstChild("SawmillBladeTouch")

	if sawmillBladeTouch then
		Client.Sound.Play("SawmillSaw", {
			Position = sawmillBladeTouch.Position,
			Replicate = true
		})
	end

	local success, result = pcall(function()
		return Client.Events.RequestSawmillSaw:InvokeServer(instance, instance2)
	end)

	if success and result and result.Success then
		v4[instance2] = nil
		return
	end

	local name = instance2.Name

	if success and result then
		result = result.Reason or result
	end

	print("Sawmill: server rejected", name, result)
	task.delay(0.5, function()
		instance2.Parent = parent
		v4[instance2] = nil
	end)
end

function StartSawSweep(instance)
	if v3[instance] then
		return
	end

	v3[instance] = true
	task.spawn(function()
		local sawmillBladeTouch = instance:WaitForChild("Functional").TouchPart:WaitForChild("SawmillBladeTouch")

		while instance:GetAttribute("LoggingCampState") == "Sawing" do
			overlapParams.FilterDescendantsInstances = { workspace.Items }

			for _, v5 in pairs(workspace:GetPartsInPart(sawmillBladeTouch, overlapParams)) do
				task.spawn(TrySawLog, instance, v5.Parent)
			end

			task.wait(0.4)
		end

		v3[instance] = nil
	end)
end

function SetupSawTouch(instance)
	instance:WaitForChild("Functional"):WaitForChild("TouchPart"):WaitForChild("SawmillBladeTouch").Touched:Connect(function(otherPart)
		if instance:GetAttribute("LoggingCampState") ~= "Sawing" then
			return
		end

		TrySawLog(instance, otherPart.Parent)
	end)
end

function CampAdded(instance)
	task.spawn(function()
		SetupSawTouch(instance)
	end)
	instance:GetAttributeChangedSignal("LoggingCampState"):Connect(function()
		if instance:GetAttribute("LoggingCampState") == "Sawing" then
			StartBlade(instance)
			StartSawSweep(instance)
		end
	end)

	if instance:GetAttribute("LoggingCampState") == "Sawing" then
		task.spawn(function()
			Client.UtilityAlec.preload({
				"rbxassetid://93196474551553",
				"rbxassetid://104427212319988",
				"rbxassetid://73449814291911"
			})
		end)
		StartBlade(instance)
		StartSawSweep(instance)
	end
end

function LoggingCampClient.Init()
	Client.InteractionHandler.RegisterInteraction("SawmillLever", function(p)
		Client.Events.RequestPullSawmillLever:FireServer(p)
	end)
	Client.Utility.ForAllTagged("LoggingCamp", CampAdded)
end

return LoggingCampClient