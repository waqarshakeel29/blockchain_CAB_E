import 'dart:convert';

enum OrderStatus {
  notStarted, // scheduled but there is some time left
  findingDriver, // scheduled time has come, now finding a messenger
  findingDriverFailed, // finding failed
  driverOnWay, // finding success, messenger on the way
  driverReachedSource,
  driverReachedDestination,
  orderCompleted,
  orderCancelled,
}

class Order {
  int userOrderNo;
  String orderId;
  String messageDocId;
  bool isNow;
  OrderStatus status;
  String userUid;

  String driverId;
  double driverLat;
  double driverLng;

  double rating;
  String instruction;
  String ratingComment;
  double sourceLat;
  double sourceLng;
  String sourceLocationName;
  double destLat;
  double destlng;
  String destLocationName;
  int creationTime;
  int scheduledTime;
  int completedTime;
  double fare;
  bool isCatered;
  Order({
    this.userOrderNo,
    this.orderId,
    this.status,
    this.messageDocId,
    this.isNow,
    this.userUid,
    this.driverId,
    this.driverLat,
    this.driverLng,
    this.rating,
    this.instruction,
    this.ratingComment,
    this.sourceLat,
    this.sourceLng,
    this.sourceLocationName,
    this.destLat,
    this.destlng,
    this.destLocationName,
    this.creationTime,
    this.scheduledTime,
    this.completedTime,
    this.fare,
    this.isCatered,
  });

  Map<String, dynamic> toMap() {
    return {
      'userOrderNo': userOrderNo,
      'orderId': orderId,
      'orderStatus': status.index,
      'messageDocId': messageDocId,
      'isNow': isNow,
      'userUid': userUid,
      'driverId': driverId,
      'driverLat': driverLat,
      'driverLng': driverLng,
      'rating': rating,
      'instruction': instruction,
      'ratingComment': ratingComment,
      'sourceLat': sourceLat,
      'sourceLng': sourceLng,
      'sourceLocationName': sourceLocationName,
      'destLat': destLat,
      'destlng': destlng,
      'destLocationName': destLocationName,
      'creationTime': creationTime,
      'scheduledTime': scheduledTime,
      'completedTime': completedTime,
      'fare': fare,
      'isCatered': isCatered,
    };
  }

  factory Order.fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return Order(
      userOrderNo: map['userOrderNo'],
      orderId: map['orderId'],
      messageDocId: map['messageDocId'],
      isNow: map['isNow'],
      status: OrderStatus.values[map['orderStatus']],
      userUid: map['userUid'],
      driverId: map['driverId'],
      driverLat: map['driverLat'],
      driverLng: map['driverLng'],
      rating: map['rating'],
      instruction: map['instruction'],
      ratingComment: map['ratingComment'],
      sourceLat: map['sourceLat'],
      sourceLng: map['sourceLng'],
      sourceLocationName: map['sourceLocationName'],
      destLat: map['destLat'],
      destlng: map['destlng'],
      destLocationName: map['destLocationName'],
      creationTime: map['creationTime'],
      scheduledTime: map['scheduledTime'],
      completedTime: map['completedTime'],
      fare: map['fare'],
      isCatered: map['isCatered'],
    );
  }

  String toJson() => json.encode(toMap());

  factory Order.fromJson(String source) => Order.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Order(userOrderNo: $userOrderNo, orderId: $orderId, messageDocId: $messageDocId, isNow: $isNow, userUid: $userUid, driverId: $driverId, driverLat: $driverLat, driverLng: $driverLng, rating: $rating, instruction: $instruction, ratingComment: $ratingComment, sourceLat: $sourceLat, sourceLng: $sourceLng, sourceLocationName: $sourceLocationName, destLat: $destLat, destlng: $destlng, destLocationName: $destLocationName, creationTime: $creationTime, scheduledTime: $scheduledTime, completedTime: $completedTime, fare: $fare, isCatered: $isCatered)';
  }
}
