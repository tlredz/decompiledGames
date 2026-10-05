local ReplicatedStorage = game:GetService("ReplicatedStorage")
local surveyRemote = ReplicatedStorage:WaitForChild("JWE_Events"):WaitForChild("SurveyRemote")
local SurveyValues = require(ReplicatedStorage.shared.Jurassic.SurveyValues)
local menu = script.Parent:WaitForChild("Menu")
local content = menu:WaitForChild("Content")
local question = content:WaitForChild("Question")
local input = content:WaitForChild("Input")
local options = content:WaitForChild("Options")
local boxOptions = content:WaitForChild("BoxOptions")
local color = Color3.fromRGB(165, 218, 85)
local color2 = Color3.fromRGB(210, 177, 89)
local color3 = Color3.fromRGB(210, 177, 89)
local color4 = Color3.fromRGB(115, 201, 255)
local clone = options:WaitForChild("SurveyTemplate"):Clone()
local clone2 = clone:WaitForChild("GameTemplate"):Clone()
local clone3 = clone:WaitForChild("CircleTemplate"):Clone()
local clone4 = options:WaitForChild("MultipleChoiceTemplate"):Clone()
local clone5 = boxOptions:WaitForChild("QuestionTemplate"):Clone()
local clone6 = boxOptions:WaitForChild("BlankTemplate"):Clone()
options:WaitForChild("SurveyTemplate"):Destroy()
options:WaitForChild("MultipleChoiceTemplate"):Destroy()
boxOptions:WaitForChild("QuestionTemplate"):Destroy()
boxOptions:WaitForChild("BlankTemplate"):Destroy()

local function clearContainer(instance)
	for _, guiObject in ipairs(instance:GetChildren()) do
		if guiObject:IsA("GuiObject") then
			guiObject:Destroy()
		end
	end
end

local v = {}
local count = 0

local function checkGridComplete(p)
	local v2 = SurveyValues.List[p]

	if not v2 or v2.Type ~= "Grid" then
		return false
	end

	for _, row in ipairs(v2.Rows) do
		if not (row:find("None of the above") or v[p][row]) then
			return false
		end
	end

	return true
end

