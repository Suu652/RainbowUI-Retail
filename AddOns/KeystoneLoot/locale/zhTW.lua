if (GetLocale() ~= 'zhTW') then
    return;
end

local AddonName, KeystoneLoot = ...;
local Translate = KeystoneLoot.Translate;


Translate['Left click: Open overview'] = '點一下查詢裝備';
Translate['Right click: Open settings'] = '右鍵: 設定選項';
Translate['Enable Minimap Button'] = '啟用小地圖按鈕';
Translate['Enable Loot Reminder'] = '啟用戰利品提醒';
Translate['Favorites Show All Specializations'] = '最愛顯示所有專精';
Translate['%s (%s Season %d)'] = '%s（%s 第 %d 賽季）';
Translate['Veteran'] = '精兵';    -- 探險者 Explorer 冒險者 Adventurer
Translate['Champion'] = '勇士';
Translate['Hero'] = '英雄';
Translate['Myth'] = '史詩';
Translate['Revival Catalyst'] = '重生育籃';
Translate['Correct loot specialization set?'] = '是否有正確設定戰利品拾取專精?';
Translate['Show Item Level In Keystone Tooltip'] = '在鑰石的浮動提示中顯示物品等級';
Translate['Highlighting'] = '顯著標示';
Translate['No Stats'] = '沒有屬性';
Translate['The favorites are ready to share:'] = '最愛已準備好分享:';
Translate['Paste an import string to import favorites:'] = '貼上匯入字串來匯入最愛:';
Translate['Overwrite'] = '取代';
Translate['Successfully imported %d |4item:items;.'] = '已成功匯入 %d 個物品。';
Translate['Invalid import string.'] = '無效的匯入字串。';
