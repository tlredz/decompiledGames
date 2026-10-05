local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local Players = game:GetService("Players")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage2.ClientGameModules.DeviceListener)
local v2 = require3(ReplicatedStorage2.Shared.CustomModeInfo)
local v3 = require3(ReplicatedStorage2.Shared.CustomModeUtil)
local v4 = require3(ReplicatedStorage2.Packages.Trove)
local remoteEvent = require3(ReplicatedStorage2.Packages.Net):RemoteEvent("UpdateTrainingConfiguration")
local customModeUI = Players.LocalPlayer.PlayerGui:WaitForChild("CustomModeUI")
local frame = customModeUI.Frame
local v5 = nil
local maid = v4.new()

local function promptDropdown(instance, items, fn)
	if v5 == instance then
		maid:Clean()
		return
	end

	maid:Clean()
	v5 = instance
	instance.List.Visible = true

	for k, item in items do
		local clone = instance.List.UIListLayout.Option:Clone()
		clone.Label.Text = item
		clone.LayoutOrder = k
		clone.Parent = instance.List
		maid:Add(clone)
		local v6 = item
		maid:Add(clone.Activated:Once(function()
			maid:Clean()
			fn(v6)
		end))
	end

	maid:Add(function()
		if instance and instance.Parent and instance:FindFirstChild("List") then
			instance.List.Visible = false
		end

		v5 = nil
	end)
end

local states = {}
local v6 = v4.new()
local name = "Classic"
local CustomModeRulesController = {}

