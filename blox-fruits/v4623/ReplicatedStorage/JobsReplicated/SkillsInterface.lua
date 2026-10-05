require(script.Parent.Types)
local Controls = require(script.Parent.Controls)
local GamepadConversion = require(game.ReplicatedStorage:WaitForChild("GamepadConversion"))
local JobToolsInfo = require(script.Parent.JobToolsInfo)
local LastInput = require(game.ReplicatedStorage.Modules.LastInput)
local UserInputService = game:GetService("UserInputService")
game:GetService("ContextActionService")
local SkillsInterface = {
	ControlBindings = nil
}
local v = nil
local v2 = nil

function SkillsInterface.destroyJobToolSkills(_)
	if v then
		v:Destroy()
		v = nil
	end
end

local v3 = {
	Z = 1,
	X = 2,
	C = 3,
	V = 4
}
task.spawn(function()
	if not game.Players.LocalPlayer then
		return
	end

	local playerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui", 999)
	local JobProgressionInfo = require(game.ReplicatedStorage.JobsReplicated.JobProgressionInfo)
	local main = nil
	playerGui.ChildAdded:Connect(function(child)
		if child.Name == "Main" then
			main = child
		end
	end)
	main = playerGui:WaitForChild("Main", 999)
	local skills = main:WaitForChild("Skills", 999)
	local container = skills:WaitForChild("Container", 999)
	local template = container:WaitForChild("Template", 999)
	local RageBar = require(script.RageBar)
	local rageBar = RageBar(skills)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function reflectInputTypeForSkill(p)
		local visible = LastInput:Get() == "Gamepad"
		p.Key.Visible = not visible
		p.GamepadKey.Visible = visible
	end

	local function inputTypeChanged()
		for _, child in skills:GetChildren() do
			if not child:GetAttribute("SkillsContainer") then
				continue
			end

			for _, child2 in child:GetChildren() do
				if not child2:FindFirstChild("GamepadKey") then
					continue
				end

				reflectInputTypeForSkill(child2) -- equivalent call inferred; original call site unknown
			end
		end
	end

	task.defer(inputTypeChanged)
	LastInput.Changed:Connect(inputTypeChanged)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function tryConnectButton(_, clone, p)
		if UserInputService.TouchEnabled then
			SkillsInterface.ControlBindings[p.Key or "Z"]:AddBinding(clone.Mobile, Controls.ControlSchemes.Any)

			if (v2:GetAttribute("Level") or v2.Level.Value) >= p.Mastery then
				clone.Mobile.Visible = true
			end
		end
	end

	local TweenService = game:GetService("TweenService")

	function SkillsInterface.animateCooldown(childName, childName2, p)
		local child = skills:WaitForChild(childName, 0.1)

		if not child then
			return
		end

		local child2 = child:FindFirstChild(childName2)

		if child2 then
			local cooldown = child2.Cooldown
			cooldown.Size = UDim2.new(1, 0, 1, -1)
			TweenService:Create(
				cooldown,
				TweenInfo.new(p - tick(), Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
				{
					Size = UDim2.new(0, 0, 1, -1)
				}
			):Play()
		end
	end

	local function setupRageBar(instance)
		rageBar.DisableAll()
		rageBar.ResizeBars()
		local job = JobProgressionInfo.Jobs[instance:GetAttribute("JobId")]
		rageBar.SetColors(job.JobColor, job.JobColor)
		rageBar.SetText("Power")
		rageBar.ConnectUpdate(instance:GetAttributeChangedSignal("SkillChargeAlpha"), function()
			if instance.Parent == game.Players.LocalPlayer.Character then
				return instance:GetAttribute("SkillChargeAlpha") * 100
			end
		end, (instance:GetAttribute("SkillChargeAlpha") or 0) * 100)
		rageBar.SyncToSkillActivated(instance)
		rageBar.SetVisible(true)
	end

	local function makeSkillFrame(instance, p, clone)
		local clone2 = template:Clone()
		local color = Color3.new(1, 1, 1)
		clone2.Title.TextColor3 = color
		clone2.Level.TextColor3 = color
		clone2.Key.TextColor3 = color
		local key = p.Key or "Z"
		clone2.Key.Text = "[" .. key .. "]"
		clone2.GamepadKey.Image = GamepadConversion.getImg(key)
		reflectInputTypeForSkill(clone2) -- equivalent call inferred; original call site unknown
		clone2.Level.Text = ""
		clone2.Title.Text = p.Name
		clone2.Name = key
		clone2.LayoutOrder = v3[key]
		clone2.Visible = true
		clone2.Parent = clone
		instance:GetAttributeChangedSignal("SkillChargeAlpha"):Connect(function() end)
		clone2.Level.Text = ""
		instance:GetAttributeChangedSignal("SkillId"):Connect(function()
			clone2.Title.Text = JobToolsInfo.GetSkill(instance).Name
		end)
		tryConnectButton(nil, clone2, p) -- equivalent call inferred; original call site unknown
		return clone2
	end

	function SkillsInterface.setupJobToolSkills(instance, _)
		local name = instance.Name

		if not main then
			return SkillsInterface.destroyJobToolSkills(instance)
		end

		skills.Visible = false

		for _, frame in skills:GetChildren() do
			if frame:IsA("Frame") then
				frame.Visible = false
			end
		end

		v2 = instance
		local child = skills:FindFirstChild(name)

		if child then
			SkillsInterface.makeSkillsVisible(true, 1, instance.Name)
			setupRageBar(instance)
			child.Visible = true
		else
			local clone = container:Clone()
			clone.Name = name
			clone:SetAttribute("SkillsContainer", true)
			clone.Parent = skills
			clone.Visible = true
			local _ = instance:GetAttribute("Level") or 1
			local skillFrame = makeSkillFrame(instance, JobToolsInfo.GetSkill(instance), clone)
			instance.AncestryChanged:Connect(function(_, instance2)
				if instance2 == game.Players.LocalPlayer.Character then
					skillFrame.Title.Text = JobToolsInfo.GetSkill(instance).Name
					clone.Visible = true
				else
					clone.Visible = false

					if not (instance2 and instance2:IsDescendantOf(game)) then
						clone:Destroy()
					end
				end
			end)
			v = clone
			SkillsInterface.makeSkillsVisible(true, 1, instance.Name)
			skills.Visible = true
			setupRageBar(instance)
		end
	end

	function SkillsInterface.makeSkillsVisible(_: boolean, p: number, value: string)
		local v5 = 0.937 - p * 0.2 * 0.42
		skills.Position = UDim2.new(0.83, -10, v5, -10)
		skills.Title.Text = value:upper()
		skills.Visible = true
	end

	function SkillsInterface.onMasteryUpdated(_: string, _: number, _: number) end
end)
return SkillsInterface