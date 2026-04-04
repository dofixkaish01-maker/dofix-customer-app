import 'package:flutter/material.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xE22178A8),
        title: const Text("Mahadev"), // Dynamic future me hoga
      ),

      body: Column(
        children: [

          /// TOP PROFILE SECTION
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [

                /// PROFILE IMAGE
                const CircleAvatar(
                  radius: 35,
                  backgroundColor: Color(0xFF72BEE8),
                  child: Icon(Icons.person, size: 30,color: Color(0xFF000000),),
                ),

                const SizedBox(height: 10),

                /// NAME
                const Text(
                  "Mahadev",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                /// RATING
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    5,
                        (index) => const Icon(
                      Icons.star,
                      size: 18,
                      color: Colors.orange,
                    ),
                  ),
                ),

                const SizedBox(height: 4),

                const Text(
                  "5.0 • 12 reviews",
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          /// REVIEWS TITLE
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "User Reviews",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          /// STATIC REVIEW LIST
          Expanded(
            child: ListView.builder(
              itemCount: 5,
              itemBuilder: (context, index) {
                return _reviewCard();
              },
            ),
          ),
        ],
      ),
    );
  }

  /// UPDATED STATIC REVIEW CARD
  Widget _reviewCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// 🔹 SERVICE NAME + RATING
          Row(
            children: [
              const Expanded(
                child: Text(
                  "AC Repair Service",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              Row(
                children: List.generate(
                  5,
                      (index) => const Icon(
                    Icons.star,
                    size: 14,
                    color: Colors.orange,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 4),

          /// DATE
          const Text(
            "12 Mar 2026",
            style: TextStyle(fontSize: 11, color: Colors.grey),
          ),

          const SizedBox(height: 6),

          /// COMMENT
          const Text(
            "Great service! Very professional and on time.",
            style: TextStyle(fontSize: 13),
          ),

          const SizedBox(height: 8),

          ///  STATIC REVIEW IMAGES
          SizedBox(
            height: 70,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [

                _imageItem("https://via.placeholder.com/150"),
                _imageItem("https://via.placeholder.com/150/0000FF"),
                _imageItem("https://via.placeholder.com/150/FF0000"),

              ],
            ),
          ),

          const SizedBox(height: 8),

          Divider(color: Colors.grey.shade300, thickness: 0.6),
        ],
      ),
    );
  }}
Widget _imageItem(String url) {
  return Container(
    margin: const EdgeInsets.only(right: 8),
    width: 70,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(8),
      color: Colors.grey.shade200,
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        url,
        fit: BoxFit.cover,
      ),
    ),
  );
}