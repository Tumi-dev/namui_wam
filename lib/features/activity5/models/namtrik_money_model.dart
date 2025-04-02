class NamtrikMoneyModel {
  final int number;
  final List<String> moneyImages;
  final String moneyNamtrik;
  final int valueMoney;
  final String audiosNamtrik;

  NamtrikMoneyModel({
    required this.number,
    required this.moneyImages,
    required this.moneyNamtrik,
    required this.valueMoney,
    required this.audiosNamtrik,
  });

  factory NamtrikMoneyModel.fromJson(Map<String, dynamic> json) {
    return NamtrikMoneyModel(
      number: json['number'],
      moneyImages: List<String>.from(json['money_images']),
      moneyNamtrik: json['money_namtrik'],
      valueMoney: json['value_money'],
      audiosNamtrik: json['audios_namtrik'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'money_images': moneyImages,
      'money_namtrik': moneyNamtrik,
      'value_money': valueMoney,
      'audios_namtrik': audiosNamtrik,
    };
  }
}