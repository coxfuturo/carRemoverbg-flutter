class ProcessingStep {
  final String label;
  final int duration;

  ProcessingStep({
    required this.label,
    required this.duration,
  });
}


final List<ProcessingStep> processingSteps = [
  ProcessingStep(label: "Uploading", duration: 1200),
  ProcessingStep(label: "Segmentation", duration: 1500),
  ProcessingStep(label: "Enhancement", duration: 1800),
  ProcessingStep(label: "Compositing", duration: 1400),
  ProcessingStep(label: "Finalizing", duration: 1000),
];


