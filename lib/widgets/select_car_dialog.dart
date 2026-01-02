import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

Future<String?> showSelectCarDialog({
  required BuildContext context,
  required List<String> carList,
}) {
  String tempSelectedCar = carList.first;
  final TextEditingController customCarController =
  TextEditingController();

  return showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          return AlertDialog(
            backgroundColor: const Color(0xFF0E2235),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              "Select Car",
              style: TextStyle(color: Colors.white),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: tempSelectedCar,
                    dropdownColor: const Color(0xFF07121E),
                    iconEnabledColor: Colors.white,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFF07121E),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    items: carList
                        .map(
                          (car) => DropdownMenuItem(
                        value: car,
                        child: Text(car),
                      ),
                    )
                        .toList(),
                    onChanged: (value) {
                      setDialogState(() {
                        tempSelectedCar = value!;
                      });
                    },
                  ),
                  if (tempSelectedCar == "Other") ...[
                    const SizedBox(height: 12),
                    TextField(
                      controller: customCarController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: "Enter car name",
                        hintStyle:
                        const TextStyle(color: Colors.white38),
                        filled: true,
                        fillColor: const Color(0xFF07121E),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text(
                  "Cancel",
                  style: TextStyle(color: Colors.white54),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  final finalCarName = tempSelectedCar == "Other"
                      ? customCarController.text.trim()
                      : tempSelectedCar;

                  if (finalCarName.isEmpty) {
                    Fluttertoast.showToast(
                      msg: "Please enter car name",
                    );
                    return;
                  }

                  Navigator.pop(dialogContext, finalCarName);
                },
                child: const Text("Save"),
              ),
            ],
          );
        },
      );
    },
  );
}
