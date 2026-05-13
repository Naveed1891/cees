-- Supabase Schema & Realtime Setup

-- 1. Enable UUID Extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 2. Create Teachers Table
CREATE TABLE teachers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,
    department TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 3. Create Rooms Table
CREATE TABLE rooms (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    capacity INTEGER NOT NULL,
    is_available BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 4. Create Courses Table
CREATE TABLE courses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title TEXT NOT NULL,
    code TEXT NOT NULL,
    teacher_id UUID REFERENCES teachers(id) ON DELETE RESTRICT,
    room_id UUID REFERENCES rooms(id) ON DELETE RESTRICT,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    day_of_week TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 5. Enable Row Level Security (RLS)
ALTER TABLE teachers ENABLE ROW LEVEL SECURITY;
ALTER TABLE rooms ENABLE ROW LEVEL SECURITY;
ALTER TABLE courses ENABLE ROW LEVEL SECURITY;

-- 6. Create RLS Policies
-- Allow public (anon) read-only access so the public dashboard works
CREATE POLICY "Allow public read-only access on teachers" ON teachers FOR SELECT USING (true);
CREATE POLICY "Allow public read-only access on rooms" ON rooms FOR SELECT USING (true);
CREATE POLICY "Allow public read-only access on courses" ON courses FOR SELECT USING (true);

-- Allow authenticated users to have full access (Create, Read, Update, Delete)
CREATE POLICY "Allow authenticated full access on teachers" ON teachers FOR ALL USING (auth.role() = 'authenticated');
CREATE POLICY "Allow authenticated full access on rooms" ON rooms FOR ALL USING (auth.role() = 'authenticated');
CREATE POLICY "Allow authenticated full access on courses" ON courses FOR ALL USING (auth.role() = 'authenticated');

-- 7. Enable Realtime for the tables used in the public dashboard
-- This enables changes to be pushed to the client immediately via WebSockets
ALTER PUBLICATION supabase_realtime ADD TABLE courses;
ALTER PUBLICATION supabase_realtime ADD TABLE rooms;
ALTER PUBLICATION supabase_realtime ADD TABLE teachers;
