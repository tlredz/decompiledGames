local module = require("@game/ReplicatedStorage/Omni")
local fusion = module.Libs.Fusion
local View = {
	Clean = function(connection)
		if typeof(connection) == "RBXScriptConnection" then
			connection:Disconnect()
			return
		end

		if typeof(connection) == "Instance" then
			connection:Destroy()
			return
		end

		if connection.Instance then
			return
		end

		if connection.doCleanup then
			connection:doCleanup()
		elseif connection.Destroy then
			connection:Destroy()
		elseif connection.Disconnect then
			connection:Disconnect()
		end
	end,
	Button = function(p, p2, value)
		local v = module.Button:Create(p, value or "Small")
		v:BindFunction("Commerce", p2)
		return v
	end,
	Animate = function(p, p2: number, flag: boolean?)
		local scope = fusion.scoped(fusion)
		local v

		if flag then
			v = UDim2.fromScale(-0.5, 0.5)
		else
			v = UDim2.fromScale(0.5, 1.5)
		end

		local value = scope:Value(v)
		scope:Hydrate(p)({
			Position = scope:Spring(value, 10, 1)
		})
		local thread = task.delay(p2 * 0.05, function()
			if p.Parent then
				value:set(UDim2.fromScale(0.5, 0.5))
			end
		end)
		table.insert(scope, function()
			if coroutine.status(thread) ~= "dead" then
				pcall(task.cancel, thread)
			end
		end)
		return scope
	end,
	Tooltip = function(data, text: string, connections)
		local v = module.Libs.NeoHover.GetByIdentifier("Tooltip")

		if not v then
			return
		end

		table.insert(connections, data.MouseEnter:Connect(function()
			v:Open(data, {
				Text = text
			})
		end))
		table.insert(connections, data.MouseLeave:Connect(function()
			v:Close(data)
		end))
		table.insert(connections, data.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.Touch then
				v:Click(data, {
					Text = text
				})
			end
		end))
	end,
	Image = function(value)
		if typeof(value) == "number" and value > 0 then
			return "rbxassetid://" .. value
		end

		if typeof(value) == "string" then
			return value
		end

		return ""
	end,
	RenderCharacter = function(viewport, name: string?, flag: boolean?, flag2: boolean?)
		if not viewport then
			return false
		end

		module.Utils.Camera.ClearViewport(viewport)
		viewport.Visible = false

		if typeof(name) ~= "string" or name == "" then
			return false
		end

		local character = module.Utils.Characters.Get({
			Name = name,
			Shiny = flag == true,
			RemoveHumanoidStates = true
		})

		if not character then
			return false
		end

		local viewportCharacter = module.Utils.Camera.ViewportCharacter
		local v2 = {
			Viewport = viewport,
			Character = character,
			Animation = module.Utils.Characters.GetCharacterAnimation(name, "Idle"),
			CustomCFrame = 0
		}
		local customCFrame

		if flag2 ~= true then
			customCFrame = CFrame.new(-0.25, -1.5, -3.5) * CFrame.Angles(0, 2.8797932657906435, 0) or nil
		end

		v2.CustomCFrame = customCFrame
		viewportCharacter(v2)
		viewport.Visible = true
		return true
	end
}

function View.RewardHover(data, data2, p, list)
	local v = ({
		Fighter = "Fighters",
		Weapon = "Weapons",
		Mount = "Mounts",
		Item = "Items"
	})[data2.Type]
	local v2 = p and v and module.Libs.NeoHover.GetByIdentifier(v)

	if v2 then
		local v3 = {
			IsFake = true,
			Name = data2.Name,
			Amount = data2.Amount,
			Data = {
				ID = "",
				Name = data2.Name,
				Level = data2.Level or 1,
				Exp = 0,
				Shiny = data2.Shiny == true
			}
		}
		table.insert(list, data.MouseEnter:Connect(function()
			v2:Open(data, v3)
		end))
		table.insert(list, data.MouseLeave:Connect(function()
			v2:Close(data)
		end))
		table.insert(list, data.Activated:Connect(function()
			v2:Click(data, v3)
		end))
		table.insert(list, {
			Destroy = function()
				if v2.Element == data then
					v2:Close(nil, true)
				end
			end
		})
	else
		local v3

		if data2.Type == "Fighter" then
			v3 = module.Shared.Fighters.GetDisplayName(data2.Name)
		else
			v3 = data2.Name
		end

		View.Tooltip(data, v3 .. " x" .. data2.Amount, list)
	end
