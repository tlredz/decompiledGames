local module = require("@game/ReplicatedStorage/Omni")
local fusion = module.Libs.Fusion
require("./../Controller")
local list = module.Interface:WaitForChild("Frames"):WaitForChild("Quests"):WaitForChild("RightFrame"):WaitForChild("Rewards"):WaitForChild("List")
local quests = module.Assets:WaitForChild("Interface"):WaitForChild("Templates"):WaitForChild("Quests")
return fusion.scoped(fusion, {
	Build = function(scope, duration: number)
		scope.Size = scope:Value(UDim2.fromScale(0, 0))
		scope.SizeSpring = scope:Spring(scope.Size, 10, 1)
		scope.Instance = quests.Reward:Clone()
		scope.Instance.Name = scope.Info.Name
		scope.Instance.Main.Amount.Text = scope.Info.Text
		scope.Instance.Main.UIGradient:SetAttribute("Rarity", scope.Info.Rarity or "Common")

		if scope.Info.Icon then
			scope.Instance.Main.Icon.Visible = true
			scope.Instance.Main.Viewport.Visible = false
			scope.Instance.Main.Icon.Image = scope.Info.Icon or ""
		else
			scope.Instance.Main.Icon.Visible = false
			scope.Instance.Main.Viewport.Visible = true
			module.Utils.Camera.ViewportCharacter({
				Viewport = scope.Instance.Main.Viewport,
				Animation = module.Utils.Characters.GetCharacterAnimation(scope.Info.Name, "Idle"),
				Character = module.Utils.Characters.Get({
					Name = scope.Info.Name,
					Shiny = scope.Info.Shiny,
					RemoveHumanoidStates = true
				})
			})
		end

		local v = module.Button:Create(scope.Instance.Main, "Small")
		v:BindFunction("Click", function()
			if not scope.Hover then
				return
			end

			if scope.Tooltip then
				scope.Hover:Click(scope.Instance, {
					Text = scope.Info.Name
				})
			else
				scope.Hover:Click(scope.Instance, {
					IsFake = true,
					Data = scope.Info
				})
			end
		end)
		v:BindOnEnter("Hover", function()
			if not scope.Hover then
				return
			end

			if scope.Tooltip then
				scope.Hover:Open(scope.Instance, {
					Text = scope.Info.Name
				})
			else
				scope.Hover:Open(scope.Instance, {
					IsFake = true,
					Data = scope.Info
				})
			end
		end)
		v:BindOnLeave("Hover", function()
			if not scope.Hover then
				return
			end

			scope.Hover:Close(scope.Instance)
		end)
		scope.Instance.Parent = list
		scope.Instance.Visible = true
		scope:Hydrate(scope.Instance.Main)({
			Size = scope.SizeSpring
		})

		if duration and duration > 0 then
			task.delay(duration, function()
				if not next(scope) then
					return
				end

				scope.Size:set(UDim2.fromScale(1, 1))
			end)
		else
			scope.Size:set(UDim2.fromScale(1, 1))
		end

		return true
	end
})