import React, { useState, useEffect } from 'react';
import { User } from '@supabase/supabase-js';
import Sidebar from './Sidebar';
import ChatWindow from './ChatWindow';
import UserList from './UserList';
import { supabase } from '../lib/supabase';

interface ChatRoom {
  id: string;
  name: string;
  description?: string;
  created_at: string;
}

interface ChatInterfaceProps {
  user: User;
}

const ChatInterface: React.FC<ChatInterfaceProps> = ({ user }) => {
  const [rooms, setRooms] = useState<ChatRoom[]>([]);
  const [activeRoom, setActiveRoom] = useState<ChatRoom | null>(null);
  const [sidebarOpen, setSidebarOpen] = useState(true);

  useEffect(() => {
    fetchRooms();
  }, []);

  const fetchRooms = async () => {
    const { data, error } = await supabase
      .from('chat_rooms')
      .select('*')
      .order('created_at', { ascending: true });

    if (!error && data) {
      setRooms(data);
      if (data.length > 0 && !activeRoom) {
        setActiveRoom(data[0]);
      }
    }
  };

  const createRoom = async (name: string, description?: string) => {
    const { data, error } = await supabase
      .from('chat_rooms')
      .insert([{ name, description }])
      .select()
      .single();

    if (!error && data) {
      setRooms(prev => [...prev, data]);
      setActiveRoom(data);
    }
  };

  return (
    <div className="flex h-screen bg-white dark:bg-gray-900">
      <Sidebar
        user={user}
        rooms={rooms}
        activeRoom={activeRoom}
        onRoomSelect={setActiveRoom}
        onCreateRoom={createRoom}
        isOpen={sidebarOpen}
        onToggle={() => setSidebarOpen(!sidebarOpen)}
      />
      
      <div className="flex-1 flex">
        <ChatWindow
          user={user}
          room={activeRoom}
          sidebarOpen={sidebarOpen}
          onToggleSidebar={() => setSidebarOpen(!sidebarOpen)}
        />
        <UserList room={activeRoom} />
      </div>
    </div>
  );
};

export default ChatInterface;