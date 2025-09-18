-- Создание таблиц для приложения BallersBestBuddy
-- Выполните эти команды в SQL Editor нового проекта Supabase

-- 1. Таблица групп
CREATE TABLE groups (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT,
    color TEXT DEFAULT '#3B82F6',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. Таблица игроков
CREATE TABLE players (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name TEXT NOT NULL,
    birth_date DATE,
    login TEXT NOT NULL UNIQUE,
    password TEXT,
    total_points INTEGER DEFAULT 0,
    attendance_count INTEGER DEFAULT 0,
    avatar_url TEXT,
    group_id UUID REFERENCES groups(id) ON DELETE SET NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. Таблица тренировок
CREATE TABLE training_sessions (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    date DATE NOT NULL,
    title TEXT NOT NULL,
    group_id UUID REFERENCES groups(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 4. Таблица посещаемости
CREATE TABLE attendance (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    player_id UUID NOT NULL REFERENCES players(id) ON DELETE CASCADE,
    session_id UUID NOT NULL REFERENCES training_sessions(id) ON DELETE CASCADE,
    attended BOOLEAN DEFAULT FALSE,
    points INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(player_id, session_id)
);

-- 5. Таблица расписания тренировок
CREATE TABLE training_schedules (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    group_id UUID NOT NULL REFERENCES groups(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    weekdays INTEGER[] NOT NULL, -- массив дней недели (1-7)
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 6. Таблица запланированных тренировок
CREATE TABLE scheduled_trainings (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    group_id UUID NOT NULL REFERENCES groups(id) ON DELETE CASCADE,
    date DATE NOT NULL,
    title TEXT NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    schedule_id UUID REFERENCES training_schedules(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Создание индексов для оптимизации запросов
CREATE INDEX idx_players_group_id ON players(group_id);
CREATE INDEX idx_players_login ON players(login);
CREATE INDEX idx_training_sessions_group_id ON training_sessions(group_id);
CREATE INDEX idx_training_sessions_date ON training_sessions(date);
CREATE INDEX idx_attendance_player_id ON attendance(player_id);
CREATE INDEX idx_attendance_session_id ON attendance(session_id);
CREATE INDEX idx_training_schedules_group_id ON training_schedules(group_id);
CREATE INDEX idx_scheduled_trainings_group_id ON scheduled_trainings(group_id);
CREATE INDEX idx_scheduled_trainings_date ON scheduled_trainings(date);

-- Включение Row Level Security (RLS)
ALTER TABLE groups ENABLE ROW LEVEL SECURITY;
ALTER TABLE players ENABLE ROW LEVEL SECURITY;
ALTER TABLE training_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE attendance ENABLE ROW LEVEL SECURITY;
ALTER TABLE training_schedules ENABLE ROW LEVEL SECURITY;
ALTER TABLE scheduled_trainings ENABLE ROW LEVEL SECURITY;

-- Политики безопасности (разрешаем все операции для анонимных пользователей)
-- В продакшене рекомендуется настроить более строгие политики
CREATE POLICY "Enable all operations for all users" ON groups FOR ALL USING (true);
CREATE POLICY "Enable all operations for all users" ON players FOR ALL USING (true);
CREATE POLICY "Enable all operations for all users" ON training_sessions FOR ALL USING (true);
CREATE POLICY "Enable all operations for all users" ON attendance FOR ALL USING (true);
CREATE POLICY "Enable all operations for all users" ON training_schedules FOR ALL USING (true);
CREATE POLICY "Enable all operations for all users" ON scheduled_trainings FOR ALL USING (true);

-- Создание Storage bucket для аватаров
INSERT INTO storage.buckets (id, name, public) VALUES ('avatars', 'avatars', true);

-- Политика для Storage bucket
CREATE POLICY "Public Access" ON storage.objects FOR SELECT USING (bucket_id = 'avatars');
CREATE POLICY "Public Upload" ON storage.objects FOR INSERT WITH CHECK (bucket_id = 'avatars');
CREATE POLICY "Public Update" ON storage.objects FOR UPDATE USING (bucket_id = 'avatars');
CREATE POLICY "Public Delete" ON storage.objects FOR DELETE USING (bucket_id = 'avatars');
