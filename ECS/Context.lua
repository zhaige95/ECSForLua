local Entity = require("ECS.Entity")
local Matcher = require("ECS.Matcher")

Context = {
    mEntityList = {},
    mEntityList_Recycle = {},
    mComponentList_Recycle = {},
    mGroupList = {},
    mEntityUID = 0,
    mMatcher = Matcher.new()
}



-----------------------------------------------------------------------------------------------------------------------
-- Context API
-----------------------------------------------------------------------------------------------------------------------

---获取实体uid
---@return integer UID
function Context:GetEntityUID()
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
    entity.mUID = self:GetEntityUID()
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
    self.mMatcher:Reset()
end


function Context:GetGroup(matcher)
    
end












