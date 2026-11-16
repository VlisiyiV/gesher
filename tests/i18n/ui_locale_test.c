#include "../../compat/locale/ui_locale.h"
#include <assert.h>
int main(void) {
  assert(GesherUiMatch(L"he-IL-u-ca-hebrew,en-US") == GESHER_UI_HE);
  assert(GesherUiMatch(L" HE_il , en-US") == GESHER_UI_HE);
  assert(GesherUiMatch(L"de-DE,iw-IL,en-US") == GESHER_UI_HE);
  assert(GesherUiMatch(L"en-GB,he-IL") == GESHER_UI_EN);
  assert(GesherUiMatch(L"ar-SA,fr-FR") == GESHER_UI_EN);
  assert(GesherUiMatch(NULL) == GESHER_UI_EN);
  assert(GesherUiMatch(L"hebrew,xx") == GESHER_UI_EN);
  assert(GesherUiMatch(L"zh-CN,en-US") == GESHER_UI_ZH);
  assert(GesherUiMatch(L" ZH_hans_cn ") == GESHER_UI_ZH);
  assert(GesherUiMatch(L"ja-JP,zh-TW") == GESHER_UI_ZH);
  assert(GesherUiMatch(L"zhx,en-US") == GESHER_UI_EN);
  assert(GesherUiRtl(GESHER_UI_HE));
  assert(!GesherUiRtl(GESHER_UI_EN));
  assert(!GesherUiRtl(GESHER_UI_ZH));
  assert(wcscmp(GesherUiText(GESHER_UI_HE, "starting"), L"\u05de\u05e4\u05e2\u05d9\u05dc\u2026") == 0);
  assert(wcscmp(GesherUiText(GESHER_UI_ZH, "starting"), L"\u6b63\u5728\u542f\u52a8\u2026") == 0);
  SetEnvironmentVariableW(L"GESHER_LOCALES", L"de-DE,he-IL");
  assert(GesherUiCurrentLanguage() == GESHER_UI_HE);
  SetEnvironmentVariableW(L"GESHER_LOCALES", L"en-US,he-IL");
  assert(GesherUiCurrentLanguage() == GESHER_UI_EN);
  SetEnvironmentVariableW(L"GESHER_LOCALES", L"fr-FR");
  assert(GesherUiCurrentLanguage() == GESHER_UI_EN);
  SetEnvironmentVariableW(L"GESHER_LOCALES", NULL);
  enum GesherUiLanguage default_lang = GesherUiCurrentLanguage();
  assert(default_lang == GESHER_UI_HE || default_lang == GESHER_UI_EN || default_lang == GESHER_UI_ZH);
  return 0;
}
