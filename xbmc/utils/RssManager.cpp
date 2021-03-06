/*
 *      Copyright (C) 2005-2013 Team XBMC
 *      http://xbmc.org
 *
 *  This Program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2, or (at your option)
 *  any later version.
 *
 *  This Program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with XBMC; see the file COPYING.  If not, see
 *  <http://www.gnu.org/licenses/>.
 *
 */

#include "RssManager.h"

#include <utility>

#include "addons/AddonInstaller.h"
#include "addons/AddonManager.h"
#include "filesystem/File.h"
#include "interfaces/builtins/Builtins.h"
#include "messaging/ApplicationMessenger.h"
#include "messaging/helpers/DialogHelper.h"
#include "profiles/ProfilesManager.h"
#include "settings/lib/Setting.h"
#include "settings/Settings.h"
#include "threads/SingleLock.h"
#include "utils/log.h"
#include "utils/RssReader.h"
#include "utils/StringUtils.h"
#include "utils/Variant.h"

using namespace XFILE;
using namespace KODI::MESSAGING;

using KODI::MESSAGING::HELPERS::DialogResponse;

CRssManager::CRssManager()
{
  m_bActive = false;
}

CRssManager::~CRssManager()
{
  Stop();
}

CRssManager& CRssManager::GetInstance()
{
  static CRssManager sRssManager;
  return sRssManager;
}

void CRssManager::OnSettingsLoaded()
{
  Load();
}

void CRssManager::OnSettingsUnloaded()
{
  Clear();
}

bool CRssManager::OnSettingChanging(const CSetting *setting)
{
  if (setting == NULL)
    return false;

  const std::string &settingId = setting->GetId();
  if (settingId == CSettings::SETTING_LOOKANDFEEL_RSSHOST ||
      settingId == CSettings::SETTING_LOOKANDFEEL_RSSINTERVAL ||
      settingId == CSettings::SETTING_LOOKANDFEEL_RSSRTL)
  {
    Reload();
  }
  return true;
}

void CRssManager::Start()
 {
   m_bActive = true;
}

void CRssManager::Stop()
{
  CSingleLock lock(m_critical);
  m_bActive = false;
}

bool CRssManager::Load()
{
  CSingleLock lock(m_critical);

  m_mapRssUrl.rtl = CSettings::GetInstance().GetBool(CSettings::SETTING_LOOKANDFEEL_RSSRTL);
  m_mapRssUrl.url = CSettings::GetInstance().GetString(CSettings::SETTING_LOOKANDFEEL_RSSHOST);
  m_mapRssUrl.interval = CSettings::GetInstance().GetInt(CSettings::SETTING_LOOKANDFEEL_RSSINTERVAL);
  return true;
}

bool CRssManager::Reload()
{
  Stop();
  if (!Load())
    return false;
  Start();

  return true;
}

void CRssManager::Clear()
{
  CSingleLock lock(m_critical);
  m_mapRssUrl = *new RssSet();
}
