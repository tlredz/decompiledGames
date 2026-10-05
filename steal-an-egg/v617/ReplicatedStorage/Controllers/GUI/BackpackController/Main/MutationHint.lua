local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Save = require(ReplicatedStorage.Shared.Save)
local Trove = require(ReplicatedStorage.Packages.Trove)
return function(parent, instance)
	local localPlayer = Players.LocalPlayer
	local maid = Trove.new()
	local v = Trove.new()
	maid:Add(v)
	local v2 = nil
	local textLabel = Instance.new("TextLabel")
	textLabel.Name = "MutationHint"
	textLabel.AnchorPoint = Vector2.new(0.5, 1)
	textLabel.Position = UDim2.new(0.5, 0, 0, -8)
	textLabel.Size = UDim2.new(1, 0, 0, 52.5)
	textLabel.BackgroundTransparency = 1
	textLabel.Font = Enum.Font.GothamBold
	textLabel.TextColor3 = Color3.new(1, 1, 1)
	textLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
	textLabel.TextStrokeTransparency = 0.25
	textLabel.Text = "Click on an egg to apply the mutation"
	textLabel.TextSize = 25
	textLabel.TextScaled = true
	textLabel.TextWrapped = false
	textLabel.Active = false
	textLabel.ZIndex = 10
	textLabel.Visible = false
	local uITextSizeConstraint = Instance.new("UITextSizeConstraint")
	uITextSizeConstraint.MaxTextSize = 25
	uITextSizeConstraint.Parent = textLabel
	textLabel.Parent = parent
	maid:Add(textLabel)
	local v3 = Trove.new()
	maid:Add(v3)

	local function updateLayout()
		local currentCamera = Workspace.CurrentCamera

		if not currentCamera or parent.Size.X.Offset <= 0 or parent.AbsoluteSize.X <= 0 then
			return
		end

		local viewportSize = currentCamera.ViewportSize
		local v4 = parent.AbsoluteSize.X / parent.Size.X.Offset
		local touchEnabled = UserInputService.TouchEnabled
		local v5

		if touchEnabled then
			v5 = math.min(viewportSize.X, viewportSize.Y) * 0.052
		else
			v5 = viewportSize.Y * 0.03148148148148148
		end

		local v6 = math.max(v5, 14)
		local v7 = viewportSize.X * (touchEnabled and 0.76 or 0.7)
		local v8 = v6 / v4
		textLabel.Size = UDim2.fromOffset(v7 / v4, v8 * 1.3)
		textLabel.Position = UDim2.new(0.5, 0, 0, -math.max(8, viewportSize.Y * 0.012) / v4)
		uITextSizeConstraint.MinTextSize = 1
		uITextSizeConstraint.MaxTextSize = math.max(1, (math.floor(v8 + 0.5)))
		textLabel.TextSize = uITextSizeConstraint.MaxTextSize
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function bindCamera()
		v3:Clean()
		local currentCamera = Workspace.CurrentCamera

		if currentCamera then
			v3:Connect(currentCamera:GetPropertyChangedSignal("ViewportSize"), updateLayout)
		end

		updateLayout()
	end

	maid:Connect(Workspace:GetPropertyChangedSignal("CurrentCamera"), bindCamera)
	maid:Connect(parent:GetPropertyChangedSignal("AbsoluteSize"), updateLayout)
	maid:Connect(UserInputService:GetPropertyChangedSignal("TouchEnabled"), updateLayout)
	bindCamera() -- equivalent call inferred; original call site unknown

	local function refresh()
		textLabel.Visible = false
		local v4 = Save.Peek()

		if instance.Visible or not v2 or v4 == nil then
			return
		end

		if not v4.BossMastery or v4.BossMastery.HasUsedMutationConsumable then
			return
		end

		local humanoid = v2:FindFirstChildOfClass("Humanoid")

		if not humanoid or humanoid.Health <= 0 then
			return
		end

		for _, tool in v2:GetChildren() do
			if not (tool:IsA("Tool") and tool:GetAttribute("ItemType") == "MutationConsumable") then
				continue
			end

			local mutationId = tool:GetAttribute("MutationId") or "Boss"

			if not (mutationId == "Boss" or mutationId == "Scrambled") then
				continue
			end

			textLabel.Visible = true
			break
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function bindCharacter(character)
		v:Clean()
		v2 = character

		if character then
			-- equivalent calls inferred from this helper; original call sites unknown
			local function watchChild(humanoid)
				if humanoid:IsA("Humanoid") then
					v:Connect(humanoid.Died, refresh)
				end
			end

			for _, child in character:GetChildren() do
				watchChild(child) -- equivalent call inferred; original call site unknown
			end

			v:Connect(character.ChildAdded, function(humanoid)
				watchChild(humanoid) -- equivalent call inferred; original call site unknown
				refresh()
			end)
			v:Connect(character.ChildRemoved, refresh)
		end

		refresh()
	end

	maid:Connect(localPlayer.CharacterAdded, bindCharacter)
	maid:Connect(localPlayer.CharacterRemoving, function()
		bindCharacter(nil) -- equivalent call inferred; original call site unknown
	end)
	maid:Connect(instance:GetPropertyChangedSignal("Visible"), refresh)
	maid:Add(task.spawn(function()
		if Save.Await() ~= nil then
			refresh()
		end
	end))
	maid:Add(Save.WatchFields("BossMastery", refresh))
	maid:Connect(parent.Destroying, function()
		maid:Destroy()
	end)
	bindCharacter(localPlayer.Character)
end