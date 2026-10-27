local RunService          = game:GetService("RunService")
local Players             = game:GetService("Players")
local Workspace           = game:GetService("Workspace")
local UserInputService    = game:GetService("UserInputService")
local StarterGui          = game:GetService("StarterGui")
local VirtualInputManager = game:GetService("VirtualInputManager")
local CollectionService   = game:GetService("CollectionService")
local HttpService         = game:GetService("HttpService")
local LocalPlayer         = Players.LocalPlayer

local GENV = (getgenv and getgenv()) or _G

local function safe_notify(api, props)
    local title = tostring(props.title or (api and api.name) or "Lilac")
    local content = tostring(props.content or props.text or props.message or "")
    local duration = tonumber(props.duration) or 3

    local payload = {
        title = title, content = content, duration = duration,
        text = content, message = content, description = content, body = content,
        Title = title, Content = content, Text = content, Message = content,
        Duration = duration, time = duration,
    }

    local function attempt()
        local ui = api and api.ui
        if ui and type(ui.notify) == "function" then
            local ok = pcall(function()
                ui:notify(payload)
            end)
            if ok then
                return true
            end
        end

        local ok = pcall(function()
            StarterGui:SetCore("SendNotification", {
                Title = title,
                Text = content,
                Duration = duration,
            })
        end)
        return ok
    end

    task.spawn(function()
        local delays = { 0.15, 0.5, 1, 2, 4 }
        for _, delay in ipairs(delays) do
            task.wait(delay)
            if attempt() then
                return
            end
        end
    end)
end

local FONT_OPTIONS = {
    "UI", "System", "Plex", "Monospace", "Monospace Bold",
}

local TEXT_PRESETS = {
    "LILAC", "Harry Extensions", "harryfemboy", "Ragebot", "Rivals",
}

local CROSSHAIR_ANIMATIONS = {
    "Static", "Bounce", "Rotate", "Bounce + Rotate",
}

local function normalize_crosshair_animation(value)
    if type(value) == "number" then
        return CROSSHAIR_ANIMATIONS[value] or "Static"
    end

    local text = tostring(value or "Static")
    local numeric_index = tonumber(text)
    if numeric_index and CROSSHAIR_ANIMATIONS[numeric_index] then
        return CROSSHAIR_ANIMATIONS[numeric_index]
    end

    for _, option in ipairs(CROSSHAIR_ANIMATIONS) do
        if option == text then
            return option
        end
    end
    return "Static"
end

local function normalize_font_name(value)
    if type(value) == "number" then
        return FONT_OPTIONS[value] or "UI"
    end

    local text = tostring(value or "UI")
    local numeric_index = tonumber(text)
    if numeric_index and FONT_OPTIONS[numeric_index] then
        return FONT_OPTIONS[numeric_index]
    end

    for _, option in ipairs(FONT_OPTIONS) do
        if option == text then
