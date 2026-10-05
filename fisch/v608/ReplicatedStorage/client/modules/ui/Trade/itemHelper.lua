local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local item = ReplicatedStorage.resources.ui.trade.Item
local objectHelper = require(ReplicatedStorage.client.modules.ui.Backpack.objectHelper)
require(ReplicatedStorage.shared.FormatNumber)
local WorldController = require(ReplicatedStorage.client.legacyControllers.WorldController)
local RodSkins = require(ReplicatedStorage.shared.modules.RodSkins)
local bobbers = require(ReplicatedStorage.shared.modules.fishing.bobbers)
local fx = require(ReplicatedStorage.shared.modules.fx)
local ViewportModule = require(game.ReplicatedStorage.client.modules.ViewportModule)
local animatedgradient = require(ReplicatedStorage.shared.modules.fx.animatedgradient)
local assets = require(ReplicatedStorage.shared.utils.assets)
local vessels = require(ReplicatedStorage.shared.modules.vessels)
local library = vessels.library
local display = WorldController:GetCurrencyData(WorldController:GetCurrentCurrency()).Display
local v = {
	Currency = function(p, p2)
		local clone = item:Clone()

		if p2 then
			clone.InputBox.Visible = true
			clone.InputBox.Text = ""
			clone.MiddleLabel.Visible = false
			clone.Label.Text = display
		else
			clone.Label.Text = ""
			clone.MiddleLabel.Visible = true
			clone.MiddleLabel.Text = `{display}{p}`
		end

		return clone
	end,
	Item = function(p, _)
		local v2 = objectHelper.createWithData(p)

		if v2:FindFirstChild("Favourited") then
			v2.Favourited:Destroy()
		end

		return v2
	end,
	RodSkin = function(p: string, _)
		local clone = item:Clone()
		clone.Active = true
		clone.Selectable = true
		clone.Label.Text = RodSkins.Skins[p].DisplayText or p
		clone.Icon.Image = RodSkins.Skins[p].Icon
		return clone
	end,
	Boat = function(text: string, _)
		local v2 = library[text]
		local clone = item:Clone()
		clone.Active = true
		clone.Selectable = true
		clone.Label.Text = text
		clone.Icon.Image = v2.Icon
		return clone
	end,
	Bobber = function(p: string, _)
		local clone = item:Clone()
		clone.Active = true
		clone.Selectable = true
		clone.Label.Text = `[{p}]`
		local success, result = pcall(function()
			local bobber = bobbers.Bobbers[p]

			if bobber.Rarity == "Exotic" then
				clone.Label.TextColor3 = Color3.fromRGB(255, 255, 255)
				local new = animatedgradient.new(animatedgradient._presets.Rainbow)
				new.Parent = clone.Label
			elseif bobber.Rarity == "Secret" then
				clone.Label.TextColor3 = Color3.fromRGB(255, 255, 255)
				local new_2 = animatedgradient.new(animatedgradient._presets.Secret)
				new_2.Parent = clone.Label
			end

			if bobber.Icon then
				clone.Icon.Visible = true
				clone.Icon.Image = bobber.Icon
				clone.MouseEnter:Connect(function()
					clone.UIStroke.Color = Color3.fromRGB(255, 255, 255)
					fx:PlaySound(ReplicatedStorage.resources.sounds.sfx.ui.itemhover, script.Parent, true)
				end)
				clone.MouseLeave:Connect(function()
					clone.UIStroke.Color = Color3.fromRGB(0, 0, 0)
				end)
			else
				clone.vp.Visible = true
				local camera = Instance.new("Camera")
				camera.FieldOfView = 60
				camera.Parent = clone.vp
				clone.vp.CurrentCamera = camera
				clone.vp.Ambient = Color3.fromRGB(211, 211, 211)
				clone.vp.LightColor = Color3.fromRGB(255, 255, 255)
				local clone2 = assets.getAsync("bobber", p):Clone()
				clone2.PrimaryPart.Anchored = true
				clone2.Parent = clone.vp
				local v2 = ViewportModule.new(clone.vp, camera)
				local boundingBox, _ = clone2:GetBoundingBox()
				v2:SetModel(clone2)
				local cframe = CFrame.fromEulerAnglesYXZ(0, 0, 0.4363323129985824)
				local fitDistance = v2:GetFitDistance(boundingBox.Position)
				camera.CFrame = CFrame.new(boundingBox.Position) * cframe * CFrame.new(0, 0, fitDistance)
				local v3 = nil
				clone.MouseEnter:Connect(function()
					clone.UIStroke.Color = Color3.fromRGB(255, 255, 255)
					v3 = TweenService:Create(
						clone.vp.CurrentCamera,
						TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
						{
							FieldOfView = 50,
							CFrame = camera.CFrame * CFrame.Angles(0, 0, -0.05235987755982989)
						}
					):Play()
					fx:PlaySound(ReplicatedStorage.resources.sounds.sfx.ui.itemhover, script.Parent, true)
				end)
				clone.MouseLeave:Connect(function()
					clone.UIStroke.Color = Color3.fromRGB(0, 0, 0)

					if v3 then
						v3:Cancel()
					end

					v3 = TweenService:Create(
						clone.vp.CurrentCamera,
						TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
						{
							FieldOfView = 60,
							CFrame = camera.CFrame * CFrame.Angles(0, 0, 0.05235987755982989)
						}
					):Play()
				end)
			end
		end)

		if not success then
			warn((`couldn't setup ui for {p}. why? here's why: {result}`))
		end

		return clone
	end,
	Halo = function(p: string, _)
		local halos = require(ReplicatedStorage.shared.modules.library.halos)
		local halo = halos[p]
		local clone = item:Clone()
		clone.Active = true
		clone.Selectable = true
		clone.Label.Text = halo.DisplayText or p
		clone.Icon.Image = halo.Icon or ""
		return clone
	end,
	Lantern = function(p: string, _)
		local lanterns = require(ReplicatedStorage.shared.modules.library.lanterns)
		local lantern = lanterns[p]
		local clone = item:Clone()
		clone.Active = true
		clone.Selectable = true
		clone.Label.Text = lantern.DisplayText or p
		clone.Icon.Image = lantern.Icon or ""
		return clone
	end,
	BoothSkin = function(p: string, _)
		local SalesBooth = require(ReplicatedStorage.shared.modules.SalesBooth)
		local item2 = SalesBooth.Items[p]
		local clone = item:Clone()
		clone.Active = true
		clone.Selectable = true
		clone.Label.Text = item2.DisplayName or p
		clone.Icon.Image = item2.Icon or ""
		return clone
	end,
	Glider = function(p, _)
		local items = require(ReplicatedStorage.shared.modules.library.items)
		local item2 = items.Items[p.name]
		local clone = item:Clone()
		clone.Active = true
		clone.Selectable = true
		clone.Label.Text = p.name
		clone.Icon.Image = item2 and item2.Icon or ""
		return clone
	end,
	CompanionSkin = function(p: string, _)
		local skins = require(ReplicatedStorage.shared.modules.library.companions.skins)
		local skin = skins.Skins[p]
		local clone = item:Clone()
		clone.Active = true
		clone.Selectable = true
		clone.Label.Text = skin.DisplayText or p
		clone.Icon.Image = skin.Icon or ""
		return clone
	end
}
return {
	create = function(data, flag: boolean)
		local v2 = v[data.type](data.data, flag)

		if not v2:FindFirstChild("Stack") then
			return v2
		end

		if data.stack then
			v2.Stack.Text = "x" .. data.stack
			return v2
		end

		if data.type == "RodSkin" then
			v2.Stack.Text = "x1"
		end

		return v2
	end
}