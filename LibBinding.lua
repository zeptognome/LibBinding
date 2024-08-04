--[[ 
LibBinding
Copyright (c) 2024 zeptognome
Functions to determine current binding or items 
Please note bindType=2
]]--

assert(LibStub, "LibStub not found.");
local major, minor = "LibBinding", 1;

--- @class LibBinding
---@field ItemBinding BindingType 
local lib = LibStub:NewLibrary(major, minor);

if not lib then return end;

---@enum BindingType
local BindingType = {
  NONE = 0,
  ACCOUNT = 1,
  SOULBOUND = 2,
  QUEST = 3,
  BOE = 4,
  BOU = 5,
  WUE = 6,
  UNKNOWN = 99
}

---@enum BindingString
local BindingString = {
 [BindingType.NONE] = "None",
 [BindingType.ACCOUNT] = "Warbound",
 [BindingType.SOULBOUND] = "Soulbound",
 [BindingType.QUEST] = "Quest",
 [BindingType.BOE] = "BoE",
 [BindingType.BOU] = "BoU",
 [BindingType.WUE] = "WuE",
 [BindingType.UNKNOWN] = "Unknown",
}

---@func LibBinding.isNonBinding(itemLocation)
---@param itemLocation ItemLocationMixin
---@return boolean
function lib.isNonbinding(itemLocation)
  local bindType,_,_,_ = select(14,C_Item.GetItemInfo(C_Item.GetItemID(itemLocation)))
  return (bindType == 0)
end

---@func LibBinding.isBound(itemLocation)
---@param itemLocation ItemLocationMixin
---@return boolean
function lib.isBound(itemLocation)
  return C_Item.IsBound(itemLocation) or C_Item.IsBoundToAccountUntilEquip(itemLocation)
end

---@func LibBinding.isUnbound(itemLocation)
---@param itemLocation ItemLocationMixin
---@return boolean
function lib.isUnbound(itemLocation)
  return not C_Item.IsBound(itemLocation) and not C_Item.IsBoundToAccountUntilEquip(itemLocation)
end

---@func LibBinding.Questbound(itemLocation)
---@param itemLocation ItemLocationMixin
---@return boolean
function lib.isQuestbound(itemLocation)
  local bindType,_,_,_ = select(14,C_Item.GetItemInfo(C_Item.GetItemID(itemLocation)))
  return (bindType == 4)
end

---@func LibBinding.isBindOnEquip(itemLocation)
---@param itemLocation ItemLocationMixin
---@return boolean
function lib.isBindOnEquip(itemLocation)
  local bindType,_,_,_ = select(14,C_Item.GetItemInfo(C_Item.GetItemID(itemLocation)))
  return not lib.isBound(itemLocation) and (bindType == 2)
end

---@func LibBinding.isBindOnUse(itemLocation)
---@param itemLocation ItemLocationMixin
---@return boolean
function lib.isBindOnUse(itemLocation)
  local bindType,_,_,_ = select(14,C_Item.GetItemInfo(C_Item.GetItemID(itemLocation)))
  return not lib.isBound(itemLocation) and (bindType == 3)
end

---@func LibBinding.isSoulbound(itemLocation)
---@param itemLocation ItemLocationMixin
---@return boolean
function lib.isSoulbound(itemLocation)
  return C_Item.IsBound(itemLocation) and not C_Bank.IsItemAllowedInBankType(Enum.BankType.Account, itemLocation)
end

---@func LibBinding.isWarbound(itemLocation)
---@param itemLocation ItemLocationMixin
---@return boolean
function lib.isWarbound(itemLocation)
  return C_Item.IsBound(itemLocation) and C_Bank.IsItemAllowedInBankType(Enum.BankType.Account, itemLocation)
end

---@func LibBinding.isWarboundUntilEquipped(itemLocation)
---@param itemLocation ItemLocationMixin
---@return boolean
function lib.isWarboundUntilEquipped(itemLocation)
  return not C_Item.IsBound(itemLocation) and C_Item.IsBoundToAccountUntilEquip(itemLocation)
end

---@func LibBinding.GetItemBinding(itemLocation)
---@param itemLocation ItemLocationMixin
---@return BindingString
function lib.GetItemBinding(itemLocation)
  if not C_Item.IsItemDataCached(itemLocation) then
    print ("LibBindings request on unloaded item")
    return BindingString[BindingType.UNKNOWN]
  end

  local bindType,_,_,_ = select(14,C_Item.GetItemInfo(C_Item.GetItemID(itemLocation)))
  if bindType == 0 then
    return BindingString[BindingType.NONE]
  end

  if bindType == 4 then
    return BindingString[BindingType.QUEST]
  end

  local isbound = C_Item.IsBound(itemLocation)
  local warbank = C_Bank.IsItemAllowedInBankType(Enum.BankType.Account, itemLocation)

  if isbound and warbank then
    return BindingString[BindingType.ACCOUNT]
  elseif isbound and not warbank then
    return BindingString[BindingType.SOULBOUND]
  end

  if not isbound and not warbank then
    return BindingString[BindingType.UNKNOWN]
  end

  if C_Item.IsBoundToAccountUntilEquip(itemLocation) then
    return BindingString[BindingType.WUE]
  end

  if bindType == 2 then
    return BindingString[BindingType.BOE]
  end

  if bindType == 3 then
    return BindingString[BindingType.BOU]
  end

 return BindingString[BindingType.UNKNOWN]
end

--[[
local bindType,_,_,_ = select(14,C_Item.GetItemInfo(C_Item.GetItemID(loc)))
local isbound = C_Item.IsBound(loc)
local warbank = C_Bank.IsItemAllowedInBankType(Enum.BankType.Account, loc)
local bonding = nil

  if warbank and bagbind then
     binding = "1, Account"
  elseif warbank and not bagbind and wue then
     binding = "9, Warbound until Equipped"
  elseif warbank and not bagbind and not wue then
     binding = "7, BindOnEquip"
  elseif not warbank and bagbind then
     binding = "3, Soulbound"
  end
end

name = C_Item.GetItemName(loc)
print ("")
print (name, C_Item.GetItemID(loc))
print ("C_Item.GetitemInfo bindType:",bindType, bindenum[bindType])
print ("C_Item.WuE:",wue)
print ("C_Item.isBound:",isbound)
print ("ContainerItemInfo.isBound:",bagbind)
print ("Warbank:", warbank)
print ("Tooltip leftText:",leftText)
print ("")
print ("Tooltip bonding:",bonding, TTItemBond[bonding])
print ("Calc Binding:   ",binding)
]]--