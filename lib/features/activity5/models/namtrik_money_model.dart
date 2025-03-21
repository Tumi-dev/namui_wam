class NamtrikMoneyModel {
  final int number;
  final List<String> moneyImages;
  final String moneyNamtrik;
  final String audiosNamtrik;

  NamtrikMoneyModel({
    required this.number,
    required this.moneyImages,
    required this.moneyNamtrik,
    required this.audiosNamtrik,
  });

  factory NamtrikMoneyModel.fromJson(Map<String, dynamic> json) {
    return NamtrikMoneyModel(
      number: json['number'],
      moneyImages: List<String>.from(json['money_images']),
      moneyNamtrik: json['money_namtrik'],
      audiosNamtrik: json['audios_namtrik'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'money_images': moneyImages,
      'money_namtrik': moneyNamtrik,
      'audios_namtrik': audiosNamtrik,
    };
  }
}