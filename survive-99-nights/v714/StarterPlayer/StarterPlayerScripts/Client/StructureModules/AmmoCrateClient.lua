local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
local ammoCrateUpgraded = nil
local v = 3
local v2 = nil
local AmmoCrateClient = {
	OpenBox = function(p)
		v2 = p

		if v2.Name == "Heavy Ammo Crate" then
			ammoCrateUpgraded = Client.Interface.AmmoCrateUpgraded
			Client.Interface.AmmoCrate.Visible = false
		else
			ammoCrateUpgraded = Client.Interface.AmmoCrate
			Client.Interface.AmmoCrateUpgraded.Visible = false
		end

		ammoCrateUpgraded.Amount.ScrapAmount.Text = workspace.Map.Campground:GetAttribute("TotalScrap")
		ammoCrateUpgraded.Visible = true
	end
}
local v3 = true
local flag = true

function DoErrorMessage(p, p2)
	if flag then
		Client.PopUpUI.AddPopUp(p2, "warning")
		flag = false
		task.spawn(function()
			for _ = 1, 3 do
				p.TextColor3 = Color3.fromRGB(255, 0, 0)
				wait(0.3)
				p.TextColor3 = Color3.fromRGB(255, 255, 255)
				wait(0.3)
			end

			p.TextColor3 = Color3.fromRGB(255, 0, 0)
		end)
		task.spawn(function()
			wait(2.1)
			p.TextColor3 = Color3.fromRGB(255, 255, 255)
			flag = true
		end)
	end
end

function BuyAmmo(p)
	if not (v2 and v2.Parent) then
		ammoCrateUpgraded.Visible = false
	elseif v3 and v2 then
		Client.Sound.Play("KeyPress", {
			Duplicate = true
		})
		v3 = false

		if p == "Shotgun Ammo" then
			v = 20
		elseif p == "Explosive Rifle Ammo" or p == "Explosive Revolver Ammo" then
			v = 5
		else
			v = 3
		end

		local totalScrap = workspace.Map.Campground:GetAttribute("TotalScrap")
		local totalScrap2 = workspace.Map.Campground:GetAttribute("TotalScrap")

		if v <= totalScrap2 then
			Client.PopUpUI.AddPopUp(p .. " purchased")
			ammoCrateUpgraded.Amount.ScrapAmount.Text = totalScrap - v
			Client.Events.AmmoBoxConsume:FireServer(v2, p)
		else
			DoErrorMessage(ammoCrateUpgraded.Amount.ScrapAmount, "not enough scrap")
		end

		task.spawn(function()
			wait(0.2)
			v3 = true
		end)
	end
end

function HeavyAmmoButtonInitialize()
	local ammoCrateUpgraded2 = Client.Interface.AmmoCrateUpgraded
	ammoCrateUpgraded2.Amount.Frame.RevolverLabel.Activated:Connect(function()
		BuyAmmo("Revolver Ammo")
	end)
	ammoCrateUpgraded2.Amount.Frame.RifleLabel.Activated:Connect(function()
		BuyAmmo("Rifle Ammo")
	end)
	ammoCrateUpgraded2.Amount.Frame.ShotgunLabel.Activated:Connect(function()
		BuyAmmo("Shotgun Ammo")
	end)
	ammoCrateUpgraded2.Amount.ExplosiveFrame.RevolverLabel.Activated:Connect(function()
		BuyAmmo("Explosive Revolver Ammo")
	end)
	ammoCrateUpgraded2.Amount.ExplosiveFrame.RifleLabel.Activated:Connect(function()
		BuyAmmo("Explosive Rifle Ammo")
	end)
	ammoCrateUpgraded2.CloseButton.MouseButton1Down:Connect(function()
		Client.Sound.Play("CloseButton")
		ammoCrateUpgraded.Visible = false
	end)
end

function AmmoCrateClient.Init()
	task.spawn(function()
		ammoCrateUpgraded = Client.Interface.AmmoCrate
		ammoCrateUpgraded.CloseButton.MouseButton1Down:Connect(function()
			Client.Sound.Play("CloseButton")
			ammoCrateUpgraded.Visible = false
		end)
		ammoCrateUpgraded.Amount.Frame.RifleLabel.MouseButton1Down:Connect(function()
			BuyAmmo("Rifle Ammo")
		end)
		ammoCrateUpgraded.Amount.Frame.RevolverLabel.MouseButton1Down:Connect(function()
			BuyAmmo("Revolver Ammo")
		end)
		ammoCrateUpgraded.Amount.Frame.ShotgunLabel.MouseButton1Down:Connect(function()
			BuyAmmo("Shotgun Ammo")
		end)
		HeavyAmmoButtonInitialize()
	end)
end

return AmmoCrateClient