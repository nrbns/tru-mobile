import 'package:flutter/widgets.dart';
import 'package:lucide_icons/lucide_icons.dart' as orig;

/// Compatibility wrapper for `LucideIcons` used across the app.
///
/// This file defines a `LucideIcons` class with static constants
/// that delegate to the real icon definitions in the `lucide_icons`
/// package. Add mappings here for any missing or renamed icons.
class LucideIcons {
  LucideIcons._();

  // Common icons — delegate to the original package
  static const IconData arrowLeft = orig.LucideIcons.arrowLeft;
  static const IconData sparkles = orig.LucideIcons.sparkles;
  static const IconData music = orig.LucideIcons.music;
  static const IconData chevronRight = orig.LucideIcons.chevronRight;
  static const IconData headphones = orig.LucideIcons.headphones;
  static const IconData calendar = orig.LucideIcons.calendar;
  static const IconData calendarDays = orig.LucideIcons.calendarDays;
  static const IconData flame = orig.LucideIcons.flame;
  static const IconData heart = orig.LucideIcons.heart;
  static const IconData bookOpen = orig.LucideIcons.bookOpen;
  static const IconData moon = orig.LucideIcons.moon;
  static const IconData trophy = orig.LucideIcons.trophy;
  static const IconData trendingUp = orig.LucideIcons.trendingUp;
  static const IconData droplet = orig.LucideIcons.droplet;
  static const IconData zap = orig.LucideIcons.zap;
  static const IconData award = orig.LucideIcons.award;
  static const IconData dumbbell = orig.LucideIcons.dumbbell;
  static const IconData clock = orig.LucideIcons.clock;
  static const IconData play = orig.LucideIcons.play;
  static const IconData chevronLeft = orig.LucideIcons.chevronLeft;
  static const IconData phone = orig.LucideIcons.phone;
  static const IconData wind = orig.LucideIcons.wind;
  static const IconData brain = orig.LucideIcons.brain;
  static const IconData info = orig.LucideIcons.info;
  static const IconData lightbulb = orig.LucideIcons.lightbulb;
  static const IconData checkCircle = orig.LucideIcons.checkCircle;
  static const IconData circle = orig.LucideIcons.circle;
  static const IconData cross = orig.LucideIcons.cross;
  static const IconData mail = orig.LucideIcons.mail;
  static const IconData lock = orig.LucideIcons.lock;
  static const IconData playCircle = orig.LucideIcons.playCircle;
  static const IconData bot = orig.LucideIcons.bot;
  static const IconData moreVertical = orig.LucideIcons.moreVertical;
  static const IconData database = orig.LucideIcons.database;
  static const IconData user = orig.LucideIcons.user;
  static const IconData send = orig.LucideIcons.send;
  static const IconData save = orig.LucideIcons.save;
  static const IconData minus = orig.LucideIcons.minus;
  static const IconData plus = orig.LucideIcons.plus;
  static const IconData moreHorizontal = orig.LucideIcons.moreHorizontal;
  static const IconData awardAlt = orig.LucideIcons.award;
  static const IconData star = orig.LucideIcons.star;
  static const IconData helpCircle = orig.LucideIcons.helpCircle;
  static const IconData heartHandshake = orig.LucideIcons.heartHandshake;
  static const IconData fileText = orig.LucideIcons.fileText;
  static const IconData quote = orig.LucideIcons.quote;
  static const IconData volume2 = orig.LucideIcons.volume2;
  static const IconData share2 = orig.LucideIcons.share2;
  static const IconData bookmark = orig.LucideIcons.bookmark;
  static const IconData scanLine = orig.LucideIcons.scanLine;
  static const IconData camera = orig.LucideIcons.camera;
  static const IconData filter = orig.LucideIcons.filter;
  static const IconData home = orig.LucideIcons.home;
  static const IconData alertCircle = orig.LucideIcons.alertCircle;
  static const IconData messageCircle = orig.LucideIcons.messageCircle;
  static const IconData sun = orig.LucideIcons.sun;
  static const IconData activity = orig.LucideIcons.activity;
  static const IconData smile = orig.LucideIcons.smile;
  static const IconData meh = orig.LucideIcons.meh;
  static const IconData frown = orig.LucideIcons.frown;
  static const IconData angry = orig.LucideIcons.angry;
  static const IconData pause = orig.LucideIcons.pause;
  static const IconData skipBack = orig.LucideIcons.skipBack;
  static const IconData skipForward = orig.LucideIcons.skipForward;
  static const IconData square = orig.LucideIcons.square;
  static const IconData mapPin = orig.LucideIcons.mapPin;
  static const IconData bell = orig.LucideIcons.bell;
  static const IconData sliders = orig.LucideIcons.sliders;
  static const IconData barChart = orig.LucideIcons.barChart;
  static const IconData mic = orig.LucideIcons.mic;
  // Provide maximize/minimize aliases used in some screens; map to square as a safe fallback.
  static const IconData maximize = orig.LucideIcons.square;
  static const IconData minimize = orig.LucideIcons.square;
  static const IconData settings = orig.LucideIcons.settings;
  static const IconData edit = orig.LucideIcons.edit;
  static const IconData palette = orig.LucideIcons.palette;
  static const IconData shield = orig.LucideIcons.shield;
  static const IconData logOut = orig.LucideIcons.logOut;

  // Additional mappings discovered during build: provide fallbacks
  static const IconData stop = orig.LucideIcons.square;
  static const IconData loader = orig.LucideIcons.refreshCw;
  static const IconData messageSquare = orig.LucideIcons.messageCircle;
  static const IconData pauseCircle = orig.LucideIcons.pauseCircle;
  static const IconData x = orig.LucideIcons.x;
  static const IconData check = orig.LucideIcons.check;
  static const IconData search = orig.LucideIcons.search;

  // Names that the app used but the package didn't provide — map them
  // to reasonable fallbacks from the original icon set.
  static const IconData bookOpenText = orig.LucideIcons.bookOpen;
  static const IconData crescent = orig.LucideIcons.moon;
  static const IconData om = orig.LucideIcons.fileText;
  static const IconData lotus = orig.LucideIcons.sparkles;

  // More fallbacks for icons referenced in the app but not present in the
  // installed lucide_icons version. These map to reasonable existing icons
  // defined above to avoid scattered code edits across the repo.
  static const IconData apple = star;
  static const IconData trendingDown = trendingUp;
  static const IconData users = user;
  static const IconData arrowRight = chevronRight;
  static const IconData book = bookOpen;
  static const IconData library = bookOpen;
  static const IconData translate = fileText;
  static const IconData refreshCw = loader;
  static const IconData crown = award;
  static const IconData utensils = dumbbell;
  static const IconData sunrise = sun;
  static const IconData image = camera;
  static const IconData plusCircle = plus;
  static const IconData target = mapPin;
  static const IconData penTool = edit;
  static const IconData arrowDown = chevronLeft;
  static const IconData hand = brain;
  // Backwards-compatible mapping for an icon name used in the repo.
  // The original `lucide_icons` package may not expose `magicWand` in
  // the installed version; map it to `sparkles` as a reasonable fallback.
  static const IconData magicWand = sparkles;
}
