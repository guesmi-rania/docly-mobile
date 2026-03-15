import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../theme/app_theme.dart';

class PrescriptionScreen extends StatefulWidget {
  final String patientName;
  final String appointmentId;
  final String doctorName;
  final String specialty;

  const PrescriptionScreen({
    super.key,
    required this.patientName,
    required this.appointmentId,
    required this.doctorName,
    required this.specialty,
  });

  @override
  State<PrescriptionScreen> createState() => _PrescriptionScreenState();
}

class _PrescriptionScreenState extends State<PrescriptionScreen> {
  final List<MedicationEntry> _medications = [MedicationEntry()];
  final _diagnosisController = TextEditingController();
  final _notesController = TextEditingController();
  bool _generating = false;

  // ── Couleurs PDF (pas de const, PdfColor n'est pas const-compatible) ──
  static final _pdfPrimary     = PdfColor.fromHex('#1a73e8');
  static final _pdfDark        = PdfColor.fromHex('#0d47a1');
  static final _pdfWhite       = PdfColor.fromHex('#FFFFFF');
  static final _pdfWhiteSoft   = PdfColor.fromHex('#B3FFFFFF'); // blanc ~70%
  static final _pdfGrey100     = PdfColor.fromHex('#F5F5F5');
  static final _pdfTextPrimary = PdfColor.fromHex('#1a1a2e');
  static final _pdfTextGrey    = PdfColor.fromHex('#888888');

