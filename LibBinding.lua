---- LibBinding ---
assert(LibStub, "LibStub not found.");
local major, minor = "LibBinding", 1;

---@class LibBinding
local LibBinding = LibStub:NewLibrary(major, minor);

if not LibBinding then return end;

---@enum Binding
LibBinding.BINDING = {
  NONE = "None",
  SOULBOUND = "Soulbound",
  BOE = "BoE",
  BOU = "BoU",
  QUEST = "Quest",
  NOBANK = "NoBank",
  UNKNOWN = "Unknown",
  ACCOUNT = "Warbound",
  BNET = "BNet",
  WUE = "WuE",
}

---@enum BindingID -- note these are similar, but NOT the same as Enum.ItemBind
LibBinding.BINDINGID = {
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

---@class TradableMap
---@type table<BindingID|Binding|string, boolean>
LibBinding.TradableMap = {
  [LibBinding.BINDINGID.NONE] = true,
  [LibBinding.BINDING.NONE] = true,
  [""] = true,
  [LibBinding.BINDINGID.SOULBOUND] = false,
  [LibBinding.BINDING.SOULBOUND] = false,
  [ITEM_SOULBOUND] = false,
  [LibBinding.BINDINGID.BOE] = true,
  [LibBinding.BINDING.BOE] = true,
  [ITEM_BIND_ON_EQUIP] = true,
  [LibBinding.BINDINGID.BOU] = true,
  [LibBinding.BINDING.BOU] = true,
  [ITEM_BIND_ON_USE] = true,
  [LibBinding.BINDINGID.QUEST] = false,
  [LibBinding.BINDING.QUEST] = false,
  [ITEM_BIND_QUEST] = false,
  [LibBinding.BINDINGID.NOBANK] = false,
  [LibBinding.BINDING.NOBANK] = false,
  [LibBinding.BINDINGID.UNKNOWN] = false,
  [LibBinding.BINDING.UNKNOWN] = false,
  [ERROR_CAPS] = false,
  [LibBinding.BINDINGID.ACCOUNT] = false,
  [LibBinding.BINDING.ACCOUNT] = false,
  [ITEM_ACCOUNTBOUND] = false,
  [LibBinding.BINDINGID.BNET] = false,
  [LibBinding.BINDING.BNET] = false,
  [ITEM_BNETACCOUNTBOUND] = false,
  [LibBinding.BINDINGID.WUE] = false,
  [LibBinding.BINDING.WUE] = false,
  [ITEM_ACCOUNTBOUND_UNTIL_EQUIP] = false,
}

---@class BindingStringMAP
---@type table<Binding, BindingID>
LibBinding.BINDINGSTRINGMAP = {
  [LibBinding.BINDING.NONE] = LibBinding.BINDINGID.NONE,
  [LibBinding.BINDING.SOULBOUND] = LibBinding.BINDINGID.SOULBOUND,
  [LibBinding.BINDING.BOE] = LibBinding.BINDINGID.BOE,
  [LibBinding.BINDING.BOU] = LibBinding.BINDINGID.BOU,
  [LibBinding.BINDING.QUEST] = LibBinding.BINDINGID.QUEST,
  [LibBinding.BINDING.NOBANK] = LibBinding.BINDINGID.NOBANK,
  [LibBinding.BINDING.UNKNOWN] = LibBinding.BINDINGID.UNKNOWN,
  [LibBinding.BINDING.ACCOUNT] = LibBinding.BINDINGID.ACCOUNT,
  [LibBinding.BINDING.BNET] = LibBinding.BINDINGID.BNET,
  [LibBinding.BINDING.WUE] = LibBinding.BINDINGID.WUE,
}

---@enum BindingString
---@type table<BindingID, Binding>
LibBinding.BINDINGSTRING = {
 [LibBinding.BINDINGID.NONE] = LibBinding.BINDING.NONE,
 [LibBinding.BINDINGID.SOULBOUND] = LibBinding.BINDING.SOULBOUND,
 [LibBinding.BINDINGID.BOE] = LibBinding.BINDING.BOE,
 [LibBinding.BINDINGID.BOU] = LibBinding.BINDING.BOU,
 [LibBinding.BINDINGID.QUEST] = LibBinding.BINDING.QUEST,
 [LibBinding.BINDINGID.NOBANK] = LibBinding.BINDING.NOBANK,
 [LibBinding.BINDINGID.UNKNOWN] = LibBinding.BINDING.UNKNOWN,
 [LibBinding.BINDINGID.ACCOUNT] = LibBinding.BINDING.ACCOUNT,
 [LibBinding.BINDINGID.BNET] = LibBinding.BINDING.BNET,
 [LibBinding.BINDINGID.WUE] = LibBinding.BINDING.WUE,
}

---@enum GlobalString
---@type table<BindingID, string>
LibBinding.GLOBALSTRING = {
  [LibBinding.BINDINGID.NONE] = "",
  [LibBinding.BINDINGID.SOULBOUND] = ITEM_SOULBOUND,
  [LibBinding.BINDINGID.BOE] = ITEM_BIND_ON_EQUIP,
  [LibBinding.BINDINGID.BOU] = ITEM_BIND_ON_USE,
  [LibBinding.BINDINGID.QUEST] = ITEM_BIND_QUEST,
  [LibBinding.BINDINGID.NOBANK] = ERROR_CAPS,
  [LibBinding.BINDINGID.UNKNOWN] = ERROR_CAPS,
  [LibBinding.BINDINGID.ACCOUNT] = ITEM_ACCOUNTBOUND,
  [LibBinding.BINDINGID.BNET] = ITEM_BNETACCOUNTBOUND,
  [LibBinding.BINDINGID.WUE] = ITEM_ACCOUNTBOUND_UNTIL_EQUIP,
}

---@param itemLocation ItemLocationMixin
---@return BindingID
function LibBinding.FetchBindType(itemLocation)
  local bindType = nil -- force the assert
  local item = Item:CreateFromItemLocation(itemLocation)
  if item.IsItemDataCached then
    bindType,_,_,_ = select(14, C_Item.GetItemInfo(item:GetItemID()))
  end
    assert(bindType, "Uncached data")
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
function LibBinding.isNontradable(itemLocation)
  return C_Item.IsBound(itemLocation) or LibBinding.isWarboundUntilEquipped(itemLocation)
end

---@param itemLocation ItemLocationMixin
---@return boolean
function LibBinding.isTradable(itemLocation)
  local wue = false
  if ( C_Item.IsBoundToAccountUntilEquip and C_Item.IsBoundToAccountUntilEquip(itemLocation)) then
    wue = true
  end
  return not (wue or C_Item.IsBound(itemLocation))
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
  return (type == 2) and LibBinding.isTradable(itemLocation)
end

---@param itemLocation ItemLocationMixin
---@param bindType? Enum.ItemBind
---@return boolean
function LibBinding.isBindOnUse(itemLocation, bindType)
  local type = bindType or LibBinding.FetchBindType(itemLocation)
  return (type == 3) and LibBinding.isTradable(itemLocation)
end

---@param itemLocation ItemLocationMixin
---@param bindType? Enum.ItemBind
---@return boolean
function LibBinding.isSoulbound(itemLocation, bindType)
  local type = bindType or LibBinding.FetchBindType(itemLocation)
  return C_Item.IsBound(itemLocation)
    and not LibBinding.isQuestbound(itemLocation,type --[[@as Enum.ItemBind]])
    and not (C_Bank and C_Bank.IsItemAllowedInBankType and C_Bank.IsItemAllowedInBankType(Enum.BankType.Account, itemLocation))
end

---@param itemLocation ItemLocationMixin
---@return boolean
function LibBinding.isWarbound(itemLocation)
  local accountbankable = false
  if ( C_Bank and C_Bank.IsItemAllowedInBankType and C_Bank.IsItemAllowedInBankType(Enum.BankType.Account, itemLocation)) then
    accountbankable = true
  end
  return C_Item.IsBound(itemLocation) and accountbankable
end

---@param itemLocation ItemLocationMixin
---@return boolean
function LibBinding.isWarboundUntilEquipped(itemLocation)
  local wue = false
  if ( C_Item.IsBoundToAccountUntilEquip and C_Item.IsBoundToAccountUntilEquip(itemLocation)) then
    wue = true
  end
  return not C_Item.IsBound(itemLocation) and wue
end

---@param itemLocation ItemLocationMixin
---@param bindType Enum.ItemBind
---@return BindingID
function LibBinding.ParseBoundTypes(itemLocation, bindType)
  local type = LibBinding.BINDINGID.SOULBOUND  -- Assume Soulbound
  if C_Bank and C_Bank.IsItemAllowedInBankType(Enum.BankType.Account, itemLocation) then
    type = LibBinding.BINDINGID.ACCOUNT  -- Assign AccountBound
  end
  if bindType == 4 then
    type = LibBinding.BINDINGID.QUEST   -- Quest type overrides all other bindings
  end
  return type
end

---@param itemLocation ItemLocationMixin
---@param bindType Enum.ItemBind
---@return BindingID
function LibBinding.GetItemBinding(itemLocation, bindType)
  -- assume synthetictype passed correctly or default to a GetItemInfo lookup
  local synthetictype = bindType --[[@as BindingID]]

  if C_Item.IsBound(itemLocation) then  -- Types Soulbound(1), Quest(4), and Accountbound(7) should match
    synthetictype = LibBinding.ParseBoundTypes(itemLocation, synthetictype --[[@as Enum.ItemBind]])
  end

  if C_Item.IsBoundToAccountUntilEquip and C_Item.IsBoundToAccountUntilEquip(itemLocation) then
    synthetictype = LibBinding.BINDINGID.WUE   -- override Warbound BoEs from type BoE(2) to type WuE(9)
  end

  if LibBinding.isTradable (itemLocation) and C_Bank and C_Bank.IsItemAllowedInBankType and not C_Bank.IsItemAllowedInBankType(Enum.BankType.Account, itemLocation) then
    synthetictype = LibBinding.BINDINGID.NOBANK  -- this shouldn't happen, something has changed as of 11.0, only quest(4) and soulbound(1) items are blocked from account bank
  end

  return synthetictype -- types None(0), BoE(2), BoU(3) plus any types we don't see such as unused(6) or BNet(8)
end

---@param binding Binding|BindingID|string
---@return boolean
function LibBinding.isBindingTradable(binding) -- mostly here for future compat if Enum.ItemBind changes
  return LibBinding.TradableMap[binding]
end

---@param binding Binding|BindingID|string
---@return boolean
function LibBinding.isBindingNontradable(binding)
  return LibBinding.TradableMap[binding]
end
