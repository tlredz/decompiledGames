local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
return {
	CurrentAreas = {
		Test = {
			Grid = {
				{
					IsParent = true,
					Center = Vector2.new(workspace:WaitForChild("OuterBox").Position.X, workspace.OuterBox.Position.Z),
					Radius = Vector2.new(workspace.OuterBox.Size.X / 2, workspace.OuterBox.Size.Z / 2),
					Type = Menum.AreaType.Rectangle,
					ChildAreas = {
						InnerBox = {
							Grid = {
								{
									IsParent = true,
									Center = Vector2.new(
										workspace:WaitForChild("InnerBox").Position.X,
										workspace.InnerBox.Position.Z
									),
									Radius = Vector2.new(workspace.InnerBox.Size.X / 2, workspace.InnerBox.Size.Z / 2),
									Type = Menum.AreaType.Rectangle,
									ChildAreas = {
										FinalBox = {
											Grid = {
												{
													Center = Vector2.new(
														workspace:WaitForChild("FinalBox").Position.X,
														workspace.FinalBox.Position.Z
													),
													Radius = Vector2.new(
														workspace.FinalBox.Size.X / 2,
														workspace.FinalBox.Size.Z / 2
													),
													Type = Menum.AreaType.Rectangle
												}
											}
										}
									}
								}
							}
						}
					}
				},
				{
					IsParent = true,
					Center = Vector2.new(
						workspace:WaitForChild("OuterCircle").Position.X,
						workspace.OuterCircle.Position.Z
					),
					Radius = Vector2.new(workspace.OuterCircle.Size.Y / 2, workspace.OuterCircle.Size.Z / 2),
					Type = Menum.AreaType.Circle,
					ChildAreas = {
						InnerCircle = {
							Grid = {
								{
									IsParent = true,
									Center = Vector2.new(
										workspace:WaitForChild("InnerCircle").Position.X,
										workspace.InnerCircle.Position.Z
									),
									Radius = Vector2.new(
										workspace.InnerCircle.Size.Y / 2,
										workspace.InnerCircle.Size.Z / 2
									),
									Type = Menum.AreaType.Circle,
									ChildAreas = {
										FinalCircle = {
											Grid = {
												{
													Center = Vector2.new(
														workspace:WaitForChild("FinalCircle").Position.X,
														workspace.FinalCircle.Position.Z
													),
													Radius = Vector2.new(
														workspace.FinalCircle.Size.Y / 2,
														workspace.FinalCircle.Size.Z / 2
													),
													Type = Menum.AreaType.Circle,
													YLimits = Vector2.new(31, 50)
												},
												{
													Center = Vector2.new(
														workspace:WaitForChild("SecondFianlCircle").Position.X,
														workspace.SecondFianlCircle.Position.Z
													),
													Radius = Vector2.new(
														workspace.SecondFianlCircle.Size.Y / 2,
														workspace.SecondFianlCircle.Size.Z / 2
													),
													Type = Menum.AreaType.Circle,
													YLimits = Vector2.new(31, 50)
												}
											}
										}
									}
								}
							}
						}
					}
				}
			}
		}
	}
}