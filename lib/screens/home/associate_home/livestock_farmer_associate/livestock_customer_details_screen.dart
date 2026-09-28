import 'package:flutter/material.dart';
import 'package:pashudhan_qr/app/app.locator.dart';
import 'package:pashudhan_qr/models/pashudhan_model.dart';
import 'package:pashudhan_qr/models/vaccination_model.dart';
import 'package:pashudhan_qr/models/breeding_model.dart';
import 'package:pashudhan_qr/repository/vaccination_repository.dart';
import 'package:pashudhan_qr/repository/breeding_repository.dart';
import 'package:pashudhan_qr/screens/reports/livestock_details_associate_view.dart';
import 'package:pashudhan_qr/screens/reports/vaccination_detail_screen.dart';
import 'package:pashudhan_qr/screens/reports/breeding_detail_screen.dart';

class LivestockCustomerDetailsScreen extends StatefulWidget {
  final String mobileNumber;
  final List<Pashudhan> pashudhans;

  const LivestockCustomerDetailsScreen({
    super.key,
    required this.mobileNumber,
    required this.pashudhans,
  });

  @override
  State<LivestockCustomerDetailsScreen> createState() => _LivestockCustomerDetailsScreenState();
}

class _LivestockCustomerDetailsScreenState extends State<LivestockCustomerDetailsScreen> {
  final _vaccinationRepo = locator<VaccinationRepository>();
  final _breedingRepo = locator<BreedingRepository>();

  bool _isLoading = true;
  List<Vaccination> _vaccinations = [];
  List<BreedingReport> _breedingReports = [];
  String? _errorMessage;

  static const Color primaryYellow = Color(0xFFEDC93A);
  static const Color primaryGreen = Color(0xFFA1BC2A);
  static const Color darkBrown = Color(0xFF452B14);

  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await Future.wait([
        _vaccinationRepo.getVaccinations(),
        _breedingRepo.getBreedingReports(),
      ]);

      final allVaccinations = results[0] as List<Vaccination>;
      final allBreeding = results[1] as List<BreedingReport>;

      // Get all livestock UUIDs under this owner
      final livestockUuids = widget.pashudhans.map((p) => p.uuid).toSet();

