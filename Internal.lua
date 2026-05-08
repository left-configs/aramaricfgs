--[[
    mirukuyowa V3 - ULTRA GENESIS (aramaricfgs Edition)
    UPGRADED FROM V2 TO V3
    FEATURES: Bullet Penetration (Wall Bang), Advanced RageBot, Anti-Aim, Silent Aim
]]

-- [1] CORE SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local VIM = game:GetService("VirtualInputManager")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- [2] GLOBAL SETTINGS
getgenv().Config = {
    Combat = {
        SilentAim = false,
        RageBot = false,
        WallBang = false, -- 弾貫通
        HitPart = "Head",
        SilentFOV = 200,
        Prediction = 0.165,
        WallCheck = true,
        AntiAim = false,
        SpinSpeed = 50,
        AutoShoot = false
    },
    Visuals = {
        ESP = false,
        FOVCircle = true
    }
}

-- [3] TARGETING UTILITIES
local function GetClosestPlayer()
    local target = nil
    local dist = getgenv().Config.Combat.SilentFOV

    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health > 0 then
            local pos, onScreen = Camera:WorldToViewportPoint(v.Character[getgenv().Config.Combat.HitPart].Position)
            local mousePos = Vector2.new(Mouse.X, Mouse.Y)
            local distance = (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude

            if distance < dist then
                if getgenv().Config.Combat.WallCheck and not getgenv().Config.Combat.WallBang then
                    local ray = Ray.new(Camera.CFrame.Position, v.Character[getgenv().Config.Combat.HitPart].Position - Camera.CFrame.Position)
                    local part = Workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character, Camera})
                    if part and part:IsDescendantOf(v.Character) then
                        target = v
                        dist = distance
                    end
                else
                    target = v
                    dist = distance
                end
            end
        end
    end
    return target
end

-- [4] HOOKS & WALL BANG LOGIC
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}

    if not checkcaller() then
        if (method == "FindPartOnRayWithIgnoreList" or method == "Raycast") and getgenv().Config.Combat.SilentAim then
            local target = GetClosestPlayer()
            if target and target.Character and target.Character:FindFirstChild(getgenv().Config.Combat.HitPart) then
                local hitPos = target.Character[getgenv().Config.Combat.HitPart].Position + (target.Character[getgenv().Config.Combat.HitPart].Velocity * getgenv().Config.Combat.Prediction)
                
                if method == "Raycast" then
                    args[2] = (hitPos - args[1]).Unit * 1000
                else
                    args[1] = Ray.new(Camera.CFrame.Position, (hitPos - Camera.CFrame.Position).Unit * 1000)
                end
            end
        end

        -- Bullet Penetration (Wall Bang) Implementation
        if getgenv().Config.Combat.WallBang and method == "Raycast" then
            if args[3] and typeof(args[3]) == "RaycastParams" then
                args[3].FilterType = Enum.RaycastFilterType.Exclude
                -- Ignore map obstacles to allow bullets to pass through
                local ignoreList = {Workspace:FindFirstChild("Map"), Workspace.Terrain}
                args[3].FilterDescendantsInstances = ignoreList
            end
        end
    end

    return oldNamecall(self, unpack(args))
end)

-- [5] ANTI-AIM (SPINBOT)
RunService.Stepped:Connect(function()
    if getgenv().Config.Combat.AntiAim and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = LocalPlayer.Character.HumanoidRootPart
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(getgenv().Config.Combat.SpinSpeed), 0)
    end
end)

-- [6] UI DESIGN (V3 CUSTOM)
local function CreateUI()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "aramaricfgs_V3"
    ScreenGui.Parent = CoreGui

    local Main = Instance.new("Frame")
    Main.Size = UDim2.new(0, 450, 0, 300)
    Main.Position = UDim2.new(0.5, -225, 0.5, -150)
    Main.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    Main.BorderSizePixel = 0
    Main.Active = true
    Main.Draggable = true
    Main.Parent = ScreenGui

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 8)
    Corner.Parent = Main

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.Text = "aramaricfgs V3 - ULTRA"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 16
    Title.Parent = Main

    local function CreateToggle(name, configKey, pos)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 180, 0, 35)
        btn.Position = pos
        btn.Text = name .. ": OFF"
        btn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
        btn.TextColor3 = Color3.fromRGB(200, 200, 200)
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 14
        btn.Parent = Main

        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 6)
        btnCorner.Parent = btn

        btn.MouseButton1Click:Connect(function()
            getgenv().Config.Combat[configKey] = not getgenv().Config.Combat[configKey]
            btn.Text = name .. ": " .. (getgenv().Config.Combat[configKey] and "ON" or "OFF")
            btn.TextColor3 = getgenv().Config.Combat[configKey] and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(200, 200, 200)
        end)
    end

    CreateToggle("Silent Aim", "SilentAim", UDim2.new(0.05, 0, 0.2, 0))
    CreateToggle("Wall Bang (Beta)", "WallBang", UDim2.new(0.05, 0, 0.4, 0))
    CreateToggle("Rage Bot", "RageBot", UDim2.new(0.53, 0, 0.2, 0))
    CreateToggle("Anti-Aim", "AntiAim", UDim2.new(0.53, 0, 0.4, 0))
    CreateToggle("Auto Shoot", "AutoShoot", UDim2.new(0.05, 0, 0.6, 0))
end

-- [7] FOV CIRCLE
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1.5
FOVCircle.Radius = getgenv().Config.Combat.SilentFOV
FOVCircle.Visible = true
FOVCircle.Color = Color3.fromRGB(255, 255, 255)

RunService.RenderStepped:Connect(function()
    FOVCircle.Position = Vector2.new(Mouse.X, Mouse.Y + 36)
    FOVCircle.Visible = getgenv().Config.Visuals.FOVCircle
end)

-- [8] AUTO SHOOT LOOP
spawn(function()
    while task.wait() do
        if getgenv().Config.Combat.AutoShoot or getgenv().Config.Combat.RageBot then
            local target = GetClosestPlayer()
            if target then
                VIM:SendMouseButtonEvent(Mouse.X, Mouse.Y, 0, true, game, 1)
                task.wait(0.02)
                VIM:SendMouseButtonEvent(Mouse.X, Mouse.Y, 0, false, game, 1)
            end
        end
    end
end)

CreateUI()
print("aramaricfgs V3: Script Loaded.")