function CustomModeRulesController:AddRule(state)
	local maid2 = v4.new()
	v6:Add(maid2)
	local v7 = v4.new()
	maid2:Add(v7)
	local v8 = maid2:Add(frame.Conditions.UIListLayout.Rule:Clone())
	local list = v8.List
	local title = list.Title
	title.Title.Text = state.Name
	maid2:Add(title.Title:GetPropertyChangedSignal("Text"):Connect(function()
		state.Name = title
	end))
	local v9 = {}

	for k in v2.Events do
		table.insert(v9, k)
	end

	table.sort(v9)
	maid2:Add(title.Event.Activated:Connect(function()
		promptDropdown(title.Event, v9, function(p)
			v7:Clean()
			state.Event = p
			title.Event.Label.Text = p
		end)
	end))
	title.Enabled.Check.Visible = state.Enabled
	maid2:Add(title.Enabled.Activated:Connect(function()
		local v10 = not state.Enabled
		state.Enabled = v10
		title.Enabled.Check.Visible = v10
	end))
	maid2:Add(title.RemoveRule.Activated:Once(function()
		v8:Destroy()
	end))
	maid2:Add(function()
		local index = table.find(states, state)

		if index then
			table.remove(states, index)
		end
	end)
	local conditions = list.Conditions
	maid2:Add(conditions.Title.Plus.Activated:Connect(function()
		local v10 = {
			Variable = "Ball Speed",
			Type = "Equals",
			Value = 0
		}
		local maid3 = v4.new()
		v7:Add(maid3)
		local v11 = maid3:Add(list.UIListLayout.Frame:Clone())
		maid3:Add(function()
			local index = table.find(state.Conditions, v10)

			if index then
				table.remove(state.Conditions, index)
			end
		end)
		maid3:Add(v11.Input3:GetPropertyChangedSignal("Text"):Connect(function()
			v11.Input3.Text = string.gsub(v11.Input3.Text, "%D+", "")
			v10.Value = tonumber(v11.Input3.Text) or 0
		end))
		maid3:Add(v11.DropDown1.Activated:Connect(function()
			local possibleConditionVariables = v3.getPossibleConditionVariables(v2.Events[state.Event])
			local v12 = {}

			for k in possibleConditionVariables do
				table.insert(v12, k)
			end

			table.sort(v12)
			promptDropdown(v11.DropDown1, v12, function(variable)
				v10.Variable = variable
				local possibleConditionVariable = possibleConditionVariables[variable]
				local valueType = v2.ValueTypes[possibleConditionVariable]
				local v13, v14 = next(valueType.Conditions)

				if v13 and v14 ~= nil then
					v10.Type = v13
					local v15 = v10
					local v16

					if type(v14) == "table" then
						v16 = v14[1]
					elseif possibleConditionVariable == "Number" then
						v16 = 0
					elseif possibleConditionVariable == "Team" then
						v16 = v3.getTeams(name)[1]
					end

					v15.Value = v16
					v11.DropDown1.Label.Text = v10.Variable
					v11.DropDown2.Label.Text = v10.Type
					v11.DropDown2.Visible = true

					if possibleConditionVariable == "Number" then
						v11.Input3.Text = v10.Value
						v11.DropDown3.Visible = false
						v11.Input3.Visible = true
					else
						v11.DropDown3.Label.Text = v10.Value
						v11.DropDown3.Visible = true
						v11.Input3.Visible = false
					end
				end
			end)
		end))
		maid3:Add(v11.DropDown2.Activated:Connect(function()
			local v12 = v3.getPossibleConditionVariables(v2.Events[state.Event])[v10.Variable]
			local valueType = v2.ValueTypes[v12]
			local v13 = {}

			for k in valueType.Conditions do
				table.insert(v13, k)
			end

			table.sort(v13)
			promptDropdown(v11.DropDown2, v13, function(p)
				local condition = valueType.Conditions[p]
				v10.Type = p
				local v14 = v10
				local v15

				if type(condition) == "table" then
					v15 = condition[1]
				elseif v12 == "Number" then
					v15 = 0
				elseif v12 == "Team" then
					v15 = v3.getTeams(name)[1]
				end

				v14.Value = v15
				v11.DropDown2.Label.Text = v10.Type

				if v12 == "Number" then
					v11.Input3.Text = v10.Value
					v11.DropDown3.Visible = false
					v11.Input3.Visible = true
				else
					v11.DropDown3.Label.Text = v10.Value
					v11.DropDown3.Visible = true
					v11.Input3.Visible = false
				end
			end)
		end))
		maid3:Add(v11.DropDown3.Activated:Connect(function()
			local v12 = v3.getPossibleConditionVariables(v2.Events[state.Event])[v10.Variable]
			local condition = v2.ValueTypes[v12].Conditions[v10.Type]
			local v13 = type(condition) ~= "table" and {} or condition
			table.sort(v13)
			promptDropdown(v11.DropDown3, v13, function(p)
				v10.Value = p
				v11.DropDown3.Label.Text = v10.Value
			end)
		end))
		v11.Parent = conditions
		table.insert(state.Conditions, v10)
	end))
	local results = list.Results
	maid2:Add(results.Title.Plus.Activated:Connect(function()
		local v10 = {
			Variable = "Ball Speed",
			Type = "Equals",
			Value = 0
		}
		local maid3 = v4.new()
		v7:Add(maid3)
		local v11 = maid3:Add(list.UIListLayout.Frame:Clone())
		maid3:Add(function()
			local index = table.find(state.Results, v10)

			if index then
				table.remove(state.Results, index)
			end
		end)
		maid3:Add(v11.Input3:GetPropertyChangedSignal("Text"):Connect(function()
			v11.Input3.Text = string.gsub(v11.Input3.Text, "%D+", "")
			v10.Value = tonumber(v11.Input3.Text) or 0
		end))
		maid3:Add(v11.DropDown1.Activated:Connect(function()
			local possibleResultVariables = v3.getPossibleResultVariables(v2.Events[state.Event])
			local v12 = {}

			for k in possibleResultVariables do
				table.insert(v12, k)
			end

			table.sort(v12)
			promptDropdown(v11.DropDown1, v12, function(variable)
				v10.Variable = variable
				v11.DropDown1.Label.Text = v10.Variable
				v11.DropDown1.Visible = true
				local possibleResultVariable = possibleResultVariables[variable]
				local valueType = v2.ValueTypes[possibleResultVariable]
				local text, v14 = next(valueType.Results)
				v11.DropDown2.Label.Text = text
				v11.DropDown2.Visible = true

				if text and v14 ~= nil then
					v10.Type = text

					if v14 then
						local v15 = v10
						local v16

						if possibleResultVariable == "Number" then
							v16 = 0
						elseif possibleResultVariable == "Team" then
							v16 = v3.getTeams(name)[1]
						end

						v15.Value = v16

						if possibleResultVariable == "Number" then
							v11.Input3.Text = v10.Value
							v11.Input3.Visible = true
						else
							v11.DropDown3.Label.Text = v10.Value
							v11.DropDown3.Visible = true
						end
					else
						v10.Value = nil
						v11.DropDown3.Visible = false
						v11.Input3.Visible = false
					end
				end
			end)
		end))
		maid3:Add(v11.DropDown2.Activated:Connect(function()
			local possibleResultVariables = v3.getPossibleResultVariables(v2.Events[state.Event])
			local possibleResultVariable = possibleResultVariables[v10.Variable]
			local v12 = {}

			for k in v2.ValueTypes[possibleResultVariable].Results do
				table.insert(v12, k)
			end

			table.sort(v12)
			promptDropdown(v11.DropDown2, v12, function(text)
				local possibleResultVariable2 = possibleResultVariables[v10.Variable]
				local valueType = v2.ValueTypes[possibleResultVariable2]
				v11.DropDown2.Label.Text = text
				v11.DropDown2.Visible = true
				v10.Type = text

				if valueType then
					local v13 = v10
					local v14

					if possibleResultVariable2 == "Number" then
						v14 = 0
					elseif possibleResultVariable2 == "Team" then
						v14 = v3.getTeams(name)[1]
					end

					v13.Value = v14

					if possibleResultVariable2 == "Number" then
						v11.Input3.Text = v10.Value
						v11.Input3.Visible = true
					else
						v11.DropDown3.Label.Text = v10.Value
						v11.DropDown3.Visible = true
					end
				else
					v10.Value = nil
					v11.DropDown3.Visible = false
					v11.Input3.Visible = false
				end
			end)
		end))
		maid3:Add(v11.DropDown3.Activated:Connect(function()
			local v12 = v3.getPossibleResultVariables(v2.Events[state.Event])[v10.Variable]
			local _ = v2.ValueTypes[v12].Results[v10.Type]
			local v13

			if v12 == "Teams" then
				v13 = v3.getTeams(name)
			end

			table.sort(v13)
			promptDropdown(v11.DropDown3, v13, function(p)
				v10.Value = p
				v11.DropDown3.Label.Text = v10.Value
				v11.DropDown3.Visible = true
			end)
		end))
		v11.Parent = results
		table.insert(state.Results, v10)
	end))
	v8.Parent = frame.Conditions
	v8.Destroying:Once(function()
		maid2:Destroy()
	end)
	table.insert(states, state)
