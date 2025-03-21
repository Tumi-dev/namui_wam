class NamtrikArticleModel {
  final int number;
  final String imageArticle;
  final int priceArticle;
  final String namePriceNamtrik;
  final List<int> numberMoneyImages;

  NamtrikArticleModel({
    required this.number,
    required this.imageArticle,
    required this.priceArticle,
    required this.namePriceNamtrik,
    required this.numberMoneyImages,
  });

  factory NamtrikArticleModel.fromJson(Map<String, dynamic> json) {
    return NamtrikArticleModel(
      number: json['number'],
      imageArticle: json['image_articles'],
      priceArticle: json['price_articles'],
      namePriceNamtrik: json['name_price_namtrik'],
      numberMoneyImages: List<int>.from(json['number_money_images']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'image_articles': imageArticle,
      'price_articles': priceArticle,
      'name_price_namtrik': namePriceNamtrik,
      'number_money_images': numberMoneyImages,
    };
  }

  @override
  String toString() {
    return 'NamtrikArticleModel{number: $number, imageArticle: $imageArticle, priceArticle: $priceArticle, namePriceNamtrik: $namePriceNamtrik}';
  }
}
