import 'package:carbgremover/models/BackgroundItem.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BackgroundSelector extends StatefulWidget {
  const BackgroundSelector({super.key});

  @override
  State<BackgroundSelector> createState() => _BackgroundSelectorState();
}

class _BackgroundSelectorState extends State<BackgroundSelector> {
  int _selectedIndex = 0;

  final List<BackgroundPreset> backgroundPresets = [
    BackgroundPreset(
      title: "Studio",
      imagePath: "assets/backgrounds/studio.jpg",
    ),
    BackgroundPreset(
      title: "Outdoor",
      imagePath: "assets/backgrounds/outdoor.jpg",
    ),
    BackgroundPreset(
      title: "Luxury",
      imagePath: "assets/backgrounds/premium.jpg",
    ),
    BackgroundPreset(
      title: "Premium",
      imagePath: "assets/backgrounds/premium.jpg",
    ),
  ];


  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Background",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 12),

        SizedBox(
          height: 90,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: backgroundPresets.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final preset = backgroundPresets[index];
              final isSelected = index == _selectedIndex;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
                child: Container(
                  width: 90,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF29B6F6)
                          : Colors.white.withOpacity(0.15),
                      width: isSelected ? 2 : 1,
                    ),
                    image: DecorationImage(
                      image: AssetImage(preset.imagePath), // 👈 IMAGE HERE
                      fit: BoxFit.cover,
                    ),
                  ),

                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      margin: const EdgeInsets.all(6),
                      padding: const EdgeInsets.symmetric(
                        vertical: 4,
                        horizontal: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.45),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        preset.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
