local TweenService = game:GetService("TweenService")
local DeerInjuredClient = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
local parent2 = nil
local currentState = 0
local hungerToRestore = 200
local thread = nil

function GetMappedValue(p, _)
	if p >= 170 then
		return 0.2
	end

	return 2 - p / 170 * 1.8
end

function OnDeerFed()
	if not (parent2 and parent2:FindFirstChild("HungryHighlight")) then
		return
	end

	local hungryHighlight = parent2:FindFirstChild("HungryHighlight")

	if not hungryHighlight then
		return
	end

	print(GetMappedValue(parent2:GetAttribute("HungerToRestore"), hungerToRestore))
	local v2 = GetMappedValue(parent2:GetAttribute("HungerToRestore"), hungerToRestore)

	local function fadeBack()
		if thread then
			task.cancel(thread)
			thread = nil
		end

		TweenService:Create(hungryHighlight, TweenInfo.new(v2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
			FillTransparency = 1
		}):Play()
		thread = task.delay(v2, function()
			TweenService:Create(hungryHighlight, TweenInfo.new(v2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
				FillTransparency = 0.75
			}):Play()
			thread = nil
		end)
	end

	fadeBack()
end

local v2 = { function()
		wait(2)
		local rightLeg = parent2:FindFirstChild("RightLeg")
		local brokenDeerAntler = parent2.Parent:FindFirstChild("Broken Deer Antler")

		if rightLeg and rightLeg:FindFirstChild("Highlight") and brokenDeerAntler and brokenDeerAntler:FindFirstChild("Highlight") then
			task.spawn(function()
				local highlight = rightLeg:FindFirstChild("Highlight")
				local highlight2 = brokenDeerAntler.Highlight

				while parent2.Parent and (parent2:GetAttribute("LegHealed") == nil or parent2:GetAttribute("AntlerHealed") == nil) do
					wait(3)

					if highlight and parent2:GetAttribute("LegHealed") == nil then
						TweenService:Create(
							highlight,
							TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
							{
								FillTransparency = 0.7
							}
						):Play()
					end

					if highlight2 and parent2:GetAttribute("AntlerHealed") == nil then
						TweenService:Create(
							highlight2,
							TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
							{
								FillTransparency = 0.7
							}
						):Play()
					end

					wait(0.2)

					if highlight and parent2:GetAttribute("LegHealed") == nil then
						TweenService:Create(
							highlight,
							TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
							{
								FillTransparency = 1
							}
						):Play()
					end

					if highlight2 and parent2:GetAttribute("AntlerHealed") == nil then
						TweenService:Create(
							highlight2,
							TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
							{
								FillTransparency = 1
							}
						):Play()
					end
				end

				if highlight then
					highlight.Adornee = nil
					highlight:Destroy()
				end

				if highlight2 then
					highlight2.Adornee = nil
					highlight2:Destroy()
				end
			end)
		end
	end, function()
		task.spawn(function()
			wait(4)

			if parent2:FindFirstChild("HungryHighlight") then
				return
			end

			local highlight = Instance.new("Highlight")
			highlight.Name = "HungryHighlight"
			highlight.FillColor = Color3.fromRGB(58, 109, 3)
			highlight.OutlineTransparency = 1
			highlight.FillTransparency = 1
			highlight.DepthMode = Enum.HighlightDepthMode.Occluded
			highlight.Parent = parent2
			TweenService:Create(highlight, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
				FillTransparency = 0.75
			}):Play()
		end)
	end, function()
		if parent2:FindFirstChild("HungryHighlight") then
			parent2.HungryHighlight.Adornee = nil
			parent2.HungryHighlight:Destroy()
		end

		task.spawn(function()
			wait(4.1)

			if parent2:FindFirstChild("HungryHighlight") then
				parent2.HungryHighlight.Adornee = nil
				parent2.HungryHighlight:Destroy()
			end
		end)
	end }

function ActivateHealPrompt(instance)
	local healCheck = instance:GetAttribute("HealCheck")
	instance.Triggered:Connect(function()
		if parent2:GetAttribute(healCheck) then
			return
		end

		local toolEquipped = Client.InventoryHandler.ToolEquipped()
		local model = toolEquipped and toolEquipped.Model

		if not model or model.Name ~= "Bandage" and model.Name ~= "MedKit" then
			return
		end

		print("attempt heal")
		model.Parent = game.ReplicatedStorage.TempStorage
		local v3 = Client.Events.RequestHealInjuredDeer:InvokeServer(parent2, model, healCheck)

		if not (v3 and v3.Success) then
			task.delay(0.5, function()
				if model.Parent == game.ReplicatedStorage.TempStorage then
					model.Parent = localPlayer.Inventory
				end
			end)
		end
	end)
