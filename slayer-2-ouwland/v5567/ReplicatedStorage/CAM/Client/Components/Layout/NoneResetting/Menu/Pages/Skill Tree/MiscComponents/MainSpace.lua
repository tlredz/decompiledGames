local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.CAM.Client.Components.Layout.NoneResetting.Menu.Pages["Skill Tree"].TreeConfigurations)
require(ReplicatedStorage.Packages.faye)
return function(object, object2)
	return object:Space(function(state)
		local CS = state.Current.Locked ~= false and 1 or state.Current.IsBranch and 3 or 2

		if state.CS ~= CS then
			state.CS = CS

			if CS == 1 then
				state.ChainTransparency:Set(0.925)
			else
				state.ChainTransparency:Reset()
			end

			state.State:Set(CS)
		end

		local mode = object2:Compare(state.Current) and 2 or state.Hovering and 3 or 1
		local hasEquipped = object2:Get() ~= nil

		if state.Mode ~= mode or state.HasEquipped ~= hasEquipped then
			state.Mode = mode
			state.HasEquipped = hasEquipped

			if mode == 2 then
				state.ContentTransparency:Set(0)
				state.OuterColor:Set(Color3.new(1, 1, 1))
				state.InnerColor:Set(Color3.new(0.35, 0.45, 0.5))
				state.GlowColor:Set(Color3.new(0.45, 0.55, 0.6))
				state.GradientDisabled:Set(true)
			elseif mode == 3 then
				state.ContentTransparency:Set(0)
				state.OuterColor:Reset()
				state.InnerColor:Reset()
				state.GlowColor:Reset()
				state.GradientDisabled:Reset()
			else
				if object2:Get() == nil then
					state.ContentTransparency:Reset()
				else
					state.ContentTransparency:Set(0.75)
				end

				state.OuterColor:Reset()
				state.InnerColor:Reset()
				state.GlowColor:Reset()
				state.GradientDisabled:Reset()
			end
		end
	end):Call()
end