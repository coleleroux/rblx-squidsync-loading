local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local ContentProvider = game:GetService("ContentProvider")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local uiLetters = ReplicatedStorage.ui.letters

local screenGui = playerGui:WaitForChild("screenGui")
local logoContainer = screenGui:WaitForChild("logoContainer")

local word = "squidsync"
local letterSize = 50
local spacing = 5
local totalWidth = (#word * letterSize) + ((#word - 1) * spacing)
-- Adjust for the screenGui's current size
local screenWidth = screenGui.AbsoluteSize.X
local startPositionX = (screenWidth - totalWidth) / 2
local centerY = 0.5 -- Center vertically in the screenGui

-- Collect all assets to preload
local assetsToPreload = {}
for i = 1, #word do
    local char = word:sub(i, i)
    local letterImage = uiLetters:FindFirstChild("letter-" .. char)
    if letterImage then
        table.insert(assetsToPreload, letterImage.Value)
    end
end

-- Function to create the tween for each letter
local function createTween(letterImage, startPosition, endPosition, delay, duration, repeatCount, reverses)
    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, repeatCount, reverses, delay)
    local goal = { Position = endPosition }
    local tween = TweenService:Create(letterImage, tweenInfo, goal)
    return tween
end

local function createSineWaveBounceTween(imageInstance, duration, repeatCount, reverses)
    local tweenInfo = TweenInfo.new(
        duration,
        Enum.EasingStyle.Sine,
        Enum.EasingDirection.Out,
        repeatCount,
        reverses
    )
    local goals = {
        Position = imageInstance.Position + UDim2.new(0, 0, 0, -10), -- translateY(-10px)
        Size = imageInstance.Size * 0.95, -- scale(0.95)
        Transparency = 0 -- opacity: 1 (in Roblox, 0 means fully visible)
    }
    local tween = TweenService:Create(imageInstance, tweenInfo, goals)

    -- Tween modifiers for different keyframes
    tween.Completed:Connect(function(playbackState)
        if playbackState == Enum.PlaybackState.Completed then
            -- 25% keyframe equivalent
            goals.Position = imageInstance.Position + UDim2.new(0, 0, 0, 5)
            goals.Size = imageInstance.Size * 1.05
            goals.Transparency = 0.5
            local tween25 = TweenService:Create(imageInstance, tweenInfo, goals)
            tween25:Play()

            -- 50% keyframe equivalent
            goals.Position = imageInstance.Position + UDim2.new(0, 0, 0, -5)
            goals.Size = imageInstance.Size * 1
            goals.Transparency = 0.75
            local tween50 = TweenService:Create(imageInstance, tweenInfo, goals)
            tween50:Play()

            -- 75% keyframe equivalent
            goals.Position = imageInstance.Position + UDim2.new(0, 0, 0, 2)
            goals.Size = imageInstance.Size * 0.98
            goals.Transparency = 0.875
            local tween75 = TweenService:Create(imageInstance, tweenInfo, goals)
            tween75:Play()

            -- 100% keyframe equivalent
            goals.Position = imageInstance.Position
            goals.Size = imageInstance.Size * 1
            goals.Transparency = 1
            local tween100 = TweenService:Create(imageInstance, tweenInfo, goals)
            tween100:Play()
        end
    end)

    return tween
end

-- Preload assets and wait for a minimum of 5 seconds
local startTime = tick()
ContentProvider:PreloadAsync(assetsToPreload)
local elapsedTime = tick() - startTime
if elapsedTime < 5 then
    wait(5 - elapsedTime) -- Ensure a minimum of 5 seconds wait time
end

-- Assuming logoContainer is a Frame or similar UI element
logoContainer.AnchorPoint = Vector2.new(0.5, 0.5) -- Set anchor to the center
logoContainer.Position = UDim2.new(0.5, 0, 0.5, 0) -- Center on screen
logoContainer.Size = UDim2.new(0, totalWidth, 0, letterSize) -- Set size to contain all letters

-- Calculate the starting X position for the first letter to center the word in the logoContainer
local centerX = logoContainer.AbsoluteSize.X / 2
local firstLetterX = centerX - (totalWidth / 2)

-- Create, play, and store tweens for each letter
local tweens = {}
for i = 1, #word do
    local char = word:sub(i, i)
    local letterImage = uiLetters:FindFirstChild("letter-" .. char)
    if letterImage then
        local imageInstance = Instance.new("ImageLabel")
        imageInstance.Image = letterImage.Value
        imageInstance.Size = UDim2.new(0, letterSize, 0, letterSize)
        -- Calculate the position for each letter relative to the center of the logoContainer
        local letterPositionX = firstLetterX + (i - 1) * (letterSize + spacing)
        local initialPosition = UDim2.new(0, letterPositionX, 0.5, 0)
        imageInstance.Position = initialPosition
        imageInstance.AnchorPoint = Vector2.new(0, 0.5)
        imageInstance.BackgroundTransparency = 1
        imageInstance.Parent = logoContainer

        -- Create the tween for the letter
        local bouncePosition = UDim2.new(0, letterPositionX, 0.5, -20) -- Bounce up by 20 pixels
        local tween = createTween(imageInstance, initialPosition, bouncePosition, (i - 1) * 0.1, 0.75, -1, true)
        table.insert(tweens, tween)
        tween:Play()
    end
end

-- Wait for the condition to tween letters back and fade out
wait(5) -- Simulate additional wait time or conditions

-- Cancel all repeating tweens and tween letters back to their starting positions
for i, tween in ipairs(tweens) do
    tween:Cancel()
    local letterImage = tween.Instance
    local letterPositionX = firstLetterX + (i - 1) * (letterSize + spacing)
    local initialPosition = UDim2.new(0, letterPositionX, 0.5, 0)
    local resetTween = createTween(letterImage, letterImage.Position, initialPosition, 0, 0.5, 0, false)
    resetTween:Play()
end

-- Wait for all letters to move back to their starting positions
wait(0.5)

-- Fade out each letter
for _, tween in ipairs(tweens) do
    local letterImage = tween.Instance
    local fadeOutTween = TweenService:Create(letterImage, TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {Transparency = 1})
    fadeOutTween:Play()
end

-- Wait for the letters to fade out
wait(0.5)

-- Finally, fade out and destroy the logoContainer
local fadeOutTween = TweenService:Create(logoContainer, TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {Transparency = 1})
fadeOutTween.Completed:Connect(function()
    logoContainer:Destroy()
end)
fadeOutTween:Play()