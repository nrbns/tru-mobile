import * as admin from "firebase-admin";

// Initialize only if not already initialized (when called as standalone script)
if (!admin.apps.length) {
  admin.initializeApp();
}

const db = admin.firestore();

/**
 * Seed Spiritual Data - Populate Firestore with real spiritual content
 * Run: npm run seed or ts-node src/seedSpiritualData.ts
 */
export async function seedSpiritualData() {
  console.log("🌱 Seeding spiritual data...");

  // 1. Seed Affirmations
  const affirmations = [
    {
      type: "healing",
      text: "I am whole, I am healed, I am at peace with all that is.",
      category: "healing",
      repeatCount: 7,
    },
    {
      type: "healing",
      text: "Every cell in my body vibrates with divine light and healing energy.",
      category: "healing",
      repeatCount: 5,
    },
    {
      type: "confidence",
      text: "I trust myself and my inner wisdom guides me perfectly.",
      category: "confidence",
      repeatCount: 7,
    },
    {
      type: "confidence",
      text: "I am capable, strong, and worthy of all my dreams.",
      category: "confidence",
      repeatCount: 5,
    },
    {
      type: "abundance",
      text: "I am open to receiving all the blessings the universe has for me.",
      category: "abundance",
      repeatCount: 7,
    },
    {
      type: "peace",
      text: "I release all tension and surrender to inner peace.",
      category: "peace",
      repeatCount: 10,
    },
    {
      type: "gratitude",
      text: "I am grateful for every breath, every moment, every blessing.",
      category: "gratitude",
      repeatCount: 5,
    },
  ];

  for (const affirmation of affirmations) {
    await db.collection("affirmations").add(affirmation);
    console.log(`✅ Added affirmation: ${affirmation.text.substring(0, 30)}...`);
  }

  // 2. Seed Christian Scriptures
  const christianVerses = [
    {
      tradition: "christian",
      text: "For I know the plans I have for you, declares the Lord, plans to prosper you and not to harm you, plans to give you hope and a future.",
      translation: "NIV",
      book: "Jeremiah",
      chapter: 29,
      verse: 11,
      theme: "hope",
    },
    {
      tradition: "christian",
      text: "Be still, and know that I am God; I will be exalted among the nations, I will be exalted in the earth.",
      translation: "NIV",
      book: "Psalms",
      chapter: 46,
      verse: 10,
      theme: "peace",
    },
    {
      tradition: "christian",
      text: "The Lord is my shepherd; I shall not want. He makes me lie down in green pastures. He leads me beside still waters.",
      translation: "NIV",
      book: "Psalms",
      chapter: 23,
      verse: 1,
      theme: "comfort",
    },
    {
      tradition: "christian",
      text: "I can do all things through him who strengthens me.",
      translation: "NIV",
      book: "Philippians",
      chapter: 4,
      verse: 13,
      theme: "strength",
    },
    {
      tradition: "christian",
      text: "Cast all your anxiety on him because he cares for you.",
      translation: "NIV",
      book: "1 Peter",
      chapter: 5,
      verse: 7,
      theme: "anxiety",
    },
  ];

  for (const verse of christianVerses) {
    await db.collection("scriptures").add(verse);
    console.log(`✅ Added Christian verse: ${verse.book} ${verse.chapter}:${verse.verse}`);
  }

  // 3. Seed Islamic Ayahs
  const islamicAyahs = [
    {
      tradition: "islamic",
      text: "وَمَا خَلَقْتُ الْجِنَّ وَالْإِنْسَ إِلَّا لِيَعْبُدُونِ",
      translation: "And I did not create the jinn and mankind except to worship Me.",
      surah: "Adh-Dhariyat",
      ayah: 56,
      theme: "purpose",
    },
    {
      tradition: "islamic",
      text: "اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ",
      translation: "Allah - there is no deity except Him, the Ever-Living, the Sustainer of existence.",
      surah: "Al-Baqarah",
      ayah: 255,
      theme: "divinity",
    },
    {
      tradition: "islamic",
      text: "وَمَن يَتَّقِ اللَّهَ يَجْعَل لَّهُ مَخْرَجًا",
      translation: "And whoever fears Allah - He will make for him a way out.",
      surah: "At-Talaq",
      ayah: 2,
      theme: "hope",
    },
    {
      tradition: "islamic",
      text: "فَإِنَّ مَعَ الْعُسْرِ يُسْرًا",
      translation: "Indeed, with hardship comes ease.",
      surah: "Ash-Sharh",
      ayah: 5,
      theme: "patience",
    },
  ];

  for (const ayah of islamicAyahs) {
    await db.collection("scriptures").add(ayah);
    console.log(`✅ Added Islamic ayah: ${ayah.surah} ${ayah.ayah}`);
  }

  // 4. Seed Jewish Lessons
  const jewishLessons = [
    {
      tradition: "jewish",
      topic: "Tikkun Olam - Repairing the World",
      text: "The concept of Tikkun Olam teaches us that we each have a role in healing and repairing the world through acts of kindness, charity, and justice.",
      category: "Torah",
      references: ["Genesis 1:27", "Pirkei Avot 1:2"],
    },
    {
      tradition: "jewish",
      topic: "The Power of Gratitude",
      text: "Reciting daily blessings (brachot) helps us cultivate gratitude and recognize the divine in everyday moments.",
      category: "Halacha",
      references: ["Berachot 35a"],
    },
    {
      tradition: "jewish",
      topic: "Shabbat Rest",
      text: "Shabbat reminds us that rest is sacred and essential for spiritual renewal and human dignity.",
      category: "Torah",
      references: ["Exodus 20:8-11"],
    },
  ];

  for (const lesson of jewishLessons) {
    await db.collection("lessons").add(lesson);
    console.log(`✅ Added Jewish lesson: ${lesson.topic}`);
  }

  // 5. Seed Yoga Sessions
  const yogaSessions = [
    {
      name: "Morning Energizing Flow",
      level: "beginner",
      duration: 20,
      focus: "flexibility",
      equipment: ["mat"],
      poses: [
        { name: "Sun Salutation A", duration_sec: 120 },
        { name: "Warrior I", duration_sec: 60 },
        { name: "Warrior II", duration_sec: 60 },
        { name: "Tree Pose", duration_sec: 45 },
      ],
    },
    {
      name: "Evening Relaxation",
      level: "beginner",
      duration: 15,
      focus: "relaxation",
      equipment: ["mat"],
      poses: [
        { name: "Child's Pose", duration_sec: 120 },
        { name: "Cat-Cow", duration_sec: 90 },
        { name: "Supine Twist", duration_sec: 90 },
        { name: "Savasana", duration_sec: 300 },
      ],
    },
    {
      name: "Strength Builder",
      level: "intermediate",
      duration: 30,
      focus: "strength",
      equipment: ["mat"],
      poses: [
        { name: "Plank", duration_sec: 60 },
        { name: "Chaturanga", duration_sec: 30 },
        { name: "Downward Dog", duration_sec: 60 },
        { name: "Warrior III", duration_sec: 45 },
      ],
    },
  ];

  for (const session of yogaSessions) {
    await db.collection("yoga_sessions").add(session);
    console.log(`✅ Added yoga session: ${session.name}`);
  }

  // 6. Seed Mantras (for mantras collection)
  const mantras = [
    {
      tradition: "hinduism",
      text: "ॐ नमो भगवते वासुदेवाय",
      translation: "Om Namo Bhagavate Vasudevaya",
      meaning: "I bow to the Divine within",
      category: "devotional",
      repetitions: 108,
    },
    {
      tradition: "hinduism",
      text: "ॐ शान्ति शान्ति शान्ति",
      translation: "Om Shanti Shanti Shanti",
      meaning: "Peace, peace, peace",
      category: "peace",
      repetitions: 108,
    },
    {
      tradition: "buddhism",
      text: "Om Mani Padme Hum",
      translation: "The jewel is in the lotus",
      meaning: "Compassion and wisdom united",
      category: "compassion",
      repetitions: 108,
    },
    {
      tradition: "buddhism",
      text: "Om Tare Tuttare Ture Soha",
      translation: "I prostrate to Tara who liberates",
      meaning: "Protection and swift action",
      category: "protection",
      repetitions: 21,
    },
  ];

  for (const mantra of mantras) {
    await db.collection("mantras").add(mantra);
    console.log(`✅ Added mantra: ${mantra.translation}`);
  }

  // 7. Seed Sacred Verses
  const sacredVerses = [
    {
      tradition: "hinduism",
      verse: "योगस्थ: कुरु कर्माणि संगं त्यक्त्वा धनञ्जय | सिद्ध्यसिद्ध्यो: समो भूत्वा समत्वं योग उच्यते ||",
      translation: "Perform your duty with equanimity, Arjuna, abandoning all attachment to success or failure. Such equanimity is called yoga.",
      source: "Bhagavad Gita",
      chapter: "2",
      verse_number: "48",
    },
    {
      tradition: "hinduism",
      verse: "शान्ति: शान्ति: शान्ति:",
      translation: "Peace, peace, peace",
      source: "Vedic Prayer",
      chapter: null,
      verse_number: null,
    },
  ];

  for (const verse of sacredVerses) {
    await db.collection("sacred_verses").add(verse);
    console.log(`✅ Added sacred verse: ${verse.source}`);
  }

  console.log("✨ Spiritual data seeding complete!");
}

// Run if called directly
if (require.main === module) {
  seedSpiritualData()
    .then(() => {
      console.log("✅ Seeding finished successfully");
      process.exit(0);
    })
    .catch((error) => {
      console.error("❌ Seeding error:", error);
      process.exit(1);
    });
}

