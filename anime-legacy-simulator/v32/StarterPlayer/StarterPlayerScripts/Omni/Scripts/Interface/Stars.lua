local module = require("@game/ReplicatedStorage/Omni")
local cframe = CFrame.Angles(0, 3.141592653589793, 0)
local _ = {
	YMaxOffset = 1,
	Duration = 5
}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Fusion = require(ReplicatedStorage.Omni.Libs.Fusion)
local stopButtons = module.Interface:WaitForChild("HUD"):WaitForChild("StopButtons")
local star = module.Interface:WaitForChild("Frames"):WaitForChild("Star")
local buttons = star:WaitForChild("Buttons")
local starSettings = module.Interface:WaitForChild("Frames"):WaitForChild("StarSettings")
local otherButtons = star:WaitForChild("OtherButtons")
local settings = otherButtons:WaitForChild("Settings")
local close = otherButtons:WaitForChild("Close")
local shinyChance = star:WaitForChild("ShinyChance")
local list = star:WaitForChild("List")
local price = star:WaitForChild("Price")
local pity = star:WaitForChild("Pity")
local rarities = module.Assets:WaitForChild("Effects"):WaitForChild("Rarities")
local starModel = module.Assets:WaitForChild("Models"):WaitForChild("StarModel")
local fakeStarModel = module.Assets:WaitForChild("Models"):WaitForChild("FakeStarModel")
local star2 = module.Assets:WaitForChild("Interface"):WaitForChild("HUD"):WaitForChild("Star")
local starOpen = module.Assets:WaitForChild("Interface"):WaitForChild("HUD"):WaitForChild("StarOpen")
local star3 = module.Assets:WaitForChild("Interface"):WaitForChild("Templates"):WaitForChild("Star")
local open = module.Assets:WaitForChild("Animations"):WaitForChild("Star"):WaitForChild("Open")
local v = 0
local loopConnection = nil
local loopConnection2 = nil
local count = 0
local count2 = 0
local v2 = 0
local v3 = false
local visible2 = false
local flag = false
local v5 = false
local v6 = nil
local v7 = nil
local count3 = 0
local count4 = 0
local size = otherButtons.Size
local scope = Fusion.scoped(Fusion)
local value = scope:Value(nil)
local value2 = scope:Value(false)
local value3 = scope:Value(false)
local value4 = scope:Value(0)
local spring = scope:Spring(value4, 10, 1)
local v8 = {}
local v9 = {}
local Stars = {}

local function GetAccessDistance()
	if scope.peek(value2) then
		return 25
	end

	return 10
end

local function HasStarAccess(p: string, p2: number)
	local v10 = module.Shared.Stars.List[p]

	if not v10 then
		return false
	end

	if module.Data.Gamepasses["Remote Access"] == true and module.Utils.PlayerStats.OwnsMap(v10.MapName, module.Data) then
		return true
	end

	local HRP = module:GetHRP()

	if not HRP then
		return false
	end

	for _, v11 in v8 do
		if v11.Name == p and v11.Model:IsDescendantOf(workspace) and (HRP.Position - v11.OriginalPosition).Magnitude < p2 then
			return true
		end
	end

	return false
end

-- equivalent calls inferred from this helper; original call sites unknown
local function HasInventorySpace()
	local _, _, v10 = module.Utils.PlayerStats.FightersInventory(module.Data, module.Instance)
	return v10 > 0
end

local function Notify(message: string)
	module.Signal:FireSelf("Interface", "Notifications", "Create", "Text", {
		Message = message,
		Color = Color3.new(1, 1, 0)
	})
end

-- equivalent calls inferred from this helper; original call sites unknown
local function CheckInventorySpace()
	if HasInventorySpace() then
		return true
	end

	local v10 = scope.peek(value2)
	Stars.CancelAutoRoll()
	Notify(v10 and "Your inventory is full! Auto roll stopped." or "Your inventory is full!")
	return false
end

-- equivalent calls inferred from this helper; original call sites unknown
local function StopForInventory()
	if not scope.peek(value2) then
		return
	end

	Stars.CancelAutoRoll()
	Notify("Your inventory is full! Auto roll stopped.")
end

-- equivalent calls inferred from this helper; original call sites unknown
local function SuspendAutoRoll()
	local v10 = scope.peek(value)

	if v10 and scope.peek(value2) then
		v6 = v10
		v7 = nil
	end

	Stars.CancelAutoRoll(true)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function PauseAutoRoll()
	if not scope.peek(value2) then
		Stars.CancelAutoRoll()
		return
	end

	SuspendAutoRoll() -- equivalent call inferred; original call site unknown
	Notify("You moved away from the star! Come back to resume the auto roll.")
end

local function TemplateUpdater(p, p2: number)
	p.Main.Position = UDim2.fromScale(0.5, p2 * 0.5 + 0.5)
