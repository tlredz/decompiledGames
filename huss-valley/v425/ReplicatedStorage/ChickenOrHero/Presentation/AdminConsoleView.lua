local ValleyPanels = require(script.Parent.ValleyPanels)
local ValleyTheme = require(script.Parent.ValleyTheme)
local AdminConsoleView = {}

function AdminConsoleView.apply(data)
	local console = data.Console
	console:SetAttribute("UIProportionalGroup", nil)

	for _, descendant in console:GetDescendants() do
		if descendant:IsA("UIAspectRatioConstraint") or descendant:IsA("UISizeConstraint") or descendant:IsA("UITextSizeConstraint") or descendant:IsA("UIScale") then
			descendant:Destroy()
		end

		if not (descendant:IsA("TextLabel") or descendant:IsA("TextButton") or descendant:IsA("TextBox")) then
			continue
		end

		descendant.TextScaled = false
		descendant.TextColor3 = ValleyTheme.Paper
	end

	console.Size = UDim2.fromOffset(800, 510)
	console.AnchorPoint = Vector2.new(0.5, 0.5)
	console.Position = UDim2.fromScale(0.5, 0.5)
	ValleyTheme.surface(console, ValleyTheme.Ink, ValleyTheme.Gold, 8, 0.45)
	console.BackgroundTransparency = 0.03
	ValleyPanels.make("UIScale", console, "Scale", {});
	(console:FindFirstChild("Eyebrow") or ValleyPanels.text(
		console,
		"Eyebrow",
		"HUSS VALLEY  /  STAFF TOOLS",
		22,
		17,
		600,
		18,
		11,
		ValleyTheme.Gold
	)).TextColor3 = ValleyTheme.Gold
	console.Title.Position = UDim2.fromOffset(22, 42)
	console.Title.Size = UDim2.new(1, -96, 0, 34)
	console.Title.TextSize = 21
	console.Title.TextXAlignment = Enum.TextXAlignment.Left
	console.Title.Font = Enum.Font.GothamBold
	console.Close.AnchorPoint = Vector2.zero
	console.Close.Size = UDim2.fromOffset(44, 44)
	console.Close.Position = UDim2.new(1, -66, 0, 20)
	ValleyTheme.button(console.Close, ValleyTheme.Gold)
	console.Close.TextSize = 25
	console.Close.Modal = true
	console.Scroll.Position = UDim2.fromOffset(22, 93)
	console.Scroll.Size = UDim2.new(1, -44, 1, -183)
	console.Scroll.BackgroundColor3 = ValleyTheme.Ink:Lerp(ValleyTheme.Paper, 0.025)
	console.Scroll.BackgroundTransparency = 0
	console.Scroll.BorderSizePixel = 0
	console.Scroll.ScrollBarThickness = 4
	console.Scroll.ScrollBarImageColor3 = ValleyTheme.Gold
	console.Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	console.Scroll.ClipsDescendants = true
	console.Scroll.Active = true
	console.Scroll.Output.Font = Enum.Font.Code
	console.Scroll.Output.TextSize = 14
	console.Scroll.Output.TextColor3 = ValleyTheme.Paper
	console.Scroll.Output.TextWrapped = true
	console.Scroll.Output.AutomaticSize = Enum.AutomaticSize.Y
	console.Command.AnchorPoint = Vector2.zero
	console.Command.Position = UDim2.new(0, 22, 1, -66)
	console.Command.Size = UDim2.new(1, -134, 0, 44)
	ValleyTheme.surface(console.Command, ValleyTheme.Ink:Lerp(ValleyTheme.Gold, 0.1), ValleyTheme.Gold, 5, 0.7)
	console.Command.Font = Enum.Font.Code
	console.Command.TextSize = 16
	console.Command.ClearTextOnFocus = false
	console.Command.PlaceholderText = ";help"
	console.Command.PlaceholderColor3 = ValleyTheme.Muted
	console.Send.AnchorPoint = Vector2.zero
	console.Send.Position = UDim2.new(1, -100, 1, -66)
	console.Send.Size = UDim2.fromOffset(78, 44)
	ValleyTheme.button(console.Send, ValleyTheme.Gold)
	console.Send.TextSize = 14
	local footer = console:FindFirstChild("Footer") or ValleyPanels.text(
		console,
		"Footer",
		"TAB completes · ↑ ↓ suggestions · ALT + ↑ ↓ history",
		22,
		0,
		700,
		16,
		10,
		ValleyTheme.Muted
	)
	footer.Position = UDim2.new(0, 22, 1, -18)
	footer.Size = UDim2.new(1, -44, 0, 16)
	local openConsole = data.OpenConsole
	openConsole:SetAttribute("UIProportionalGroup", nil)

	for _, child in openConsole:GetChildren() do
		if not (child:IsA("UIScale") or child:IsA("UIAspectRatioConstraint") or child:IsA("UISizeConstraint")) then
			continue
		end

		child:Destroy()
	end

	openConsole.Size = UDim2.fromOffset(44, 38)
	openConsole.AnchorPoint = Vector2.new(1, 0)
	openConsole.Position = UDim2.new(1, -14, 0, 86)
	openConsole.TextScaled = false
	openConsole.TextSize = 23
	ValleyTheme.button(openConsole, ValleyTheme.Gold)
	local notice = data.Notice
	notice.RichText = false
	notice:SetAttribute("UIProportionalGroup", nil)

	for _, child in notice:GetChildren() do
		if not (child:IsA("UIScale") or child:IsA("UIAspectRatioConstraint") or child:IsA("UISizeConstraint")) then
			continue
		end

		child:Destroy()
	end

	notice.BackgroundTransparency = 1
	notice.TextColor3 = ValleyTheme.Paper
	notice.TextStrokeColor3 = ValleyTheme.Ink
	notice.TextStrokeTransparency = 0.2
	notice.Font = Enum.Font.GothamBold
	notice.AnchorPoint = Vector2.new(0.5, 0)
	notice.Position = UDim2.fromScale(0.5, 0.18)
	notice.Size = UDim2.fromScale(0.75, 0.13)
	notice.TextScaled = true
	notice.TextWrapped = true
	local uITextSizeConstraint = notice:FindFirstChildOfClass("UITextSizeConstraint") or Instance.new("UITextSizeConstraint")
	uITextSizeConstraint.MinTextSize = 12
	uITextSizeConstraint.MaxTextSize = 23
	uITextSizeConstraint.Parent = notice
end

function AdminConsoleView.layout(p)
	local absoluteSize = p.AbsoluteSize
	local console = p.Console
	local v

	if absoluteSize.X > absoluteSize.Y then
		v = absoluteSize.Y < 500
	else
		v = false
	end

	console.Size = UDim2.fromOffset(absoluteSize.X < absoluteSize.Y and 460 or 800, v and 350 or 510)
	console.Scale.Scale = math.min(
		1.1,
		absoluteSize.X * 0.94 / console.Size.X.Offset,
		absoluteSize.Y * 0.91 / console.Size.Y.Offset
	)
	console.Title.TextSize = absoluteSize.X < absoluteSize.Y and 15 or 21
	local suggestions = console:FindFirstChild("Suggestions")

	if suggestions then
		suggestions.Position = UDim2.new(0, 22, 1, -74)
		suggestions.Size = UDim2.new(1, -44, 0, v and 156 or 204)
		ValleyTheme.surface(suggestions, ValleyTheme.Ink, ValleyTheme.Gold, 5, 0.45)
	end
end

return AdminConsoleView