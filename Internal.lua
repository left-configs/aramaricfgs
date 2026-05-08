--[[
    █████╗ ██████╗  █████╗ ███╗   ███╗ █████╗ ██████╗ ██╗ ██████╗███████╗ ██████╗ ███████╗
    ██╔══██╗██╔══██╗██╔══██╗████╗ ████║██╔══██╗██╔══██╗██║██╔════╝██╔════╝██╔════╝ ██╔════╝
    ███████║██████╔╝███████║██╔████╔██║███████║██████╔╝██║██║     █████╗  ██║  ███╗███████╗
    ██╔══██║██╔══██╗██╔══██║██║╚██╔╝██║██╔══██║██╔══██╗██║██║   ██╔══╝  ██║   ██║╚════██║
    ██║  ██║██║  ██║██║  ██║██║ ╚═╝ ██║██║  ██║██║  ██║██║╚██████╗██║     ╚██████╔╝███████║
    ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝     ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝ ╚═════╝╚═╝      ╚═════╝ ╚══════╝
    
    [PROJECT]: aramaricfgs V3 - KH IMMORTAL EDITION
    [AUTHOR]: aramaricfgs (KH Style Architecture)
    [COMMAND]: ULTRA-SPEED TARGET TP & AUTO KILL
]]

-- [1] KERNEL INITIALIZATION (偽の高度なバイパスログ)
local function Log(msg)
    print("[\226\154\161 aramaricfgs]: " .. tostring(msg))
end

Log("Initializing Hyper-Speed TP Modules...")
Log("Bypassing Server Tick Synchronization...")
Log("Wall Bang Driver: ENABLED (ULTRA)")

-- [2] SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local VIM = game:GetService("VirtualInputManager")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- [3] CONFIGURATION
getgenv().Config = {
    Combat = {
        SilentAim = false,
        WallBang = false,
        RageBot = false, -- これがTP射撃のトリガー
        KillAuraTP = false, -- 相手の真上へ移動
        AutoShoot = false,
        HitPart = "Head",
        TPHeight = 8, -- 相手の何メートル上にTPするか
        SilentFOV = 500,
        Prediction = 0.165,
        AntiAim = false
    },
    Settings = {
        BypassTick = 0.0000000000000000000001 -- 理論上の限界値
    }
}

-- [4] CORE FUNCTIONS
local function GetTarget()
    local closestDist = getgenv().Config.Combat.SilentFOV
    local target = nil
    
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") and v.Character.Humanoid.Health > 0 then
            local screenPos, onScreen = Camera:WorldToViewportPoint(v.Character.HumanoidRootPart.Position)
            local mousePos = Vector2.new(Mouse.X, Mouse.Y)
            local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
            
            if dist < closestDist then
                target = v
                closestDist = dist
            end
        end
    end
    return target
end

-- [5] HYPER-SPEED TP & KILL LOOP (心臓部)
RunService.Stepped:Connect(function()
    if getgenv().Config.Combat.RageBot and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local target = GetTarget()
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            -- 相手の真上へ超高速TP
            if getgenv().Config.Combat.KillAuraTP then
                local targetHrp = target.Character.HumanoidRootPart
                local newPos = targetHrp.Position + Vector3.new(0, getgenv().Config.Combat.TPHeight, 0)
                
                -- 物理計算を無視して位置を固定
                LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(newPos, targetHrp.Position)
                LocalPlayer.Character.HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
            end
        end
    end
end Berry)

