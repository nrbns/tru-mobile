-- TruResetX v1.0 Database Schema
-- Production-ready Supabase setup

-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Users table (extends Supabase auth.users)
CREATE TABLE public.users (
    id UUID REFERENCES auth.users(id) PRIMARY KEY,
    email TEXT UNIQUE NOT NULL,
    name TEXT,
    age INTEGER,
    gender TEXT CHECK (gender IN ('male', 'female', 'other')),
    height INTEGER, -- in cm
    weight DECIMAL(5,2), -- in kg
    goal TEXT CHECK (goal IN ('weight_loss', 'muscle_gain', 'fitness', 'mental_health', 'spiritual_growth')),
    plan_id UUID,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Workout plans
CREATE TABLE public.workout_plans (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    description TEXT,
    duration_weeks INTEGER DEFAULT 4,
    difficulty TEXT CHECK (difficulty IN ('beginner', 'intermediate', 'advanced')),
    focus TEXT CHECK (focus IN ('strength', 'cardio', 'flexibility', 'mindfulness', 'holistic')),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Workouts
CREATE TABLE public.workouts (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
    plan_id UUID REFERENCES public.workout_plans(id) ON DELETE SET NULL,
    date DATE NOT NULL,
    title TEXT NOT NULL,
    duration INTEGER, -- in minutes
    calories_burned INTEGER,
    ar_score DECIMAL(3,2), -- 0.00 to 1.00
    mood_before INTEGER CHECK (mood_before >= 1 AND mood_before <= 10),
    mood_after INTEGER CHECK (mood_after >= 1 AND mood_after <= 10),
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Exercises
CREATE TABLE public.exercises (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    workout_id UUID REFERENCES public.workouts(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    reps INTEGER,
    sets INTEGER,
    weight DECIMAL(5,2), -- in kg
    duration INTEGER, -- in seconds
    form_score DECIMAL(3,2), -- 0.00 to 1.00
    rest_time INTEGER, -- in seconds
    order_index INTEGER,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Food logs
CREATE TABLE public.food_logs (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
    date DATE NOT NULL,
    meal_type TEXT CHECK (meal_type IN ('breakfast', 'lunch', 'dinner', 'snack')),
    food_name TEXT NOT NULL,
    image_url TEXT,
    calories INTEGER,
    protein DECIMAL(5,2), -- in grams
    carbs DECIMAL(5,2), -- in grams
    fat DECIMAL(5,2), -- in grams
    fiber DECIMAL(5,2), -- in grams
    sugar DECIMAL(5,2), -- in grams
    sodium DECIMAL(5,2), -- in mg
    serving_size TEXT,
    confidence_score DECIMAL(3,2), -- AI confidence 0.00 to 1.00
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Mood logs
CREATE TABLE public.mood_logs (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
    date DATE NOT NULL,
    mood_score INTEGER CHECK (mood_score >= 1 AND mood_score <= 10),
    energy_level INTEGER CHECK (energy_level >= 1 AND energy_level <= 10),
    stress_level INTEGER CHECK (stress_level >= 1 AND stress_level <= 10),
    sleep_quality INTEGER CHECK (sleep_quality >= 1 AND sleep_quality <= 10),
    notes TEXT,
    tags TEXT[], -- array of mood tags
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Meditation logs
CREATE TABLE public.meditation_logs (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
    date DATE NOT NULL,
    duration INTEGER NOT NULL, -- in minutes
    type TEXT CHECK (type IN ('meditation', 'breathwork', 'mindfulness', 'visualization')),
    session_name TEXT,
    mood_before INTEGER CHECK (mood_before >= 1 AND mood_before <= 10),
    mood_after INTEGER CHECK (mood_after >= 1 AND mood_after <= 10),
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Chat history with AI coach
CREATE TABLE public.chat_history (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
    role TEXT CHECK (role IN ('user', 'assistant', 'system')),
    message TEXT NOT NULL,
    persona TEXT CHECK (persona IN ('astra', 'sage', 'fuel', 'general')),
    session_id UUID,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- User goals and streaks
CREATE TABLE public.user_goals (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
    category TEXT CHECK (category IN ('fitness', 'nutrition', 'mental_health', 'spiritual', 'sleep')),
    goal_text TEXT NOT NULL,
    target_value DECIMAL(10,2),
    current_value DECIMAL(10,2) DEFAULT 0,
    unit TEXT,
    target_date DATE,
    is_completed BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- User streaks
CREATE TABLE public.user_streaks (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
    category TEXT CHECK (category IN ('workouts', 'meditation', 'mood_logging', 'nutrition_logging')),
    current_streak INTEGER DEFAULT 0,
    longest_streak INTEGER DEFAULT 0,
    last_activity_date DATE,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, category)
);

-- Notifications
CREATE TABLE public.notifications (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    body TEXT NOT NULL,
    type TEXT CHECK (type IN ('reminder', 'achievement', 'motivation', 'system')),
    scheduled_time TIMESTAMP WITH TIME ZONE,
    sent_time TIMESTAMP WITH TIME ZONE,
    is_read BOOLEAN DEFAULT false,
    action_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Daily summaries (AI-generated)
CREATE TABLE public.daily_summaries (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
    date DATE NOT NULL,
    summary_text TEXT NOT NULL,
    wellness_score DECIMAL(3,2), -- 0.00 to 1.00
    achievements TEXT[],
    recommendations TEXT[],
    mood_trend TEXT,
    energy_trend TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, date)
);

-- Create indexes for better performance
CREATE INDEX idx_workouts_user_date ON public.workouts(user_id, date DESC);
CREATE INDEX idx_food_logs_user_date ON public.food_logs(user_id, date DESC);
CREATE INDEX idx_mood_logs_user_date ON public.mood_logs(user_id, date DESC);
CREATE INDEX idx_meditation_logs_user_date ON public.meditation_logs(user_id, date DESC);
CREATE INDEX idx_chat_history_user_session ON public.chat_history(user_id, session_id);
CREATE INDEX idx_notifications_user_scheduled ON public.notifications(user_id, scheduled_time);

-- Row Level Security (RLS) policies
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.workout_plans ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.workouts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.exercises ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.food_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.mood_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.meditation_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.chat_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_goals ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_streaks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.daily_summaries ENABLE ROW LEVEL SECURITY;

-- RLS Policies - Users can only access their own data
CREATE POLICY "Users can view own profile" ON public.users FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Users can update own profile" ON public.users FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can manage own workout plans" ON public.workout_plans FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "Users can manage own workouts" ON public.workouts FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "Users can manage own exercises" ON public.exercises FOR ALL USING (auth.uid() = (SELECT user_id FROM public.workouts WHERE id = workout_id));

CREATE POLICY "Users can manage own food logs" ON public.food_logs FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "Users can manage own mood logs" ON public.mood_logs FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "Users can manage own meditation logs" ON public.meditation_logs FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "Users can manage own chat history" ON public.chat_history FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "Users can manage own goals" ON public.user_goals FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "Users can manage own streaks" ON public.user_streaks FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "Users can manage own notifications" ON public.notifications FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "Users can manage own daily summaries" ON public.daily_summaries FOR ALL USING (auth.uid() = user_id);

-- Functions for automatic updates
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON public.users FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_user_streaks_updated_at BEFORE UPDATE ON public.user_streaks FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Function to update user streaks
CREATE OR REPLACE FUNCTION update_user_streak(
    p_user_id UUID,
    p_category TEXT,
    p_activity_date DATE
)
RETURNS VOID AS $$
DECLARE
    current_streak INTEGER;
    last_activity DATE;
BEGIN
    -- Get current streak info
    SELECT current_streak, last_activity_date 
    INTO current_streak, last_activity
    FROM public.user_streaks 
    WHERE user_id = p_user_id AND category = p_category;
    
    -- If no streak record exists, create one
    IF NOT FOUND THEN
        INSERT INTO public.user_streaks (user_id, category, current_streak, longest_streak, last_activity_date)
        VALUES (p_user_id, p_category, 1, 1, p_activity_date);
        RETURN;
    END IF;
    
    -- Check if this is a consecutive day
    IF last_activity = p_activity_date - INTERVAL '1 day' THEN
        -- Consecutive day - increment streak
        current_streak := current_streak + 1;
    ELSIF last_activity < p_activity_date - INTERVAL '1 day' THEN
        -- Gap in streak - reset to 1
        current_streak := 1;
    ELSE
        -- Same day - don't change streak
        RETURN;
    END IF;
    
    -- Update or insert streak
    INSERT INTO public.user_streaks (user_id, category, current_streak, longest_streak, last_activity_date)
    VALUES (p_user_id, p_category, current_streak, GREATEST(current_streak, COALESCE((SELECT longest_streak FROM public.user_streaks WHERE user_id = p_user_id AND category = p_category), 0)), p_activity_date)
    ON CONFLICT (user_id, category)
    DO UPDATE SET 
        current_streak = EXCLUDED.current_streak,
        longest_streak = GREATEST(EXCLUDED.longest_streak, user_streaks.longest_streak),
        last_activity_date = EXCLUDED.last_activity_date,
        updated_at = NOW();
END;
$$ LANGUAGE plpgsql;

-- Triggers to automatically update streaks
CREATE OR REPLACE FUNCTION trigger_update_workout_streak()
RETURNS TRIGGER AS $$
BEGIN
    PERFORM update_user_streak(NEW.user_id, 'workouts', NEW.date::DATE);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION trigger_update_meditation_streak()
RETURNS TRIGGER AS $$
BEGIN
    PERFORM update_user_streak(NEW.user_id, 'meditation', NEW.date::DATE);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION trigger_update_mood_logging_streak()
RETURNS TRIGGER AS $$
BEGIN
    PERFORM update_user_streak(NEW.user_id, 'mood_logging', NEW.date::DATE);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION trigger_update_nutrition_logging_streak()
RETURNS TRIGGER AS $$
BEGIN
    PERFORM update_user_streak(NEW.user_id, 'nutrition_logging', NEW.date::DATE);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_workout_streak_trigger 
    AFTER INSERT ON public.workouts 
    FOR EACH ROW EXECUTE FUNCTION trigger_update_workout_streak();

CREATE TRIGGER update_meditation_streak_trigger 
    AFTER INSERT ON public.meditation_logs 
    FOR EACH ROW EXECUTE FUNCTION trigger_update_meditation_streak();

CREATE TRIGGER update_mood_logging_streak_trigger 
    AFTER INSERT ON public.mood_logs 
    FOR EACH ROW EXECUTE FUNCTION trigger_update_mood_logging_streak();

CREATE TRIGGER update_nutrition_logging_streak_trigger 
    AFTER INSERT ON public.food_logs 
    FOR EACH ROW EXECUTE FUNCTION trigger_update_nutrition_logging_streak();
