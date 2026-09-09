import type { Metadata } from 'next';
import './globals.css';
export const metadata: Metadata = {
  title: 'NyctoType | BogosorGames Partner Pitch',
  description: '速度と戦術で競い合うマルチスレッドタイピングバトル。大会・コミュニティ運営をともに進めるパートナーを探しています。',
  robots: { index: false, follow: false },
  icons: { icon: '/favicon.png' },
};
export default function RootLayout({ children }: Readonly<{ children: React.ReactNode }>) {
  return <html lang="ja"><body>{children}</body></html>;
}