end

local function SetupAnimations()
	local value5 = scope:Value(nil)
	local value6 = scope:Value(nil)
	local value7 = scope:Value(nil)
	local visible = scope:Value(nil)
	scope:Observer(value):onBind(function()
		if scope.peek(value) then
			value5:set(UDim2.fromScale(0.137, 0.192))
			value6:set(size)
		else
			value5:set(UDim2.fromScale(0, 0))
			value6:set(UDim2.fromScale(0, 0))
		end
	end)
	scope:Observer(value2):onBind(function()
		if scope.peek(value2) then
			visible:set(true)
			value7:set(UDim2.fromScale(1, 1))
		else
			visible:set(false)
			value7:set(UDim2.fromScale(0, 0))
		end
	end)
	scope:Hydrate(buttons)({
		Size = scope:Spring(value5, 10, 1)
	})
	scope:Hydrate(otherButtons)({
		Size = scope:Spring(value6, 10, 1)
	})
	scope:Hydrate(stopButtons.StopStar)({
		Visible = visible,
		Size = scope:Spring(value7, 10, 1)
	})
	scope:Observer(spring):onBind(function()
		local currentSpring = scope.peek(spring)

		if not currentSpring then
			return
		end

		if currentSpring == 1 then
			pity.Bar.Slider.UIGradient.Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0),
				NumberSequenceKeypoint.new(1, 0)
			})
			return
		elseif currentSpring == 0 then
			pity.Bar.Slider.UIGradient.Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 1),
				NumberSequenceKeypoint.new(1, 1)
			})
			return
		end

		local numberSequenceKeypoints = {}
		table.insert(numberSequenceKeypoints, NumberSequenceKeypoint.new(0, 0))
		table.insert(numberSequenceKeypoints, NumberSequenceKeypoint.new(currentSpring, 0))
		table.insert(numberSequenceKeypoints, NumberSequenceKeypoint.new(math.min(1, currentSpring + 0.1), 1))
		table.insert(numberSequenceKeypoints, NumberSequenceKeypoint.new(1, 1))
		pity.Bar.Slider.UIGradient.Transparency = NumberSequence.new(numberSequenceKeypoints)
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function RemoveStar(p)
	local v10 = v8[p]

	if not v10 then
		return
	end

	v8[p] = nil
	v10.HUD:Destroy()

	if v10.PrimaryPart.Parent then
		v10.PrimaryPart.Position = v10.OriginalPosition
		v10.PrimaryPart.Rotation = v10.OriginalRotation
	end
end

local function RefreshStar(model)
	local primaryPart = model.PrimaryPart
	local v10 = v8[model]

	if v10 and v10.PrimaryPart == primaryPart then
		return
	end

	RemoveStar(model) -- equivalent call inferred; original call site unknown

	if not (primaryPart and model:IsDescendantOf(workspace) and model:HasTag("StarModel")) then
		return
	end

	local name = model.Name
	local v11 = module.Shared.Stars.List[name]

	if not v11 then
		return
	end

	local position = primaryPart.Position
	local rotation = primaryPart.Rotation
	local clone = star2:Clone()
	clone.Frame.Title.Title.Text = name
	clone.Frame.Price.Value.Text = module.Utils.Number:Format(v11.Price.Amount)
	clone.Parent = primaryPart
	clone:AddTag("AnimatedHUD")
	v8[model] = {
		Name = name,
		Model = model,
		PrimaryPart = primaryPart,
		HUD = clone,
		Animating = false,
		OriginalPosition = position,
		OriginalRotation = rotation
	}
end

-- equivalent calls inferred from this helper; original call sites unknown
local function ForgetStar(k)
	local connection = v9[k]

	if connection then
		connection:Disconnect()
		v9[k] = nil
	end

	RemoveStar(k) -- equivalent call inferred; original call site unknown
end

local function AnimateStars()
	local currentCamera = workspace.CurrentCamera

	if not currentCamera then
		return
	end

	local position = currentCamera.CFrame.Position
	local v10 = math.sin(os.clock() / 5 * 3.141592653589793 * 2)
	local vector = Vector3.new(0, v10 * 360, 90)
	local vector2 = Vector3.new(0, v10 * 1, 0)

	for _, v11 in v8 do
		if (position - v11.OriginalPosition).Magnitude < 200 then
			v11.Animating = true
			v11.PrimaryPart.Position = v11.OriginalPosition + vector2
			v11.PrimaryPart.Rotation = vector
		elseif v11.Animating then
			v11.Animating = false
			v11.PrimaryPart.Position = v11.OriginalPosition
			v11.PrimaryPart.Rotation = v11.OriginalRotation
		end
	end
end

