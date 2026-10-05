local ReplicatedStorage = game:GetService("ReplicatedStorage")
local faye = require(ReplicatedStorage.Packages.faye)
local StatTypes = require(ReplicatedStorage.CAM.Global.Types.StatTypes)
local StatRow = require(ReplicatedStorage.CAM.Client.Components.Layout.ResetOnSpawn.HUD.HudBottomLeft.StatRow)
local color = Color3.new(1, 0.9, 0.9)
return function(parent, instance)
	local v = faye.new()
	local value = v:Value({})
	local v2 = {}
	local v3 = 0
	local v4 = nil

	local function show()
		if v4 ~= nil then
			return
		end

		v4 = faye.new()
		v4:Create("Frame")({
			Name = "HDebuffs",
			Parent = parent,
			Size = UDim2.fromScale(1, 0.4),
			BackgroundTransparency = 1,
			v4:Create("UIListLayout")({
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				Padding = UDim.new(0, 2)
			}),
			v4:AdvancedIterate(value, function(p2, p3, p4)
				return StatRow(p4, p2, p3)
			end)
		})
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function hide()
		if v4 ~= nil then
			v4:Destroy()
			v4 = nil
		end
	end

	local function setOn(p2: string, flag: boolean)
		local v5 = v2[p2]

		if flag then
			if v5 ~= nil then
				return
			end

			local v6 = {
				Value = v:Value(true),
				Text = v:Value(""),
				Dim = v:Value(0),
				Tint = v:Value(color)
			}
			v2[p2] = v6
			v3 += 1

			if v3 == 1 then
				show()
			end

			value:Add(p2, v6)
		elseif v5 ~= nil then
			v2[p2] = nil
			value:Remove(p2)
			v5.Value:Destroy()
			v5.Text:Destroy()
			v5.Dim:Destroy()
			v5.Tint:Destroy()
			v3 -= 1

			if v3 <= 0 and v4 ~= nil then
				v4:Destroy()
				v4 = nil
			end
		end
	end

	local flag = false

	local function bindHolder(instance2)
		if flag then
			return
		end

		flag = true

		for k, v5 in instance2:GetAttributes() do
			if StatTypes.IsMetaAttribute(k) or v5 ~= true then
				continue
			end

			setOn(StatTypes.AttributeToStat(k), true)
		end

		v:Connect(instance2.AttributeChanged, function(attributeName: string)
			if StatTypes.IsMetaAttribute(attributeName) then
				return
			end

			setOn(StatTypes.AttributeToStat(attributeName), instance2:GetAttribute(attributeName) == true)
		end)
	end

	local debuffs = instance:FindFirstChild("Debuffs")

	if debuffs == nil then
		v:Connect(instance.ChildAdded, function(p2)
			if p2.Name == "Debuffs" then
				bindHolder(p2)
			end
		end)
	else
		bindHolder(debuffs)
	end

	return function()
		hide() -- equivalent call inferred; original call site unknown
		v:Destroy()
	end
end