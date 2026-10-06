local module = require("@game/ReplicatedStorage/Omni")
local fusion = module.Libs.Fusion
local prestige = module.Interface:WaitForChild("Frames"):WaitForChild("Prestige")
local rank = prestige:WaitForChild("Rank")
local current = rank:WaitForChild("Current")
local next = rank:WaitForChild("Next")
local progress = prestige:WaitForChild("Progress")
local main = prestige:WaitForChild("Prestige"):WaitForChild("Main")
local v = {}
local scope = fusion.scoped(fusion)
local value = scope:Value(0)
local spring = scope:Spring(value, 10, 1)
local Prestige = {}
scope:Observer(spring):onBind(function()
	local currentSpring = scope.peek(spring)

	if not currentSpring then
		return
	end

	local uIGradient = progress.Bar.Slider.UIGradient

	if currentSpring >= 1 then
		uIGradient.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(1, 0)
		})
	elseif currentSpring <= 0 then
		uIGradient.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1),
			NumberSequenceKeypoint.new(1, 1)
		})
	else
		uIGradient.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(currentSpring, 0),
			NumberSequenceKeypoint.new(math.min(1, currentSpring + 0.1), 1),
			NumberSequenceKeypoint.new(1, 1)
		})
	end
end)

-- equivalent calls inferred from this helper; original call sites unknown
local function GetBonusText(p)
	local v2 = 1 + p.ExtraStatPoints
	return (v2 == 1 and "1 stat point" or v2 .. " stat points") .. " / level and " .. p.ExpMultiplier .. "x Exp"
end

function Prestige.Update()
	local amount = module.Data.Prestige.Amount
	local currentInfo = module.Shared.Prestige.GetCurrentInfo(module.Data)
	local nextInfo = module.Shared.Prestige.GetNextInfo(module.Data)
	current.Title.Prestige.Text = "Prestige " .. amount
	current.Title.Level.Text = "Level " .. currentInfo.NeededLevel
	local value2 = current.Top.Info.Value
	value2.Text = GetBonusText(currentInfo)

	if nextInfo then
		next.Title.Prestige.Text = "Prestige " .. amount + 1
		next.Title.Level.Text = "Level " .. nextInfo.NeededLevel
		local value3 = next.Top.Info.Value
		value3.Text = GetBonusText(nextInfo)
		local totalExpForLevel = module.Shared.PlayerLevel.GetTotalExpForLevel(nextInfo.NeededLevel)
		local v2 = module.Shared.PlayerLevel.GetTotalExpForLevel(module.Data.Level.Amount) + module.Data.Level.Exp
		local v3 = not (totalExpForLevel > 0) and 1 or math.clamp(v2 / totalExpForLevel, 0, 1) or 1
		progress.Title.Text = "(" .. module.Utils.Number:Format(v2) .. "/" .. module.Utils.Number:Format(totalExpForLevel) .. " XP)"
		value:set(v3)
		main.Title.Text = "Prestige"
	else
		next.Title.Prestige.Text = "MAXED"
		next.Title.Level.Text = ""
		next.Top.Info.Value.Text = "You've reached the maximum Prestige."
		progress.Title.Text = "MAXED"
		value:set(1)
		main.Title.Text = "MAXED"
	end
end

function Prestige.Start()
	spring:setPosition(0)
	v.Level = module:OnDataChangedDeferred({ "Level" }, Prestige.Update)
	v.Prestige = module:OnDataChangedDeferred({ "Prestige" }, Prestige.Update)
	Prestige.Update()
end

function Prestige.Stop()
	for _, connection in v do
		connection:Disconnect()
	end

	table.clear(v)
end

function Prestige.Init()
	module.Frame:OnFrameOpened(prestige, Prestige.Start)
	module.Frame:OnFrameClosed(prestige, Prestige.Stop)
	module.Button:Create(main, "Default"):BindFunction("Click", function()
		local nextInfo = module.Shared.Prestige.GetNextInfo(module.Data)

		if not nextInfo then
			return
		end

		if module.Data.Level.Amount < nextInfo.NeededLevel then
			module.Signal:FireSelf("Interface", "Notifications", "Create", "Text", {
				Message = "You can't prestige yet.",
				Color = Color3.fromRGB(255, 255, 0)
			})
		else
			module.Signal:FireSelf("Interface", "Confirmation", "Start", {
				Title = "Prestige",
				Description = "This will reset your Level, Exp and Stats back to 0. Are you sure?",
				ConfirmText = "Prestige",
				Callback = function(flag: boolean)
					if not flag then
						return
					end

					module.Signal:Fire("General", "Prestige", "Prestige")
				end
			})
		end
	end)
end

return Prestige