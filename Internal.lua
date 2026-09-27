local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local RunService = game:GetService("RunService")

local targetCPS = 200
local interval = 1 / targetCPS
local lastClick = 0

local isVHeld = false

-- Vキーの検知
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.V then
        isVHeld = true
    end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.V then
        isVHeld = false
    end
end)

-- 高速クリックの処理
RunService.RenderStepped:Connect(function()
    if isVHeld then
        local currentTime = tick()
        if currentTime - lastClick >= interval then
            lastClick = currentTime
            
            -- マウスの左クリックをシミュレート
            local mouseLocation = UserInputService:GetMouseLocation()
            VirtualUser:Button1Down(Vector2.new(mouseLocation.X, mouseLocation.Y))
            task.spawn(function()
                VirtualUser:Button1Up(Vector2.new(mouseLocation.X, mouseLocation.Y))
            end)
        end
    end
end)
