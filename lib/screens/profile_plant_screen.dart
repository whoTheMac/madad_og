import 'package:flutter/material.dart';

class ProfilePlantScreen extends StatefulWidget {
  final int waterDrops;
  final VoidCallback onWaterPlant;

  const ProfilePlantScreen({super.key, required this.waterDrops, required this.onWaterPlant});

  @override
  State<ProfilePlantScreen> createState() => _ProfilePlantScreenState();
}

class _ProfilePlantScreenState extends State<ProfilePlantScreen> {
  int plantLevel = 1;

  void handleWatering() {
    if (widget.waterDrops > 0) {
      widget.onWaterPlant();
      setState(() {
        if (plantLevel < 5) plantLevel++;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Out of Water Drops! Defeat more monsters in Exam Prep to get more.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Virtual Plant Garden'), backgroundColor: Colors.green, foregroundColor: Colors.white),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Water drop balance counter
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.water_drop, color: Colors.blue, size: 28),
                  const SizedBox(width: 8),
                  Text('Water Drops: ${widget.waterDrops}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 40),

              // Gorgeous Slubber Plant Visual Representation
              Container(
                height: 220,
                width: 220,
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.green, width: 4),
                ),
                child: Center(
                  child: Text(
                    plantLevel == 1 ? '🌱' : plantLevel == 2 ? '🌿' : plantLevel == 3 ? '🪴' : plantLevel == 4 ? '🌳' : '🌺✨',
                    style: const TextStyle(fontSize: 80),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                plantLevel == 5 ? 'Your Slubber is fully bloomed & gorgeous!' : 'Slubber Growth Level: $plantLevel / 5',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.green),
              ),
              const SizedBox(height: 40),

              // Water Plant Button
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                onPressed: handleWatering,
                icon: const Icon(Icons.water_drop),
                label: const Text('Water Plant (-1 Drop)', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}