local function SetupConnections()
	module.Frame.FramesChangedSignal:Connect(function()
		if not flag then
			return
		end

		task.defer(function()
			if flag and not (module.Frame:IsFrameOpened(star) or module.Frame:IsFrameOpened(starSettings)) then
				Stars.CloseUI()
			end
		end)
	end)
	module.Services.UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed or not scope.peek(value) or not module.Frame:IsFrameOpened(star) then
			return
		end

		if input.KeyCode == Enum.KeyCode.E then
			Stars.Roll(1)
		elseif input.KeyCode == Enum.KeyCode.R then
			Stars.Roll()
		elseif input.KeyCode == Enum.KeyCode.T then
			Stars.StartAutoRoll()
		end
	end)
	local connection = module.Services.CollectionService:GetInstanceRemovedSignal("StarModel"):Connect(ForgetStar)
	local v10 = module.Utils.Instance:ObserveTaggedObject("StarModel", function(model)
		if not model:IsA("Model") then
			return
		end

		if not v9[model] then
			v9[model] = model:GetPropertyChangedSignal("PrimaryPart"):Connect(function()
				RefreshStar(model)
			end)
		end

		RefreshStar(model)
	end)
	script.Destroying:Connect(function()
		v10:Destroy()
		connection:Disconnect()

		for k in v9 do
			ForgetStar(k) -- equivalent call inferred; original call site unknown
		end
	end)
	module.Services.RunService.Heartbeat:Connect(function()
		AnimateStars()
		local now = os.clock()

		if now - v < 0.2 then
			return
		end

		v = now
		Stars.RefreshCloseStars()
	end)
end

local function SetupAutoRolling()
	local computed = scope:Computed(function(use)
		return use(value2) or use(value3)
	end)
	scope:Observer(computed):onBind(function()
		module.Frame:SetHidden(star, scope.peek(computed))
	end)
	local connection = module:OnDataChanged({ "Fighters" }, function()
		if not HasInventorySpace() then
			StopForInventory() -- equivalent call inferred; original call site unknown
		end
	end)
	script.Destroying:Connect(function()
		if connection then
			connection:Disconnect()
		end

		Stars.CancelAutoRoll(true)

		if loopConnection2 then
			loopConnection2:Disconnect()
			loopConnection2 = nil
		end
	end)
	scope:Observer(value2):onBind(function()
		if scope.peek(value2) then
			loopConnection = module.Utils.Loop:Connect({
				Time = 1,
				Identifier = "StarsAutoRollingLoop",
				Callback = function(connection2)
					if connection2 == loopConnection and scope.peek(value2) then
						Stars.Roll()
					else
						connection2:Disconnect()
					end
				end
			})
		elseif loopConnection then
			loopConnection:Disconnect()
			loopConnection = nil
		end
	end)
	scope:Observer(value3):onBind(function()
		local v10 = scope.peek(value2)

		if not scope.peek(value3) and v10 then
			local v11 = count
			task.defer(function()
				if v11 == count and scope.peek(value2) then
					Stars.Roll()
				end
			end)
		end
	end)
end

local function SetupButtons()
	close.Visible = false
	module.Button:Create(close.Main, "Default"):BindFunction("Click", function()
		if not visible2 then
			return
		end

		module.Frame:SetPastUI("Teleport")
		Stars.CloseUI()
	end)
	module.Button:Create(buttons.Single.Main, "Default"):BindFunction("Click", function()
		Stars.Roll(1)
	end)
	module.Button:Create(buttons.Max.Main, "Default"):BindFunction("Click", function()
		Stars.Roll()
	end)
	module.Button:Create(buttons.Auto.Main, "Default"):BindFunction("Click", function()
		Stars.StartAutoRoll()
	end)
	module.Button:Create(stopButtons.StopStar.Main, "Default"):BindFunction("Click", function()
		Stars.CancelAutoRoll()
	end)
	module.Button:Create(settings.Main, "Default"):BindFunction("Click", function()
		module.Frame:Open("StarSettings")
	end)
end

function Stars.CancelAutoRoll(flag2: boolean?)
	local v10 = scope.peek(value2)
	count += 1
	value2:set(false)

	if loopConnection then
		loopConnection:Disconnect()
		loopConnection = nil
	end

	if v10 and not flag2 then
		count4 = 0
		module.AutoRoll.SaveStar(nil)
	end
end

function Stars.StartAutoRoll()
	local v10 = scope.peek(value)

	if not v10 or scope.peek(value2) then
		return
	end

	-- equivalent call inferred; original call site unknown
	if not CheckInventorySpace() then
		return
	end

	count3 = 0
	value2:set(true)
	module.AutoRoll.SaveStar(v10)
end

function Stars.InventoryFull()
	if not scope.peek(value2) then
		return
	end

	Stars.CancelAutoRoll()
	Notify("Your inventory is full! Auto roll stopped.")
end

