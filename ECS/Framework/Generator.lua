--============================================================================================
-- ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓

local process = {
    TestComponent = "ECS\\Game\\Test\\TestComponent.lua",
    MoveComponent = "ECS\\Game\\Move\\MoveComponent.lua",
    Camp1Component = "ECS\\Game\\Camp1Component.lua"
}


-- ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑
--============================================================================================

require("Core.functions")
local generate_path = 'ECS\\Generated\\Components\\Game'

local entity_extention = {}
--[[
    entity_extention = {
        [TestComponent] = 'id, list, bol'
    }
]]
---------------------------------------------------------------------------------------
-- 生成GameComponent代码
---------------------------------------------------------------------------------------
print("----------- 生成GameComponent代码 -----------------------------------------------")

for name, path in pairs(process) do
    local code_comp = [[
local _Base = require('ECS.Framework.Component')
local [Name] = class('[Name]', _Base)

function [Name]:Init([Param])
[Prop]
end

function [Name]:SetData([Param])
[SetData]
end

return [Name]
]]

    local comp = path:gsub('\\', '.')
    comp = comp:gsub('.lua', '')
    local script = require(comp)

    local file = io.open(path, "r")
    assert(file, "read file is nil")

    entity_extention[name] = {}

    ---------------- 处理属性字段 ----------------
    local content = ''
    local set_content = ''
    local index = 0
    local line = ''
    local param = ''

    for r in file:lines() do
        if table_is_empty(script) then
            break
        end
        index = index + 1
        if index >= 2 then
            if r == '}' then
                break
            end
            line = r
            line = line:gsub(' ', '')
            line = line:gsub('\n', '')
            if line == '' then -- 处理空行
                goto continue
            end
            if line:sub(#line) == ',' then
                line = line:sub(1, #line - 1)
            end
            -- 分割行，1 = 属性名，2 = 属性默认值
            local sp_pos = line:find('=')
            local prop_name = line
            local prop_value = ''
            if sp_pos then
                prop_name = line:sub(1, sp_pos - 1)
                prop_value = line:sub(sp_pos + 1)
            end


            if nil == sp_pos then
                content = string.format("%s        self.%s = %s\n", content, prop_name, prop_name)
            else
                -- 需要处理布尔值，不能直接用or，否则不能正确赋值
                if type(script[prop_name]) == 'boolean' then
                    content = string.format("%s        self.%s = %s == nil and false or %s\n", content, prop_name,
                        prop_name,
                        prop_value)
                else
                    content = string.format("%s        self.%s = %s or %s\n", content, prop_name, prop_name, prop_value)
                end
            end


            -- 需要处理布尔值，不能直接用or，否则不能正确赋值
            if type(script[prop_name]) == 'boolean' then
                set_content = string.format("%s        self.%s = %s == nil and self.%s or %s\n", set_content, prop_name,
                    prop_name,
                    prop_name, prop_name)
            else
                set_content = string.format("%s        self.%s = %s or self.%s\n", set_content, prop_name, prop_name,
                    prop_name)
            end

            ---------------- 处理参数 ----------------
            param = string.format('%s, %s', param, prop_name)
        end
        ::continue::
    end
    param = string.sub(param, 3, #param)

    file:close()

    code_comp = code_comp:gsub('%[Name]', name)
    code_comp = code_comp:gsub('%[Param]', param)
    code_comp = code_comp:gsub('%[Prop]', content)
    code_comp = code_comp:gsub('%[SetData]', set_content)


    -- 缓存到GameEntity扩展列表
    entity_extention[name] = param

    file = io.open(generate_path .. name .. '.lua', 'w+')

    assert(file, "create file is nil")
    file:write(code_comp)
    file:close()


    print('----------------------')
end



---------------------------------------------------------------------------------------
-- 生成GameEntity代码
---------------------------------------------------------------------------------------
print("----------- 生成GameEntity代码 -----------------------------------------------")

local entity_path = "ECS\\Generated\\GameEntity.lua"

local code_head = [[
local GameEntity = class("GameEntity")

function GameEntity:ClearComponents()
[ClearCode]
end

]]


local code_body = [[

--========= [Name] ========================================================================
function GameEntity:Add[PName]([Param])
    if self:HasComponent(GameComponentLookUp.[Name]) == true then
        self:Update[PName]([Param])
        return
    end
    self.[PName] = Context:_GetComponent(GameComponentLookUp.[Name])
    self.[PName]:Init([Param])
    self:_OnAddComponent(self.[PName])
    Context:_OnAddComponent(self, self.[PName])
end

function GameEntity:Update[PName]([Param])
    if self:HasComponent(GameComponentLookUp.[Name]) == false then
        self:Add[PName]([Param])
        return
    end
    self.[PName]:SetData([Param])
    Context:_OnUpdateComponent(self, self.[PName])
end

function GameEntity:Remove[PName]()
    if self:HasComponent(GameComponentLookUp.[Name]) == false then return end
    Context:_OnRemoveComponent(self, self.[PName])
    self:_OnRemoveComponent(self.[PName])
    self.[PName] = nil
end

function GameEntity:Has[PName]()
    return self:HasComponent(GameComponentLookUp.[Name])
end
]]

local clear_builder = ''

for key, value in pairs(entity_extention) do
    local propery_name = key:gsub("Component", '')
    local code = code_body
    code = code:gsub('%[Param]', value)
    code = code:gsub('%[PName]', propery_name)
    code = code:gsub('%[Name]', key)
    code_head = code_head .. code

    clear_builder = clear_builder .. string.format("    self.%s = nil\n", propery_name)
end

code_head = code_head:gsub('%[ClearCode]', clear_builder)
code_head = code_head .. [[

return GameEntity
]]

print(code_head)

local entity_file = io.open(entity_path, "w+")
assert(entity_file, "entity_file file is nil")
entity_file:write(code_head)
entity_file:close()


---------------------------------------------------------------------------------------
-- 生成GameContext代码
---------------------------------------------------------------------------------------
print("----------- 生成GameContext代码 -----------------------------------------------")

local path_context = "ECS\\Generated\\GameContext.lua"
local code_context = [[
-------------------------------------------------------------------------------------------------
-- 自动生成，请勿改动
-------------------------------------------------------------------------------------------------

GameComponentScript = {
[REQ]
}

GameComponentLookUp = {
[LOK]
}

--- 组件匹配id，和GameComponentLookUp保持一致，主要是为了书写简洁
EMatcher = {
[MAC]
}
]]

local req = ''
local lok = ''
local mac = ''
local index = 1
for key, value in pairs(entity_extention) do
    req = req .. string.format("    [%d] = require('ECS.Generated.Components.Game%s'),\n", index, key)
    lok = lok .. string.format("    %s = %d,\n", key, index)
    mac = mac .. string.format("    %s = %d,\n", key:gsub('Component', ''), index)
    index = index + 1
end
code_context = code_context:gsub('%[REQ]', req)
code_context = code_context:gsub('%[LOK]', lok)
code_context = code_context:gsub('%[MAC]', mac)

print(code_context)

local context_file = io.open(path_context, "w+")
assert(context_file, "context_file file is nil")
context_file:write(code_context)
context_file:close()


print("----------- 代码生成完毕 ------------------------------------------------------")