end

function View.RenderReward(parent, p, p2)
	local reward = module.Shared.Gems.Reward(p, p.Origin)
	local v = {
		Fighter = module.Shared.Fighters.List,
		Weapon = module.Shared.Weapons.List,
		Mount = module.Shared.Mounts.List,
		Banner = module.Shared.ProfileBanners.List,
		Item = module.Shared.Items.List,
		Currency = module.Shared.Perks,
		Gamepass = module.Shared.Gamepasses
	}
	local v2 = {
		Fighter = module.Shared.Fighters.Exclusives,
		Weapon = module.Shared.Weapons.Exclusives,
		Mount = module.Shared.Mounts.Exclusives,
		Banner = module.Shared.ProfileBanners.Exclusives
	}
	local v3 = v[reward.Type]
	local v4 = v3 and v3[reward.Name]
	local v5 = v2[reward.Type]
	local v6 = v5 and v5[reward.Name]
	local rarity = v4 and v4.Rarity or v6 and v6.Rarity or reward.Type == "Gamepass" and "Exclusive" or nil
	local uIGradient = parent:FindFirstChild("UIGradient")
	local image = View.Image(reward.Icon)

	if uIGradient then
		uIGradient:SetAttribute("Rarity", rarity)
	end

	if image == "" and v4 and reward.Type ~= "Gamepass" then
		image = View.Image(v4.Icon)
	end

	parent.Icon.Image = image
	parent.Icon.Visible = image ~= ""
	parent.Title.Text = tostring(reward.Amount) .. "x"

	if reward.Type == "Fighter" then
		local viewport = parent:FindFirstChild("Viewport")

		if not viewport then
			viewport = module.Assets.Interface.Templates.Index.Slot.Main.Viewport:Clone()
			viewport.Parent = parent
		end

		if View.RenderCharacter(viewport, reward.Name, reward.Shiny, true) then
			parent.Icon.Visible = false
		end
	end

	View.RewardHover(parent, reward, v4, p2)
end

function View.ApplyGamepassInfo(data, p: string, p2)
	local image = View.Image(p2 and p2.IconImageAssetId)

	if image == "" then
		return
	end

	local icon = data.Offer.Kind == "Gamepass" and data.Offer.Name == p and data.Instance.Main:FindFirstChild("Icon")

	if icon then
		icon.Image = image
		icon.Visible = true
	end

	for _, rewardView in data.RewardViews do
		if not (rewardView.Type == "Gamepass" and rewardView.Name == p) then
			continue
		end

		rewardView.Content.Icon.Image = image
		rewardView.Content.Icon.Visible = true
	end
end

