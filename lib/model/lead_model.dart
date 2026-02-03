import 'package:cloud_firestore/cloud_firestore.dart';

class LeadModel {
  // --- CONSTANTS (Use these to avoid typos) ---
  static const String SOURCE_APP = 'APP';
  static const String SOURCE_MANUAL = 'MANUAL_ADMIN_ENTRY';
  static const String SOURCE_WORKSHOP = 'WORKSHOP_FORM';

  static const String TYPE_PATIENT_INQUIRY = 'PATIENT_INQUIRY';
  static const String TYPE_WORKSHOP_REG = 'WORKSHOP';
  static const String TYPE_GENERAL = 'GENERAL_INQUIRY';

  // --- FIELDS ---
  final String? id; // Firestore Document ID
  final String tenantId;
  final String bookingReferenceId; // E.g., "NW-849201"

  // Personal Details
  final String userName;
  final String phoneNumber;
  final String? age;
  final String? gender;
  final String? address;

  // Context (What they want)
  final String bookingType;   // PATIENT_INQUIRY or WORKSHOP
  final String interestLabel; // "Diabetes Reversal" or "Yoga Workshop"
  final String? interestId;   // ID of specific workshop (optional)

  // The "Words"
  final String userMessage;   // "I have thyroid issues..." (Client's voice)
  final String notes;         // "Call in evening..." (Admin's voice)

  // Meta
  final String source;        // Where did this come from?
  final String status;        // NEW_LEAD, CALLED, CONVERTED
  final String paymentStatus; // PAID, UNPAID, N/A
  final DateTime createdAt;

  LeadModel({
    this.id,
    required this.tenantId,
    required this.bookingReferenceId,
    required this.userName,
    required this.phoneNumber,
    this.age,
    this.gender,
    this.address,
    required this.bookingType,
    required this.interestLabel,
    this.interestId,
    this.userMessage = '',
    this.notes = '',
    required this.source,
    this.status = 'NEW_LEAD',
    this.paymentStatus = 'N/A',
    required this.createdAt,
  });

  // --- 1. CONVERT TO MAP (For Saving to Firestore) ---
  Map<String, dynamic> toMap() {
    return {
      'tenant_id': tenantId,
      'booking_reference_id': bookingReferenceId,
      'user_name': userName,
      'phone_number': phoneNumber,
      'age': age,
      'gender': gender,
      'address': address,

      // The Standardized Fields
      'booking_type': bookingType,
      'interest_label': interestLabel,
      'plan_selection': interestLabel, // Keeping this for backward compatibility
      'interest_id': interestId,

      // Messages
      'user_message': userMessage,
      'notes': notes,

      // Status
      'source': source,
      'status': status,
      'payment_status': paymentStatus,
      'created_at': Timestamp.fromDate(createdAt),
    };
  }

  // --- 2. CREATE FROM SNAPSHOT (For Reading from Firestore) ---
  factory LeadModel.fromSnapshot(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return LeadModel(
      id: doc.id,
      tenantId: data['tenant_id'] ?? '',
      // Fallback for old leads that don't have an ID yet
      bookingReferenceId: data['booking_reference_id'] ?? 'OLD-DATA',

      userName: data['user_name'] ?? 'Unknown',
      phoneNumber: data['phone_number'] ?? '',
      age: data['age'],
      gender: data['gender'],
      address: data['address'],

      bookingType: data['booking_type'] ?? TYPE_GENERAL,
      // Fallback to old 'plan_selection' if 'interest_label' is missing
      interestLabel: data['interest_label'] ?? data['plan_selection'] ?? 'General',
      interestId: data['interest_id'],

      userMessage: data['user_message'] ?? '',
      notes: data['notes'] ?? '',

      source: data['source'] ?? SOURCE_MANUAL,
      status: data['status'] ?? 'NEW_LEAD',
      paymentStatus: data['payment_status'] ?? 'N/A',
      createdAt: (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}