function Stars.Resume(p: string)
	if not module.Shared.Stars.List[p] then
		module.AutoRoll.SaveStar(nil)
		return
	end

	v6 = p
	v7 = nil
end

function Stars.Roll(p: number?)
	if v3 or scope.peek(value3) or os.clock() < v2 then
		return
	end

	local v10 = scope.peek(value)

	if not v10 then
		return
	end

	if HasStarAccess(v10, scope.peek(value2) and 25 or 10) then
		-- equivalent call inferred; original call site unknown
		if not CheckInventorySpace() then
			return
		end

		local v11 = p or module.Utils.PlayerStats.MaxStarOpens(module.Data, module.Instance)
		local v12 = 3.5 / module.Utils.PlayerStats.StarOpenSpeed(module.Data, module.Instance)
		v3 = true
		count2 += 1
		v2 = os.clock() + v12
		local v13 = count2
		module.Signal:Fire("General", "Stars", "Roll", v10, v11, v13)
		task.delay(math.max(30, v12 + 3), function()
			if v13 ~= count2 or not v3 then
				return
			end

			v3 = false
			module.AutoRoll.Expire("Stars", v13)
		end)
	else
		PauseAutoRoll() -- equivalent call inferred; original call site unknown
	end
end

function Stars.RollFailed(p: string, p2: number?, p3: string?)
	if module.AutoRoll.TakeExpired("Stars", p2) or (not v3 or p2 ~= count2 or p ~= scope.peek(value)) then
		return
	end

	v3 = false

	if module.AutoRoll.ShouldRetry(p3) then
		v2 = os.clock() + 1
		return
	end

	local v10 = scope.peek(value2)

	if p3 == "Access" and v10 then
		count3 += 1

		if count3 < 5 then
			v2 = os.clock() + 1
			return
		end

		if count4 < 3 then
			count4 += 1

			if not scope.peek(value2) then
				Stars.CancelAutoRoll()
				return
			end

			SuspendAutoRoll() -- equivalent call inferred; original call site unknown
			Notify("You moved away from the star! Come back to resume the auto roll.")
			return
		end
	end

	Stars.CancelAutoRoll()

	if not v10 then
		return
	end

	if p3 == "Access" then
		Notify("You are too far from the star! Auto roll stopped.")
	elseif p3 == "Invalid" then
		Notify("Auto roll stopped. Please try again!")
	end
end

local function SendDropNotification(data, p)
	local status = data.Deconstructed and "Deconstructed" or data.Sold and "Sold" or data.Deleted and "Deleted" or nil
	module.Signal:FireSelf("Interface", "Notifications", "Create", "Drop", {
		Type = "Fighter",
		Name = data.Name,
		Amount = data.Amount,
		Shiny = data.Shiny,
		Rarity = p.Rarity,
		Status = status
	})
end