end

function CustomModeRulesController.CleanRules(_)
	v6:Clean()
end

function CustomModeRulesController:Start()
	frame.Close.Activated:Connect(function()
		customModeUI.Enabled = false
		remoteEvent:FireServer({
			ServerRules = states
		})
	end)

	for _, button in frame.Base:GetChildren() do
		if not button:IsA("GuiButton") then
			continue
		end

		local v7 = button
		button.Activated:Connect(function()
			v6:Clean()
			name = v7.Name

			for i, button2 in frame.Base:GetChildren() do
				if button2:IsA("ImageButton") then
					button2.ImageTransparency = button2.Name == v7.Name and 0 or 0.5
				end
			end
		end)
	end

	frame.ClearRules.Activated:Connect(function()
		v6:Clean()
	end)
	frame.NewRule.Activated:Connect(function()
		self:AddRule({
			Name = `Rule {#states + 1}`,
			Enabled = true,
			Event = "Parried",
			Conditions = {},
			Results = {}
		})
	end)

	local function reflectLatestInputMode()
		local isMobile = v:IsMobile()
		frame.Size = isMobile and UDim2.fromScale(0.9, 0.9) or UDim2.fromScale(0.8, 0.8)
		frame.UIAspectRatioConstraint.AspectRatio = isMobile and 1.6 or 1
	end

	v:Observe(reflectLatestInputMode)
end

return CustomModeRulesController