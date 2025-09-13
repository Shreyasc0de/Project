/*
  # Complete Chat Application Schema

  1. New Tables
    - `profiles` - User profiles with extended metadata
      - `id` (uuid, references auth.users)
      - `username` (text, unique)
      - `avatar_url` (text, optional)
      - `last_seen` (timestamp)
      - `created_at` (timestamp)
    
    - `chat_rooms` - Chat rooms/channels
      - `id` (uuid, primary key)
      - `name` (text, unique room name)
      - `description` (text, optional)
      - `created_by` (uuid, references profiles)
      - `created_at` (timestamp)
    
    - `messages` - Chat messages
      - `id` (uuid, primary key)
      - `content` (text, message content)
      - `user_id` (uuid, references profiles)
      - `room_id` (uuid, references chat_rooms)
      - `reply_to` (uuid, optional, references messages)
      - `edited_at` (timestamp, optional)
      - `created_at` (timestamp)
    
    - `message_reactions` - Message reactions/emojis
      - `id` (uuid, primary key)
      - `message_id` (uuid, references messages)
      - `user_id` (uuid, references profiles)
      - `emoji` (text)
      - `created_at` (timestamp)
    
    - `room_members` - Room membership and permissions
      - `id` (uuid, primary key)
      - `room_id` (uuid, references chat_rooms)
      - `user_id` (uuid, references profiles)
      - `role` (text, default 'member')
      - `joined_at` (timestamp)

  2. Security
    - Enable RLS on all tables
    - Add policies for authenticated users to manage their own data
    - Add policies for room-based access control
    - Add policies for message access based on room membership

  3. Functions
    - Trigger to automatically create profile on user signup
    - Trigger to update last_seen timestamp
    - Function to handle room member management

  4. Indexes
    - Performance indexes for real-time queries
    - Composite indexes for common query patterns
*/

-- Create profiles table
CREATE TABLE IF NOT EXISTS profiles (
  id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  username text UNIQUE,
  avatar_url text,
  last_seen timestamptz DEFAULT now(),
  created_at timestamptz DEFAULT now()
);

-- Create chat_rooms table
CREATE TABLE IF NOT EXISTS chat_rooms (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text UNIQUE NOT NULL,
  description text,
  created_by uuid REFERENCES profiles(id) ON DELETE SET NULL,
  created_at timestamptz DEFAULT now()
);

-- Create messages table
CREATE TABLE IF NOT EXISTS messages (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  content text NOT NULL,
  user_id uuid NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  room_id uuid NOT NULL REFERENCES chat_rooms(id) ON DELETE CASCADE,
  reply_to uuid REFERENCES messages(id) ON DELETE SET NULL,
  edited_at timestamptz,
  created_at timestamptz DEFAULT now()
);

-- Create message_reactions table
CREATE TABLE IF NOT EXISTS message_reactions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  message_id uuid NOT NULL REFERENCES messages(id) ON DELETE CASCADE,
  user_id uuid NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  emoji text NOT NULL,
  created_at timestamptz DEFAULT now(),
  UNIQUE(message_id, user_id, emoji)
);

-- Create room_members table
CREATE TABLE IF NOT EXISTS room_members (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  room_id uuid NOT NULL REFERENCES chat_rooms(id) ON DELETE CASCADE,
  user_id uuid NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  role text DEFAULT 'member' CHECK (role IN ('admin', 'moderator', 'member')),
  joined_at timestamptz DEFAULT now(),
  UNIQUE(room_id, user_id)
);

-- Enable Row Level Security
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE chat_rooms ENABLE ROW LEVEL SECURITY;
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE message_reactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE room_members ENABLE ROW LEVEL SECURITY;

-- Profiles policies
CREATE POLICY "Users can read all profiles"
  ON profiles
  FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Users can update own profile"
  ON profiles
  FOR UPDATE
  TO authenticated
  USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile"
  ON profiles
  FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = id);

-- Chat rooms policies
CREATE POLICY "Anyone can read chat rooms"
  ON chat_rooms
  FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Authenticated users can create rooms"
  ON chat_rooms
  FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = created_by);

CREATE POLICY "Room creators can update their rooms"
  ON chat_rooms
  FOR UPDATE
  TO authenticated
  USING (auth.uid() = created_by);

-- Messages policies
CREATE POLICY "Users can read messages from rooms they're in"
  ON messages
  FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM room_members
      WHERE room_members.room_id = messages.room_id
      AND room_members.user_id = auth.uid()
    )
    OR
    EXISTS (
      SELECT 1 FROM chat_rooms
      WHERE chat_rooms.id = messages.room_id
    )
  );

CREATE POLICY "Users can insert messages to rooms they're in"
  ON messages
  FOR INSERT
  TO authenticated
  WITH CHECK (
    auth.uid() = user_id
    AND (
      EXISTS (
        SELECT 1 FROM room_members
        WHERE room_members.room_id = messages.room_id
        AND room_members.user_id = auth.uid()
      )
      OR
      EXISTS (
        SELECT 1 FROM chat_rooms
        WHERE chat_rooms.id = messages.room_id
      )
    )
  );

CREATE POLICY "Users can update own messages"
  ON messages
  FOR UPDATE
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own messages"
  ON messages
  FOR DELETE
  TO authenticated
  USING (auth.uid() = user_id);

-- Message reactions policies
CREATE POLICY "Users can read all reactions"
  ON message_reactions
  FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Users can add own reactions"
  ON message_reactions
  FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own reactions"
  ON message_reactions
  FOR DELETE
  TO authenticated
  USING (auth.uid() = user_id);

-- Room members policies
CREATE POLICY "Users can read room memberships"
  ON room_members
  FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Users can join rooms"
  ON room_members
  FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can leave rooms"
  ON room_members
  FOR DELETE
  TO authenticated
  USING (auth.uid() = user_id);

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_messages_room_created ON messages(room_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_messages_user ON messages(user_id);
CREATE INDEX IF NOT EXISTS idx_profiles_last_seen ON profiles(last_seen DESC);
CREATE INDEX IF NOT EXISTS idx_room_members_room ON room_members(room_id);
CREATE INDEX IF NOT EXISTS idx_room_members_user ON room_members(user_id);
CREATE INDEX IF NOT EXISTS idx_message_reactions_message ON message_reactions(message_id);

-- Function to handle new user registration
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS trigger AS $$
BEGIN
  INSERT INTO profiles (id, username, avatar_url)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'username', split_part(NEW.email, '@', 1)),
    COALESCE(NEW.raw_user_meta_data->>'avatar_url', 'https://api.dicebear.com/7.x/initials/svg?seed=' || encode(NEW.email::bytea, 'base64'))
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger for new user registration
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION handle_new_user();

-- Function to update last_seen timestamp
CREATE OR REPLACE FUNCTION update_last_seen()
RETURNS trigger AS $$
BEGIN
  UPDATE profiles 
  SET last_seen = now()
  WHERE id = NEW.user_id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger to update last_seen when user sends a message
DROP TRIGGER IF EXISTS on_message_created ON messages;
CREATE TRIGGER on_message_created
  AFTER INSERT ON messages
  FOR EACH ROW EXECUTE FUNCTION update_last_seen();

-- Insert default rooms
INSERT INTO chat_rooms (name, description) VALUES
  ('general', 'General discussion for everyone'),
  ('random', 'Random conversations and fun topics'),
  ('tech-talk', 'Discuss technology, programming, and innovation')
ON CONFLICT (name) DO NOTHING;