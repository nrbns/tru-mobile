import * as functions from "firebase-functions/v2";
import * as admin from "firebase-admin";

const region = "asia-south1";

/**
 * Cloud Function to populate exercise library with sample data
 * Run this once to seed the exercises collection
 */
export const populateExercises = functions.https.onRequest(
  { region, cors: true },
  async (req, res) => {
    // Verify admin or use admin SDK directly
    const firestore = admin.firestore();

    const exercises = [
    // Bodyweight Exercises
    {
      name: "Push-ups",
      muscle_groups: ["chest", "triceps", "shoulders"],
      equipment: ["bodyweight"],
      difficulty: "beginner",
      is_compound: true,
      video_url: "https://example.com/videos/push-ups.mp4",
      instructions: "Lower your body until chest nearly touches floor, then push back up.",
      tips: ["Keep core tight", "Don't let hips sag", "Full range of motion"],
    },
    {
      name: "Pull-ups",
      muscle_groups: ["back", "biceps"],
      equipment: ["pull-up bar"],
      difficulty: "intermediate",
      is_compound: true,
      video_url: "https://example.com/videos/pull-ups.mp4",
      instructions: "Hang from bar, pull body up until chin clears bar.",
      tips: ["Full range of motion", "Control the descent", "Engage lats"],
    },
    {
      name: "Bodyweight Squats",
      muscle_groups: ["quadriceps", "glutes"],
      equipment: ["bodyweight"],
      difficulty: "beginner",
      is_compound: true,
      video_url: "https://example.com/videos/squats.mp4",
      instructions: "Lower body by bending knees until thighs parallel to floor.",
      tips: ["Keep knees aligned", "Back straight", "Depth matters"],
    },
    {
      name: "Lunges",
      muscle_groups: ["quadriceps", "glutes", "hamstrings"],
      equipment: ["bodyweight"],
      difficulty: "beginner",
      is_compound: true,
      video_url: "https://example.com/videos/lunges.mp4",
      instructions: "Step forward and lower back knee toward ground.",
      tips: ["Front knee over ankle", "Keep torso upright"],
    },
    {
      name: "Plank",
      muscle_groups: ["core", "shoulders"],
      equipment: ["bodyweight"],
      difficulty: "beginner",
      is_compound: false,
      video_url: "https://example.com/videos/plank.mp4",
      instructions: "Hold body straight in push-up position, supported by forearms.",
      tips: ["Straight line head to heels", "Engage core", "Breathe normally"],
    },
    // Dumbbell Exercises
    {
      name: "Dumbbell Bench Press",
      muscle_groups: ["chest", "triceps", "shoulders"],
      equipment: ["dumbbells", "bench"],
      difficulty: "intermediate",
      is_compound: true,
      video_url: "https://example.com/videos/db-bench-press.mp4",
      instructions: "Press dumbbells up from chest level until arms extended.",
      tips: ["Control the weight", "Full range of motion", "Keep feet planted"],
    },
    {
      name: "Dumbbell Rows",
      muscle_groups: ["back", "biceps"],
      equipment: ["dumbbells", "bench"],
      difficulty: "intermediate",
      is_compound: true,
      video_url: "https://example.com/videos/db-rows.mp4",
      instructions: "Pull dumbbell to hip, squeeze back muscles at top.",
      tips: ["Keep core tight", "Don't swing", "Elbow close to body"],
    },
    {
      name: "Dumbbell Shoulder Press",
      muscle_groups: ["shoulders", "triceps"],
      equipment: ["dumbbells"],
      difficulty: "intermediate",
      is_compound: true,
      video_url: "https://example.com/videos/db-shoulder-press.mp4",
      instructions: "Press dumbbells overhead until arms fully extended.",
      tips: ["Core engaged", "Don't arch back excessively", "Control the descent"],
    },
    {
      name: "Dumbbell Bicep Curls",
      muscle_groups: ["biceps"],
      equipment: ["dumbbells"],
      difficulty: "beginner",
      is_compound: false,
      video_url: "https://example.com/videos/db-curls.mp4",
      instructions: "Curl dumbbells up by flexing biceps, lower slowly.",
      tips: ["Don't swing", "Full contraction", "Control the negative"],
    },
    {
      name: "Dumbbell Tricep Extension",
      muscle_groups: ["triceps"],
      equipment: ["dumbbells"],
      difficulty: "beginner",
      is_compound: false,
      video_url: "https://example.com/videos/db-tricep-ext.mp4",
      instructions: "Extend arms overhead, lower dumbbell behind head.",
      tips: ["Keep elbows stationary", "Full extension", "Control the movement"],
    },
    // Gym Equipment Exercises
    {
      name: "Barbell Bench Press",
      muscle_groups: ["chest", "triceps", "shoulders"],
      equipment: ["barbell", "bench"],
      difficulty: "intermediate",
      is_compound: true,
      video_url: "https://example.com/videos/bb-bench-press.mp4",
      instructions: "Lower bar to chest, press up until arms locked.",
      tips: ["Control the descent", "Full lockout", "Spotter for heavy weights"],
    },
    {
      name: "Barbell Squat",
      muscle_groups: ["quadriceps", "glutes", "hamstrings"],
      equipment: ["barbell", "squat rack"],
      difficulty: "intermediate",
      is_compound: true,
      video_url: "https://example.com/videos/bb-squat.mp4",
      instructions: "Lower body until thighs parallel, drive up through heels.",
      tips: ["Depth is key", "Keep back tight", "Knees out"],
    },
    {
      name: "Deadlift",
      muscle_groups: ["back", "glutes", "hamstrings"],
      equipment: ["barbell"],
      difficulty: "advanced",
      is_compound: true,
      video_url: "https://example.com/videos/deadlift.mp4",
      instructions: "Lift bar from ground, keep back straight, extend hips.",
      tips: ["Form over weight", "Neutral spine", "Hip hinge movement"],
    },
    {
      name: "Barbell Rows",
      muscle_groups: ["back", "biceps"],
      equipment: ["barbell"],
      difficulty: "intermediate",
      is_compound: true,
      video_url: "https://example.com/videos/bb-rows.mp4",
      instructions: "Pull bar to lower chest/upper abs, squeeze lats.",
      tips: ["Back straight", "Elbows close", "Full range"],
    },
    // Cardio/Functional
    {
      name: "Burpees",
      muscle_groups: ["full body"],
      equipment: ["bodyweight"],
      difficulty: "intermediate",
      is_compound: true,
      video_url: "https://example.com/videos/burpees.mp4",
      instructions: "Squat, jump back to plank, push-up, jump forward, jump up.",
      tips: ["Full extension on jump", "Stay controlled", "Modify if needed"],
    },
    {
      name: "Mountain Climbers",
      muscle_groups: ["core", "shoulders", "cardio"],
      equipment: ["bodyweight"],
      difficulty: "beginner",
      is_compound: true,
      video_url: "https://example.com/videos/mountain-climbers.mp4",
      instructions: "Alternate bringing knees to chest in plank position.",
      tips: ["Keep core tight", "Smooth rhythm", "Full range"],
    },
    ];

    try {
      const batch = firestore.batch();
      const exercisesRef = firestore.collection("exercises");

      exercises.forEach((exercise) => {
        const docRef = exercisesRef.doc();
        batch.set(docRef, {
          ...exercise,
          created_at: admin.firestore.FieldValue.serverTimestamp(),
        });
      });

      await batch.commit();

      res.status(200).json({
        success: true,
        message: `Added ${exercises.length} exercises to library`,
        count: exercises.length,
      });
    } catch (error: any) {
      console.error("Error populating exercises:", error);
      res.status(500).json({
        success: false,
        error: error.message || "Failed to populate exercises",
      });
    }
  }
);