function Stars.Rolled(p: string, list2, p2: number?)
	if module.AutoRoll.TakeExpired("Stars", p2) then
		for _, v10 in ipairs(list2) do
			local v11 = module.Shared.Fighters.List[v10.Name]

			if v11 then
				SendDropNotification(v10, v11)
			end
		end
	else
		if not v3 or p2 ~= count2 or p ~= scope.peek(value) then
			return
		end

		v3 = false
		count3 = 0
		count4 = 0

		if not module.Shared.Stars.List[p] then
			return
		end

		value3:set(true)
		local v10 = {}

		for _, v11 in ipairs(list2) do
			local v12 = module.Shared.Fighters.List[v11.Name]

			if v12 and v12.Rarity == "Secret" then
				module.Scripts.Rendering.SecretCutscene.Play(v11.Name, v11.Shiny)
				SendDropNotification(v11, v12)
			else
				table.insert(v10, v11)
			end
		end

		if #v10 == 0 then
			value3:set(false)
			return
		end

		local starOpenSpeed = module.Utils.PlayerStats.StarOpenSpeed(module.Data, module.Instance)
		local v11 = 3.5 / starOpenSpeed

		if module.Data.Settings["Hide Star Animation"] == true then
			local flag2 = false
			local destroyingConnection = script.Destroying:Connect(function()
				flag2 = true
			end)
			task.wait(v11)
			destroyingConnection:Disconnect()

			if flag2 then
				return
			end

			for _, v12 in ipairs(v10) do
				local v13 = module.Shared.Fighters.List[v12.Name]

				if v13 then
					SendDropNotification(v12, v13)
				end
			end

			value3:set(false)
		else
			local currentCamera = workspace.CurrentCamera
			local v12 = {}
			local v13 = {}

			for _, v14 in ipairs(v10) do
				local v15 = module.Shared.Fighters.List[v14.Name]

				if not v15 then
					continue
				end

				local allCharacterAnimations = module.Utils.Characters.GetAllCharacterAnimations(v14.Name)

				if not allCharacterAnimations then
					continue
				end

				local idle = allCharacterAnimations.Idle

				if not idle then
					continue
				end

				local model, _, HRP = module.Utils.Characters.Get({
					Name = v14.Name,
					Shiny = v14.Shiny,
					RemoveHumanoidStates = true
				})

				if not (model and HRP) then
					continue
				end

				v14.Rarity = v15.Rarity
				local clone = fakeStarModel:Clone()
				table.insert(v12, clone)
				v14.FakeStar = clone
				v14.FakeStarSize = v14.FakeStar:GetExtentsSize()
				v14.FakeStar:PivotTo(currentCamera.CFrame * CFrame.new(0, 0, -10))

				for _, part in v14.FakeStar:GetChildren() do
					if not part:IsA("BasePart") then
						continue
					end

					part.Massless = true
					part.CanTouch = false
					part.CanQuery = false
					part.CanCollide = false
					part.CastShadow = false
					part.CollisionGroup = "Fighters"
				end

				local clone2 = starModel:Clone()
				table.insert(v12, clone2)
				v14.Star = clone2
				v14.StarSize = v14.Star:GetExtentsSize()
				v14.Star:PivotTo(v14.FakeStar.PrimaryPart.CFrame * CFrame.Angles(1.5707963267948966, 0, 0))
				local weldConstraint = Instance.new("WeldConstraint")
				weldConstraint.Part0 = v14.FakeStar.MeshPart
				weldConstraint.Part1 = v14.Star.PrimaryPart
				weldConstraint.Parent = v14.FakeStar.MeshPart

				for _, part in v14.Star:GetChildren() do
					if not part:IsA("BasePart") then
						continue
					end

					part.Massless = true
					part.CanTouch = false
					part.CanQuery = false
					part.CanCollide = false
					part.CastShadow = false
					part.CollisionGroup = "Fighters"
				end

				v14.FakeStar.Parent = workspace.Cache
				v14.Star.Parent = workspace.Cache
				v14.HRP = HRP
				v14.HRP.Anchored = true
				v14.Model = model
				v14.Model.Parent = workspace.Cache
				table.insert(v12, v14.Model)
				v14.HUD = starOpen:Clone()
				v14.HUD.Holder.Main.Title.Text = v14.Name .. " (" .. v14.Amount .. "x)"
				v14.HUD.Holder.Main.Shiny.Visible = v14.Shiny == true
				v14.HUD.Holder.Main.Deleted.Visible = v14.Deleted == true
				v14.HUD.Holder.Main.Deleted.Text = v14.Deconstructed and "Deconstructed" or v14.Sold and "Sold" or "Deleted"
				v14.HUD.Holder.Main.Rarity.Text = v15.Rarity
				v14.HUD.Holder.Main.Rarity.UIGradient:SetAttribute("Rarity", v15.Rarity)
				v14.HUD.Holder.Main.Enabled = false
				v14.HUD.Parent = workspace.Cache
				table.insert(v12, v14.HUD)

				for _, part in v14.Model:GetChildren() do
					if not part:IsA("BasePart") then
						continue
					end

					part.Massless = true
					part.CanTouch = false
					part.CanQuery = false
					part.CanCollide = false
					part.CastShadow = false
					part.CollisionGroup = "Fighters"
				end

				v14.ModelAnimation = v14.Model.Humanoid.Animator:LoadAnimation(idle)
				v14.ModelAnimation.Priority = Enum.AnimationPriority.Action4
				v14.ModelAnimation.Looped = true
				v14.StarAnimation = v14.FakeStar.AnimationController.Animator:LoadAnimation(open)
				v14.StarAnimation.Priority = Enum.AnimationPriority.Action4
				v14.StarAnimation.Looped = false
				table.insert(v13, v14)
			end

			local count5 = #v13

			if count5 == 0 then
				value3:set(false)
				return
			end

			module.Signal:FireSelf("Player", "FOV", "Disable")
			local v14 = nil
			local v15 = nil
			local v16 = false
			local v17 = false
			local v18 = false

			-- equivalent calls inferred from this helper; original call sites unknown
			local function CancelSounds()
				v18 = true

				if v14 then
					v14:cancel()
					v14 = nil
				end

				if v15 then
					v15:cancel()
					v15 = nil
				end
			end

			local characterRemovingConnection = module.Instance.CharacterRemoving:Connect(CancelSounds)
			local destroyingConnection = script.Destroying:Connect(CancelSounds)
			local v19 = nil
			local v20 = nil

			local function Update(p3: number)
				if not v18 and p2 ~= count2 then
					CancelSounds() -- equivalent call inferred; original call site unknown
				end

				local now = os.clock()
				local cFrame = currentCamera.CFrame
				local screenCoverSize = module.Utils.Camera.GetScreenCoverSize(3, 0.5)

				if screenCoverSize ~= v19 then
					v19 = screenCoverSize
					v20 = module.Utils.Math.Create3DGrid(count5, screenCoverSize, 3, 1)
				end

				for i, v21 in ipairs(v13) do
					local v22 = v20[i]

					if not v22 then
						continue
					end

					local v23 = math.min(v22.Size.X, v22.Size.Y)
					local v24 = math.max(v21.StarSize.X, v21.StarSize.Y)
					local v25 = math.max(v21.FakeStarSize.X, v21.FakeStarSize.Y)
					local currentStarScale = 1 / (v24 / v23)
					local currentFakeStarScale = 1 / (v25 / v23)
					local currentEffectScale = 1 / (5 / v23)
					local v29 = v23 * 0.05
					local v30 = now / 2.5 * 3.141592653589793 * 2
					local v31 = not v21.UnitAnimationTime and 0 or math.sin(v30) * v29 or 0
					local v32 = not v21.UnitAnimationTime and 0 or math.cos(v30) * v29 or 0
					local v33 = not v21.UnitAnimationTime and 0 or -(v31 + v32) * v29 or 0
					local v34 = cFrame * v22.CFrame * CFrame.new(v31, v32, v33)

					if v21.Star and v21.CurrentStarScale ~= currentStarScale then
						v21.CurrentStarScale = currentStarScale
						v21.Star:ScaleTo(currentStarScale)
					end

					if v21.FakeStar and v21.CurrentFakeStarScale ~= currentFakeStarScale then
						v21.CurrentFakeStarScale = currentFakeStarScale
						v21.FakeStar:ScaleTo(currentFakeStarScale)
					end

					if v21.FakeStar then
						v21.FakeStar:PivotTo(v34)
					end

					if not v21.PlayedModelAnimation then
						v21.ModelAnimation:Play()
						v21.PlayedModelAnimation = true
					end

					if not v21.PlayedStarAnimation then
						v21.StarAnimation:Play(nil, nil, starOpenSpeed / 1.5)
						v21.PlayedStarAnimation = true
					end

					if v21.PlayedStarAnimation and not v21.StarAnimation.IsPlaying then
						if not (v17 or v18) then
							v17 = true

							if v14 then
								v14:cancel()
								v14 = nil
							end

							v15 = module.Sound:PlayEffect("Star.End", {
								MaxVoices = 1
							})
						end

						v21.UnitAnimationTime = (v21.UnitAnimationTime or 0) + p3
						local unitAnimationTime = v21.UnitAnimationTime or 0
						local v35 = math.min(unitAnimationTime / (0.3 / starOpenSpeed), 1)
						local v36 = unitAnimationTime / (2.5 / starOpenSpeed)

						if v21.Star then
							v21.Star:Destroy()
							v21.Star = nil
						end

						if v21.FakeStar then
							v21.FakeStar:Destroy()
							v21.FakeStar = nil
						end

						if v21.PlayedRarityEffect then
							if v21.RarityEffect then
								if v21.CurrentEffectScale ~= currentEffectScale then
									v21.CurrentEffectScale = currentEffectScale
									v21.RarityEffect:ScaleTo(currentEffectScale)
								end

								v21.RarityEffect:PivotTo(v34 * cframe)
							end
						else
							v21.PlayedRarityEffect = true
							local child = rarities:FindFirstChild(v21.Rarity)

							if child then
								local clone = child:Clone()
								clone:ScaleTo(currentEffectScale)
								clone:PivotTo(v34 * cframe)
								clone.Parent = workspace.Cache
								local weldConstraint = Instance.new("WeldConstraint")
								weldConstraint.Part0 = v21.HRP
								weldConstraint.Part1 = clone.PrimaryPart
								weldConstraint.Parent = clone
								module.Utils.Particles:Emit(clone)
								table.insert(v12, clone)
								v21.RarityEffect = clone
								v21.CurrentEffectScale = currentEffectScale
							end
						end

						local currentModelScale = currentEffectScale * v35

						if v21.CurrentModelScale ~= currentModelScale then
							v21.CurrentModelScale = currentModelScale
							v21.HUD:ScaleTo(currentModelScale)
							v21.Model:ScaleTo(currentModelScale)
						end

						v21.HUD.Holder.Main.Enabled = v35 >= 1
						v21.HUD:PivotTo(v34 * cframe)
						v21.Model:PivotTo(v34 * cframe * CFrame.Angles(0, math.rad(-90 + 180 * v36), 0))
					else
						local starAnimation = v21.StarAnimation

						if not v16 and not v17 and not v18 and starAnimation.Length > 0 and starAnimation.Speed > 0 then
							local duration = (starAnimation.Length - starAnimation.TimePosition) / starAnimation.Speed

							if duration > 0 then
								v16 = true
								v14 = module.Sound:PlayEffect("Star.Start", {
									Duration = duration,
									MaxVoices = 1
								})
							end
						end

						if v21.CurrentModelScale ~= 0.001 then
							v21.CurrentModelScale = 0.001
							v21.Model:ScaleTo(0.001)
						end
					end
				end
			end

			local preRenderConnection = module.Services.RunService.PreRender:Connect(Update)
			Update(0)
			task.wait(v11)
			preRenderConnection:Disconnect()
			characterRemovingConnection:Disconnect()
			destroyingConnection:Disconnect()

			if v14 then
				v14:cancel()
				v14 = nil
			end

			for _, v21 in ipairs(v13) do
				if v21.Star then
					v21.Star:Destroy()
				end

				if v21.FakeStar then
					v21.FakeStar:Destroy()
				end

				if v21.Model then
					v21.Model:Destroy()
				end
			end

			for _, v21 in v12 do
				if v21.Parent then
					v21:Destroy()
				end
			end

			module.Signal:FireSelf("Player", "FOV", "Enable")
			value3:set(false)
		end
	end
