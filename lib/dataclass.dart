enum CarPose {
  front,
  back,
  unknown,
}


const allowedCarLabels = [
  "car",
  "vehicle",
  "automobile",
];

const rejectedViewLabels = [
  "wheel",
  "tire",
  "door",
  "side mirror",
  "window",
  "dashboard",
  "steering wheel",
  "interior",
];

const frontHints = [
  "headlight",
  "grille",
  "license plate",
  "bumper",
];

const backHints = [
  "taillight",
  "trunk",
  "rear",
  "bumper",
];
