local InstantiableComponentsMap = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local instantiableComponents = ReplicatedStorage.InstantiableComponents
InstantiableComponentsMap.COMPONENTS = {
	LoadingSpinner = instantiableComponents.Ui.LoadingSpinner,
	LoadingSpinnerAE = instantiableComponents.Ui.LoadingSpinnerAE
}

function InstantiableComponentsMap.GetInstantiableComponent(p: string)
	return InstantiableComponentsMap.COMPONENTS[p]
end

return InstantiableComponentsMap