end

function Stars.IsRolling()
	return scope.peek(value3) == true
end

function Stars.IsAutoRolling()
	return scope.peek(value2) == true
end

function Stars.Start(p: string)
	local v10 = module.Shared.Stars.List[p]

	if not (v10 and module.Data.Gamepasses["Remote Access"] == true and module.Utils.PlayerStats.OwnsMap(
		v10.MapName,
		module.Data
	)) then
		return
	end

	Stars.OpenUI(p, true)
	module.Frame:Close("Teleport")
end

function Stars.OpenUI(current: string, flag2: boolean?)
	if not module.Shared.Stars.List[current] then
		return
	end

	if scope.peek(value) ~= current then
		Stars.CancelAutoRoll()
		count2 += 1
		v3 = false
	end

	if loopConnection2 then
		loopConnection2:Disconnect()
		loopConnection2 = nil
	end

	visible2 = flag2 == true
	flag = true
	v5 = false
	close.Visible = visible2
	value:set(current)
	module.Frame:Open(star)
	spring:setPosition(0)
	starSettings:SetAttribute("Current", current)
	Stars.RefreshInterface()
	loopConnection2 = module.Utils.Loop:Connect({
		Time = 1,
		Identifier = "StarsInterfaceRefreshLoop",
		Callback = function(connection)
			if scope.peek(value) then
				Stars.RefreshInterface()
			else
				connection:Disconnect()
			end
		end
	})