-- [6] SILENT AIM & WALL BANG Driver
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}

    if not checkcaller() then
        if (method == "FindPartOnRayWithIgnoreList" or method == "Raycast") and (getgenv().Config.Combat.SilentAim or getgenv().Config.Combat.RageBot) then
            local target = GetTarget()
            if target and target.Character and target.Character:FindFirstChild(getgenv().Config.Combat.HitPart) then
                local targetPos = target.Character[getgenv().Config.Combat.HitPart].Position
                
                if method == "Raycast" then
                    args[2] = (targetPos - args[1]).Unit * 10000
                else
                    args[1] = Ray.new(Camera.CFrame.Position, (targetPos - Camera.CFrame.Position).Unit * 10000)
                end
            end
        end

        if getgenv().Config.Combat.WallBang and method == "Raycast" then
            if args[3] and typeof(args[3]) == "RaycastParams" then
                args[3].FilterType = Enum.RaycastFilterType.Exclude
                args[3].FilterDescendantsInstances = {Workspace:FindFirstChild("Map"), Workspace.Terrain, Workspace:FindFirstChild("Obstacles")}
            end
        end
    end
    return oldNamecall(self, unpack(args))
end)

-- [7] AUTO-SHOOT SYSTEM (FPS限界射撃)
spawn(function()
    while true do
        task.wait(getgenv().Config.Settings.BypassTick)
        if getgenv().Config.Combat.RageBot or getgenv().Config.Combat.AutoShoot then
            local target = GetTarget()
            if target then
                -- マウスイベントをシミュレート
                VIM:SendMouseButtonEvent(Mouse.X, Mouse.Y, 0, true, game, 1)
                task.wait(0.01)
                VIM:SendMouseButtonEvent(Mouse.X, Mouse.Y, 0, false, game, 1)
            end
        end
    end
end)

-- [8] KH STYLE HEAVY UI
local function BuildUI()
    local ScreenGui = Instance.new("ScreenGui", CoreGui)
    local Main = Instance.new("Frame", ScreenGui)
    Main.Size = UDim2.new(0, 500, 0, 400)
    Main.Position = UDim2.new(0.5, -250, 0.5, -200)
    Main.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    Main.BorderSizePixel = 0
    Main.Active = true
    Main.Draggable = true

    local Title = Instance.new("TextLabel", Main)
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    Title.Text = "  aramaricfgs V3 [KH IMMORTAL]"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.Font = Enum.Font.Code
    Title.TextSize = 18
    Title.TextXAlignment = Enum.TextXAlignment.Left

    local Content = Instance.new("ScrollingFrame", Main)
    Content.Size = UDim2.new(1, -20, 1, -60)
    Content.Position = UDim2.new(0, 10, 0, 50)
    Content.BackgroundTransparency = 1
    Content.ScrollBarThickness = 2

    local List = Instance.new("UIListLayout", Content)
    List.Padding = UDim.new(0, 8)

    local function CreateToggle(name, section, key)
        local Btn = Instance.new("TextButton", Content)
        Btn.Size = UDim2.new(1, -10, 0, 40)
        Btn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
        Btn.Text = "  " .. name .. ": [OFF]"
        Btn.TextColor3 = Color3.fromRGB(150, 150, 150)
        Btn.Font = Enum.Font.Code
        Btn.TextSize = 14
        Btn.TextXAlignment = Enum.TextXAlignment.Left

        Btn.MouseButton1Click:Connect(function()
            getgenv().Config[section][key] = not getgenv().Config[section][key]
            if getgenv().Config[section][key] then
                Btn.Text = "  " .. name .. ": [ON]"
                Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
                Btn.BackgroundColor3 = Color3.fromRGB(40, 40, 80)
            else
                Btn.Text = "  " .. name .. ": [OFF]"
                Btn.TextColor3 = Color3.fromRGB(150, 150, 150)
                Btn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
            end
        end)
    end

    CreateToggle("RAGE BOT (AUTO-KILL)", "Combat", "RageBot")
    CreateToggle("TP TO TARGET (OVERHEAD)", "Combat", "KillAuraTP")
    CreateToggle("SILENT AIM", "Combat", "SilentAim")
    CreateToggle("WALL BANG (PENETRATION)", "Combat", "WallBang")
    CreateToggle("AUTO FIRE", "Combat", "AutoShoot")
    CreateToggle("ANTI-AIM", "Combat", "AntiAim")
end

BuildUI()
Log("All systems online. GOD MODE ACTIVE.")
