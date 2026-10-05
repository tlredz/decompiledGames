require(script.Parent.Types)
local Controls = require(script.Parent.Controls)
local Net = require(game.ReplicatedStorage.Modules.Net)
Net:RemoteFunction("JobsRemoteFunction")
local Net2 = require(game.ReplicatedStorage.Modules.Net)
local remoteFunction = Net2:RemoteFunction("JobToolAbilities")
local SkillsInterface = require(script.Parent.SkillsInterface)
require(script.Parent.Types)
local JobToolsInfo = require(script.Parent.JobToolsInfo)
local RunService = game:GetService("RunService")
RunService:IsServer()
local localPlayer = game.Players.LocalPlayer
JobToolAbilities = nil
task.spawn(function()
	JobToolAbilities = script.Parent:WaitForChild("JobToolAbilities")
end)
local JobTools = {
	Info = JobToolsInfo,
	getEquippedJobTool = function()
		local character = localPlayer.Character
		local tool

		if character then
			tool = character:FindFirstChildOfClass("Tool")
		end

		if tool and tool:HasTag("JobTool") then
			return tool
		end
	end
}

local function lerp(p: number, p2: number, p3: number)
	return p + (p2 - p) * p3
end

JobTools.SkillsInterface = SkillsInterface
JobTools.ControlBindings = {}
JobTools.SkillsInterface.ControlBindings = JobTools.ControlBindings
JobTools.CurrentAbility = nil
local v = {
	Z = Enum.KeyCode.ButtonX,
	X = Enum.KeyCode.ButtonA,
	C = Enum.KeyCode.ButtonB,
	V = Enum.KeyCode.ButtonY
}

for _, v2 in {
	"Z",
	"X",
	"C",
	"V"
} do
	local now = 0
	local controlBindings = JobTools.ControlBindings
	local registerControlBindings = Controls.RegisterControlBindings
	local v3 = {
		Name = "JobTool_" .. v2,
		AllowSimultaneousInputs = false,
		ControlPriority = Controls.ControlPriorities.Skill + 100,
		ControlBinds = 0,
		OnBegan = 0,
		OnChanged = 0,
		OnEnded = 0
	}
	local consoleOrComputers = {
		[Enum.KeyCode[v2]] = Controls.ControlSchemes.ConsoleOrComputer,
		[v[v2]] = Controls.ControlSchemes.ConsoleOrComputer
	}
	v3.ControlBinds = consoleOrComputers
	local v4 = v2

	function v3.OnBegan(p)
		if now > tick() then
			return false
		end

		local equippedJobTool = JobTools.getEquippedJobTool()

		if not (equippedJobTool and JobToolsInfo.GetInfo(equippedJobTool)) then
			return false
		end

		local skill = JobToolsInfo.GetSkill(equippedJobTool)
		local skillChargeAlpha = JobToolsInfo.GetSkillChargeAlpha(equippedJobTool)

		if not skill then
			return false
		end

		if skillChargeAlpha < 1 then
			local Notification = require(game.ReplicatedStorage.Notification)
			Notification.new("Must have max power!"):Display()
			return false
		else
			local child = JobToolAbilities:FindFirstChild(skill.Name)

			if not child then
				return
			end

			now = 1e999
			local module = require(child)

			if module.onActivated(equippedJobTool, p) ~= true then
				return false
			end

			script.Parent.AbilityActivated:Fire(equippedJobTool, p)
			SkillsInterface.animateCooldown(equippedJobTool.Name, v4, now)

			if remoteFunction:InvokeServer(v4, true) then
				now = tick() + skill.Cooldown
			else
				now = tick()
			end

			SkillsInterface.animateCooldown(equippedJobTool.Name, v4, now)
		end
	end

	function v3.OnChanged(_, _) end

	function v3.OnEnded(_) end

	controlBindings[v2] = registerControlBindings(v3)
end

Controls.RegisterControlBindings({
	Name = "JobTool_Primary",
	AllowSimultaneousInputs = false,
	ControlPriority = Controls.ControlPriorities.Tool,
	ControlBinds = {
		[Enum.UserInputType.Touch] = Controls.ControlSchemes.Mobile,
		[Enum.UserInputType.MouseButton1] = Controls.ControlSchemes.ConsoleOrComputer,
		[Enum.KeyCode.ButtonR2] = Controls.ControlSchemes.ConsoleOrComputer
	},
	OnBegan = function(_)
		return false
	end,
	OnChanged = function(_, _) end,
	OnEnded = function(_) end
})

function JobTools.isSkillUnlocked(_, _: string)
	return true
end

return JobTools