end

function Stars.CloseUI()
	if not flag then
		return
	end

	flag = false
	v5 = true

	if loopConnection2 then
		loopConnection2:Disconnect()
		loopConnection2 = nil
	end

	for _, frame in list:GetChildren() do
		if frame:IsA("Frame") then
			frame:Destroy()
		end
	end

	module.Frame:Close(starSettings)
	module.Frame:Close(star)
end

function Stars.RefreshInterface()
	if not flag then
		return
	end

	local v10 = scope.peek(value)

	if not v10 then
		return
	end

	local v11 = module.Shared.Stars.List[v10]

	if not v11 then
		return
	end

	local shinyChance2 = module.Utils.PlayerStats.ShinyChance(module.Data, module.Instance)
	shinyChance.Text = "Shiny Chance: " .. (module.Utils.Probability.FormatPercentage(shinyChance2) or "0%")
	local v12 = module.Utils.Info:Get(v11.Price.Type, v11.Price.Name) or {}
	price.Icon.Image = v12.Icon or ""
	price.Value.Text = module.Utils.Number:Format(v11.Price.Amount) .. " YEN"
	local v13 = module.Data.Pity[`Star_{v10}`] or {
		CurrentAmount = 0,
		CurrentIndex = 1
	}
	local v14 = v11.Pity[v13.CurrentIndex]

	if v14 then
		value4:set(v13.CurrentAmount / v14.Amount)
		pity.Value.Text = `{v14.Name} Pity: {module.Utils.Number:Format(v13.CurrentAmount)}/{module.Utils.Number:Format(v14.Amount)}`
	end

	local luck = module.Utils.PlayerStats.Luck(module.Data, module.Instance)
	local formatted = `Star_{v10}`
	local preview = module.Shared.Stars.GetPreview(
		v11,
		luck,
		module.Data.Pity[formatted],
		module.Shared.SoftPity.GetState(module.Data, formatted),
		module.Data
	)

	if not preview then
		return
	end

	local chances = preview.Chances
	local index = 0

	for _, chance in chances do
		if index < chance.Index then
			index = chance.Index
		end
	end

	for _, v15 in v11.List do
		if v15.Hide then
			continue
		end

		local chance = chances[v15.Name]
		local v16 = module.Shared.Fighters.List[v15.Name]

		if not (chance and v16) then
			continue
		end

		local clone = list:FindFirstChild(v15.Name)

		if not clone then
			clone = star3:Clone()
			clone.Name = v15.Name
			clone.Main.UIGradient:SetAttribute("Rarity", v16.Rarity)
			clone.LayoutOrder = -chance.Index
			clone.Parent = list
			clone.Visible = true
			module.Utils.Interface.Show({
				Holder = clone,
				Speed = 10,
				Update = TemplateUpdater,
				Delay = 0.5 * (1 - (chance.Index - 1) / index)
			})
		end

		clone.Main.Chance.Text = chance.Chance >= 0.1 and module.Utils.Probability.FormatPercentage(chance.Chance) or "???"
		local visible = clone:GetAttribute("Visible")
		local v17 = module.Shared.Index.GetAmount("Fighter", v15.Name, module.Data) > 0

		if visible == v17 then
			continue
		end

		clone:SetAttribute("Visible", v17)
		clone.Main.Title.Text = v17 ~= true and "???" or v15.Name or "???"
		module.Utils.Camera.ViewportCharacter({
			Locked = not v17,
			Viewport = clone.Main.Viewport,
			Animation = module.Utils.Characters.GetCharacterAnimation(v15.Name, "Idle"),
			Character = module.Utils.Characters.Get({
				Name = v15.Name,
				Shiny = v15.Shiny,
				RemoveHumanoidStates = true
			})
		})
	end

	for _, frame in list:GetChildren() do
		if not frame:IsA("Frame") then
			continue
		end

		local v15 = false

		for _, v17 in v11.List do
			if v17.Hide or frame.Name ~= v17.Name then
				continue
			end

			v15 = true
			break
		end

		if not v15 then
			frame:Destroy()
		end
	end
