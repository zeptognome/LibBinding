--[[ 
LibBinding
Copyright (c) 2024 zeptognome
Functions to determine current binding of items 
]]--

assert(LibStub, "LibStub not found.");
local major, minor = "LibBinding", 1;

---@class LibBinding
local LibBinding = LibStub:NewLibrary(major, minor);

if not LibBinding then return end;

---@enum BindingType -- note these are similar, but NOT the same as Enum.ItemBind
LibBinding.BindingType = {
  NONE = 0,
  SOULBOUND = 1,
  BOE = 2,
  BOU = 3,
  QUEST = 4,
  NOBANK = 5,
  UNKNOWN = 6,
  ACCOUNT = 7,
  BNET = 8,
  WUE = 9,
}

---@enum BindingString
LibBinding.BindingString = {
 [LibBinding.BindingType.NONE] = "None",
 [LibBinding.BindingType.SOULBOUND] = "Soulbound",
 [LibBinding.BindingType.BOE] = "BoE",
 [LibBinding.BindingType.BOU] = "BoU",
 [LibBinding.BindingType.QUEST] = "Quest",
 [LibBinding.BindingType.NOBANK] = "NoBank",
 [LibBinding.BindingType.UNKNOWN] = "Unknown",
 [LibBinding.BindingType.ACCOUNT] = "Warbound",
 [LibBinding.BindingType.BNET] = "BNet",
 [LibBinding.BindingType.WUE] = "WuE",
}

---@enum GlobalString
LibBinding.GlobalString = {
  [LibBinding.BindingType.NONE] = "",
  [LibBinding.BindingType.SOULBOUND] = ITEM_SOULBOUND,
  [LibBinding.BindingType.BOE] = ITEM_BIND_ON_EQUIP,
  [LibBinding.BindingType.BOU] = ITEM_BIND_ON_USE,
  [LibBinding.BindingType.QUEST] = ITEM_BIND_QUEST,
  [LibBinding.BindingType.NOBANK] = ERROR_CAPS,
  [LibBinding.BindingType.UNKNOWN] = ERROR_CAPS,
  [LibBinding.BindingType.ACCOUNT] = ITEM_ACCOUNTBOUND,
  [LibBinding.BindingType.BNET] = ITEM_BNETACCOUNTBOUND,
  [LibBinding.BindingType.WUE] = ITEM_ACCOUNTBOUND_UNTIL_EQUIP,
}

---@param itemLocation ItemLocationMixin
---@return Enum.ItemBind
function LibBinding.FetchBindType(itemLocation)
  local bindType
  local item = Item:CreateFromItemLocation(itemLocation)
  local itemCallback = function()
    bindType,_,_,_ = select(14, C_Item.GetItemInfo(item:GetItemID()))
  end
  item:ContinueOnItemLoad(itemCallback)
  return bindType
end

---@param itemLocation ItemLocationMixin
---@param bindType? Enum.ItemBind
---@return boolean
function LibBinding.isNonbinding(itemLocation, bindType)
  local type = bindType or LibBinding.FetchBindType(itemLocation)
  return (type == 0)
end

---@param itemLocation ItemLocationMixin
---@return boolean
function LibBinding.isUntradable(itemLocation)
  return C_Item.IsBound(itemLocation) or C_Item.IsBoundToAccountUntilEquip(itemLocation)
end

---@param itemLocation ItemLocationMixin
---@return boolean
function LibBinding.isTradeable(itemLocation)
  return not C_Item.IsBound(itemLocation) and not C_Item.IsBoundToAccountUntilEquip(itemLocation)
end

---@param itemLocation ItemLocationMixin
---@param bindType? Enum.ItemBind
---@return boolean
function LibBinding.isQuestbound(itemLocation,bindType)
  local type = bindType or LibBinding.FetchBindType(itemLocation)
  return (type == 4)
end

---@param itemLocation ItemLocationMixin
---@param bindType? Enum.ItemBind
---@return boolean
function LibBinding.isBindOnEquip(itemLocation,bindType)
  local type = bindType or LibBinding.FetchBindType(itemLocation)
  return (type == 2) and LibBinding.isTradeable(itemLocation)
end

---@param itemLocation ItemLocationMixin
---@param bindType? Enum.ItemBind
---@return boolean
function LibBinding.isBindOnUse(itemLocation, bindType)
  local type = bindType or LibBinding.FetchBindType(itemLocation)
  return (type == 3) and LibBinding.isTradeable(itemLocation)
end

---@param itemLocation ItemLocationMixin
---@param bindType? Enum.ItemBind
---@return boolean
function LibBinding.isSoulbound(itemLocation, bindType)
  local type = bindType or LibBinding.FetchBindType(itemLocation)
  return C_Item.IsBound(itemLocation)
    and not LibBinding.isQuestbound(itemLocation,type)
    and not C_Bank.IsItemAllowedInBankType(Enum.BankType.Account, itemLocation)
end

---@param itemLocation ItemLocationMixin
---@return boolean
function LibBinding.isWarbound(itemLocation)
  return C_Item.IsBound(itemLocation) and C_Bank.IsItemAllowedInBankType(Enum.BankType.Account, itemLocation)
end

---@param itemLocation ItemLocationMixin
---@return boolean
function LibBinding.isWarboundUntilEquipped(itemLocation)
  return C_Item.IsBoundToAccountUntilEquip(itemLocation) and not C_Item.IsBound(itemLocation)
end

---@param itemLocation ItemLocationMixin
---@param bindType? Enum.ItemBind
---@return BindingType
function LibBinding.ParseBoundTypes(itemLocation, bindType)
  local type = 1  -- Assume Soulbound
  if C_Bank.IsItemAllowedInBankType(Enum.BankType.Account, itemLocation) then
    type = 7  -- Assign AccountBound
  end
  if bindType == 4 then
    type = 4   -- Quest type overrides all other bindings
  end
  return type
end

---@param itemLocation ItemLocationMixin
---@param bindType? Enum.ItemBind
---@return BindingType
function LibBinding.GetItemBinding(itemLocation, bindType)
  -- assume synthetictype passed correctly or default to a GetItemInfo lookup
  local synthetictype = bindType or LibBinding.FetchBindType(itemLocation) --[[@as BindingType]]

  if C_Item.IsBound(itemLocation) then  -- Types Soulbound(1), Quest(4), and Accountbound(7) should match
    synthetictype = LibBinding.ParseBoundTypes(itemLocation, synthetictype)
  end

  if C_Item.IsBoundToAccountUntilEquip(itemLocation) then
    synthetictype = 9   -- override Warbound BoEs from type BoE(2) to type WuE(9)
  end

  if not C_Bank.IsItemAllowedInBankType(Enum.BankType.Account, itemLocation) then
    synthetictype = 5  -- this shouldn't happen, something has changed as of 11.0, only quest(4) and soulbound(1) items are blocked from account bank
  end

  return LibBinding.BindingType[synthetictype] -- types None(0), BoE(2), BoU(3) plus any types we don't see such as unused(6) or BNet(8)
end
