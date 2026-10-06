local createVector = vector.create
local module = require("@game/ReplicatedStorage/Omni")
local characterWalkSpeed = module.Services.StarterPlayer.CharacterWalkSpeed
local v = characterWalkSpeed * 2
local mobile = module.Interface:WaitForChild("HUD"):WaitForChild("Mobile")
local moveDirectionChangedConnection = nil
local v2 = false
local Run = {
	Update = function(_: boolean?)
		local character = module:GetCharacter()

		if not character then
			return
		end

		local humanoid = character:WaitForChild("Humanoid")

		if not humanoid then
			return
		end

		local mount = module.Instance:GetAttribute("Mount")
		local frozen = module.Instance:GetAttribute("Frozen")
		local skillMovementLocked = character:GetAttribute("SkillMovementLocked")
		local skillSpeedMultiplier = character:GetAttribute("SkillSpeedMultiplier") or 1
		local running = module.Instance:GetAttribute("Running")
		local v3 = humanoid.MoveDirection ~= createVector(0, 0, 0)
		mobile.Run.Title.Text = running and "[ON]" or "[OFF]"
		mobile.Run.Title.FrontTitle.Text = running and "[ON]" or "[OFF]"
		local frontTitle = mobile.Run.Title.FrontTitle
		local textColor

		if running then
			textColor = Color3.new(0, 1, 0)
		else
			textColor = Color3.new(1, 0, 0)
		end

		frontTitle.TextColor3 = textColor
		local animate = module:GetAnimate()

		if frozen or skillMovementLocked then
			if animate then
				animate:RemoveCustomStateName("Run", "Walk")
			end

			humanoid.WalkSpeed = 0
			module.Signal:FireSelf("Player", "FOV", "Remove", "Sprint")
		elseif mount then
			local v5 = module.Shared.Mounts.List[mount]

			if not v5 then
				return
			end

			if animate then
				animate:RemoveCustomStateName("Run", "Walk")
			end

			if v5.Type == "Ground" then
				humanoid.WalkSpeed = v5.MaxSpeed
			end

			module.Signal:FireSelf("Player", "FOV", "Remove", "Sprint")
		elseif running then
			humanoid.WalkSpeed = v * skillSpeedMultiplier

			if v3 then
				if animate then
					animate:AddCustomStateName("Run", "Walk", "Run")
				end

				module.Signal:FireSelf("Player", "FOV", "Add", "Sprint", 15)
			else
				if animate then
					animate:RemoveCustomStateName("Run", "Walk")
				end

				module.Signal:FireSelf("Player", "FOV", "Remove", "Sprint")
			end
		else
			humanoid.WalkSpeed = characterWalkSpeed * skillSpeedMultiplier

			if animate then
				animate:RemoveCustomStateName("Run", "Walk")
			end

			module.Signal:FireSelf("Player", "FOV", "Remove", "Sprint")
		end
	end
}

function Run.Active(_, p)
	if p ~= Enum.UserInputState.Begin or module.Instance:GetAttribute("CancelRunning") then
		return
	end

	local v3 = module.Data.Settings["Always Run"] and true or not module.Instance:GetAttribute("Running")
	module.Instance:SetAttribute("Running", v3)
	Run.Update()
end

module:OnCharacterAdded(function(instance)
	if not instance then
		return
	end

	local humanoid = instance:FindFirstChild("Humanoid")

	if not humanoid then
		return
	end

	if moveDirectionChangedConnection and typeof(moveDirectionChangedConnection) == "RBXScriptConnection" then
		moveDirectionChangedConnection:Disconnect()
		moveDirectionChangedConnection = nil
	end

	v2 = humanoid.MoveDirection ~= createVector(0, 0, 0)
	moveDirectionChangedConnection = humanoid:GetPropertyChangedSignal("MoveDirection"):Connect(function()
		local v3 = humanoid.MoveDirection ~= createVector(0, 0, 0)

		if v3 == v2 then
			return
		end

		v2 = v3
		Run.Update()
	end)
	Run.Update(true)
end)
module.Instance:GetAttributeChangedSignal("Mount"):Connect(Run.Update)
module.Instance:GetAttributeChangedSignal("Frozen"):Connect(function()
	local PlayerModule = require(module.Instance.PlayerScripts:WaitForChild("PlayerModule"))
	local controls = PlayerModule:GetControls()

	if module.Instance:GetAttribute("Frozen") then
		controls:Disable()
	else
		controls:Enable()
	end

	Run.Update()
end)
module.Utils.Loop:Connect({
	Time = 1,
	Callback = function()
		if module.Data.Settings["Always Run"] then
			module.Instance:SetAttribute("Running", true)
			Run.Update()
		end
	end
})
module.Button:Create(mobile.Run, "Small"):BindFunction("Click", function()
	Run.Active(nil, Enum.UserInputState.Begin)
end)
module.Services.ContextActionService:BindAction(
	"Run",
	Run.Active,
	false,
	Enum.KeyCode.ButtonL1,
	Enum.KeyCode.LeftControl
)
module.Instance:SetAttribute("Running", false)
Run.Update()
return Run