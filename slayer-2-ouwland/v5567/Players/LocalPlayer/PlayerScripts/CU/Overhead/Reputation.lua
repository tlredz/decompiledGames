local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local faye = require(ReplicatedStorage.Packages.faye)
local interfaceutility = require(ReplicatedStorage.Packages.interfaceutility)
local BunchaIcons = require(ReplicatedStorage.CAM.Global.BunchaIcons)
local Platform_Handler = require(ReplicatedStorage.CAM.Client.Controllers.Platform_Handler)
return function(parent, character, _, _)
	local playerFromCharacter = Players:GetPlayerFromCharacter(character)

	if playerFromCharacter == nil then
		return
	end

	local v = faye.new()

	-- equivalent calls inferred from this helper; original call sites unknown
	local function listless()
		return Platform_Handler.IsGamepad() or Platform_Handler.Platform.Value == "Mobile"
	end

	local value = v:Value(listless())
	v:Connect(Platform_Handler.Platform.Changed.Event, function()
		value:Set(listless())
	end)
	local text = v:Value("")

	-- equivalent calls inferred from this helper; original call sites unknown
	local function follow(intValue)
		if not intValue:IsA("IntValue") then
			return
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function read()
			text:Set((tostring(intValue.Value)))
		end

		read() -- equivalent call inferred; original call site unknown
		v:Connect(intValue.Changed, read)
	end

	local function hookFolder(instance)
		local reputation = instance:FindFirstChild("Reputation")

		if reputation == nil then
			v:Connect(instance.ChildAdded, function(intValue)
				if intValue.Name == "Reputation" then
					follow(intValue) -- equivalent call inferred; original call site unknown
				end
			end)
			return
		end

		follow(reputation) -- equivalent call inferred; original call site unknown
	end

	local leaderstats = playerFromCharacter:FindFirstChild("leaderstats")

	if leaderstats == nil then
		v:Connect(playerFromCharacter.ChildAdded, function(instance)
			if instance.Name == "leaderstats" then
				local reputation = instance:FindFirstChild("Reputation")

				if reputation == nil then
					v:Connect(instance.ChildAdded, function(intValue)
						if intValue.Name == "Reputation" then
							follow(intValue) -- equivalent call inferred; original call site unknown
						end
					end)
				else
					follow(reputation) -- equivalent call inferred; original call site unknown
				end
			end
		end)
	else
		local reputation = leaderstats:FindFirstChild("Reputation")

		if reputation == nil then
			v:Connect(leaderstats.ChildAdded, function(intValue)
				if intValue.Name == "Reputation" then
					follow(intValue) -- equivalent call inferred; original call site unknown
				end
			end)
		elseif reputation:IsA("IntValue") then
			-- equivalent calls inferred from this helper; original call sites unknown
			local function read()
				text:Set((tostring(reputation.Value)))
			end

			read() -- equivalent call inferred; original call site unknown
			v:Connect(reputation.Changed, read)
		end
	end

	v:Create("Frame")({
		Name = "IReputation",
		Parent = parent,
		Size = UDim2.fromScale(1, 0.25),
		BackgroundTransparency = 1,
		Visible = v:Do(function(callback)
			return callback(value) == true and callback(text) ~= ""
		end),
		v:Create("UIListLayout")({
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			FillDirection = Enum.FillDirection.Horizontal,
			SortOrder = Enum.SortOrder.Name,
			Padding = UDim.new(0.02, 0)
		}),
		v:Create("ImageLabel")({
			Name = "AIcon",
			Size = UDim2.fromScale(0, 1),
			BackgroundTransparency = 1,
			Image = BunchaIcons.Reputation,
			v:Create("UIAspectRatioConstraint")({
				AspectRatio = 1,
				AspectType = Enum.AspectType.ScaleWithParentSize,
				DominantAxis = Enum.DominantAxis.Height
			})
		}),
		v:Create("TextLabel")({
			Name = "Value",
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			Text = text,
			TextColor3 = Color3.new(1, 1, 1),
			TextScaled = true,
			FontFace = Font.fromEnum(Enum.Font.SourceSansSemibold),
			v:Create("UIStroke")({
				Thickness = 1.5,
				Transparency = 0.75
			}),
			After = function(instance)
				-- equivalent calls inferred from this helper; original call sites unknown
				local function fit()
					if instance.Text == "" then
						return
					end

					instance.Size = UDim2.fromScale(interfaceutility.GetScaledTextSize(instance), 1)
				end

				fit() -- equivalent call inferred; original call site unknown
				v:Connect(instance:GetPropertyChangedSignal("Text"), fit)
			end
		})
	})
	return function()
		v:Destroy()
	end
end