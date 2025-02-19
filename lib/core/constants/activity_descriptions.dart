class ActivityGameDescriptions {
  static const String activity1GameDescription = 'Møik sølkøtash';
  static const String activity2GameDescription = 'Muntsillan namtrikmai pør';
  static const String activity3GameDescription = 'Yunømar';
  static const String activity4GameDescription = 'Por implementar';
  static const String activity5GameDescription = 'Por implementar';
  static const String activity6GameDescription = 'Por implementar';

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