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
      question: "Kaam kaise milega?",
      answer:
      "App par aapke location aur skill ke according service requests milengi. Aap request accept karke customer ke paas ja sakte hain.",
    ),
    FaqItem(
      question: "Booking accept karne ke baad kya hota hai?",
      answer:
      "Accept karne ke baad booking aapke ongoing list me chali jaati hai aur aap kaam complete kar sakte hain.",
    ),
    FaqItem(
      question: "Uniform aur ID Card milega?",
      answer:
      "Company approved uniform aur ID card provide kiya jayega (agar policy me ho).",
    ),
    FaqItem(
      question: "Rating aur review ka kya importance hai?",
      answer:
      "High rating wale partners ko zyada aur priority booking milti hai. Achhi service dena zaroori hai.",
    ),
    FaqItem(
      question: "Kya main apni timing choose kar sakta hoon?",
      answer:
      "Haan, aap apni availability app me set kar sakte hain.",
    ),
    FaqItem(
      question: "Kya main multiple services add kar sakta hoon?",
      answer:
      "Nhi Kr Skte.",
    ),
    FaqItem(
      question: "Agar customer cancel kare to kya hoga?",
      answer:
      "Customer cancellation policy ke hisab se applicable charges partner ko mil sakte hain (terms & conditions ke according).",
    ),
    FaqItem(
      question: "Partner account block kab ho sakta hai?",
      answer:
      "Fake job completionCustomer complaint\nPoor rating\nCompany policy violatian.",
    ),
    FaqItem(
      question: "Partner Kitni Holiday le sakte hai OR Kitni Job Chord Sakte hai ?",
      answer:
      "Hafte me 1 or Mahine me 4.",
    ),
  ];

  final List<FaqItem> paymentFaq = [
    FaqItem(
      question: "Payment kaise milega?",
      answer:
      "Payment weekly ya daily settlement ke through direct bank account me transfer kiya jata hai.",
    ),
    FaqItem(
      question: "Commission kitna katega?",
      answer:
      "DoFix har completed service par fixed percentage commission charge karta hai. (Yaha aap apna % likh sakte hain).",
    ),
    FaqItem(
      question: "Agar payment issue ho to kya karein?",
      answer:
      "App ke support section me complaint raise karein ya DoFix Partner Support team se contact karein.",
    ),
    FaqItem(
      question: "Earnings kaise track kare?",
      answer:
      "Paise tab me aap daily, weekly aur monthly earnings track kar sakte hain.",
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
