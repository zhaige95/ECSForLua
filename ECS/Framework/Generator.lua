--============================================================================================
-- ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓

local process = {
    TestComponent = "ECS\\Game\\Test\\TestComponent.lua",
    MoveComponent = "ECS\\Game\\Move\\MoveComponent.lua",

}


-- ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑
--============================================================================================

require("Core.functions")
local generate_path = 'ECS\\Generated\\Components\\Game'

local code_template = [[
    local _Base = require('ECS.Framework.Component')
    local %s = class('%s', _Base)

    function %s:Init(%s)
%s
    end

    return %s
]]

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
    local comp = path:gsub('\\', '.')
    comp = comp:gsub('.lua', '')
    local script = require(comp)

    local file = io.open(path, "r")
    assert(file, "read file is nil")

    entity_extention[name] = {}

    ---------------- 处理参数 ----------------
    local param = ''
    for key, value in pairs(script) do
        param = string.format('%s, %s', param, key)
    end
    param = string.sub(param, 3, #param)

    ---------------- 处理属性字段 ----------------
    local content = ''
    local index = 0
    local line = ''
    for r in file:lines() do
        index = index + 1
        if index >= 2 then
            if r == '}' then
                break
            end
            line = r
            line = line:gsub(' ', '')
            line = line:gsub('\n', '')
            if line:sub(#line) == ',' then
                line = line:sub(1, #line - 1)
            end
            -- 分割行，1 = 属性名，2 = 属性默认值
            local sp = split(line, '=')


            if #sp == 1 then
                content = string.format("%s        self.%s = %s\n", content, sp[1], sp[1])
            elseif #sp == 2 then
                -- 需要处理布尔值，不能直接用or，否则不能正确赋值
                if type(script[sp[1]]) == 'boolean' then
                    content = string.format("%s        self.%s = %s == nil and false or %s\n", content, sp[1], sp[1], sp[2])
                else
                    content = string.format("%s        self.%s = %s or %s\n", content, sp[1], sp[1], sp[2])
                end
            end
        end
    end

    file:close()

    local code = string.format(code_template, name, name, name, param, content, name)
    print(code)

    -- 缓存到GameEntity扩展列表
    entity_extention[name] = param

    file = io.open(generate_path .. name .. '.lua', 'w+')

    assert(file, "create file is nil")
    file:write(code)
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
        -- TODO 已存在组件触发replace
        return
    end
    self.[PName] = Context:_GetComponent(GameComponentLookUp.[Name])
    self.[PName]:Init([Param])
    self:_OnAddComponent(self.[PName])
    Context:_OnAddComponent(self, self.[PName])
end

function GameEntity:Remove[PName]()
    if self:HasComponent(GameComponentLookUp.[Name]) == false then return end
    self:_OnRemoveComponent(self.[PName])
    Context:_OnRemoveComponent(self, self.[PName])
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
entity_file:write(code_head)
entity_file:close()









print("----------- 代码生成完毕 ------------------------------------------------------")