end

function ConnectHealPrompts(instance)
	local descendants = {}

	for _, descendant in pairs(instance.PrimaryPart:GetDescendants()) do
		if descendant.Name ~= "HealPrompt" then
			continue
		end

		table.insert(descendants, descendant)
		ActivateHealPrompt(descendant)
	end

	local function updatePrompts()
		local toolEquipped = Client.InventoryHandler.ToolEquipped()
		local model = toolEquipped and toolEquipped.Model
		local v3 = model and (model.Name == "Bandage" or model.Name == "MedKit") and true or false

		for _, v4 in pairs(descendants) do
			local attribute = instance:GetAttribute((v4:GetAttribute("HealCheck")))
			v4.Enabled = v3 and not attribute
		end
	end

	updatePrompts()
	Client.Events.EquippedItemChanged:Connect(function()
		updatePrompts()
	end)
end

Client.Events.OnDeerFed:Connect(function()
	OnDeerFed()
end)
local flag = true

function ConnectFoodPrompt(instance)
	local v3 = {}
	instance:WaitForChild("FeedTouchZone").Touched:Connect(function(otherPart)
		local DELAY_DURATION = 0.5
		local parent = otherPart.Parent

		if not parent.Parent or parent:GetAttribute("Owner") ~= localPlayer.UserId and parent:GetAttribute("LastOwner") ~= localPlayer.UserId or v3[parent] then
			return
		end

		v3[parent] = true
		task.delay(DELAY_DURATION, function()
			v3[parent] = nil
		end)

		if parent.Name == "Purple Fur Tuft" then
			if instance:GetAttribute("CurrentState") == 4 then
				parent.Parent = game.ReplicatedStorage.TempStorage
				local v4 = Client.Events.RequestGiveDeerFur:InvokeServer(instance, parent)

				if not (v4 and v4.Success) then
					task.delay(DELAY_DURATION, function()
						if parent.Parent == game.ReplicatedStorage.TempStorage then
							parent.Parent = workspace.Items
						end
					end)
				end
			elseif flag then
				flag = false
				Client.PopUpUI.AddPopUp("the deer might want this later...", "hungrydeer")
				task.spawn(function()
					wait(5)
					flag = true
				end)
			end
		else
			if instance:GetAttribute("CurrentState") ~= 2 then
				return
			end

			if parent:GetAttribute("RestoreHunger") then
				parent.Parent = game.ReplicatedStorage.TempStorage
				task.spawn(function()
					OnDeerFed()
				end)
				local v4 = Client.Events.RequestFeedInjuredDeer:InvokeServer(instance, parent)

				if not (v4 and v4.Success) then
					task.delay(DELAY_DURATION, function()
						if parent.Parent == game.ReplicatedStorage.TempStorage then
							parent.Parent = workspace.Items
						end
					end)
				end
			end
		end
	end)
end

function DeerAdded(instance)
	if not instance:IsDescendantOf(workspace) then
		return
	end

	parent2 = instance
	currentState = parent2:GetAttribute("CurrentState") or 0

	if currentState ~= 0 then
		v2[currentState]()
	end

	parent2:GetAttributeChangedSignal("CurrentState"):Connect(function()
		currentState = parent2:GetAttribute("CurrentState") or 1

		if v2[currentState] then
			v2[currentState]()
		end
	end)
	parent2.PrimaryPart.Touched:Connect(function(otherPart)
		if otherPart.Name == "TorchTouchZone" then
			print("Deer touched by torch")
			Client.Events.HurtDeerTorch:FireServer(parent2)
		end
	end)
	task.spawn(function()
		wait(4)
		hungerToRestore = parent2:GetAttribute("HungerToRestore") or 200
	end)
	ConnectHealPrompts(instance)
	ConnectFoodPrompt(instance)
end

function DeerRemoved(_) end

function DeerInjuredClient.Init()
	Client.Utility.ForAllTagged("DeerInjured", DeerAdded, DeerRemoved)
end

return DeerInjuredClient