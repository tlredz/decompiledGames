require(game.ReplicatedStorage.DialoguesList.Types)
return {
	Title = "mygame43",
	Get = function(_)
		return {
			Text = { "Hey son, want to change how your Aura ability looks visually? Your original strength will remain the same. <Color=Yellow>You won't notice any difference if you still haven't unlocked the Aura ability or evolved to any stages.<Color=/>" },
			Option1 = {
				Label = "Talk",
				JumpTo = function()
					return ((function()
						local function call(p)
							game.ReplicatedStorage.Remotes.CommF_:InvokeServer("ChangeBusoStage", p)
							return {
								Text = { "[Visual stage changed.]" }
							}
						end

						local v = nil
						v = {
							Text = { "Select a stage. (1/3)" },
							Option1 = {
								Label = "Stage 0",
								Text = { "" },
								JumpTo = function()
									return (call(0))
								end
							},
							Option2 = {
								Label = "Stage 1",
								Text = { "" },
								JumpTo = function()
									return (call(1))
								end
							},
							Option3 = {
								Label = "Next",
								JumpTo = function()
									return {
										Text = { "Select a stage. (2/3)" },
										Option1 = {
											Label = "Stage 2",
											Text = { "" },
											JumpTo = function()
												return (call(2))
											end
										},
										Option2 = {
											Label = "Stage 3",
											Text = { "" },
											JumpTo = function()
												return (call(3))
											end
										},
										Option3 = {
											Label = "Next",
											JumpTo = function()
												return {
													Text = { "Select a stage. (3/3)" },
													Option1 = {
														Label = "Stage 4",
														Text = { "" },
														JumpTo = function()
															return (call(4))
														end
													},
													Option2 = {
														Label = "Stage 5",
														Text = { "" },
														JumpTo = function()
															return (call(5))
														end
													},
													Option3 = {
														Label = "Next",
														Text = { "" },
														JumpTo = function()
															return v
														end
													}
												}
											end
										}
									}
								end
							}
						}
						return v
					end)())
				end
			}
		}
	end
}