end

local function TryResume()
	if not v6 then
		return
	end

	local v10 = v6

	if scope.peek(value2) then
		v6 = nil
		return
	end

	if not v7 then
		v7 = os.clock() + 60
	end

	local now = os.clock()

	if v7 < now then
		v6 = nil
		module.AutoRoll.SaveStar(nil)
		Notify("You didn't return to the star in time. Auto roll stopped.")
	else
		if v3 or scope.peek(value3) or not HasStarAccess(v10, 20) then
			return
		end

		v6 = nil

		if flag then
			Stars.CloseUI()
		end

		if scope.peek(value) ~= v10 then
			count2 += 1
			v3 = false
		end

		visible2 = false
		value:set(v10)
		Stars.StartAutoRoll()

		if scope.peek(value2) then
			Notify("Auto roll resumed!")
			return
		end

		value:set(nil)
		module.AutoRoll.SaveStar(nil)
	end
end

local function GetAliveHRP()
	local HRP = module:GetHRP()

	if not HRP then
		return
	end

	local humanoid = HRP.Parent and HRP.Parent:FindFirstChildOfClass("Humanoid")

	if humanoid and humanoid.Health <= 0 then
		return
	else
		return HRP
	end
end

function Stars.RefreshCloseStars()
	local HRP = module:GetHRP()

	if HRP then
		local humanoid = HRP.Parent and HRP.Parent:FindFirstChildOfClass("Humanoid")

		if humanoid and humanoid.Health <= 0 then
			HRP = nil
		end
	else
		HRP = nil
	end

	if HRP then
		TryResume()
		local v10 = scope.peek(value)
		local hUDEnabled = v10 == nil
		local v12 = nil

		for _, v13 in v8 do
			local magnitude = (HRP.Position - v13.OriginalPosition).Magnitude

			if v13.HUDEnabled ~= hUDEnabled then
				v13.HUDEnabled = hUDEnabled
				v13.HUD:SetAttribute("Enabled", hUDEnabled)
			end

			if magnitude < 10 and (not v12 or magnitude < v12.Distance) then
				v12 = {
					Name = v13.Name,
					Distance = magnitude
				}
			end
		end

		if v10 and (visible2 and flag or scope.peek(value2) or v3 or scope.peek(value3)) then
			if not HasStarAccess(v10, scope.peek(value2) and 25 or 10) then
				PauseAutoRoll() -- equivalent call inferred; original call site unknown
				Stars.CloseUI()

				if not (v3 or scope.peek(value3)) then
					value:set(nil)
					visible2 = false
				end
			end
		else
			if not flag then
				value:set(nil)
				visible2 = false
			end

			if not v12 then
				v5 = false
			end

			if v5 or module.Frame:IsFrameOpened("Teleport") then
				return
			end

			if v12 and v12.Name ~= scope.peek(value) then
				Stars.OpenUI(v12.Name)
			elseif not v12 then
				Stars.CloseUI()
				value:set(nil)
			end
		end
	else
		SuspendAutoRoll() -- equivalent call inferred; original call site unknown
	end
end

function Stars.Init()
	SetupButtons()
	SetupAnimations()
	SetupConnections()
	SetupAutoRolling()
end

return Stars