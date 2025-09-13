# Real-time Chat Application

A modern, real-time chat application built with React, TypeScript, and Supabase.

## Features

- 🔐 User authentication (sign up/sign in)
- 💬 Real-time messaging
- 👥 Multiple chat rooms
- 🎨 Modern, responsive UI
- 🌙 Dark mode support
- ⚡ Real-time updates with Supabase

## Tech Stack

- **Frontend**: React 18, TypeScript, Vite
- **Styling**: Tailwind CSS
- **Backend**: Supabase (PostgreSQL, Auth, Real-time)
- **Icons**: Lucide React

## Getting Started

### Prerequisites

- Node.js 18+ 
- npm or yarn
- Supabase account

### Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/chat-app.git
cd chat-app
```

2. Install dependencies:
```bash
npm install
```

3. Set up Supabase:
   - Create a new project at [supabase.com](https://supabase.com)
   - Go to Settings → API
   - Copy your Project URL and anon key

4. Configure environment variables:
```bash
cp .env.example .env
# Edit .env with your Supabase credentials
```

5. Run the database migration:
   - Go to your Supabase dashboard
   - Navigate to SQL Editor
   - Run the migration file: `supabase/migrations/20250913160727_orange_pine.sql`

6. Start the development server:
```bash
npm run dev
```

7. Open [http://localhost:5173](http://localhost:5173) in your browser

## Project Structure

```
src/
├── components/          # React components
│   ├── AuthForm.tsx    # Authentication form
│   ├── ChatInterface.tsx # Main chat interface
│   ├── ChatWindow.tsx  # Chat window component
│   ├── MessageList.tsx # Message display
│   ├── Sidebar.tsx     # Sidebar with rooms
│   └── UserList.tsx    # Online users
├── lib/
│   └── supabase.ts     # Supabase client
└── utils/
    └── dateUtils.ts    # Date formatting utilities
```

## Environment Variables

Create a `.env` file in the root directory:

```env
VITE_SUPABASE_URL=your_supabase_project_url
VITE_SUPABASE_ANON_KEY=your_supabase_anon_key
```

## Database Schema

The application uses the following main tables:
- `profiles` - User profiles
- `chat_rooms` - Chat rooms/channels
- `messages` - Chat messages
- `room_members` - Room membership
- `message_reactions` - Message reactions

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## License

MIT License - see LICENSE file for details
