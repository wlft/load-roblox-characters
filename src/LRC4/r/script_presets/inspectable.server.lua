-- // Inserted by LRC4
-- // Written by @Wolf1te 17/08/24 | 1.0 - 17/08/24
-- // https://create.roblox.com/store/asset/8867876284/Load-Roblox-Characters-4

local players = game:GetService("Players")
local gs = game:GetService("GuiService")

repeat task.wait() until script.Parent:IsA("Model") and script.Parent:FindFirstChildOfClass("Humanoid")

local target_uid = script:GetAttribute("uid") or script:GetAttribute("target_uid")

if typeof(target_uid) ~= "number" then return end


local prox = Instance.new("ProximityPrompt", script.Parent:FindFirstChildOfClass("Humanoid").RootPart or script.Parent)
prox.Name = "lrc4_inspect"
prox.ActionText = "Inspect Avatar"
prox.ObjectText = `@{players:GetNameFromUserIdAsync(target_uid)}'s Avatar`
prox.HoldDuration = 0.7
prox.KeyboardKeyCode = Enum.KeyCode.I
prox.Exclusivity = Enum.ProximityPromptExclusivity.OneGlobally
prox.RequiresLineOfSight = false

prox.Triggered:Connect(function()
	gs:InspectPlayerFromHumanoidDescription(script.Parent:FindFirstChildOfClass("Humanoid"):FindFirstChildOfClass("HumanoidDescription"), players:GetNameFromUserIdAsync(target_uid))
end)