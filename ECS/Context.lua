-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
-- ECS Context ECS运行环境
-- Date - 2023-5-22
-- by - 良人
-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------

local Entity = require("ECS.Entity")
local Matcher = require("ECS.Matcher")
local Group = require("ECS.Group")

Context = {
    --- 实体对象回收池
    mEntityList_Recycle = {},
    --- 组件对象回收池
    mComponentList_Recycle = {},

    --- 实体列表
    mEntityList = {},
    --- 过滤组列表
    mGroupList = {},
    --[[
        mGroupList = {
            [onAdd:true] = {
                [onRemove:true] = { ... }
            },
            [onAdd:false] = {
                [onRemove:true] = { ... }
            }
        }
    ]]

    --- 实体UID，自增
    mEntityUID = 0,
    --- 匹配器实例，只需要一个
    mMatcher = Matcher.new()
}



-----------------------------------------------------------------------------------------------------------------------
-- Context API
-----------------------------------------------------------------------------------------------------------------------


function Context:Init()
    self.mGroupList[true][true] = {}
    self.mGroupList[true][false] = {}
    self.mGroupList[false][false] = {}
    self.mGroupList[false][true] = {}
end


---获取实体uid
---@return integer UID
function Context:_GetEntityUID()
    self.mEntityUID = self.mEntityUID + 1
    return self.mEntityUID
end

-----------------------------------------------------------------------------------------------------------------------
-- Entity 实体相关
-----------------------------------------------------------------------------------------------------------------------

--- 创建Entity
---@return Entity 实体
function Context:CreateEntity()
    local entity = nil
    if #self.mEntityList_Recycle > 0 then
        entity = table.remove(self.mEntityList_Recycle, #self.mEntityList_Recycle)
    else
        entity = Entity.new()
    end
    entity.mUID = self:_GetEntityUID()
    self.mEntityList[entity.mUID] = entity
    return entity
end

-----------------------------------------------------------------------------------------------------------------------
-- Component 组件相关
-----------------------------------------------------------------------------------------------------------------------

---获取组件实例，优先取回收的组件，不够时创建新的
---@param comp_name 组件名
---@return Component 组件实例
function Context:GetComponent(comp_name)
    if self.mComponentList_Recycle[comp_name] and
        #self.mComponentList_Recycle[comp_name] > 0 then
        return table.remove(self.mComponentList_Recycle[comp_name], 1)
    end
    return self.mComps["TestComponent"].new()
end

-----------------------------------------------------------------------------------------------------------------------
-- System 系统相关
-----------------------------------------------------------------------------------------------------------------------


-----------------------------------------------------------------------------------------------------------------------
-- Group 过滤组相关
-----------------------------------------------------------------------------------------------------------------------

function Context:Matcher()
    return self.mMatcher:Reset()
end

function Context:GetGroup(matcher)
    local group = nil
    
    if nil == group then
       group = Group.new(matcher)
       table.insert(self.mGroupList[group.mOnAdded][group.mOnRemoved], group)
    end

    return group
end
