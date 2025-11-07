// This file is a compatibility shim. The canonical meditation model lives in
// `lib/data/models/meditation_log.dart`. Keep this re-export while the codebase
// migrates old imports. Remove this file once all references use the canonical
// model directly.

// Re-export the canonical model
export 'meditation_log.dart';
