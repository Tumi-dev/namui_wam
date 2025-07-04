class ActivityGameDescriptions {
  static const String activity1GameDescription = 'Mɵik sɵlkɵtash';
  static const String activity2GameDescription = 'Muntsikmeran namtrikmai pɵr';
  static const String activity3GameDescription = 'Nɵsik utɵwan';
  static const String activity4GameDescription = 'Anwan ashkun';
  static const String activity5GameDescription = 'Yunɵmar';
  static const String activity6GameDescription = 'Wammeran pɵrik';

  static String getDescriptionForActivity(int activityNumber) {
    switch (activityNumber) {
      case 1:
        return activity1GameDescription;
      case 2:
        return activity2GameDescription;
      case 3:
        return activity3GameDescription;
      case 4:
        return activity4GameDescription;
      case 5:
        return activity5GameDescription;
      case 6:
        return activity6GameDescription;
      default:
        return '';
    }
  }
}
