-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
-- 过滤组
-- Date - 2023-5-22
-- by - 良人
-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------

local Group = class("Group")

function Group:ctor(id, matcher)
    self:Reset()

    self.mAdded = matcher.mAdded
    self.mRemoved = matcher.mRemoved
    self.mAnyMode = matcher.mAnyMode

    for key, value in pairs(matcher.mAllOfContent) do
        self.mAllOfIndexer[value] = true
        table.insert(self.mAllOfContent, value)
    end
    for key, value in pairs(matcher.mNoneOfContent) do
        self.mNoneOfIndexer[value] = true
        table.insert(self.mNoneOfContent, value)
    end
    self.mID = id
end

function Group:OnDispose()

end

function Group:Reset()
    self.mAllOfContent = {}
    self.mNoneOfContent = {}

    self.mAllOfIndexer = {}
    self.mNoneOfIndexer = {}

    self.mAdded = false
    self.mRemoved = false
    self.mAnyMode = false

    self.mEntityIndexer = {}
end

function Group:GetEntities()
    for key, value in pairs(self.mEntityIndexer) do
        print("group entity ", key)
    end
end

-----------------------------------------------------------------------------------------------------------------------
-- Group 私有方法
-----------------------------------------------------------------------------------------------------------------------

function Group:_OnAddComponent(e, comp_id)
    if self:_MatchEntity(e) then
        self.mEntityIndexer[e.mUID] = true
    end
end

function Group:_OnRemoveComponent(e, comp_id)
    if self.mRemoved == true then
        if self:_MatchEntity(e) then
            self.mEntityIndexer[e.mUID] = true
        end
    else
        self.mEntityIndexer[e.mUID] = nil
    end
end

function Group:_Match(matcher)
    if self.mAdded ~= matcher.mAdded or
        self.mRemoved ~= matcher.mRemoved or
        self.mAnyMode ~= matcher.mAnyMode
    then
        return false
    end
    if #matcher.mAllOfContent ~= #self.mAllOfContent or #matcher.mNoneOfContent ~= #self.mNoneOfContent then
        return false
    end
    for _, value in pairs(matcher.mAllOfContent) do
        if not self.mAllOfIndexer[value] then
            return false
        end
    end
    for _, value in pairs(matcher.mNoneOfContent) do
        if not self.mNoneOfIndexer[value] then
            return false
        end
    end
    return true
end

function Group:_MatchEntity(e)
    for _, id in pairs(self.mAllOfContent) do
        if e:HasComponent(id) == false then
            return false
        end
    end
    for _, id in pairs(self.mNoneOfContent) do
        if e:HasComponent(id) == true then
            return false
        end
    end
    return true
end

return Group