      // Filter vaccinations and breeding reports in memory
      _vaccinations = allVaccinations.where((v) => livestockUuids.contains(v.animalUuid)).toList();
      _breedingReports = allBreeding.where((b) => livestockUuids.contains(b.pashudhanUuid)).toList();

    } catch (e) {
      _errorMessage = 'Failed to load report history. Using cached livestock list.';
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: primaryGreen,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: darkBrown, size: 28),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text(
            'L.FARMER REPORT CARD',
            style: TextStyle(
              color: darkBrown,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          bottom: const TabBar(
            indicatorColor: darkBrown,
            indicatorWeight: 4,
            labelColor: darkBrown,
            unselectedLabelColor: Colors.white,
            labelStyle: TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
            tabs: [
              Tab(text: 'LIVESTOCK', icon: Icon(Icons.agriculture, size: 20)),
              Tab(text: 'VACCINE', icon: Icon(Icons.vaccines, size: 20)),
              Tab(text: 'BREEDING', icon: Icon(Icons.favorite, size: 20)),
            ],
          ),
          shape: const Border(bottom: BorderSide(color: darkBrown, width: 4.0)),
        ),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: primaryYellow, strokeWidth: 4),
              )
            : Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/pattern_bg.png'),
                    repeat: ImageRepeat.repeat,
                    opacity: 0.08,
                  ),
                ),
                child: Column(
                  children: [
                    // Header card with mobile number and total count
                    _buildOwnerHeaderCard(),
                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                        ),
                      ),
                    // Tab content
                    Expanded(
                      child: TabBarView(
                        children: [
                          _buildLivestockList(),
                          _buildVaccinationsList(),
                          _buildBreedingList(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildOwnerHeaderCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primaryYellow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: darkBrown, width: 3.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: primaryGreen,
              shape: BoxShape.circle,
              border: Border.all(color: darkBrown, width: 2),
            ),
            child: const Icon(Icons.person, color: darkBrown, size: 36),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'LIVESTOCK FARMER / CUSTOMER',
                  style: TextStyle(
                    color: darkBrown,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  widget.mobileNumber,
                  style: const TextStyle(
                    color: darkBrown,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Total Livestock Registered: ${widget.pashudhans.length}',
                  style: const TextStyle(
                    color: darkBrown,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLivestockList() {
    if (widget.pashudhans.isEmpty) {
      return _buildEmptyState('No registered livestock found');
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: widget.pashudhans.length,
      itemBuilder: (context, index) {
        final pashudhan = widget.pashudhans[index];
        final name = pashudhan.name.isNotEmpty ? pashudhan.name : 'N/A';
        final isGoat = pashudhan.category.toUpperCase() == 'GOAT';

        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => LivestockDetailsAssociateView(pashudhan: pashudhan)),
          ),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: darkBrown, width: 3),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1F000000),
                  offset: Offset(2, 4),
                  blurRadius: 4,
                )
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: primaryGreen.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: darkBrown, width: 2),
                  ),
                  child: Center(
                    child: Icon(
                      isGoat ? Icons.agriculture_outlined : Icons.agriculture,
                      color: darkBrown,
                      size: 30,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name.toUpperCase(),
                        style: const TextStyle(
                          color: darkBrown,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Category: ${pashudhan.category} | Breed: ${pashudhan.breed}',
                        style: const TextStyle(color: darkBrown, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Lactation: ${pashudhan.lactationNumber} | Milk Yield: ${pashudhan.milkYield} L',
                        style: const TextStyle(color: darkBrown, fontWeight: FontWeight.w500),
                      ),
                      Text(
                        'Age: ${pashudhan.ageInMonths} Months | Weight: ${pashudhan.weight} kg',
                        style: const TextStyle(color: darkBrown, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: primaryYellow,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: darkBrown, width: 1.5),
                        ),
                        child: Text(
                          'Tag: ${pashudhan.earTagNumber}',
                          style: const TextStyle(
                            color: darkBrown,
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      );
      },
    );
  }

  Widget _buildVaccinationsList() {
    if (_vaccinations.isEmpty) {
      return _buildEmptyState('No vaccination history found');
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _vaccinations.length,
      itemBuilder: (context, index) {
        final vac = _vaccinations[index];
        final pashudhan = widget.pashudhans.firstWhere(
          (p) => p.uuid == vac.animalUuid,
          orElse: () => widget.pashudhans.first,
        );
        final name = pashudhan.name.isNotEmpty ? pashudhan.name : 'N/A';

        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => VaccinationDetailScreen(uuid: vac.uuid)),
          ),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: darkBrown, width: 3),
            ),
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    vac.vaccineName?.toUpperCase() ?? 'UNKNOWN VACCINE',
                    style: const TextStyle(
                      color: darkBrown,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: primaryGreen,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: darkBrown, width: 1.5),
                    ),
                    child: Text(
                      name.toUpperCase(),
                      style: const TextStyle(
                        color: darkBrown,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(color: darkBrown, thickness: 1.5),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 16, color: darkBrown),
                  const SizedBox(width: 6),
                  Text(
                    'Given: ${vac.vaccinationDate != null ? vac.vaccinationDate!.substring(0, 10) : 'N/A'}',
                    style: const TextStyle(color: darkBrown, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.notification_important, size: 16, color: Colors.red),
                  const SizedBox(width: 6),
                  Text(
                    'Next Due: ${vac.nextDueDate != null ? vac.nextDueDate!.substring(0, 10) : 'N/A'}',
                    style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w900),
                  ),
                ],
              ),
              if (vac.notes != null && vac.notes!.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  'Notes: ${vac.notes}',
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                )
              ]
            ],
          ),
        ),
      );
    },
  );
  }

  Widget _buildBreedingList() {
    if (_breedingReports.isEmpty) {
      return _buildEmptyState('No breeding history found');
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _breedingReports.length,
      itemBuilder: (context, index) {
        final br = _breedingReports[index];
        final pashudhan = widget.pashudhans.firstWhere(
          (p) => p.uuid == br.pashudhanUuid,
          orElse: () => widget.pashudhans.first,
        );
        final name = pashudhan.name.isNotEmpty ? pashudhan.name : 'N/A';

        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => BreedingDetailScreen(uuid: br.uuid)),
          ),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: darkBrown, width: 3),
            ),
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Insemination: ${br.inseminationType?.toUpperCase() ?? 'N/A'}',
                    style: const TextStyle(
                      color: darkBrown,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: primaryGreen,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: darkBrown, width: 1.5),
                    ),
                    child: Text(
                      name.toUpperCase(),
                      style: const TextStyle(
                        color: darkBrown,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(color: darkBrown, thickness: 1.5),
              const SizedBox(height: 4),
              if (br.bullBreed != null && br.bullBreed!.isNotEmpty && br.bullBreed != 'N/A')
                Text(
                  'Bull Breed: ${br.bullBreed}',
                  style: const TextStyle(color: darkBrown, fontWeight: FontWeight.bold),
                ),
              if (br.strawNo != null && br.strawNo!.isNotEmpty && br.strawNo != 'N/A')
                Text(
                  'Straw No: ${br.strawNo}',
                  style: const TextStyle(color: darkBrown, fontWeight: FontWeight.bold),
                ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.date_range, size: 16, color: darkBrown),
                  const SizedBox(width: 6),
                  Text(
                    'Date: ${br.dateOfInsemination != null ? br.dateOfInsemination!.substring(0, 10) : 'N/A'}',
                    style: const TextStyle(color: darkBrown, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              if (br.dateOfCalving != null && br.dateOfCalving!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.child_friendly, size: 16, color: darkBrown),
                    const SizedBox(width: 6),
                    Text(
                      'Calved: ${br.dateOfCalving!.substring(0, 10)} (${br.numberOfCalves ?? 0} Calves)',
                      style: const TextStyle(color: darkBrown, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ]
            ],
          ),
        ),
      );
    },
  );
  }

  Widget _buildEmptyState(String text) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, color: darkBrown.withOpacity(0.5), size: 60),
          const SizedBox(height: 12),
          Text(
            text,
            style: TextStyle(
              color: darkBrown.withOpacity(0.7),
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
