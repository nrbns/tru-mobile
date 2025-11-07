Wearables Integration — Architecture & Data Model

Overview

Device (Boat/Noise/bands) -> BLE GATT or vendor cloud
iPhone <-> Apple Watch via WatchConnectivity / HealthKit
Android devices: BLE + Google Fit

Mobile app (Flutter) receives device data, does lightweight validation/edge processing, timestamps, device metadata

Firebase: Authentication -> Firestore (realtime), Cloud Storage (raw files), Cloud Functions (aggregation & jobs), Firebase Analytics, Crashlytics, Cloud Messaging

Data model

/users/{uid}/devices/{deviceId}
- deviceId
- vendor
- model
- pairedAt
- lastSeen

/users/{uid}/telemetry/{docId}
- type: "heart_rate" | "steps" | "sleep" | "spo2" | "audio_noise_level" | "gps" | "accelerometer"
- deviceId
- value
- unit
- timestamp
- sampleRateHz
- quality
- batchId

/sessions/{sessionId}
- activityType
- startTime
- endTime
- devicesUsed
- summaryMetrics

Cloud Functions
- daily aggregator: populate /analytics/aggregates/{date_userid}
- alerts: high-noise exposure, arrhythmia detection (prototype)

Privacy & consent
- Explicit consent screens per data category
- Delete my data endpoint (Cloud Function) that deletes collections under /users/{uid}
- Store user mapping for vendor OAuth tokens securely in Firestore with restricted access rules

Sampling guidance & batching
- Heart rate: 1-5Hz for active sessions; 1 / 5-60s for background monitoring
- Buffer 30-300s and batch commit to Firestore

Implementation notes
- Use flutter_reactive_ble for BLE
- Use HealthKit and Google Fit as canonical aggregators
- Background: WorkManager for Android, background fetch/processing on iOS with proper entitlements

This document is a concise reference for the sprint implementation.
