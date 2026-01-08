class CarPose {
  final String name;
  final String guideImage;

  const CarPose({
    required this.name,
    required this.guideImage,
  });
}


final List<CarPose> poses = [

  CarPose(name: "Front", guideImage: "assets/images/front.png"),
  CarPose(name: "Front Left", guideImage: "assets/images/frontLeft.png"),
  CarPose(name: "Front Right", guideImage: "assets/images/frontRight.png"),
  CarPose(name: "Left Side", guideImage: "assets/images/left_side.png"),
  CarPose(name: "Right Side", guideImage: "assets/images/rightSide.png"),
  CarPose(name: "Back Left", guideImage: "assets/images/backLeft.png"),
  CarPose(name: "BACK", guideImage: "assets/images/back.png"),
  CarPose(name: "Back Right", guideImage: "assets/images/backRight.png"),
  CarPose(name: "Interior Dashboard", guideImage: "assets/images/dashboard.png"),

];