function View.Card(instance, parent, player, layoutOrder: number)
	local clone = instance:Clone()
	clone.Name = player.Name
	clone.LayoutOrder = layoutOrder
	local main = clone.Main
	main.Title.Text = player.Name

	if main:FindFirstChild("Desc") then
		main.Desc.Text = player.Description or ""
	end

	local uIGradient = main:FindFirstChild("UIGradient")

	if uIGradient and player.Color then
		uIGradient.Color = ColorSequence.new(Color3.new(1, 1, 1), player.Color)
	end

	local uIGradient2 = main.Title:FindFirstChild("UIGradient")

	if player.Kind == "Bundle" and uIGradient2 and player.Color then
		uIGradient2.Color = ColorSequence.new(Color3.new(1, 1, 1), player.Color)
	end

	if main:FindFirstChild("Thumb") then
		local thumb = main.Thumb
		local image

		if player.Kind == "Bundle" then
			image = player.Thumb or ""
		else
			image = player.Icon or ""
		end

		thumb.Image = image
		main.Thumb.Visible = main.Thumb.Image ~= ""
	end

	for _, viewportFrame in main:GetChildren() do
		if not viewportFrame:IsA("ViewportFrame") then
			continue
		end

		viewportFrame.Visible = false

		for _, baseScript in viewportFrame:GetDescendants() do
			if baseScript:IsA("BaseScript") then
				baseScript.Enabled = false
			end
		end
	end

	local icon = main:FindFirstChild("Icon")

	if player.Kind == "Bundle" then
		local character = View.RenderCharacter(main:FindFirstChild("ModelViewport"), player.Character, player.Shiny)

		if icon then
			icon.Image = View.Image(player.Icon)
			icon.Visible = not character and icon.Image ~= ""
		end
	elseif player.Kind == "Gamepass" and icon then
		icon.Image = ""
		icon.Visible = false
	elseif player.Kind == "GemPack" and icon then
		local image = View.Image(player.Icon)

		if image ~= "" then
			icon.Image = image
		end
	end

	local f2PIndicator = main:FindFirstChild("F2PIndicator")

	if f2PIndicator then
		f2PIndicator.Visible = player.Kind == "Gamepass" and module.Settings.F2PGamepasses[player.Name] == true
	end

	local buttons = main.Buttons

	for _, childName in { "Gems", "Gift" } do
		local child = buttons:FindFirstChild(childName)

		if child then
			child.Visible = false
		end
	end

	local robux = buttons:FindFirstChild("Robux") or buttons:FindFirstChild("Buy")
	local resources = {}
	local rewardViews = {}
	local rewards = main:FindFirstChild("Rewards")

	if rewards then
		rewards.Visible = true
		local uIListLayout = rewards:FindFirstChildWhichIsA("UIListLayout")
		local wraps = uIListLayout and uIListLayout.Wraps
		local automaticCanvasSize

		if wraps then
			automaticCanvasSize = Enum.AutomaticSize.Y
		else
			automaticCanvasSize = Enum.AutomaticSize.X
		end

		rewards.AutomaticCanvasSize = automaticCanvasSize
		local scrollingDirection

		if wraps then
			scrollingDirection = Enum.ScrollingDirection.Y
		else
			scrollingDirection = Enum.ScrollingDirection.X
		end

		rewards.ScrollingDirection = scrollingDirection
		local children = {}

		for _, child in rewards:GetChildren() do
			if child.Name == "Slot" then
				table.insert(children, child)
			end
		end

		local v5 = typeof(player.Rewards) ~= "table" and {} or table.clone(player.Rewards)

		if player.AllGamepasses then
			for _, v6 in module.Shared.CommerceCatalog.GetSection("Gamepasses") do
				table.insert(v5, {
					Type = "Gamepass",
					Name = v6.Name,
					Amount = 1
				})

				if typeof(v6.Rewards) ~= "table" then
					continue
				end

				for _, reward in v6.Rewards do
					table.insert(v5, reward)
				end
			end
		end

		for k, v6 in v5 do
			if not (typeof(v6) == "table" and typeof(v6.Type) == "string" and typeof(v6.Name) == "string") then
				continue
			end

			if typeof(v6.Amount) ~= "number" then
				continue
			end

			local clone2 = children[k]

			if not clone2 then
				clone2 = module.Assets.Interface.Templates.Shop.Reward:Clone()
				clone2.Parent = rewards
			end

			if not clone2 then
				continue
			end

			clone2.Name = "Reward" .. k
			clone2.LayoutOrder = k
			clone2.Visible = true
			local cloneMain = clone2:FindFirstChild("Main") or clone2
			View.RenderReward(cloneMain, v6, resources)
			table.insert(rewardViews, {
				Type = v6.Type,
				Name = v6.Name,
				Content = cloneMain
			})
		end

		for i = #v5 + 1, #children do
			children[i]:Destroy()
		end
	end

	clone.Parent = parent
	return {
		Instance = clone,
		Offer = player,
		Button = robux.Main,
		RobuxContainer = robux,
		GemsContainer = buttons:FindFirstChild("Gems"),
		GemsButton = buttons:FindFirstChild("Gems") and buttons.Gems.Main,
		Resources = resources,
		RewardViews = rewardViews,
		Animation = View.Animate(main, layoutOrder)
	}
end

function View.DestroyCard(data)
	local v = module.Libs.NeoHover.GetByIdentifier("Tooltip")

	if v and v.Element and v.Element:IsDescendantOf(data.Instance) then
		v:Close(nil, true)
	end

	if data.Bind then
		View.Clean(data.Bind)
	end

	if data.GemsBind then
		View.Clean(data.GemsBind)
	end

	for _, resource in data.Resources do
		View.Clean(resource)
	end

	View.Clean(data.Animation)
	data.Instance:Destroy()
end

return View