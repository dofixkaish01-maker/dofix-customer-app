import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const Color primaryColor = Color(0xff227fa8);

class PartnerFaqScreen extends StatefulWidget {
  const PartnerFaqScreen({super.key});

  @override
  State<PartnerFaqScreen> createState() => _PartnerFaqScreenState();
}

class _PartnerFaqScreenState extends State<PartnerFaqScreen> {
  final TextEditingController _searchController = TextEditingController();

  int selectedType = 0; // 0 = General, 1 = Payments
  String _searchText = "";

  final List<FaqItem> generalFaq = [
    FaqItem(
      question: "Dofix kya hai?",
      answer: "Dofix ek organized home maintenance platform hai jo Delhi NCR mein trusted AC repair, plumbing services, electrician services aur appliance repair provide karta hai. Hum transparent pricing aur professional service standards ke saath safe aur reliable home service experience deliver karte hain.",
    ),
    FaqItem(
      question: "Main Dofix par service kaise book kar sakta/sakti hoon?",
      answer:
      "Booking process simple aur secure hai. Apni required home service select karein, preferred time slot choose karein, address confirm karein aur kuch hi minutes mein booking complete ho jaati hai. Aapko instant confirmation aur service details mil jaati hain.",
    ),
    FaqItem(
      question: "Dofix kaun-kaun se areas mein service deta hai?",
      answer:
      "Dofix Delhi, Noida, Gurgaon, Ghaziabad aur poore NCR region mein services provide karta hai — taaki aapko fast aur reliable home repair & installation services near you mil sakein.",
    ),
    FaqItem(
      question: "Kya Dofix ke technicians verified hote hain?",
      answer:
      "Haan. Har technician strict background verification, skill assessment aur identity checks se guzarta hai. Customer safety, professional behaviour aur quality workmanship humari top priority hai.",
    ),
    FaqItem(
      question: "Service ki pricing kaise decide hoti hai?",
      answer:
      "Hum transparent aur standardized pricing model follow karte hain. Charges inspection ya predefined rates ke basis par upfront bataye jaate hain. Koi hidden cost nahi hoti — final price aapki approval ke baad hi kaam shuru hota hai.",
    ),
    FaqItem(
      question: "Kya Dofix AC installation aur gas refilling service deta hai?",
      answer:
      "Bilkul. Professional AC installation, uninstallation, servicing, repair aur gas refilling services trained aur experienced technicians ke through provide ki jaati hain.",
    ),
    FaqItem(
      question: "Dofix kaun-kaun si services provide karta hai?",
      answer:
      "AC Repair & Installation Plumbing Services Electrician Services Appliance Repair General Home Maintenance Yeh aapka one-stop solution hai reliable home services ke liye.",
    ),
    FaqItem(
      question: "PLocal technician ke bajaye Dofix kyu choose karein?",
      answer:
      "✔ Background-verified professionals Standardized aur transparent pricing Selected services par warranty Responsive customer support Isliye aapko milta hai safer aur zyada dependable service experience.",
    ),
    FaqItem(
      question: "Kya service warranty ya post-service support milta hai?",
      answer:
      "Haan, selected services par limited service warranty milti hai. Agar koi issue ho, toh dedicated support team prompt resolution aur proper follow-up ensure karti hai.",
    ),
  ];

  final List<FaqItem> paymentFaq = [
    FaqItem(
      question: "Kaun-kaun se payment methods accept hote hain?",
      answer:
      "Aap UPI, debit/credit cards, net banking aur cash se payment kar sakte hain. Saare digital payments secure payment gateways ke through process hote hain.",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final currentFaq = selectedType == 0 ? generalFaq : paymentFaq;

    final filteredFaqs = currentFaq
        .where((faq) =>
        faq.question.toLowerCase().contains(_searchText.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Help & FAQ",
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search question...",
                prefixIcon: const Icon(CupertinoIcons.search),
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchText = value;
                });
              },
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          /// FAQ TYPE SELECTOR
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              height: 45,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  _buildTab("General", 0),
                  _buildTab("Payments", 1),
                ],
              ),
            ),
          ),

          /// FAQ LIST
          Expanded(
            child: filteredFaqs.isEmpty
                ? const Center(
              child: Text(
                "No FAQ Found",
                style: TextStyle(color: Colors.grey),
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: filteredFaqs.length,
              itemBuilder: (context, index) {
                return _FaqTile(faq: filteredFaqs[index]);
              },
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildTab(String title, int index) {
    final isSelected = selectedType == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedType = index;
            _searchController.clear();
            _searchText = "";
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isSelected ? primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: GoogleFonts.poppins(
              color: isSelected ? Colors.white : Colors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

/* ---------------- FAQ TILE ---------------- */

class _FaqTile extends StatefulWidget {
  final FaqItem faq;

  const _FaqTile({required this.faq});

  @override
  State<_FaqTile> createState() => _FaqTileState();
}

class _FaqTileState extends State<_FaqTile> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: isExpanded
                ? primaryColor.withOpacity(0.6)
                : Colors.grey.withOpacity(0.3)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          setState(() {
            isExpanded = !isExpanded;
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.faq.question,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    duration: const Duration(milliseconds: 200),
                    turns: isExpanded ? 0.5 : 0,
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: isExpanded ? primaryColor : Colors.grey,
                    ),
                  ),
                ],
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 200),
                child: isExpanded
                    ? Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    widget.faq.answer,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      height: 1.6,
                      color: Colors.black.withOpacity(0.65),
                    ),
                  ),
                )
                    : const SizedBox.shrink(),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class FaqItem {
  final String question;
  final String answer;

  FaqItem({required this.question, required this.answer});
}
