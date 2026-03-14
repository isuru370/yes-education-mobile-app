import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../core/enums/scan_type.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../route_observer.dart';
import '../../../students/presentaion/pages/single_student_view_page.dart';
import '../bloc/read_attendance/read_attendance_bloc.dart';
import '../bloc/read_payment/read_payment_bloc.dart';
import '../bloc/read_student/read_student_bloc.dart';
import '../bloc/read_tute/read_tute_bloc.dart';

class QrScannerPage extends StatefulWidget {
  final ScanType scanType;
  final String token;

  const QrScannerPage({super.key, required this.scanType, required this.token});

  @override
  State<QrScannerPage> createState() => _QrScannerPageState();
}

class _QrScannerPageState extends State<QrScannerPage> with RouteAware {
  bool _hasPermission = false;
  bool _isScanned = false;

  // Manual entry controllers
  final TextEditingController _customIdController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _requestPermission();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    _customIdController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  void didPopNext() {
    // Reset scanner and clear manual input when returning
    setState(() {
      _isScanned = false;
      _customIdController.clear();
    });
  }

  Future<void> _requestPermission() async {
    final status = await Permission.camera.request();
    setState(() => _hasPermission = status.isGranted);
  }

  void _handleManualSubmit() {
    if (_isScanned) return; // prevent double submission

    final customId = _customIdController.text.trim();
    if (customId.isEmpty) return;

    setState(() => _isScanned = true);
    _focusNode.unfocus(); // hide keyboard

    // Trigger the appropriate bloc event based on scanType
    if (widget.scanType == ScanType.attendance) {
      context.read<ReadAttendanceBloc>().add(
        ReadAttendanceRequested(token: widget.token, customId: customId),
      );
    } else if (widget.scanType == ScanType.payment) {
      context.read<ReadPaymentBloc>().add(
        ReadPaymentRequested(token: widget.token, customId: customId),
      );
    } else if (widget.scanType == ScanType.student) {
      context.read<ReadStudentBloc>().add(
        ReadStudentRequested(token: widget.token, customId: customId),
      );
    } else if (widget.scanType == ScanType.tute) {
      context.read<ReadTuteBloc>().add(
        ReadTuteRequested(token: widget.token, customId: customId),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasPermission) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Camera Permission'),
          backgroundColor: AppTheme.primaryColor,
        ),
        body: const Center(
          child: Text(
            'Camera permission is required to scan QR codes.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return MultiBlocListener(
      listeners: [
        // ---------------- ATTENDANCE ----------------
        BlocListener<ReadAttendanceBloc, ReadAttendanceState>(
          listener: (context, state) {
            if (state is ReadAttendanceLoaded) {
              if (state.attendanceList.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Class not available for this student.'),
                  ),
                );
                _isScanned = false;
              } else {
                Navigator.pushNamed(
                  context,
                  '/attendance-details',
                  arguments: {'token': widget.token, 'attendanceState': state},
                );
              }
            }

            if (state is ReadAttendanceError) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
              _isScanned = false;
            }
          },
        ),

        // ---------------- PAYMENT ----------------
        BlocListener<ReadPaymentBloc, ReadPaymentState>(
          listener: (context, state) {
            if (state is ReadPaymentLoaded) {
              if (state.response.data.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('No payment records found.')),
                );
                _isScanned = false;
              } else {
                Navigator.pushNamed(
                  context,
                  '/payment-details',
                  arguments: {'token': widget.token, 'paymentState': state},
                );
              }
            }

            if (state is ReadPaymentError) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
              _isScanned = false;
            }
          },
        ),

        // ---------------- STUDENT ----------------
        BlocListener<ReadStudentBloc, ReadStudentState>(
          listener: (context, state) {
            if (state is ReadStudentLoaded) {
              final student = state.response.data;
              if (student != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SingleStudentViewPage(
                      token: widget.token,
                      student: student,
                    ),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      state.response.message ?? 'Student not found',
                    ),
                  ),
                );
              }
            }

            if (state is ReadStudentError) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
        ),

        // ---------------- TUTE ----------------
        BlocListener<ReadTuteBloc, ReadTuteState>(
          listener: (context, state) {
            if (state is ReadTuteSuccess) {
              final tuteData = state.response.data;
              if (tuteData.isNotEmpty) {
                Navigator.pushNamed(
                  context,
                  '/read_tute',
                  arguments: {
                    'token': widget.token,
                    'read_tute_success': state.response,
                  },
                );
              } else {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Tute data not found')));
              }
            }

            if (state is ReadTuteFailure) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppTheme.primaryColor,
          title: Text(
            widget.scanType == ScanType.attendance
                ? 'Scan Attendance QR'
                : widget.scanType == ScanType.payment
                ? 'Scan Payment QR'
                : widget.scanType == ScanType.tute
                ? 'Scan Tute QR'
                : 'Scan Student',
          ),
          centerTitle: true,
        ),
        body: Stack(
          children: [
            MobileScanner(
              onDetect: (capture) {
                if (_isScanned) return;

                final value = capture.barcodes.first.rawValue;
                if (value == null || value.isEmpty) return;

                _isScanned = true;

                if (widget.scanType == ScanType.attendance) {
                  context.read<ReadAttendanceBloc>().add(
                    ReadAttendanceRequested(
                      token: widget.token,
                      customId: value,
                    ),
                  );
                } else if (widget.scanType == ScanType.payment) {
                  context.read<ReadPaymentBloc>().add(
                    ReadPaymentRequested(token: widget.token, customId: value),
                  );
                } else if (widget.scanType == ScanType.student) {
                  context.read<ReadStudentBloc>().add(
                    ReadStudentRequested(token: widget.token, customId: value),
                  );
                } else if (widget.scanType == ScanType.tute) {
                  context.read<ReadTuteBloc>().add(
                    ReadTuteRequested(token: widget.token, customId: value),
                  );
                }
              },
            ),
            // Scanning guide overlay
            Center(
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppTheme.primaryColor.withValues(alpha: 0.6),
                    width: 3,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            // Manual entry search bar
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _customIdController,
                            focusNode: _focusNode,
                            decoration: const InputDecoration(
                              hintText: 'Enter custom ID',
                              border: InputBorder.none,
                            ),
                            onSubmitted: (_) => _handleManualSubmit(),
                            enabled: !_isScanned,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.search),
                          onPressed: _isScanned ? null : _handleManualSubmit,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
