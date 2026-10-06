local module = require("@game/ReplicatedStorage/Omni")
local userInputService = module.Services.UserInputService
local color = Color3.new(1, 1, 1)
local fusion = module.Libs.Fusion
local dialog = module.Interface:WaitForChild("Frames"):WaitForChild("Dialog")
local content = dialog:WaitForChild("Content")
local scroll = content:WaitForChild("Options"):WaitForChild("Scroll")
local dialog2 = module.Assets:WaitForChild("Interface"):WaitForChild("Templates"):WaitForChild("Dialog")
local innerScopes = {}
local v = nil
local v2 = nil
local v3 = nil
local currentIndex = nil
local thread = nil
local v4 = module.Utils.Text.Create(content.Desc, {
	CharacterSpacing = 1.5
})
local Dialog = {}
local scope = fusion.scoped(fusion, {
	Build = function(self, duration: number)
		self.Position = self:Value(UDim2.fromScale(-0.5, 0.5))
		self.PositionSpring = self:Spring(self.Position, 10, 1)
		self.Instance = dialog2.Option:Clone()
		self.Instance.Name = self.Text
		self.Instance.Main.Title.Text = self.Text
		self.Instance.Main.UIGradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, self.LightenedColor),
			ColorSequenceKeypoint.new(1, self.Color)
		})
		self.Instance.Main.Title.UIGradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, self.LightenedColor),
			ColorSequenceKeypoint.new(1, color)
		})
		module.Button:Create(self.Instance.Main, "Small"):BindFunction("Click", function()
			if self.Callback() == "Stop" then
				Dialog.Stop()
			end
		end)
		self.Instance.Parent = scroll
		self.Instance.Visible = true
		self:Hydrate(self.Instance.Main)({
			Position = self.PositionSpring
		})

		if duration and duration > 0 then
			task.delay(duration, function()
				if not next(self) then
					return
				end

				self.Position:set(UDim2.fromScale(0.5, 0.5))
			end)
		else
			self.Position:set(UDim2.fromScale(0.5, 0.5))
		end

		return true
	end
})

-- equivalent calls inferred from this helper; original call sites unknown
local function GetCurrentStep()
	if v then
		return v.Conversation[v.CurrentIndex]
	end
end

local function ClearOptions(flag: boolean?)
	for _, v5 in innerScopes do
		v5.Position:set(UDim2.fromScale(-0.5, 0.5))

		if flag then
			v5.Instance:Destroy()
			v5:doCleanup()
		else
			local v6 = v5
			task.delay(0.5, function()
				v6.Instance:Destroy()
				v6:doCleanup()
			end)
		end
	end

	table.clear(innerScopes)
end

local function GenerateOptions()
	if not v then
		return
	end

	local currentStep = GetCurrentStep() -- equivalent call inferred; original call site unknown

	if not currentStep then
		return
	end

	for k, option in currentStep.Options do
		local innerScope = scope:innerScope()
		innerScope.Text = option.Text
		innerScope.Color = option.Color
		innerScope.LightenedColor = module.Utils.Colors:Lighten(option.Color, 0.5)
		innerScope.Callback = option.Callback

		if innerScope:Build(k * 0.05) then
			table.insert(innerScopes, innerScope)
		else
			innerScope:doCleanup()
		end
	end

	scroll.Parent.UIGradient.Enabled = #currentStep.Options >= 4
end

-- equivalent calls inferred from this helper; original call sites unknown
local function GenerateNextStep()
	if not v then
		return
	end

	ClearOptions()
	v.CurrentIndex += 1
	local currentStep = GetCurrentStep() -- equivalent call inferred; original call site unknown

	if currentStep then
		v4:SetText(currentStep.Text, currentStep.Animations, true)
	else
		Dialog.Stop()
	end
end

function Dialog.Start(p: string)
	if v then
		return
	end

	local npc = module.Npcs[p]

	if not npc or typeof(npc.Dialog) ~= "function" then
		return
	end

	local dialog3 = npc.Dialog(module.Instance, module.Data)

	if typeof(dialog3) ~= "table" then
		return
	end

	for _, v5 in dialog3 do
		if not v5.Options then
			v5.Options = {}
		end

		if not v5.Animations then
			v5.Animations = {}
		end
	end

	ClearOptions(true)

	if thread then
		task.cancel(thread)
		thread = nil
	end

	content.Title.Text = npc.CustomName or p
	module.Utils.Camera.ViewportCharacter({
		Viewport = dialog.PlayerViewport,
		CustomCFrame = CFrame.new(0, -1.25, -4) * CFrame.Angles(0, -2.792526803190927, 0),
		Animation = module.Utils.Characters.GetCharacterAnimation(p, "Idle"),
		Character = module.Utils.Characters.Get({
			Name = p,
			Shiny = false,
			RemoveHumanoidStates = true
		})
	})
	v = {
		NpcName = p,
		CurrentIndex = 0,
		Conversation = dialog3
	}
	local analytics = module.Scripts.General.Analytics

	if analytics then
		analytics.TrackDialog(p)
	end

	Dialog.Update()
end

function Dialog.Stop()
	v = nil
	Dialog.Update()
end

function Dialog.Update()
	if v or not module.Frame:IsFrameOpened(dialog) then
		if v and not module.Frame:IsFrameOpened(dialog) then
			module.Frame:Open(dialog)
		end
	else
		module.Frame:Close(dialog)
	end

	if v and (v.CurrentIndex == 0 or v.StepEnded == true) then
		GenerateNextStep() -- equivalent call inferred; original call site unknown
	end
end

function Dialog.Next()
	Dialog.Update()
end

function Dialog.Back()
	Dialog.Update()
end

v4:SetAppearing("FadeUp", {
	Time = 0.05
})
v4:OnAppear(function()
	if not (v and module.Frame:IsFrameOpened(dialog)) then
		return
	end

	local v5 = v
	local currentIndex2 = v5.CurrentIndex

	if v5.CompletedIndex == currentIndex2 then
		return
	end

	local currentStep = GetCurrentStep() -- equivalent call inferred; original call site unknown

	if not currentStep then
		return
	end

	v5.CompletedIndex = currentIndex2

	if #currentStep.Options == 0 then
		task.delay(currentStep.Cooldown or 1, function()
			if v ~= v5 or v5.CurrentIndex ~= currentIndex2 or not module.Frame:IsFrameOpened(dialog) then
				return
			end

			GenerateNextStep() -- equivalent call inferred; original call site unknown
		end)
	else
		GenerateOptions()
	end
end)
userInputService.InputBegan:Connect(function(input)
	if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch or (not v or v2) or not module.Frame:IsFrameOpened(dialog) then
		return
	end

	if content.Desc:GetAttribute("Appeared") == true then
		return
	end

	v2 = input
	v3 = v
	currentIndex = v.CurrentIndex
end)
userInputService.InputEnded:Connect(function(input)
	if input ~= v2 then
		return
	end

	local v5 = v3
	local v6 = currentIndex
	v2 = nil
	v3 = nil
	currentIndex = nil
	task.defer(function()
		if not v5 or v ~= v5 or v5.CurrentIndex ~= v6 or not module.Frame:IsFrameOpened(dialog) then
			return
		end

		v4:SkipAppearing()
	end)
end)
module.Frame:OnFrameClosed(dialog, function()
	v = nil
	v2 = nil
	v3 = nil
	currentIndex = nil
	ClearOptions()

	if thread then
		task.cancel(thread)
	end

	thread = task.delay(0.25, function()
		thread = nil
		module.Utils.Camera.ClearViewport(dialog.PlayerViewport)
	end)
end)
return Dialog