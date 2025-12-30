import 'package:flutter/material.dart';
import '../../main.dart';

class FAQPage extends StatelessWidget {
  const FAQPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Frequently Asked Questions'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildFAQItem(
            context,
            question: 'What is Travenor?',
            answer: 'Travenor is your daily companion for group travel experiences. It helps you discover and join curated group tours across Bangladesh with verified tour leads and guaranteed refunds.',
            isExpanded: true,
          ),
          
          const SizedBox(height: 12),
          
          _buildFAQItem(
            context,
            question: 'How are tours organized?',
            answer: 'Each tour is led by a verified tour guide with a fixed itinerary, group size, and departure date. You can browse tours, check details, and book your spot directly through the app.',
          ),
          
          const SizedBox(height: 12),
          
          _buildFAQItem(
            context,
            question: 'Can I cancel my booking?',
            answer: 'Yes, you can cancel your booking according to our refund policy. If a tour doesn\'t happen or gets canceled, you\'ll receive a full refund automatically.',
          ),
          
          const SizedBox(height: 12),
          
          _buildFAQItem(
            context,
            question: 'How does the payment work?',
            answer: 'You can pay securely through our app using mobile banking, credit cards, or other payment methods. Your payment is held securely until the tour is confirmed.',
          ),
          
          const SizedBox(height: 12),
          
          _buildFAQItem(
            context,
            question: 'What happens if I miss a day or the tour?',
            answer: 'Tours follow a fixed schedule. If you miss the departure or certain activities, refunds may vary based on the tour\'s specific refund policy. Contact support for assistance.',
          ),
          
          const SizedBox(height: 12),
          
          _buildFAQItem(
            context,
            question: 'How can I contact support if I face any issues?',
            answer: 'You can reach our support team via email at support@travenor.com or call/WhatsApp us at +880 1758-000666. We typically respond within 24 hours (Monday-Friday).',
          ),
          
          const SizedBox(height: 12),
          
          _buildFAQItem(
            context,
            question: 'Are all tour leads verified?',
            answer: 'Yes! Every tour lead on Travenor goes through a background check and verification process. Look for the "Verified Lead" badge on tour details.',
          ),
          
          const SizedBox(height: 12),
          
          _buildFAQItem(
            context,
            question: 'Can I bring a friend who hasn\'t booked?',
            answer: 'All participants must book through the app to join the tour. This ensures proper headcount, insurance coverage, and a better experience for everyone.',
          ),
        ],
      ),
    );
  }

  Widget _buildFAQItem(
    BuildContext context, {
    required String question,
    required String answer,
    bool isExpanded = false,
  }) {
    return _FAQExpansionTile(
      question: question,
      answer: answer,
      initiallyExpanded: isExpanded,
    );
  }
}

class _FAQExpansionTile extends StatefulWidget {
  final String question;
  final String answer;
  final bool initiallyExpanded;

  const _FAQExpansionTile({
    required this.question,
    required this.answer,
    this.initiallyExpanded = false,
  });

  @override
  State<_FAQExpansionTile> createState() => _FAQExpansionTileState();
}

class _FAQExpansionTileState extends State<_FAQExpansionTile> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppTheme.borderGray,
            width: 1,
          ),
        ),
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            _isExpanded = !_isExpanded;
          });
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.question,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                  Icon(
                    _isExpanded ? Icons.remove : Icons.add,
                    color: AppTheme.textPrimary,
                    size: 24,
                  ),
                ],
              ),
              if (_isExpanded) ...[
                const SizedBox(height: 12),
                Text(
                  widget.answer,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                        height: 1.5,
                      ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
