class CollectStatus {
  final String estimated;
  final String exact;

  CollectStatus({required this.estimated,required  this.exact});

  factory CollectStatus.fromJson(Map<String, dynamic> parsedJson) {

      return CollectStatus(
        estimated: parsedJson['estimated']!=null&&parsedJson['estimated']!=''?parsedJson['estimated']:'0',
        exact: parsedJson['exact']!=null&&parsedJson['exact']!=''?parsedJson['exact']:'0',
      );
  }
  Map<String, dynamic> toJson() {


    return {
      'estimated' : estimated,
      'exact' : exact,
    };
  }
}
