local TweenService = game:GetService("TweenService")
local Consumable = {}
Consumable.__index = Consumable
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
localPlayer:GetMouse()
local count = 0
local v = nil
local v2 = false

function Consumable.new(model, realModel)
	local self = setmetatable({}, Consumable)
	self.Model = model
	self.RealModel = realModel
	return self
end

function HoldBar(p)
	local healBar = Client.Interface.HealBar
	healBar.Visible = true
	local fill = healBar:FindFirstChild("Fill")

	if v then
		v:Cancel()
	end

	fill.Size = UDim2.new(0, 0, 0.9, 0)
	v = TweenService:Create(fill, TweenInfo.new(0.25, Enum.EasingStyle.Linear), {
		Size = UDim2.new(0.95, 0, 0.8, 0)
	})
	v:Play()
	task.spawn(function()
		wait(0.25)

		if p == count then
			v2 = true
			healBar.Visible = false
			fill.Size = UDim2.new(0, 0, 0.9, 0)
		end
	end)
end

function Consumable.Activate(p)
	local realModel = p.RealModel
	local latest = Client.InventoryUI.GetLatestFromItemStack(realModel)

	if localPlayer:GetAttribute("Class") == "Bunny" and latest:GetAttribute("HasMeat") then
		Client.PopUpUI.AddPopUp("Bunny class can't eat meat", "easter")
		return
	end

	count += 1
	local v3 = count

	if realModel.Name == "MedKit" or realModel.Name == "Bandage" then
		HoldBar(v3)

		repeat
			wait()
		until v2 or v3 ~= count

		if v3 ~= count then
			return
		end
	end

	v2 = false
	local parent = latest.Parent
	latest.Parent = game.ReplicatedStorage.TempStorage
	task.spawn(function()
		local v4 = Client.Events.RequestConsumeItem:InvokeServer(latest)

		if v4 and v4.Success then
			if latest.Name == "Stew" or latest.Name == "Hearty Stew" or latest.Name == "Pumpkin Soup" or latest.Name == "Seafood Chowder" then
				Client.Sound.Play("Slurp", {
					Volume = 0.4,
					Replicate = true,
					Duplicate = true,
					ReplicationProperties = {
						Instance = localPlayer.Character.Head,
						Volume = 0.2
					}
				})
			else
				Client.Sound.Play("Eat", {
					Volume = 0.4,
					Replicate = true,
					Duplicate = true,
					ReplicationProperties = {
						Instance = localPlayer.Character.Head,
						Volume = 0.2
					}
				})
			end
		else
			wait(0.5)
			latest.Parent = parent
		end
	end)
end

function Consumable.Deactivate(_)
	Client.Interface.HealBar.Visible = false
	count += 1
end

function Consumable:OnEquip()
	self.Equipped = true

	if self.RealModel:GetAttribute("RestoreHealth") then
		Client.GuiButtonHandler.ShowButton("Heal (HOLD)")
	end
end

function Consumable:OnUnequip()
	self.Equipped = false
	Client.GuiButtonHandler.HideButton("Heal (HOLD)")
end

return Consumable