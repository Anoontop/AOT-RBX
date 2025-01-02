local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Holding = false

-- Aimbot Settings
_G.AimbotEnabled = false -- Default is off
_G.TeamCheck = true
_G.AimPart = "Head"
_G.Sensitivity = 0.1

-- FOV Circle Settings
_G.CircleSides = 64
_G.CircleColor = Color3.fromRGB(255, 255, 255)
_G.CircleTransparency = 0.7
_G.CircleRadius = 80
_G.CircleFilled = false
_G.CircleVisible = true
_G.CircleThickness = 1

local FOVCircle = Drawing.new("Circle")
FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
FOVCircle.Radius = _G.CircleRadius
FOVCircle.Filled = _G.CircleFilled
FOVCircle.Color = _G.CircleColor
FOVCircle.Visible = _G.CircleVisible
FOVCircle.Transparency = _G.CircleTransparency
FOVCircle.NumSides = _G.CircleSides
FOVCircle.Thickness = _G.CircleThickness

-- Function to toggle aimbot
function ToggleAimbot()
    _G.AimbotEnabled = not _G.AimbotEnabled
    print("Aimbot Enabled:", _G.AimbotEnabled)
end

local function GetClosestPlayer()
    local MaximumDistance = _G.CircleRadius
    local Target = nil

    for _, v in pairs(Players:GetPlayers()) do
        if v.Name ~= LocalPlayer.Name then
            if _G.TeamCheck == false or v.Team ~= LocalPlayer.Team then
                if v.Character and v.Character:FindFirstChild("HumanoidRootPart") and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health > 0 then
                    local ScreenPoint, OnScreen = Camera:WorldToViewportPoint(v.Character.HumanoidRootPart.Position)
                    if OnScreen then
                        local MousePosition = UserInputService:GetMouseLocation()
                        local VectorDistance = (Vector2.new(MousePosition.X, MousePosition.Y) - Vector2.new(ScreenPoint.X, ScreenPoint.Y)).Magnitude
                        
                        if VectorDistance < MaximumDistance then
                            MaximumDistance = VectorDistance
                            Target = v
                        end
                    end
                end
            end
        end
    end
    return Target
end

UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        Holding = true
    elseif input.KeyCode == Enum.KeyCode.F then -- Toggle with "F" key
        ToggleAimbot()
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        Holding = false
    end
end)

RunService.RenderStepped:Connect(function()
    local MousePosition = UserInputService:GetMouseLocation()
    FOVCircle.Position = Vector2.new(MousePosition.X, MousePosition.Y)
    FOVCircle.Radius = _G.CircleRadius
    FOVCircle.Filled = _G.CircleFilled
    FOVCircle.Color = _G.CircleColor
    FOVCircle.Visible = _G.CircleVisible
    FOVCircle.Transparency = _G.CircleTransparency
    FOVCircle.NumSides = _G.CircleSides
    FOVCircle.Thickness = _G.CircleThickness

    if Holding and _G.AimbotEnabled then
        local Target = GetClosestPlayer()
        if Target and Target.Character and Target.Character:FindFirstChild(_G.AimPart) then
            local TargetPosition = Target.Character[_G.AimPart].Position
            local Tween = TweenService:Create(
                Camera,
                TweenInfo.new(_G.Sensitivity, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
                {CFrame = CFrame.new(Camera.CFrame.Position, TargetPosition)}
            )
            Tween:Play()
        end
    end
end)