local function CreateQuestion(p)
	local v2 = SurveyValues.List[p]
	question.Text = not v2 and "Would you like to take a survey?" or v2.Question or "Would you like to take a survey?"
	clearContainer(boxOptions)
	clearContainer(options)
	clearContainer(clone)
	boxOptions.Visible = false
	options.Visible = false
	input.Visible = false

	if p == 0 then
		options.Visible = true
		v[0] = {}

		for i, text in ipairs({ "Yes", "No" }) do
			local clone7 = clone4:Clone()
			clone7.Title.Text = text
			clone7.LayoutOrder = i
			clone7.BackgroundColor3 = color4
			clone7.Parent = options
			local v4 = text
			clone7.Activated:Connect(function()
				v[0][1] = v4

				for i2, button in ipairs(options:GetChildren()) do
					if button:IsA("ImageButton") then
						button.BackgroundColor3 = button == clone7 and color3 or color4
					end
				end

				input.Visible = true
			end)
		end

		input.Title.Text = "Next"
	elseif v2 and v2.Type == "Grid" then
		boxOptions.Visible = true
		options.Visible = true
		v[p] = {}
		local layoutOrder = 1
		local clone7 = clone6:Clone()
		clone7.LayoutOrder = layoutOrder
		clone7.Parent = boxOptions
		local layoutOrder2 = layoutOrder + 1

		for _, column in ipairs(v2.Columns) do
			local clone8 = clone5:Clone()
			clone8.Title.Text = column
			clone8.LayoutOrder = layoutOrder2
			clone8.Parent = boxOptions
			layoutOrder2 += 1
		end

		local v5 = {}
		local v6 = {}

		for i, row in ipairs(v2.Rows) do
			if row:find("None of the above") then
				table.insert(v5, i)
			else
				table.insert(v6, i)
			end
		end

		for i = #v6, 2, -1 do
			local v7 = math.random(i)
			local v8 = v6[v7]
			local v9 = v6[i]
			v6[i] = v8
			v6[v7] = v9
		end

		local v7 = {}

		for _, v8 in ipairs(v6) do
			table.insert(v7, v8)
		end

		for _, v8 in ipairs(v5) do
			table.insert(v7, v8)
		end

		for i, v8 in ipairs(v7) do
			local row = v2.Rows[v8]
			local clone8 = clone:Clone()
			clone8.Name = "Row" .. i
			clone8.LayoutOrder = i
			clone8.Parent = options
			local clone9 = clone2:Clone()
			clone9.Title.Text = row
			clone9.LayoutOrder = 1
			clone9.Parent = clone8
			local clones = {}

			for i2 = 1, #v2.Columns do
				local clone10 = clone3:Clone()
				clone10.Name = tostring(i2)
				clone10.LayoutOrder = i2 + 1
				clone10.Circle.UIStroke.Color = color2
				clone10.Circle.Checkmark.Visible = false
				clone10.Parent = clone8
				clones[i2] = clone10
				local text = row
				local v10 = i2
				local v11 = clones
				clone10.InputBegan:Connect(function(input2)
					if input2.UserInputType == Enum.UserInputType.MouseButton1 then
						v[p][text] = v2.Columns[v10]

						for i3, v12 in ipairs(v11) do
							v12.Circle.UIStroke.Color = i3 == v10 and color or color2
							v12.Circle.Checkmark.Visible = i3 == v10
						end

						input.Visible = checkGridComplete(p)
					end
				end)
			end
		end

		input.Title.Text = p < #SurveyValues.List and "Next" or "Submit"
	else
		options.Visible = true
		v[p] = {}
		local v3 = {}
		local v4 = {}
		local v5 = {}

		for i, txt in ipairs(v2 and v2.Answers or {}) do
			if txt:find("None of the above") then
				table.insert(v3, {
					txt = txt,
					idx = i
				})
			else
				table.insert(v4, {
					txt = txt,
					idx = i
				})
			end
		end

		for i = #v4, 2, -1 do
			local v6 = math.random(i)
			local v7 = v4[v6]
			local v8 = v4[i]
			v4[i] = v7
			v4[v6] = v8
		end

		for _, v6 in ipairs(v4) do
			table.insert(v5, v6)
		end

		for _, v6 in ipairs(v3) do
			table.insert(v5, v6)
		end

		for i, v6 in ipairs(v5) do
			local clone7 = clone4:Clone()
			clone7.Title.Text = v6.txt
			clone7.LayoutOrder = i
			clone7.BackgroundColor3 = color4
			clone7.Parent = options
			local v7 = v6
			clone7.Activated:Connect(function()
				v[p] = { v7.txt }

				for i2, button in ipairs(options:GetChildren()) do
					if button:IsA("ImageButton") then
						button.BackgroundColor3 = button == clone7 and color3 or color4
					end
				end

				input.Visible = true
			end)
		end

		input.Title.Text = p < #SurveyValues.List and "Next" or "Submit"
	end
end

input.Activated:Connect(function()
	input.Visible = false

	if count == 0 then
		if v[0][1] == "No" then
			menu.Visible = false
			count = 0
			CreateQuestion(0)
		else
			count += 1
			CreateQuestion(count)
		end
	else
		count += 1

		if count > #SurveyValues.List then
			menu.Visible = false
			surveyRemote:FireServer(v)
		else
			CreateQuestion(count)
			task.wait(0.5)
			local v2 = SurveyValues.List[count]

			if count == 0 then
				input.Visible = v[0][1] ~= nil
				return
			end

			if v2 and v2.Type == "Grid" then
				input.Visible = checkGridComplete(count)
				return
			end

			local v3 = v[count]
			input.Visible = v3 and #v3 > 0
		end
	end
end)
CreateQuestion(0)