  @override
  void dispose() {
    _diagnosisController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _generatePDF() async {
    setState(() => _generating = true);
    try {
      final pdf  = pw.Document();
      final date = DateTime.now();
      final dateStr = '${date.day}/${date.month}/${date.year}';

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(40),
          build: (context) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [

              // ── Header ──────────────────────────────────────────────
              pw.Container(
                padding: const pw.EdgeInsets.all(20),
                decoration: pw.BoxDecoration(
                  gradient: pw.LinearGradient(
                    colors: [_pdfPrimary, _pdfDark],
                    begin: pw.Alignment.topLeft,
                    end: pw.Alignment.bottomRight,
                  ),
                  borderRadius: pw.BorderRadius.circular(12),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'DOCLY',
                          style: pw.TextStyle(
                            color: _pdfWhite,         // ← plus de PdfColors.white70
                            fontSize: 24,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.Text(
                          'Ordonnance Médicale',
                          style: pw.TextStyle(
                            color: _pdfWhiteSoft,     // ← remplace white70
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(
                          'Dr. ${widget.doctorName}',
                          style: pw.TextStyle(
                            color: _pdfWhite,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.Text(
                          widget.specialty,
                          style: pw.TextStyle(
                            color: _pdfWhiteSoft,     // ← remplace white70
                            fontSize: 12,
                          ),
                        ),
                        pw.Text(
                          'Date : $dateStr',
                          style: pw.TextStyle(
                            color: _pdfWhiteSoft,     // ← remplace white70
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 20),

              // ── Patient ─────────────────────────────────────────────
              pw.Container(
                padding: const pw.EdgeInsets.all(14),
                decoration: pw.BoxDecoration(
                  color: _pdfGrey100,
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Row(
                  children: [
                    pw.Text(
                      'Patient : ',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text(widget.patientName),
                  ],
                ),
              ),

              pw.SizedBox(height: 16),

              // ── Diagnostic ──────────────────────────────────────────
              if (_diagnosisController.text.isNotEmpty) ...[
                pw.Text(
                  'Diagnostic :',
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                pw.SizedBox(height: 6),
                pw.Text(
                  _diagnosisController.text,
                  style: pw.TextStyle(fontSize: 13, color: _pdfTextPrimary),
                ),
                pw.SizedBox(height: 16),
              ],

              // ── Médicaments ─────────────────────────────────────────
              pw.Text(
                'Prescriptions :',
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              pw.SizedBox(height: 8),

              ..._medications
                  .where((m) => m.name.isNotEmpty)
                  .toList()
                  .asMap()
                  .entries
                  .map(
                    (e) => pw.Container(
                      margin: const pw.EdgeInsets.only(bottom: 8),
                      padding: const pw.EdgeInsets.all(12),
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(color: _pdfPrimary, width: 1),
                        borderRadius: pw.BorderRadius.circular(8),
                      ),
                      child: pw.Row(
                        children: [
                          // Numéro
                          pw.Container(
                            width: 24,
                            height: 24,
                            decoration: pw.BoxDecoration(
                              color: _pdfPrimary,
                              shape: pw.BoxShape.circle,
                            ),
                            child: pw.Center(
                              child: pw.Text(
                                '${e.key + 1}',
                                style: pw.TextStyle(
                                  color: _pdfWhite,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                          pw.SizedBox(width: 12),
                          // Infos médicament
                          pw.Expanded(
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text(
                                  e.value.name,
                                  style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold,
                                  ),
                                ),
                                if (e.value.dosage.isNotEmpty)
                                  pw.Text(
                                    'Posologie : ${e.value.dosage}',
                                    style: pw.TextStyle(
                                      fontSize: 12,
                                      color: _pdfTextGrey,
                                    ),
                                  ),
                                if (e.value.duration.isNotEmpty)
                                  pw.Text(
                                    'Durée : ${e.value.duration}',
                                    style: pw.TextStyle(
                                      fontSize: 12,
                                      color: _pdfTextGrey,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

              // ── Notes ───────────────────────────────────────────────
              if (_notesController.text.isNotEmpty) ...[
                pw.SizedBox(height: 16),
                pw.Text(
                  'Recommandations :',
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                pw.SizedBox(height: 6),
                pw.Text(
                  _notesController.text,
                  style: pw.TextStyle(fontSize: 13, color: _pdfTextPrimary),
                ),
              ],

              pw.Spacer(),

              // ── Signature ───────────────────────────────────────────
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Column(
                    children: [
                      pw.Container(
                        width: 140,
                        height: 50,
                        decoration: pw.BoxDecoration(
                          border: pw.Border(
                            bottom: pw.BorderSide(color: _pdfPrimary),
                          ),
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'Dr. ${widget.doctorName}',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                      pw.Text(
                        widget.specialty,
                        style: pw.TextStyle(
                          fontSize: 11,
                          color: _pdfTextGrey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      );

      await Printing.sharePdf(
        bytes: await pdf.save(),
        filename: 'ordonnance_${widget.patientName}_$dateStr.pdf',
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: $e'),
          backgroundColor: AppTheme.danger,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
      );
    } finally {
      if (mounted) setState(() => _generating = false);
    }
  }

  // ── BUILD ──────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nouvelle ordonnance'),
        flexibleSpace: Container(
          decoration: BoxDecoration(gradient: AppTheme.gradient),  
        ),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: _generating
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2),
                  )
                : const Icon(Icons.picture_as_pdf),
            onPressed: _generating ? null : _generatePDF,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          // Patient
          _sectionCard(
            colors: colors,
            title: '👤 Patient',
            child: Text(
              widget.patientName,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: colors.textPrimary,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Diagnostic
          _sectionCard(
            colors: colors,
            title: '🩺 Diagnostic',
            child: TextField(
              controller: _diagnosisController,
              decoration: const InputDecoration(
                hintText: 'Ex: Rhinopharyngite aiguë...',
                border: InputBorder.none,
              ),
              maxLines: 2,
            ),
          ),

          const SizedBox(height: 12),

          // Médicaments
          _sectionCard(
            colors: colors,
            title: '💊 Médicaments',
            child: Column(
              children: [
                ..._medications.asMap().entries.map(
                      (e) => _MedicationRow(
                        entry: e.value,
                        index: e.key,
                        onRemove: _medications.length > 1
                            ? () => setState(
                                () => _medications.removeAt(e.key))
                            : null,
                      ),
                    ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () =>
                      setState(() => _medications.add(MedicationEntry())),
                  icon: const Icon(Icons.add),
                  label: const Text('Ajouter un médicament'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Notes
          _sectionCard(
            colors: colors,
            title: '📝 Recommandations',
            child: TextField(
              controller: _notesController,
              decoration: const InputDecoration(
                hintText: 'Repos, alimentation, suivi...',
                border: InputBorder.none,
              ),
              maxLines: 3,
            ),
          ),

          const SizedBox(height: 24),

          // Bouton générer
          SizedBox(
            height: 52,
            child: DecoratedBox(
              decoration: BoxDecoration(          // ← pas de const ici
                gradient: AppTheme.gradient,
                borderRadius: BorderRadius.circular(14),
              ),
              child: ElevatedButton.icon(
                onPressed: _generating ? null : _generatePDF,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                icon: const Icon(Icons.picture_as_pdf),
                label: Text(
                  _generating
                      ? 'Génération...'
                      : 'Générer & Partager l\'ordonnance',
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _sectionCard({
    required AppColors colors,
    required String title,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.w800, fontSize: 14)),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

// ── Modèle médicament ────────────────────────────────────────────────
class MedicationEntry {
  String name     = '';
  String dosage   = '';
  String duration = '';
}

// ── Widget ligne médicament ──────────────────────────────────────────
class _MedicationRow extends StatelessWidget {
  final MedicationEntry entry;
  final int index;
  final VoidCallback? onRemove;

  const _MedicationRow({
    required this.entry,
    required this.index,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.primaryLight,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: AppTheme.primary,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  onChanged: (v) => entry.name = v,
                  decoration: const InputDecoration(
                    hintText: 'Nom du médicament',
                    border: InputBorder.none,
                    isDense: true,
                  ),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              if (onRemove != null)
                GestureDetector(
                  onTap: onRemove,
                  child: const Icon(Icons.close,
                      size: 18, color: AppTheme.danger),
                ),
            ],
          ),
          const Divider(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: (v) => entry.dosage = v,
                  decoration: const InputDecoration(
                    hintText: 'Posologie (ex: 1cp x2/j)',
                    border: InputBorder.none,
                    isDense: true,
                    hintStyle: TextStyle(fontSize: 12),
                  ),
                  style: const TextStyle(fontSize: 13),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  onChanged: (v) => entry.duration = v,
                  decoration: const InputDecoration(
                    hintText: 'Durée (ex: 7 jours)',
                    border: InputBorder.none,
                    isDense: true,
                    hintStyle: TextStyle(fontSize: 12),
                  ),
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}