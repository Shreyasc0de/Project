# Real-time Chat Application

A modern, real-time chat application built with React, TypeScript, and Supabase. Features secure user authentication, real-time messaging, multiple chat rooms, and a beautiful responsive interface.

## ✨ Features

- 🔐 **Secure Authentication** - User registration and login with Supabase Auth
- 💬 **Real-time Messaging** - Instant message delivery and updates
- 👥 **Multiple Chat Rooms** - Create and join different conversation channels
- 🎨 **Modern UI/UX** - Clean, responsive design with dark mode support
- ⚡ **Real-time Updates** - Live user presence and message synchronization
- 🔒 **Row Level Security** - Secure data access with PostgreSQL policies
- 📱 **Mobile Responsive** - Works perfectly on all device sizes

## 🛠️ Tech Stack

- **Frontend**: React 18, TypeScript, Vite
- **Styling**: Tailwind CSS with custom components
- **Backend**: Supabase (PostgreSQL, Auth, Real-time subscriptions)
- **Icons**: Lucide React
- **State Management**: React hooks and context

## 🚀 Quick Start

### Prerequisites

- Node.js 18 or higher
- npm or yarn package manager
- Supabase account (free tier available)

### Installation

1. **Clone the repository:**
```bash
git clone https://github.com/Shreyasc0de/Project.git
cd Project
```

2. **Install dependencies:**
```bash
npm install
```

3. **Set up Supabase:**
   - Create a new project at [supabase.com](https://supabase.com)
   - Go to Settings → API
   - Copy your Project URL and anon key

4. **Configure environment variables:**
```bash
# Create .env file with your Supabase credentials
VITE_SUPABASE_URL=your_supabase_project_url
VITE_SUPABASE_ANON_KEY=your_supabase_anon_key
```

5. **Set up the database:**
   - Go to your Supabase dashboard
   - Navigate to SQL Editor
   - Copy and run the migration from `supabase/migrations/20250913160727_orange_pine.sql`

6. **Start the development server:**
```bash
npm run dev
```

7. **Open your browser:**
   - Navigate to [http://localhost:5173](http://localhost:5173)
   - Create an account and start chatting!

## 📁 Project Structure

```
src/
├── components/          # React components
│   ├── AuthForm.tsx    # User authentication form
│   ├── ChatInterface.tsx # Main chat application interface
│   ├── ChatWindow.tsx  # Individual chat room window
│   ├── MessageList.tsx # Message display and management
│   ├── Sidebar.tsx     # Navigation sidebar with rooms
│   ├── TypingIndicator.tsx # Real-time typing indicators
│   └── UserList.tsx    # Online users display
├── lib/
│   └── supabase.ts     # Supabase client configuration
├── utils/
│   └── dateUtils.ts    # Date and time formatting utilities
└── App.tsx             # Main application component
```

## 🗄️ Database Schema

The application uses a robust PostgreSQL schema with the following key tables:

- **`profiles`** - User profile information and metadata
- **`chat_rooms`** - Chat room definitions and settings
- **`messages`** - Individual chat messages with threading support
- **`room_members`** - User membership and permissions for each room
- **`message_reactions`** - Emoji reactions on messages

All tables include Row Level Security (RLS) policies for secure data access.

## 🔧 Environment Variables

Create a `.env` file in the root directory with your Supabase credentials:

```env
VITE_SUPABASE_URL=your_supabase_project_url
VITE_SUPABASE_ANON_KEY=your_supabase_anon_key
```

## 🚀 Deployment

### Vercel (Recommended)
1. Connect your GitHub repository to Vercel
2. Add environment variables in Vercel dashboard
3. Deploy automatically on every push

### Netlify
1. Connect your GitHub repository to Netlify
2. Set build command: `npm run build`
3. Set publish directory: `dist`
4. Add environment variables in Netlify dashboard

### Manual Deployment
```bash
npm run build
# Upload the 'dist' folder to your hosting provider
```

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Built with [React](https://reactjs.org/) and [TypeScript](https://www.typescriptlang.org/)
- Styled with [Tailwind CSS](https://tailwindcss.com/)
- Backend powered by [Supabase](https://supabase.com/)
- Icons by [Lucide](https://lucide.dev/)
